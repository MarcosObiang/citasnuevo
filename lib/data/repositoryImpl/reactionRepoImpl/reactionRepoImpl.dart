import 'dart:async';
import 'dart:ffi';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/data/Mappers/ReactionsMappers.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/reactionDataSources/reactionDataSource.dart';
import 'package:citasnuevo/domain/repository/reactionRepository/reactionRepository.dart';

import '../../../domain/entities/ReactionEntity.dart';
import '../../../domain/repository/DataManager.dart';

class ReactionRepositoryImpl implements ReactionRepository,ModuleCleanerDataSource  {
  @override
  ReactionDataSource reactionDataSource;
  ReactionRepositoryImpl({
    required this.reactionDataSource,
  });
  @override
  StreamController<Map> get additionalDataStream =>
      this.reactionDataSource.additionalDataSender;
  @override
  StreamController<Map<String, dynamic>> get reactionListener =>
      this.reactionDataSource.reactionListener;

  Either<Failure, Map> getAdditionalValues() {
    return Right(reactionDataSource.getAdditionalData());
  }

  @override
  Future<Either<Failure, void>> revealReaction(
      {required String reactionId}) async {
    try {
      await reactionDataSource.revealReaction(reactionId);
      return Right(Void);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else if (e is ReactionException) {
        return Left(ReactionFailure(message: e.toString()));
      } else {
        return Left(GenericModuleFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> acceptReaction(
      {required String reactionId, required String reactionSenderId}) async {
    try {
      await reactionDataSource.acceptReaction(
          reactionId: reactionId, reactionSenderId: reactionSenderId);
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else if (e is ReactionException) {
        return Left(ReactionFailure(message: e.toString()));
      } else {
        return Left(GenericModuleFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> rejectReaction(
      {required String reactionId}) async {
    try {
      await reactionDataSource.rejectReaction(reactionId: reactionId);
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else if (e is ReactionException) {
        return Left(ReactionFailure(message: e.toString()));
      } else {
        return Left(GenericModuleFailure(message: e.toString()));
      }
    }
  }

  @override
  Either<Failure, bool> clearData() {
    try {
      reactionDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      return Left(ChatFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      reactionDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      reactionDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

 

  @override
  Stream reactionStream() async* {

    await for (final event in reactionDataSource.reactionListener.stream) {
      try{
   if (event is Exception) {
        yield event;
      } else {
        bool isModified = event["modified"];
        bool deleted = event["deleted"];
        bool notify = event["notify"];
        Map<dynamic, dynamic> reactionData = event["reaction"];

        Reaction reaction = ReactionMapper.fromMap(reactionData);

      yield  {
      "modified": isModified,
      "reaction": reaction,
      "deleted": deleted,
      "notify": notify
    };
      }
      }catch(e){
yield e;
      }
   
    }
  }
}
