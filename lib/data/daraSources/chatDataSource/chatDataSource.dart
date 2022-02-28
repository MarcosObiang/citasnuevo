// ignore_for_file: cancel_subscriptions, close_sinks

import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/idGenerator.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/ChatConverter.dart';
import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:citasnuevo/data/Mappers/ProfilesMapper.dart';
import 'package:citasnuevo/data/daraSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/ProfileEntity.dart';

abstract class ChatDataSource implements DataSource {
  late StreamSubscription<QuerySnapshot<Object?>> chatListener;
  late StreamSubscription<QuerySnapshot<Object?>> messageListener;

  late StreamController<dynamic> chatStream;
  late StreamController<Map<String, dynamic>> messageStream;

  Future<bool> messagesSeen({required List<String> data});
  void initializeChatListener();
  void listenToMessages();
  Future<bool> sendMessages(
      {required Map<String, dynamic> message,
      required String messageNotificationToken,
      required String remitentId});

  Future<dynamic> loadMoreMessages(
      {required String chatId, required String lastMessageId});
  Future<Profile> getUserProfile({required String profileId});
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
  @override
  late StreamSubscription<QuerySnapshot<Object?>> messageListener;
  @override
  StreamController<Map<String, dynamic>> messageStream =
      new StreamController.broadcast();

  HttpsCallable llamarDejarMensajesLedio =
      FirebaseFunctions.instance.httpsCallable("dejarEnLeido");

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
      if (event.docChanges.length > 1) {
        for (int i = 0; i < event.docChanges.length; i++) {
          String chatId = event.docChanges[i].doc.get("idConversacion");

          List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages =
              await readMessages(chatId);

          List<QueryDocumentSnapshot<Map<String, dynamic>>> emptyList = [];
          Map<String, dynamic> chatData = {
            "chat": event.docChanges[i].doc.data() as Map<String, dynamic>,
            "messages": chatMessages.isNotEmpty ? chatMessages : emptyList
          };
          chatDataList.add(chatData);
        }

        List<Chat> object = await compute(ChatConverter.fromMap, chatDataList);

        chatStream.add({
          "modified": false,
          "removed": false,
          "chatList": object,
          "firstQuery": true
        });
        isInitializerFinished = true;
      } else {
        if (event.docChanges.first.type == DocumentChangeType.added) {
          List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages = [];
          Map<String, dynamic> chatData = {
            "chat": event.docChanges.first.doc.data() as Map<String, dynamic>,
            "messages": chatMessages
          };
          List<Map<String, dynamic>> singleChatDataList = [];
          singleChatDataList.add(chatData);

          List<Chat> object = ChatConverter.fromMap(singleChatDataList);

          chatStream.add({
            "modified": false,
            "removed": false,
            "chatList": object,
            "firstQuery": false
          });

          isInitializerFinished = true;
        }

        if (event.docChanges.first.type == DocumentChangeType.removed) {
          List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages = [];
          Map<String, dynamic> chatData = {
            "chat": event.docChanges.first.doc.data() as Map<String, dynamic>,
            "messages": chatMessages
          };
          List<Map<String, dynamic>> singleChatDataList = [];
          singleChatDataList.add(chatData);

          List<Chat> object = ChatConverter.fromMap(singleChatDataList);
          chatStream.add({
            "modified": false,
            "removed": true,
            "chatList": object,
            "firstQuery": false
          });
        }
        if (event.docChanges.first.type == DocumentChangeType.modified) {
          List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages = [];
          Map<String, dynamic> chatData = {
            "chat": event.docChanges.first.doc.data() as Map<String, dynamic>,
            "messages": chatMessages
          };
          List<Map<String, dynamic>> singleChatDataList = [];
          singleChatDataList.add(chatData);

          List<Chat> object = ChatConverter.fromMap(singleChatDataList);

          chatStream.add({
            "modified": true,
            "removed": true,
            "chatList": object,
            "firstQuery": false
          });
        }
      }
    });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> readMessages(
      String chatId) async {
    FirebaseFirestore instance = FirebaseFirestore.instance;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> data = [];
    QuerySnapshot<Map<String, dynamic>> net = await instance
        .collection("mensajes")
        .where("idConversacion", isEqualTo: chatId)
        .orderBy("horaMensaje", descending: true)
        .limit(5)
        .get();
    data.addAll(net.docs);

    return data;
  }

  void closeStreams() {
    chatListener.cancel();
    chatStream.close();
    messageListener.cancel();
    messageStream.close();
  }

  @override
  void listenToMessages() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

      messageListener = firestoreInstance
          .collection("mensajes")
          .where("interlocutores", arrayContains: userId)
          .orderBy("horaMensaje", descending: true)
          .limit(1)
          .snapshots()
          .listen((event) {
        if (isInitializerFinished) {
          if (event.docChanges.first.type == DocumentChangeType.modified) {
            messageStream.add({
              "message": MessageConverter.fromMap(event.docs.first),
              "modified": true
            });
          } else {
            messageStream.add({
              "message": MessageConverter.fromMap(event.docs.first),
              "modified": false
            });
          }
        }
      });

      try {} catch (e) {
        ChatException(message: e.toString());
      }
    } else {
      throw NetworkException();
    }
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
        messageData["token"] = messageNotificationToken;
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

  @override
  Future<bool> messagesSeen({required List<String> data}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

      try {
        for (int i = 0; i < data.length; i++) {
          await firestoreInstance
              .collection("mensajes")
              .doc(data[i])
              .update({"mensajeLeido": true});
        }

        return true;
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException();
    }
  }

  @override
  Future<List<Message>> loadMoreMessages(
      {required String chatId, required String lastMessageId}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
      List<Message> messagesList = [];

      try {
        DocumentSnapshot lastMessage = await firestoreInstance
            .collection("mensajes")
            .doc(lastMessageId)
            .get();

        QuerySnapshot<Map<String, dynamic>> messages = await firestoreInstance
            .collection("mensajes")
            .where("idConversacion", isEqualTo: chatId)
            .orderBy("horaMensaje", descending: true)
            .startAfterDocument(lastMessage)
            .limit(10)
            .get();
        messages.docs.forEach((element) {
          messagesList.add(MessageConverter.fromMap(element));
        });

        return messagesList;
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException();
    }
  }

  @override
  Future<Profile> getUserProfile({required String profileId}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable solicitarUsuarioDeterminado = FirebaseFunctions.instance
            .httpsCallable("solicitarUsuarioDeterminado");
        List<Map<dynamic, dynamic>> profilesCache = [];

        HttpsCallableResult httpsCallableResult =
            await solicitarUsuarioDeterminado.call({"id": profileId});
        if (httpsCallableResult.data["estado"] == "correcto") {
          Object? objectT= httpsCallableResult.data["datos"];
            profilesCache.add(objectT as Map<dynamic, dynamic>);


          return ProfileMapper.fromMap({
            "profilesList": [profilesCache.first],
            "userCharacteristicsData": source.getData["filtros usuario"]
          }).first;
        } else {
          throw ChatException(message: "PROFILE_COULD_NOT_BE_FETCHED");
        }
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException();
    }
  }
}
