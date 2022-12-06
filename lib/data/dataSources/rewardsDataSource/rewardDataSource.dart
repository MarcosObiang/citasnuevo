import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/core/common/commonUtils/idGenerator.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/RewardMapper.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../core/error/Failure.dart';
import '../../../domain/repository/DataManager.dart';

abstract class RewardDataSource implements DataSource, ModuleCleanerDataSource {
  // ignore: close_sinks
  late StreamController<Map<String, dynamic>>? rewardStream;

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
  StreamSubscription? sourceStreamSubscription;

  @override
  StreamController<Map<String, dynamic>>? rewardStream =
      new StreamController.broadcast();
  @override
  Future<void> getDailyReward() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
            functionId: "giveDailyReward",
            data: jsonEncode(
                {"firstReward": false, "userId": GlobalDataContainer.userId}));
        if (execution.statusCode == 200) {
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
      //  Dependencies.advertisingServices.closeStream();
      throw NetworkException(message: kNetworkErrorMessage);
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
        throw RewardException(
            message: "ERROR_BUILDING_SHARING_LINK:[message: ${e.toString()}]");
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void subscribeToMainDataSource() {
    try {
      rewardStream?.add(source.getData);

      sourceStreamSubscription = source.dataStream.stream.listen((event) {
        rewardStream?.add(event);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void clearModuleData() {
    try {
      rewardStream?.close();
      sourceStreamSubscription?.cancel();
      rewardStream = new StreamController.broadcast();
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  void initializeModuleData() {
    try {
      subscribeToMainDataSource();
    } catch (e) {
      throw ModuleInitializeException(message: e.toString());
    }
  }

  @override
  Future<bool> getFrstReward() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
            functionId: "giveDailyReward",
            data: jsonEncode(
                {"firstReward": true, "userId": GlobalDataContainer.userId}));
        if (execution.statusCode == 200) {
          return true;
        } else {
          throw RewardException(message: "Error");
        }
      } catch (e) {
        throw RewardException(message: "Error");
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }
}
