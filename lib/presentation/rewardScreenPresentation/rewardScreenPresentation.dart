import 'dart:async';

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/domain/controller/rewardController.dart';
import 'package:citasnuevo/domain/entities/RewardsEntity.dart';
import 'package:citasnuevo/domain/repository/rewardRepository/rewardRepository.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/dialogs.dart';
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

enum SharingRewardState {
  inProcess,
  done,
}

enum FirstRewards {
  inProcess,
  done,
}

enum RewardedAdShowingState {
  adLoading,
  errorLoadingAd,
  adShowing,
  adNotShowing,
  adShown,
  adIncomplete
}

enum RewardScreenState { loading, done, error, loadingAd }

class RewardScreenPresentation extends ChangeNotifier
    implements
        ShouldUpdateData<RewardInformationSender>,
        Presentation,
        ModuleCleanerPresentation {
  RewardController rewardController;
  DailyRewardState _dailyRewardState = DailyRewardState.done;
  FirstRewards _firstRewards = FirstRewards.done;
  SharingRewardState _sharingRewardState = SharingRewardState.done;
  RewardScreenState _rewardScreenState = RewardScreenState.loading;
  RewardedAdShowingState _rewardedAdShowingState =
      RewardedAdShowingState.adNotShowing;
  int coins = 0;

  set setRewardedAdShowingstate(RewardedAdShowingState rewardedAdShowingState) {
    this._rewardedAdShowingState = rewardedAdShowingState;

    notifyListeners();
  }

  set setRewardScreenState(RewardScreenState rewardScreenState) {
    this._rewardScreenState = rewardScreenState;
    notifyListeners();
  }

  set setSharingRewardState(SharingRewardState sharingRewardState) {
    this._sharingRewardState = sharingRewardState;
    notifyListeners();
  }

  set setDayliRewardState(DailyRewardState dailyRewardState) {
    this._dailyRewardState = dailyRewardState;
    notifyListeners();
  }

  set setFirstRewards(FirstRewards firstRewards) {
    this._firstRewards = firstRewards;
    notifyListeners();
  }

  FirstRewards get getFirstRewards => this._firstRewards;

  RewardScreenState get getRewardScreenState => this._rewardScreenState;
  SharingRewardState get getSharingRewardState => this._sharingRewardState;

  RewardedAdShowingState get getRewardedAdShowingState =>
      this._rewardedAdShowingState;
  DailyRewardState get getDayliRewardState => this._dailyRewardState;
  late Rewards rewards;
  RewardScreenPresentation({required this.rewardController});

  @override
  StreamSubscription<RewardInformationSender>? updateSubscription;

  String premiumPrice = "";
  String? sharingLink;

  StreamController<int>? dailyRewardTieRemainingStream;

  @override
  void clearModuleData() {
    updateSubscription?.cancel();
    dailyRewardTieRemainingStream?.close();
    setDayliRewardState = DailyRewardState.done;
    setFirstRewards = FirstRewards.done;
    coins = 0;
    setRewardScreenState = RewardScreenState.loading;
  }



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

  void getSharingLink() async {
    setSharingRewardState = SharingRewardState.inProcess;

    var result = await rewardController.getSharingLink();

    result.fold((l) {
      setSharingRewardState = SharingRewardState.done;

      if (l is NetworkFailure) {
       PresentationDialogs.instance. showErrorDialog(
            content: "Hotty npuede conectarse a internet",
            context: startKey.currentContext,
            title: "Error");
      } else {
       PresentationDialogs.instance. showErrorDialog(
            content: "Error al intentar realizar la operacion",
            context: startKey.currentContext,
            title: "Error");
      }
    }, (r) {
      sharingLink = r;
      setSharingRewardState = SharingRewardState.done;
    });
  }

  void askDailyReward({required bool showAd}) async {
    if (showAd == true) {
      setRewardedAdShowingstate = RewardedAdShowingState.adLoading;

      await Dependencies.advertisingServices.showRewarded();

      if (Dependencies.advertisingServices.rewardedAdvertismentStateStream !=
          null) {
        await for (Map<String, dynamic> event in Dependencies
            .advertisingServices.rewardedAdvertismentStateStream!.stream) {
          String status = event["status"];

          if (status == "FAILED") {
            setRewardedAdShowingstate = RewardedAdShowingState.errorLoadingAd;
          }

          if (status == "CLOSED") {
            setRewardedAdShowingstate = RewardedAdShowingState.adShown;
          }
          if (status == "INCOMPLETE") {
            setRewardedAdShowingstate = RewardedAdShowingState.adIncomplete;
          }
          Dependencies.advertisingServices.closeStream();

          if (status != "INCOMPLETE" && status != "FAILED") {
            setDayliRewardState = DailyRewardState.inProcess;

            var result = await rewardController.askDailyReward();
            result.fold((l) {
              setRewardedAdShowingstate = RewardedAdShowingState.adNotShowing;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setDayliRewardState = DailyRewardState.done;
              });
             PresentationDialogs.instance. showErrorDialog(
                  content: "Error al intentar realizar la operacion",
                  context: startKey.currentContext,
                  title: "Error");
            }, (r) {
              setRewardedAdShowingstate = RewardedAdShowingState.adNotShowing;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setDayliRewardState = DailyRewardState.done;
              });
              showInAppRewardNotification(
                  rewardDescription: "Ya tienes 600 creditos",
                  rewardHeader: "Genial");
            });
          }
        }
      }
    } else {
      setDayliRewardState = DailyRewardState.inProcess;
      var result = await rewardController.askDailyReward();
      result.fold((l) {
        setDayliRewardState = DailyRewardState.done;
       PresentationDialogs.instance. showErrorDialog(
            content: "Hotty npuede conectarse a internet",
            context: startKey.currentContext,
            title: "Error");
      }, (r) {
        setDayliRewardState = DailyRewardState.done;
        showInAppRewardNotification(
            rewardDescription: "Ya tienes 600 creditos",
            rewardHeader: "Genial");
      });
    }
  }

  void askFirstReward() async {
    setFirstRewards = FirstRewards.inProcess;
    var result = await rewardController.askFirstReward();
    result.fold((l) {
      setFirstRewards = FirstRewards.done;
     PresentationDialogs.instance. showErrorDialog(
          content: "Error al intentar realizar la operacion",
          context: startKey.currentContext,
          title: "Error");
    }, (r) {
      setFirstRewards = FirstRewards.done;
      showInAppRewardNotification(
          rewardDescription: "Te regalamos 15000 creditos",
          rewardHeader: "Disfruta Hotty");
    });
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
      dailyRewardTieRemainingStream?.add(event.secondsToDailyReward as int);
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
