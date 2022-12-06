// ignore_for_file: cancel_subscriptions, close_sinks

import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/common/commonUtils/idGenerator.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
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
import 'package:flutter/foundation.dart';

import '../../../domain/entities/ProfileEntity.dart';

abstract class ChatDataSource implements DataSource, ModuleCleanerDataSource {
  StreamSubscription<RealtimeMessage>? chatListenerSubscription;
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
  Future<Map<String, dynamic>> getUserProfile({required String profileId});
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
  StreamSubscription<RealtimeMessage>? chatListenerSubscription;
  @override
  StreamSubscription<RealtimeMessage>? messageListenerSubscription;
  @override
  StreamController<Map<String, dynamic>> messageStream =
      new StreamController.broadcast();

  ChatDatsSourceImpl({
    required this.source,
  });

  Future<void> _addCurrentConversations() async {
    try {
      List<Map<String, dynamic>> chatDataList = await loadChats();

      chatStream?.add({
        "modified": false,
        "removed": false,
        "chatList": chatDataList,
        "added": false,
        "firstQuery": true,
        "chatListIsEmpty": false,
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

  Future<void> _addNewConversation({required Map<String, dynamic> doc}) async {
    String chatId = doc["idConversacion"];
    if (chatIds.contains(chatId) == false) {
      List<Map<String, dynamic>> emptyList = [];

      Map<String, dynamic> chatData = {
        "chat": doc,
        "messages": emptyList,
        "userId": GlobalDataContainer.userId,
      };
      List<Map<String, dynamic>> singleChatDataList = [];
      singleChatDataList.add(chatData);

      chatIds.add(chatId);

      _addData(data: {
        "modified": false,
        "removed": false,
        "chatList": singleChatDataList,
        "added": false,
        "firstQuery": true,
        "chatListIsEmpty": false,
        "payloadType": "chat",
      });
    }
  }

  void _removeConversation({required Map<String, dynamic> doc}) {
    List<Map<String, dynamic>> chatMessages = [];
    Map<String, dynamic> chatData = {
      "chat": doc,
      "messages": chatMessages,
      "userId": GlobalDataContainer.userId,
    };
    String? chatId = doc["conversationId"];
    List<Map<String, dynamic>> singleChatDataList = [];
    singleChatDataList.add(chatData);

    singleChatDataList.forEach((element) {
      chatIds.removeWhere((chatID) => chatID == chatId);
    });

    _addData(data: {
      "payloadType": "chat",
      "modified": false,
      "removed": true,
      "added": false,
      "chatList": singleChatDataList,
      "firstQuery": false,
      "chatListIsEmpty": false
    });
  }

  void _modifyConversation({required Map<String, dynamic> doc}) {
    List<Map<String, dynamic>> chatMessages = [];
    Map<String, dynamic> chatData = {
      "chat": doc,
      "messages": chatMessages,
      "userId": GlobalDataContainer.userId,
    };
    List<Map<String, dynamic>> singleChatDataList = [];
    singleChatDataList.add(chatData);

    _addData(data: {
      "payloadType": "chat",
      "modified": true,
      "added": false,
      "removed": false,
      "chatList": singleChatDataList,
      "firstQuery": false,
      "chatListIsEmpty": false
    });
  }

  Future<List<Map<String, dynamic>>> loadChats() async {
    List<Map<String, dynamic>> data = [];
    Databases databases = Databases(Dependencies.serverAPi.client!);
    DocumentList documentList = await databases.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "637d10c17be1c3d1544d",
        queries: [
          Query.equal("user1Id", GlobalDataContainer.userId),
        ]);
    DocumentList documentList2 = await databases.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "637d10c17be1c3d1544d",
        queries: [Query.equal("user2Id", GlobalDataContainer.userId)]);

    documentList.documents.addAll(documentList2.documents);
    for (int i = 0; i < documentList.documents.length; i++) {
      var messages = await databases.listDocuments(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "637d18ff8b3927cce18d",
          queries: [
            Query.orderDesc("timestamp"),
            Query.equal("conversationId", documentList.documents[i].$id),
          ]);

      data.add({
        "chat": documentList.documents[i].data,
        "messages": messages.documents,
        "userId": GlobalDataContainer.userId,
      });
    }
    return data;
  }

  /// Keeps chats up to date
  ///
  /// Listen to new chats, when a chat is removed, or when is modified
  @override
  void initializeChatListener() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        await _addCurrentConversations();
        Realtime realtime = Realtime(Dependencies.serverAPi.client!);
        chatListenerSubscription = realtime
            .subscribe([
              "databases.636d59d7a2f595323a79.collections.637d10c17be1c3d1544d.documents"
            ])
            .stream
            .listen((dato) async {
              try {
                String createEvent =
                    "databases.636d59d7a2f595323a79.collections.637d10c17be1c3d1544d.documents.${dato.payload["reactionId"]}.create";
                String updateEvent =
                    "databases.636d59d7a2f595323a79.collections.637d10c17be1c3d1544d.documents.${dato.payload["reactionId"]}.update";
                String deleteEvent =
                    "databases.636d59d7a2f595323a79.collections.637d10c17be1c3d1544d.documents.${dato.payload["reactionId"]}.delete";
                if (dato.events.first.contains(createEvent)) {
                  await _addNewConversation(doc: dato.payload);
                }
                if (dato.events.first.contains(updateEvent)) {
                  _modifyConversation(doc: dato.payload);
                }
                if (dato.events.first.contains(deleteEvent)) {
                  _removeConversation(doc: dato.payload);
                }
              } catch (e) {
                if (e is AppwriteException) {
                  chatStream
                      ?.addError(ChatException(message: e.message.toString()));
                } else {
                  chatStream?.addError(ChatException(message: e.toString()));
                }
              }
            }, onError: (error) {
              _addError(e: ChatException(message: "ERROR_FROM_BACKEND"));
            });

        chatListenerSubscription?.onError((_) {
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

  void _addMessage({required Map<String, dynamic> data}) {
    _addData(data: data);
  }

  @override
  void listenToMessages() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Realtime realtime = Realtime(Dependencies.serverAPi.client!);
        messageListenerSubscription = realtime
            .subscribe([
              "databases.636d59d7a2f595323a79.collections.637d18ff8b3927cce18d.documents"
            ])
            .stream
            .listen((dato) {
              try {
                String createEvent =
                    "databases.636d59d7a2f595323a79.collections.637d18ff8b3927cce18d.documents.${dato.payload["messageId"]}.create";
                String updateEvent =
                    "databases.636d59d7a2f595323a79.collections.637d18ff8b3927cce18d.documents.${dato.payload["messageId"]}.update";

                if (dato.events.first.contains(createEvent)) {
                  _addMessage(data: {
                    "payloadType": "message",
                    "message": dato.payload,
                    "modified": false
                  });
                }
                if (dato.events.first.contains(updateEvent)) {
                  _addMessage(data: {
                    "payloadType": "message",
                    "message": (dato.payload),
                    "modified": true
                  });
                }
              } catch (e) {
                if (e is AppwriteException) {
                  _addError(e: ChatException(message: e.message.toString()));
                } else {
                  _addError(e: ChatException(message: e.toString()));
                }
              }
            }, onError: (e) {
              _addError(e: ChatException(message: e.toString()));
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
      userId = source.getData["userId"];
      sourceStreamSubscription = source.dataStream.stream.listen((event) {
        userId = event["userId"];
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
        Functions functions = Functions(Dependencies.serverAPi.client!);

        Execution execution = await functions.createExecution(
            functionId: "sendMessages",
            data: jsonEncode({
              "senderId": GlobalDataContainer.userId,
              "recieverId": remitentId,
              "message": message["messageContent"],
              "conversationId": message["conversationId"],
              "messageType": message["messageType"],
            }));

        if (execution.statusCode == 200) {
          print("excellent");
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
  Future<bool> messagesSeen({required List<String> data}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      //   FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

      try {
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
      List<Message> messagesList = [];

      try {
        return messagesList;
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProfile(
      {required String profileId}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
            functionId: "getSingleUserProfile",
            data: jsonEncode({"userId": profileId}));

        if (execution.status == "completed") {
          return  {
            "profileData": jsonDecode(execution.response)["payload"],
            "userData": source.getData,
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
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
            functionId: "deleteConversation",
            data: jsonEncode({"conversationId": chatId}));

        if (jsonDecode(execution.response)["payload"] == "correcto") {
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
      chatListenerSubscription?.cancel();
      chatStream?.close();
      messageListenerSubscription?.cancel();
      messageStream.close();
      chatIds.clear();
      chatListenerSubscription = null;
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
