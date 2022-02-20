import 'package:citasnuevo/domain/entities/MessageEntity.dart';

import 'ProfileEntity.dart';

class Chat {
  int unreadMessages;
  bool matchCreated;
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

  Chat({
    required this.unreadMessages,
    required this.matchCreated,
    required this.chatId,
    required this.remitentId,
    required this.messagesId,
    required this.remitenrPicture,
    required this.remitentPictureHash,
    required this.remitentName,
    required this.notificationToken,
  });
}
