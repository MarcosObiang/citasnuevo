import 'dart:async';
import 'dart:ffi';

import 'package:dartz/dartz.dart';

import '../DataManager.dart';
import '../../core/error/Exceptions.dart';
import '../../core/error/Failure.dart';
import 'ReactionEntity.dart';
import 'ReactionsMappers.dart';
import 'reactionDataSource.dart';
import 'reactionRepository.dart';

class ReactionRepositoryImpl
    implements ReactionRepository, ModuleCleanerDataSource {
  @override
  ReactionDataSource reactionDataSource;
  ReactionRepositoryImpl({
    required this.reactionDataSource,
  });

  @override
  StreamController? streamParserController = StreamController();

  @override
  StreamSubscription? streamParserSubscription;

  @override
  StreamController? get getStreamParserController =>
      this.streamParserController;


  @override
  StreamController<Map<String, dynamic>> get rewardedStatusListener =>
      reactionDataSource.rewadedAdvertismentStatusListener;
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
      await reactionDataSource.rejectReaction(reactionId: [reactionId]);
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
  Either<Failure, bool> initializeModuleData() {
    try {
      parseStreams();
      reactionDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      streamParserController?.close();
      streamParserSubscription?.cancel();
      streamParserController = null;
      streamParserSubscription = null;
      streamParserController = new StreamController();
      reactionDataSource.clearModuleData();

      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  void parseStreams() {
    if (reactionDataSource.reactionListener != null &&
        this.streamParserController != null) {
      streamParserSubscription =
          reactionDataSource.reactionListener!.stream.listen((event) {
        String payloadType = event["payloadType"];
        if (payloadType == "reaction") {
          bool isModified = event["modified"];
          bool deleted = event["deleted"];
          bool notify = event["notify"];
          Map<dynamic, dynamic> reactionData = event["reaction"];

          Reaction reaction = ReactionMapper.fromMap(reactionData);
          this.streamParserController!.add({
            "payloadType": payloadType,
            "modified": isModified,
            "reaction": reaction,
            "deleted": deleted,
            "notify": notify
          });
        } else {
          double? reactionsAverage = event["reactionsAverage"];
          int? coins = event["coins"];
          bool? isPremium = event["isPremium"];
          this.streamParserController!.add({
            "payloadType": "additionalData",
            "reactionsAverage": reactionsAverage,
            "coins": coins,
            "isPremium": isPremium
          });
        }
      }, onError: (error) {
        this.streamParserController!.addError(error);
      });
    }
  }



  @override
  Future<Either<Failure, bool>> showRewarded() async {
    try {
      await reactionDataSource.showRewardedAd();
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
  void closeAdsStreams() {
    reactionDataSource.closeAdsStreams();
  }
}
