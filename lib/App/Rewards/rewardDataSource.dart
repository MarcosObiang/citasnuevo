import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../core/services/Ads.dart';
import '../DataManager.dart';
import '../MainDatasource/principalDataSource.dart';
import '../../core/error/Exceptions.dart';
import '../../core/globalData.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../controllerDef.dart';

abstract class RewardDataSource
    implements DataSource, ModuleCleanerDataSource, AdvertisementShowCapacity {
  // ignore: close_sinks
  late StreamController<Map<String, dynamic>>? rewardStream;

  /// Used for get a link so the user can share it and get rewarded with coins
  Future<bool> getDynamicLink();

  /// Used to claim a daily reward after spending all of the coins 24 h before
  Future<void> getDailyReward();

  Future<bool> getFrstReward();
  Future<bool> usePromotionalCode();
  Future<bool> rewardTicketSuccesfulShares();

  ///Use to get real time updates from the data source
  ///
}

class RewardDataSourceImpl implements RewardDataSource {
  @override
  ApplicationDataSource source;
  RewardDataSourceImpl(
      {required this.source, required this.advertisingServices});
  @override
  StreamSubscription? sourceStreamSubscription;
  StreamSubscription<RealtimeMessage>? reactionSubscriptionListener;
  @override
  AdvertisingServices advertisingServices;

  @override
  StreamController<Map<String, dynamic>>
      get rewadedAdvertismentStatusListener =>
          advertisingServices.rewardedAdvertismentStateStream;

  @override
  StreamController<Map<String, dynamic>>? rewardStream =
      new StreamController.broadcast();
  @override
  Future<void> getDailyReward() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution = await Dependencies.serverAPi.functions
            .createExecution(
                functionId: "giveDailyReward",
                body: jsonEncode({
                  "firstReward": true,
                  "userId": GlobalDataContainer.userId
                }));

        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];

        if (status == 200) {
          Dependencies.advertisingServices.closeStream();
        } else {
          Dependencies.advertisingServices.closeStream();
          throw RewardException(message: message);
        }
      } catch (e) {
        Dependencies.advertisingServices.closeStream();
        throw RewardException(message: e.toString());
      }
    } else {
      Dependencies.advertisingServices.closeStream();
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> getDynamicLink() async {
    /* if (await Dependencies.networkInfoContract.isConnected) {
      try {
        final response = await Dependencies
            .serverAPi.app!.currentUser!.functions
            .call("giveFirstReward", [
          jsonEncode(
              {"firstReward": true, "userId": GlobalDataContainer.userId})
        ]);

        var responseDecoded = jsonDecode(response);

        int status = responseDecoded["executionCode"];
        String message = responseDecoded["message"];
        if (status == 200) {
          return true;
        } else {
          throw RewardException(message: message);
        }
      } catch (e) {
        throw RewardException(message: "ERROR");
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/
    return true;
  }

  @override
  Future<bool> showRewardedAd() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        return advertisingServices.showAd();
      } catch (e) {
        throw ReactionException(message: "FAILED");
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void subscribeToMainDataSource() {
    try {
      rewardStream?.add(source.getData);
      log(source.getData.toString());

      sourceStreamSubscription = source.dataStream?.stream.listen((event) {
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
      reactionSubscriptionListener?.cancel();
      rewardStream = null;
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
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution = await Dependencies.serverAPi.functions
            .createExecution(
                functionId: "giveDailyReward",
                body: jsonEncode({
                  "firstReward": true,
                  "userId": GlobalDataContainer.userId
                }));

        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];

        if (status == 200) {
          return true;
        } else {
          throw RewardException(message: message);
        }
      } catch (e) {
        throw RewardException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> usePromotionalCode() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution = await Dependencies.serverAPi.functions
            .createExecution(
                functionId: "usePromotionalCode",
                body: jsonEncode({"userId": GlobalDataContainer.userId}));

        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];

        if (status == 200) {
          return true;
        } else {
          throw RewardException(message: message);
        }
      } catch (e) {
        throw RewardException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> rewardTicketSuccesfulShares() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Execution execution = await Dependencies.serverAPi.functions
            .createExecution(
                functionId: "rewardTicketSuccesfulShares",
                body: jsonEncode({"userId": GlobalDataContainer.userId}));

        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];
        if (status == 200) {
          return true;
        } else {
          throw RewardException(message: message);
        }
      } catch (e) {
        throw RewardException(message: "Error: $e");
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void closeAdsStreams() {
    advertisingServices.closeStream();
  }
}
