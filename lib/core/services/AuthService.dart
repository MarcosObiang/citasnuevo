import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
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
      final f = await Dependencies.serverAPi.account
          .createOAuth2Session(provider: OAuthProvider.google,scopes: [

      ]);
      final user = await Dependencies.serverAPi.account.get();

      GlobalDataContainer.userId = user.$id;
      GlobalDataContainer.userEmail = user.email ?? "";
      GlobalDataContainer.userName = user.name ?? "";
      Dependencies.applicationDataSource.setUserId(user.$id);
      bool userDataExists =
          await Dependencies.applicationDataSource.checkIfUserModelExists();
      if (userDataExists) {
        await Dependencies.applicationDataSource.initializeMainDataSource();
      }
      return {
        "status": "SIGNED_IN",
        "userId": user.$id,
        "email": user.email,
        "userName": user.name,
        "userDataExists": userDataExists
      };
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
      final session = await Dependencies.serverAPi.account.getSession(
        sessionId: "current",
      );
      final user;

   

      if (session.current) {
       User user= await Dependencies.serverAPi.account.get();
        GlobalDataContainer.userId = user.$id;
        GlobalDataContainer.userEmail = user.email ?? "";
        GlobalDataContainer.userName = user.name ?? "";
        Dependencies.applicationDataSource.setUserId(user.$id);
        bool userDataExists =
            await Dependencies.applicationDataSource.checkIfUserModelExists();
        if (userDataExists) {
          await Dependencies.applicationDataSource.initializeMainDataSource();
        }

        return {
          "status": "SIGNED_IN",
          "userId": user.$id,
          "email": user.email,
          "userName": user.name,
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
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> logOut() async {
    try {
      
      await Dependencies.serverAPi.account.deleteSession(sessionId: "current");

      Dependencies.clearDependenciesAndUserIdentifiers();

      return {"status": "OK"};
    } catch (e) {
      throw AuthException(message: "${e.toString()}");
    }
  }
}
