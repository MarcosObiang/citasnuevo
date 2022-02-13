import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/daraSources/reactionDataSources/reactionDataSource.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:dartz/dartz.dart';

abstract class ReactionRepository {
  late ReactionDataSource reactionDataSource;

  ///Data such as gems and the average reaction on the user`s profile are streamed here
  StreamController<Map> get additionalDataStream;

  ///Reactions are streamed here
  StreamController<Map<String, dynamic>> get reactionListener;

  ///Initialize Reaction listener
  ///
  ///Returns [NetworkFailure] if there is a connection problem
  ///
  ///Returns [ReactionFailure] if any problem occurs
  Either<Failure, bool> initializeReactionListener();

  ///Get first addidional values (gems and reaction average)
  Either<Failure, Map> getAdditionalValues();
}
