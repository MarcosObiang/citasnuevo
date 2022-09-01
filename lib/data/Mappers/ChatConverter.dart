import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ChatConverter {
  static List<Chat> fromMap(
    List<Map<String, dynamic>> data,
  ) {
    List<Chat> chatList = [];
    List<Chat> chatListToReturn = [];

    data.forEach((element) {
      bool firstDateMEssageAdded = false;
      Map<String, dynamic> chatData = element["chat"];
      
      List<Message> messagesList = [];
      String userId = element["userId"];

      Chat chat = new Chat(
        userBlocked: chatData["bloqueado"],
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



      //chat.messagesList.addAll(messagesList);
      //chat.calculateUnreadMessages(userId);
      chatList.add(chat);
    });

   // chatListToReturn = _orderChatList(chatList);

    return chatList;
  }

  static bool shouldAddDateMessage(
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

/*  @protected
  static List<Chat> _orderChatList(List<Chat> chatList) {
    List<Chat> chatListToReturn = chatList;
    List<Chat> chatsWithMessages = [];

    for (int i = 0; i < chatListToReturn.length; i++) {
if(chatListToReturn[i].lastMessage)

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
  }*/
}
