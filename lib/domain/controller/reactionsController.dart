import 'dart:async';
import 'dart:ffi';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/reactionRepository/reactionRepository.dart';
import 'package:dartz/dartz.dart';

import '../../core/dependencies/error/Failure.dart';
import 'controllerDef.dart';

abstract class ReactionController
    implements
        ShouldControllerRemoveData<ReactionInformationSender>,
        ShouldControllerUpdateData<ReactionInformationSender>,
        ShouldControllerAddData<ReactionInformationSender>,
        ModuleCleaner {
  ///Saves the reactions in a list
  late List<Reaction> reactions;

  ///The average of all the reactions recieevd by the user
  late double reactionsAverage;

  /// if the listener is initialized
  late bool listenerInitialized;

  ///Amount of coins the user has
  late int coins;

  /// Any time we add a new reaction to the [reactions]list, first we give the reaction
  ///
  /// a common reference of a stream, if a reaction expires they can use this stream
  ///
  /// to tell the [ReactionController] they should be deleted
  // ignore: close_sinks
  late StreamController<Reaction> expiredReactionsListener;
}

class ReactionsControllerImpl implements ReactionController {
  @override
  List<Reaction> reactions = [];
  @override
  double reactionsAverage = 0;
  @override
  bool listenerInitialized = false;
  @override
  int coins = 0;

  @override
  late StreamController<ReactionInformationSender> addDataController =
      new StreamController.broadcast();

  @override
  late StreamController<ReactionInformationSender> removeDataController =
      new StreamController.broadcast();

  @override
  late StreamController<ReactionInformationSender> updateDataController =
      StreamController.broadcast();

  StreamController<ReactionInformationSender> get getAddData =>
      this.addDataController;

  StreamController<ReactionInformationSender> get getRemoveData =>
      this.removeDataController;

  StreamController<ReactionInformationSender> get getUpdateData =>
      this.updateDataController;

  @override
  StreamController<Reaction> expiredReactionsListener =
      StreamController.broadcast();
  StreamController<Map<String, dynamic>> streamExpiredReactions =
      StreamController.broadcast();

  ReactionRepository reactionRepository;
  ReactionsControllerImpl({
    required this.reactionRepository,
  });

  StreamController<Map> get getAdditionalData =>
      reactionRepository.additionalDataStream;
  StreamController<Map<String, dynamic>> get streamIdExpiredReactions =>
      this.streamExpiredReactions;

  StreamController<Map<String, dynamic>> get getReactions =>
      this.reactionRepository.reactionListener;

  StreamController<String> streamRevealedReactionId =
      new StreamController.broadcast();

  late StreamSubscription coinsStreamSubscription;
  late StreamSubscription expiredReactionSubscription;
  late StreamSubscription reactionSubscription;

  Future<Either<Failure, bool>> initializeReactionListener() async {
    initReactionStream();
    initializeExpiredTimeListener();
    return reactionRepository.initializeReactionListener();
  }

  int lastSyncronizationTime = 0;

  @override
  void clearModuleData() {
    reactions.clear();

    expiredReactionsListener.close();
    streamExpiredReactions.close();
    streamRevealedReactionId.close();
    addDataController.close();
    removeDataController.close();
    updateDataController.close();
    coinsStreamSubscription.cancel();
    expiredReactionSubscription.cancel();
    reactionSubscription.cancel();
    streamRevealedReactionId = new StreamController.broadcast();
    streamExpiredReactions = StreamController.broadcast();
    expiredReactionsListener = StreamController.broadcast();
    addDataController = new StreamController.broadcast();
    removeDataController = new StreamController.broadcast();

    updateDataController = new StreamController.broadcast();

    listenerInitialized = false;
    reactionsAverage = 0;
    coins = 0;
    reactionRepository.clearModuleData();
  }

  void initReactionStream() {
    initCoinListener();

    reactionSubscription =
        reactionRepository.reactionListener.stream.listen((event) {
      bool isModified = event["modified"];
      Reaction reaction = event["reaction"];
      bool isDeleted = event["deleted"];

      if (isDeleted == false) {
        if (isModified == false) {
          reaction.reactionExpiredId = this.expiredReactionsListener;
          reactions.add(reaction);
          addDataController.add(ReactionInformationSender(
              index: null,
              reaction: reaction,
              reactionAverage: reactionsAverage,
              sync: false,
              isModified: isModified,
              isDeleted: isDeleted,
              coins: coins));
        } else {
          for (int i = 0; i < reactions.length; i++) {
            if (reactions[i].idReaction == reaction.idReaction) {
              reactions[i].setName = reaction.getName;
              reactions[i].imageHash = reaction.imageHash;
              reactions[i].imageUrl = reaction.imageUrl;
              reactions[i].setReactionRevealigState =
                  ReactionRevealigState.revealed;
            }
          }
        }
      }
    }, onError: (error) {
      addDataController.addError(error);
    });
  }

