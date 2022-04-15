import 'dart:async';

import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';

import '../../../core/dependencies/error/Failure.dart';

abstract class RewardDataSource implements DataSource {
  /// Called first to create the [Rewards] object and initialize it
  Future<Either<Failure, Rewards>> getRewardObject();

  /// Used for get a link so the user can share it and get rewarded with coins
  Future<Either<Failure, String>> getDynamicLink();

  /// Used to claim a daily reward after spending all of the coins 24 h before
  Future<Either<Failure, bool>> getDailyReward();

  ///Used to get the verification reward after the ferivication process is succesful
  Future<Either<Failure, bool>> getVerificationReward();

  /// Used to get the shared link reward after the link is shared
  Future<Either<Failure, bool>> getLinkSharedReward();

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
  Future<Either<Failure, bool>> getLinkSharedReward() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Rewards>> getRewardObject() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      Map dataSource = source.getData;
      try {
        Rewards rewards = new Rewards(
            timeUntilDailyReward: dataSource["siguienteRecompensa"],
            welcomeRewardRigth: dataSource["primeraRecompensa"],
            rewardForShareRigth: false,
            rewardForVerificationRigth: false,
            dailyRewardRigth: dataSource["esperandoRecompensa"]);
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
    source.dataStream.stream.listen((event) {});
  }

  @override
  late var dataConverter;

  @override
  bool clearModuleData() {
    // TODO: implement clearModuleData
    throw UnimplementedError();
  }

  @override
  void initializeModuleData() {
    // TODO: implement initializeModuleData
  }

  @override
 late StreamSubscription sourceStreamSubscription;
}
