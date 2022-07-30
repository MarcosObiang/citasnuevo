import 'package:citasnuevo/core/iapPurchases/iapPurchases.dart';
import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Screens/HomeScreen.dart';
import 'package:citasnuevo/presentation/routes.dart';
import 'package:citasnuevo/presentation/userCreatorPresentation/userCreatorScreen.dart';
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

class AuthScreenPresentation extends ChangeNotifier
    implements Presentation, ModuleCleaner {
  AuthState _authState = AuthState.notSignedIn;
  AuthScreenController authScreenController;

  AuthState get authState => _authState;
  AuthScreenPresentation({
    required this.authScreenController,
  });

  @override
  void restart() {
    clearModuleData();
    initializeModuleData();
  }

  @override
  bool clearModuleData() {
    authState = AuthState.notSignedIn;
    return true;
  }

  @override
  void initializeModuleData() {
    // TODO: implement initializeModuleData
  }
  set authState(AuthState authState) {
    this._authState = authState;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  void goToMainScreenApp(BuildContext? context) {
    if (context != null) {
      Navigator.push(context, GoToRoute(page: HomeAppScreen()));
    }
  }

  void goToCreateUserPage(BuildContext? context) {
    if (context != null) {
      Navigator.push(
          context,
          GoToRoute(
              page: UserCreatorScreen(
            userName: GlobalDataContainer.userName,
          )));
    }
  }

  ///This method will be called by Flutter´s initState method on the splash screen to check if there is any current user logged in the app
  ///
  ///
  Future<void> checkSignedInUser() async {
    authState = AuthState.signingIn;
    var data = await authScreenController.checkIfUserIsAlreadySignedUp();

    data.fold((failure) {
      if (failure is NetworkFailure) {
        showNetworkErrorDialog(context: startKey.currentContext);
      }

      authState = AuthState.error;
    }, (authResponseEnity) async {
      if (authResponseEnity == true) {
        authState = AuthState.succes;
        if (GlobalDataContainer.userId != null) {
          await Dependencies.startDependencies(restart: false);
          bool signInResult = await Dependencies.initializeDependencies();

          if (signInResult == true) {
            Dependencies.startUtilDependencies();

            goToMainScreenApp(startKey.currentContext);
          } else {
            authState = AuthState.notSignedIn;
          }
        }
      } else {
        authState = AuthState.notSignedIn;
      }
    });
  }

  ///This method will be called when the usr presses the "Sign In With Google" button
  ///
  ///
  void signInWithGoogle() async {
    authState = AuthState.signingIn;
    var authSate1 = await authScreenController.signInWithGoogleAccount();
    authSate1.fold((failure) {
      authState = AuthState.error;

      if (failure is NetworkFailure) {
        showNetworkError();
      }
    }, (authResponseEnity) async {
      authState = AuthState.succes;
      if (GlobalDataContainer.userId != null) {
        await Dependencies.startDependencies(restart: false);
        bool signInResult = await Dependencies.initializeDependencies();

        if (signInResult == true) {
          Dependencies.startUtilDependencies();

          goToMainScreenApp(startKey.currentContext);
        } else {
          goToCreateUserPage(startKey.currentContext);
        }
      }
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
}
