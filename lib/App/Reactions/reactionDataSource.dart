import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:async/async.dart';
import 'package:citasnuevo/App/controllerDef.dart';
import 'package:citasnuevo/core/services/Ads.dart';

import '../../../../core/globalData.dart';
import '../DataManager.dart';
import '../MainDatasource/principalDataSource.dart';
import '../../core/common/commonUtils/DateNTP.dart';
import '../../core/dependencies/dependencyCreator.dart';
import '../../core/error/Exceptions.dart';
import '../../core/params_types/params_and_types.dart';

abstract class ReactionDataSource
    implements DataSource, ModuleCleanerDataSource, AdvertisementShowCapacity {
// ignore: close_sinks
  late StreamController<Map<String, dynamic>>? reactionListener;
  // ignore: close_sinks

  Future<void> revealReaction(String reactionId, bool showAd);

  Future<bool> acceptReaction({
    required String reactionId,
    required String reactionSenderId,
  });

  Future<bool> rejectReaction({required List<String> reactionId});
  Map<String, dynamic> getAdditionalData();
}

class ReactionDataSourceImpl implements ReactionDataSource {
  @override
  StreamController<Map<String, dynamic>>? reactionListener =
      new StreamController();

  @override
  StreamSubscription? sourceStreamSubscription;
  @override
  AdvertisingServices advertisingServices;
  StreamSubscription<RealtimeMessage>? reactionSubscriptionListener;

  @override
  StreamController<Map<String, dynamic>>
      get rewadedAdvertismentStatusListener =>
          advertisingServices.rewardedAdvertismentStateStream;

  @override
  ApplicationDataSource source;
  String? userID = kNotAvailable;
  int reactionAverage = 0;
  int totalReactionPoints = 0;
  int reactionCount = 0;

  int? coins = 0;
  Map? aditionalData = new Map();
  bool? isPremium = false;
  List<String> reactionsId = [];

  ReactionDataSourceImpl(
      {required this.source, required this.advertisingServices});

