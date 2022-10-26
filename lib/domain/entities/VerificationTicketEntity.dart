
import 'dart:io';
import 'dart:typed_data';

class VerificationTicketEntity {
  String handGesture;
  String verificationRequestId;
  bool verified;
  int verificationAttempts;
  String status;
  bool isFemale;
  VerificationTicketEntity({
    required this.handGesture,
    required this.verificationRequestId,
    required this.verified,
    required this.verificationAttempts,
    required this.status,
    required this.isFemale,
    
  });

}
