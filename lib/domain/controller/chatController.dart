// ignore_for_file: unused_element

import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/controller_bridges/ChatToMessagesController.dart';
import 'package:citasnuevo/domain/controller_bridges/MessagesToChatControllerBridge.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../core/dependencies/error/Failure.dart';
import '../controller_bridges/HomeScreenCotrollerBridge.dart';
import '../entities/MessageEntity.dart';
import '../entities/ProfileEntity.dart';

abstract class ChatController
    implements
        ShouldControllerRemoveData<ChatInformationSender>,
        ShouldControllerUpdateData<ChatInformationSender>,
        ShouldControllerAddData<ChatInformationSender>,
        ModuleCleanerController {
  late ChatRepository chatRepository;
  late List<Chat> chatList;
  late bool anyChatOpen;
  late String lastChatToRecieveMessageId;
  late String chatOpenId;
  late int chatRemovedIndex;

  // ignore: cancel_subscriptions
  late StreamSubscription<dynamic>? chatListenerSubscription;
  // ignore: cancel_subscriptions
  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId, required String chatId});
  Future<Either<Failure, bool>> initializeChatListener();
  /* Future<Either<Failure, bool>> sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId});
  Future<void> setMessagesOnSeen({required String chatId});
  bool get getAnyChatOpen => this.anyChatOpen;
  set setAnyChatOpen(bool value);
  Future<Either<Failure, bool>> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});*/
  void _initializeChatListener();
  // void _initializeMessageListener();
  // void _reorderChatByLastMessageDate({required String chatIdToMoveUp});
}

class ChatControllerImpl implements ChatController {
  ChatRepository chatRepository;
  List<Chat> chatList = [];
  int chatRemovedIndex = -1;
  bool anyChatOpen = false;
  String lastChatToRecieveMessageId = "NOT_AVAILABLE";
  String chatOpenId = "";
  StreamSubscription<dynamic>? chatListenerSubscription;
  @override
  StreamController<ChatInformationSender>? addDataController =
      StreamController.broadcast();

  @override
  StreamController<ChatInformationSender>? removeDataController =
      StreamController.broadcast();

  @override
  StreamController<ChatInformationSender>? updateDataController =
      StreamController.broadcast();

  HomeScreenControllerBridge homeScreenControllreBridge;
  MessagesToChatControllerBridge messagesToChatControllerBridge;
  ChatToMessagesControllerBridge chatToMessagesControllerBridge;

  StreamController? get getChatStream => chatRepository.getChatStream;
  StreamController<dynamic> get getMessageStream =>
      chatRepository.getMessageStream;

  bool _checkIfChatExists({required String chatId}) {
    bool itExists = false;
    if (chatList.isNotEmpty) {
      chatList.forEach((a) {
        if (a.chatId == chatId) {
          itExists = true;
        }
      });
    }
    return itExists;
  }

  bool get getAnyChatOpen => this.anyChatOpen;
  ChatControllerImpl(
      {required this.chatRepository,
      required this.homeScreenControllreBridge,
      required this.messagesToChatControllerBridge,
      required this.chatToMessagesControllerBridge});

  set setAnyChatOpen(bool value) {
    this.anyChatOpen = value;

    if (value == false) {
      if (lastChatToRecieveMessageId != "NOT_AVAILABLE") {
        // _reorderChatByLastMessageDate(
        //   chatIdToMoveUp: lastChatToRecieveMessageId);
      }
    }
  }

  Future<Either<Failure, bool>> initializeChatListener() async {
    _initializeChatListener();
    return await chatRepository.initializeChatListener();
  }

