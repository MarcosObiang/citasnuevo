import 'dart:async';

import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/RewardMapper.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';

import '../../../core/dependencies/error/Failure.dart';

abstract class RewardDataSource implements DataSource {
  // ignore: close_sinks
  late StreamController<Rewards> rewardStream;

  /// Used for get a link so the user can share it and get rewarded with coins
  Future<Either<Failure, String>> getDynamicLink();

  /// Used to claim a daily reward after spending all of the coins 24 h before
  Future<Either<Failure, bool>> getDailyReward();

  ///Use to get real time updates from the data source
  ///

}

class RewardDataSourceImpl implements RewardDataSource {
  @override
  ApplicationDataSource source;
  RewardDataSourceImpl({
    required this.source,
  });

  @override
  Future<Either<Failure, bool>> getDailyReward() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> getDynamicLink() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Rewards>> getRewardObject() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      Map dataSource = source.getData;
      try {
        Rewards rewards = new Rewards(
      isPremium: dataSource["monedasInfinitas"],
            timeUntilDailyReward: dataSource["siguienteRecompensa"],
            waitingFirstReward: dataSource["primeraRecompensa"],
            rewardForShareRigth: false,
            rewardForVerificationRigth: false,
            waitingReward: dataSource["esperandoRecompensa"]);
        return Right(rewards);
      } catch (e) {
        return Left(RewardFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> getVerificationReward() {
    throw UnimplementedError();
  }

  @override
  void subscribeToMainDataSource() {
    rewardStream.add(RewardMapper.instance.fromMap(data: source.getData));

    sourceStreamSubscription = source.dataStream.stream.listen((event) {
      rewardStream.add(RewardMapper.instance.fromMap(data: event));
    });
  }

  @override
  bool clearModuleData() {
    rewardStream.close();
    sourceStreamSubscription.cancel();
    return true;
  }

  @override
  void initializeModuleData() {
    rewardStream = new StreamController.broadcast();
    subscribeToMainDataSource();
  }

  @override
  late StreamSubscription sourceStreamSubscription;

  @override
  late StreamController<Rewards> rewardStream;
}
