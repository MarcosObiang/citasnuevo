import 'package:intl/intl.dart';

import 'MessageEntity.dart';

class MessageConverter {
  static Message fromMap(Map<String, dynamic> messageData) {
    var dateformat = DateFormat.Hm();
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(messageData["timestamp"]).toLocal();
    String dateText = dateformat.format(
        DateTime.fromMillisecondsSinceEpoch(messageData["timestamp"])
            .toLocal());
    String messageTypeString = messageData["messageType"];

    late MessageType messageType;

    if (messageTypeString == MessageType.TEXT.name) {
      messageType = MessageType.TEXT;
    }
    if (messageTypeString == MessageType.GIPHY.name) {
      messageType = MessageType.GIPHY;
    }
    if (messageTypeString == MessageType.AUDIO.name) {
      messageType = MessageType.AUDIO;
    }
    if (messageTypeString == MessageType.IMAGE.name) {
      messageType = MessageType.IMAGE;
    }

    return Message(
      messageDateText: dateText,
      read: messageData["readByReciever"],
      isResponse: false,
      data: messageData["message"],
      chatId: messageData["conversationId"],
      senderId: messageData["senderId"],
      messageId: messageData["messageId"],
      messageDate: dateTime.millisecondsSinceEpoch,
      messageType: messageType,
    );
  }

  static Map<String, dynamic> toMap(Message message) {
    return {
      "readByReciever": message.read,
      "isResponse": message.isResponse,
      "messageContent": message.data,
      "conversationId": message.chatId,
      "senderId": message.senderId,
      "messageId": message.messageId,
      "timestamp": message.messageDate,
      "messageType": message.messageType.name,
      "fileData": message.fileData
    };
  }
}
