import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../DataManager.dart';
import '../../PrincipalScreen.dart';
import '../../UserSettings/UserSettingsEntity.dart';
import '../../../Utils/dialogs.dart';
import '../../../Utils/presentationDef.dart';
import '../../../core/dependencies/dependencyCreator.dart';
import '../../../core/error/Failure.dart';
import '../../../core/globalData.dart';
import '../../../core/params_types/params_and_types.dart';
import '../../../main.dart';
import '../UserCreatorEntity.dart';
import '../userCreatorController.dart';
import 'Widgets/userCreatorScreen.dart';

enum UserCreatorScreenState {
  LOADING,
  READY,
  ERROR,
  LOCATION_ERROR,
  MODULE_ERROR
}

enum LocationErrorType {
  NO_ERROR,
  LOCATION_PERMISSION_DENIED_FOREVER,
  LOCATION_PERMISSION_DENIED,
  UNABLE_TO_DETERMINE_LOCATION_STATUS,
  LOCATION_SERVICE_DISABLED
}

class UserCreatorPresentation extends ChangeNotifier
    implements ShouldUpdateData, Presentation, ModuleCleanerPresentation {
  @override
  StreamSubscription? updateSubscription;
  UserCreatorController userCreatorController;
  UserCreatorScreenState _userCreatorScreenState =
      UserCreatorScreenState.LOADING;
  LocationErrorType _locationErrorType = LocationErrorType.NO_ERROR;

  bool goBackUserCreated = false;

  set setUserCreatorScreenState(UserCreatorScreenState userCreatorScreenState) {
    this._userCreatorScreenState = userCreatorScreenState;
    notifyListeners();
  }

  UserCreatorEntity get getUserCreatorEntity =>
      userCreatorController.userCreatorEntity;
  set setUserCreatorEntity(UserCreatorEntity userCreatorEntity) {
    userCreatorController.userCreatorEntity = userCreatorEntity;
    notifyListeners();
  }

  UserCreatorScreenState get getUserCreatorScreenState =>
      this._userCreatorScreenState;

  set setLocationErrorType(LocationErrorType locationErrorType) {
    this._locationErrorType = locationErrorType;
    notifyListeners();
  }

  LocationErrorType get getLocationTypeError => this._locationErrorType;

  UserCreatorPresentation({required this.userCreatorController});

  @override
  void clearModuleData() {
    try {
      updateSubscription?.cancel();
      goBackUserCreated = false;
      _userCreatorScreenState = UserCreatorScreenState.LOADING;
      userCreatorController.clearModuleData();
    } catch (e) {
      print(e);
    }
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
    PresentationDialogs().showErrorDialogWithOptions(
        context: startKey.currentContext,
        dialogOptionsList: [
          DialogOptions(
              function: () async {
                var result = await userCreatorController.logOut();
                result.fold((l) {
                  PresentationDialogs().showErrorDialog(
                      title: AppLocalizations.of(startKey.currentContext!)!.error,
                      content: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_sessionCouldNotBeClosed,
                      context: startKey.currentContext as BuildContext);
                }, (succes) async {
                  Dependencies.clearDependenciesAfterCreateUser();

                  Navigator.of(startKey.currentContext as BuildContext)
                      .popUntil((route) => route.isFirst);
                });
              },
              text: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_exit),
          DialogOptions(
              function: () async {
                Navigator.pop(startKey.currentContext as BuildContext);
              },
              text: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_stay)
        ],
        dialogTitle: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_closeSession,
        dialogText: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_sessionWillEnd);
  }

  void createUser() async {
    setUserCreatorScreenState = UserCreatorScreenState.LOADING;

    Either<Failure, bool> result = await userCreatorController.createUser();

    result.fold((failure) {
      setUserCreatorScreenState = UserCreatorScreenState.ERROR;

      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      }
      if (failure is LocationServiceFailure) {
        if (failure.message == "LOCATION_PERMISSION_DENIED_FOREVER") {
          setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
          setLocationErrorType =
              LocationErrorType.LOCATION_PERMISSION_DENIED_FOREVER;
          PresentationDialogs.instance.showErrorDialogWithOptions(
              dialogOptionsList: [],
              dialogTitle: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_locationAccess,
              dialogText: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_locationAccessDenied,
              context: startKey.currentContext);
        }
        if (failure.message == "LOCATION_PERMISSION_DENIED") {
          setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
          setLocationErrorType = LocationErrorType.LOCATION_PERMISSION_DENIED;
          PresentationDialogs.instance.showErrorDialog(
              title: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_locationAccess,
              content: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_locationAccessDenied,
              context: startKey.currentContext);
        }

        if (failure.message == "UNABLE_TO_DETERMINE_LOCATION_STATUS") {
          setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
          setLocationErrorType =
              LocationErrorType.UNABLE_TO_DETERMINE_LOCATION_STATUS;
        }

        if (failure.message == "LOCATION_SERVICE_DISABLED") {
          setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
          setLocationErrorType = LocationErrorType.LOCATION_SERVICE_DISABLED;
        }
      }
    }, (succes) async {
      Dependencies.clearDependenciesAfterCreateUser();
      goBackUserCreated = true;

      Navigator.of(startKey.currentContext as BuildContext)
          .popUntil((route) => route.isFirst);
    });
  }

  void goToMainScreenApp(BuildContext? context) {
    if (context != null) {
      Navigator.pushNamed(context, PrincipalScreen.routeName);
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

  @override
  void update() {
    log("update function initialized");
    updateSubscription =
        userCreatorController.updateDataController?.stream.listen((event) {
      setUserCreatorScreenState = UserCreatorScreenState.READY;
      notifyListeners();
    });
  }

  /// -------------REQUIREMENTS CHECKER---------------
  ///
  /// Checks if the user name fits the standars
  ///
  bool nameChecker({required String userName}) {
    bool value = true;
    if (userName.trim().length < 1) {
      value = false;
      PresentationDialogs().showErrorDialog(
          title: AppLocalizations.of(startKey.currentContext!)!.error,
          content: "El nombre no puede estar vacio",
          context: startKey.currentContext);
    }
    if (userName.length > 25) {
      value = false;
      PresentationDialogs().showErrorDialog(
          title: AppLocalizations.of(startKey.currentContext!)!.error,
          content: "El nombre no puede tener mas de 25 caracteres",
          context: startKey.currentContext);
    }
    return value;
  }

  /// -------------REQUIREMENTS CHECKER---------------
  ///
  /// Checks if the user age fits the standars
  ///
  bool ageChecker({required int? userAge}) {
    bool value = true;
    if (userAge != null) {
      if (userAge < 18) {
        value = false;
        PresentationDialogs().showErrorDialog(
            title: AppLocalizations.of(startKey.currentContext!)!.error,
            content: "Debes tener 18 años o más",
            context: startKey.currentContext);
      }
    }
    if (userAge == null) {
      value = false;
      PresentationDialogs().showErrorDialog(
          title: AppLocalizations.of(startKey.currentContext!)!.error,
          content: "Debes seneccionar tu fecha de nacimiento",
          context: startKey.currentContext);
    }

    return value;
  }

  bool pictureChecker() {
    bool result = false;

    for (int i = 0; i < getUserCreatorEntity.userPicruresList.length; i++) {
      if (getUserCreatorEntity.userPicruresList[i].getUserPictureBoxstate ==
          UserPicutreBoxState.pictureFromBytes) {
        result = true;
      }
    }
    if(result==false){
       PresentationDialogs().showErrorDialog(
          title: AppLocalizations.of(startKey.currentContext!)!.error,
          content: "Debes seleccionar almenos una foto",
          context: startKey.currentContext);
    }
    return result;
  }

  /// Once the app checks for location permission and is denied, we could use this method to request permission
  ///
  /// to use the location services of the device.
  ///
  /// Caution:if the succes parameter is equal  to [LocationPermission.deniedForever]
  ///
  /// we cant ask for permission again,we should aswk the user to go into settings and give
  ///
  /// the location permission from there
  ///
  ///
  void requestPermission() async {
    var result = await userCreatorController.requestPermission();
    result.fold((failure) {}, (succes) {
      if (succes["status"] == "correct" || succes["status"] == "correct") {
        setLocationErrorType = LocationErrorType.NO_ERROR;
        createUser();
      }
      if (succes["status"] == kLocationPermissionDeniedForever) {
        setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
        setLocationErrorType =
            LocationErrorType.LOCATION_PERMISSION_DENIED_FOREVER;
        print("LOCATION_PERMISSION_DENIED_FOREVER");
      }
      if (succes["status"] == kLocationServiceDisabled) {
        setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
        setLocationErrorType = LocationErrorType.LOCATION_SERVICE_DISABLED;
      }

      if (succes["status"] == kLocationPermissionDenied) {
        setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;

        setLocationErrorType = LocationErrorType.LOCATION_PERMISSION_DENIED;
        print("LOCATION_PERMISSION_DENIED");
      }

      if (succes["status"] == kLocationUnknownStatus) {
        setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
        setLocationErrorType =
            LocationErrorType.UNABLE_TO_DETERMINE_LOCATION_STATUS;
        print("UNABLE_TO_DETERMINE_LOCATION_STATUS");
      }
    });
  }

  void openLocationSettings() async {
    var result = await userCreatorController.goToLocationSettings();
    result.fold((failure) {
      if (failure.message == "LOCATION_PERMISSION_DENIED_FOREVER") {
        setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
        setLocationErrorType =
            LocationErrorType.LOCATION_PERMISSION_DENIED_FOREVER;
        print("LOCATION_PERMISSION_DENIED_FOREVER");
        PresentationDialogs.instance.showErrorDialog(
            title: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_locationAccess,
            content: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_locationAccessDenied,
            context: startKey.currentContext);
      }
      if (failure.message == "LOCATION_SERVICE_DISABLED") {
        setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
        setLocationErrorType = LocationErrorType.LOCATION_SERVICE_DISABLED;
      }

      if (failure.message == "LOCATION_PERMISSION_DENIED") {
        setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
        PresentationDialogs.instance.showErrorDialog(
            title: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_locationAccess,
            content: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_locationAccessDenied,
            context: startKey.currentContext);
        setLocationErrorType = LocationErrorType.LOCATION_PERMISSION_DENIED;
        print("LOCATION_PERMISSION_DENIED");
      }

      if (failure.message == "UNABLE_TO_DETERMINE_LOCATION_STATUS") {
        setUserCreatorScreenState = UserCreatorScreenState.LOCATION_ERROR;
        setLocationErrorType =
            LocationErrorType.UNABLE_TO_DETERMINE_LOCATION_STATUS;
        print("UNABLE_TO_DETERMINE_LOCATION_STATUS");
      }
    }, (succes) {
      createUser();
    });
  }

  void setUserSex({required bool isUserWoman}) {
    userCreatorController.userCreatorEntity.isUserWoman = isUserWoman;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void updateUserCharacteristicListState(List<UserCharacteristic> list) {
    userCreatorController.userCreatorEntity.userCharacteristics = list;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void updateUserDatingPreference(
      {required bool showWoman, required bool showBothSexes}) {
    userCreatorController.userCreatorEntity.showWoman = showWoman;
    userCreatorController.userCreatorEntity.showBothSexes = showBothSexes;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void showPromotionalCodeInfo(){
        PresentationDialogs().showErrorDialog(
            title: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_invitationCode,
            content: AppLocalizations.of(startKey.currentContext!)!.userCreatorPresentation_invitationCodeInfo,
            context: startKey.currentContext);

  }
}
