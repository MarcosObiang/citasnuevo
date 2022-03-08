import 'package:equatable/equatable.dart';


const kNotAvailable="NOT_AVAILABLE";



class Params extends Equatable {
  const Params();
  @override
  // TODO: implement props
  List<Object> get props => [];
}



enum LoginType { facebook, google }
enum AuthState { notSignedIn, signingIn, error, succes }
enum ProfileListState { empty, loading, ready, error }
enum ReportSendingState { notSended, sending, sended, error }
enum ChatReportSendingState { notSended, sending, sended, error }



class GetUserParams extends Params {
  final LoginType loginType;
  const GetUserParams({required this.loginType});
}

class LoginParams extends Params {
  final LoginType loginType;
  const LoginParams({required this.loginType});
}

class RatingParams extends Params {
  final double rating;
  final String profileId;

  RatingParams({required this.rating, required this.profileId});
}

class ReportParams extends Params {
  final String idReporter;
  final String idUserReported;
  final String reportDetails;

  ReportParams(this.idReporter, this.idUserReported, this.reportDetails);
}
