import 'dart:async';

import '../ControllerBridges/HomeScreenCotrollerBridge.dart';
import 'reactionRepository.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/Failure.dart';
import '../DataManager.dart';
import '../controllerDef.dart';
import 'ReactionEntity.dart';

abstract class ReactionController
    implements
        ShouldControllerRemoveData<ReactionInformationSender>,
        ShouldControllerUpdateData<ReactionInformationSender>,
        ShouldControllerAddData<ReactionInformationSender>,
        ModuleCleanerController {
  ///Saves the reactions in a list
  late List<Reaction> reactions;

  ///The average of all the reactions recieevd by the user
  late int reactionsAverage;

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

  int reactionCount = 0;
  int totalReactionPoints = 0;
}

class ReactionsControllerImpl implements ReactionController {
  @override
  List<Reaction> reactions = [];
  @override
  int reactionsAverage = 0;
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

  StreamController<Map<String, dynamic>> streamExpiredReactions =
      StreamController.broadcast();

  HomeScreenControllerBridge homeScreencontrollerbridge;

  ReactionRepository reactionRepository;
  ReactionsControllerImpl(
      {required this.reactionRepository,
      required this.homeScreencontrollerbridge});

  StreamController<Map<String, dynamic>> get streamIdExpiredReactions =>
      this.streamExpiredReactions;

  StreamController<Map<String, dynamic>> get rewardedAdvertismentStateStream =>
      this.reactionRepository.rewardedStatusListener;

  StreamController<String> streamRevealedReactionId =
      new StreamController.broadcast();

  StreamSubscription? coinsStreamSubscription;
  StreamSubscription? reactionSubscription;
  StreamSubscription? homeScreenControllerBridgeSubscription;

  ReactionType frequentReactionType = ReactionType.PASS;

  @override
  int reactionCount = 0;

  @override
  int totalReactionPoints = 0;
  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      initReactionStream();
      listenControllerBridgeSignal();
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

      streamExpiredReactions.close();
      streamRevealedReactionId.close();
      addDataController?.close();
      removeDataController?.close();
      updateDataController?.close();
      coinsStreamSubscription?.cancel();
      reactionSubscription?.cancel();
      streamRevealedReactionId = new StreamController.broadcast();
      streamExpiredReactions = StreamController.broadcast();
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
        if (reactions.indexWhere(
                (element) => element.idReaction == reaction.idReaction) ==
            -1) {
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
      }
      if (isModified == true) {
        for (int i = 0; i < reactions.length; i++) {
          if (reactions[i].idReaction == reaction.idReaction) {
            if (reaction.revealed == false) {
              reactions[i].userBlocked = reaction.userBlocked;
            }
            if (reaction.revealed == true) {
              reactions[i].userBlocked = reaction.userBlocked;
              reactions[i].reactionValue = reaction.reactionValue;

              reactions[i].name = reaction.name;
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

  Reaction? rejectReactionBySenderId(String senderId) {
    int index = reactions.indexWhere((element) => element.senderId == senderId);
    if (index >= 0) {
      return reactions[index];
    } else {
      return null;
    }
  }

  void listenControllerBridgeSignal() {
    homeScreenControllerBridgeSubscription = homeScreencontrollerbridge
        .controllerBridgeInformationSenderStream?.stream
        .listen((event) {
      if (event["header"] == "new_chat") {
        String senderId = event["data"];
        rejectReaction(
            reactionId: "", removeBySenderId: true, reactionSenderId: senderId);
      }
    });
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

  void _additionalDataProcessing(Map<String, dynamic> event) {
    try {
      reactionCount = event["reactionCount"];
      reactionsAverage = event["reactionAverage"];
      totalReactionPoints = event["totalReactionPoints"];

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
      {required String reactionId,required bool showAd}) async {
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
        await reactionRepository.revealReaction(reactionId: reactionId,showAd: showAd);

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
      {required String reactionId,
      required bool removeBySenderId,
      required String? reactionSenderId}) async {
    syncReactions();

    if (removeBySenderId == true) {
      String? result = rejectReactionBySenderId(reactionSenderId!)!.idReaction;
      if (result != null) {
        reactionId = result;
      } else {
        return Right(false);
      }
    }
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
      for (int i = 0; i < reactions.length; i++) {
        if (reactions[i].idReaction == reactionId) {
          this.reactions[i].setReactionAceptingState =
              ReactionAceptingState.error;
        }
      }
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

  Future<Either<Failure, bool>> showRewarded() async {
    return reactionRepository.showRewarded();
  }

  void closeAdsStreams() {
    reactionRepository.closeAdsStreams();
  }
}
