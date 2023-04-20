import 'dart:async';

import 'package:dartz/dartz.dart';

import '../DataManager.dart';
import '../../core/error/Failure.dart';
import '../../core/streamParser/streamPareser.dart';
import 'rewardDataSource.dart';

abstract class RewardRepository
    implements ModuleCleanerRepository, StreamParser {
  late RewardDataSource rewardDataSource;

  Future<Either<Failure, bool>> getDailyReward();
  Future<Either<Failure, bool>> getFirstReward();
  Future<Either<Failure, bool>> getSharingLink();
  Future<Either<Failure, bool>> usePromotionalCode();
  Future<Either<Failure, bool>> rewardTicketSuccesfulShares();
}
