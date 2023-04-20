enum VerificationProcessStatus {
  // ignore: constant_identifier_names
  VERIFICATION_NOT_INITIALIZED,
  VERIFICATION_INITIALIZED,

  VERIFICATION_WAITING_MODERATION,
  VERIFICATION_NOT_SUCCESFULL,
  VERIFICATION_SUCCESFULL
}

class VerificationTicketEntity {
  String handGesture;
  bool verified;
  VerificationProcessStatus verificationProcessStatus;
  bool isFemale;
  VerificationTicketEntity({
    required this.handGesture,
    required this.verified,
    required this.verificationProcessStatus,
    required this.isFemale,
  });
}
