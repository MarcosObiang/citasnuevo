import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/presentation/AuthScreen.dart';
class AuthResponseEntity {
  AuthState authState = AuthState.notSignedIn;
  AuthResponseEntity.succes() {
    authState = AuthState.succes;
  }
  AuthResponseEntity.error() {
    authState = AuthState.error;
  }
  AuthResponseEntity.inProcess() {
    authState = AuthState.signingIn;
  }
  AuthResponseEntity.notSignedIn() {
    authState = AuthState.notSignedIn;
  }}