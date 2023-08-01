const kNetworkErrorMessage = "NETWORK_ERROR";

class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
  String toString() {
    return message;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
  @override
  String toString() {
    return message;
  }
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});
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
  @override
  String toString() {
    return message;
  }

  FetchProfilesException({
    required this.message,
  }) {
    print(message);
  }
}

class ReactionException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  ReactionException({required this.message}) {
    print(message);
  }
}

class BlindDateChatException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  BlindDateChatException({required this.message}) {
    print(message);
  }
}

class ReportException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  ReportException({
    required this.message,
  }) {
    print(message);
  }
}

class ChatException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  ChatException({
    required this.message,
  }) {
    print(message);
  }
}

class SettingsException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  @override
  SettingsException({
    required this.message,
  }) {
    print(message);
  }
}

class AppSettingsException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  AppSettingsException({
    required this.message,
  }) {
    print(message);
  }
}

class UserSettingsException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  UserSettingsException({
    required this.message,
  }) {
    print(message);
  }
}

class UserCreatorException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  UserCreatorException({
    required this.message,
  }) {
    print(message);
  }
}

class RewardException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  RewardException({
    required this.message,
  }) {
    print(message);
  }
}

class LocationServiceException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  LocationServiceException({
    required this.message,
  }) {
    print(message);
  }
}

class InitException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  InitException({
    required this.message,
  }) {
    print(message);
  }
}

class SanctionException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  SanctionException({
    required this.message,
  }) {
    print(message);
  }
}

class MessagesException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  MessagesException({
    required this.message,
  }) {
    print(message);
  }
}

class ModuleInitializeException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  ModuleInitializeException({
    required this.message,
  }) {
    print(message);
  }
}

class ModuleCleanException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  ModuleCleanException({
    required this.message,
  }) {
    print(message);
  }
}

class VerificationException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  VerificationException({
    required this.message,
  }) {
    print(message);
  }
}

class PurchaseSystemException implements Exception {
  String message;
  @override
  String toString() {
    return message;
  }

  PurchaseSystemException({
    required this.message,
  }) {
    print(message);
  }
}

class LateInitErrorChecker {
  /// Used to check if the error is caused due to not initialized variables in the code
  static bool isInitError({required dynamic e}) {
    if (e is Error) {
      String errorMessage = e.toString();
      if (errorMessage.contains("has not been initialized")) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
