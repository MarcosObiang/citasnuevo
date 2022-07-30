import 'dart:async';

import 'package:citasnuevo/domain/controller/rewardController.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';
import 'package:citasnuevo/domain/repository/rewardRepository/rewardRepository.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notify_inapp/notify_inapp.dart';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../domain/controller/controllerDef.dart';
import '../../domain/repository/DataManager.dart';

enum DailyRewardState {
  inProcess,
  done,
}

enum FirstRewards {
  inProcess,
  done,
}

enum RewardScreenState { loading, done, error }

class RewardScreenPresentation extends ChangeNotifier
    implements
        ShouldUpdateData<RewardInformationSender>,
        Presentation,
        ModuleCleaner {
  RewardController rewardController;
  DailyRewardState _dailyRewardState = DailyRewardState.done;
  FirstRewards _firstRewards = FirstRewards.done;
  RewardScreenState _rewardScreenState = RewardScreenState.loading;
  int coins = 0;

  set setRewardScreenState(RewardScreenState rewardScreenState) {
    this._rewardScreenState = rewardScreenState;
    notifyListeners();
  }

  RewardScreenState get getRewardScreenState => this._rewardScreenState;

  set setDayliRewardState(DailyRewardState dailyRewardState) {
    this._dailyRewardState = dailyRewardState;
    notifyListeners();
  }

  FirstRewards get getFirstRewards => this._firstRewards;

  set setFirstRewards(FirstRewards firstRewards) {
    this._firstRewards = firstRewards;
    notifyListeners();
  }

  DailyRewardState get getDayliRewardState => this._dailyRewardState;
  late Rewards rewards;
  RewardScreenPresentation({required this.rewardController});

  @override
  late StreamSubscription<RewardInformationSender>? updateSubscription;

  String premiumPrice = "";

  late StreamController<int> dailyRewardTieRemainingStream;

  @override
  void clearModuleData() {
    updateSubscription?.cancel();
    dailyRewardTieRemainingStream.close();
    setDayliRewardState = DailyRewardState.done;
    setFirstRewards = FirstRewards.done;
    coins = 0;
    setRewardScreenState = RewardScreenState.loading;
  }

  @override
  void initialize() {}

  @override
  void initializeModuleData() {
    rewardController.initializeModuleData();
    dailyRewardTieRemainingStream = new StreamController.broadcast();
    update();
  }

  @override
  void restart() {
    clearModuleData();

    initializeModuleData();
  }

  void askDailyReward() async {
    setDayliRewardState = DailyRewardState.inProcess;
    var result = await rewardController.askDailyReward();
    result.fold((l) {
      setDayliRewardState = DailyRewardState.done;
    }, (r) {
      setDayliRewardState = DailyRewardState.done;
      showInAppRewardNotification(
          rewardDescription: "Ya tienes 600 creditos", rewardHeader: "Genial");
    });
  }

  void askFirstReward() async {
    setFirstRewards = FirstRewards.inProcess;
    var result = await rewardController.askFirstReward();
    result.fold((l) {
      setFirstRewards = FirstRewards.done;
    }, (r) {
      setFirstRewards = FirstRewards.done;
      showInAppRewardNotification(
          rewardDescription: "Te regalamos 30000 creditos",
          rewardHeader: "Disfruta Hotty");
    });
  }

  @override
  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {}

  @override
  void showLoadingDialog() {}

  @override
  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }

  @override
  void update() {
    updateSubscription =
        rewardController.updateDataController?.stream.listen((event) {
      if (event.rewards != null) {
        if (event.premiumPrice != null &&
            event.rewards != null &&
            event.rewards?.coins != null) {
          premiumPrice = event.premiumPrice!;
          rewards = event.rewards as Rewards;
          coins = event.rewards!.coins;
        }
      }

      setRewardScreenState = RewardScreenState.done;
      dailyRewardTieRemainingStream.add(event.secondsToDailyReward as int);
    }, onError: (error) {
      setRewardScreenState = RewardScreenState.error;
    });
  }

  void showInAppRewardNotification(
      {required String rewardHeader, required String rewardDescription}) {
    Notify notify = Notify();
    notify.show(
        startKey.currentContext as BuildContext,
        Padding(
          padding: EdgeInsets.all(10.h),
          child: Container(
              height: 150.h,
              width: ScreenUtil().screenWidth,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: EdgeInsets.all(10.h),
                child: Column(
                  children: [
                    Text(
                      rewardHeader,
                      style: GoogleFonts.lato(fontSize: 60.sp),
                    ),
                    Text(
                      rewardDescription,
                      style: GoogleFonts.lato(fontSize: 40.sp),
                    ),
                  ],
                ),
              )),
        ),
        duration: 300);
  }
}
