import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/reactionDataSources/reactionDataSource.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';

abstract class ReactionRepository implements ModuleCleaner {
  late ReactionDataSource reactionDataSource;

  ///Data such as gems and the average reaction on the user`s profile are streamed here
  StreamController<Map> get additionalDataStream;

  ///Reactions are streamed here
  StreamController<Map<String, dynamic>> get reactionListener;

  

  ///Get first addidional values (gems and reaction average)
  Either<Failure, Map> getAdditionalValues();

  Future<Either<Failure, void>> revealReaction({required String reactionId});

  Future<Either<Failure,bool>>acceptReaction({required String reactionId,required String reactionSenderId,});

  Future<Either<Failure,bool>> rejectReaction({required String reactionId});


    Either<Failure,bool> clearData();

}
