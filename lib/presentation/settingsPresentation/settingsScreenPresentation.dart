import 'dart:async';

import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:flutter/material.dart';

import 'package:citasnuevo/domain/controller/SettingsController.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';

enum SettingsScreenState { loading, loaded, error }

class SettingsScreenPresentation extends ChangeNotifier
    implements ShouldUpdateData<SettingsInformationSender>, Presentation {
  SettingsController settingsController;
  late SettingsEntity settingsEntity;
  SettingsScreenState settingsScreenState = SettingsScreenState.loading;

  @override
  late StreamSubscription<SettingsInformationSender> updateSubscription;
  SettingsScreenPresentation({
    required this.settingsController,
  }) {
    initialize();
  }

  set setSettingsScreenState(SettingsScreenState settingsScreenState) {
    this.settingsScreenState = settingsScreenState;
    notifyListeners();
  }

  @override
  void initialize() {
    settingsController.initializeModuleData();

    setSettingsScreenState = SettingsScreenState.loading;

    update();
  }

  @override
  void restart() {
    setSettingsScreenState = SettingsScreenState.loading;
    updateSubscription.cancel();

    settingsController.clearModuleData();
    initialize();
  }

  @override
  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {}

  @override
  void showLoadingDialog() {
    // TODO: implement showLoadingDialog
  }

  @override
  void showNetworkErrorDialog({required BuildContext? context}) {
    // TODO: implement showNetworkErrorDialog
  }

  @override
  void update() {
    updateSubscription =
        settingsController.updateDataController.stream.listen((event) {
      setSettingsScreenState = SettingsScreenState.loaded;

      settingsEntity = event.settingsEntity;
      notifyListeners();
    }, onError: (error) {
      setSettingsScreenState = SettingsScreenState.error;
    });
  }
}