  void _recieveLastChatMessageFromMessageController() {
    messagesToChatControllerBridge
        .controllerBridgeInformationSenderStream?.stream
        .listen((event) {
      String eventType = event["eventType"];
      if (eventType == "chatLastMessageAtInit") {
        List<Message> message = event["data"];
        for (int i = 0; i < message.length; i++) {
          for (int a = 0; a < chatList.length; a++) {
            if (chatList[a].chatId == message[i].chatId) {
              chatList[a].lastMessage = message[i];
            }
          }
        }
        _orderChatList();

        updateDataController?.add(ChatInformationSender(
            chatList: [],
            messageList: null,
            firstQuery: false,
            isChat: true,
            isModified: false,
            index: null,
            isDeleted: false));
      }
      if (eventType == "chatLastMessage") {
        Message message = event["data"];

        for (int i = 0; i < chatList.length; i++) {
          if (message.chatId == chatList[i].chatId) {
            chatList[i].lastMessage = message;
            _reorderChatByLastMessageDate(chatIdToMoveUp: message.chatId);
            updateDataController?.add(ChatInformationSender(
                chatList: [],
                messageList: null,
                firstQuery: false,
                isChat: true,
                isModified: false,
                index: null,
                isDeleted: false));
            break;
          }
        }
      }
      if (eventType == "unreadMessagesAtInit") {
        List<Map<String, dynamic>> dataList = event["data"];

        for (int a = 0; a < dataList.length; a++) {
          String chatId = dataList[a]["chatId"];
          int unreadMessages = dataList[a]["unreadMessages"];
          for (int i = 0; i < chatList.length; i++) {
            if (chatId == chatList[i].chatId) {
              chatList[i].unreadMessages = unreadMessages;

              break;
            }
          }
        }
        updateDataController?.add(ChatInformationSender(
            chatList: [],
            messageList: null,
            firstQuery: false,
            isChat: true,
            isModified: false,
            index: null,
            isDeleted: false));
      }
      if (eventType == "unreadMessages") {
        String chatId = event["data"]["chatId"];
        int unreadMessages = event["data"]["unreadMessages"];

        for (int i = 0; i < chatList.length; i++) {
          if (chatId == chatList[i].chatId) {
            chatList[i].unreadMessages = unreadMessages;
            updateDataController?.add(ChatInformationSender(
                chatList: [],
                messageList: null,
                firstQuery: false,
                isChat: true,
                isModified: false,
                index: null,
                isDeleted: false));
            break;
          }
        }
      }
    });
  }

// ignore: slash_for_doc_comments
/**  Orders the chat list 
*
* At the event "chatLastMessageAtinit" "eventType" we need to order the chad list by all the chat's "lastMessage" property
* 
* ! CAUTION:
* 
* ! USE ONLY AT THE "CHATLASTMESSAGEATINIT" EVENT TO FIRST ORDER THE CHAT ITEMS,
*/
  void _orderChatList() {
    List<Chat> chatsWithMessages = [];
    List<Chat> chatsWithoutMessages = [];
    List<Chat> finalList = [];

    List<Chat> finalChatList = []..addAll(chatList);
    for (int i = 0; i < finalChatList.length; i++) {
      if (finalChatList[i].lastMessage != null) {
        Chat chat = finalChatList[i];
        chatsWithMessages.add(chat);
      } else {
        Chat chat = finalChatList[i];
        chatsWithoutMessages.add(chat);
      }
    }

    if (chatsWithMessages.length > 0) {
      chatsWithMessages.sort((b, a) =>
          a.lastMessage!.messageDate.compareTo(b.lastMessage!.messageDate));
    }

    finalList.insertAll(0, chatsWithoutMessages);
    finalList.insertAll(0, chatsWithMessages);

    chatList = finalList;
  }

  @protected
  void _initializeChatListener() {
    chatListenerSubscription = chatRepository.chatStream()?.listen((event) {
      if (event is ChatException) {
        addDataController?.addError(event);
        chatListenerSubscription?.cancel();
      } else {
        bool isModified = event["modified"];
        bool isRemoved = event["removed"];
        bool firstQuery = event["firstQuery"];
        bool isAdded = event["added"];
        List<Chat> chatListFromStream = event["chatDataList"];
        if (firstQuery == true) {
          chatListFromStream.forEach((element) {
            if (_checkIfChatExists(chatId: element.chatId) == false) {
              chatList.add(element);
            }
          });
          addDataController?.add(ChatInformationSender(
              chatList: chatListFromStream,
              messageList: null,
              firstQuery: firstQuery,
              isModified: isModified,
              isChat: true,
              index: null,
              isDeleted: false));
        }

        if (isAdded) {
          chatListFromStream.forEach((element) {
            if (_checkIfChatExists(chatId: element.chatId) == false) {
              chatList.add(element);
            }
          });
          addDataController?.add(ChatInformationSender(
              chatList: chatListFromStream,
              messageList: null,
              firstQuery: firstQuery,
              isModified: isModified,
              isChat: true,
              index: null,
              isDeleted: false));

          _sendDataToMessagesController(
              isModified: isModified,
              isRemoved: isRemoved,
              isAdded: isAdded,
              chat: chatListFromStream);
        }

        if (isRemoved) {
          for (int a = 0; a < chatList.length; a++) {
            if (chatList[a].chatId == chatListFromStream.first.chatId) {
              chatList.removeAt(a);
              chatRemovedIndex = a;
              for (int i = 0; i < chatList.length; i++) {
                /*chatList[i].calculateUnreadMessages(
                    GlobalDataContainer.userId as String);*/
              }
              _sendDataToMessagesController(
                  isModified: isModified,
                  isRemoved: isRemoved,
                  isAdded: isAdded,
                  chat: chatListFromStream);

              removeDataController?.add(ChatInformationSender(
                  chatList: chatListFromStream,
                  messageList: null,
                  firstQuery: firstQuery,
                  isChat: true,
                  isModified: isModified,
                  index: null,
                  isDeleted: isRemoved));

              break;
            }
          }
        }

        if (isModified) {
          for (int a = 0; a < chatList.length; a++) {
            for (int z = 0; z < chatListFromStream.length; z++) {
              if (chatList[a].chatId == chatListFromStream[z].chatId) {
                chatList[a].remitenrPicture =
                    chatListFromStream[z].remitenrPicture;
                chatList[a].remitentPictureHash =
                    chatListFromStream[z].remitentPictureHash;
                chatList[a].remitentName = chatListFromStream[z].remitentName;
                chatList[a].notificationToken =
                    chatListFromStream[z].notificationToken;
                chatList[a].userBlocked = chatListFromStream[z].userBlocked;
                _sendDataToMessagesController(
                    isModified: isModified,
                    isRemoved: isRemoved,
                    isAdded: isAdded,
                    chat: chatListFromStream);

                updateDataController?.add(ChatInformationSender(
                    chatList: chatListFromStream,
                    messageList: null,
                    firstQuery: firstQuery,
                    isChat: true,
                    isModified: isModified,
                    index: null,
                    isDeleted: isRemoved));

                break;
              }
            }
          }
        }
        sendChatData();
        //   sendMessageData();
      }
    }, onError: (error) {
      addDataController?.addError(error);
    });
  }

