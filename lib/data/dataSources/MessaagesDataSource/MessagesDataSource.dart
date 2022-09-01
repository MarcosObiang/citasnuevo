import 'dart:async';

import 'package:citasnuevo/core/globalData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/common/commonUtils/DateNTP.dart';
import '../../../core/common/commonUtils/idGenerator.dart';
import '../../../core/dependencies/error/Exceptions.dart';
import '../../../core/platform/networkInfo.dart';
import '../../../domain/repository/DataManager.dart';
import '../principalDataSource/principalDataSource.dart';

abstract class MessagesDataSource
    implements DataSource, ModuleCleanerDataSource {
  StreamSubscription<QuerySnapshot<Object?>>? messageListenerSubscription;
  late StreamController<Map<String, dynamic>>? messageStream;
  void listenToMessages();
  Future<bool> sendMessages(
      {required Map<String, dynamic> message,
      required String messageNotificationToken,
      required String remitentId});
  Future<bool> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});
  Future<bool> messagesSeen({required List<String> data});
  Future<Map<String, dynamic>> getUserProfile({required String profileId});
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getMessages(
      {required String chatId});
}

class MessagesDataSourceImpl implements MessagesDataSource {
  @override
  StreamSubscription<QuerySnapshot<Object?>>? messageListenerSubscription;

  @override
  StreamController<Map<String, dynamic>>? messageStream =
      StreamController.broadcast();

  @override
  ApplicationDataSource source;

  bool isInitializerFinished = false;

  @override
  StreamSubscription? sourceStreamSubscription;
  MessagesDataSourceImpl({
    required this.source,
    this.sourceStreamSubscription,
  });

  @override
  void clearModuleData() {
    // TODO: implement clearModuleData
  }

  @override
  void initializeModuleData() {
    initialize();
  }

