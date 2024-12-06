// ignore_for_file: unused_element

import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../ControllerBridges/HomeScreenCotrollerBridge.dart';
import '../DataManager.dart';
import '../ProfileViewer/ProfileEntity.dart';
import '../controllerDef.dart';
import '../../core/error/Failure.dart';
import 'ChatEntity.dart';
import 'MessageEntity.dart';
import 'chatRepo.dart';

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
  Future<Either<Failure, bool>> createBlindDate();
  Future<Either<Failure, bool>> revealBlinDate({required String chatId});
  void closeAdsStreams();
  StreamController<Map<String, dynamic>> get rewardedAdvertismentStateStream;

  bool get getAnyChatOpen => this.anyChatOpen;
  set setAnyChatOpen(bool value);

  ///sends message
  Future<Either<Failure, bool>> sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId,
      required bool retryMessageSending});

  /// Deletes chat
  Future<Either<Failure, bool>> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});
  void _initializeChatListener();
  Future<void> setMessagesOnSeen({required String chatId});
  void _reorderChatByLastMessageDate({required String chatIdToMoveUp});
  Chat removeChatsFromList({required int chatIndex});
  void removeMessageFromChatList(
      {required String messageId, required String chatId});
  Future<Either<Failure, Uint8List?>> getImage();
  Future<Either<Failure, bool>> goToLocationSettings();
  Future<Either<Failure, bool>> showRewarded();

  bool isAppInForeground = false;
   bool get isUserPremium;
}

class ChatControllerImpl implements ChatController {
  bool isAppInForeground = false;

  @override
  bool get isUserPremium => chatRepository.isUserPremium;

  ChatRepository chatRepository;
  List<Chat> chatList = [];
  int chatRemovedIndex = -1;
  bool anyChatOpen = false;
  String lastChatToRecieveMessageId = kNotAvailable;
  String chatOpenId = "";
  int newChats = 0;
  int newMessages = 0;

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

