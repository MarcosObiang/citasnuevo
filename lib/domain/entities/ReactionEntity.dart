import 'dart:async';

enum ReactionRevealigState { notRevealed, revealed, revealing, error }
enum ReactionAceptingState { done, inProcess, notAccepted, error }
enum ReactionDeclineState { done, inProcess, notDeclined, error }

class Reaction {
  int age;
  int secondsUntilExpiration = 0;
  int reactionExpirationDateInSeconds;
  bool stopCounter = false;
  bool revealingProcessStarted = false;
  double reactioValue;
  String imageHash;
  String imageUrl;
  String name;
  String idReaction;
  String senderId;
  ReactionRevealigState reactionRevealigState;
  ReactionAceptingState reactionAceptingState =
      ReactionAceptingState.notAccepted;
  ReactionDeclineState reactionDeclineState = ReactionDeclineState.notDeclined;
  get getReactionAceptingState => this.reactionAceptingState;

  set setReactionAceptingState(reactionAceptingState) {
    this.reactionAceptingState = reactionAceptingState;
    reactionRevealedStateStream.add(this.reactionAceptingState);
  }

  get getReactionDeclineState => this.reactionDeclineState;

  set setReactionDeclineState(reactionDeclineState) {
    this.reactionDeclineState = reactionDeclineState;
    reactionRevealedStateStream.add(this.reactionDeclineState);
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
    if (reactionRevealigState == ReactionRevealigState.revealed &&
        this.reactionRevealigState != ReactionRevealigState.revealed) {
      this.reactionRevealigState = reactionRevealigState;
      reactionRevealedStateStream.add(this.reactionRevealigState);
    }
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
      required this.reactionRevealigState}) {
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
        if (this.secondsUntilExpiration == 1) {
          this.reactionExpiredId.add(this);

          closeSecondsRemainingStream();
          reactionTimer.cancel();
        }
      });
    }
  }
}
