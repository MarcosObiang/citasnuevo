// ignore_for_file: unused_element

import 'dart:async';

import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../core/error/Failure.dart';
import '../controller_bridges/HomeScreenCotrollerBridge.dart';
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
  late StreamSubscription<dynamic>? messageListenerSubscription;
  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId, required String chatId});
  Future<Either<Failure, bool>> initializeChatListener();
  Future<Either<Failure, bool>> initializeMessageListener();
  Future<Either<Failure, bool>> sendMessage(
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
      required String chatId});
  void _initializeChatListener();
  void _reorderChatByLastMessageDate({required String chatIdToMoveUp});
}

class ChatControllerImpl implements ChatController {
  ChatRepository chatRepository;
  List<Chat> chatList = [];
  int chatRemovedIndex = -1;
  bool anyChatOpen = false;
  String lastChatToRecieveMessageId = "NOT_AVAILABLE";
  String chatOpenId = "";
  StreamSubscription<dynamic>? chatListenerSubscription;
  StreamSubscription<dynamic>? messageListenerSubscription;
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

  StreamController? get getChatStream =>
      chatRepository.getStreamParserController;

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
      {required this.chatRepository, required this.homeScreenControllreBridge});

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
    return await chatRepository.initializeMessageListener();
  }

  void _chatDataProcessing(Map<String, dynamic> event) {
    if (event is Exception) {
      addDataController?.addError(event);
      chatListenerSubscription?.cancel();
    } else {
      bool isModified = event["modified"];
      bool isRemoved = event["removed"];
      bool firstQuery = event["firstQuery"];
      List<Chat> chatListFromStream = event["chatList"];
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

      if (firstQuery == false && isRemoved == false && isModified == false) {
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

      if (isRemoved) {
        for (int a = 0; a < chatList.length; a++) {
          if (chatList[a].chatId == chatListFromStream.first.chatId) {
            chatList.removeAt(a);
            chatRemovedIndex = a;
            for (int i = 0; i < chatList.length; i++) {
              chatList[i].calculateUnreadMessages(
                  GlobalDataContainer.userId as String);
            }
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
              chatList[a].userBlocked = chatListFromStream[z].userBlocked;
              chatList[a].remitentPictureHash =
                  chatListFromStream[z].remitentPictureHash;
              chatList[a].remitentName = chatListFromStream[z].remitentName;
              chatList[a].notificationToken =
                  chatListFromStream[z].notificationToken;
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
      sendMessageData();
    }
  }

  @protected
  void _initializeChatListener() {
    chatListenerSubscription = getChatStream?.stream.listen((event) {
      String payloadType = event["payloadType"];

      if (payloadType == "chat") {
        _chatDataProcessing(event);
      } else {
        _messageDataProcesing(event);
        sendChatData();
        sendMessageData();
      }
    }, onError: (error) {
      addDataController?.addError(error);
    });
  }

  Future<void> addDateMessageToChat(
      {required Message message,
      required int index,
      required bool isModified}) async {
    DateTime tiempo = DateTime.fromMillisecondsSinceEpoch(message.messageDate);
    var dateformat = DateFormat.yMEd();
    String dateText = dateformat.format(tiempo);
    chatList[index].messagesList.insert(
        0,
        Message(
            messageDateText: dateText,
            read: true,
            isResponse: false,
            data: "data",
            chatId: message.chatId,
            senderId: kNotAvailable,
            messageId: "messageId",
            messageDate: tiempo.millisecondsSinceEpoch,
            messageType: MessageType.DATE));
    addDataController?.add(ChatInformationSender(
        chatList: chatList,
        messageList: [
          Message(
              messageDateText: dateText,
              read: true,
              isResponse: false,
              data: "data",
              chatId: message.chatId,
              senderId: kNotAvailable,
              messageId: "messageId",
              messageDate: tiempo.millisecondsSinceEpoch,
              messageType: MessageType.DATE)
        ],
        firstQuery: false,
        isModified: isModified,
        isChat: false,
        index: null,
        isDeleted: false));
    await Future.delayed(Duration(milliseconds: 200));
  }

  @protected
  void _messageDataProcesing(Map<String, dynamic> event) async {
    for (int i = 0; i < chatList.length; i++) {
      bool isModified = event["modified"];
      Message message = event["message"];

      ///Looking for the chat the message is for
      ///
      ///
      if (chatList[i].chatId == message.chatId) {
        /// The only way a message could be modified if it hsa been read by the remitent, so basically we are checking if a message has been read
        ///
        ///
        if (isModified == false) {
          if (chatList[i].messagesList.length > 1) {
            if (checkMessageTime(
                message.messageDate, chatList[i].messagesList[0].messageDate)) {
              await addDateMessageToChat(
                  message: message, index: i, isModified: isModified);
            }
          }

          if (chatList[i].messagesList.length <= 1) {
            await addDateMessageToChat(
                message: message, index: i, isModified: isModified);
          }

          chatList[i].messagesList.insert(0, message);
          addDataController?.add(ChatInformationSender(
              chatList: chatList,
              messageList: [message],
              firstQuery: false,
              isModified: isModified,
              isChat: false,
              index: null,
              isDeleted: false));

          if (message.senderId != GlobalDataContainer.userId) {
            chatList[i].unreadMessages += 1;
          }

          if (chatList.length > 1) {
            lastChatToRecieveMessageId = message.chatId;
            if (this.anyChatOpen == false) {
              _reorderChatByLastMessageDate(chatIdToMoveUp: message.chatId);
            }
          }
        }
        if (isModified == true) {
          for (int a = 0; a < chatList[i].messagesList.length; a++) {
            ///When we reach a message from the remitent wich has been read
            ///
            ///we can asume that all the above messages had been read too, so there is no point in checking all the messages
            ///
            ///and we break the foo loop
            if (chatList[i].messagesList[a].read == true) {
              break;
            }

            if (chatList[i].messagesList[a].messageId == message.messageId &&
                chatList[i].messagesList[a].read == false) {
              chatList[i].messagesList[a].read = true;
            }
            updateDataController?.add(ChatInformationSender(
                chatList: chatList,
                messageList: [message],
                firstQuery: false,
                isModified: isModified,
                isChat: false,
                index: null,
                isDeleted: false));
          }
          chatList[i]
              .calculateUnreadMessages(GlobalDataContainer.userId as String);
        }
      }
    }
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
          }
          if (chatList[i].messagesList[b].read == true &&
              chatList[i].messagesList[b].senderId !=
                  GlobalDataContainer.userId) {
            break;
          }
        }
      }
    }
    await chatRepository.setMessagesOnSeen(data: messagesIdList);
  }

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

  Future<Either<Failure, bool>> sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId}) async {
    return await chatRepository.sendMessages(
        message: message,
        messageNotificationToken: messageNotificationToken,
        remitentId: remitentId);
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
    Future.delayed(Duration(milliseconds: 1000));
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

  /// Checks if two consecutive messages have the same date (ymd), if it returns true, it will mean we should add a new [Message] of type [MessageType.DATE] above the new message
  bool checkMessageTime(int currentMessageTime, int lastMessageTime) {
    bool addNewDateMessage = false;

    DateTime lastMessageDateTime =
        DateTime.fromMillisecondsSinceEpoch(lastMessageTime);
    DateTime currentMessageDateTime =
        DateTime.fromMillisecondsSinceEpoch(currentMessageTime);

    if (currentMessageDateTime.year != lastMessageDateTime.year ||
        currentMessageDateTime.month != lastMessageDateTime.month ||
        currentMessageDateTime.day != lastMessageDateTime.day) {
      addNewDateMessage = true;
    }

    return addNewDateMessage;
  }

  @override
  Either<Failure, bool> clearModuleData() {
    chatList.clear();
    chatRemovedIndex = -1;
    anyChatOpen = false;
    lastChatToRecieveMessageId = kNotAvailable;
    chatOpenId = "";
    chatListenerSubscription?.cancel();
    messageListenerSubscription?.cancel();
    addDataController?.close();
    addDataController = new StreamController.broadcast();
    removeDataController?.close();
    removeDataController = new StreamController.broadcast();
    updateDataController?.close();
    updateDataController = new StreamController.broadcast();
    return chatRepository.clearModuleData();
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    return chatRepository.initializeModuleData();
  }

  void sendChatData() {
    int newChats = 0;

    for (int a = 0; a < chatList.length; a++) {
      if (chatList[a].messagesList.isEmpty == true) {
        newChats = newChats + 1;
      }
    }

    homeScreenControllreBridge
        .addInformation(information: {"header": "chat", "data": newChats});
  }

  void sendMessageData() {
    int newMessages = 0;

    for (int b = 0; b < chatList.length; b++) {
      if (chatList[b].messagesList.isNotEmpty == true) {
        newMessages = newMessages + chatList[b].unreadMessages;
      }
    }

    homeScreenControllreBridge.addInformation(
        information: {"header": "message", "data": newMessages});
  }
}
