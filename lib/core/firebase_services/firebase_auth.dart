import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:citasnuevo/core/globalData.dart';

abstract class AuthService {
  Future<Map<String, dynamic>> logUserFromGoogle();
  Future<Map<String, dynamic>> logUserFromFacebook();
  Future<Map<String, dynamic>> userAlreadySignedIn();
  Future<Map<String, dynamic>> logOut();
}

class AuthServiceImpl implements AuthService {
  late GoogleSignIn _googleSignIn = new GoogleSignIn();

  /// We log the user with his facebook account and we return a Map wich contains the user id and the email.
  ///
  ///
  /// Throws [AuthException] if there is some problem while authenticating
  ///
  @override
  Future<Map<String, dynamic>> logUserFromFacebook() async {
    late UserCredential userCredential;
    // Trigger the sign-in flow
    try {
      final LoginResult loginResult =
          await FacebookAuth.instance.login(permissions: ["email"]);
      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);
      // Once signed in, return the UserCredential
      userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
      GlobalDataContainer.userId = userCredential.user!.uid;
      GlobalDataContainer.userName = userCredential.user!.displayName;

      return {
        "userId": userCredential.user!.uid,
        "email": userCredential.user!.email
      };
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  /// We log the user with his google account and we return a Map wich contains the user id and the email.
  ///
  ///
  /// Throws [AuthException] if there is some problem while authenticating
  ///
  @override
  Future<Map<String, dynamic>> logUserFromGoogle() async {
    try {

      await Dependencies.serverAPi.account
          ?.createOAuth2Session(provider: "google", success: "", failure: "");

      var userData = await Dependencies.serverAPi.account?.get();

      if (userData != null) {
        GlobalDataContainer.userId = userData.$id;
        GlobalDataContainer.userName = userData.name;
        GlobalDataContainer.userEmail = userData.email;

        return {
          "userId": userData.$id,
          "email": userData.$id,
        };
      } else {
        return {
          "userId": "unknown",
          "email": "unknown",
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
    var userData = await Dependencies.serverAPi.account?.get();

    this._googleSignIn = new GoogleSignIn();

    if (userData != null) {
      GlobalDataContainer.userId = userData.$id;
      GlobalDataContainer.userName = userData.name;

      return {
        "userId": userData.$id,
        "email": userData.$id,
      };
    } else {
      return {
        "userId": "unknown",
        "email": "unknown",
      };
    }
  }

  @override
  Future<Map<String, dynamic>> logOut() async {
    try {
      await Dependencies.serverAPi.account?.deleteSessions();

      return {"status": "OK"};
    } on AppwriteException {
      print("object");

      throw AuthException(message: "e.toString()");
    }
  }
}
