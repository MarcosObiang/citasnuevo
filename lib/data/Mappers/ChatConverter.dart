import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConverter {
  static List<Chat> fromMap(List<Map<String, dynamic>> data) {
    List<Chat> chatList = [];
    data.forEach((element) {
      QueryDocumentSnapshot<Map<String, dynamic>> chatData = element["chat"];
      List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages = element["messages"];
      List<Message> messagesList = [];

      Chat chat = new Chat(
        unreadMessages: 0,
        matchCreated: true,
        chatId: chatData["idConversacion"],
        remitentId: chatData["idRemitente"],
        messagesId: chatData["idMensajes"],
        remitenrPicture: chatData["imagenRemitente"],
        remitentPictureHash: chatData["hash"],
        remitentName: chatData["nombreRemitente"],
        notificationToken: chatData["tokenNotificacion"],
      );

      chatMessages.forEach((message) {
       messagesList.add(MessageConverter.fromMap(message));
      });

      chat.messagesList.addAll(messagesList.reversed);
      chatList.add(chat);
    });

    return chatList;
  }
}
