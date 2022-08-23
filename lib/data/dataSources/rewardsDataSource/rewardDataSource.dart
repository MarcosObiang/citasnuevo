import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/idGenerator.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/RewardMapper.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../core/dependencies/error/Failure.dart';

abstract class RewardDataSource implements DataSource {
  // ignore: close_sinks
  late StreamController<Rewards>? rewardStream;

  /// Used for get a link so the user can share it and get rewarded with coins
  Future<String> getDynamicLink();

  /// Used to claim a daily reward after spending all of the coins 24 h before
  Future<void> getDailyReward();

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
  Future<void> getDailyReward() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable callDailyReward =
            FirebaseFunctions.instance.httpsCallable("solcitarCreditosDiarios");
        HttpsCallableResult httpsCallable = await callDailyReward.call();
        if (httpsCallable.data["estado"] == "correcto") {
          Dependencies.advertisingServices.closeStream();
        } else {
          Dependencies.advertisingServices.closeStream();
          throw RewardException(message: "Error");
        }
      } catch (e) {
        Dependencies.advertisingServices.closeStream();
        throw RewardException(message: "Error");
      }
    } else {
      Dependencies.advertisingServices.closeStream();
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }

  @override
  Future<String> getDynamicLink() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable recopensaComparte =
            FirebaseFunctions.instance.httpsCallable("linkComparteGana");
        String rewardCode = IdGenerator.instancia.createId();
        final dynamicLinkParams = DynamicLinkParameters(
            link: Uri.parse(
                "https://marcosobiang98.wixsite.com/obydevgames/comarteGana/$rewardCode"),
            uriPrefix: "https://citas.page.link",
            androidParameters:
                AndroidParameters(packageName: "com.hotty.citas"));

        final uri = await FirebaseDynamicLinks.instance
            .buildShortLink(dynamicLinkParams);
        await recopensaComparte.call({
          "codigo": rewardCode,
          "id": GlobalDataContainer.userId,
          "link": uri.shortUrl.toString()
        });
        return uri.shortUrl.toString();
      } catch (e) {
        throw RewardException(message: "ERROR_BUILDING_SHARING_LINHK:[message: ${e.toString()}]");
      }
    } else {
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }


  @override
  Future<Either<Failure, bool>> getVerificationReward() {
    throw UnimplementedError();
  }

  @override
  void subscribeToMainDataSource() {
    rewardStream?.add(RewardMapper.instance.fromMap(data: source.getData));

    sourceStreamSubscription = source.dataStream.stream.listen((event) {
      rewardStream?.add(RewardMapper.instance.fromMap(data: event));
    });
  }

  @override
  bool clearModuleData() {
    rewardStream?.close();
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
  StreamController<Rewards>? rewardStream;

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
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }
}