  void _sendDataToMessagesController(
      {required bool isModified,
      required bool isRemoved,
      required bool isAdded,
      required List<Chat> chat}) {
    if (isAdded) {
      chatToMessagesControllerBridge.addInformation(
          information: {"eventType": "addNewMessageGroup", "data": chat});
    }
    if (isRemoved) {
      chatToMessagesControllerBridge.addInformation(
          information: {"eventType": "removeMessageGroup", "data": chat});
    }
    if (isModified) {
      chatToMessagesControllerBridge.addInformation(
          information: {"eventType": "modifyMessageGroup", "data": chat});
    }
  }

// ignore: slash_for_doc_comments
/**
 * Puts at the top the last chat to recieve a messageSenderBar
 * 
 * 
 * Any time a chat recieves a message, [ChatController] will be notified bi the [MessagesController]

 * Via [messagesToChatControllerBridge] whose stream is listened in the method [_recieveLastChatMessageFromMessageController]
 * 
 */
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
      {required String profileId, required String chatId}) async {
    for (int a = 0; a < chatList.length; a++) {
      if (chatList[a].chatId == chatId) {
        chatList[a].senderProfileLoadingState =
            SenderProfileLoadingState.LOADING;
      }
    }
    Either<Failure, Profile> result = await chatRepository.getUserProfile(
        profileId: profileId, chatId: chatId);

    result.fold((l) {
      for (int i = 0; i < chatList.length; i++) {
        if (profileId == chatList[i].remitentId &&
            chatList[i].chatId == chatId) {
          chatList[i].senderProfileLoadingState =
              SenderProfileLoadingState.ERROR;
        }
      }
    }, (r) {
      for (int i = 0; i < chatList.length; i++) {
        if (profileId == chatList[i].remitentId &&
            chatList[i].chatId == chatId) {
          chatList[i].senderProfile = r;
          chatList[i].senderProfileLoadingState =
              SenderProfileLoadingState.READY;
        }
      }
    });

    return result;
  }

  Future<Either<Failure, bool>> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId}) async {
    for (int i = 0; i < this.chatList.length; i++) {
      if (this.chatList[i].chatId == chatId) {
        this.chatList[i].isBeingDeleted = true;
        break;
      }

      updateDataController?.add(ChatInformationSender(
          chatList: chatList,
          messageList: [],
          firstQuery: false,
          isModified: false,
          index: 0,
          isDeleted: false,
          isChat: false));
    }
    var result = await chatRepository.deleteChat(
        remitent1: remitent1,
        remitent2: remitent2,
        reportDetails: reportDetails,
        chatId: chatId);

    result.fold((l) {
      for (int i = 0; i < this.chatList.length; i++) {
        if (this.chatList[i].chatId == chatId) {
          this.chatList[i].isBeingDeleted = false;
          break;
        }
      }
    }, (r) {});

    return result;
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      chatList.clear();
      chatRemovedIndex = -1;
      anyChatOpen = false;
      lastChatToRecieveMessageId = kNotAvailable;
      chatOpenId = "";
      chatListenerSubscription?.cancel();
      addDataController?.close();
      addDataController = new StreamController.broadcast();
      removeDataController?.close();
      removeDataController = new StreamController.broadcast();
      updateDataController?.close();
      updateDataController = new StreamController.broadcast();
      var result = chatRepository.clearModuleData();
      return result;
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    _recieveLastChatMessageFromMessageController();
    var result = chatRepository.initializeModuleData();

    return result;
  }

  void sendChatData() {
    int newChats = 0;

    for (int a = 0; a < chatList.length; a++) {
      if (chatList[a].lastMessage != null) {
        newChats = newChats + 1;
      }
    }

    homeScreenControllreBridge
        .addInformation(information: {"header": "chat", "data": newChats});
  }
}
