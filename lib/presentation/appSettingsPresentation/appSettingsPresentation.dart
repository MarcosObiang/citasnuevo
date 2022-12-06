import 'dart:async';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/domain/controller/appSettingsController.dart';
import 'package:citasnuevo/domain/entities/ApplicationSettingsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/main.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../core/dependencies/dependencyCreator.dart';
import '../../domain/controller/controllerDef.dart';
import '../dialogs.dart';
import '../presentationDef.dart';

enum AppSettingsScreenState { loading, loaded, error }

enum AppSettingsScreenUpdateState { loading, loaded, error, done }

class AppSettingsPresentation extends ChangeNotifier
    implements ShouldUpdateData, Presentation, ModuleCleanerPresentation {
  AppSettingsController appSettingsController;
  late AppSettingsScreenState appSettingsScreenState;
  late AppSettingsScreenUpdateState appSettingsScreenUpdateState =
      AppSettingsScreenUpdateState.done;
  late ApplicationSettingsEntity applicationSettingsEntity;
  AppSettingsPresentation({required this.appSettingsController});
  @override
  late StreamSubscription? updateSubscription;
  get getAppSettingsEntity => appSettingsController.applicationSettingsEntity;
  set setAppSettingsScreenState(AppSettingsScreenState appSettingsScreenState) {
    this.appSettingsScreenState = appSettingsScreenState;
    notifyListeners();
  }

  set setAppSettingsScreenUpdateState(
      AppSettingsScreenUpdateState appSettingsScreenUpdateState) {
    this.appSettingsScreenUpdateState = appSettingsScreenUpdateState;
    notifyListeners();
  }

  @override
  void clearModuleData() {
    try {
      setAppSettingsScreenState = AppSettingsScreenState.loading;
      updateSubscription?.cancel();
      updateSubscription = null;

      var result = appSettingsController.clearModuleData();
      result.fold(
          (l) => setAppSettingsScreenState = AppSettingsScreenState.error,
          (r) => null);
    } catch (e) {
      setAppSettingsScreenState = AppSettingsScreenState.error;
    }
  }

  @override
  void initializeModuleData() {
    try {
      setAppSettingsScreenState = AppSettingsScreenState.loading;
      update();
      var result = appSettingsController.initializeModuleData();
      result.fold(
          (l) => setAppSettingsScreenState = AppSettingsScreenState.error,
          (r) => null);
    } catch (e) {
      setAppSettingsScreenState = AppSettingsScreenState.error;
    }
  }

  @override
  void restart() {
    try {
      clearModuleData();
      initializeModuleData();
    } catch (e) {
      setAppSettingsScreenState = AppSettingsScreenState.error;
    }
  }

  void logOut() async {
    var authSate1 = await appSettingsController.logOut();
    authSate1.fold((failure) {
      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        PresentationDialogs.instance.showErrorDialog(
            title: "Error",
            content: "Error al intentar cerrar sesion",
            context: startKey.currentContext);
      }
    }, (authResponseEnity) async {
      Dependencies.clearDependencies();
      Navigator.of(startKey.currentContext as BuildContext)
          .popUntil((route) => route.isFirst);
    });
  }

  void deleteAccount() async {
    var authSate1 = await appSettingsController.deleteAccount();
    authSate1.fold((failure) {
      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        PresentationDialogs.instance.showErrorDialog(
            title: "Error",
            content: "Error al intentar borrar usuario",
            context: startKey.currentContext);
      }
    }, (authResponseEnity) async {
      Dependencies.clearDependencies();
      Navigator.of(startKey.currentContext as BuildContext)
          .popUntil((route) => route.isFirst);
    });
  }

  void updateSettings(
      ApplicationSettingsEntity applicationSettingsEntity, bool saveSettings) async {
        if(saveSettings){
    setAppSettingsScreenUpdateState = AppSettingsScreenUpdateState.loading;
    var result = await appSettingsController
        .updateAppSettings(applicationSettingsEntity);
    result.fold((l) {
      setAppSettingsScreenUpdateState = AppSettingsScreenUpdateState.error;
      if (l is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        Future.delayed(Duration(milliseconds: 500), () {
          PresentationDialogs.instance.showErrorDialog(
              title: "Error",
              content: "No se han podido guardar los ajustes",
              context: startKey.currentContext);
        });
      }
    }, (r) {
      setAppSettingsScreenUpdateState = AppSettingsScreenUpdateState.done;
    });
        }

  }

  @override
  void update() {
    updateSubscription =
        appSettingsController.updateDataController?.stream.listen((event) {
      if (event is ApplicationSettingsEntity) {
        applicationSettingsEntity = new ApplicationSettingsEntity(
            distance: event.distance,
            maxAge: event.maxAge,
            minAge: event.minAge,
            inCm: event.inCm,
            inKm: event.inKm,
            showBothSexes: event.showBothSexes,
            showWoman: event.showWoman,
            showProfile: event.showProfile);
        setAppSettingsScreenState = AppSettingsScreenState.loaded;
      }
    }, onError: (error) {
      setAppSettingsScreenState = AppSettingsScreenState.error;
    });
  }
}
