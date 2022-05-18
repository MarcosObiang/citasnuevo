import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';
import 'package:citasnuevo/domain/repository/rewardRepository/rewardRepository.dart';

import '../repository/DataManager.dart';

abstract class RewardController
    implements
        ShouldControllerUpdateData<RewardInformationSender>,
        ModuleCleaner {
  late Rewards rewards;
  late int secondsUntilDailyReward;
  late bool firstReward;
  late bool waitingDailyReward;
  late bool isVerified;
  late bool isPremium;
}

class RewardControllerImpl implements RewardController {
  RewardControllerImpl({required this.rewardRepository});

  RewardRepository rewardRepository;

  @override
  late Rewards rewards;

  @override
  late bool firstReward = false;

  @override
  late bool isPremium = false;

  @override
  late bool isVerified = false;

  @override
  late int secondsUntilDailyReward = 0;

  @override
  late StreamController<RewardInformationSender> updateDataController;

  @override
  late bool waitingDailyReward = false;

  late StreamSubscription rewardStreamSubscription;

  bool isRewardCounterRunning = false;

  @override
  void clearModuleData() {
    rewardStreamSubscription.cancel();
    updateDataController.close();
  }

  @override
  void initializeModuleData() {
    updateDataController = StreamController.broadcast();
    initialize();
  }

  void initialize() {
    rewardStreamSubscription =
        rewardRepository.getRewardsStream.stream.listen((event) {
      this.rewards = event;

      updateDataController.add(RewardInformationSender(
          rewards: this.rewards,
          secondsToDailyReward: secondsUntilDailyReward));
      if (isRewardCounterRunning == false) {
        stardDailyRewardCounter();
        isRewardCounterRunning = true;
      }
    });
  }

  void stardDailyRewardCounter() async {
    DateTime todayTime = await DateNTP.instance.getTime();
    int secondsToday = todayTime.millisecondsSinceEpoch ~/ 1000;
    int secondsRemaining = secondsToday - this.rewards.timeUntilDailyReward;
    secondsUntilDailyReward = secondsRemaining;
    late Timer dailyRewardTimer;

    if (secondsRemaining > 0) {
      if (secondsRemaining > 84600) {
        secondsRemaining = 84600;
      }
      dailyRewardTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        this.secondsUntilDailyReward = this.secondsUntilDailyReward - 1;

        updateDataController.add(RewardInformationSender(
            rewards: this.rewards,
            secondsToDailyReward: secondsUntilDailyReward));
        if (secondsUntilDailyReward == 1) {
          dailyRewardTimer.cancel();
          isRewardCounterRunning = false;
        }
      });
    }
  }
}
