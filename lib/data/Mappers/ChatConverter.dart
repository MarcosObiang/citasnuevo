import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatConverter {
  static List<Chat> fromMap(List<Map<String, dynamic>> data,) {
    List<Chat> chatList = [];
    List<Chat> chatListToReturn = [];

    data.forEach((element) {
      Map<String, dynamic> chatData = element["chat"];
      List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages =
          element["messages"];
      List<Message> messagesList = [];
      String userId=element["userId"];

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



      for (int i = 0; i < chatMessages.length; i++) {
        if ((chatMessages.length - i) > 1) {
          int horaMensajeActual = chatMessages[i]["horaMensaje"];
          int horaMensajeSiguiente = chatMessages[i + 1]["horaMensaje"];

          DateTime tiempo =
              DateTime.fromMillisecondsSinceEpoch(horaMensajeActual);
          DateTime tiempoSiguiente =
              DateTime.fromMillisecondsSinceEpoch(horaMensajeSiguiente);

          if ((tiempo.difference(tiempoSiguiente)).inSeconds>86400) {
            messagesList.add(MessageConverter.fromMap(chatMessages[i]));
            messagesList.add(Message(
                read: true,
                isResponse: false,
                data: "data",
                chatId: chat.chatId,
                senderId:"NOT_AVAILABLE",
                messageId: "messageId",
                messageDate: tiempoSiguiente.millisecondsSinceEpoch,
                messageType: MessageType.DATE));
          } else {
            messagesList.add(MessageConverter.fromMap(chatMessages[i]));
          }
        }
      }

      chat.messagesList.addAll(messagesList);
      chat.calculateUnreadMessages(userId );
      chatList.add(chat);
    });

    chatListToReturn = _orderChatList(chatList);

    return chatListToReturn;
  }

  @protected
  static List<Chat> _orderChatList(List<Chat> chatList) {
    List<Chat> chatListToReturn = chatList;
    List<Chat> chatsWithMessages = [];

    for (int i = 0; i < chatListToReturn.length; i++) {
      if (chatListToReturn[i].messagesList.length > 0) {
        Chat chat = chatListToReturn[i];
        chatsWithMessages.add(chat);
      }
    }
    chatListToReturn.removeWhere((element) => element.messagesList.length > 0);

    if (chatsWithMessages.length > 0) {
      chatsWithMessages.sort((a, b) => b.messagesList.first.messageDate
          .compareTo(a.messagesList.first.messageDate));
    }

    chatListToReturn.insertAll(0, chatsWithMessages);
    return chatListToReturn;
  }
}
