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
import 'package:citasnuevo/core/services/Ads.dart';
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
  late StreamSubscription<Map<String, dynamic>>
      chatListenerSubscription;
  late List<Message> messagesWithOutChat;
  Future<bool> goToLocationSettings();
  bool isUserPremium = false;

  StreamController<dynamic>? chatStream;

  Future<bool> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});

  Future<bool> messagesSeen({required List<Map<String, dynamic>> messages});

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
  late StreamSubscription<Map<String, dynamic>>
      chatListenerSubscription;
  late StreamSubscription<Map<String, dynamic>>
      messageListenerSubscription;
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

  Map<String, dynamic> chatModelToMap(Map<String,dynamic> chatModel) {
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

   /* final realmReference = source.realm!.query<ChatModel>(
        r'user1Id == $0 OR user2Id == $0', [GlobalDataContainer.userId, false]);

    realmReference.forEach((element) {
      if (element.isDeleted == false) {
        final realmReferenceMessages = source.realm!.query<MessageModel>(
          r'conversationId == $0 SORT(timestamp DESC)',
          ['${element.conversationId}'],
        );
        List<Map<String, dynamic>> messagesList = [];
        realmReferenceMessages.forEach((element) {
          messagesList.add(messageModelToMap(element));
        });

        data.add({
          "chat": chatModelToMap(element),
          "messages": messagesList,
          "userId": GlobalDataContainer.userId,
        });
      }
    });*/
    return data;
  }

  /// Keeps chats up to date
  ///
  /// Listen to new chats, when a chat is removed, or when is modified
  @override
  void initializeChatListener() async {
    /*if (await Dependencies.networkInfoContract.isConnected) {
      try {
        await _addCurrentConversations();

        chatListenerSubscription = source.realm!
            .query<ChatModel>(r'user1Id == $0 OR user2Id == $0',
                ['${GlobalDataContainer.userId}'])
            .changes
            .listen((RealmResultsChanges<ChatModel> event) async {
              if (event.inserted.isNotEmpty) {
                List<int> indexes = event.inserted;

                for (int i = 0; i < indexes.length; i++) {
                  if (event.results[indexes[i]].isDeleted == true) {
                    _removeConversation(
                        doc: chatModelToMap(event.results[indexes[i]]));
                  } else {
                    _addNewConversation(
                        doc: chatModelToMap(event.results[indexes[i]]));
                  }
                }
              }
              if (event.modified.isNotEmpty) {
                List<int> indexes = event.modified;

                for (int i = 0; i < indexes.length; i++) {
                  if (event.results[indexes[i]].isDeleted == true) {
                    _removeConversation(
                        doc: chatModelToMap(event.results[indexes[i]]));
                  } else {
                    _modifyConversation(
                        doc: chatModelToMap(event.results[indexes[i]]));
                  }
                }
              }

              if (event.newModified.isNotEmpty) {
                List<int> indexes = event.newModified;

                for (int i = 0; i < indexes.length; i++) {
                  if (event.results[indexes[i]].isDeleted == true) {
                    _removeConversation(
                        doc: chatModelToMap(event.results[indexes[i]]));
                  } else {
                    _modifyConversation(
                        doc: chatModelToMap(event.results[indexes[i]]));
                  }
                }
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
    }*/
  }

  void _addMessage({required Map<String, dynamic> data}) {
    _addData(data: data);
  }

  Map<String, dynamic> messageModelToMap(Map <String,dynamic> messageModel) {
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
    /*if (await Dependencies.networkInfoContract.isConnected) {
      try {
       messageListenerSubscription = source.realm!
            .query<MessageModel>(r'recieverId == $0 OR senderId == $0',
                ["${GlobalDataContainer.userId}"])
            .changes
            .listen((event) {
              if (event.inserted.isNotEmpty) {
                List<int> indexes = event.inserted;
                for (int i = 0; i < indexes.length; i++) {
                  _addMessage(data: {
                    "payloadType": "message",
                    "message": messageModelToMap(event.results[indexes[i]]),
                    "modified": false
                  });
                }
              }

              if (event.modified.isNotEmpty) {
                List<int> indexes = event.modified;

                for (int i = 0; i < indexes.length; i++) {
                  if (event.newModified.contains(event.newModified[i])) {
                    break;
                  }
                  _addMessage(data: {
                    "payloadType": "message",
                    "message": messageModelToMap(event.results[indexes[i]]),
                    "modified": true
                  });
                }
              }

              if (event.newModified.isNotEmpty) {
                List<int> indexes = event.newModified;

                for (int i = 0; i < indexes.length; i++) {
                  if (event.modified.contains(indexes[i])) {
                    break;
                  }
                  _addMessage(data: {
                    "payloadType": "message",
                    "message": messageModelToMap(event.results[indexes[i]]),
                    "modified": true
                  });
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
      userId = source.getData["userId"];
      sourceStreamSubscription = source.dataStream?.stream.listen((event) {
        userId = event["userId"];
        isUserPremium = event["isUserPremium"];
      });
    } catch (e) {
      throw Exception(e);
    }*/
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
   /*   try {
        String userMessage = message["messageContent"];

        if (message["messageType"] == MessageType.AUDIO.name ||
            message["messageType"] == MessageType.IMAGE.name) {
          userMessage = base64Encode(message["fileData"]);
        }

        var realmReference = await source.realm!.writeAsync<MessageModel>(() {
          ObjectId id = ObjectId();

          return source.realm!.add(MessageModel(
            id,
            userMessage,
            GlobalDataContainer.userId,
            remitentId,
            message["conversationId"],
            DateTime.now().millisecondsSinceEpoch,
            id.toString(),
            false,
            message["messageType"],
          ));
        });

        return true;
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/

  }
      return true;


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
   /* if (await Dependencies.networkInfoContract.isConnected) {
      try {
        final response = await Dependencies
            .serverAPi.app!.currentUser!.functions
            .call("getSingleUserProfile", [
          jsonEncode({"userId": profileId})
        ]);
        int status = jsonDecode(response)["executionCode"];

        if (status == 200) {
          return {
            "profileData": jsonDecode(response)["payload"],
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
    }*/

    return {};
  }

  @override
  Future<bool> deleteChat({
    required String remitent1,
    required String remitent2,
    required String reportDetails,
    required String chatId,
  }) async {
   /* if (await Dependencies.networkInfoContract.isConnected) {
      try {
        final response = await Dependencies
            .serverAPi.app!.currentUser!.functions
            .call("deleteChat", [
          jsonEncode({
            "conversationId": chatId,
            "isUserBeingReported":
                reportDetails != kNotAvailable ? true : false,
            "reportDetails": reportDetails,
            "userId": GlobalDataContainer.userId,
            "userReportedId":
                remitent1 == GlobalDataContainer.userId ? remitent2 : remitent1
          })
        ]);
        int status = jsonDecode(response)["executionCode"];
        String message = jsonDecode(response)["message"];

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
    }*/

    return true;
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
  Future<bool> messagesSeen(
      {required List<Map<String, dynamic>> messages}) async {
   /* if (await Dependencies.networkInfoContract.isConnected) {
      try {
        List<MessageModel> messagesParsed = [];
        messages.forEach((element) {
          messagesParsed.add(MessageModel(
            ObjectId.fromHexString(element["messageId"]),
            element["messageContent"],
            element["senderId"],
            GlobalDataContainer.userId,
            element["conversationId"],
            element["timestamp"],
            element["messageId"],
            true,
            element["messageType"],
          ));
        });

        await source.realm!.writeAsync(() {
          source.realm?.addAll(messagesParsed, update: true);
        });

        return true;
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/

    return true;
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
   /* if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Map<String, dynamic> locationServicesStatus =
            await LocationService.instance.locationServicesState();
        if (locationServicesStatus["status"] == "correct") {
          final response = await Dependencies
              .serverAPi.app!.currentUser!.functions
              .call("createBlindDate", [
            jsonEncode({
              "userId": GlobalDataContainer.userId,
              "distance": 60,
              "lat": locationServicesStatus["lat"],
              "lon": locationServicesStatus["lon"],
            })
          ]);
          int status = jsonDecode(response)["executionCode"];
          String message = jsonDecode(response)["message"];

          if (status == 200) {
            return true;
          } else {
            throw ChatException(message: "Something went wrong");
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
    }*/

    return true;
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
  /*  if (await Dependencies.networkInfoContract.isConnected) {
      try {
        final response = await Dependencies
            .serverAPi.app!.currentUser!.functions
            .call("revealBlindDate", [
          jsonEncode({"chatId": chatId})
        ]);

        int status = jsonDecode(response)["executionCode"];

        if (status == 200) {
          return true;
        } else {
          throw ChatException(message: "Something went wrong");
        }
      } catch (e) {
        throw ChatException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/

    return true;
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
  
  @override
  void subscribeToMainDataSource() {
    // TODO: implement subscribeToMainDataSource
  }
}
