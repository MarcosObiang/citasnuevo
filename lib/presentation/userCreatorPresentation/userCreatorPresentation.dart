import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/controller/userCreatorController.dart';
import 'package:citasnuevo/domain/entities/UserCreatorEntity.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/Routes.dart';
import 'package:citasnuevo/presentation/dialogs.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:citasnuevo/presentation/userCreatorPresentation/userCreatorScreen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../core/dependencies/dependencyCreator.dart';
import '../../core/error/Failure.dart';
import '../../core/globalData.dart';
import '../../domain/repository/DataManager.dart';
import '../homeScreenPresentation/Screens/HomeScreen.dart';

enum UserCreatorScreenState { LOADING, READY, ERROR }

enum UserCreationProcessState { NOT_STARTED, LOADING, ERROR }

class UserCreatorPresentation extends ChangeNotifier
    implements
        ShouldUpdateData<UserCreatorInformationSender>,
        Presentation,
        ModuleCleanerPresentation {
  @override
  late StreamSubscription<UserCreatorInformationSender>? updateSubscription;
  UserCreatorController userCreatorController;
  UserCreatorScreenState _userCreatorScreenState =
      UserCreatorScreenState.LOADING;
  UserCreationProcessState _userCreationProcessState =
      UserCreationProcessState.NOT_STARTED;
  bool goBackUserCreated = false;

  set setUserCreatorScreenState(UserCreatorScreenState userCreatorScreenState) {
    this._userCreatorScreenState = userCreatorScreenState;
    notifyListeners();
  }

  set setUserCreationProcessState(UserCreationProcessState userCreationState) {
    this._userCreationProcessState = userCreationState;
    notifyListeners();
  }

  UserCreatorEntity get getUserCreatorEntity =>
      userCreatorController.userCreatorEntity;
  UserCreatorScreenState get getUserCreatorScreenState =>
      this._userCreatorScreenState;
  UserCreationProcessState get getUserCreationProcessState =>
      this._userCreationProcessState;

  UserCreatorPresentation({required this.userCreatorController});

  @override
  void clearModuleData() {
    updateSubscription?.cancel();
    goBackUserCreated = false;
    _userCreatorScreenState = UserCreatorScreenState.LOADING;
    _userCreationProcessState = UserCreationProcessState.NOT_STARTED;
  }

  @override
  void initializeModuleData() {
    userCreatorController.initializeModuleData();
    update();
  }

  void addPicture({required Uint8List imageData, required int index}) {
    userCreatorController.insertImageFile(imageData, index);
    notifyListeners();
  }

  void deletePircture(int index) {
    userCreatorController.deleteImage(index);
    notifyListeners();
  }

  @override
  void restart() {
    clearModuleData();
    initializeModuleData();
  }

  void addDate({required DateTime dateTime}) async {
    await userCreatorController.userCreatorEntity
        .addUserDate(dateTime: dateTime);
    notifyListeners();
  }

  void logOut() async {
    var result = await userCreatorController.logOut();
    result.fold((l) {}, (r) {});
  }

  void createUser() async {
    setUserCreationProcessState = UserCreationProcessState.LOADING;

    Either<Failure, bool> result = await userCreatorController.createUser();

    result.fold((failure) {
      setUserCreationProcessState = UserCreationProcessState.ERROR;

      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      }
    }, (succes) async {
      Dependencies.clearDependenciesAfterCreateUser();
      goBackUserCreated = true;

      Navigator.of(startKey.currentContext as BuildContext)
          .popUntil((route) => route.isFirst);
      var data = await Dependencies.authRepository.checkSignedInUser();

      data.fold((f) {
        if (f is NetworkFailure) {
          PresentationDialogs.instance
              .showNetworkErrorDialog(context: startKey.currentContext);
        }
      }, (authResponseEnity) async {
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
    });
  }

  void goToMainScreenApp(BuildContext? context) {
    if (context != null) {
      Navigator.pushNamed(context, HomeAppScreen.routeName);
    }
  }

  void goToCreateUserPage(BuildContext? context) {
    if (context != null) {
      Navigator.pushNamed(context, UserCreatorScreen.routeName,
          arguments:
              UserCreatorScreenArgs(userName: GlobalDataContainer.userName));
    }
  }

  @override
  void update() {
    updateSubscription =
        userCreatorController.getDataStream?.stream.listen((event) {
      setUserCreatorScreenState = UserCreatorScreenState.READY;
      notifyListeners();
    });
  }
}
