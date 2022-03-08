import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Screens/HomeScreen.dart';
import 'package:citasnuevo/presentation/routes.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/controller/authScreenController.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../core/dependencies/dependencyCreator.dart';
import '../../core/globalData.dart';

class AuthScreenPresentation extends ChangeNotifier implements Presentation {
  AuthState _authState = AuthState.notSignedIn;
  AuthScreenController authScreenController;

  AuthState get authState => _authState;
  late Failure failuretype;
  AuthScreenPresentation({
    required this.authScreenController,
  });
  set authState(AuthState authState) {
    this._authState = authState;

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  void goToMainScreenApp(BuildContext? context) {
    if (context != null) {
      Navigator.push(context, GoToRoute(page: HomeAppScreen()));
    }
  }

  ///This method will be called by Flutter´s initState method on the splash screen to check if there is any current user logged in the app
  ///
  ///
  Future<Either<Failure, AuthResponseEntity>> checkSignedInUser() async {
    authState = AuthState.signingIn;
    var data = await authScreenController.checkIfUserIsAlreadySignedUp();

    data.fold((failure) {
      failuretype = failure;

      if (failuretype is NetworkFailure) {}

      authState = AuthState.error;
    }, (authResponseEnity) async {
      authState = authResponseEnity.authState;
      if (GlobalDataContainer.userId != null) {
        await Dependencies.startDependencies();

        Dependencies.reactionPresentation.initializeReactionsListener();
        Dependencies.chatPresentation.initialize();
       
      }

      Dependencies.startUtilDependencies();
      goToMainScreenApp(startKey.currentContext);
    });
    return data;
  }

  ///This method will be called when the usr presses the "Sign In With Google" button
  ///
  ///
  void signInWithGoogle() async {
    authState = AuthState.signingIn;
    var authSate1 = await authScreenController.signInWithGoogleAccount();
    authSate1.fold((failure) {
      failuretype = failure;
      if (failuretype is NetworkFailure) {
        showNetworkError();
      }
      authState = AuthState.error;
    }, (authResponseEnity) async {
      authState = authResponseEnity.authState;
      if (GlobalDataContainer.userId != null) {
        await Dependencies.startDependencies();

        Dependencies.reactionPresentation.initializeReactionsListener();
        Dependencies.chatPresentation.initialize();

      }

      Dependencies.startUtilDependencies();
      goToMainScreenApp(startKey.currentContext);
    });
  }

  @override
  void showLoadingDialog() {}

  @override
  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }

  void showNetworkError() {}

  @override
  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }

  @override
  void initialize() {
    // TODO: implement initialize
  }

  @override
  void restart() {
    // TODO: implement restart
  }

  @override
  bool clearModuleData() {
    // TODO: implement clearModuleData
    throw UnimplementedError();
  }
}
