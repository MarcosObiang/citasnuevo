import 'dart:async';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/core/streamParser/streamPareser.dart';
import 'package:citasnuevo/data/dataSources/rewardsDataSource/rewardDataSource.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';
import 'package:dartz/dartz.dart';

import '../DataManager.dart';

abstract class RewardRepository  implements ModuleCleanerRepository,StreamParser{
  late RewardDataSource rewardDataSource;


   Future<Either<Failure,bool>> getDailyReward();
   Future<Either<Failure,bool>> getFirstReward();
   Future<Either<Failure,String>>getSharingLink();

}