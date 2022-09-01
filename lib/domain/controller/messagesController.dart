import 'dart:async';

import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/messagesRepo/messagesRepo.dart';
import 'package:intl/intl.dart';

import '../../core/params_types/params_and_types.dart';
import '../controller_bridges/ChatToMessagesController.dart';
import '../controller_bridges/MessagesToChatControllerBridge.dart';
import '../entities/ProfileEntity.dart';

abstract class MessagesController
    implements
        ModuleCleanerController,
        ShouldControllerAddData,
        ShouldControllerUpdateData {
  late MessagesRepo messagesRepository;
  late List<MessagesGroup> messageGroupList;
  Future<void> setMessagesOnSeen({required String chatId});
  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId, required String chatId});
  Future<Either<Failure, bool>> sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId});
  Future<Either<Failure, bool>> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});
  bool chatWindowOpen = false;
}

class MessagesControllerImpl implements MessagesController {
  @override
  bool chatWindowOpen = false;
  @override
  MessagesRepo messagesRepository;
  @override
  StreamController? addDataController = StreamController.broadcast();

  @override
  List<MessagesGroup> messageGroupList = [];

  @override
  StreamController? updateDataController = StreamController.broadcast();
  @override
  String lastChatToRecieveMessageId = kNotAvailable;

  MessagesToChatControllerBridge messagesToChatControllerBridge;
  ChatToMessagesControllerBridge chatToMessagesControllerBridge;

  MessagesControllerImpl(
      {required this.messagesRepository,
      required this.chatToMessagesControllerBridge,
      required this.messagesToChatControllerBridge});

  @override
  Either<Failure, bool> clearModuleData() {
    updateDataController?.close();
    addDataController?.close();
    updateDataController = null;
    addDataController = null;
    updateDataController = StreamController.broadcast();
    addDataController = StreamController.broadcast();
    try {
      messagesRepository.clearModuleData();

      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      _recieveEventsFromChatController();
      messagesEventsListener();

      messagesRepository.initializeModuleData();

      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  void _recieveEventsFromChatController() {
    chatToMessagesControllerBridge
        .controllerBridgeInformationSenderStream?.stream
        .listen((event) {
      String eventType = event["eventType"];
      if (eventType == "addNewMessageGroup") {
        List<Chat> chatList = event["data"];
        chatList.forEach((element) {
          MessagesGroup messagesGroup = new MessagesGroup(
              unreadMessages: 0,
              matchCreated: false,
              userBlocked: false,
              chatId: element.chatId,
              remitentId: element.remitentId,
              messagesId: element.messagesId,
              remitenrPicture: element.remitenrPicture,
              remitentPictureHash: element.remitentPictureHash,
              remitentName: element.remitentName,
              notificationToken: element.notificationToken);

          messageGroupList.add(messagesGroup);
          addDataController
              ?.add({"eventType": "addNewMessageGroup", "data": messagesGroup.chatId});
        });
      }
      if (eventType == "modifyMessageGroup") {
        List<Chat> chatList = event["data"];

        chatList.forEach((element) {
          int index = messageGroupList.indexWhere((messageGroupElement) =>
              messageGroupElement.chatId == element.chatId);

          messageGroupList[index].remitenrPicture = element.remitenrPicture;
          messageGroupList[index].remitentPictureHash =
              element.remitentPictureHash;
          messageGroupList[index].remitentName = element.remitentName;
          messageGroupList[index].notificationToken = element.notificationToken;
          messageGroupList[index].userBlocked = element.userBlocked;
        });
        updateDataController?.add({"eventType": "modifyMessageGroup", "data": null});
      }

      if (eventType == "removeMessageGroup") {
        List<Chat> chatList = event["data"];

        chatList.forEach((element) {
          int index = messageGroupList.indexWhere((messageGroupElement) =>
              messageGroupElement.chatId == element.chatId);

          messageGroupList[index].isBeingDeleted=true;

          updateDataController?.add({"eventType": "chatDeleted", "data": element.chatId});
        });
      }
    });
  }

  /// Removes chat from list when it ahs been  notified as deleted by the chatController

  void deleteMarkedMessagesGroups(){
    messageGroupList.removeWhere((element) => element.isBeingDeleted==true);
  }

  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId, required String chatId}) async {
    for (int a = 0; a < messageGroupList.length; a++) {
      if (messageGroupList[a].chatId == chatId) {
        messageGroupList[a].senderProfileLoadingState =
            SenderProfileLoadingStateMessaageScreen.LOADING;
      }
    }
    Either<Failure, Profile> result = await messagesRepository.getUserProfile(
        profileId: profileId, chatId: chatId);

    result.fold((l) {
      for (int i = 0; i < messageGroupList.length; i++) {
        if (profileId == messageGroupList[i].remitentId &&
            messageGroupList[i].chatId == chatId) {
          messageGroupList[i].senderProfileLoadingState =
              SenderProfileLoadingStateMessaageScreen.ERROR;
        }
      }
    }, (r) {
      for (int i = 0; i < messageGroupList.length; i++) {
        if (profileId == messageGroupList[i].remitentId &&
            messageGroupList[i].chatId == chatId) {
          messageGroupList[i].senderProfile = r;
          messageGroupList[i].senderProfileLoadingState =
              SenderProfileLoadingStateMessaageScreen.READY;
        }
      }
    });

    return result;
  }

