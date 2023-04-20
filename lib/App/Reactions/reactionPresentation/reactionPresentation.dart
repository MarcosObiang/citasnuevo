// ignore_for_file: unused_field, unnecessary_null_comparison

import 'dart:async';
import 'dart:math';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/common/common_widgets.dart/errorWidget.dart';
import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/main.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notify_inapp/notify_inapp.dart';

import '../../DataManager.dart';
import '../../PrincipalScreen.dart';
import '../../PrincipalScreenFataNotifier.dart';
import '../../Rewards/rewardScreenPresentation/rewardScreen.dart';
import '../../../Utils/dialogs.dart';
import '../../../Utils/presentationDef.dart';
import '../../controllerDef.dart';
import '../../../core/dependencies/dependencyCreator.dart';
import '../ReactionEntity.dart';
import '../reactionsController.dart';
import 'Screens/ReactionScreen.dart';
import 'Widgets/RevealingCard.dart';

enum RevealingAnimationState { notTurning, turned, turning }

enum ReactionListState {
  loading,
  ready,
  empty,
  error,
  loadingAd,
  errorLoadingAd
}

enum AdShowingState {
  adLoading,
  errorLoadingAd,
  adShown,
  adShowing,
  adNotshowing
}

class ReactionPresentation extends ChangeNotifier
    implements
        Presentation,
        ShouldAddData<ReactionInformationSender>,
        ShouldRemoveData<ReactionInformationSender>,
        ShouldUpdateData<ReactionInformationSender>,
        ModuleCleanerPresentation,
        PrincipalScreenNotifier {
  int _coins = 0;
  bool additionalDataRecieverIsInitialized = false;
  double _reactionsAverage = 0;
  ReactionListState _reactionListState = ReactionListState.empty;
  AdShowingState _adShowingstate = AdShowingState.adNotshowing;
  ReactionsControllerImpl reactionsController;
  bool readyToSincronize = false;
  int lastSincronizationTimeInSeconds = 0;
  bool isPremium = false;

  @override
  StreamSubscription<ReactionInformationSender>? addDataSubscription;

  @override
  StreamSubscription<ReactionInformationSender>? updateSubscription;

  @override
  StreamSubscription<ReactionInformationSender>? removeDataSubscription;
  @override
  void initializeModuleData() {
    try {
      addData();
      removeData();
      update();
      setReactionListState = ReactionListState.loading;

      reactionsController.initializeModuleData();
    } catch (e) {
      this._reactionListState = ReactionListState.error;
    }
  }

  @override
  void clearModuleData() {
    try {
      lastSincronizationTimeInSeconds = 0;
      _coins = 0;
      additionalDataRecieverIsInitialized = false;
      _reactionsAverage = 0;
      _reactionListState = ReactionListState.empty;
      updateSubscription?.cancel();
      addDataSubscription?.cancel();
      removeDataSubscription?.cancel();
      reactionsController.clearModuleData();
    } catch (e) {
      this._reactionListState = ReactionListState.error;
    }
  }

  set setReactionListState(ReactionListState reactionListState) {
    this._reactionListState = reactionListState;
    notifyListeners();
  }

  set setAdShowingState(AdShowingState adShowingState) {
    this._adShowingstate = adShowingState;
    notifyListeners();
  }

  AdShowingState get getAdShowingState => this._adShowingstate;
  set setCoins(int coins) {
    this._coins = coins;
    notifyListeners();
  }

  set setAverage(double average) {
    this._reactionsAverage = average;
    notifyListeners();
  }

  set setIsPremium(bool isPremium) {
    this.isPremium = isPremium;
    notifyListeners();
  }

  int get getCoins => this._coins;
  double get getAverage => this._reactionsAverage;
  ReactionListState get getReactionListState => this._reactionListState;

  void initializeValues() {
    setCoins = reactionsController.coins;
    setAverage = reactionsController.reactionsAverage;
    setIsPremium = reactionsController.isPremium;
  }

  void acceptReaction(
      {required String reactionId, required String reactionSenderId}) async {
    var result = await reactionsController.acceptReaction(
        reactionId: reactionId, reactionSenderId: reactionSenderId);

    result.fold((failure) {
      if (failure is NetworkFailure) {
        PresentationDialogs.instance.showNetworkErrorDialog(
            context: ReactionScreen.reactionsListKey.currentContext);
      }
      if (failure is ReactionFailure) {
        PresentationDialogs.instance.showErrorDialog(
            content: "Error al intentar realizar la operacion",
            context: ReactionScreen.reactionsListKey.currentContext,
            title: "Error");
      }
    }, (r) {});
  }

  void rejectReaction({required String reactionId}) async {
    var result = await reactionsController.rejectReaction(
      reactionId: reactionId,
    );

    result.fold((failure) {
      if (failure is NetworkFailure) {
        PresentationDialogs.instance.showNetworkErrorDialog(
            context: ReactionScreen.reactionsListKey.currentContext);
      }
      if (failure is ReactionFailure) {
        PresentationDialogs.instance.showErrorDialog(
            content: "Error al intentar realizar la operacion",
            context: ReactionScreen.reactionsListKey.currentContext,
            title: "Error");
      }
    }, (r) {});
  }

  ReactionPresentation({
    required this.reactionsController,
  });

  void revealReaction({required String reactionId}) async {
    if (isPremium == false) {
      if (getCoins >= 200) {
        if (reactionsController.checkIfReactionCanShowAds(reactionId)) {
          var adResult = await reactionsController.showRewarded();

          adResult.fold((l) {
            if (l is NetworkFailure) {
              PresentationDialogs.instance.showNetworkErrorDialog(
                  context: startKey.currentContext);
            } else {
              PresentationDialogs.instance.showErrorDialog(
                  content: "Error al intentar realizar la operacion",
                  context: startKey.currentContext,
                  title: "Error");
            }
          }, (r) async {
            if (Dependencies
                    .advertisingServices.interstitialAdvertismentStateStream !=
                null) {
              setAdShowingState = AdShowingState.adLoading;

              await for (Map<String, dynamic> event in reactionsController
                  .rewardedAdvertismentStateStream.stream) {
                if (event["status"] == "FAILED") {
                  setAdShowingState = AdShowingState.errorLoadingAd;
                }
                if (event["status"] == "CLOSED") {
                  setAdShowingState = AdShowingState.adShown;
                }
                if (event["status"] == "EXPIRED") {
                  setAdShowingState = AdShowingState.errorLoadingAd;
                }
                if (event["status"] == "NOT_READY") {
                  setAdShowingState = AdShowingState.errorLoadingAd;
                }
                if (event["status"] == "SHOWING") {
                  setAdShowingState = AdShowingState.adShowing;
                }
                reactionsController.closeAdsStreams();
                setAdShowingState = AdShowingState.adNotshowing;

                var result = await reactionsController.revealReaction(
                    reactionId: reactionId);
                result.fold((failure) {
                  if (failure is NetworkFailure) {
                    PresentationDialogs.instance.showNetworkErrorDialog(
                        context:
                            startKey.currentContext);
                  }
                  if (failure is ReactionFailure) {
                    PresentationDialogs.instance.showErrorDialog(
                        content: "Error al intentar realizar la operacion",
                        context: ReactionScreen.reactionsListKey.currentContext,
                        title: "Error");
                  }
                }, (r) {});
              }
            } else {
              setAdShowingState = AdShowingState.errorLoadingAd;
            }
          });
        } else {
          var result =
              await reactionsController.revealReaction(reactionId: reactionId);
          result.fold((failure) {
            if (failure is NetworkFailure) {
              PresentationDialogs.instance.showNetworkErrorDialog(
                  context: ReactionScreen.reactionsListKey.currentContext);
            }
            if (failure is ReactionFailure) {
              PresentationDialogs.instance.showErrorDialog(
                  content: "Error al intentar realizar la operacion",
                  context: ReactionScreen.reactionsListKey.currentContext,
                  title: "Error");
            }
          }, (r) {});
        }
      } else {
        PresentationDialogs.instance.showErrorDialogWithOptions(
            context: ReactionScreen.reactionsListKey.currentContext,
            dialogText: "No tienes gemas suficientes",
            dialogTitle: "Gemas Insuficientes",
            dialogOptionsList: [
              DialogOptions(
                  function: () =>
                      Navigator.pop(startKey.currentContext as BuildContext),
                  text: "Entendido"),
              DialogOptions(
                  function: () {
                    Navigator.pop(startKey.currentContext as BuildContext);

                    var bottomNavigationBar = PrincipalScreen
                        .bottomNavigationKey
                        .currentWidget as BottomNavigationBar;
                    if (bottomNavigationBar != null) {
                      if (bottomNavigationBar.onTap != null) {
                        bottomNavigationBar.onTap!(3);
                      }
                    }
                  },
                  text: "Ganar Gemas"),
            ]);
      }
    } else {
      var result =
          await reactionsController.revealReaction(reactionId: reactionId);
      result.fold((failure) {
        if (failure is NetworkFailure) {
          PresentationDialogs.instance.showNetworkErrorDialog(
              context: ReactionScreen.reactionsListKey.currentContext);
        }
        if (failure is ReactionFailure) {
          PresentationDialogs.instance.showErrorDialog(
              content: "Error al intentar realizar la operacion",
              context: ReactionScreen.reactionsListKey.currentContext,
              title: "Error");
        }
      }, (r) {});
    }
  }

  void goTorewards(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context, rootNavigator: false)
        .pushNamed(RewardScreen.routeName);
  }

  @override
  void restart() {
    clearModuleData();

    initializeModuleData();
  }

  @override
  void update() {
    updateSubscription =
        reactionsController.updateDataController?.stream.listen((event) {
      if (reactionsController.reactions.isEmpty) {
        setReactionListState = ReactionListState.empty;
      } else {
        setReactionListState = ReactionListState.ready;
      }

      if (event.coins != null) {
        setCoins = event.coins as int;
      }
      if (event.reactionAverage != null) {
        setAverage = event.reactionAverage as double;
      }
      if (event.isPremium != null) {
        setIsPremium = event.isPremium;
      }
      notifyPrincipalScreen();

      notifyListeners();
    }, onError: (_) {
      setReactionListState = ReactionListState.error;
    });
  }

  @override
  void addData() async {
    addDataSubscription = reactionsController.addDataController?.stream.listen(
        (event) {
          if (event.isModified == false) {
            setReactionListState = ReactionListState.ready;
            notifyPrincipalScreen();

            if (event.notify) {
              showInAppNotification();
            }

            if (ReactionScreen.reactionsListKey.currentContext != null &&
                ReactionScreen.reactionsListKey.currentState != null) {
              ReactionScreen.reactionsListKey.currentState
                  ?.insertItem(0, duration: Duration(milliseconds: 500));
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
            }
          }
        },
        cancelOnError: false,
        onError: (_) {
          setReactionListState = ReactionListState.error;
        });
  }

  @override
  void removeData() {
    removeDataSubscription =
        reactionsController.removeDataController?.stream.listen(
            (event) {
              DateTime? reactionExpireTime;
              ReactionRevealigState? reactionRevealigState;

              if (event.reaction != null) {
                reactionExpireTime = DateTime.fromMillisecondsSinceEpoch(
                    event.reaction!.reactionExpirationDateInSeconds * 1000);
                reactionRevealigState = event.reaction!.reactionRevealigState;
              }
              if (ReactionScreen.reactionsListKey.currentState != null &&
                  ReactionScreen.boxConstraints != null) {
                if (event.index != null && event.reaction != null) {
                  ReactionScreen.reactionsListKey.currentState?.removeItem(
                      event.index as int,
                      (context, animation) => ReactionCard(
                          reaction: event.reaction as Reaction,
                          boxConstraints: ReactionScreen.boxConstraints,
                          index: event.index as int,
                          animation: animation),
                      duration: Duration(milliseconds: 500));

                  if (reactionsController.reactions.length == 0) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      setReactionListState = ReactionListState.empty;
                    });
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      notifyListeners();
                    });
                  }
                }
              } else {
                if (reactionsController.reactions.length == 0) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    setReactionListState = ReactionListState.empty;
                  });
                }
              }
              if (reactionExpireTime != null &&
                  reactionRevealigState == ReactionRevealigState.notRevealed) {
                showExpiredINAppNotification(dateTime: reactionExpireTime);
              }
              notifyPrincipalScreen();
            },
            cancelOnError: false,
            onError: (_) {
              setReactionListState = ReactionListState.error;
            });
  }

  void showInAppNotification() {
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
                      "Nueva reacción",
                      style: GoogleFonts.lato(fontSize: 60.sp),
                    ),
                    Text(
                      "Tienes una nueva reacción",
                      style: GoogleFonts.lato(fontSize: 40.sp),
                    ),
                  ],
                ),
              )),
        ),
        duration: 300);
  }

  void showExpiredINAppNotification({required DateTime dateTime}) {
    var expireTimeFormat = new DateFormat.yMEd().add_Hms();

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
                      "Reaccion caducada",
                      style: GoogleFonts.lato(fontSize: 60.sp),
                    ),
                    Text(
                      " Ha caducado el ${expireTimeFormat.format(dateTime)}",
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
      "payload": "reactionData",
      "newReactions": reactionsController.reactions.length,
      "coins": getCoins,
      "isPremium": isPremium
    });
  }
}
