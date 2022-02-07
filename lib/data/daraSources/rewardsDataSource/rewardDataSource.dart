import 'package:dartz/dartz.dart';

import 'package:citasnuevo/data/daraSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';

import '../../../core/dependencies/error/Failure.dart';

abstract class RewardDataSource implements DataSource {
  /// Called first to create the [Rewards] object an initialize the object data
  Future<Either<Failure, Rewards>> getRewardObject();

  /// Used for get a link so the user can share it and get rewarded with coins
  Future<Either<Failure, bool>> getDynamicLink();

  /// Used to claim a daily reward after spending all of the coins 24 h before
  Future<Either<Failure, bool>> getDailyReward();

  ///Used to get the verification reward after the ferivication process is succesful
  Future<Either<Failure, bool>> getVerificationReward();

  /// Used to get the shared link reward after the link is shared
  Future<Either<Failure, bool>> getLinkSharedReward();
}

class RewardDataSourceImpl implements RewardDataSource {
  @override
  ApplicationDataSource source;
  RewardDataSourceImpl({
    required this.source,
  });

  @override
  Future<Either<Failure, bool>> getDailyReward() {
    // TODO: implement getDailyReward
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> getDynamicLink() {
    // TODO: implement getDynamicLink
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> getLinkSharedReward() {
    // TODO: implement getLinkSharedReward
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Rewards>> getRewardObject() {
    // TODO: implement getRewardObject
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> getVerificationReward() {
    // TODO: implement getVerificationReward
    throw UnimplementedError();
  }

  @override
  void subscribeToMainDataSource() {
    // TODO: implement subscribeToMainDataSource
  }
}
