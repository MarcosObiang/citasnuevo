import 'dart:async';

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
  Future<Either<Failure, bool>> getDailyReward() {
    // TODO: implement getDailyReward
    throw UnimplementedError();
  }

  @override
  // TODO: implement getRewardsStream
  StreamController<Rewards> get getRewardsStream =>
      rewardDataSource.rewardStream;

  @override
  void initializeModuleData() {
    rewardDataSource.initializeModuleData();
  }
}
