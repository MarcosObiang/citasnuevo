import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../DataManager.dart';
import '../MainDatasource/principalDataSource.dart';
import '../../core/common/commonUtils/idGenerator.dart';
import '../../core/error/Exceptions.dart';
import '../../core/globalData.dart';
import '../../core/platform/networkInfo.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import '../../../core/dependencies/dependencyCreator.dart';

abstract class RewardDataSource implements DataSource, ModuleCleanerDataSource {
  // ignore: close_sinks
  late StreamController<Map<String, dynamic>>? rewardStream;

  /// Used for get a link so the user can share it and get rewarded with coins
  Future<bool> getDynamicLink();

  /// Used to claim a daily reward after spending all of the coins 24 h before
  Future<void> getDailyReward();

  Future<bool> getFrstReward();
  Future<bool> usePromotionalCode();
    Future<bool> rewardTicketSuccesfulShares
();


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
  StreamSubscription<RealtimeMessage>? reactionSubscriptionListener;

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
  Future<bool> getDynamicLink() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
            functionId: "ticketRewardCreator",
            data: jsonEncode({"userId": GlobalDataContainer.userId}));
        int status = jsonDecode(execution.response)["status"];
        String message = jsonDecode(execution.response)["message"];
        if (status == 200) {
          return true;
        }
        if (status == 201) {
          throw RewardException(message: message);
        } else {
          throw RewardException(message: message);
        }
      } catch (e) {
        throw RewardException(message: "ERROR");
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void subscribeToMainDataSource() {
    
    try {
      rewardStream?.add(source.getData);

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
      rewardStream=null;
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

  @override
  Future<bool> usePromotionalCode() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
          functionId: "usePromotionalCode",
        );
         int status = jsonDecode(execution.response)["status"];
        String message = jsonDecode(execution.response)["message"];
        if (status == 200) {
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
  
  @override
  Future<bool> rewardTicketSuccesfulShares()async {
      if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
          functionId: "rewardTicketSuccesfulShares",
        );
         int status = jsonDecode(execution.response)["status"];
        String message = jsonDecode(execution.response)["message"];
        if (status == 200) {
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
