import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';

import 'package:citasnuevo/core/firebase_services/firebase_app.dart';
import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';

import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';

abstract class AuthDataSource {
  Future<AuthResponseEntity> signInWithGoogle({required LoginParams params});
  Future<AuthResponseEntity> signInWithFacebook({required LoginParams params});
  Future<AuthResponseEntity> signOut();
  Future<AuthResponseEntity> checkIfIsSignedIn();
}

class AuthDataSourceImpl implements AuthDataSource {

  
  @override
  Future<AuthResponseEntity> signInWithFacebook(
      {required LoginParams params}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        await AuthenticationImpl().logUserFromFacebook();
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
            await AuthenticationImpl().logUserFromGoogle();
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
  Future<AuthResponseEntity> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponseEntity> checkIfIsSignedIn() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Map<String, dynamic> userData =
            await AuthenticationImpl().userAlreadySignedIn();
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
