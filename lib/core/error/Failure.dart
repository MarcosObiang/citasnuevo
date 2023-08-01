
abstract class Failure {
  late String message;
}

class GenericModuleFailure implements Failure {
  @override
  String message;
  GenericModuleFailure({
    required this.message,
  });
}

class ServerFailure implements Failure {
  @override
  String message;
  ServerFailure({
    required this.message,
  });
}

class NetworkFailure implements Failure {
  @override
  String message;
  NetworkFailure({
    required this.message,
  });
}

class PurchaseSystemFailure implements Failure {
  @override
  String message;
  PurchaseSystemFailure({
    required this.message,
  });
}

class AuthFailure implements Failure {
  @override
  String message;
  AuthFailure({
    required this.message,
  });
}

class ApplicationStateFailure implements Failure {
  @override
  String message;
  ApplicationStateFailure({
    required this.message,
  });
}

class FetchUserFailure implements Failure {
  @override
  String message;
  FetchUserFailure({
    required this.message,
  });
}

class RatingProfilesFailure implements Failure {
  @override
  String message;
  RatingProfilesFailure({
    required this.message,
  });
}

class ReportFailure implements Failure {
  @override
  String message;
  ReportFailure({
    required this.message,
  });
}

class RewardFailure implements Failure {
  @override
  String message;
  RewardFailure({
    required this.message,
  });
}

class ReactionFailure implements Failure {
  @override
  String message;
  ReactionFailure({
    required this.message,
  });
}

class ChatFailure implements Failure {
  @override
  String message;
  ChatFailure({
    required this.message,
  });
}

class SettingsFailure implements Failure {
  @override
  String message;
  SettingsFailure({
    required this.message,
  });
}

class AppSettingsFailure implements Failure {
  @override
  String message;
  AppSettingsFailure({
    required this.message,
  });
}

class UserSettingsFailure implements Failure {
  @override
  String message;
  UserSettingsFailure({
    required this.message,
  });
}

class UserCreatorFailure implements Failure {
  String message;
  @override
  UserCreatorFailure({
    required this.message,
  });
}

class SanctionFailure implements Failure {
  String message;
  SanctionFailure({
    required this.message,
  });
}

class LocationServiceFailure implements Failure {
  @override
  String message;
  LocationServiceFailure({
    required this.message,
  });
}

class MessagesFailure implements Failure {
  @override
  String message;
  MessagesFailure({
    required this.message,
  });
}

class VerificationFailure implements Failure {
  @override
  String message;
  VerificationFailure({
    required this.message,
  });
}

class ModuleInitializeFailure implements Failure {
  @override
  String message;
  ModuleInitializeFailure({
    required this.message,
  });
}

class ModuleClearFailure implements Failure {
  @override
  String message;
  ModuleClearFailure({
    required this.message,
  });
}

class BlindDateChatFailure implements Failure {
  @override
  String message;
  BlindDateChatFailure({
    required this.message,
  });
}
