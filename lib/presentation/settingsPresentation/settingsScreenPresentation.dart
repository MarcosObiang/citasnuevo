import 'dart:async';

import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:flutter/material.dart';

import 'package:citasnuevo/domain/controller/SettingsController.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';

enum SettingsScreenState { loading, loaded, error }

class SettingsScreenPresentation extends ChangeNotifier
    implements
        ShouldUpdateData<SettingsInformationSender>,
        Presentation,
        ModuleCleanerPresentation {
  SettingsController settingsController;
  late SettingsEntity settingsEntity;
  bool _isAppSettingsUpdating = false;
  bool _isUSerSettingsUpdating = false;
  SettingsScreenState settingsScreenState = SettingsScreenState.loading;

  @override
  late StreamSubscription<SettingsInformationSender>? updateSubscription;
  SettingsScreenPresentation({
    required this.settingsController,
  });

  void purchase(String productId, bool renewPurchase) {
    settingsController.purchase(productId, renewPurchase);
  }

  set setSettingsScreenState(SettingsScreenState settingsScreenState) {
    this.settingsScreenState = settingsScreenState;
  }

  set setIsAppSettingsUpdating(bool isAppSettingsUpdating) {
    this._isAppSettingsUpdating = isAppSettingsUpdating;
    WidgetsBinding.instance.addPostFrameCallback((data) {
      notifyListeners();
    });
  }

  set setIsUserSettingsUpdating(bool isUserSettingsUpdating) {
    this._isUSerSettingsUpdating = isUserSettingsUpdating;
    WidgetsBinding.instance.addPostFrameCallback((data) {
      notifyListeners();
    });
  }

  bool get getIsAppSettingsUpdating => _isAppSettingsUpdating;
  bool get getIsUserSettingsUpdating => _isUSerSettingsUpdating;



  @override
  void restart() {
    clearModuleData();

    initializeModuleData();
  }

  @override
  void update() {
    updateSubscription =
        settingsController.updateDataController?.stream.listen((event) {
      setSettingsScreenState = SettingsScreenState.loaded;

      settingsEntity = event.settingsEntity;
      if (event.isAppSettingsUpdating != null) {
        setIsAppSettingsUpdating = event.isAppSettingsUpdating as bool;
      }
      if (event.isUserSettingsUpdating != null) {
        setIsUserSettingsUpdating = event.isUserSettingsUpdating as bool;
      }
      notifyListeners();
    }, onError: (error) {
      setSettingsScreenState = SettingsScreenState.error;
    });
  }

  @override
  void clearModuleData() {
    setSettingsScreenState = SettingsScreenState.loading;
    updateSubscription?.cancel();

    settingsController.clearModuleData();
  }

  @override
  void initializeModuleData() {
    settingsController.initializeModuleData();

    setSettingsScreenState = SettingsScreenState.loading;

    update();
  }
}
