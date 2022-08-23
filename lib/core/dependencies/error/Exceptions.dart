const kNetworkErrorMessage= "NETWORK_ERROR";


class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
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
  FetchProfilesException({
    required this.message,
  }) {
    print(message);
  }
}

class ReactionException implements Exception {
  String message;
  StackTrace stackTrace;
  ReactionException({required this.message, required this.stackTrace}) {
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

class UserCreatorException implements Exception {
  String message;
  UserCreatorException({
    required this.message,
  }) {
    print(message);
  }
}

class RewardException implements Exception {
  String message;
  RewardException({
    required this.message,
  }) {
    print(message);
  }
}

class LocationServiceException implements Exception {
  String message;
  LocationServiceException({
    required this.message,
  }) {
    print(message);
  }
}

class InitException implements Exception {
  String message;
  InitException({
    required this.message,
  }) {
    print(message);
  }
}
class SanctionException implements Exception {
  String message;
  SanctionException({
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
