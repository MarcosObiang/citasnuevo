import 'dart:async';

import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

import '../../core/dependencies/error/Failure.dart';
import '../entities/ProfileEntity.dart';

class ChatController {
  ChatRepository chatRepository;
  List<Chat> chatList = [];
  int chatRemovedIndex = -1;
  bool anyChatOpen = false;
  String lastChatToRecieveMessageId = "NOT_AVAILABLE";
  String chatOpenId = "";
  ChatController({
    required this.chatRepository,
  });

  StreamController get getChatStream => chatRepository.getChatStream;
  StreamController<Map<String, dynamic>> get getMessageStream =>
      chatRepository.getMessageStream;

  bool get getAnyChatOpen => this.anyChatOpen;

  set setAnyChatOpen(bool value) {
    this.anyChatOpen = value;

    if (value == false) {
      if (lastChatToRecieveMessageId != "NOT_AVAILABLE") {
        _reorderChatByLastMessageDate(
            chatIdToMoveUp: lastChatToRecieveMessageId);
      }
    }
  }

  Future<Either<Failure, bool>> initializeChatListener() async {
    _initializeChatListener();
    return await chatRepository.initializeChatListener();
  }

  Future<Either<Failure, bool>> initializeMessageListener() async {
    _initializeMessageListener();
    return await chatRepository.initializeMessageListener();
  }

  @protected
  void _initializeChatListener() {
    getChatStream.stream.listen((event) {
      bool isModified = event["modified"];
      bool isRemoved = event["removed"];
      List<Chat> chatListFromStream = event["chatList"];

      if (isRemoved == false && isModified == false) {
        chatList.insertAll(0, chatListFromStream);
      }

      if (isRemoved) {
        for (int a = 0; a < chatList.length; a++) {
          if (chatList[a].chatId == chatListFromStream.first.chatId) {
            chatList.removeAt(a);
            chatRemovedIndex = a;
            break;
          }
        }
      }

      if (isModified) {
        for (int a = 0; a < chatList.length; a++) {
          if (chatList[a].chatId == chatList.first.chatId) {
            chatList[a].remitenrPicture = chatList.first.remitenrPicture;
            chatList[a].remitentPictureHash =
                chatList.first.remitentPictureHash;
            chatList[a].remitentName = chatList.first.remitentName;
            chatList[a].notificationToken = chatList.first.notificationToken;

            break;
          }
        }
      }
    });
  }

  @protected
  void _initializeMessageListener() {
    getMessageStream.stream.listen((event) {
      for (int i = 0; i < chatList.length; i++) {
        bool isModified = event["modified"];
        Message message = event["message"];
        if (chatList[i].chatId == message.chatId) {
          if (isModified == false) {
            if (chatList[i].chatId == message.chatId)
              chatList[i].messagesList.insert(0, message);
            chatList[i].unreadMessages += 1;
            if (chatList.length > 1) {
              lastChatToRecieveMessageId = message.chatId;
              if (this.anyChatOpen == false) {
                _reorderChatByLastMessageDate(chatIdToMoveUp: message.chatId);
              }
            }
          }
          if (isModified == true) {
            for (int a = 0; a < chatList[i].messagesList.length; a++) {
              if (chatList[i].messagesList[a].messageId == message.messageId &&
                  chatList[i].messagesList[a].senderId !=
                      GlobalDataContainer.userId) {
                chatList[i].messagesList[a].read = true;
                chatList[i].calculateUnreadMessages();
              }
            }
          }
        }
      }
    });
  }

  Future<void> setMessagesOnSeen({required String chatId}) async {
    List<String> messagesIdList = [];
    for (int i = 0; i < chatList.length; i++) {
      if (chatList[i].chatId == chatId) {
        chatList[i].unreadMessages = 0;
        for (int b = 0; b < chatList[i].messagesList.length; b++) {
          if (chatList[i].messagesList[b].read == false &&
              chatList[i].messagesList[b].senderId !=
                  GlobalDataContainer.userId) {
            messagesIdList.add(chatList[i].messagesList[b].messageId);
          } else {
            break;
          }
        }
      }
    }
    await chatRepository.setMessagesOnSeen(data: messagesIdList);
  }

  @protected
  void _reorderChatByLastMessageDate({required String chatIdToMoveUp}) {
    if (chatList.first.chatId != chatIdToMoveUp) {
      for (int i = 0; i < chatList.length; i++) {
        if (chatList[i].chatId == chatIdToMoveUp) {
          Chat chat = chatList.removeAt(i);
          chatList.insert(0, chat);

          break;
        }
      }
    }
  }

  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId}) async {
    Either<Failure, Profile> result =
        await chatRepository.getUserProfile(profileId: profileId);

    result.fold((l) {}, (r) {
      for (int i = 0; i < chatList.length; i++) {
        if (profileId == chatList[i].remitentId) {
          chatList[i].senderProfile = r;
        }
      }
    });

    return result;
  }

  Future<Either<Failure, List<Message>>> loadMoreMessages(
      {required String chatId, required String lastMessageId}) async {
    late Either<Failure, List<Message>> result;

    if (chatList.isNotEmpty == true) {
      for (int i = 0; i < chatList.length; i++) {
        if (chatList[i].chatId == chatId) {
          chatList[i].additionalMessagesLoadState =
              AdditionalMessagesLoadState.LOADING;
          result = await chatRepository.loadMoreMessages(
              chatId: chatId, lastMessageId: lastMessageId);

          result.fold((l) {
            chatList[i].additionalMessagesLoadState =
                AdditionalMessagesLoadState.ERROR;
            return Left(l);
          }, (r) {
            if (r.isEmpty) {
              chatList[i].additionalMessagesLoadState =
                  AdditionalMessagesLoadState.NO_MORE_MESSAGES;
            } else {
              chatList[i].additionalMessagesLoadState =
                  AdditionalMessagesLoadState.READY;
              chatList[i].messagesList.addAll(r);
            }

            return Right(r);
          });
        }
      }
    }
    if (chatList.isNotEmpty == false) {
      return Left(ChatFailure());
    }
    return result;
  }

  Future<Either<Failure, bool>> sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId}) async {
    return await chatRepository.sendMessages(
        message: message,
        messageNotificationToken: messageNotificationToken,
        remitentId: remitentId);
  }
}
