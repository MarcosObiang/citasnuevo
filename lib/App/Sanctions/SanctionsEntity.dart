import 'dart:async';

enum PenalizationState {
  NOT_PENALIZED,
  IN_MODERATION_WAITING,
  PENALIZED,
  IN_MODERATION_DONE
}
class SanctionsEntity {
  int sanctionTimeStamp;
  int timeRemaining = 0;
  PenalizationState penalizationState;
  Timer? sanctionTimer;

  StreamController<int> sanctionStreamController = StreamController.broadcast();

  SanctionsEntity(
      {required this.sanctionTimeStamp, required this.penalizationState});

  /// Starts the sanction timer.
  ///
  ///
  /// Once a [SanctionEntity] had been created, this function will be called to start the its countdown
  ///
  /// The function requires the most up to date timestamp in milliseconds since epoch to calculate the actual time difference in milliseconds
  /// between the sanction limit and now

  void sanctionTimerStart({required int actualTimeInMilliseconds}) {
    if (penalizationState == PenalizationState.PENALIZED &&
        sanctionTimeStamp > 0) {
      timeRemaining = (this.sanctionTimeStamp - actualTimeInMilliseconds);
      if (timeRemaining > 0) {
        sanctionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (timeRemaining <= 1) {
            sanctionTimer?.cancel();
          }
          if (timeRemaining > 1) {
            timeRemaining = timeRemaining - 1000;
            sanctionStreamController.add(timeRemaining);
          }
        });
      }
    }
  }

  /// Correctly dispose the sanction entity
  ///
  /// Once the variable wich holds the [SanctionsEntity] is going to be set to [Null], it needs to be disposed first to avoid
  /// memory leaks

  void disposeSanctionObject() {
    sanctionStreamController.close();

    sanctionTimer?.cancel();
  }
}