  void messagesEventsListener() {
    messagesRepository.messagesStream().listen((event) {
      if (event["eventType"] == "addConversationData") {
        List<MessagesGroup> messageGroup = event["data"];
        _addConversationData(data: messageGroup);
        _sendLastMessagesGroupToChatControllerAtInit();
        _sendUnreadMessagesDatatoChatControllerAtInit();
      }
      if (event["eventType"] == "addNewMessageData") {
        Message message = event["data"];
        bool modified = event["modified"];
        int conversationDataIndex = this
            .messageGroupList
            .indexWhere((listElement) => listElement.chatId == message.chatId);
        if (modified == true) {
          _updateMessagesToRead(
              data: event, conversationDataIndex: conversationDataIndex);
          for (int i = 0;
              i < messageGroupList[conversationDataIndex].messagesList.length;
              i++) {
            if (messageGroupList[conversationDataIndex].messagesList[i].read ==
                true) {
              break;
            }
          }
          messageGroupList[conversationDataIndex]
              .calculateUnreadMessages(GlobalDataContainer.userId as String);
        }
        if (modified == false) {
          if (messageGroupList[conversationDataIndex].messagesList.length > 1) {
            if (shouldAddTimeLabelAboveMessage(
                message.messageDate,
                messageGroupList[conversationDataIndex]
                    .messagesList
                    .first
                    .messageDate)) {
              addDateMessageToChat(
                  message: message,
                  index: conversationDataIndex,
                  isModified: message.read);
            }
            _addNewMessageData(
                message: message, conversationDataIndex: conversationDataIndex);
            _sendUnreadMessagesDatatoChatController(
                messageGroup: messageGroupList[conversationDataIndex]);
            _sendLastMessagesGroupToChatController(
                messagesGroup: messageGroupList[conversationDataIndex]);
          }
          if (messageGroupList[conversationDataIndex].messagesList.length <=
              1) {
            _addNewMessageData(
                message: message, conversationDataIndex: conversationDataIndex);
            _sendUnreadMessagesDatatoChatController(
                messageGroup: messageGroupList[conversationDataIndex]);
            _sendLastMessagesGroupToChatController(
                messagesGroup: messageGroupList[conversationDataIndex]);
          }

          if (message.senderId != GlobalDataContainer.userId) {
            messageGroupList[conversationDataIndex].unreadMessages += 1;
          }
          if (messageGroupList.length > 1) {
            lastChatToRecieveMessageId = message.chatId;
            if (this.chatWindowOpen == false) {
              _reorderChatByLastMessageDate(chatIdToMoveUp: message.chatId);
            }
          }
        }
      }
    });
  }

