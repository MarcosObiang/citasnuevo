// ignore_for_file: unused_field, unnecessary_null_comparison

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:citasnuevo/presentation/reactionPresentation/Screens/ReactionScreen.dart';
import 'package:flutter/cupertino.dart';

import 'package:citasnuevo/domain/controller/reactionsController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';

enum ReactionListState { ready, empty, error }

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

      setReactionListState = ReactionListState.ready;
      reactionsController.getReactions.stream.listen((event) {
        if (ReactionScreen.reactionsListKey.currentContext != null &&
            ReactionScreen.reactionsListKey.currentState != null) {
          ReactionScreen.reactionsListKey.currentState?.insertItem(0);
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            notifyListeners();
          });
        }
      });

      if (reactionsController.listenerInitialized == false) {}
    });
  }

  ReactionPresentation({
    required this.reactionsController,
  });

  void reactionRevealed() {
    for (int i = 0; i < reactionsController.reactions.length; i++) {
      reactionsController.reactions[i].setReactionRevealigState =
        ReactionRevealigState.revealed;
    }
  }

  @override
  void showErrorDialog(
      {required String errorLog,
      required String errorName,
      required BuildContext context}) {}

  @override
  void showLoadingDialog() {}
}
