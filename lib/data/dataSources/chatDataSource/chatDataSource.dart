// ignore_for_file: cancel_subscriptions, close_sinks

import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/common/commonUtils/idGenerator.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/ChatConverter.dart';
import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:citasnuevo/data/Mappers/ProfilesMapper.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/ProfileEntity.dart';

abstract class ChatDataSource implements DataSource, ModuleCleanerDataSource {
  StreamSubscription<QuerySnapshot<Object?>>? chatListenerSbscription;
  late List<Message> messagesWithOutChat;

  StreamController<dynamic>? chatStream;

  Future<bool> messagesSeen({required List<String> data});
  Future<bool> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});

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
  String userId = kNotAvailable;
  @override
  List<Message> messagesWithOutChat = [];

  @override
  StreamSubscription? sourceStreamSubscription;

  List<String> chatIds = [];

  @override
  StreamController? chatStream = new StreamController.broadcast();
  @override
  StreamSubscription<QuerySnapshot<Object?>>? chatListenerSbscription;
  @override
  StreamSubscription<QuerySnapshot<Object?>>? messageListenerSubscription;
  @override
  StreamController<Map<String, dynamic>> messageStream =
      new StreamController.broadcast();

  HttpsCallable llamarDejarMensajesLedio =
      FirebaseFunctions.instance.httpsCallable("dejarEnLeido");

  ChatDatsSourceImpl({
    required this.source,
  });

  Future<void> _addCurrentConversations(
      {required QuerySnapshot<Map<String, dynamic>> event}) async {
    List<Map<String, dynamic>> chatDataList = [];

    for (int i = 0; i < event.docChanges.length; i++) {
      String chatId = event.docChanges[i].doc.get("idConversacion");

      List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages =
          await readMessages(chatId);

      List<QueryDocumentSnapshot<Map<String, dynamic>>> emptyList = [];
      Map<String, dynamic> chatData = {
        "chat": event.docChanges[i].doc.data() as Map<String, dynamic>,
        "messages": chatMessages.isNotEmpty ? chatMessages : emptyList,
        "userId": GlobalDataContainer.userId,
      };
      chatDataList.add(chatData);
      chatIds.add(chatId);
    }

    try {
      List<Chat> object = await compute(ChatConverter.fromMap, chatDataList);
      chatStream?.add({
        "modified": false,
        "removed": false,
        "chatList": object,
        "firstQuery": true,
        "payloadType": "chat",
      });

      isInitializerFinished = true;
    } catch (e) {
      throw ChatException(message: e.toString());
    }
  }

  void _addData({required Map<String, dynamic> data}) {
    if (chatStream != null) {
      chatStream!.add(data);
    } else {
      throw ChatException(message: kStreamParserNullError);
    }
  }

  void _addError({required dynamic e}) {
    if (chatStream != null) {
      chatStream!.addError(e);
    } else {
      throw ChatException(message: kStreamParserNullError);
    }
  }

  Future<void> _addNewConversation(
      {required DocumentSnapshot<Map<String, dynamic>> doc}) async {
    String chatId = doc.get("idConversacion");
    if (chatIds.contains(chatId) == false) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages =
          await readMessages(chatId);

      List<QueryDocumentSnapshot<Map<String, dynamic>>> emptyList = [];

      Map<String, dynamic> chatData = {
        "chat": doc.data() as Map<String, dynamic>,
        "messages": chatMessages.length > 0 ? chatMessages : emptyList,
        "userId": GlobalDataContainer.userId,
      };
      List<Map<String, dynamic>> singleChatDataList = [];
      singleChatDataList.add(chatData);

      chatIds.add(chatId);

      _addData(data: {
        "payloadType": "chat",
        "modified": false,
        "removed": false,
        "chatList": singleChatDataList,
        "firstQuery": false
      });
    }
  }

  void _removeConversation(
      {required DocumentSnapshot<Map<String, dynamic>> doc}) {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages = [];
    Map<String, dynamic> chatData = {
      "chat": doc.data() as Map<String, dynamic>,
      "messages": chatMessages,
      "userId": GlobalDataContainer.userId,
    };
    String? chatId = doc.data()?["idConversacion"];
    List<Map<String, dynamic>> singleChatDataList = [];
    singleChatDataList.add(chatData);

    singleChatDataList.forEach((element) {
      chatIds.removeWhere((chatID) => chatID == chatId);
    });

    _addData(data: {
      "payloadType": "chat",
      "modified": false,
      "removed": true,
      "chatList": singleChatDataList,
      "firstQuery": false
    });
  }

  void _modifyConversation(
      {required DocumentSnapshot<Map<String, dynamic>> doc}) {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> chatMessages = [];
    Map<String, dynamic> chatData = {
      "chat": doc.data() as Map<String, dynamic>,
      "messages": chatMessages,
      "userId": GlobalDataContainer.userId,
    };
    List<Map<String, dynamic>> singleChatDataList = [];
    singleChatDataList.add(chatData);

    _addData(data: {
      "payloadType": "chat",
      "modified": true,
      "removed": false,
      "chatList": singleChatDataList,
      "firstQuery": false
    });
  }

  /// Keeps chats up to date
  ///
  /// Listen to new chats, when a chat is removed, or when is modified
  @override
  void initializeChatListener() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        FirebaseFirestore instance = FirebaseFirestore.instance;

        chatListenerSbscription = instance
            .collection("usuarios")
            .doc(userId)
            .collection("conversaciones")
            .orderBy("creacionConversacion", descending: true)
            .snapshots()
            .listen((event) async {
          if (event.docChanges.isNotEmpty) {
            if (event.docChanges.length > 0 && isInitializerFinished == false) {
              await _addCurrentConversations(event: event);
            }
            if (event.docChanges.length > 0 && isInitializerFinished == true) {
              try {
                for (int a = 0; a < event.docChanges.length; a++) {
                  if (event.docChanges[a].type == DocumentChangeType.added) {
                    await _addNewConversation(doc: event.docChanges[a].doc);
                  }

                  if (event.docChanges[a].type == DocumentChangeType.removed) {
                    _removeConversation(doc: event.docChanges[a].doc);
                  }

                  if (event.docChanges[a].type == DocumentChangeType.modified) {
                    _modifyConversation(doc: event.docChanges[a].doc);
                  }
                }
              } catch (e) {
                chatStream?.addError(ChatException(message: e.toString()));

                throw ChatException(message: e.toString());
              }
            }
          } else {
            List<Map<String, dynamic>> emptyList = [];
            _addData(data: {
              "modified": false,
              "removed": false,
              "chatList": emptyList,
              "firstQuery": true,
              "chatListIsEmpty": true
            });
          }
        }, onError: (error) {
          _addError(e: ChatException(message: "ERROR_FROM_BACKEND"));

          throw ChatException(message: "ERROR_FROM_BACKEND");
        }, cancelOnError: true);

        chatListenerSbscription?.onError((_) {
          _addError(e: ChatException(message: "ERROR_FROM_BACKEND"));

          throw ChatException(message: "ERROR_FROM_BACKEND");
        });
      } catch (e) {
        _addError(e: ChatException(message: "ERROR_FROM_BACKEND"));

        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> readMessages(
      String chatId) async {
    FirebaseFirestore instance = FirebaseFirestore.instance;

    List<QueryDocumentSnapshot<Map<String, dynamic>>> data = [];

    QuerySnapshot<Map<String, dynamic>> net = await instance
        .collection("mensajes")
        .where("idConversacion", isEqualTo: chatId)
        .orderBy("horaMensaje", descending: true)
        .get();
    data.addAll(net.docs);

    return data;
  }

  void _addMessage({required Map<String, dynamic> data}) {
    _addData(data: data);
  }

  @override
  void listenToMessages() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

        messageListenerSubscription = firestoreInstance
            .collection("mensajes")
            .where("interlocutores", arrayContains: userId)
            .orderBy("horaMensaje", descending: true)
            .snapshots()
            .listen((event) {
          if (isInitializerFinished) {
            if (event.docChanges.isNotEmpty) {
              try {
                if (event.docChanges.first.type ==
                    DocumentChangeType.modified) {
                  _addMessage(data: {
                    "payloadType": "message",
                    "message": (event.docs.first.data()),
                    "modified": true
                  });
                }
                if (event.docChanges.first.type == DocumentChangeType.added) {
                  _addMessage(data: {
                    "payloadType": "message",
                    "message": event.docs.first.data(),
                    "modified": false
                  });
                }
              } catch (e) {
                _addError(e: ChatException(message: e.toString()));
              }
            }
          }
        });
      } catch (e) {
        _addError(e: ChatException(message: e.toString()));

        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void subscribeToMainDataSource() {
    try {
      userId = source.getData["id"];
      sourceStreamSubscription = source.dataStream.stream.listen((event) {
        userId = event["id"];
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Send messages to the receptor
  ///
  ///
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
        messageData["idEmisor"] = userId;
        messageData["tipoMensaje"] = message["tipoMensaje"];
        messageData["respuesta"] = false;
        messageData["mensajeRespuesta"] = {};
        messageData["cargaNotificacion"] = true;
        messageData["notificarEsteUsuario"] = remitentId;
        messageData["interlocutores"] = [userId, remitentId];
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
      throw NetworkException(message: kNetworkErrorMessage);
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
            .limit(15)
            .get();
        messages.docs.forEach((element) {
          messagesList.add(MessageConverter.fromMap(element.data()));
        });

        return messagesList;
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
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
          Object? objectT = httpsCallableResult.data["datos"];
          profilesCache.add(objectT as Map<dynamic, dynamic>);

          return ProfileMapper.fromMap({
            "profilesList": [profilesCache.first],
            "userCharacteristicsData": source.getData["filtros usuario"],
            "todayDateTime": await DateNTP.instance.getTime()
          }).first;
        } else {
          throw ChatException(message: "PROFILE_COULD_NOT_BE_FETCHED");
        }
      } catch (e) {
        throw ChatException(message: e.toString());
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
  void clearModuleData() {
    try {
      chatListenerSbscription?.cancel();
      chatStream?.close();
      messageListenerSubscription?.cancel();
      messageStream.close();
      chatIds.clear();
      chatListenerSbscription = null;
      chatStream = null;
      chatStream = new StreamController.broadcast();
      messageStream = new StreamController.broadcast();
      sourceStreamSubscription?.cancel();
      sourceStreamSubscription = null;

      isInitializerFinished = false;
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  void initializeModuleData() {
    try {
      subscribeToMainDataSource();
    } catch (e) {
      throw ModuleInitializeException(message: e.toString());
    }
  }
}
