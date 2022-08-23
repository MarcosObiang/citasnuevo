import 'dart:convert';

import 'package:equatable/equatable.dart';

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

  UserSettingsFailure copyWith({
    String? message,
  }) {
    return UserSettingsFailure(
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
    };
  }

  factory UserSettingsFailure.fromMap(Map<String, dynamic> map) {
    return UserSettingsFailure(
      message: map['message'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSettingsFailure.fromJson(String source) =>
      UserSettingsFailure.fromMap(json.decode(source));

  @override
  String toString() => 'UserSettingsFailure(message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettingsFailure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
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
