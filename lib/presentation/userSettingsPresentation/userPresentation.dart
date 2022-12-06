import 'dart:typed_data';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/domain/controller/userSettingsController.dart';
import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'dart:async';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../domain/controller/controllerDef.dart';
import '../../domain/repository/DataManager.dart';
import '../presentationDef.dart';

enum UserSettingsScreenState { loading, loaded, error }

enum UserSettingsScreenUpdateState { loading, loaded, error, done }

class UserSettingsPresentation extends ChangeNotifier
    implements
        ShouldUpdateData,
        Presentation,
        ModuleCleanerPresentation {
  UserSettingsController userSettingsController;

  UserSettingsPresentation({required this.userSettingsController});
  late UserSettingsScreenState userSettingsScreenState;
  late UserSettingsScreenUpdateState _userSettingsScreenUpdateState =
      UserSettingsScreenUpdateState.done;
  UserSettingsEntity get getUserSettingsEntity =>
      userSettingsController.userSettingsEntity;
  set setUserSettingsScreenState(
      UserSettingsScreenState userSettingsScreenState) {
    this.userSettingsScreenState = userSettingsScreenState;
    notifyListeners();
  }

  bool saveChanges = false;

  set setUserSettingsScreenUdateState(
      UserSettingsScreenUpdateState userSettingsScreenUpdateState) {
    this._userSettingsScreenUpdateState = userSettingsScreenUpdateState;
    notifyListeners();
  }

  UserSettingsScreenUpdateState get getUserSettingsScreenUpdateState =>
      _userSettingsScreenUpdateState;

  @override
  late StreamSubscription? updateSubscription;

  void addPictureFromDevice(Uint8List uint8list, int index) {
    userSettingsController.insertImageFile(uint8list, index);
  }

  void deletePicture(int index) {
    userSettingsController.deleteImage(index);
  }

  @override
  void restart() {
    clearModuleData();
    initializeModuleData();
  }

  void userSettingsUpdate() async {
    if (saveChanges) {
      setUserSettingsScreenUdateState = UserSettingsScreenUpdateState.loading;

      var result = await userSettingsController.updateSettings();

      result.fold((l) {
        setUserSettingsScreenUdateState = UserSettingsScreenUpdateState.done;

        if (l is NetworkFailure) {
          PresentationDialogs.instance
              .showNetworkErrorDialog(context: startKey.currentContext);
        } else {
          PresentationDialogs.instance.showErrorDialog(
              title: "Error",
              content: "No se han podido guardar los cambios",
              context: startKey.currentContext);
        }
      }, (r) {
        setUserSettingsScreenUdateState = UserSettingsScreenUpdateState.done;
      });
    } else {
      userSettingsController.revertChanges();
    }
  }

  @override
  void update() {
    updateSubscription =
        userSettingsController.updateDataController?.stream.listen((event) {
      setUserSettingsScreenState = UserSettingsScreenState.loaded;
    }, onError: (error) {
      setUserSettingsScreenState = UserSettingsScreenState.error;
    });
  }

  @override
  void clearModuleData() {
    setUserSettingsScreenState = UserSettingsScreenState.loading;
    updateSubscription?.cancel();
    userSettingsController.clearModuleData();
  }

  @override
  void initializeModuleData() {
    userSettingsController.initializeModuleData();
    setUserSettingsScreenState = UserSettingsScreenState.loading;
    update();
  }
}
