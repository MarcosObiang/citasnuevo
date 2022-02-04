import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:citasnuevo/core/firebase_services/firebase_app.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
abstract class AuthenticationContract {
  Future<Map<String, dynamic>> logUserFromGoogle();
  Future<Map<String, dynamic>> logUserFromFacebook();
  Future<Map<String, dynamic>> userAlreadySignedIn();}
class AuthenticationImpl implements AuthenticationContract {
  /// We log the user with his facebook account and we return a Map wich contains the user id and the email.
  ///
  /// Throws [NetworkException] if there is no connection
  ///
  /// Throws [AuthException] if there is some problem while authenticating
  ///
  @override
  Future<Map<String, dynamic>> logUserFromFacebook() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
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
        return {
          "userId": userCredential.user!.uid,
          "email": userCredential.user!.email
        };
      } on Exception {
        throw AuthException();
      }
    } else {
      throw NetworkException();
    }
  }
  /// We log the user with his google account and we return a Map wich contains the user id and the email.
  ///
  /// Throws [NetworkException] if there is no connection
  ///
  /// Throws [AuthException] if there is some problem while authenticating
  ///
  @override
  Future<Map<String, dynamic>> logUserFromGoogle() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      late UserCredential userCredential;
      try {
        final GoogleSignInAccount? googleSignInAccount =
            await GoogleSignIn().signIn();
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
          throw AuthException();
        }
      } catch (e,s) {
        print(e);
        print(s);
        throw AuthException();
      }
        GlobalDataContainer.userId = userCredential.user!.uid;
      return {
        "userId": userCredential.user?.uid,
        "email": userCredential.user?.email
      };
    } else {
      throw NetworkException();
    }
  }
  @override
  Future<Map<String, dynamic>> userAlreadySignedIn() async {
    FirebaseAuth? user = FirebaseAuth.instance;
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      if (user.currentUser != null) {
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
    else{
      throw NetworkException();
    }
  }}