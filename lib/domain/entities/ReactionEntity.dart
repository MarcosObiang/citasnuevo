import 'dart:async';
import 'dart:ffi';

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
  bool canShowAds=true;
  bool userBlocked=false;
  double reactioValue;
  String imageHash;
  String imageUrl;
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

  get getAge => this.age;

  set setAge(age) => this.age = age;

  get getSecondsUntilExpiration => this.secondsUntilExpiration;

  set setSecondsUntilExpiration(secondsUntilExpiration) =>
      this.secondsUntilExpiration = secondsUntilExpiration;

  get getReactionExpirationDateInSeconds =>
      this.reactionExpirationDateInSeconds;

  set setReactionExpirationDateInSeconds(reactionExpirationDateInSeconds) =>
      this.reactionExpirationDateInSeconds = reactionExpirationDateInSeconds;

  get getStopCounter => this.stopCounter;

  set setStopCounter(stopCounter) => this.stopCounter = stopCounter;

  get getRevealingProcessStarted => this.revealingProcessStarted;

  set setRevealingProcessStarted(revealingProcessStarted) =>
      this.revealingProcessStarted = revealingProcessStarted;

  get getReactioValue => this.reactioValue;

  set setReactioValue(reactioValue) => this.reactioValue = reactioValue;

  get getImageHash => this.imageHash;

  set setImageHash(imageHash) => this.imageHash = imageHash;

  get getImageUrl => this.imageUrl;

  set setImageUrl(imageUrl) => this.imageUrl = imageUrl;

  get getName => this.name;

  set setName(name) => this.name = name;

  get getIdReaction => this.idReaction;

  set setIdReaction(idReaction) => this.idReaction = idReaction;

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
      required this.reactioValue,
      required this.imageHash,
      required this.imageUrl,
      required this.name,
      required this.idReaction,
      required this.reactionRevealigState,required this.userBlocked,required this.revealed}) {
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
        if (this.secondsUntilExpiration <=1 &&
            reactionTimer.isActive==true &&
            secondsRemainingStream.isClosed == false) {
          reactionTimer.cancel();

          this.reactionExpiredId.add(this);

          closeSecondsRemainingStream();
        }
      });
    }
  }
}
