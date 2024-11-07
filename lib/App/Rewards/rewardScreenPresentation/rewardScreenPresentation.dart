import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notify_inapp/notify_inapp.dart';

import '../../PrincipalScreenDataNotifier.dart';
import '../../DataManager.dart';
import '../../../Utils/dialogs.dart';
import '../../../Utils/presentationDef.dart';
import '../../controllerDef.dart';
import '../../../core/dependencies/dependencyCreator.dart';
import '../../../core/error/Failure.dart';
import '../../../main.dart';
import '../RewardsEntity.dart';
import '../rewardController.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

enum DailyRewardState {
  inProcess,
  done,
}

enum PromotionalCodeState {
  inProcess,
  done,
}

enum RewardTicketSuccesfulSharesState {
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
        ModuleCleanerPresentation,
        PrincipalScreenNotifier {
  RewardController rewardController;
  DailyRewardState _dailyRewardState = DailyRewardState.done;
  FirstRewards _firstRewards = FirstRewards.done;
  RewardTicketSuccesfulSharesState _rewardTicketSuccesfulSharesState =
      RewardTicketSuccesfulSharesState.done;

  PromotionalCodeState _sharingRewardState = PromotionalCodeState.done;
  RewardScreenState _rewardScreenState = RewardScreenState.loading;
  RewardedAdShowingState _rewardedAdShowingState =
      RewardedAdShowingState.adNotShowing;
  int coins = 0;

  set setRewardTicketSuccesfulShareState(
      RewardTicketSuccesfulSharesState rewardTicketSuccesfulSharesState) {
    this._rewardTicketSuccesfulSharesState = rewardTicketSuccesfulSharesState;
    notifyListeners();
  }

  set setRewardedAdShowingstate(RewardedAdShowingState rewardedAdShowingState) {
    this._rewardedAdShowingState = rewardedAdShowingState;

    notifyListeners();
  }

  set setRewardScreenState(RewardScreenState rewardScreenState) {
    this._rewardScreenState = rewardScreenState;
    notifyListeners();
  }

  set setPromotionalCodeState(PromotionalCodeState sharingRewardState) {
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

  RewardTicketSuccesfulSharesState get getRewardTicketSuccessfulShareState =>
      this._rewardTicketSuccesfulSharesState;

  RewardScreenState get getRewardScreenState => this._rewardScreenState;
  PromotionalCodeState get getPromotionalCodeState => this._sharingRewardState;

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
    dailyRewardTieRemainingStream = new StreamController.broadcast();
    rewardController.clearModuleData();
  }

  @override
  void initializeModuleData() {
    rewardController.initializeModuleData();
    update();
  }

  @override
  void restart() {
    clearModuleData();

    initializeModuleData();
  }

  void getSharingLink() async {
    setPromotionalCodeState = PromotionalCodeState.inProcess;

    var result = await rewardController.getSharingLink();

    result.fold((l) {
      setPromotionalCodeState = PromotionalCodeState.done;

      if (l is NetworkFailure) {
        PresentationDialogs.instance.showErrorDialog(
            content: AppLocalizations.of(startKey.currentContext!)!
                .purchase_system_presentation_hottyNoInternet,
            context: startKey.currentContext,
            title: AppLocalizations.of(startKey.currentContext!)!.error);
      } else {
        PresentationDialogs.instance.showErrorDialog(
            content: AppLocalizations.of(startKey.currentContext!)!
                .purchase_system_presentation_operationFailed,
            context: startKey.currentContext,
            title: AppLocalizations.of(startKey.currentContext!)!.error);
      }
    }, (r) {
      sharingLink = rewardController.rewards?.dynamicLink;
      setPromotionalCodeState = PromotionalCodeState.done;
    });
  }

  void askDailyReward({required bool showAd}) async {
    if (showAd == true) {
      setRewardedAdShowingstate = RewardedAdShowingState.adLoading;

      var adResult = await rewardController.showRewarded();
      adResult.fold((l) {
        if (l is NetworkFailure) {
          PresentationDialogs.instance
              .showNetworkErrorDialog(context: startKey.currentContext);
        } else {
          PresentationDialogs.instance.showErrorDialog(
              content: AppLocalizations.of(startKey.currentContext!)!
                  .purchase_system_presentation_operationFailed,
              context: startKey.currentContext,
              title: AppLocalizations.of(startKey.currentContext!)!.error);
        }
      }, (r) async {
        await for (Map<String, dynamic> event in Dependencies
            .advertisingServices.rewardedAdvertismentStateStream.stream) {
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
          rewardController.closeAdsStreams();

          if (status != "INCOMPLETE" && status != "FAILED") {
            setDayliRewardState = DailyRewardState.inProcess;

            var result = await rewardController.askDailyReward();
            result.fold((l) {
              setRewardedAdShowingstate = RewardedAdShowingState.adNotShowing;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setDayliRewardState = DailyRewardState.done;
              });
              PresentationDialogs.instance.showErrorDialog(
                  content: AppLocalizations.of(startKey.currentContext!)!
                      .purchase_system_presentation_operationFailed,
                  context: startKey.currentContext,
                  title: AppLocalizations.of(startKey.currentContext!)!.error);
            }, (r) {
              setRewardedAdShowingstate = RewardedAdShowingState.adNotShowing;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setDayliRewardState = DailyRewardState.done;
              });
              showInAppRewardNotification(
                  rewardDescription: AppLocalizations.of(
                          startKey.currentContext!)!
                      .rewardScreenPresentation_dailyRewardNotificationMessage(
                          "600"),
                  rewardHeader: AppLocalizations.of(startKey.currentContext!)!
                      .rewardScreenPresentation_dailyRewardNotificationTitle);
            });
          }
        }
      });
    } else {
      setDayliRewardState = DailyRewardState.inProcess;
      var result = await rewardController.askDailyReward();
      result.fold((l) {
        setDayliRewardState = DailyRewardState.done;
        PresentationDialogs.instance.showErrorDialog(
            content: AppLocalizations.of(startKey.currentContext!)!
                .purchase_system_presentation_hottyNoInternet,
            context: startKey.currentContext,
            title: AppLocalizations.of(startKey.currentContext!)!.error);
      }, (r) {
        setDayliRewardState = DailyRewardState.done;
        showInAppRewardNotification(
            rewardDescription: AppLocalizations.of(startKey.currentContext!)!
                .rewardScreenPresentation_dailyRewardNotificationMessage("600"),
            rewardHeader: AppLocalizations.of(startKey.currentContext!)!
                .rewardScreenPresentation_dailyRewardNotificationTitle);
      });
    }
  }

  void askFirstReward() async {
    setFirstRewards = FirstRewards.inProcess;
    var result = await rewardController.askFirstReward();
    result.fold((l) {
      setFirstRewards = FirstRewards.done;
      PresentationDialogs.instance.showErrorDialog(
          content: AppLocalizations.of(startKey.currentContext!)!
              .purchase_system_presentation_operationFailed,
          context: startKey.currentContext,
          title: AppLocalizations.of(startKey.currentContext!)!.error);
    }, (r) {
      setFirstRewards = FirstRewards.done;
      showInAppRewardNotification(
          rewardDescription: AppLocalizations.of(startKey.currentContext!)!
              .rewardScreenPresentation_dailyRewardNotificationMessage("15000"),
          rewardHeader: AppLocalizations.of(startKey.currentContext!)!
              .rewardScreenPresentation_dailyRewardNotificationTitle);
    });
  }

  void usePromotionalCode() async {
    setPromotionalCodeState = PromotionalCodeState.inProcess;
    var result = await rewardController.usePromotionalCode();
    result.fold((l) {
      setPromotionalCodeState = PromotionalCodeState.done;
      PresentationDialogs.instance.showErrorDialog(
          content: AppLocalizations.of(startKey.currentContext!)!
              .purchase_system_presentation_operationFailed,
          context: startKey.currentContext,
          title: AppLocalizations.of(startKey.currentContext!)!.error);
    }, (r) {
      setPromotionalCodeState = PromotionalCodeState.done;
      showInAppRewardNotification(
          rewardDescription: AppLocalizations.of(startKey.currentContext!)!
              .rewardScreenPresentation_dailyRewardNotificationMessage("15000"),
          rewardHeader: AppLocalizations.of(startKey.currentContext!)!
              .rewardScreenPresentation_dailyRewardNotificationTitle);
    });
  }

  void rewardTicketSuccesfultShares() async {
    setRewardTicketSuccesfulShareState =
        RewardTicketSuccesfulSharesState.inProcess;
    var result = await rewardController.rewardTicketSuccesfulShares();
    result.fold((l) {
      setRewardTicketSuccesfulShareState =
          RewardTicketSuccesfulSharesState.done;
      PresentationDialogs.instance.showErrorDialog(
          content: AppLocalizations.of(startKey.currentContext!)!
              .purchase_system_presentation_operationFailed,
          context: startKey.currentContext,
          title: AppLocalizations.of(startKey.currentContext!)!.error);
    }, (r) {
      setRewardTicketSuccesfulShareState =
          RewardTicketSuccesfulSharesState.done;
      showInAppRewardNotification(
          rewardDescription: AppLocalizations.of(startKey.currentContext!)!
              .rewardScreenPresentation_dailyRewardNotificationMessage("15000"),
          rewardHeader: AppLocalizations.of(startKey.currentContext!)!
              .rewardScreenPresentation_dailyRewardNotificationTitle);
    });
  }

  @override
  void update() {
    dailyRewardTieRemainingStream = new StreamController.broadcast();

    updateSubscription =
        rewardController.updateDataController?.stream.listen((event) {
      if (event.rewards != null) {
        if (event.premiumPrice != null &&
            event.rewards != null &&
            event.rewards?.coins != null) {
          premiumPrice = event.premiumPrice!;
          rewards = event.rewards as Rewards;
          coins = event.rewards!.coins;
          sharingLink = event.rewards!.dynamicLink;
          notifyPrincipalScreen();
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

  @override
  StreamController<Map<String, dynamic>>? principalScreenNotifier =
      StreamController();

  @override
  void notifyPrincipalScreen() {
    principalScreenNotifier?.add({
      "payload": "rewardData",
      "rewardTicketSuccesfulShares": rewards.rewardTicketSuccesfulShares,
      "promotionalCodePendingOfUse": rewards.promotionalCodePendingOfUse,
      "waitingDailyReward": rewardController.secondsUntilDailyReward == 0 &&
              rewards.waitingReward == true
          ? true
          : false,
      "waitingFirstReward": rewards.waitingFirstReward
    });
  }
}
