import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'ChatEntity.dart';
import 'MessageEntity.dart';
import 'MessajeConverter.dart';

class ChatConverter {
  static List<Chat> fromMap(
    List<Map<String, dynamic>> data,
  ) {
    List<Chat> chatList = [];
    List<Chat> chatListToReturn = [];
    bool thisIsUser1 = false;

    data.forEach((element) {
      bool firstDateMEssageAdded = false;
      Map<String, dynamic> chatData = element["chat"];
      List<Map<String, dynamic>> chatMessages = element["messages"];
      List<Message> messagesList = [];
      String userId = element["userId"];

      if (chatData["user1Id"] == userId) {
        thisIsUser1 = true;
      }

      Chat chat = new Chat(
        unreadMessages: 0,
        matchCreated: true,
        userBlocked:
            thisIsUser1 ? chatData["user2Blocked"] : chatData["user1Blocked"],
        chatId: chatData["conversationId"],
        remitentId: thisIsUser1 ? chatData["user2Id"] : chatData["user1Id"],
        messagesId: chatData["conversationId"],
        remitentPicture: thisIsUser1
            ? jsonDecode(chatData["user2Picture"])["imageId"]
            : jsonDecode(chatData["user1Picture"])["imageId"],
      
        remitentName:
            thisIsUser1 ? chatData["user2Name"] : chatData["user1Name"],
        notificationToken:    thisIsUser1 ? chatData["user2NotificationToken"] : chatData["user1NotificationToken"],
      );

      for (int i = 0; i < chatMessages.length; i++) {
        if (chatMessages.length > 1) {
          if (i + 1 < chatMessages.length) {
            int horaMensajeActual = chatMessages[i]["timestamp"];

            int horaMensajeSiguiente = chatMessages[i + 1]["timestamp"];

            DateTime tiempo = DateTime.fromMillisecondsSinceEpoch(
                    horaMensajeActual,
                    isUtc: true)
                .toLocal();
            DateTime tiempoSiguiente = DateTime.fromMillisecondsSinceEpoch(
                    horaMensajeSiguiente,
                    isUtc: true)
                .toLocal();

            bool addMessageDate =
                shouldAddDateMessage(horaMensajeActual, horaMensajeSiguiente);
            if (addMessageDate == true) {
              var dateformat = DateFormat.yMEd();
              String dateText = dateformat.format(tiempo);
              messagesList
                  .add(MessageConverter.fromMap(chatMessages[i]));
              messagesList.add(Message(
                  messageDateText: dateText,
                  read: false,
                  isResponse: false,
                  data: "data",
                  chatId: chat.chatId,
                  senderId: "NOT_AVAILABLE",
                  messageId: "messageId",
                  messageDate: tiempoSiguiente.millisecondsSinceEpoch,
                  messageType: MessageType.DATE));
            }
            if (addMessageDate == false) {
              messagesList
                  .add(MessageConverter.fromMap(chatMessages[i]));
            }
          } else {
            messagesList.add(MessageConverter.fromMap(chatMessages[i]));
          }
          if (firstDateMEssageAdded == false && i == chatMessages.length - 1) {
            int horaMensajeActual = chatMessages[i]["timestamp"];

            DateTime tiempo = DateTime.fromMillisecondsSinceEpoch(
                    horaMensajeActual,
                    isUtc: true)
                .toLocal();

            var dateformat = DateFormat.yMEd();
            String dateText = dateformat.format(tiempo);

            messagesList.add(Message(
                messageDateText: dateText,
                read: false,
                isResponse: false,
                data: "data",
                chatId: chat.chatId,
                senderId: "NOT_AVAILABLE",
                messageId: "messageId",
                messageDate: tiempo.millisecondsSinceEpoch,
                messageType: MessageType.DATE));
            firstDateMEssageAdded = true;
          }
        } else {
          int horaMensajeActual = chatMessages[i]["timestamp"];

          DateTime tiempo = DateTime.fromMillisecondsSinceEpoch(
                  horaMensajeActual,
                  isUtc: true)
              .toLocal();

          var dateformat = DateFormat.yMEd();
          String dateText = dateformat.format(tiempo);

          messagesList.add(MessageConverter.fromMap(chatMessages[i]));
          messagesList.add(Message(
              messageDateText: dateText,
              read: false,
              isResponse: false,
              data: "data",
              chatId: chat.chatId,
              senderId: "NOT_AVAILABLE",
              messageId: "messageId",
              messageDate: tiempo.millisecondsSinceEpoch,
              messageType: MessageType.DATE));
        }
      }

      chat.messagesList.addAll(messagesList);
      chat.calculateUnreadMessages(userId);
      chatList.add(chat);
    });

    chatListToReturn = _orderChatList(chatList);

    return chatListToReturn;
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
