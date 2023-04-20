import 'package:intl/intl.dart';

import '../../core/globalData.dart';
import 'MessageEntity.dart';

class MessageConverter {
  static Message fromMap(Map<String, dynamic> messageData) {
    var dateformat = DateFormat.Hm();
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(messageData["timestamp"])
            .toLocal();
    String dateText = dateformat.format(
        DateTime.fromMillisecondsSinceEpoch(messageData["timestamp"])
            .toLocal());

    return Message(
      messageDateText: dateText,
      read: messageData["readByReciever"],
      isResponse: false,
      data: messageData["messageContent"],
      chatId: messageData["conversationId"],
      senderId: messageData["senderId"],
      messageId: messageData["messageId"],
      messageDate: dateTime.millisecondsSinceEpoch,
      messageType: messageData["messageType"] == "texto"
          ? MessageType.TEXT
          : MessageType.GIPHY,
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
      "messageType": message.messageType == MessageType.TEXT ? "texto" : "image"
    };
  }

 
}
