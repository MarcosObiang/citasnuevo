import 'dart:async';

import '../../../Utils/dialogs.dart';
import '../../../Utils/presentationDef.dart';
import '../../../../core/error/Failure.dart';
import '../../DataManager.dart';
import '../ApplicationSettingsEntity.dart';
import '../appSettingsController.dart';

import '../../../main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/dependencies/dependencyCreator.dart';

enum AppSettingsScreenState { loading, loaded, error }

enum AppSettingsScreenUpdateState { loading, loaded, error, done }

class AppSettingsPresentation extends ChangeNotifier
    implements ShouldUpdateData, Presentation, ModuleCleanerPresentation {
  AppSettingsController appSettingsController;
  AppSettingsScreenState appSettingsScreenState =
      AppSettingsScreenState.loading;
  AppSettingsScreenUpdateState appSettingsScreenUpdateState =
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
      appSettingsScreenUpdateState = AppSettingsScreenUpdateState.done;
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
    PresentationDialogs.instance.showErrorDialogWithOptions(
        context: startKey.currentContext,
        dialogOptionsList: [
          DialogOptions(
              function: () {
                Navigator.pop(startKey.currentContext as BuildContext);
              },
              text: "Cancelar"),
          DialogOptions(
              function: () async {
                var authSate1 = await appSettingsController.logOut();
                authSate1.fold((failure) {
                  if (failure is NetworkFailure) {
                    PresentationDialogs.instance.showNetworkErrorDialog(
                        context: startKey.currentContext);
                  } else {
                    PresentationDialogs.instance.showErrorDialog(
                        title: "Error",
                        content: "Error al intentar cerrar sesion",
                        context: startKey.currentContext);
                  }
                }, (authResponseEnity) async {
                  Dependencies.clearDependenciesAndUserIdentifiers();
                  Navigator.of(startKey.currentContext as BuildContext)
                      .popUntil((route) => route.isFirst);
                });
              },
              text: "Aceptar")
        ],
        dialogTitle: "Cerrar sesion",
        dialogText: "Quieres cerar sesión");
  }

  void deleteAccount() async {
    PresentationDialogs.instance.showErrorDialogWithOptions(
        context: startKey.currentContext,
        dialogOptionsList: [
          DialogOptions(
              function: () {
                Navigator.pop(startKey.currentContext as BuildContext);
              },
              text: "Cancelar"),
          DialogOptions(
              function: () async {
                var authSate1 = await appSettingsController.deleteAccount();
                authSate1.fold((failure) {
                  if (failure is NetworkFailure) {
                    PresentationDialogs.instance.showNetworkErrorDialog(
                        context: startKey.currentContext);
                  } else {
                    PresentationDialogs.instance.showErrorDialog(
                        title: "Error",
                        content: "Error al intentar borrar usuario",
                        context: startKey.currentContext);
                  }
                }, (authResponseEnity) async {
                  Dependencies.clearDependenciesAndUserIdentifiers();
                  Navigator.of(startKey.currentContext as BuildContext)
                      .popUntil((route) => route.isFirst);
                });
              },
              text: "Aceptar")
        ],
        dialogTitle: "Borrar Usuario",
        dialogText:
            "¿Estas seguro de que quieres eliminar tu cuenta?.\nTodos tus datos seran borrados permanentemente");
  }

  void updateSettings(ApplicationSettingsEntity applicationSettingsEntity,
      bool saveSettings) async {
    if (saveSettings) {
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
