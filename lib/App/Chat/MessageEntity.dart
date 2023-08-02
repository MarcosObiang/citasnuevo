import 'dart:typed_data';

import '../../Utils/getImageFile.dart';
import '../ProfileViewer/ProfileEntity.dart';

enum MessageType { TEXT, GIPHY, IMAGE, DATE, AUDIO }

enum MessageSendingState { SENDING, SENT, ERROR, NOT_SENT }

class Message {
  late int messageDate;
  late bool read;
  late bool isResponse;
  late String data;
  late String chatId;
  late String senderId;
  late String messageId;
  late String messageDateText;
  Uint8List? fileData;
  Future<Uint8List?>? remitentFile = null;

  late MessageSendingState messageSendingState = MessageSendingState.SENT;
  MessageType messageType;
  Message(
      {required this.read,
      required this.messageDateText,
      required this.isResponse,
      required this.data,
      required this.chatId,
      required this.senderId,
      required this.messageId,
      required this.messageDate,
      required this.messageType,
      this.fileData});

  void initMessage() {
    if (this.messageType == MessageType.AUDIO ||
        this.messageType == MessageType.IMAGE && this.fileData == null) {
      remitentFile = Future.value(null);
      remitentFile = ImageFile.getFile(fileId: this.data);
      remitentFile?.then((value) => fileData = value);
    }
  }
}

enum SenderProfileLoadingStateMessaageScreen {
  READY,
  LOADING,
  ERROR,
  NOT_LOADED_YET,
}

class MessagesGroup {
  int unreadMessages;
  bool matchCreated;
  bool isBeingDeleted = false;
  bool userBlocked;
  String chatId;
  String remitentId;
  String messagesId;
  String remitenrPicture;
  String remitentPictureHash;
  String remitentName;
  String notificationToken;
  Message? lastMessage;
  Profile? senderProfile;
  List<Message> messagesList = [];
  SenderProfileLoadingStateMessaageScreen senderProfileLoadingState =
      SenderProfileLoadingStateMessaageScreen.NOT_LOADED_YET;

  MessagesGroup({
    required this.unreadMessages,
    required this.matchCreated,
    required this.userBlocked,
    required this.chatId,
    required this.remitentId,
    required this.messagesId,
    required this.remitenrPicture,
    required this.remitentPictureHash,
    required this.remitentName,
    required this.notificationToken,
    this.lastMessage,
    this.senderProfile,
  });
}
