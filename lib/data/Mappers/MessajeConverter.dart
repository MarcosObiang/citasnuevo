import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessageConverter {
  static Message fromMap(Map<String, dynamic> messageData) {
    var dateformat = DateFormat.Hm();
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(messageData["horaMensaje"])
            .toLocal();
    String dateText = dateformat.format(
        DateTime.fromMillisecondsSinceEpoch(messageData["horaMensaje"])
            .toLocal());

    return Message(
      messageDateText: dateText,
      read: messageData["mensajeLeido"],
      isResponse: messageData["respuesta"],
      data: messageData["mensaje"],
      chatId: messageData["idConversacion"],
      senderId: messageData["idEmisor"],
      messageId: messageData["idMensaje"],
      messageDate: dateTime.millisecondsSinceEpoch,
      messageType: messageData["tipoMensaje"] == "texto"
          ? MessageType.TEXT
          : MessageType.GIPHY,
    );
  }

  static Map<String, dynamic> toMap(Message message) {
    return {
      "mensajeLeido": message.read,
      "isResponse": message.isResponse,
      "mensaje": message.data,
      "idConversacion": message.chatId,
      "idEmisor": message.senderId,
      "idMensaje": message.messageId,
      "horaMensaje": message.messageDate,
      "tipoMensaje": message.messageType == MessageType.TEXT ? "texto" : "gif"
    };
  }

  static List<MessagesGroup> chatDataConverter(
    List<Map<String, dynamic>> data
  ) {
    List<MessagesGroup> chatList = [];
     List<MessagesGroup> chatListToReturn = [];

    data.forEach((element) {
      bool firstDateMEssageAdded = false;
      Map<String, dynamic> chatData = element["chatInfo"];
      List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages =
          element["chatMessages"];
      String userId=element["userId"];
      List<Message> messagesList = [];

      MessagesGroup chat = MessagesGroup(
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

      for (int i = 0; i < chatMessages.length; i++) {
        if (chatMessages.length > 1) {
          if (i + 1 < chatMessages.length) {
            int horaMensajeActual = chatMessages[i]["horaMensaje"];

            int horaMensajeSiguiente = chatMessages[i + 1]["horaMensaje"];

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
                  .add(MessageConverter.fromMap(chatMessages[i].data()));
              messagesList.add(Message(
                  messageDateText: dateText,
                  read: true,
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
                  .add(MessageConverter.fromMap(chatMessages[i].data()));
            }
          } else {
            messagesList.add(MessageConverter.fromMap(chatMessages[i].data()));
          }
          if (firstDateMEssageAdded == false && i == chatMessages.length - 1) {
            int horaMensajeActual = chatMessages[i]["horaMensaje"];

            DateTime tiempo = DateTime.fromMillisecondsSinceEpoch(
                    horaMensajeActual,
                    isUtc: true)
                .toLocal();

            var dateformat = DateFormat.yMEd();
            String dateText = dateformat.format(tiempo);

            messagesList.add(Message(
                messageDateText: dateText,
                read: true,
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
          int horaMensajeActual = chatMessages[i]["horaMensaje"];

          DateTime tiempo = DateTime.fromMillisecondsSinceEpoch(
                  horaMensajeActual,
                  isUtc: true)
              .toLocal();

          var dateformat = DateFormat.yMEd();
          String dateText = dateformat.format(tiempo);

          messagesList.add(MessageConverter.fromMap(chatMessages[i].data()));
          messagesList.add(Message(
              messageDateText: dateText,
              read: true,
              isResponse: false,
              data: "data",
              chatId: chat.chatId,
              senderId: "NOT_AVAILABLE",
              messageId: "messageId",
              messageDate: tiempo.millisecondsSinceEpoch,
              messageType: MessageType.DATE));
        }
      }

      chat.messagesList = messagesList;
       chat.calculateUnreadMessages(userId);
       if(chat.messagesList.isNotEmpty){
      chat.lastMessage=messagesList.first;

       }
      
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

  static List<MessagesGroup> _orderChatList(
      List<MessagesGroup> chatList) {
    List<MessagesGroup> chatListToReturn = chatList;
     List<MessagesGroup> chatsWithMessages = [];

    for (int i = 0; i < chatList.length; i++) {
      if (chatListToReturn[i].lastMessage!=null) {
       MessagesGroup chat = chatListToReturn[i];
        chatsWithMessages.add(chat);
      }
    }
    

    if (chatsWithMessages.length > 0) {


      chatsWithMessages.sort((a, b) => a.lastMessage
          !.messageDate
          .compareTo(b.lastMessage
          !.messageDate));
    }

    chatListToReturn.insertAll(0, chatsWithMessages);
    return chatListToReturn;
  }
}
