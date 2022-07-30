import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/RewardMapper.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../core/dependencies/error/Failure.dart';

abstract class RewardDataSource implements DataSource {
  // ignore: close_sinks
  late StreamController<Rewards> rewardStream;

  /// Used for get a link so the user can share it and get rewarded with coins
  Future<String> getDynamicLink();

  /// Used to claim a daily reward after spending all of the coins 24 h before
  Future<bool> getDailyReward();

  Future<bool> getFrstReward();

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
  Future<bool> getDailyReward() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        await Dependencies.advertisingServices.showRewarded();

        await for (bool event in Dependencies
            .advertisingServices.advertismentStateStream.stream) {
          if (event) {
            HttpsCallable callDailyReward = FirebaseFunctions.instance
                .httpsCallable("solcitarCreditosDiarios");
            HttpsCallableResult httpsCallable = await callDailyReward.call();
            if (httpsCallable.data["estado"] == "correcto") {
              return true;
            } else {
              throw RewardException(message: "Error");
            }
          }
          
        }
        return true;
      } catch (e) {
        throw RewardException(message: "Error");
      }
    } else {
      throw NetworkException();
    }
  }

  @override
  Future<String> getDynamicLink() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Rewards>> getRewardObject() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      Map dataSource = source.getData;
      try {
        Rewards rewards = new Rewards(
            coins: dataSource["creditos"],
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
    sourceStreamSubscription?.cancel();
    return true;
  }

  @override
  void initializeModuleData() {
    rewardStream = new StreamController.broadcast();
    subscribeToMainDataSource();
  }

  @override
   StreamSubscription? sourceStreamSubscription;

  @override
  late StreamController<Rewards> rewardStream;

  @override
  Future<bool> getFrstReward() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable callDailyReward =
            FirebaseFunctions.instance.httpsCallable("pedirPrimeraRecompensa");
        HttpsCallableResult httpsCallable = await callDailyReward.call();
        if (httpsCallable.data["estado"] == "correcto") {
          return true;
        } else {
          throw RewardException(message: "Error");
        }
      } catch (e) {
        throw RewardException(message: "Error");
      }
    } else {
      throw NetworkException();
    }
  }
}
