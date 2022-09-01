// ignore_for_file: cancel_subscriptions, close_sinks

import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/common/commonUtils/idGenerator.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/ChatConverter.dart';
import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:citasnuevo/data/Mappers/ProfilesMapper.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/ProfileEntity.dart';
import '../../../domain/repository/DataManager.dart';

abstract class ChatDataSource implements DataSource,ModuleCleanerDataSource {
  StreamSubscription<QuerySnapshot<Object?>>? chatListenerSbscription;
  StreamSubscription<QuerySnapshot<Object?>>? messageListenerSubscription;
  late List<Message> messagesWithOutChat;

  StreamController<dynamic>? chatStream;
  late StreamController<Map<String, dynamic>> messageStream;

  Future<bool> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});

  void initializeChatListener();
  void listenToMessages();
 

  Future<Map<String,dynamic>> getUserProfile({required String profileId});
//void sendMessages()

}

class ChatDatsSourceImpl implements ChatDataSource {
  @override
  ApplicationDataSource source;
  bool isInitializerFinished = false;
  String? userId = kNotAvailable;
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
    List<QueryDocumentSnapshot<Map<String, dynamic>>> emptyMessagesList = [];

    for (int i = 0; i < event.docChanges.length; i++) {
      String chatId = event.docChanges[i].doc.get("idConversacion");

    
      Map<String, dynamic> chatData = {
        "chat": event.docChanges[i].doc.data() as Map<String, dynamic>,
        "userId": GlobalDataContainer.userId,
      };
      chatDataList.add(chatData);
      chatIds.add(chatId);
    }

    try {
      chatStream?.add({
        "modified": false,
        "removed": false,
        "added": false,
        "chatDataList": chatDataList,
        "firstQuery": true,
        "chatListIsEmpty": false
      });

      isInitializerFinished = true;
    } catch (e) {
      throw ChatException(message: e.toString());
    }
  }

  Future<void> _addNewConversation(
      {required DocumentSnapshot<Map<String, dynamic>> doc}) async {
    String chatId = doc.get("idConversacion");
    if (chatIds.contains(chatId) == false) {
      

      List<QueryDocumentSnapshot<Map<String, dynamic>>> emptyList = [];

      Map<String, dynamic> chatData = {
        "chat": doc.data() as Map<String, dynamic>,
        "userId": GlobalDataContainer.userId,
      };
      List<Map<String, dynamic>> singleChatDataList = [];
      singleChatDataList.add(chatData);

      chatIds.add(chatId);

      chatStream?.add({
        "added": true,
        "modified": false,
        "removed": false,
        "chatDataList": singleChatDataList,
        "firstQuery": false,
        "chatListIsEmpty": false
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
    List<Map<String, dynamic>> singleChatDataList = [];
    singleChatDataList.add(chatData);

    List<Chat> object = ChatConverter.fromMap(singleChatDataList);
    object.forEach((element) {
      chatIds.removeWhere((chatID) => chatID == element.chatId);
    });

    chatStream?.add({
      "modified": false,
      "removed": true,
      "chatDataList": singleChatDataList,
      "firstQuery": false,
      "added": false,
      "chatListIsEmpty": false
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

    chatStream?.add({
      "modified": true,
      "removed": false,
      "chatDataList": singleChatDataList,
      "firstQuery": false,
      "added": false,
      "chatListIsEmpty": false
    });
  }

  void _emptyConversation() {
    List<Chat> emptyList = [];
    chatStream?.add({
      "modified": false,
      "removed": false,
      "chatDataList": emptyList,
      "firstQuery": true,
      "chatListIsEmpty": true
    });
  }

  /// Keeps chats up to date
  ///
  /// Listen to new chats, when a chat is removed, or when is modified
  @override
  void initializeChatListener() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        if (userId != null) {
          FirebaseFirestore instance = FirebaseFirestore.instance;

          chatListenerSbscription = instance
              .collection("usuarios")
              .doc(userId)
              .collection("conversaciones")
              .orderBy("creacionConversacion", descending: true)
              .snapshots()
              .listen((event) async {
            if (event.docChanges.isNotEmpty) {
              if (event.docChanges.length > 0 &&
                  isInitializerFinished == false) {
                await _addCurrentConversations(event: event);
              }
              if (event.docChanges.length > 0 &&
                  isInitializerFinished == true) {
                try {
                  for (int a = 0; a < event.docChanges.length; a++) {
                    if (event.docChanges[a].type == DocumentChangeType.added) {
                      await _addNewConversation(doc: event.docChanges[a].doc);
                    }

                    if (event.docChanges[a].type ==
                        DocumentChangeType.removed) {
                      _removeConversation(doc: event.docChanges[a].doc);
                    }

                    if (event.docChanges[a].type ==
                        DocumentChangeType.modified) {
                      _modifyConversation(doc: event.docChanges[a].doc);
                    }
                  }
                } catch (e) {
                  chatStream?.addError(ChatException(message: e.toString()));

                  throw ChatException(message: e.toString());
                }
              }
            } else {
              _emptyConversation();
            }
          }, onError: (error) {
            chatStream?.addError(ChatException(message: "ERROR_FROM_BACKEND"));

            throw ChatException(message: "ERROR_FROM_BACKEND");
          }, cancelOnError: true);
        }
        if (userId == null) {
          throw ChatException(message: "USER_ID_CANNOT_BE_NULL");
        }

        chatListenerSbscription?.onError((_) {
          chatStream?.addError(ChatException(message: "ERROR_FROM_BACKEND"));

          throw ChatException(message: "ERROR_FROM_BACKEND");
        });
      } catch (e) {
        chatStream?.addError(ChatException(message: "ERROR_FROM_BACKEND"));

        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }



  @override
  void listenToMessages() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        if (userId != null) {
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
                    messageStream.add({
                      "message": event.docs.first.data(),
                      "modified": true
                    });
                  }
                  if (event.docChanges.first.type == DocumentChangeType.added) {
                    messageStream.add({
                      "message": event.docs.first.data(),
                      "modified": false
                    });

                  }
                } catch (e) {
                  messageStream.addError(ChatException(message: e.toString()));
                }
              }
            }
          });
        }
        if (userId == null) {
          throw ChatException(message: "USER_ID_CANNOT_BE_NULL");
        }
      } catch (e) {
        messageStream.addError(ChatException(message: e.toString()));

        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void subscribeToMainDataSource() {
    userId = source.getData["id"];
    sourceStreamSubscription = source.dataStream.stream.listen((event) {
      userId = event["id"];
    });
  }

  /// Send messages to the receptor
  ///
  ///



  




  @override
  Future<Map<String,dynamic>> getUserProfile({required String profileId}) async {
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
