import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/rewardsDataSource/rewardDataSource.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';
import 'package:citasnuevo/domain/repository/rewardRepository/rewardRepository.dart';

class RewardRepoImpl implements RewardRepository {
  @override
  RewardDataSource rewardDataSource;
  RewardRepoImpl({
    required this.rewardDataSource,
  });

  @override
  void clearModuleData() {
    rewardDataSource.clearModuleData();
  }

  @override
  Future<Either<Failure, bool>> getDailyReward() async {
    try {
      await rewardDataSource.getDailyReward();
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(RewardFailure());
      }
    }
  }

  @override
  StreamController<Rewards> get getRewardsStream =>
      rewardDataSource.rewardStream;

  @override
  void initializeModuleData() {
    rewardDataSource.initializeModuleData();
  }
  
  @override
  Future<Either<Failure, bool>> getFirstReward()async {
  try {
      await rewardDataSource.getFrstReward();
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(RewardFailure());
      }
    }
  }
}
