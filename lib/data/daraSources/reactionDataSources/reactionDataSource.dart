import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/ConverterDefinition.dart';
import 'package:citasnuevo/data/Mappers/ReactionsMappers.dart';
import 'package:citasnuevo/data/daraSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ReactionDataSource implements DataSource<Reaction> {
// ignore: close_sinks
  late StreamController<Map<String, dynamic>> reactionListener;
  // ignore: close_sinks
  late StreamController<Map<dynamic, dynamic>> additionalDataSender;
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
  DataSourceConverter<Reaction> dataConverter;

  @override
  ApplicationDataSource source;
  late String userID;
  late double reactionsAverage;
  late int coins;
  late Map aditionalData;

  ReactionDataSourceImpl({
    required this.dataConverter,
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
            .where("idDestino", isEqualTo: "VFXR80UHWMX2Qc1ZIelXZbVjlrD3")
            .snapshots()
            .listen((dato) {
          dato.docChanges.forEach((element) {
            if (element.type == DocumentChangeType.added) {
              Reaction reaction = this
                  .dataConverter
                  .fromMap(element.doc.data() as Map<String, dynamic>);

              reactionListener.add({"modified": false, "reaction": reaction});
            }
            if (element.type == DocumentChangeType.modified) {
              Reaction reaction = this
                  .dataConverter
                  .fromMap(element.doc.data() as Map<String, dynamic>);
              reactionListener.add({"modified": true, "reaction": reaction});
            }
          });
        });
      } catch (e) {
        throw ReactionException(message: e.toString());
      }
    } else {
      throw NetworkException();
    }
  }

  @override
  void subscribeToMainDataSource() {
    userID = source.getData["id"];
    reactionsAverage = source.getData["mediaTotal"];
    coins = source.getData["creditos"];
    additionalDataSender
        .add({"reactionsAverage": reactionsAverage, "coins": coins});
    source.dataStream.stream.listen((event) {
      reactionsAverage = event["mediaTotal"];
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
}
