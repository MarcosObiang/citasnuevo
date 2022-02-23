// ignore_for_file: unused_field, unnecessary_null_comparison

import 'package:citasnuevo/core/common/common_widgets.dart/errorWidget.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:citasnuevo/presentation/reactionPresentation/Screens/ReactionScreen.dart';

import 'package:citasnuevo/domain/controller/reactionsController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:flutter/material.dart';

enum ReactionListState { loading, ready, empty, error }

class ReactionPresentation extends ChangeNotifier implements Presentation {
  int _coins = 0;
  bool additionalDataRecieverIsInitialized = false;
  double _reactionsAverage = 0;
  ReactionListState _reactionListState = ReactionListState.empty;
  ReactionsController reactionsController;

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

  void initializeDataReciever() {
    try {
      if (this.additionalDataRecieverIsInitialized == false) {
        reactionsController.getAdditionalData.stream.listen((event) {
          setCoins = event["coins"];
          setAverage = event["reactionsAverage"];
          this.additionalDataRecieverIsInitialized = true;
        });
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
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

  void initializeExpiredReactionsStream() {
    reactionsController.streamIdExpiredReactions.stream.listen((event) {
      int index = event["index"];
      Reaction reaction = event["reaction"];
      if (ReactionScreen.reactionsListKey.currentState != null &&
          ReactionScreen.boxConstraints != null) {
        ReactionScreen.reactionsListKey.currentState?.removeItem(
            index,
            (context, animation) => ReactionCard(
                reaction: reaction,
                boxConstraints: ReactionScreen.boxConstraints,
                index: index,
                animation: animation),
            duration: Duration(milliseconds: 300));

        if (reactionsController.reactions.length == 0) {
          setReactionListState = ReactionListState.empty;
        }
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          notifyListeners();
        });
      }
    });
  }

  void initializeReactionsListener() async {
    var result = await reactionsController.initializeReactionListener();
    result.fold((failure) {
      setReactionListState = ReactionListState.error;
    }, (succes) {
      initializeExpiredReactionsStream();

      reactionsController.getReactions.stream.listen((event) {
        bool isModified = event["modified"];
        if (isModified == false) {
          setReactionListState = ReactionListState.ready;

          if (ReactionScreen.reactionsListKey.currentContext != null &&
              ReactionScreen.reactionsListKey.currentState != null) {
            ReactionScreen.reactionsListKey.currentState?.insertItem(0);
            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {});
          }
        }
      });

      if (reactionsController.listenerInitialized == false) {}
    });
  }

  ReactionPresentation({
    required this.reactionsController,
  });

  void reactionRevealed({required String reactionId}) async {
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
}
