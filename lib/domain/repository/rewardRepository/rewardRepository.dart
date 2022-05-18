import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/rewardsDataSource/rewardDataSource.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';
import 'package:dartz/dartz.dart';

import '../DataManager.dart';

abstract class RewardRepository  implements ModuleCleaner{
  late RewardDataSource rewardDataSource;

   StreamController<Rewards> get getRewardsStream;

   Future<Either<Failure,bool>> getDailyReward();

}