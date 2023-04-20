import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../core/error/Exceptions.dart';
import '../../core/error/Failure.dart';
import 'RewardMapper.dart';
import 'RewardsEntity.dart';
import 'rewardDataSource.dart';
import 'rewardRepository.dart';


class RewardRepoImpl implements RewardRepository {
  @override
  RewardDataSource rewardDataSource;
  RewardRepoImpl({
    required this.rewardDataSource,
  });

  @override
  StreamController? streamParserController = StreamController();

  @override
  StreamSubscription? streamParserSubscription;

  @override
  StreamController? get getStreamParserController =>
      this.streamParserController;

  @override
  Future<Either<Failure, bool>> getDailyReward() async {
    try {
      await rewardDataSource.getDailyReward();
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(RewardFailure(message: e.toString()));
      }
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      parseStreams();
      rewardDataSource.initializeModuleData();
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
      rewardDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> getFirstReward() async {
    try {
      await rewardDataSource.getFrstReward();
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(RewardFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> getSharingLink() async {
    try {
      var result = await rewardDataSource.getDynamicLink();
      return Right(result);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(RewardFailure(message: e.toString()));
      }
    }
  }

  @override
  void parseStreams() {
    if (this.streamParserController != null &&
        rewardDataSource.rewardStream != null) {
      this.streamParserSubscription =
          rewardDataSource.rewardStream!.stream.listen((event) {
        Rewards rewards = RewardMapper.instance.fromMap(data: event);

        streamParserController!
            .add({"payloadType": "rewards", "rewards": rewards});
      }, onError: (error) {
        streamParserController!.addError(error);
      });
    }
  }

  @override
  Future<Either<Failure, bool>> usePromotionalCode() async {
    try {
      await rewardDataSource.usePromotionalCode();
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(RewardFailure(message: e.toString()));
      }
    }
  }
  
  @override
  Future<Either<Failure, bool>> rewardTicketSuccesfulShares()async {
     try {
      await rewardDataSource.rewardTicketSuccesfulShares();
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(RewardFailure(message: e.toString()));
      }
    }
  }
}
