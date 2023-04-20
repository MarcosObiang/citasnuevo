import 'VerificationTicketEntity.dart';

class VerificationTIcketMapper {
  static VerificationTicketEntity fromMap(
      {required Map<String, dynamic> data}) {
    late VerificationProcessStatus verificationProcessStatus;
    String verificationStatus = data["verificationStatus"];
    if (verificationStatus ==
        VerificationProcessStatus.VERIFICATION_INITIALIZED.name) {
      verificationProcessStatus =
          VerificationProcessStatus.VERIFICATION_INITIALIZED;
    }
    if (verificationStatus ==
        VerificationProcessStatus.VERIFICATION_NOT_INITIALIZED.name) {
      verificationProcessStatus =
          VerificationProcessStatus.VERIFICATION_NOT_INITIALIZED;
    }
    if (verificationStatus ==
        VerificationProcessStatus.VERIFICATION_NOT_SUCCESFULL.name) {
      verificationProcessStatus =
          VerificationProcessStatus.VERIFICATION_NOT_SUCCESFULL;
    }
    if (verificationStatus ==
        VerificationProcessStatus.VERIFICATION_SUCCESFULL.name) {
      verificationProcessStatus =
          VerificationProcessStatus.VERIFICATION_SUCCESFULL;
    }
    if (verificationStatus ==
        VerificationProcessStatus.VERIFICATION_WAITING_MODERATION.name) {
      verificationProcessStatus =
          VerificationProcessStatus.VERIFICATION_WAITING_MODERATION;
    }

    return VerificationTicketEntity(
      handGesture: data["imageExpectedHandGesture"],
      verified: verificationProcessStatus ==
              VerificationProcessStatus.VERIFICATION_SUCCESFULL
          ? true
          : false,
      isFemale: false,
      verificationProcessStatus: verificationProcessStatus,
    );
  }

  static Map<String, dynamic> toMap(
      {required VerificationTicketEntity verificationTicketEntity}) {
    return {
      "handGesture": verificationTicketEntity.handGesture,
      "verified": verificationTicketEntity.verified,
      "verificationProcessStatus":
          verificationTicketEntity.verificationProcessStatus.name
    };
  }
}
