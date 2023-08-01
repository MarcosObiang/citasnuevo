import 'package:appwrite/appwrite.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../App/controllerDef.dart';
import '../dependencies/dependencyCreator.dart';
import '../error/Exceptions.dart';
import '../globalData.dart';
import '../params_types/params_and_types.dart';

abstract class AuthService {
  Future<Map<String, dynamic>> logUser(
      {required SignInProviders signInProviders});
  Future<Map<String, dynamic>> userAlreadySignedIn();
  Future<Map<String, dynamic>> logOut();
}

class AuthServiceImpl implements AuthService {
  /// We log the user with his google account and we return a Map wich contains the user id and the email.
  ///
  ///
  /// Throws [AuthException] if there is some problem while authenticating
  ///
  @override
  Future<Map<String, dynamic>> logUser(
      {required SignInProviders signInProviders}) async {
    try {
      await Dependencies.serverAPi.account?.createOAuth2Session(
          provider: signInProviders.name, success: "", failure: "");

      var userData = await Dependencies.serverAPi.account?.get();

      if (userData != null) {
        GlobalDataContainer.userId = userData.$id;
        GlobalDataContainer.userEmail = userData.email;
        GlobalDataContainer.userName = userData.name;
        Dependencies.applicationDataSource.setUserId(userData.$id);
        bool userDataExists =
            await Dependencies.applicationDataSource.checkIfUserDataExists();
        if (userDataExists) {
          await Dependencies.applicationDataSource.initializeMainDataSource();
        }
        return {
          "status": "SIGNED_IN",
          "userId": userData.$id,
          "email": userData.email,
          "userName": userData.name,
          "userDataExists": userDataExists
        };
      } else {
        return {
          "status": "NOT_SIGNED_IN",
          "userId": kNotAvailable,
          "email": kNotAvailable,
          "userName": kNotAvailable,
          "userDataExists": false
        };
      }
    } catch (e) {
      if (e is AppwriteException) {
        throw Exception(e.message);
      } else {
        throw Exception(e.toString());
      }
    }
  }

  @override
  Future<Map<String, dynamic>> userAlreadySignedIn() async {
    try {
      var userData = await Dependencies.serverAPi.account?.get();

      if (userData != null) {
        GlobalDataContainer.userId = userData.$id;
        GlobalDataContainer.userEmail = userData.email;
        GlobalDataContainer.userName = userData.name;
        Dependencies.applicationDataSource.setUserId(userData.$id);
        bool userDataExists =
            await Dependencies.applicationDataSource.checkIfUserDataExists();
        if (userDataExists) {
          await Dependencies.applicationDataSource.initializeMainDataSource();
        }

        return {
          "status": "SIGNED_IN",
          "userId": userData.$id,
          "email": userData.email,
          "userName": userData.name,
          "userDataExists": userDataExists
        };
      } else {
        return {
          "status": "NOT_SIGNED_IN",
          "userId": kNotAvailable,
          "email": kNotAvailable,
          "userName": kNotAvailable,
          "userDataExists": false
        };
      }
    } catch (e) {
      if (e is AppwriteException) {
        if (e.message == "User (role: guests) missing scope (account)") {
          return {
            "status": "NOT_SIGNED_IN",
            "userId": kNotAvailable,
            "email": kNotAvailable,
            "userName": kNotAvailable,
            "userDataExists": false
          };
        } else {
          throw Exception(e.message);
        }
      } else {
        throw Exception(e.toString());
      }
    }
  }

  @override
  Future<Map<String, dynamic>> logOut() async {
    try {
      await Dependencies.serverAPi.account?.deleteSessions();

      return {"status": "OK"};
    } on AppwriteException {
      throw AuthException(message: "e.toString()");
    }
  }
}
