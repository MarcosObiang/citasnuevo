import 'dart:async';

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';

import 'package:citasnuevo/data/Mappers/ReactionsMappers.dart';
import 'package:citasnuevo/data/daraSources/principalDataSource/principalDataSource.dart';
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
  void initializeReactionListener();
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
  @override
  ApplicationDataSource source;
  late String userID;
  late double reactionsAverage;
  late int coins;
  late Map aditionalData;

  ReactionDataSourceImpl({
    required this.source,
  }) {
    subscribeToMainDataSource();
  }

  Map<String, dynamic> getAdditionalData() {
    return {"coins": coins, "averageReactions": reactionsAverage};
  }

  @override
  void initializeReactionListener() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        FirebaseFirestore instance = FirebaseFirestore.instance;
        int queryDate =
            DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch ~/
                1000;
        instance
            .collection("valoraciones")
            .where("Time", isGreaterThanOrEqualTo: queryDate)
            .where("idDestino", isEqualTo: userID)
            .snapshots()
            .listen((dato) {
          dato.docChanges.forEach((element) {
            if (element.type == DocumentChangeType.added) {
              Reaction reaction = ReactionConverter.fromMap(
                  element.doc.data() as Map<String, dynamic>);

              reactionListener.add({
                "modified": false,
                "reaction": reaction,
                "dataLength": dato.docChanges.length
              });
            }
            if (element.type == DocumentChangeType.modified) {
              Reaction reaction = ReactionConverter.fromMap(
                  element.doc.data() as Map<String, dynamic>);
              reactionListener.add({
                "modified": true,
                "reaction": reaction,
                "dataLength": dato.docChanges.length
              });
            }
          });
        });
      } catch (e, s) {
        throw ReactionException(message: e.toString(), stackTrace: s);
      }
    } else {
      throw NetworkException();
    }
  }

  @override
  void subscribeToMainDataSource() {
    userID = source.getData["id"];
    reactionsAverage = double.parse(source.getData["mediaTotal"].toString());
    coins = source.getData["creditos"];
    additionalDataSender
        .add({"reactionsAverage": reactionsAverage, "coins": coins});
    source.dataStream.stream.listen((event) {
      reactionsAverage = double.parse(event["mediaTotal"].toString());
      coins = source.getData["creditos"];

      additionalDataSender
          .add({"reactionsAverage": reactionsAverage, "coins": coins});
    });
  }

  void closeReactionListener() {
    if (reactionListener.isClosed == false) {
      reactionListener.close();
      additionalDataSender.close();
    }
  }

  @override
  Future<void> revealReaction(String reactionId) async {
    late StreamSubscription<bool> adsStreamSubscription;

    int cero = 0;
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable callToRevealReactionFunction =
            FirebaseFunctions.instance.httpsCallable("quitarCreditosUsuario");

        await Dependencies.advertisingServices.showInterstitial();

        adsStreamSubscription = Dependencies
            .advertisingServices.advertismentStateStream.stream
            .listen((event) async {
          if (event) {
            cero += 1;
            print(cero);
            HttpsCallableResult result = await callToRevealReactionFunction
                .call({
              "idValoracion": reactionId,
              "idUsuario": userID,
              "primeraSolicitud": false
            });

            if (result.data["estado"] != "correcto") {
              adsStreamSubscription.cancel();

              throw Exception(["NOT_ALLOWED"]);
            }
            if (result.data["estado"] == "correcto") {
              adsStreamSubscription.cancel();
            }
          } else {
            adsStreamSubscription.cancel();

            throw Exception(["AD_INCOMPLETE"]);
          }
        });
      } catch (e, S) {
        adsStreamSubscription.cancel();

        throw ReactionException(message: e.toString(), stackTrace: S);
      }
    } else {
      throw NetworkException();
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

        if (httpsCallableResult.data["estado"] == "correcto" &&
            httpsCallableResult.data["mensaje"] == 0) {
          return true;
        } else {
          throw Exception(["NOT_ALLOWED"]);
        }
      } catch (e, s) {
        throw ReactionException(message: e.toString(), stackTrace: s);
      }
    } else {
      throw NetworkException();
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
      throw NetworkException();
    }
  }

  @override
  bool clearModuleData() {
    // TODO: implement clearModuleData
    throw UnimplementedError();
  }
}
