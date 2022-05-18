import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';

import 'package:citasnuevo/core/firebase_services/firebase_app.dart';
import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';

import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthDataSource
    implements
        AuthenticationLogInCapacity,
        AuthenticationUserAlreadySignedInCapacity {

}

class AuthDataSourceImpl implements AuthDataSource {
  AuthService authService;
  AuthDataSourceImpl({required this.authService});







  @override
  Future<bool> checkIfUserIsAlreadySignedIn() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Map<String, dynamic> userData = await authService.userAlreadySignedIn();
        if (userData["userId"] != "unknown") {
          GlobalDataContainer.userId = userData["userId"];
          return true;
        } else {
          return false;
        }
      } catch (e) {
        throw e;
      }
    } else {
      throw NetworkException();
    }
  }

  @override
  Future<bool> logIn({required SignInProviders signInProviders}) async{
 if (await NetworkInfoImpl.networkInstance.isConnected) {

      try {
        
        Map<String, dynamic> userData = await authService.logUserFromGoogle();
        GlobalDataContainer.userId = userData["userId"];
        return true;
      } catch (e, s) {
        print(s);
        throw e;
      }
    } else {
      throw NetworkException();
    }
  }
}
