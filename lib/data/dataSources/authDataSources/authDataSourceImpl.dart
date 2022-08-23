import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';

import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';

abstract class AuthScreenDataSource
    implements
        AuthenticationLogInCapacity,
        AuthenticationUserAlreadySignedInCapacity
         {}

class AuthScreenDataSourceImpl implements AuthScreenDataSource {
  AuthService authService;
  AuthScreenDataSourceImpl({required this.authService});

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
        throw AuthException(message: e.toString());
      }
    } else {
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }

  @override
  Future<bool> logIn({required SignInProviders signInProviders}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Map<String, dynamic> userData = await authService.logUserFromGoogle();
        GlobalDataContainer.userId = userData["userId"];
        return true;
      } catch (e) {
        throw AuthException(message: e.toString());
      }
    } else {
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }
}
