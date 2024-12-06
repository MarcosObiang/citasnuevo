import 'dart:async';


enum ReactionRevealigState { notRevealed, revealed, revealing, error }

enum ReactionAceptingState {
  done,
  inProcessAcepting,
  inProcessDeclining,
  notAccepted,
  error
}

class Reaction {
  int age;
  int secondsUntilExpiration = 0;
  int reactionExpirationDateInSeconds;
  bool stopCounter = false;
  bool revealingProcessStarted = false;
  bool canShowAds = true;
  bool userBlocked = false;
  int reactionValue;
  String imageHash;
  Map<String, dynamic> imageUrl;
  String name;
  String idReaction;
  String senderId;
  bool revealed;
  ReactionRevealigState reactionRevealigState;
  ReactionAceptingState reactionAceptingState =
      ReactionAceptingState.notAccepted;
  get getReactionAceptingState => this.reactionAceptingState;

  set setReactionAceptingState(reactionAceptingState) {
    this.reactionAceptingState = reactionAceptingState;
    reactionRevealedStateStream.add(this.reactionAceptingState);
  }


  get getReactionRevealigState => this.reactionRevealigState;

  set setReactionRevealigState(reactionRevealigState) {
    this.reactionRevealigState = reactionRevealigState;
    reactionRevealedStateStream.add(this.reactionRevealigState);
  }

  StreamController<dynamic> reactionRevealedStateStream =
      new StreamController.broadcast();
  StreamController<int> secondsRemainingStream =
      new StreamController.broadcast();
  // ignore: close_sinks
  late StreamController<Reaction> reactionExpiredId;

  Reaction(
      {required this.age,
      required this.senderId,
      required this.reactionExpirationDateInSeconds,
      required this.imageHash,
      required this.imageUrl,
      required this.name,
      required this.idReaction,
      required this.reactionRevealigState,
      required this.userBlocked,
      required this.revealed,
      required this.reactionValue
      
      }) {
    this.getExpirationSeconds();
  }

  void getExpirationSeconds() {
    this.secondsUntilExpiration = reactionExpirationDateInSeconds -
        DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (this.secondsUntilExpiration > 86400) {
      this.secondsUntilExpiration = 86400;
    }
    if (this.secondsUntilExpiration > 0) {
      startReactionCounter();
    }
  }

  /// Resynchronizes the reaction's expiration date by updating
  /// [secondsUntilExpiration] field.
  void resyncReaction() {
    this.secondsUntilExpiration = reactionExpirationDateInSeconds -
        DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (this.secondsUntilExpiration > 86400) {
      this.secondsUntilExpiration = 86400;
    }
  }

  void closeSecondsRemainingStream() {
    if (secondsRemainingStream.isClosed == false) {
      secondsRemainingStream.close();
    }
  }

  void startReactionCounter() {
    late Timer reactionTimer;

    if (this.reactionExpirationDateInSeconds > 0 &&
        this.reactionRevealigState == ReactionRevealigState.notRevealed &&
        secondsRemainingStream.isClosed == false) {
      reactionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (this.secondsUntilExpiration > 0 &&
            this.reactionRevealigState == ReactionRevealigState.notRevealed &&
            secondsRemainingStream.isClosed == false) {
          this.secondsUntilExpiration = this.secondsUntilExpiration - 1;
          secondsRemainingStream.add(this.secondsUntilExpiration);
        }

        if (this.reactionRevealigState == ReactionRevealigState.revealed) {
          closeSecondsRemainingStream();
          reactionTimer.cancel();
        }
        if (this.secondsUntilExpiration <= 1 &&
            reactionTimer.isActive == true &&
            secondsRemainingStream.isClosed == false) {
          reactionTimer.cancel();

          this.reactionExpiredId.add(this);

          closeSecondsRemainingStream();
        }
      });
    }
  }
}
