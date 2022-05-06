import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';

import 'package:citasnuevo/core/firebase_services/firebase_app.dart';
import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';

import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthDataSource {
  Future<AuthResponseEntity> signInWithGoogle({required LoginParams params});
  Future<AuthResponseEntity> signInWithFacebook({required LoginParams params});
  Future<AuthResponseEntity> signOut();
  Future<AuthResponseEntity> checkIfIsSignedIn();
}

class AuthDataSourceImpl implements AuthDataSource {
  AuthService authService;
  AuthDataSourceImpl({required this.authService});
  @override
  Future<AuthResponseEntity> signInWithFacebook(
      {required LoginParams params}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        await authService.logUserFromFacebook();
        return AuthResponseEntity.succes();
      } catch (e) {
        throw e;
      }
    } else {
      throw NetworkException();
    }
  }

  @override
  Future<AuthResponseEntity> signInWithGoogle(
      {required LoginParams params}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Map<String, dynamic> userData =
            await authService.logUserFromGoogle();
        GlobalDataContainer.userId = userData["userId"];
        return AuthResponseEntity.succes();
      } catch (e, s) {
        print(s);
        throw e;
      }
    } else {
      throw NetworkException();
    }
  }

  @override
  Future<AuthResponseEntity> signOut() async {
    try {
      await AuthServiceImpl().logOut();
      return AuthResponseEntity.succes();
    } catch (e) {
      return AuthResponseEntity.error();
    }
  }

  @override
  Future<AuthResponseEntity> checkIfIsSignedIn() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Map<String, dynamic> userData =
            await authService.userAlreadySignedIn();
        if (userData["userId"] != "unknown") {
          GlobalDataContainer.userId = userData["userId"];
          return AuthResponseEntity.succes();
        } else {
          return AuthResponseEntity.notSignedIn();
        }
      } catch (e) {
        throw e;
      }
    } else {
      throw NetworkException();
    }
  }
}