  @override
  Future<Map<String, dynamic>> getUserProfile(
      {required String profileId}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable solicitarUsuarioDeterminado = FirebaseFunctions.instance
            .httpsCallable("solicitarUsuarioDeterminado");
        List<Map<dynamic, dynamic>> profilesCache = [];

        HttpsCallableResult httpsCallableResult =
            await solicitarUsuarioDeterminado.call({"id": profileId});
        if (httpsCallableResult.data["estado"] == "correcto") {
          Object? objectT = httpsCallableResult.data["datos"];
          profilesCache.add(objectT as Map<dynamic, dynamic>);

          return {
            "profilesList": [profilesCache.first],
            "userCharacteristicsData": source.getData["filtros usuario"],
            "todayDateTime": await DateNTP.instance.getTime()
          };
        } else {
          throw MessagesException(message: "PROFILE_COULD_NOT_BE_FETCHED");
        }
      } catch (e) {
        throw MessagesException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void listenToMessages() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        if (GlobalDataContainer.userId != null) {
          FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

          messageListenerSubscription = firestoreInstance
              .collection("mensajes")
              .where("interlocutores",
                  arrayContains: GlobalDataContainer.userId)
              .orderBy("horaMensaje", descending: true)
              .snapshots()
              .listen((event) {
            if (isInitializerFinished) {
              if (event.docChanges.isNotEmpty) {
                try {
                  if (event.docChanges.first.type ==
                      DocumentChangeType.modified) {
                    messageStream?.add({
                      "data": event.docs.first.data(),
                      "modified": true,
                      "eventType": "addNewMessageData",
                    });
                  }
                  if (event.docChanges.first.type == DocumentChangeType.added) {
                    messageStream?.add({
                      "eventType": "addNewMessageData",
                      "data": event.docs.first.data(),
                      "modified": false
                    });
                  }
                } catch (e) {
                  messageStream
                      ?.addError(MessagesException(message: e.toString()));
                }
              }
            }
          });
        }
        if (GlobalDataContainer.userId == null) {
          throw MessagesException(message: "USER_ID_CANNOT_BE_NULL");
        }
      } catch (e) {
        messageStream?.addError(ChatException(message: e.toString()));

        throw MessagesException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> messagesSeen({required List<String> data}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
      int messagesCounter = 0;
      WriteBatch writeBatch = FirebaseFirestore.instance.batch();
      try {
        for (int i = 0; i < data.length; i++) {
          writeBatch.update(
              firestoreInstance.collection("mensajes").doc(data[i]),
              {"mensajeLeido": true});
          messagesCounter += 1;

          if (messagesCounter >= 400) {
            await writeBatch.commit();
            messagesCounter = 0;
            writeBatch = FirebaseFirestore.instance.batch();
          }
        }

        writeBatch.commit();
        return true;
      } catch (e) {
        throw MessagesException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> deleteChat({
    required String remitent1,
    required String remitent2,
    required String reportDetails,
    required String chatId,
  }) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable llamarEliminarConversacion =
            FirebaseFunctions.instance.httpsCallable("eliminarConversaciones");

        HttpsCallableResult httpsCallableResult =
            await llamarEliminarConversacion.call({
          "idConversacion": chatId,
          "idInterlocutor1": remitent1,
          "idInterlocutor2": remitent2,
          "idDenuncia": IdGenerator.instancia.createId(),
          "detalles": reportDetails,
        });

        if (httpsCallableResult.data["estado"] == "correcto") {
          return true;
        } else {
          throw ChatException(message: "CHAT_COULD_NOT_BE_DELETED");
        }
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> sendMessages(
      {required Map<String, dynamic> message,
      required String messageNotificationToken,
      required String remitentId}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        String messageId = IdGenerator.instancia.createId();
        DateTime messageDate = await DateNTP.instance.getTime();

        FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
        Map<String, dynamic> messageData = message;
        messageData["token"] = messageNotificationToken;
        messageData["horaMensaje"] = messageDate.millisecondsSinceEpoch;
        messageData["mensaje"] = message["mensaje"];
        messageData["idMensaje"] = messageId;
        messageData["mensajeLeido"] = false;
        messageData["nombreEmisor"] = source.getData["Nombre"];
        messageData["idConversacion"] = message["idConversacion"];
        messageData["idTemporalMensaje"] = IdGenerator.instancia.createId();
        messageData["entregado"] = true;
        messageData["idEmisor"] = GlobalDataContainer.userId;
        messageData["tipoMensaje"] = message["tipoMensaje"];
        messageData["respuesta"] = false;
        messageData["mensajeRespuesta"] = {};
        messageData["cargaNotificacion"] = true;
        messageData["notificarEsteUsuario"] = remitentId;
        messageData["interlocutores"] = [
          GlobalDataContainer.userId,
          remitentId
        ];
        await firestoreInstance
            .collection("mensajes")
            .doc(messageId)
            .set(messageData);

        return true;
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void subscribeToMainDataSource() {
    // TODO: implement subscribeToMainDataSource
  }

  void initialize() async {
    listenToMessages();

    await _getConversationData(userId: GlobalDataContainer.userId as String);
  }

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getMessages(
      {required String chatId}) async {
    FirebaseFirestore instance = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> data;

    QuerySnapshot<Map<String, dynamic>> messages = await instance
        .collection("mensajes")
        .where("idConversacion", isEqualTo: chatId)
        .orderBy("horaMensaje", descending: true)
        .get();

    data = messages;
    return data.docs;
  }

  /// Gets conversation data
  ///
  /// returns a Map List wich contains both, chat info and its messages

  Future<void> _getConversationData({required String userId}) async {
    List<Map<String, dynamic>> data = [];
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        FirebaseFirestore instance = FirebaseFirestore.instance;

        QuerySnapshot<Map<String, dynamic>> conversations = await instance
            .collection("usuarios")
            .doc(userId)
            .collection("conversaciones")
            .get();

        for (int i = 0; i < conversations.docs.length; i++) {
          List<QueryDocumentSnapshot<Map<String, dynamic>>> messagesList =
              await getMessages(chatId: conversations.docs[i].id);
          data.add({
            "chatInfo": conversations.docs[i].data(),
            "chatMessages": messagesList,"userId":GlobalDataContainer.userId as String
          });
        }

        messageStream?.add({"dataType": "conversationData", "data": data});
        this.isInitializerFinished = true;
      } catch (e) {
        throw MessagesException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }
}
