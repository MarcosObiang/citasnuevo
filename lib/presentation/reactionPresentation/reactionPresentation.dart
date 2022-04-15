// ignore_for_file: unused_field, unnecessary_null_comparison

import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/common/common_widgets.dart/errorWidget.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/presentation/reactionPresentation/Screens/ReactionScreen.dart';

import 'package:citasnuevo/domain/controller/reactionsController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:citasnuevo/presentation/reactionPresentation/Widgets/RevealingCard.dart';
import 'package:flutter/material.dart';

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

  @override
  late StreamSubscription<ReactionInformationSender> addDataSubscription;

  @override
  late StreamSubscription<ReactionInformationSender> updateSubscription;

  @override
  late StreamSubscription<ReactionInformationSender> removeDataSubscription;

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

  int get getCoins => this._coins;
  double get getAverage => this._reactionsAverage;
  ReactionListState get getReactionListState => this._reactionListState;

  void initializeValues() {
    setCoins = reactionsController.coins;
    setAverage = reactionsController.reactionsAverage;
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
    updateSubscription.cancel();
    addDataSubscription.cancel();
    removeDataSubscription.cancel();

    initialize();
  }

  @override
  void update() {
    updateSubscription =
        reactionsController.updateDataController.stream.listen((event) {
      if (event.coins != null) {
        setCoins = event.coins as int;
      }
      if (event.reactionAverage != null) {
        setAverage = event.reactionAverage as double;
      }
      if (event.sync == true) {
        restart();
      }
      notifyListeners();
    }, onError: (_) {
      setReactionListState = ReactionListState.error;
    });
  }

  @override
  void addData() async {
    var result = await reactionsController.initializeReactionListener();
    result.fold((failure) {
      setReactionListState = ReactionListState.error;
    }, (succes) {
      addDataSubscription = reactionsController.addDataController.stream.listen(
          (event) {
            if (event.isModified == false) {
              setReactionListState = ReactionListState.ready;

              if (ReactionScreen.reactionsListKey.currentContext != null &&
                  ReactionScreen.reactionsListKey.currentState != null) {
                ReactionScreen.reactionsListKey.currentState?.insertItem(0);
                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {});
              }
            }
          },
          cancelOnError: false,
          onError: (_) {
            setReactionListState = ReactionListState.error;
          });
    });
  }

  @override
  void removeData() {
    removeDataSubscription =
        reactionsController.removeDataController.stream.listen(
            (event) {
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
                      duration: Duration(milliseconds: 300));

                  if (reactionsController.reactions.length == 0) {
                    setReactionListState = ReactionListState.empty;
                  }
                  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                    notifyListeners();
                  });
                }
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
}
