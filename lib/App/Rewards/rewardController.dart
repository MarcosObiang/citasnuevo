import 'dart:async';

import 'package:citasnuevo/App/ControllerBridges/PurchseSystemControllerBridge.dart';

import 'rewardRepository.dart';

import '../DataManager.dart';
import '../controllerDef.dart';
import '../../core/common/commonUtils/DateNTP.dart';
import '../../core/error/Failure.dart';

import 'package:dartz/dartz.dart';

import 'RewardScreenControllerBridge.dart';
import 'RewardsEntity.dart';



abstract class RewardController
    implements
        ShouldControllerUpdateData<RewardInformationSender>,
        ModuleCleanerController {
  Rewards? rewards;
  late int secondsUntilDailyReward;
  late bool firstReward;
  late bool waitingDailyReward;
  late bool isVerified;
  late bool isPremium;
  late String? premiumPrice;
  late String? sharingLink;
  Future<Either<Failure, bool>> askDailyReward();
  Future<Either<Failure, bool>> askFirstReward();
  Future<Either<Failure, bool>> getSharingLink();
  Future<Either<Failure, bool>> usePromotionalCode();
  Future<Either<Failure, bool>> rewardTicketSuccesfulShares();

  void _rewardStateListener();
}

class RewardControllerImpl implements RewardController {
  RewardControllerImpl(
      {required this.rewardRepository,
      required this.rewardScreenControlBridge,required this.purchaseSystemControllerBridge});

  RewardRepository rewardRepository;
  RewardScreenControllerBridge rewardScreenControlBridge;
  PurchaseSystemControllerBridge purchaseSystemControllerBridge;
  @override
  Rewards? rewards;

  @override
  bool firstReward = false;

  @override
  bool isPremium = false;

  @override
  bool isVerified = false;

  @override
  int secondsUntilDailyReward = 0;

  @override
  StreamController<RewardInformationSender>? updateDataController =
      StreamController.broadcast();

  @override
  bool waitingDailyReward = false;

  StreamSubscription? rewardStreamSubscription;

  StreamSubscription? externalSubscription;

  bool isRewardCounterRunning = false;

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      rewardStreamSubscription?.cancel();
      updateDataController?.close();
      externalSubscription?.cancel();
      updateDataController = StreamController.broadcast();

      var result = rewardRepository.clearModuleData();
      return result;
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      recieveExternalInformation();
      recieveExternalInformationPurchaseSystem();
      _rewardStateListener();
      var result = rewardRepository.initializeModuleData();
      return result;
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  void recieveExternalInformation() {
    externalSubscription = rewardScreenControlBridge
        .controllerBridgeInformationSenderStream?.stream
        .listen((event) {
      this.premiumPrice = event["data"];
      updateDataController?.add(RewardInformationSender(
                premiumPrice: this.premiumPrice,
                rewards: this.rewards,
                isPremium: this.isPremium,
                secondsToDailyReward: secondsUntilDailyReward));
    });
  }
    void recieveExternalInformationPurchaseSystem() {
     purchaseSystemControllerBridge
        .controllerBridgeInformationSenderStream?.stream
        .listen((event) {
      this.premiumPrice = event["data"]["price"];
      updateDataController?.add(RewardInformationSender(
                premiumPrice: this.premiumPrice,
                rewards: this.rewards,
                isPremium: this.isPremium,
                secondsToDailyReward: secondsUntilDailyReward));
    });
  }

  void stardDailyRewardCounter() async {
    if (rewards != null) {
      DateTime todayTime = await DateNTP.instance.getTime();
      int secondsToday = todayTime.millisecondsSinceEpoch;
      int secondsRemaining =
          (this.rewards!.timeUntilDailyReward - secondsToday) ~/ 1000;
      secondsUntilDailyReward = secondsRemaining;
      late Timer dailyRewardTimer;

      if (secondsRemaining > 0) {
        if (secondsRemaining > 84600) {
          secondsRemaining = 84600;
        }
    
          dailyRewardTimer = Timer.periodic(Duration(seconds: 1), (timer) {
            isRewardCounterRunning = true;

            waitingDailyReward = true;

            this.secondsUntilDailyReward = this.secondsUntilDailyReward - 1;
            this.isPremium = rewards!.isPremium;
            updateDataController?.add(RewardInformationSender(
                premiumPrice: this.premiumPrice,
                rewards: this.rewards,
                isPremium: this.isPremium,
                secondsToDailyReward: secondsUntilDailyReward));
            if (secondsUntilDailyReward == 0) {
              secondsUntilDailyReward = 0;
              isRewardCounterRunning = false;
              waitingDailyReward = false;
              dailyRewardTimer.cancel();
            }
          });
        
      }
      else {
          secondsUntilDailyReward = 0;
          waitingDailyReward = false;
          isRewardCounterRunning = false;
        }
    }
  }

  @override
  String? premiumPrice;

  @override
  Future<Either<Failure, bool>> askDailyReward() async {
    return await rewardRepository.getDailyReward();
  }

  @override
  Future<Either<Failure, bool>> askFirstReward() async {
    return rewardRepository.getFirstReward();
  }

  @override
  void _rewardStateListener() {
    rewardStreamSubscription =
        rewardRepository.getStreamParserController?.stream.listen((event) {
      if (this.rewards == null) {
        rewards = event["rewards"];
        String payloadType = event["payloadType"];
        rewards = event["rewards"];
        if (payloadType == "rewards") {
          if (rewards != null) {
            if (this.rewards?.waitingReward == true &&
                this.rewards!.timeUntilDailyReward > 0) {
              stardDailyRewardCounter();
            }

            updateDataController?.add(RewardInformationSender(
                premiumPrice: this.premiumPrice ?? "0",
                rewards: this.rewards,
                isPremium: this.isPremium,
                secondsToDailyReward: secondsUntilDailyReward));
          }
        }
      } else {
        Rewards cacheTemporal = event["rewards"];
        if (cacheTemporal != this.rewards) {
          this.rewards = cacheTemporal;
          if (this.rewards?.waitingReward == true &&
              this.rewards!.timeUntilDailyReward > 0) {
            stardDailyRewardCounter();
          }

          updateDataController?.add(RewardInformationSender(
              premiumPrice: this.premiumPrice ?? "0",
              rewards: this.rewards,
              isPremium: this.isPremium,
              secondsToDailyReward: secondsUntilDailyReward));
        }
      }
    }, onError: (error) {
      updateDataController?.addError(error);
    });
  }

  @override
  Future<Either<Failure, bool>> getSharingLink() {
    return rewardRepository.getSharingLink();
  }

  @override
  String? sharingLink;

  @override
  Future<Either<Failure, bool>> usePromotionalCode() {
    return rewardRepository.usePromotionalCode();
  }

  @override
  Future<Either<Failure, bool>> rewardTicketSuccesfulShares() {
    return rewardRepository.rewardTicketSuccesfulShares();
  }
}
