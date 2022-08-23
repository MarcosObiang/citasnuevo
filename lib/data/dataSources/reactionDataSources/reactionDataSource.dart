import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';

import 'package:citasnuevo/data/Mappers/ReactionsMappers.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

abstract class ReactionDataSource implements DataSource {
// ignore: close_sinks
  late StreamController<Map<String, dynamic>> reactionListener;
  // ignore: close_sinks
  late StreamController<Map<dynamic, dynamic>> additionalDataSender;

  Future<void> revealReaction(String reactionId);

  Future<bool> acceptReaction({
    required String reactionId,
    required String reactionSenderId,
  });

  Future<bool> rejectReaction({required String reactionId});
  Map<String, dynamic> getAdditionalData();
}

class ReactionDataSourceImpl implements ReactionDataSource {
  @override
  StreamController<Map<String, dynamic>> reactionListener =
      new StreamController.broadcast();
  @override
  StreamController<Map<dynamic, dynamic>> additionalDataSender =
      new StreamController.broadcast();

  @override
  StreamSubscription? sourceStreamSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      reactionSubscriptionListener;
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

  void _addReaction({required DocumentChange<Map<String, dynamic>> element}) {
    Reaction reaction =
        ReactionConverter.fromMap(element.doc.data() as Map<String, dynamic>);

    reactionListener.add({
      "modified": false,
      "reaction": reaction,
      "deleted": false,
      "notify": element.doc.metadata.isFromCache == true ? false : true
    });
  }

  void _modifyReaction(
      {required DocumentChange<Map<String, dynamic>> element}) {
    Reaction reaction =
        ReactionConverter.fromMap(element.doc.data() as Map<String, dynamic>);
    reactionListener.add({
      "modified": true,
      "reaction": reaction,
      "deleted": false,
      "notify": false
    });
  }

  void _deleteReaction(
      {required DocumentChange<Map<String, dynamic>> element}) {
    Reaction reaction =
        ReactionConverter.fromMap(element.doc.data() as Map<String, dynamic>);
    reactionListener.add({
      "modified": true,
      "reaction": reaction,
      "deleted": true,
      "notify": false
    });
  }

  void initializeReactionListener() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        FirebaseFirestore instance = FirebaseFirestore.instance;

        reactionSubscriptionListener = instance
            .collection("valoraciones")
            .where("idDestino", isEqualTo: userID)
            .snapshots()
            .listen((dato) {
          dato.docChanges.forEach((element) async {
            try {
              DateTime dateTime = await DateNTP.instance.getTime();
              int queryTime = dateTime.millisecondsSinceEpoch ~/ 1000;
              int caducidadValoracion = element.doc.get("caducidad");

              if (caducidadValoracion > queryTime) {
                if (element.type == DocumentChangeType.added) {
                  _addReaction(element: element);
                }
                if (element.type == DocumentChangeType.modified) {
                  _modifyReaction(element: element);
                }
              }

              if (element.type == DocumentChangeType.removed) {
                _deleteReaction(element: element);
              }
            } catch (e, s) {
              reactionListener.addError(Exception());

              throw ReactionException(message: e.toString(), stackTrace: s);
            }
          });
        });
      } catch (e, s) {
        throw ReactionException(message: e.toString(), stackTrace: s);
      }
    } else {
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }

  @override
  void subscribeToMainDataSource() async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      sourceStreamSubscription = source.dataStream.stream.listen((event) {
        reactionsAverage = double.parse(event["mediaTotal"].toString());
        if (reactionsAverage != null) {
          reactionsAverage =
              double.parse(reactionsAverage!.toStringAsFixed(1)) * 10;
        }
        coins = event["creditos"];
        isPremium = event["monedasInfinitas"];

        additionalDataSender.add({
          "reactionsAverage": reactionsAverage,
          "coins": coins,
          "isPremium": isPremium
        });
      });
      userID = source.getData["id"];
      isPremium = source.getData["monedasInfinitas"];
      reactionsAverage = double.parse(source.getData["mediaTotal"].toString());
      if (reactionsAverage != null) {
        reactionsAverage =
            double.parse(reactionsAverage!.toStringAsFixed(1)) * 10;
      }
      coins = source.getData["creditos"];
      additionalDataSender.add({
        "reactionsAverage": reactionsAverage,
        "coins": coins,
        "isPremium": isPremium
      });

      initializeReactionListener();
    } catch (e) {
      additionalDataSender.addError(e);
    }
  }

  @override
  Future<void> revealReaction(String reactionId) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable callToRevealReactionFunction =
            FirebaseFunctions.instance.httpsCallable("quitarCreditosUsuario");

        HttpsCallableResult result = await callToRevealReactionFunction.call({
          "idValoracion": reactionId,
          "idUsuario": userID,
          "primeraSolicitud": false
        });
        if (result.data["estado"] == "correcto") {}

        if (result.data["estado"] != "correcto") {
          throw Exception(["FAILED"]);
        }
      } catch (e, S) {
        throw ReactionException(message: e.toString(), stackTrace: S);
      }
    } else {
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }

  @override
  Future<bool> acceptReaction(
      {required String reactionId, required String reactionSenderId}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable callToAcceptReactionFunction =
            FirebaseFunctions.instance.httpsCallable("crearConversaciones");
        HttpsCallableResult httpsCallableResult =
            await callToAcceptReactionFunction.call({
          "idEmisor": userID,
          "idValoracion": reactionId,
          "idDestino": reactionSenderId
        });

        if (httpsCallableResult.data["estado"] == "correcto") {
          return true;
        } else {
          throw Exception(["NOT_ALLOWED"]);
        }
      } catch (e, s) {
        throw ReactionException(message: e.toString(), stackTrace: s);
      }
    } else {
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }

  @override
  Future<bool> rejectReaction({required String reactionId}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        FirebaseFirestore instance = FirebaseFirestore.instance;
        await instance.collection("valoraciones").doc(reactionId).delete();
        return true;
      } catch (e, s) {
        throw ReactionException(message: e.toString(), stackTrace: s);
      }
    } else {
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }

  @override
  void initializeModuleData() {
    subscribeToMainDataSource();
  }

  @override
  void clearModuleData() {
    reactionListener.close();
    additionalDataSender.close();
    sourceStreamSubscription?.cancel();
    reactionSubscriptionListener?.cancel();
    coins = 0;
    aditionalData = new Map();
    reactionsAverage = 0;
    userID = kNotAvailable;
    reactionListener = new StreamController.broadcast();

    additionalDataSender = new StreamController.broadcast();
  }
}
