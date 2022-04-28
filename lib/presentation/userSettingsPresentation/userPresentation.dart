import 'dart:typed_data';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/userSettingsController.dart';
import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:citasnuevo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'dart:async';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../domain/controller/controllerDef.dart';
import '../presentationDef.dart';

enum UserSettingsScreenState { loading, loaded, error }
enum UserSettingsScreenUpdateState { loading, loaded, error, done }

class UserSettingsPresentation extends ChangeNotifier
    implements ShouldUpdateData<UserSettingsInformationSender>, Presentation {
  UserSettingsController userSettingsController;

  UserSettingsPresentation({required this.userSettingsController}) {
    initialize();
  }
  late UserSettingsScreenState userSettingsScreenState;
  late UserSettingsScreenUpdateState userSettingsScreenUpdateState =
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
    this.userSettingsScreenUpdateState = userSettingsScreenUpdateState;
    notifyListeners();
  }

  @override
  late StreamSubscription<UserSettingsInformationSender> updateSubscription;

  @override
  void initialize() {
    userSettingsController.initializeModuleData();
    setUserSettingsScreenState = UserSettingsScreenState.loading;
    update();
  }

  void addPictureFromDevice(Uint8List uint8list, int index) {
    userSettingsController.insertImageFile(uint8list, index);
  }

  void deletePicture(int index) {
    userSettingsController.deleteImage(index);
  }

  @override
  void restart() {
    setUserSettingsScreenState = UserSettingsScreenState.loading;
    updateSubscription.cancel();
    userSettingsController.clearModuleData();
    initialize();
  }

  void userSettingsUpdate() async {
    if (saveChanges) {
      setUserSettingsScreenUdateState = UserSettingsScreenUpdateState.loading;

      var result = await userSettingsController.updateSettings();

      result.fold((l) {
        if (l is NetworkFailure) {
          showErrorDialog(
              title: "Error",
              content: "No se han podido guardar los cambios",
              context: startKey.currentContext);
          showNetworkErrorDialog(context: startKey.currentContext);
        }
      }, (r) {
        setUserSettingsScreenUdateState = UserSettingsScreenUpdateState.done;
      });
    } else {
      userSettingsController.revertChanges();
    }
  }

  @override
  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {
    if (context != null) {
      showDialog(
          context: context,
          useRootNavigator: false,
          builder: (context) =>
              GenericErrorDialog(content: content, title: title));
    }
  }

  @override
  void showLoadingDialog() {
    // TODO: implement showLoadingDialog
  }

  @override
  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }

  @override
  void update() {
    updateSubscription =
        userSettingsController.updateDataController.stream.listen((event) {
      setUserSettingsScreenState = UserSettingsScreenState.loaded;
    }, onError: (error) {
      setUserSettingsScreenState = UserSettingsScreenState.error;
    });
  }
}
