import 'dart:async';
import 'dart:convert';

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

  Future<void> revealReaction(String reactionId);

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
    return {};/* {
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

   /* var documents = realm!.query<ReactionModel>(
        r'recieverId == $0 AND isDeleted == $1', ["$userID", false]).toList();


    documents.forEach((element) {
        _addReaction(element: reactionModelToMap(element));
     
    });*/
   
  }

  void initializeReactionListener() async {
   /* if (await Dependencies.networkInfoContract.isConnected) {
      try {
        await getReactions();

        var realm = source.realm!;
        realm
            .query<ReactionModel>("recieverId == '$userID'")
            .changes
            .listen((RealmResultsChanges<ReactionModel> event) {
          if (event.inserted.isNotEmpty) {
            for (int i = 0; i < event.inserted.length; i++) {
              if (event.results[event.inserted[i]].isDeleted == false) {
                _addReaction(
                    element:
                        reactionModelToMap(event.results[event.inserted[i]]));
              }
            }
          }
          if (event.modified.isNotEmpty) {
            for (int i = 0; i < event.modified.length; i++) {
              if (event.results[event.modified[i]].isDeleted == true) {
                _deleteReaction(
                    element:
                        reactionModelToMap(event.results[event.modified[i]]));
              } else {
                _modifyReaction(
                    element:
                        reactionModelToMap(event.results[event.modified[i]]));
              }
            }
          }

          if (event.newModified.isNotEmpty) {
            for (int i = 0; i < event.modified.length; i++) {
              if (event.results[event.modified[i]].isDeleted == true) {
                _deleteReaction(
                    element:
                        reactionModelToMap(event.results[event.modified[i]]));
              } else {
                _modifyReaction(
                    element:
                        reactionModelToMap(event.results[event.modified[i]]));
              }
            }
          }
        });
      } catch (e) {
        throw ReactionException(
          message: e.toString(),
        );
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/
  }

  @override
  void subscribeToMainDataSource() async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      sourceStreamSubscription = source.dataStream?.stream.listen((event) {
        coins = event["userCoins"];
        isPremium = event["isUserPremium"];
        reactionAverage = event["reactionAveracePoints"];

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
  Future<void> revealReaction(String reactionId) async {
   /* if (await Dependencies.networkInfoContract.isConnected) {
      try {
        final response = await Dependencies
            .serverAPi.app!.currentUser!.functions
            .call("revealReactions", [
          jsonEncode(
              {"reactionId": reactionId, "userId": GlobalDataContainer.userId})
        ]);

        int status = jsonDecode(response)["executionCode"];
        if (status != 200) {
          throw Exception(["FAILED"]);
        }
      } catch (e) {
        throw ReactionException(
          message: e.toString(),
        );
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/
  }

  @override
  Future<bool> acceptReaction(
      {required String reactionId, required String reactionSenderId}) async {
 /*   if (await Dependencies.networkInfoContract.isConnected) {
      try {
        final response = await Dependencies
            .serverAPi.app!.currentUser!.functions
            .call("acceptReaction", [
          jsonEncode({
            "reactionId": reactionId,
          })
        ]);
        int status = jsonDecode(response)["executionCode"];

        if (status == 200) {
          return true;
        } else {
          throw ReactionException(message: "");
        }
      } catch (e) {
        throw ReactionException(
          message: e.toString(),
        );
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/ return true;
  }

  @override
  Future<bool> rejectReaction({required List<String> reactionId}) async {
  /*  if (await Dependencies.networkInfoContract.isConnected) {
      try {
        final response = await Dependencies
            .serverAPi.app!.currentUser!.functions
            .call("rejectReaction", [
          jsonEncode({"reactionIds": reactionId})
        ]);
        int status = jsonDecode(response)["executionCode"];

        if (status == 200) {
          return true;
        } else {
          throw ReactionException(message: "");
        }
      } catch (e) {
        throw ReactionException(
          message: e.toString(),
        );
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/ return true;
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
