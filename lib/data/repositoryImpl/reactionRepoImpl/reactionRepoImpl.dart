import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/daraSources/reactionDataSources/reactionDataSource.dart';
import 'package:citasnuevo/domain/repository/reactionRepository/reactionRepository.dart';

class ReactionRepositoryImpl implements ReactionRepository {
  @override
  ReactionDataSource reactionDataSource;
  ReactionRepositoryImpl({
    required this.reactionDataSource,
  });
  @override
  StreamController<Map> get additionalDataStream =>
      this.reactionDataSource.additionalDataSender;
  @override
  StreamController<Map<String,dynamic>> get reactionListener =>
      this.reactionDataSource.reactionListener;

  Either<Failure, Map> getAdditionalValues() {
    return Right(reactionDataSource.getAdditionalData());
  }

  @override
  Either<Failure, bool> initializeReactionListener() {
    try {
      reactionDataSource.initializeReactionListener();
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(ReactionFailure());
      }
    }
  }
}