  /// Processes the chat data received from the event.
  ///
  /// This function takes a [Map] of [String] to [dynamic] as input, which represents the chat data received from the event.
  /// It checks if the event is an [Exception] and if so, adds the error to the [addDataController] and cancels the [chatListenerSubscription].
  /// If the event is not an [Exception], it extracts the necessary information from the event, such as whether the chat is modified or removed,
  /// whether it is the first query, and the list of chat objects.
  /// If it is the first query, it checks if each chat object exists in the [chatList] and adds it if it doesn't.
  /// It then calculates the new chats and messages, and adds a [ChatInformationSender] object to the [addDataController] with the updated chat list.
  /// If it is not the first query and the chat is not removed or modified, it performs the same steps as the first query.
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
              homeScreenControllreBridge.addInformation(information: {
                "data": element.remitentId,
                "header": "new_chat"
              });
            
          }
        });
        calculatenewChats();
        calculateNewMessages();
        addDataController?.add(ChatInformationSender(
            newChats: newChats,
            newMessages: newMessages,
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
            if (element.isBlindDate) {
              print("new blind chat");
              homeScreenControllreBridge.addInformation(information: {
                "data": element.remitentId,
                "header": "new_blind_chat"
              });
            }
          }
        });
        calculatenewChats();
        calculateNewMessages();
        addDataController?.add(ChatInformationSender(
            newChats: newChats,
            newMessages: newMessages,
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
            // chatList.removeAt(a);
            chatList[a].removePending = true;
            //  chatRemovedIndex = a;
            for (int i = 0; i < chatList.length; i++) {
              chatList[i].calculateUnreadMessages(GlobalDataContainer.userId);
            }
            calculatenewChats();
            calculateNewMessages();
            removeDataController?.add(ChatInformationSender(
                newChats: newChats,
                newMessages: newMessages,
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
              chatList[a].remitentPicture =
                  chatListFromStream[z].remitentPicture;
              chatList[a].userBlocked = chatListFromStream[z].userBlocked;
              chatList[a].isBlindDate = chatListFromStream[z].isBlindDate;

              chatList[a].remitentName = chatListFromStream[z].remitentName;
              chatList[a].notificationToken =
                  chatListFromStream[z].notificationToken;
              updateDataController?.add(ChatInformationSender(
                  newChats: newChats,
                  newMessages: newMessages,
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
    }
  }

  @protected
  void _initializeChatListener() {
    chatListenerSubscription = getChatStream?.stream.listen((event) {
      String payloadType = event["payloadType"];

      if (payloadType == "chat") {
        _chatDataProcessing(event);
      }
      if (payloadType == "chatMessage") {
        _messageDataProcesing(event);
      }
    }, onError: (error) {
      addDataController?.addError(error);
      
            //  markMessageWithErrorStatus(chatId: message.chatId);

    });
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
          newChats: newChats,
          newMessages: newMessages,
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

  Chat removeChatsFromList({required int chatIndex}) {
    Chat removedChat = chatList.removeAt(chatIndex);

    calculatenewChats();
    calculateNewMessages();
    updateDataController?.add(ChatInformationSender(
        newChats: newChats,
        newMessages: newMessages,
        chatList: chatList,
        messageList: [],
        firstQuery: false,
        isModified: false,
        index: 0,
        isDeleted: false,
        isChat: false));
    return removedChat;
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

  void calculatenewChats() {
    newChats = 0;
    for (int a = 0; a < chatList.length; a++) {
      if (chatList[a].messagesList.isEmpty == true) {
        newChats = newChats + 1;
      }
    }
  }

  /// Opens the system settings to activate location
  ///
  /// When the user has permanently denied the location service to the app
  ///
  /// the location must permission must be given to the app in the system settings

  Future<Either<Failure, bool>> goToLocationSettings() async {
    return await chatRepository.goToAppSettings();
  }

  //
  //
  //---MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES
  //---MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES
  //---MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES
  //---MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES
  //---MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES MESSAGES
  //
  //
  //
  @protected
  void _messageDataProcesing(Map<String, dynamic> event) {
    for (int i = 0; i < chatList.length; i++) {
      bool isModified = event["modified"];
      Message message = event["message"];
      if (message.messageType == MessageType.IMAGE) {
        message.initMessage();
      }

      ///Looking for the chat the message is for
      ///
      ///
      if (chatList[i].chatId == message.chatId) {
        /// The only way a message could be modified if it hsa been read by the remitent, so basically we are checking if a message has been read
        ///
        if (message.senderId == GlobalDataContainer.userId) {
          if (isModified == false) {
            _addThisUserMessageToChatList(
                message: message, chatIndex: i, isModified: isModified);

            calculateNewMessages();
            calculatenewChats();

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
                  chatList[i].messagesList[a].read == false) {
                chatList[i].messagesList[a].read = true;
                updateDataController?.add(ChatInformationSender(
                    newChats: newChats,
                    newMessages: newMessages,
                    chatList: chatList,
                    messageList: [message],
                    firstQuery: false,
                    isModified: isModified,
                    isChat: false,
                    index: null,
                    isDeleted: false));
                break;
              }
            }
            chatList[i].calculateUnreadMessages(GlobalDataContainer.userId);
          }
        }

        if (message.senderId != GlobalDataContainer.userId) {
          if (isModified == false) {
            if (chatList[i].messagesList.length > 1) {
              if (shouldAddTimeMessage(
                  message.messageDate,
                  chatList[i]
                      .messagesList
                      .firstWhere((element) =>
                          element.messageSendingState !=
                          MessageSendingState.SENDING)
                      .messageDate)) {
                addDateMessageToChat(
                    message: message, index: i, isModified: isModified);
              }
            }

            if (chatList[i].messagesList.length <= 1) {
              addDateMessageToChat(
                  message: message, index: i, isModified: isModified);
            }

            calculateNewMessages();
            calculatenewChats();
            _addRemitentChatMessageToChatList(
                message: message, chatIndex: i, isModified: isModified);

            if (chatList.length > 1) {
              lastChatToRecieveMessageId = message.chatId;
              if (this.anyChatOpen == false) {
                _reorderChatByLastMessageDate(chatIdToMoveUp: message.chatId);
              }
            }
            if (message.chatId == chatOpenId) {
              setMessagesOnSeen(chatId: message.chatId);
            }
          }
          if (isModified == true) {
            for (int a = 0; a < chatList[i].messagesList.length; a++) {
              if (chatList[i].messagesList[a].messageId == message.messageId &&
                  chatList[i].messagesList[a].read == false) {
                chatList[i].messagesList[a].read = true;
                break;
              }
            }
            chatList[i].calculateUnreadMessages(GlobalDataContainer.userId);
            updateMessageState(message: message, isModified: isModified);
          }
        }
      }
    }
  }

  Future<Either<Failure, bool>> initializeMessageListener() async {
    return await chatRepository.initializeMessageListener();
  }

  void updateMessageState(
      {required Message message, required bool isModified}) {
    updateDataController?.add(ChatInformationSender(
        newChats: newChats,
        newMessages: newMessages,
        chatList: chatList,
        messageList: [message],
        firstQuery: false,
        isModified: isModified,
        isChat: false,
        index: null,
        isDeleted: false));
  }

  void addDateMessageToChat(
      {required Message message,
      required int index,
      required bool isModified}) {
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
        newChats: newChats,
        newMessages: newMessages,
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
  }

  /// Checks if two consecutive messages have the same date (ymd), if it returns true,
  ///  it will mean we should add a new [Message] of type [MessageType.DATE] above the new message
  bool shouldAddTimeMessage(int currentMessageTime, int lastMessageTime,
      {bool forceDateMessage = false}) {
    bool addNewDateMessage = false;

    DateTime lastMessageDateTime =
        DateTime.fromMillisecondsSinceEpoch(lastMessageTime);
    DateTime currentMessageDateTime =
        DateTime.fromMillisecondsSinceEpoch(currentMessageTime);

    if (lastMessageDateTime.year != currentMessageDateTime.year ||
        lastMessageDateTime.month != currentMessageDateTime.month ||
        lastMessageDateTime.day != currentMessageDateTime.day) {
      addNewDateMessage = true;
    }

    return addNewDateMessage;
  }

  void calculateNewMessages() {
    newMessages = 0;
    for (int b = 0; b < chatList.length; b++) {
      if (chatList[b].messagesList.isNotEmpty == true) {
        newMessages = newMessages + chatList[b].unreadMessages;
      }
    }
  }

  /// Checks if there is a message pending of being send before the user tries to send more
  ///
  /// only one message at a time can be sended
  bool isChatMessageSendingQuequeEmpty(
      {required String chatId, required bool retrySendingMessage}) {
    bool result = true;
    if (retrySendingMessage == false) {
      for (int i = 0; i < chatList.length; i++) {
        if (chatId == chatList[i].chatId) {
          if (chatList[i].messagesList.isNotEmpty) {
            for (int k = 0; k < chatList[i].messagesList.length; k++) {
              if (chatList[i].messagesList[k].senderId ==
                      GlobalDataContainer.userId &&
                  (chatList[i].messagesList[k].messageType !=
                          MessageType.DATE &&
                      (chatList[i].messagesList[k].messageSendingState ==
                              MessageSendingState.ERROR ||
                          chatList[i].messagesList[k].messageSendingState ==
                              MessageSendingState.SENDING))) {
                result = false;
                break;
              }
            }
          }
        }
      }
    }

    return result;
  }

  bool isChatListEmpty(String chatId) {
    bool isEmpty = false;
    for (int i = 0; i < chatList.length; i++) {
      if (chatList[i].chatId == chatId) {
        if (chatList[i].messagesList.isEmpty) {
          isEmpty = true;
        }
      }
    }
    return isEmpty;
  }

  Future<Either<Failure, bool>> sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId,
      required bool retryMessageSending,
      Uint8List? filedata}) async {
    if (isChatMessageSendingQuequeEmpty(
        chatId: message.chatId, retrySendingMessage: retryMessageSending)) {
      if (isChatListEmpty(message.chatId)) {
        var dateformat = DateFormat.yMEd();

        DateTime tiempo =
            DateTime.fromMillisecondsSinceEpoch(message.messageDate);
        String dateText = dateformat.format(tiempo);
        int index =
            chatList.indexWhere((element) => element.chatId == message.chatId);

        addDateMessageToChat(
            message: Message(
                messageDateText: dateText,
                read: true,
                isResponse: false,
                data: "data",
                chatId: message.chatId,
                senderId: kNotAvailable,
                messageId: "messageId",
                messageDate: tiempo.millisecondsSinceEpoch,
                messageType: MessageType.DATE,
                fileData: filedata),
            index: index,
            isModified: false);
      }

      if (retryMessageSending == false) {
        addTemporalMessageToChatList(
            messageSendingState: MessageSendingState.SENDING, message: message);
      }
      if (retryMessageSending == true) {
        int index =
            chatList.indexWhere((element) => element.chatId == message.chatId);
        chatList[index].messagesList.removeWhere((element) =>
            element.messageSendingState == MessageSendingState.ERROR &&
            element.senderId == GlobalDataContainer.userId);
        removeDataController?.add(ChatInformationSender(
            newChats: newChats,
            newMessages: newMessages,
            chatList: chatList,
            messageList: [message],
            firstQuery: false,
            isModified: false,
            isChat: false,
            index: null,
            isDeleted: false));
        addTemporalMessageToChatList(
            messageSendingState: MessageSendingState.SENDING, message: message);
      }

      var result = await chatRepository.sendMessages(
          message: message,
          messageNotificationToken: messageNotificationToken,
          remitentId: remitentId);
      result.fold((l) {
        markMessageWithErrorStatus(chatId: message.chatId);
      }, (r) {});
      return result;
    } else {
      ChatFailure chatFailure =
          ChatFailure(message: "MESSAGE_QUEQUE_IS_NOT_EMPTY");
      return Left(chatFailure);
    }
  }

  void markMessageWithErrorStatus({required String chatId}) {
    int chatIndex = chatList.indexWhere((element) => element.chatId == chatId);
    int messageIndex = chatList[chatIndex].messagesList.indexWhere((element) =>
        element.senderId == GlobalDataContainer.userId &&
        element.messageType != MessageType.DATE);

    chatList[chatIndex].messagesList[messageIndex].messageSendingState =
        MessageSendingState.ERROR;
    updateDataController?.add(ChatInformationSender(
        newChats: newChats,
        newMessages: newMessages,
        chatList: chatList,
        messageList: [chatList[chatIndex].messagesList[messageIndex]],
        firstQuery: false,
        isModified: false,
        isChat: false,
        index: null,
        isDeleted: false));
  }

  /// Adds message to the chat list while the real message has not reached the server
  ///
  /// it is used to give the user a fast feel while the meessage goes over the network
  ///
  ///

  void addTemporalMessageToChatList(
      {required MessageSendingState messageSendingState,
      required Message message}) {
    for (int i = 0; i < chatList.length; i++) {
      if (chatList[i].chatId == message.chatId) {
        message.messageSendingState = messageSendingState;
        if (shouldAddTimeMessage(
            message.messageDate, chatList[i].messagesList.first.messageDate)) {
          var dateformat = DateFormat.yMEd();

          DateTime tiempo =
              DateTime.fromMillisecondsSinceEpoch(message.messageDate);
          String dateText = dateformat.format(tiempo);
          addDateMessageToChat(
              message: Message(
                  messageDateText: dateText,
                  read: false,
                  isResponse: false,
                  data: "data",
                  chatId: message.chatId,
                  senderId: kNotAvailable,
                  messageId: "messageId",
                  messageDate: tiempo.millisecondsSinceEpoch,
                  messageType: MessageType.DATE),
              index: 0,
              isModified: false);
          chatList[i].messagesList.insert(0, message);
          updateDataController?.add(ChatInformationSender(
              newChats: newChats,
              newMessages: newMessages,
              chatList: chatList,
              messageList: [message],
              firstQuery: false,
              isModified: false,
              isChat: false,
              index: null,
              isDeleted: false));
        } else {
          chatList[i].messagesList.insert(0, message);
          updateDataController?.add(ChatInformationSender(
              newChats: newChats,
              newMessages: newMessages,
              chatList: chatList,
              messageList: [message],
              firstQuery: false,
              isModified: false,
              isChat: false,
              index: null,
              isDeleted: false));
        }
      }
    }
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

@override
   Future<Either<Failure, bool>> showRewarded() async {
    return chatRepository.showRewarded();
  }

  @override
  void removeMessageFromChatList(
      {required String messageId, required String chatId}) {
    int chatIndex = chatList.indexWhere((element) => element.chatId == chatId);
    for (int i = 0; i < chatList[chatIndex].messagesList.length; i++) {
      if (chatList[chatIndex].messagesList[i].messageId == messageId) {
        Message message = chatList[chatIndex].messagesList.removeAt(i);
        removeDataController?.add(ChatInformationSender(
            newChats: newChats,
            newMessages: newMessages,
            chatList: chatList,
            messageList: [message],
            firstQuery: false,
            isModified: false,
            isChat: false,
            index: null,
            isDeleted: false));
      }
    }
  }

  void _addRemitentChatMessageToChatList(
      {required Message message,
      required int chatIndex,
      required bool isModified}) {
    message.messageSendingState = MessageSendingState.SENT;
    chatList[chatIndex].messagesList.insert(0, message);
    if (message.senderId != GlobalDataContainer.userId &&
        message.read == false) {
      chatList[chatIndex].unreadMessages += 1;
    }
    calculateNewMessages();

    addDataController?.add(ChatInformationSender(
        newChats: newChats,
        newMessages: newMessages,
        chatList: chatList,
        messageList: [message],
        firstQuery: false,
        isModified: isModified,
        isChat: false,
        index: null,
        isDeleted: false));
  }

  void _addThisUserMessageToChatList(
      {required Message message,
      required int chatIndex,
      required bool isModified}) {
    if (message.senderId == GlobalDataContainer.userId) {
      for (int i = 0; i < chatList[chatIndex].messagesList.length; i++) {
        if (chatList[chatIndex].messagesList[i].messageSendingState !=
            MessageSendingState.SENT) {
          chatList[chatIndex].messagesList[i] = message;
          chatList[chatIndex].messagesList[i].messageSendingState =
              MessageSendingState.SENT;
          addDataController?.add(ChatInformationSender(
              newChats: newChats,
              newMessages: newMessages,
              chatList: chatList,
              messageList: [message],
              firstQuery: false,
              isModified: isModified,
              isChat: false,
              index: null,
              isDeleted: false));
        }
      }
    }
  }

  /// Call this function when a new message from the remitent arrives to let them know that we read their message
  ///
  /// Call it after the new message has been added to the [chat.messageList] and pass the [chatId] of the message
  ///
  ///
  ///
  ///
  ///
  ///

  Future<void> setMessagesOnSeen({required String chatId}) async {
    List<Message> messagesIdList = [];
    for (int i = 0; i < chatList.length; i++) {
      if (chatList[i].chatId == chatId) {
        chatList[i].unreadMessages = 0;
        for (int b = 0; b < chatList[i].messagesList.length; b++) {
          if (chatList[i].messagesList[b].read == false &&
              chatList[i].messagesList[b].senderId !=
                  GlobalDataContainer.userId &&
              chatList[i].messagesList[b].messageType != MessageType.DATE) {
            messagesIdList.add(chatList[i].messagesList[b]);
          }
          if (chatList[i].messagesList[b].read == true &&
              chatList[i].messagesList[b].senderId !=
                  GlobalDataContainer.userId &&
              chatList[i].messagesList[b].messageType != MessageType.DATE) {
            break;
          }
        }
      }
    }
    calculateNewMessages();
    updateDataController?.add(ChatInformationSender(
        newChats: newChats,
        newMessages: newMessages,
        chatList: chatList,
        messageList: [],
        firstQuery: false,
        isModified: false,
        isChat: false,
        index: null,
        isDeleted: false));

    await chatRepository.messagesSeen(messaages: messagesIdList);
  }

  @override
  Future<Either<Failure, Uint8List?>> getImage() {
    return chatRepository.getImage();
  }

  @override
  Future<Either<Failure, bool>> createBlindDate() async {
    return await chatRepository.createBlindDate();
  }

  @override
  Future<Either<Failure, bool>> revealBlinDate({required String chatId}) async {
    return await chatRepository.revealBlindDate(chatId: chatId);
  }
  
  @override
  void closeAdsStreams() {
this.chatRepository.closeAdsStreams();  }
  
  @override
  // TODO: implement rewardedAdvertismentStateStream
  StreamController<Map<String, dynamic>> get rewardedAdvertismentStateStream =>this.chatRepository.rewardedStatusListener;
}
