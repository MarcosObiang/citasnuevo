class ServerException implements Exception {
    final String message;
  ServerException({required this.message});
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
}

class NetworkException implements Exception {
  NetworkException();
}

class ApplicationStateException implements Exception {
    final String message;
  ApplicationStateException({required this.message});
}

class RatingProfilesException implements Exception {
    final String message;
  RatingProfilesException({required this.message});
}

class FetchProfilesException implements Exception {
  String message;
  FetchProfilesException({
    required this.message,
  }) {
    print(message);
  }
}

class ReactionException implements Exception {
  String message;
  StackTrace stackTrace;
  ReactionException({
    required this.message,
    required this.stackTrace
  }) {
    print(message);
  }
}

class ReportException implements Exception {
  String message;
  ReportException({
    required this.message,
  }) {
    print(message);
  }
}
class ChatException implements Exception {
  String message;
  ChatException({
    required this.message,
  }) {
    print(message);
  }
}

class SettingsException implements Exception {
  String message;
  SettingsException({
    required this.message,
  }) {
    print(message);
  }
}
class AppSettingsException implements Exception {
  String message;
  AppSettingsException({
    required this.message,
  }) {
    print(message);
  }
}

class UserSettingsException implements Exception {
  String message;
  UserSettingsException({
    required this.message,
  }) {
    print(message);
  }
}