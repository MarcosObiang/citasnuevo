import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';
import 'package:citasnuevo/domain/repository/rewardRepository/rewardRepository.dart';
import 'package:dartz/dartz.dart';

import '../controller_bridges/RewardScreenControllerBridge.dart';
import '../repository/DataManager.dart';

abstract class RewardController
    implements
        ShouldControllerUpdateData<RewardInformationSender>,
        ModuleCleaner {
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
  Future<Either<Failure,String>>getSharingLink();
  void _rewardStateListener();
}

class RewardControllerImpl implements RewardController {
  RewardControllerImpl(
      {required this.rewardRepository,
      required this.rewardScreenControlBridge});

  RewardRepository rewardRepository;
  RewardScreenControllerBridge rewardScreenControlBridge;
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
  StreamController<RewardInformationSender>? updateDataController;

  @override
  bool waitingDailyReward = false;

  StreamSubscription? rewardStreamSubscription;

  StreamSubscription? externalSubscription;

  bool isRewardCounterRunning = false;

  @override
  void clearModuleData() {
    try {
      rewardStreamSubscription?.cancel();
      updateDataController?.close();
      externalSubscription?.cancel();
    } catch (e) {}
  }

  @override
  void initializeModuleData() {
    updateDataController = StreamController.broadcast();
    rewardRepository.initializeModuleData();
    rewardScreenControlBridge.initializeStream();
    recieveExternalInformation();

    initialize();
  }

  void initialize() {
    _rewardStateListener();
  }

  void recieveExternalInformation() {
    externalSubscription = rewardScreenControlBridge
        .controllerBridgeInformationSenderStream?.stream
        .listen((event) {
      premiumPrice = event["data"];
    });
  }

  void stardDailyRewardCounter() async {
    if (rewards != null) {
      DateTime todayTime = await DateNTP.instance.getTime();
      int secondsToday = todayTime.millisecondsSinceEpoch ~/ 1000;
      int secondsRemaining = this.rewards!.timeUntilDailyReward - secondsToday;
      secondsUntilDailyReward = secondsRemaining;
      late Timer dailyRewardTimer;

      if (secondsRemaining > 0) {
        if (secondsRemaining > 84600) {
          secondsRemaining = 84600;
        }
        dailyRewardTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          waitingDailyReward = true;
          isRewardCounterRunning = true;

          this.secondsUntilDailyReward = this.secondsUntilDailyReward - 1;
          this.isPremium = rewards!.isPremium;
          updateDataController?.add(RewardInformationSender(
              premiumPrice: this.premiumPrice,
              rewards: this.rewards,
              isPremium: this.isPremium,
              secondsToDailyReward: secondsUntilDailyReward));
          if (secondsUntilDailyReward == 0) {
            secondsUntilDailyReward = 0;
            dailyRewardTimer.cancel();
            isRewardCounterRunning = false;
            waitingDailyReward = false;
          }
        });
      } else {
        secondsUntilDailyReward = 0;
        waitingDailyReward = false;
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
        rewardRepository.getRewardsStream?.stream.listen((event) {
      if (rewards != null) {
        this.isPremium = rewards!.isPremium;

        if (this.rewards?.waitingReward == false &&
            event.waitingReward == true) {
          stardDailyRewardCounter();
        }
      }

      if (isRewardCounterRunning == false) {
        stardDailyRewardCounter();
        isRewardCounterRunning = true;
      }
      this.rewards = event;

      if (rewards != null) {
        this.isPremium = rewards!.isPremium;

        updateDataController?.add(RewardInformationSender(
            premiumPrice: this.premiumPrice ?? "0",
            rewards: this.rewards,
            isPremium: this.isPremium,
            secondsToDailyReward: secondsUntilDailyReward));
      }
    }, onError: (error) {
      updateDataController?.addError(error);
    });
  }
  
  @override
  Future<Either<Failure, String>> getSharingLink() {
      return rewardRepository.getSharingLink();

  }
  
  @override
  String? sharingLink;
}
