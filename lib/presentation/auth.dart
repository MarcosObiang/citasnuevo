import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/usecases/authUseCases/authUseCases.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:flutter/material.dart';

import '../core/common/common_widgets.dart/errorWidget.dart';

class AuthScreenPresentation extends ChangeNotifier implements Presentation {
  AuthState _authState = AuthState.notSignedIn;
  LogInUseCase logInUseCase;
  CheckSignedInUserUseCase checkSignedInUserUseCase;
  AuthState get authState => _authState;
  late Failure failuretype;
  set authState(AuthState authState) {
    this._authState = authState;

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  AuthScreenPresentation(
      {required this.logInUseCase, required this.checkSignedInUserUseCase});

  ///This method will be called by Flutter´s initState method on the splash screen to check if there is any current user logged in the app
  ///
  ///
  Future<void> checkSignedInUser() async {
    authState = AuthState.signingIn;
    var data = await checkSignedInUserUseCase
        .call(const LoginParams(loginType: LoginType.google));

    data.fold((failure) {
      failuretype = failure;

      if (failuretype is NetworkFailure) {
      
      }

      authState = AuthState.error;
    }, (authResponseEnity) {
      authState = authResponseEnity.authState;
    });
  }

  ///This method will be called when the usr presses the "Sign In With Google" button
  ///
  ///
  void signInWithGoogle() async {
    authState = AuthState.signingIn;
    var authSate1 =
        await logInUseCase.call(const LoginParams(loginType: LoginType.google));
    authSate1.fold((failure) {
      failuretype = failure;
      if (failuretype is NetworkFailure) {
        showErrorDialog(
            errorLog: "errorLog",
            errorName: "errorName",
            context: startKey.currentContext as BuildContext);
      }
      authState = AuthState.error;
    }, (authResponseEntity) {
      authState = authResponseEntity.authState;
    });
  }

  @override
  void showLoadingDialog() {
    // TODO: implement showLoadingDialog
  }

  @override
  void showErrorDialog(
      {required String errorLog,
      required String errorName,
      required BuildContext context}) {
    showDialog(context: context, builder: (context) => NetwortErrorWidget());
  }

  void showNetworkError() {}
}
