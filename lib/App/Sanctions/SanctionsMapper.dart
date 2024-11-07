import 'SanctionsEntity.dart';

class SanctionMapper {
  static SanctionsEntity fromMap(Map<String, dynamic> data) {
    late PenalizationState penalizationState;
    if (data["penalizationState"] ==
        PenalizationState.IN_MODERATION_WAITING.name) {
      penalizationState = PenalizationState.IN_MODERATION_WAITING;
    }
    if (data["penalizationState"] ==
        PenalizationState.IN_MODERATION_DONE.name) {
      penalizationState = PenalizationState.IN_MODERATION_DONE;
    }
    if (data["penalizationState"] == PenalizationState.NOT_PENALIZED.name) {
      penalizationState = PenalizationState.NOT_PENALIZED;
    }
    if (data["penalizationState"] == PenalizationState.PENALIZED.name) {
      penalizationState = PenalizationState.PENALIZED;
    }

    return SanctionsEntity(
        sanctionTimeStamp: data["penalizationEndDate"],
        penalizationState: penalizationState);
  }
}
