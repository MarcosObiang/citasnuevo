// ignore_for_file: cancel_subscriptions, close_sinks

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import 'package:citasnuevo/App/controllerDef.dart';
import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/services/Ads.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/common/commonUtils/idGenerator.dart';
import '../../core/location_services/locatio_service.dart';
import '../MainDatasource/principalDataSource.dart';
import 'MessageEntity.dart';
import '../DataManager.dart';

abstract class ChatDataSource
    implements
        DataSource,
        ModuleCleanerDataSource,
        ImmageMediaPickerCapacity,
        AdvertisementShowCapacity {
  late StreamSubscription<RealtimeMessage> chatListenerSubscription;
  late List<Message> messagesWithOutChat;
  Future<bool> goToLocationSettings();
  bool isUserPremium = false;

  StreamController<dynamic>? chatStream;

  Future<bool> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});

  Future<bool> messagesSeen({required List<String> messages});

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
  Future<bool> revealBlindDate({required String chatId});

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
  bool isUserPremium = false;

  @override
  StreamSubscription? sourceStreamSubscription;

  List<String> chatIds = [];

  @override
  StreamController? chatStream = new StreamController.broadcast();
  late StreamSubscription<RealtimeMessage> chatListenerSubscription;
  late StreamSubscription<RealtimeMessage> messageListenerSubscription;
  @override
  StreamController<Map<String, dynamic>> messageStream =
      new StreamController.broadcast();

  ChatDatsSourceImpl({required this.source, required this.advertisingServices});

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

  Map<String, dynamic> chatModelToMap(Map<String, dynamic> chatModel) {
    List<Map<String, dynamic>> messagesList = [];

    /*  return {
      "conversationId": chatModel.conversationId,
      "user1Id": chatModel.user1Id,
      "user2Id": chatModel.user2Id,
      "isDeleted": chatModel.isDeleted,
      "messages": messagesList,
      "isBlindDate": chatModel.isBlindDate,
      "user1Name": chatModel.user1Name,
      "user2Name": chatModel.user2Name,
      "user1Picture": chatModel.user1Picture,
      "user2Picture": chatModel.user2Picture,
      "user1Blocked": chatModel.user1Blocked,
      "user2Blocked": chatModel.user2Blocked,
      "user1NotificationToken": chatModel.user1NotificationToken,
      "user2NotificationToken": chatModel.user2NotificationToken,
    };*/

    return {};
  }

  Future<List<Map<String, dynamic>>> loadChats() async {
    List<Map<String, dynamic>> data = [];

    Databases databases = Dependencies.serverAPi.databases;
    DocumentList documentList = await databases.listDocuments(
        databaseId: kDatabaseId,
        collectionId: kConversationsCollectionId,
        queries: [
          Query.or([
            Query.equal("user1Id", GlobalDataContainer.userId),
            Query.equal("user2Id", GlobalDataContainer.userId),
          ]),
        ]);

    for (int i = 0; i < documentList.documents.length; i++) {
      DocumentList documentListMessages = await databases.listDocuments(
          databaseId: kDatabaseId,
          collectionId: kMessagesCollectionId,
          queries: [
            Query.equal("conversationId",
                documentList.documents[i].data["conversationId"]),
            Query.orderDesc("timestamp")
          ]);

      data.add({
        "chat": documentList.documents[i].data,
        "messages": documentListMessages.documents
            .map((element) => element.data)
            .toList(),
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
    Realtime realtime = Realtime(Dependencies.serverAPi.client);

    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        await _addCurrentConversations();
        chatListenerSubscription = realtime
            .subscribe([
              "databases.${kDatabaseId}.collections.${kConversationsCollectionId}.documents"
            ])
            .stream
            .listen((event) {
              String updateEvent =
                  "databases.${kDatabaseId}.collections.${kConversationsCollectionId}.documents.*.update";
              String createEvent =
                  "databases.${kDatabaseId}.collections.${kConversationsCollectionId}.documents.*.create";
              String deleteEvent =
                  "databases.${kDatabaseId}.collections.${kConversationsCollectionId}.documents.*.delete";
              dev.log(event.events.toString());

              if (event.events.contains(updateEvent)) {
                _modifyConversation(doc: event.payload);
              } else if (event.events.contains(createEvent)) {
                _addNewConversation(doc: event.payload);
              } else if (event.events.contains(deleteEvent)) {
                _removeConversation(doc: event.payload);
              }
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
    _addData(
        data: {"payloadType": "message", "message": data, "modified": false});
  }

  void _updateMessage({required Map<String, dynamic> data}) {
    _addData(
        data: {"payloadType": "message", "message": data, "modified": true});
  }

  Map<String, dynamic> messageModelToMap(Map<String, dynamic> messageModel) {
    /* return {
      "senderId": messageModel.senderId,
      "recieverId": messageModel.recieverId,
      "message": messageModel.message,
      "messageId": messageModel.messageId,
      "timestamp": messageModel.timestamp,
      "messageType": messageModel.messageType,
      "conversationId": messageModel.conversationId,
      "readByReciever": messageModel.readByReciever,
    };*/

    return {};
  }

  @override
  void listenToMessages() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      Realtime realtime = Realtime(Dependencies.serverAPi.client);
      try {
        messageListenerSubscription = realtime
            .subscribe([
              "databases.${kDatabaseId}.collections.${kMessagesCollectionId}.documents"
            ])
            .stream
            .listen((event) {
              String updateEvent =
                  "databases.${kDatabaseId}.collections.${kMessagesCollectionId}.documents.*.update";
              String createEvent =
                  "databases.${kDatabaseId}.collections.${kMessagesCollectionId}.documents.*.create";
              String deleteEvent =
                  "databases.${kDatabaseId}.collections.${kMessagesCollectionId}.documents.*.delete";
              dev.log(event.events.toString());

              if (event.events.contains(updateEvent)) {
                _updateMessage(data: event.payload);
              }
              if (event.events.contains(createEvent)) {
                _addMessage(data: event.payload);
              }
              /* if(event.events.contains(deleteEvent)){
                _addMessage(data: event.payload);
              }*/
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
        isUserPremium = event["isUserPremium"];
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
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        String userMessage = message["messageContent"];

        if (message["messageType"] == MessageType.AUDIO.name ||
            message["messageType"] == MessageType.IMAGE.name) {
          userMessage = base64Encode(message["fileData"]);
        }

        Execution execution =
            await Dependencies.serverAPi.functions.createExecution(
                functionId: "sendMessages",
                body: jsonEncode({
                  "conversationId": message["conversationId"],
                  "messageType": message["messageType"],
                  "message": userMessage,
                  "senderId": userId,
                  "recieverId": remitentId,
                  "recieverNotificationId": messageNotificationToken,
                }));

        int statusCode = execution.responseStatusCode;
        String responseMessage = jsonDecode(execution.responseBody)["message"];
        if (statusCode == 200) {
          return true;
        } else {
          throw ChatException(message: responseMessage);
        }
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
    if (await Dependencies.networkInfoContract.isConnected) {
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
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution = await Dependencies.serverAPi.functions
            .createExecution(
                functionId: "getSingleUserProfile",
                body: jsonEncode({"userId": profileId}));

        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];
        dynamic payload = jsonDecode(execution.responseBody)["payload"];

        if (status == 200) {
          return {
            "profileData": [payload],
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
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution =
            await Dependencies.serverAPi.functions.createExecution(
                functionId: "deleteConversation",
                body: jsonEncode({
                  "conversationId": chatId,
                  "userReported": reportDetails != kNotAvailable ? true : false,
                  "reportDetails": reportDetails,
                  "userId": GlobalDataContainer.userId,
                  "userReportedId": remitent1 == GlobalDataContainer.userId
                      ? remitent2
                      : remitent1
                }));

        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];

        if (status == 200) {
          return true;
        } else {
          throw ChatException(message: message);
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
      chatListenerSubscription.cancel();
      chatStream?.close();
      messageListenerSubscription.cancel();
      messageStream.close();
      chatIds.clear();
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
  Future<bool> messagesSeen({required List<String> messages}) async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution = await Dependencies.serverAPi.functions
            .createExecution(
                functionId: "confirmMessagesHadBeenRead",
                body: jsonEncode({"messagesIds": messages}));

        int statusCode = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];
        if (statusCode == 200) {
          return true;
        } else {
          throw ChatException(message: message);
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
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Map<String, dynamic> locationServicesStatus =
            await LocationService.instance.locationServicesState();
        if (locationServicesStatus["status"] == "correct") {
          Execution execution =
              await Dependencies.serverAPi.functions.createExecution(
                  functionId: "createBlindDate",
                  body: jsonEncode({
                    "userId": GlobalDataContainer.userId,
                    "distance": 60,
                    "lat": locationServicesStatus["lat"],
                    "lon": locationServicesStatus["lon"],
                    "isShowAdOfferUsed": false
                  }));

          int status = execution.responseStatusCode;
          String message = jsonDecode(execution.responseBody)["message"];

          if (status == 200) {
            return true;
          } else {
            throw ChatException(message: message);
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

  @override
  Future<bool> revealBlindDate({required String chatId}) async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution = await Dependencies.serverAPi.functions
            .createExecution(
                functionId: "revealBlindDate",
                body: jsonEncode({"chatId": chatId}));

        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];

        if (status == 200) {
          return true;
        } else {
          throw ChatException(message: message);
        }
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  AdvertisingServices advertisingServices;

  @override
  void closeAdsStreams() {
    advertisingServices.closeStream();
  }

  @override
  // TODO: implement rewadedAdvertismentStatusListener
  StreamController<Map<String, dynamic>>
      get rewadedAdvertismentStatusListener =>
          advertisingServices.rewardedAdvertismentStateStream;

  @override
  Future<bool> showRewardedAd() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        return advertisingServices.showAd();
      } catch (e) {
        throw ChatException(message: "FAILED");
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }
}
