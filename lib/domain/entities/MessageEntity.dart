enum MessageType { TEXT, GIPHY, IMAGE, NO_TYPE, DATE }

class Message {
  int messageDate;

  bool read;
  bool isResponse;
  String data;
  String chatId;
  String senderId;
  String messageId;
  String messageDateText;
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
