import 'package:equatable/equatable.dart';

const kNotAvailable = "NOT_AVAILABLE";
const kProfileNotReviewed = "PROFILE_NOT_REVIEWED";
const kProfileInReviewProcess = "PROFILE_IN_REVIEW_PROCESS";
const kProfileReviewedSuccesfully = "PROFILE_REVIEW_SUCCESFULL";
const kProfileRefiewedError = "PROFILE_REVIEW_ERROR";
const kStreamParserNullError="STREAM_PARSER_CONTROLLER_CANNOT_BE_NULL";
const kUserIdNullError="USER_ID_CANNOT_BE_NULL";
///Location
const kLocationServiceDisabled= "LOCATION_SERVICE_DISABLED";
const kLocationUnknownStatus= "UNABLE_TO_DETERMINE_LOCATION_STATUS";
const kLocationPermissionDenied= "LOCATION_PERMISSION_DENIED";
const kLocationPermissionDeniedForever= "LOCATION_PERMISSION_DENIED_FOREVER";
class Params extends Equatable {
  const Params();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

enum LoginType { facebook, google }

enum AuthState { notSignedIn, signingIn, error, succes }

enum ProfileListState {
  empty,
  loading,
  ready,
  error,
  location_denied,
  location_forever_denied,
  location_disabled,
  location_status_unknown,
  profile_not_visible
}

enum ReportSendingState { notSended, sending, sended, error }

enum ChatReportSendingState { notSended, sending, sended, error }

enum BlindDateChatReportSendingState{ notSended, sending, sended, error }