  @override
  Future<bool> showRewardedAd() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        return advertisingServices.showAd();
      } catch (e) {
        throw ReactionException(message: "FAILED");
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  Map<String, dynamic> getAdditionalData() {
    return {
      "coins": coins,
      "reactionAverage": reactionAverage,
      "reactionCount": reactionCount,
      "totalReactionPoints": totalReactionPoints,
    };
  }

  Map<String, dynamic> reactionModelToMap(Map<String, dynamic> reactionModel) {
    return {}; /* {
      "userBlocked": reactionModel.userBlocked,
      "senderId": reactionModel.senderId,
      "recieverId": reactionModel.recieverId,
      "reactionId": reactionModel.reactionId,
      "expirationTimestamp": reactionModel.expirationTimestamp,
      "reactionType": reactionModel.reactionType,
      "userPicture": reactionModel.userPicture,
      "senderName": reactionModel.senderName,
      "reactionRevealed": reactionModel.reactionRevealed,
      "reactionValue":reactionModel.reactionValue
    };*/
  }

  void _addReaction({required Map<String, dynamic> element}) {
    if (reactionListener != null) {
      reactionListener?.add({
        "payloadType": "reaction",
        "modified": false,
        "reaction": element,
        "deleted": false,
        "notify": true
      });
    } else {
      throw Exception("REACTION_LISTENER_CANNOT_BE_NULL");
    }
  }

  void _modifyReaction({required Map<String, dynamic> element}) {
    if (reactionListener != null) {
      reactionListener?.add({
        "payloadType": "reaction",
        "modified": true,
        "reaction": element,
        "deleted": false,
        "notify": false
      });
    } else {
      throw Exception("REACTION_LISTENER_CANNOT_BE_NULL");
    }
  }

  void _deleteReaction({required Map<String, dynamic> element}) {
    if (reactionListener != null) {
      reactionListener?.add({
        "payloadType": "reaction",
        "modified": true,
        "reaction": element,
        "deleted": true,
        "notify": false
      });
    } else {
      throw Exception(kStreamParserNullError);
    }
  }

  void _sendAdditionalData() {
    if (reactionListener != null) {
      reactionListener!.add({
        "payloadType": "additionalData",
        "reactionAverage": reactionAverage,
        "reactionCount": reactionCount,
        "totalReactionPoints": totalReactionPoints,
        "coins": coins,
        "isPremium": isPremium
      });
    } else {
      throw Exception(kStreamParserNullError);
    }
  }

  void _addErrorReaction({required dynamic e}) {
    if (reactionListener != null) {
      reactionListener!.addError(Exception(e));
    } else {
      throw Exception(kStreamParserNullError);
    }
  }

  Future<void> getReactions() async {
    Databases databases = Dependencies.serverAPi.databases;

    DocumentList documentList = await databases.listDocuments(
        databaseId: kDatabaseId,
        collectionId: kReactionsCollection,
        queries: [
          Query.equal("recieverId", GlobalDataContainer.userId),
          Query.orderAsc("timestamp")
        ]);

    documentList.documents.forEach((element) {
      _addReaction(element: element.data);
    });
  }

  void initializeReactionListener() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        await getReactions();
        Realtime realtime = Realtime(Dependencies.serverAPi.client);

        reactionSubscriptionListener = realtime
            .subscribe([
              "databases.${kDatabaseId}.collections.${kReactionsCollection}.documents"
            ])
            .stream
            .listen((event) {
              String updateEvent =
                  "databases.${kDatabaseId}.collections.${kReactionsCollection}.documents.*.update";
              String createEvent =
                  "databases.${kDatabaseId}.collections.${kReactionsCollection}.documents.*.create";
              String deleteEvent =
                  "databases.${kDatabaseId}.collections.${kReactionsCollection}.documents.*.delete";
              log(event.events.toString());
              if (event.events.contains(updateEvent)) {
                _modifyReaction(element: event.payload);
              } else if (event.events.contains(createEvent)) {
                _addReaction(element: event.payload);
              } else if (event.events.contains(deleteEvent)) {
                _deleteReaction(element: event.payload);
              }
            });
      } catch (e) {
        throw ReactionException(
          message: e.toString(),
        );
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void subscribeToMainDataSource() async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      sourceStreamSubscription = source.dataStream?.stream.listen((event) {
        coins = event["userCoins"];
        isPremium = event["isUserPremium"];
        reactionAverage = event["reactionAveragePoints"];

        _sendAdditionalData();
      });
      userID = source.getData["userId"];
      isPremium = source.getData["isUserPremium"];
      reactionAverage = source.getData["reactionAveragePoints"];

      coins = source.getData["userCoins"];
      _sendAdditionalData();

      initializeReactionListener();
    } catch (e) {
      _addErrorReaction(e: e);
    }
  }

  @override
  Future<void> revealReaction(String reactionId, bool showAd) async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution = await Dependencies.serverAPi.functions
            .createExecution(
                functionId: "revealReaction",
                body: jsonEncode({
                  "reactionId": reactionId,
                  "userId": GlobalDataContainer.userId,
                  "showAd": showAd
                }));

        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];
        String details = jsonDecode(execution.responseBody)["details"];
        if (status == 200 && message == "REQUEST_SUCESSFULL") {
          return;
        } else if (status == 200 && message == "CREDITS_LOW") {
          throw Exception(message);
        }
      } catch (e) {
        throw ReactionException(
          message: e.toString(),
        );
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> acceptReaction(
      {required String reactionId, required String reactionSenderId}) async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution =
            await Dependencies.serverAPi.functions.createExecution(
                functionId: "acceptReaction",
                body: jsonEncode({
                  "reactionId": reactionId,
                }));

        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];

        if (status == 200) {
          return true;
        } else {
          throw ReactionException(message: message);
        }
      } catch (e) {
        throw ReactionException(
          message: e.toString(),
        );
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> rejectReaction({required List<String> reactionId}) async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution = await Dependencies.serverAPi.functions
            .createExecution(
                functionId: "deleteReaction",
                body:
                    jsonEncode({"reactionIds": reactionId, "userId": userID}));

        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];

        if (status == 200) {
          return true;
        } else {
          throw ReactionException(message: message);
        }
      } catch (e) {
        throw ReactionException(
          message: e.toString(),
        );
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
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
  void clearModuleData() {
    try {
      reactionListener?.close();
      reactionListener = null;
      sourceStreamSubscription?.cancel();
      reactionSubscriptionListener?.cancel();
      coins = 0;
      aditionalData = new Map();
      totalReactionPoints = 0;
      reactionAverage = 0;
      reactionCount = 0;
      userID = kNotAvailable;
      reactionListener = new StreamController.broadcast();
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  void closeAdsStreams() {
    advertisingServices.closeStream();
  }
}
