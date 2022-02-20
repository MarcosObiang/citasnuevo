import 'dart:async';
import 'dart:ffi';

import 'package:citasnuevo/core/common/commonUtils/idGenerator.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/ChatConverter.dart';
import 'package:citasnuevo/data/daraSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

abstract class ChatDataSource implements DataSource {
  late StreamSubscription<QuerySnapshot<Object?>> chatListener;
  late StreamController<dynamic> chatStream;
  void initializeChatListener();
  void listenToMessages();
  Future<bool> sendMessages(
      {required Map<String, dynamic> message,
      required String messageNotificationToken,
      required String remitentId});
//void sendMessages()

}

class ChatDatsSourceImpl implements ChatDataSource {
  @override
  ApplicationDataSource source;
  bool isInitializerFinished = false;
  late String userId;

  @override
  StreamController chatStream = new StreamController.broadcast();
  @override
  late StreamSubscription<QuerySnapshot<Object?>> chatListener;

  ChatDatsSourceImpl({
    required this.source,
  }) {
    subscribeToMainDataSource();
  }

  @override
  void initializeChatListener() async {
    FirebaseFirestore instance = FirebaseFirestore.instance;
    List<Map<String, dynamic>> chatDataList = [];

    chatListener = instance
        .collection("usuarios")
        .doc(userId)
        .collection("conversaciones")
        .orderBy("creacionConversacion", descending: true)
        .snapshots()
        .listen((event) async {
      if (!isInitializerFinished) {
        for (int i = 0; i < event.docs.length; i++) {
          String chatId = event.docs[i].get("idConversacion");

          List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages =
              await readMessages(chatId);
          Map<String, dynamic> chatData = {
            "chat": event.docs[i],
            "messages": chatMessages
          };
          chatDataList.add(chatData);
        }

        List<Chat> object = await compute(ChatConverter.fromMap, chatDataList);

        this.chatStream.add(object);
        print("gasss");
      }
    });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> readMessages(
      String chatId) async {
    FirebaseFirestore instance = FirebaseFirestore.instance;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> data = [];
    QuerySnapshot<Map<String, dynamic>> net = await instance
        .collection("mensajes")
        .where("idConversacion", isEqualTo: "BuMGbpNk8d9tGkrIL9OO26s5Bq2")
        .orderBy("horaMensaje", descending: true)
        .limit(25)
        .get();
    data.addAll(net.docs);

    return data;
  }

  void closeStreams() {
    chatListener.cancel();
    chatStream.close();
  }

  @override
  void listenToMessages() {
    // TODO: implement listenToMessages
  }

  @override
  void subscribeToMainDataSource() {
    userId = source.getData["id"];
    source.dataStream.stream.listen((event) {
      userId = event["id"];
    });
  }

  @override
  Future<bool> sendMessages(
      {required Map<String, dynamic> message,
      required String messageNotificationToken,
      required String remitentId}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
        Map<String, dynamic> messageData = message;
        messageData["token"] = message["token"];
        messageData["horaMensaje"] = DateTime.now().millisecondsSinceEpoch;
        messageData["mensaje"] = message["mensaje"];
        messageData["idMensaje"] = IdGenerator.instancia.createId();
        messageData["mensajeLeido"] = false;
        messageData["nombreEmisor"] = source.getData["Nombre"];
        messageData["idConversacion"] = message["idConversacion"];
        messageData["idTemporalMensaje"] = IdGenerator.instancia.createId();
        messageData["entregado"] = true;
        messageData["idEmisor"] = userId;
        messageData["tipoMensaje"] = message["tipoMensaje"];
        messageData["respuesta"] = false;
        messageData["mensajeRespuesta"] = {};
        messageData["cargaNotificacion"] = true;
        messageData["notificarEsteUsuario"] = remitentId;
        messageData["interlocutores"] = [userId, remitentId];

        await firestoreInstance.collection("mensajes").doc().set(messageData);
        return true;
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException();
    }
  }
}
