import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageConverter {
  static Message fromMap(
      QueryDocumentSnapshot<Map<String, dynamic>> messageData) {
    return Message(
      read: messageData["mensajeLeido"],
      isResponse: messageData["respuesta"],
      data: messageData["mensaje"],
      chatId: messageData["idConversacion"],
      senderId: messageData["idEmisor"],
      messageId: messageData["idMensaje"],
      messageDate: messageData["horaMensaje"],
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
}
