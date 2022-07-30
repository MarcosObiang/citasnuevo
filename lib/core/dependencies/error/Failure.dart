import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  const Failure([List properties = const <dynamic>[]]) : super();
}

class GenericModuleFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class ServerFailure extends Failure {
  @override
  ServerFailure() : super();
  @override
  List<Object?> get props => [];
}

class NetworkFailure extends Failure {
  @override
  NetworkFailure() : super();
  @override
  List<Object?> get props => [];
}

class AuthFailure extends Failure {
  @override
  AuthFailure() : super();
  @override
  List<Object?> get props => [];
}

class ApplicationStateFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class FetchUserFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
    String message;
  FetchUserFailure({
    required this.message,
  });
}

class RatingProfilesFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class ReportFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class RewardFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class ReactionFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}
class ChatFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class SettingsFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}
class AppSettingsFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class UserSettingsFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}


class UserCreatorFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class LocationServiceFailure extends Failure {
  @override
  List<Object?> get props => throw UnimplementedError();
  String message;
  LocationServiceFailure({
    required this.message,
  });
}