  /// Checks if two consecutive messages have the same date (ymd).
  ///
  ///
  /// if it returns true, it means we should add a [Message]
  ///
  ///
  /// of type [MessageType.DATE] above the new message
  bool shouldAddTimeLabelAboveMessage(
      int currentMessageTime, int lastMessageTime) {
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

  void _addConversationData({required List<MessagesGroup> data}) {
    this.messageGroupList.addAll(data);
  }

  void _addNewMessageData(
      {required Message message, required int conversationDataIndex}) {
    this
        .messageGroupList[conversationDataIndex]
        .messagesList
        .insert(0, message);
    addDataController?.add(
        {"eventType": "addNewMessageData", "messageChatId": message.chatId});
  }

  /// Sets message property "read" to true
  ///
  /// Sets messages "read" property to true when the server values are updated
  ///
  /// When the user recieves a new message and opens the chat, the message property "read"
  /// is set to [true] first in the server instead of the local data and [Message] objects
  ///
  /// Then when this occurs the app recieves from the server
  ///  the message and now it sets to true the [Message] object property "read" to true
  ///
  /// USER RECIEVES MESSAGE ----> USER TRIGGERS THE SERVER TO CHANGE "READ PROPERTY" ----->
  ///  "READ" PROPERTY IS CHANGED IN THE SERVER
  /// -------> THE USER RECIEVES THE MODIFICATED MESSAGE AND SETS THE LOCAL MESSAGE "READ" PROPERTY TO TRUE
  void _updateMessagesToRead(
      {required Message data, required int conversationDataIndex}) {
    for (int i = 0;
        i < this.messageGroupList[conversationDataIndex].messagesList.length;
        i++) {
      if (this.messageGroupList[conversationDataIndex].messagesList[i].read ==
          true) {
        break;
      }
      if (messageGroupList[conversationDataIndex].messagesList[i].senderId !=
              GlobalDataContainer.userId ||
          messageGroupList[conversationDataIndex].messagesList[i].read ==
              false) {
        messageGroupList[conversationDataIndex].messagesList[i].read = true;
      }

      /// notificar al controlador de chat sobre mensajes no leidos
    }
  }

  void _sendLastMessagesGroupToChatControllerAtInit() {
    List<Message> lastMessagesList = [];

    for (int i = 0; i < messageGroupList.length; i++) {
      if (messageGroupList[i].messagesList.isNotEmpty) {
        lastMessagesList.add(messageGroupList[i].messagesList.first);
      }
    }
    messagesToChatControllerBridge.addInformation(information: {
      "eventType": "chatLastMessageAtInit",
      "data": lastMessagesList
    });
  }

  void _sendLastMessagesGroupToChatController(
      {required MessagesGroup messagesGroup}) {
    messagesToChatControllerBridge.addInformation(information: {
      "eventType": "chatLastMessage",
      "data": messagesGroup.messagesList.first
    });
  }

  void _sendUnreadMessagesDatatoChatController(
      {required MessagesGroup messageGroup}) {
    messageGroup.calculateUnreadMessages(GlobalDataContainer.userId as String);
    messagesToChatControllerBridge.addInformation(information: {
      "eventType": "unreadMessages",
      "data": {
        "chatId": messageGroup.chatId,
        "unreadMessages": messageGroup.unreadMessages
      }
    });
  }

  void _sendUnreadMessagesDatatoChatControllerAtInit() {
    List<Map<String, dynamic>> unreadMessagesList = [];
    for (int i = 0; i < messageGroupList.length; i++) {
      unreadMessagesList.add({
        "chatId": messageGroupList[i].chatId,
        "unreadMessages": messageGroupList[i].unreadMessages
      });
    }

    messagesToChatControllerBridge.addInformation(information: {
      "eventType": "unreadMessagesAtInit",
      "data": unreadMessagesList
    });
  }

  Future<void> addDateMessageToChat(
      {required Message message,
      required int index,
      required bool isModified}) async {
    DateTime tiempo = DateTime.fromMillisecondsSinceEpoch(message.messageDate);
    var dateformat = DateFormat.yMEd();
    String dateText = dateformat.format(tiempo);
    this.messageGroupList[index].messagesList.insert(
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
    addDataController?.add(
        {"eventType": "addNewMessageData", "messageChatId": message.chatId});

    await Future.delayed(Duration(milliseconds: 200));
  }

  Future<void> setMessagesOnSeen({required String chatId}) async {
    List<String> messagesIdList = [];
    for (int i = 0; i < this.messageGroupList.length; i++) {
      if (this.messageGroupList[i].chatId == chatId) {
        this.messageGroupList[i].unreadMessages = 0;
        for (int b = 0; b < this.messageGroupList[i].messagesList.length; b++) {
          if (this.messageGroupList[i].messagesList[b].read == false &&
              this.messageGroupList[i].messagesList[b].senderId !=
                  GlobalDataContainer.userId) {
            messagesIdList
                .add(this.messageGroupList[i].messagesList[b].messageId);
          }
          if (this.messageGroupList[i].messagesList[b].read == true &&
              this.messageGroupList[i].messagesList[b].senderId !=
                  GlobalDataContainer.userId) {
            break;
          }
        }
      }
    }
    await messagesRepository.setMessagesOnSeen(data: messagesIdList);
  }

  void _reorderChatByLastMessageDate({required String chatIdToMoveUp}) {
    if (messageGroupList.first.chatId != chatIdToMoveUp) {
      for (int i = 0; i < messageGroupList.length; i++) {
        if (messageGroupList[i].chatId == chatIdToMoveUp) {
          MessagesGroup messageGroup = messageGroupList.removeAt(i);
          messageGroupList.insert(0, messageGroup);

          break;
        }
      }
    }
  }

  Future<Either<Failure, bool>> sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId}) async {
    return await messagesRepository.sendMessages(
        message: message,
        messageNotificationToken: messageNotificationToken,
        remitentId: remitentId);
  }

  Future<Either<Failure, bool>> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId}) async {
    for (int i = 0; i < this.messageGroupList.length; i++) {
      if (this.messageGroupList[i].chatId == chatId) {
        this.messageGroupList[i].isBeingDeleted = true;
        break;
      }

      updateDataController
          ?.add({"eventType": "chatDeleted", "chatDeletedId": chatId});
    }
    var result = await messagesRepository.deleteChat(
        remitent1: remitent1,
        remitent2: remitent2,
        reportDetails: reportDetails,
        chatId: chatId);

    result.fold((l) {
      for (int i = 0; i < this.messageGroupList.length; i++) {
        if (this.messageGroupList[i].chatId == chatId) {
          this.messageGroupList[i].isBeingDeleted = false;
          break;
        }
      }
    }, (r) {});

    return result;
  }
}
