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
    this._googleSignIn = new GoogleSignIn();
    late UserCredential userCredential;
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleSignInAccount.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        throw AuthException(message: "GOOGLE_SIGN_IN_ACCOUNT_IS_NULL");
      }
    } catch (e, s) {
      print(e);
      print(s);
      throw AuthException(message: e.toString());
    }
    GlobalDataContainer.userId = userCredential.user!.uid;
    GlobalDataContainer.userName = userCredential.user!.displayName;

    return {
      "userId": userCredential.user?.uid,
      "email": userCredential.user?.email
    };
  }

  @override
  Future<Map<String, dynamic>> userAlreadySignedIn() async {
    this._googleSignIn = new GoogleSignIn();

    FirebaseAuth? user = FirebaseAuth.instance;

    if (user.currentUser != null) {
      GlobalDataContainer.userId = user.currentUser!.uid;
          GlobalDataContainer.userName = user.currentUser!.displayName;


      return {
        "userId": user.currentUser?.uid,
        "email": user.currentUser?.email,
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
      FirebaseAuth user = FirebaseAuth.instance;

      await user.signOut().then((value) async {
        await this._googleSignIn.signOut();
      });

      return {"status": "OK"};
    } catch (e) {
      print("object");

      throw AuthException(message: e.toString());
    }
  }
}