  void initializeExpiredTimeListener() {
    expiredReactionSubscription =
        this.expiredReactionsListener.stream.listen((event) {
      int reactionIndex = reactions
          .indexWhere((element) => element.idReaction == event.idReaction);

      reactions.removeAt(reactionIndex);

      streamExpiredReactions.add({"index": reactionIndex, "reaction": event});
      removeDataController.add(ReactionInformationSender(
          index: reactionIndex,
          reaction: event,
          reactionAverage: this.reactionsAverage,
          sync: false,
          isModified: false,
          isDeleted: true,
          coins: coins));
    }, onError: (error) {
      removeDataController.addError(error);
    });
  }

  void initCoinListener() {
    coinsStreamSubscription = reactionRepository
        .reactionDataSource.additionalDataSender.stream
        .listen((event) {
      try {
        reactionsAverage = event["reactionsAverage"];
        coins = event["coins"];

        updateDataController.add(ReactionInformationSender(
            reaction: null,
            reactionAverage: reactionsAverage,
            sync: false,
            isModified: null,
            isDeleted: null,
            coins: coins,
            index: null));
      } catch (e) {
        updateDataController.addError(e);
      }
    }, onError: (error) {
      updateDataController.addError(error);
    });
  }

  Future<bool> shouldSincronize() async {
    if (await NetworkInfoImpl.networkInstance.isConnected == true) {
      try {
        bool shouldSincronize = false;
        DateTime dateTime = await DateNTP.instance.getTime();
        int timeInSecondsNow = dateTime.millisecondsSinceEpoch ~/ 1000;
        if (lastSyncronizationTime <= 0) {
          return shouldSincronize;
        } else {
          if (timeInSecondsNow - lastSyncronizationTime > 10) {
            shouldSincronize = true;
          } else {
            shouldSincronize = false;
          }
          return shouldSincronize;
        }
      } catch (e, s) {
        throw ReactionException(message: e.toString(), stackTrace: s);
      }
    } else {
      throw NetworkException();
    }
  }

  void sync() {
    reactions.clear();

    expiredReactionsListener.close();
    streamExpiredReactions.close();
    streamRevealedReactionId.close();

    coinsStreamSubscription.cancel();
    expiredReactionSubscription.cancel();
    reactionSubscription.cancel();
    streamRevealedReactionId = new StreamController.broadcast();
    streamExpiredReactions = StreamController.broadcast();
    expiredReactionsListener = StreamController.broadcast();

    listenerInitialized = false;
    reactionsAverage = 0;
    coins = 0;
    reactionRepository.clearModuleData();
    initializeModuleData();
  }

  Future<Either<Failure, void>> revealReaction(
      {required String reactionId}) async {
    bool shouldSync = false;

    try {
      shouldSync = await shouldSincronize();
    } catch (e) {
      return Left(ReactionFailure());
    }

    if (shouldSync == true) {
      Either<Failure, void> result;
      result = Right(Void);
      updateDataController.add(ReactionInformationSender(
          sync: true,
          reaction: null,
          reactionAverage: reactionsAverage,
          isModified: null,
          isDeleted: null,
          coins: coins,
          index: null));
      return result;
    } else {
      for (int i = 0; i < this.reactions.length; i++) {
        if (this.reactions[i].idReaction == reactionId) {
          this.reactions[i].setReactionRevealigState =
              ReactionRevealigState.revealing;
          updateDataController.add(ReactionInformationSender(
              sync: false,
              reaction: null,
              reactionAverage: reactionsAverage,
              isModified: null,
              isDeleted: null,
              coins: coins,
              index: null));

          break;
        }
      }

      Either<Failure, void> result =
          await reactionRepository.revealReaction(reactionId: reactionId);

      result.fold((l) {
        for (int i = 0; i < this.reactions.length; i++) {
          if (this.reactions[i].idReaction == reactionId) {
            this.reactions[i].setReactionRevealigState =
                ReactionRevealigState.notRevealed;
            updateDataController.add(ReactionInformationSender(
                sync: false,
                reaction: null,
                reactionAverage: reactionsAverage,
                isModified: null,
                isDeleted: null,
                coins: coins,
                index: null));

            break;
          }
        }
      }, (r) {});
      return result;
    }
  }

