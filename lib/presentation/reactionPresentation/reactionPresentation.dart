// ignore_for_file: unused_field, unnecessary_null_comparison

import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/common/common_widgets.dart/errorWidget.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/reactionPresentation/Screens/ReactionScreen.dart';

import 'package:citasnuevo/domain/controller/reactionsController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:citasnuevo/presentation/reactionPresentation/Widgets/RevealingCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notify_inapp/notify_inapp.dart';

enum RevealingAnimationState { notTurning, turned, turning }

enum ReactionListState { loading, ready, empty, error }

class ReactionPresentation extends ChangeNotifier
    implements
        Presentation<ReactionPresentation>,
        SouldAddData<ReactionInformationSender>,
        ShouldRemoveData<ReactionInformationSender>,
        ShouldUpdateData<ReactionInformationSender>,
        ModuleCleaner {
  int _coins = 0;
  bool additionalDataRecieverIsInitialized = false;
  double _reactionsAverage = 0;
  ReactionListState _reactionListState = ReactionListState.empty;
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
  void clearModuleData() {
    lastSincronizationTimeInSeconds = 0;
    _coins = 0;
    additionalDataRecieverIsInitialized = false;
    _reactionsAverage = 0;
    _reactionListState = ReactionListState.empty;

    reactionsController.clearModuleData();
  }

  set setReactionListState(ReactionListState reactionListState) {
    this._reactionListState = reactionListState;
    notifyListeners();
  }

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
        showNetworkErrorDialog(
            context: ReactionScreen.reactionsListKey.currentContext);
      }
      if (failure is ReactionFailure) {
        showErrorDialog(
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
        showNetworkErrorDialog(
            context: ReactionScreen.reactionsListKey.currentContext);
      }
      if (failure is ReactionFailure) {
        showErrorDialog(
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
    if (getCoins >= 200) {
      var result =
          await reactionsController.revealReaction(reactionId: reactionId);
      result.fold((failure) {
        if (failure is NetworkFailure) {
          showNetworkErrorDialog(
              context: ReactionScreen.reactionsListKey.currentContext);
        }
        if (failure is ReactionFailure) {
          showErrorDialog(
              content: "Error al intentar realizar la operacion",
              context: ReactionScreen.reactionsListKey.currentContext,
              title: "Error");
        }
      }, (r) {});
    } else {
      showErrorDialog(
        title: "Creditos insuficientes",
        content: "Ve recompensas para ver las opciones que te damos para ganar creditos gratuitos",
        context: ReactionScreen.reactionsListKey.currentContext,
      );
    }
  }

  @override
  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {
    if (context != null) {
      showDialog(
          context: context,
          builder: (context) =>
              GenericErrorDialog(title: title, content: content));
    }
  }

  @override
  void showLoadingDialog() {}

  @override
  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }

  @override
  void initialize() async {
    addData();
    removeData();
    update();
    initializeModuleData();
    DateTime dateTime = await DateNTP().getTime();
    lastSincronizationTimeInSeconds = dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  @override
  void restart() {
    clearModuleData();

    setReactionListState = ReactionListState.loading;
    updateSubscription?.cancel();
    addDataSubscription?.cancel();
    removeDataSubscription?.cancel();

    initialize();
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

            if (event.notify) {
              showInAppNotification();
            }

            if (ReactionScreen.reactionsListKey.currentContext != null &&
                ReactionScreen.reactionsListKey.currentState != null) {
              ReactionScreen.reactionsListKey.currentState
                  ?.insertItem(0, duration: Duration(milliseconds: 1500));
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
                      duration: Duration(milliseconds: 800));

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
            },
            cancelOnError: false,
            onError: (_) {
              setReactionListState = ReactionListState.error;
            });
  }

  @override
  void initializeModuleData() {
    reactionsController.initializeModuleData();
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
}
