// ignore_for_file: cancel_subscriptions, close_sinks

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/App/controllerDef.dart';
import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/common/commonUtils/idGenerator.dart';
import '../../core/location_services/locatio_service.dart';
import '../MainDatasource/principalDataSource.dart';
import 'MessageEntity.dart';
import '../DataManager.dart';

abstract class ChatDataSource
    implements DataSource, ModuleCleanerDataSource, ImmageMediaPickerCapacity {
  StreamSubscription<RealtimeMessage>? chatListenerSubscription;
  late List<Message> messagesWithOutChat;
  Future<bool> goToLocationSettings();

  StreamController<dynamic>? chatStream;

  Future<bool> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});

  Future<bool> messagesSeen({required List<String> messagesIds});

  void initializeChatListener();
  void listenToMessages();
  Future<bool> sendMessages(
      {required Map<String, dynamic> message,
      required String messageNotificationToken,
      required String remitentId});

  Future<dynamic> loadMoreMessages(
      {required String chatId, required String lastMessageId});
  Future<Map<String, dynamic>> getUserProfile({required String profileId});
  Future<bool> createBlindDate();

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
  StreamSubscription<RealtimeMessage>? chatListenerSubscription;
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
    String chatId = doc["conversationId"];
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
        "messages": messages.documents.map((e) => e.data).toList(),
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
                    "databases.636d59d7a2f595323a79.collections.637d10c17be1c3d1544d.documents.${dato.payload["conversationId"]}.create";
                String updateEvent =
                    "databases.636d59d7a2f595323a79.collections.637d10c17be1c3d1544d.documents.${dato.payload["conversationId"]}.update";
                String deleteEvent =
                    "databases.636d59d7a2f595323a79.collections.637d10c17be1c3d1544d.documents.${dato.payload["conversationId"]}.delete";
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
      sourceStreamSubscription = source.dataStream?.stream.listen((event) {
        userId = event["userId"];
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<String> uploadFile(
      {required Uint8List fileData, required String remitentId}) async {
    try {
      String id = IdGenerator.instancia.createId();
      Storage appwriteStorage = Storage(Dependencies.serverAPi.client!);

      File result = await appwriteStorage.createFile(
          bucketId: "63712fd65399f32a5414",
          fileId: "chatFile$id",
          file: InputFile.fromBytes(bytes: fileData, filename: "chatFile$id"));

      return result.name;
    } catch (e) {
      if (e is AppwriteException) {
        throw Exception(e.message);
      } else {
        throw Exception(e.toString());
      }
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
        String userMessage = message["messageContent"];

        if (message["messageType"] == MessageType.AUDIO.name ||
            message["messageType"] == MessageType.IMAGE.name) {
          userMessage = await uploadFile(
              fileData: message["fileData"], remitentId: remitentId);
        }
        Functions functions = Functions(Dependencies.serverAPi.client!);

        Execution execution = await functions.createExecution(
            xasync: false,
            functionId: "sendMessages",
            data: jsonEncode({
              "senderId": GlobalDataContainer.userId,
              "recieverNotificationId": messageNotificationToken,
              "recieverId": remitentId,
              "message": userMessage,
              "conversationId": message["conversationId"],
              "messageType": message["messageType"],
            }));

        int status = jsonDecode(execution.response)["status"];
        String messageResponse = jsonDecode(execution.response)["message"];

        if (status == 200) {
        } else {
          throw ChatException(message: messageResponse);
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
        int status = jsonDecode(execution.response)["status"];

        if (status == 200) {
          return {
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
            data: jsonEncode({
              "conversationId": chatId,
              "userReported": reportDetails != kNotAvailable ? true : false,
              "reportDetails": reportDetails,
              "userId": GlobalDataContainer.userId,
              "userReportedId": remitent1 == GlobalDataContainer.userId
                  ? remitent2
                  : remitent1
            }));

        int status = jsonDecode(execution.response)["status"];
        String messageResponse = jsonDecode(execution.response)["message"];

        if (status == 200) {
          return true;
        } else {
          throw ChatException(message: messageResponse);
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

  @override
  Future<bool> messagesSeen({required List<String> messagesIds}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
            functionId: "confirmMessagesHadBeenRead",
            data: jsonEncode({"messagesIds": messagesIds}));

        int status = jsonDecode(execution.response)["status"];
        String messageResponse = jsonDecode(execution.response)["message"];

        if (status == 200) {
          return true;
        } else {
          throw ChatException(message: messageResponse);
        }
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<Uint8List?> getImage() async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        var imageCropped = await ImageCropper()
            .cropImage(sourcePath: image.path, compressQuality: 70);
        var finalData = await imageCropped?.readAsBytes();
        return finalData;
      } else {
        throw Exception("IMAGE_NOT_AVAILABLE");
      }
    } catch (e) {
      throw ChatException(message: e.toString());
    }
  }

  @override
  Future<bool> createBlindDate() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Map<String, dynamic> locationServicesStatus =
            await LocationService.instance.locationServicesState();
        if (locationServicesStatus["status"] == "correct") {
          Functions functions = Functions(Dependencies.serverAPi.client!);
          Execution execution = await functions.createExecution(
              functionId: "createBlindDate",
              data: jsonEncode({
                "userId": GlobalDataContainer.userId,
                "distance": 6,
                "lat": locationServicesStatus["lat"],
                "lon": locationServicesStatus["lon"],
              }));

          int status = jsonDecode(execution.response)["status"];
          String messageResponse = jsonDecode(execution.response)["message"];

          if (status == 200) {
            return true;
          } else {
            throw ChatException(message: messageResponse);
          }
        } else {
          throw LocationServiceException(
              message: locationServicesStatus["status"]);
        }
      } catch (e) {
        if (e is LocationServiceException) {
          throw LocationServiceException(message: e.message);
        } else {
          throw ChatException(message: e.toString());
        }
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> goToLocationSettings() async {
    try {
      bool openSettings = await LocationService.instance.gotoLocationSettings();
      return openSettings;
    } catch (e) {
      throw LocationServiceException(message: e.toString());
    }
  }
}
