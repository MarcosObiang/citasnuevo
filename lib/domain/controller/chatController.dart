// ignore_for_file: unused_element

import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../core/dependencies/error/Failure.dart';
import '../entities/ProfileEntity.dart';

abstract class ChatController
    implements
        ShouldControllerRemoveData<ChatInformationSender>,
        ShouldControllerUpdateData<ChatInformationSender>,
        ShouldControllerAddData<ChatInformationSender>,
        ModuleCleaner,
       ExternalControllerDataSender<HomeScreenController> {
  late ChatRepository chatRepository;
  late List<Chat> chatList;
  late bool anyChatOpen;
  late String lastChatToRecieveMessageId;
  late String chatOpenId;
  late int chatRemovedIndex;

  // ignore: cancel_subscriptions
  late StreamSubscription<dynamic> chatListenerSubscription;
  // ignore: cancel_subscriptions
  late StreamSubscription<dynamic> messageListenerSubscription;
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
  void _initializeMessageListener();
  void _reorderChatByLastMessageDate({required String chatIdToMoveUp});
}

class ChatControllerImpl implements ChatController {
  ChatRepository chatRepository;
  List<Chat> chatList = [];
  int chatRemovedIndex = -1;
  bool anyChatOpen = false;
  String lastChatToRecieveMessageId = "NOT_AVAILABLE";
  String chatOpenId = "";
  late StreamSubscription<dynamic> chatListenerSubscription;
  late StreamSubscription<dynamic> messageListenerSubscription;
  @override
  late StreamController<ChatInformationSender>? addDataController =
      StreamController.broadcast();

  @override
  late StreamController<ChatInformationSender>? removeDataController =
      StreamController.broadcast();

  @override
  late StreamController<ChatInformationSender>? updateDataController =
      StreamController.broadcast();

        @override
  ControllerBridgeInformationSender<HomeScreenController>? controllerBridgeInformationSender;

  ChatControllerImpl(
      {required this.chatRepository,
      required this.controllerBridgeInformationSender});

  StreamController get getChatStream => chatRepository.getChatStream;
  StreamController<dynamic> get getMessageStream =>
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
    chatListenerSubscription = getChatStream.stream.listen((event) {
      if (event is ChatException) {
        addDataController?.addError(event);
        chatListenerSubscription.cancel();
      } else {
        bool isModified = event["modified"];
        bool isRemoved = event["removed"];
        bool firstQuery = event["firstQuery"];
        List<Chat> chatListFromStream = event["chatList"];
        if (firstQuery == true) {
          chatList.insertAll(0, chatListFromStream);
          addDataController?.add(ChatInformationSender(
              chatList: chatListFromStream,
              messageList: null,
              firstQuery: firstQuery,
              isModified: isModified,
              isChat: true,
              index: null,
              isDeleted: false));
              sendChatData();
              sendMessageData();
        }

        if (firstQuery == false && isRemoved == false && isModified == false) {
          chatList.insertAll(0, chatListFromStream);
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
            if (chatList[a].chatId == chatList.first.chatId) {
              chatList[a].remitenrPicture = chatList.first.remitenrPicture;
              chatList[a].remitentPictureHash =
                  chatList.first.remitentPictureHash;
              chatList[a].remitentName = chatList.first.remitentName;
              chatList[a].notificationToken = chatList.first.notificationToken;
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
        sendChatData();
      }
    }, onError: (error) {
      addDataController?.addError(error);
      chatListenerSubscription.cancel();
    });
  }

  @protected
  void _initializeMessageListener() {
    messageListenerSubscription = getMessageStream.stream.listen((event) async {
      if (event is ChatException) {
        chatListenerSubscription.cancel();
      } else {
        for (int i = 0; i < chatList.length; i++) {
          bool isModified = event["modified"];
          Message message = event["message"];
          if (chatList[i].chatId == message.chatId) {
            if (isModified == false) {
              if (chatList[i].chatId == message.chatId) {
                if (chatList[i].messagesList.length > 1) {
                  if (checkMessageTime(message.messageDate,
                      chatList[i].messagesList[0].messageDate)) {
                    DateTime tiempo = DateTime.fromMillisecondsSinceEpoch(
                        message.messageDate);
                    var dateformat = DateFormat.yMEd();
                    String dateText = dateformat.format(tiempo);

                    chatList[i].messagesList.insert(
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
                        messageList: [message],
                        firstQuery: false,
                        isModified: isModified,
                        isChat: false,
                        index: null,
                        isDeleted: false));
                    await Future.delayed(Duration(milliseconds: 200));
                  }
                } else {
                  DateTime tiempo =
                      DateTime.fromMillisecondsSinceEpoch(message.messageDate);
                  var dateformat = DateFormat.yMEd();
                  String dateText = dateformat.format(tiempo);
                  chatList[i].messagesList.insert(
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

                if (chatList[i].messagesList[a].messageId ==
                        message.messageId &&
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
              chatList[i].calculateUnreadMessages(
                  GlobalDataContainer.userId as String);
            }
          }
        }
      }
      sendMessageData();
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
  void clearModuleData() {
    chatList.clear();
    chatRemovedIndex = -1;
    anyChatOpen = false;
    lastChatToRecieveMessageId = kNotAvailable;
    chatOpenId = "";
    chatListenerSubscription.cancel();
    messageListenerSubscription.cancel();
    addDataController?.close();
    addDataController = new StreamController.broadcast();
    removeDataController?.close();
    removeDataController = new StreamController.broadcast();
    updateDataController?.close();
    updateDataController = new StreamController.broadcast();
    chatRepository.clearModuleData();
  }

  @override
  void initializeModuleData() {
    chatRepository.initializeModuleData();
  }

  void sendChatData() {
    int newChats = 0;

    for (int a = 0; a < chatList.length; a++) {
      if (chatList[a].messagesList.isEmpty == true) {
        newChats = newChats + 1;
      }
    }

   

        controllerBridgeInformationSender?.addInformation(information: {"header": "chat", "data": newChats});
  }

  void sendMessageData() {
    int newMessages = 0;

    for (int b = 0; b < chatList.length; b++) {
      if (chatList[b].messagesList.isNotEmpty == true) {
        newMessages = newMessages + chatList[b].unreadMessages;
      }
    }


                controllerBridgeInformationSender?.addInformation(information: {"header": "message", "data": newMessages});

  }




}
