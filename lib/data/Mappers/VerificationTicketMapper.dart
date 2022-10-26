import '../../domain/entities/VerificationTicketEntity.dart';

class VerificationTIcketMapper {
  static VerificationTicketEntity fromMap(
      {required Map<String, dynamic> data}) {
    return VerificationTicketEntity(
        handGesture: data["handGesture"],
        verificationRequestId: data["verificationTicketId"],
        verified: data["verified"],
        verificationAttempts: data["verificationAttempts"],
        isFemale: data["female"],
        status: data["status"],
     );
  }

  static Map<String, dynamic> toMap(
      {required VerificationTicketEntity verificationTicketEntity}) {
    return {
      "handGesture": verificationTicketEntity.handGesture,
      "verificationTicketId": verificationTicketEntity.verificationRequestId,
      "verified": verificationTicketEntity.verified,
      "verificationAttempts": verificationTicketEntity.verificationAttempts,
   "status":verificationTicketEntity.status
    };
  }
}
