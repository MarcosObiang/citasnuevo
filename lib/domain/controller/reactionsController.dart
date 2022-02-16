import 'dart:async';

import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:citasnuevo/domain/repository/reactionRepository/reactionRepository.dart';
import 'package:dartz/dartz.dart';

import '../../core/dependencies/error/Failure.dart';

class ReactionsController {
  List<Reaction> reactions = [];
  double reactionsAverage = 0;
  bool listenerInitialized = false;
  int coins = 0;
  StreamController<Reaction> expiredReactionsListener =
      StreamController.broadcast();
  StreamController<Map<String, dynamic>> streamExpiredReactions =
      StreamController.broadcast();

  ReactionRepository reactionRepository;
  ReactionsController({
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

  Future<Either<Failure, bool>> initializeReactionListener() async {
    initReactionStream();
    initializeExpiredTimeListener();
    return reactionRepository.initializeReactionListener();
  }

  void initReactionStream() {
    var data = reactionRepository.getAdditionalValues();
    var madata;

    data.fold((failure) => null, (succes) => madata = succes);

    coins = madata["coins"];
    reactionsAverage = madata["averageReactions"];
    reactionRepository.reactionListener.stream.listen((event) {
      bool isModified = event["modified"];
      Reaction reaction = event["reaction"];
      if (isModified == false) {
        reaction.reactionExpiredId = this.expiredReactionsListener;
        reactions.add(reaction);
      } else {
        for (int i = 0; i < reactions.length; i++) {
          if (reactions[i].idReaction == reaction.idReaction) {
            reactions[i].setReactionRevealigState =
                ReactionRevealigState.revealed;
            reactions[i].setName = reaction.getName;
            reactions[i].imageHash = reaction.imageHash;
            reactions[i].imageUrl = reaction.imageUrl;
          }
        }
      }
    });
  }

  void initializeExpiredTimeListener() {
    this.expiredReactionsListener.stream.listen((event) {
      int reactionIndex = reactions
          .indexWhere((element) => element.idReaction == event.idReaction);

      reactions.removeAt(reactionIndex);

      streamExpiredReactions.add({"index": reactionIndex, "reaction": event});
    });
  }

  void initCoinListener() {
    reactionRepository.reactionDataSource.additionalDataSender.stream
        .listen((event) {
      reactionsAverage = event["reactionsAverage"];
      coins = event["coins"];
    });
  }

  Future<Either<Failure, void>> revealReaction(
      {required String reactionId}) async {
    return await reactionRepository.revealReaction(reactionId: reactionId);
  }

  Future<Either<Failure, bool>> acceptReaction(
      {required String reactionId, required String reactionSenderId}) async {
    for (int i = 0; i < reactions.length; i++) {
      if (reactions[i].idReaction == reactionId) {
        reactions[i].setReactionAceptingState = ReactionAceptingState.inProcess;
      }
    }

    Either<Failure, bool> result = await reactionRepository.acceptReaction(
        reactionId: reactionId, reactionSenderId: reactionSenderId);

    result.fold((l) {
      for (int i = 0; i < reactions.length; i++) {
        if (reactions[i].idReaction == reactionId) {
          reactions[i].setReactionAceptingState = ReactionAceptingState.error;
        }
      }
    }, (r) {
      for (int i = 0; i < reactions.length; i++) {
        if (reactions[i].idReaction == reactionId) {
          reactions[i].setReactionAceptingState = ReactionAceptingState.done;
          Reaction reaction = reactions.removeAt(i);

          streamExpiredReactions.add({"index": i, "reaction": reaction});
        }
      }
    });

    return result;
  }

  Future<Either<Failure, bool>> rejectReaction(
      {required String reactionId}) async {
    Either<Failure, bool> result =
        await reactionRepository.rejectReaction(reactionId: reactionId);

    result.fold((l) {}, (r) {
      for (int i = 0; i < reactions.length; i++) {
        if (reactions[i].idReaction == reactionId) {
          reactions[i].setReactionAceptingState = ReactionAceptingState.done;

          Reaction reaction = reactions.removeAt(i);

          streamExpiredReactions.add({"index": i, "reaction": reaction});
        }
      }
    });
    return result;
  }

  void closeStreams() {
    expiredReactionsListener.close();
    streamExpiredReactions.close();
    streamRevealedReactionId.close();
  }
}
