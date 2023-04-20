import '../../DataManager.dart';
import '../../PrincipalScreen.dart';
import '../../UserCreator/userCreatorPresentation/Widgets/userCreatorScreen.dart';
import '../../../Utils/dialogs.dart';
import '../../../Utils/presentationDef.dart';
import '../../../core/iapPurchases/iapPurchases.dart';
import '../AuthScreenEntity.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../core/error/Failure.dart';
import '../../../core/params_types/params_and_types.dart';
import '../authScreenController.dart';
import '../../../main.dart';

import '../../../core/common/common_widgets.dart/errorWidget.dart';
import '../../../core/dependencies/dependencyCreator.dart';
import '../../../core/globalData.dart';

class AuthScreenPresentation extends ChangeNotifier
    implements Presentation, ModuleCleanerPresentation {
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
  void clearModuleData() {
    authState = AuthState.notSignedIn;
  }

  @override
  void initializeModuleData() {
    checkSignedInUser();
  }

  set authState(AuthState authState) {
    this._authState = authState;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  void goToMainScreenApp(BuildContext? context) {
    if (context != null) {
      Navigator.pushNamed(
        context,
        PrincipalScreen.routeName,
      );
    }
  }

  void goToCreateUserPage(BuildContext? context) {
    if (context != null) {
      Navigator.pushNamed(context, UserCreatorScreen.routeName,
          arguments: UserCreatorScreenArgs(
              userName: GlobalDataContainer.userName,
              email: GlobalDataContainer.userEmail));
    }
  }

  ///This method will be called by Flutter´s initState method on the splash screen to check if there is any current user logged in the app
  ///
  ///
  Future<void> checkSignedInUser() async {
    authState = AuthState.signingIn;
    var data = await authScreenController.checkIfUserIsAlreadySignedUp();
    print(data.toString());

    data.fold((failure) {
      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      }

      authState = AuthState.error;
    }, (result) async {
      String status = result["status"];

      bool userExists = result["userDataExists"];

      if (status == "SIGNED_IN") {
        authState = AuthState.succes;
        if (userExists == true) {
          goToMainScreenApp(startKey.currentContext);
          await Dependencies.initializeDependencies();
        } else {
          Dependencies.initializeUserCreatorModuleDepenencies();

          goToCreateUserPage(startKey.currentContext);
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
    var data = await authScreenController.signInWithGoogleAccount();
    data.fold((failure) {
      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      }

      authState = AuthState.error;
    }, (result) async {
      String status = result["status"];

      bool userExists = result["userDataExists"];

      if (status == "SIGNED_IN") {
        authState = AuthState.succes;
        if (userExists == true) {
          goToMainScreenApp(startKey.currentContext);
          await Dependencies.initializeDependencies();
        } else {
          Dependencies.initializeUserCreatorModuleDepenencies();

          goToCreateUserPage(startKey.currentContext);
        }
      } else {
        authState = AuthState.notSignedIn;
      }
    });
  }
}