  Future<Either<Failure, bool>> acceptReaction(
      {required String reactionId, required String reactionSenderId}) async {
    bool shouldSync = false;

    try {
      shouldSync = await shouldSincronize();
    } catch (e) {
      return Left(ReactionFailure());
    }
    if (shouldSync == true) {
      Either<Failure, bool> result;
      result = Right(true);
      updateDataController.add(ReactionInformationSender(
          sync: true,
          reaction: null,
          reactionAverage: reactionsAverage,
          isModified: null,
          isDeleted: null,
          coins: coins,
          index: null));
      return result;
    } else {
      for (int i = 0; i < this.reactions.length; i++) {
        if (this.reactions[i].idReaction == reactionId) {
          this.reactions[i].setReactionAceptingState =
              ReactionAceptingState.inProcessAcepting;
          updateDataController.add(ReactionInformationSender(
              reaction: null,
              reactionAverage: reactionsAverage,
              isModified: null,
              sync: false,
              isDeleted: null,
              coins: coins,
              index: null));

          break;
        }
      }
      Either<Failure, bool> result = await reactionRepository.acceptReaction(
          reactionId: reactionId, reactionSenderId: reactionSenderId);

      result.fold((l) {
        for (int i = 0; i < reactions.length; i++) {
          if (reactions[i].idReaction == reactionId) {
            reactions[i].setReactionAceptingState = ReactionAceptingState.error;
            updateDataController.add(ReactionInformationSender(
                reaction: null,
                reactionAverage: reactionsAverage,
                sync: false,
                isModified: null,
                isDeleted: null,
                coins: coins,
                index: null));
          }
        }
      }, (r) {
        for (int i = 0; i < reactions.length; i++) {
          if (reactions[i].idReaction == reactionId) {
            reactions[i].setReactionAceptingState = ReactionAceptingState.done;
            Reaction reaction = reactions.removeAt(i);
            removeDataController.add(ReactionInformationSender(
                sync: false,
                reaction: reaction,
                reactionAverage: reactionsAverage,
                isModified: false,
                isDeleted: true,
                coins: coins,
                index: i));
          }
        }
      });

      return result;
    }
  }

  Future<Either<Failure, bool>> rejectReaction(
      {required String reactionId}) async {
    bool shouldSync = false;

    try {
      shouldSync = await shouldSincronize();
    } catch (e) {
      return Left(ReactionFailure());
    }

    if (shouldSync == true) {
      Either<Failure, bool> result;
      result = Right(true);
      updateDataController.add(ReactionInformationSender(
          sync: true,
          reaction: null,
          reactionAverage: reactionsAverage,
          isModified: null,
          isDeleted: null,
          coins: coins,
          index: null));
      return result;
    } else {
      for (int i = 0; i < this.reactions.length; i++) {
        if (this.reactions[i].idReaction == reactionId) {
          this.reactions[i].setReactionAceptingState =
              ReactionAceptingState.inProcessDeclining;
          updateDataController.add(ReactionInformationSender(
              reaction: null,
              reactionAverage: reactionsAverage,
              sync: false,
              isModified: null,
              isDeleted: null,
              coins: coins,
              index: null));

          break;
        }
      }

      Either<Failure, bool> result =
          await reactionRepository.rejectReaction(reactionId: reactionId);

      result.fold((l) {
        updateDataController.add(ReactionInformationSender(
            reaction: null,
            reactionAverage: reactionsAverage,
            sync: false,
            isModified: null,
            isDeleted: null,
            coins: coins,
            index: null));
      }, (r) {
        for (int i = 0; i < reactions.length; i++) {
          if (reactions[i].idReaction == reactionId) {
            this.reactions[i].setReactionAceptingState =
                ReactionAceptingState.done;
            Reaction reaction = reactions.removeAt(i);

            removeDataController.add(ReactionInformationSender(
                reaction: reaction,
                reactionAverage: reactionsAverage,
                sync: false,
                isModified: false,
                isDeleted: true,
                coins: coins,
                index: i));
          }
        }
      });
      return result;
    }
  }

  @override
  void initializeModuleData() async {
    reactionRepository.initializeModuleData();
    DateTime dateTime = await DateNTP().getTime();
    lastSyncronizationTime = dateTime.millisecondsSinceEpoch ~/ 1000;
  }
}
