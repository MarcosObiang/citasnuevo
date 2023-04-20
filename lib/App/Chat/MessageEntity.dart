

import '../ProfileViewer/ProfileEntity.dart';

enum MessageType { TEXT, GIPHY, IMAGE, NO_TYPE, DATE }
enum MessageSendingState { SENDING,SENT,ERROR,NOT_SENT }


class Message {
 late int messageDate;
 late bool read;
 late bool isResponse;
 late String data;
 late String chatId;
 late String senderId;
 late String messageId;
 late String messageDateText;
 late MessageSendingState messageSendingState=MessageSendingState.SENT;
  MessageType messageType;
  Message({
    required this.read,
    required this.messageDateText,
    required this.isResponse,
    required this.data,
    required this.chatId,
    required this.senderId,
    required this.messageId,
    required this.messageDate,
    required this.messageType,
  });


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
  bool isBeingDeleted=false;
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
  List<Message>messagesList=[];
    SenderProfileLoadingStateMessaageScreen senderProfileLoadingState=SenderProfileLoadingStateMessaageScreen.NOT_LOADED_YET;

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



 void calculateUnreadMessages(String userId) {
    unreadMessages=0;
    for (int i = 0; i < messagesList.length; i++) {
      if (messagesList[i].read == false &&
          messagesList[i].senderId != userId&&messagesList[i].messageType!=MessageType.DATE) {
        unreadMessages = unreadMessages + 1;
      }
      if (messagesList[i].read == true) {
        break;
      }
    }
  }
}
