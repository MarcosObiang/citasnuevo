import 'dart:async';

import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/reactionRepository/reactionRepository.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/Failure.dart';
import '../controller_bridges/HomeScreenCotrollerBridge.dart';
import 'controllerDef.dart';

abstract class ReactionController
    implements
        ShouldControllerRemoveData<ReactionInformationSender>,
        ShouldControllerUpdateData<ReactionInformationSender>,
        ShouldControllerAddData<ReactionInformationSender>,
        ModuleCleanerController {
  ///Saves the reactions in a list
  late List<Reaction> reactions;

  ///The average of all the reactions recieevd by the user
  late double reactionsAverage;

  /// if the listener is initialized
  late bool listenerInitialized;

  ///Amount of coins the user has
  late int coins;

  late bool isPremium;

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
  bool isPremium = false;

  @override
  StreamController<ReactionInformationSender>? addDataController =
      new StreamController.broadcast();

  @override
  StreamController<ReactionInformationSender>? removeDataController =
      new StreamController.broadcast();

  @override
  StreamController<ReactionInformationSender>? updateDataController =
      StreamController.broadcast();

  StreamController<ReactionInformationSender>? get getAddData =>
      this.addDataController;

  StreamController<ReactionInformationSender>? get getRemoveData =>
      this.removeDataController;

  StreamController<ReactionInformationSender>? get getUpdateData =>
      this.updateDataController;

  @override
  StreamController<Reaction> expiredReactionsListener =
      StreamController.broadcast();
  StreamController<Map<String, dynamic>> streamExpiredReactions =
      StreamController.broadcast();

  HomeScreenControllerBridge homeScreencontrollerbridge;

  ReactionRepository reactionRepository;
  ReactionsControllerImpl(
      {required this.reactionRepository,
      required this.homeScreencontrollerbridge});

  StreamController<Map<String, dynamic>> get streamIdExpiredReactions =>
      this.streamExpiredReactions;

  StreamController<String> streamRevealedReactionId =
      new StreamController.broadcast();

  StreamSubscription? coinsStreamSubscription;
  StreamSubscription? expiredReactionSubscription;
  StreamSubscription? reactionSubscription;
  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      initReactionStream();
      initializeExpiredTimeListener();
      var result = reactionRepository.initializeModuleData();
      return result;
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      reactions.clear();

      expiredReactionsListener.close();
      streamExpiredReactions.close();
      streamRevealedReactionId.close();
      addDataController?.close();
      removeDataController?.close();
      updateDataController?.close();
      coinsStreamSubscription?.cancel();
      expiredReactionSubscription?.cancel();
      reactionSubscription?.cancel();
      streamRevealedReactionId = new StreamController.broadcast();
      streamExpiredReactions = StreamController.broadcast();
      expiredReactionsListener = StreamController.broadcast();
      addDataController = new StreamController.broadcast();
      removeDataController = new StreamController.broadcast();

      updateDataController = new StreamController.broadcast();

      listenerInitialized = false;
      reactionsAverage = 0;
      coins = 0;
      var result = reactionRepository.clearModuleData();
      return result;
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  bool checkIfReactionCanShowAds(String reactionId) {
    bool canShowAds = true;
    for (int i = 0; i < reactions.length; i++) {
      if (reactions[i].idReaction == reactionId) {
        canShowAds = reactions[i].canShowAds;
      }
    }
    return canShowAds;
  }

  void _reactionDataProcessing(Map<String, dynamic> event) {
    Reaction reaction = event["reaction"];
    bool isDeleted = event["deleted"];
    bool notify = event["notify"];
    bool isModified = event["modified"];

    if (isDeleted == false) {
      if (isModified == false) {
        reaction.reactionExpiredId = this.expiredReactionsListener;
        reactions.add(reaction);
        addDataController?.add(ReactionInformationSender(
            index: null,
            reaction: reaction,
            reactionAverage: reactionsAverage,
            isPremium: isPremium,
            notify: notify,
            sync: false,
            isModified: isModified,
            isDeleted: isDeleted,
            coins: coins));
      }
      if (isModified == true) {
        for (int i = 0; i < reactions.length; i++) {
          if (reactions[i].idReaction == reaction.idReaction) {
            if (reaction.revealed == false) {
              reactions[i].userBlocked = reaction.userBlocked;
            }
            if (reaction.revealed == true) {
              reactions[i].userBlocked = reaction.userBlocked;

              reactions[i].setName = reaction.getName;
              reactions[i].imageHash = reaction.imageHash;
              reactions[i].imageUrl = reaction.imageUrl;
              reactions[i].setReactionRevealigState =
                  ReactionRevealigState.revealed;
            }
          }
        }
      }
    } else {
      if (reactions.isNotEmpty == true) {
        int index = reactions
            .indexWhere((element) => element.idReaction == reaction.idReaction);
        if (index >= 0) {
          reactions.removeAt(index);

          removeDataController?.add(ReactionInformationSender(
              index: index,
              reaction: reaction,
              reactionAverage: reactionsAverage,
              isPremium: isPremium,
              notify: notify,
              sync: false,
              isModified: isModified,
              isDeleted: isDeleted,
              coins: coins));
        }
      }
    }

    sendReactionData();
  }

  void initReactionStream() {
    reactionSubscription =
        reactionRepository.streamParserController?.stream.listen((event) {
      String payloadType = event["payloadType"];

      if (payloadType == "reaction") {
        _reactionDataProcessing(event);
      } else {
        _additionalDataProcessing(event);
      }
    }, onError: (error) {
      addDataController?.addError(error);
    });
  }

  void initializeExpiredTimeListener() {
    expiredReactionSubscription =
        this.expiredReactionsListener.stream.listen((event) {
      int reactionIndex = reactions
          .indexWhere((element) => element.idReaction == event.idReaction);

      reactions.removeAt(reactionIndex);

      streamExpiredReactions.add({"index": reactionIndex, "reaction": event});
      removeDataController?.add(ReactionInformationSender(
          index: reactionIndex,
          isPremium: isPremium,
          reaction: event,
          reactionAverage: this.reactionsAverage,
          notify: false,
          sync: false,
          isModified: false,
          isDeleted: true,
          coins: coins));
      sendReactionData();
    }, onError: (error) {
      removeDataController?.addError(error);
    });
  }

  void _additionalDataProcessing(Map<String, dynamic> event) {
    try {
      reactionsAverage = event["reactionsAverage"];
      coins = event["coins"];
      isPremium = event["isPremium"];

      updateDataController?.add(ReactionInformationSender(
          reaction: null,
          reactionAverage: reactionsAverage,
          sync: false,
          notify: false,
          isModified: null,
          isPremium: isPremium,
          isDeleted: null,
          coins: coins,
          index: null));
      sendReactionData();
    } catch (e) {
      updateDataController?.addError(e);
    }
  }

  void syncReactions() {
    for (int i = 0; i < reactions.length; i++) {
      reactions[i].resyncReaction();
    }
  }

  Future<Either<Failure, void>> revealReaction(
      {required String reactionId}) async {
    syncReactions();

    for (int i = 0; i < this.reactions.length; i++) {
      if (this.reactions[i].idReaction == reactionId &&
          this.reactions[i].secondsUntilExpiration > 0) {
        this.reactions[i].setReactionRevealigState =
            ReactionRevealigState.revealing;
        updateDataController?.add(ReactionInformationSender(
            isPremium: isPremium,
            notify: false,
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
          this.reactions[i].canShowAds = false;
          updateDataController?.add(ReactionInformationSender(
              sync: false,
              isPremium: isPremium,
              notify: false,
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

  Future<Either<Failure, bool>> acceptReaction(
      {required String reactionId, required String reactionSenderId}) async {
    syncReactions();

    for (int i = 0; i < this.reactions.length; i++) {
      if (this.reactions[i].idReaction == reactionId) {
        this.reactions[i].setReactionAceptingState =
            ReactionAceptingState.inProcessAcepting;
        updateDataController?.add(ReactionInformationSender(
            reaction: null,
            reactionAverage: reactionsAverage,
            isPremium: isPremium,
            notify: false,
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
          updateDataController?.add(ReactionInformationSender(
              reaction: null,
              reactionAverage: reactionsAverage,
              isPremium: isPremium,
              notify: false,
              sync: false,
              isModified: null,
              isDeleted: null,
              coins: coins,
              index: null));
        }
      }
    }, (r) {});

    return result;
  }

  Future<Either<Failure, bool>> rejectReaction(
      {required String reactionId}) async {
    syncReactions();
    for (int i = 0; i < this.reactions.length; i++) {
      if (this.reactions[i].idReaction == reactionId) {
        this.reactions[i].setReactionAceptingState =
            ReactionAceptingState.inProcessDeclining;
        updateDataController?.add(ReactionInformationSender(
            reaction: null,
            reactionAverage: reactionsAverage,
            sync: false,
            isModified: null,
            isPremium: isPremium,
            notify: false,
            isDeleted: null,
            coins: coins,
            index: null));

        break;
      }
    }

    Either<Failure, bool> result =
        await reactionRepository.rejectReaction(reactionId: reactionId);

    result.fold((l) {
      updateDataController?.add(ReactionInformationSender(
          reaction: null,
          reactionAverage: reactionsAverage,
          sync: false,
          isModified: null,
          isDeleted: null,
          isPremium: isPremium,
          notify: false,
          coins: coins,
          index: null));
    }, (r) {
      for (int i = 0; i < reactions.length; i++) {
        if (reactions[i].idReaction == reactionId) {}
      }
    });
    return result;
  }

  void sendReactionData() {
    homeScreencontrollerbridge.addInformation(
        information: {"header": "reaction", "data": reactions.length});
  }
}
