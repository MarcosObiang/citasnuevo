import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';

import 'package:citasnuevo/data/Mappers/ReactionsMappers.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/globalData.dart';
import '../../../domain/repository/DataManager.dart';

abstract class ReactionDataSource
    implements DataSource, ModuleCleanerDataSource {
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
      new StreamController.broadcast();

  @override
  StreamSubscription? sourceStreamSubscription;

  StreamSubscription<RealtimeMessage>? reactionSubscriptionListener;
  @override
  ApplicationDataSource source;
  String? userID = kNotAvailable;
  double? reactionsAverage = 0;
  int? coins = 0;
  Map? aditionalData = new Map();
  bool? isPremium = false;
  List<String> reactionsId = [];

  ReactionDataSourceImpl({
    required this.source,
  });

  Map<String, dynamic> getAdditionalData() {
    return {"coins": coins, "averageReactions": reactionsAverage};
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
        "reactionsAverage": reactionsAverage,
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
    Databases databases = Databases(Dependencies.serverAPi.client!);
    DateTime dateTime = await DateNTP.instance.getTime();
    List<String> expiredReactions = [];

    var documents = await databases.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374fe10e76d07bfe639");

    documents.documents.forEach((element) {
      if (dateTime.millisecondsSinceEpoch <
          element.data["expirationTimestamp"]) {
        _addReaction(element: element.data);
      } else {
        expiredReactions.add(element.$id);
      }
    });

    await this.rejectReaction(reactionId: expiredReactions);
  }

  void initializeReactionListener() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        await getReactions();

        String reactionDataabseReference =
            "databases.636d59d7a2f595323a79.collections.6374fe10e76d07bfe639.documents";

        Realtime realtime = new Realtime(Dependencies.serverAPi.client!);

        reactionSubscriptionListener = realtime
            .subscribe([reactionDataabseReference])
            .stream
            .listen((dato) async {
              try {
                DateTime dateTime = await DateNTP.instance.getTime();
                int queryTime = dateTime.millisecondsSinceEpoch;
                int caducidadValoracion = dato.payload["expirationTimestamp"];
                String createEvent =
                    "databases.636d59d7a2f595323a79.collections.6374fe10e76d07bfe639.documents.${dato.payload["reactionId"]}.create";
                String updateEvent =
                    "databases.636d59d7a2f595323a79.collections.6374fe10e76d07bfe639.documents.${dato.payload["reactionId"]}.update";
                String deleteEvent =
                    "databases.636d59d7a2f595323a79.collections.6374fe10e76d07bfe639.documents.${dato.payload["reactionId"]}.delete";
                if (caducidadValoracion > queryTime) {
                  if (dato.events.first.contains(createEvent)) {
                    _addReaction(element: dato.payload);
                  }
                  if (dato.events.first.contains(updateEvent)) {
                    _modifyReaction(element: dato.payload);
                  }
                }

                if (dato.events.contains(deleteEvent)) {
                  _deleteReaction(element: dato.payload);
                }
              } catch (e) {
                if (e is AppwriteException) {
                  _addErrorReaction(e: e);
                } else {
                  _addErrorReaction(e: e);
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
    }
  }

  @override
  void subscribeToMainDataSource() async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      sourceStreamSubscription = source.dataStream.stream.listen((event) {
        reactionsAverage = double.parse(event["averageRating"].toString());
        if (reactionsAverage != null) {
          reactionsAverage =
              double.parse(reactionsAverage!.toStringAsFixed(1)) * 10;
        }
        coins = event["userCoins"];
        isPremium = event["isUserPremium"];

        _sendAdditionalData();
      });
      userID = source.getData["userId"];
      isPremium = source.getData["isUserPremium"];
      reactionsAverage =
          double.parse(source.getData["averageRating"].toString());
      if (reactionsAverage != null) {
        reactionsAverage =
            double.parse(reactionsAverage!.toStringAsFixed(1)) * 10;
      }
      coins = source.getData["userCoins"];
      _sendAdditionalData();

      initializeReactionListener();
    } catch (e) {
      _addErrorReaction(e: e);
    }
  }

  @override
  Future<void> revealReaction(String reactionId) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);

        Execution execution = await functions.createExecution(
            functionId: "revealreaction",
            data: jsonEncode({
              "reactionId": reactionId,
              "userId": GlobalDataContainer.userId
            }));
        HttpsCallable callToRevealReactionFunction =
            FirebaseFunctions.instance.httpsCallable("quitarCreditosUsuario");

        HttpsCallableResult result = await callToRevealReactionFunction.call({
          "idValoracion": reactionId,
          "idUsuario": userID,
          "primeraSolicitud": false
        });

        if (execution.statusCode != 200) {
          throw Exception(["FAILED"]);
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
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
            functionId: "acceptReaction",
            data: jsonEncode({"reactionId": reactionId}));
        if (execution.statusCode == 200) {
          return true;
        } else {
          throw ReactionException(message: "NOT_ALLOWED");
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
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
            functionId: "deleteReaction",
            data: jsonEncode({"reactionIds": reactionId}));
        if (execution.statusCode == 200) {
          return true;
        } else {
          throw Exception("error_deleting_reaction");
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
      reactionsAverage = 0;
      userID = kNotAvailable;
      reactionListener = new StreamController.broadcast();
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }
}
