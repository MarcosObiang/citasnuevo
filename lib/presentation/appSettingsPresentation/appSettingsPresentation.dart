import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
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
import '../presentationDef.dart';

enum AppSettingsScreenState { loading, loaded, error }
enum AppSettingsScreenUpdateState { loading, loaded, error, done }

class AppSettingsPresentation extends ChangeNotifier
    implements
        ShouldUpdateData<ApplicationSettingsInformationSender>,
        Presentation,
        ModuleCleaner {
  AppSettingsController appSettingsController;
  late AppSettingsScreenState appSettingsScreenState;
  late AppSettingsScreenUpdateState appSettingsScreenUpdateState =
      AppSettingsScreenUpdateState.done;

  AppSettingsPresentation({required this.appSettingsController});
  @override
  late StreamSubscription<ApplicationSettingsInformationSender>
      updateSubscription;
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
  void initialize() {
    appSettingsController.initializeModuleData();
    setAppSettingsScreenState = AppSettingsScreenState.loading;
    update();
  }

  @override
  void restart() {
    setAppSettingsScreenState = AppSettingsScreenState.loading;
    updateSubscription.cancel();
    appSettingsController.clearModuleData();
    initialize();
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

  void logOut() async {
    var authSate1 = await appSettingsController.logOut();
    authSate1.fold((failure) {
      if (failure is NetworkFailure) {
        showNetworkErrorDialog(context: startKey.currentContext);
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
        showNetworkErrorDialog(context: startKey.currentContext);
      }
    }, (authResponseEnity) async {
      Dependencies.clearDependencies();
      Navigator.of(startKey.currentContext as BuildContext)
          .popUntil((route) => route.isFirst);
    });
  }

  void updateSettings(
      ApplicationSettingsEntity applicationSettingsEntity) async {
    setAppSettingsScreenUpdateState = AppSettingsScreenUpdateState.loading;
    var result = await appSettingsController
        .updateAppSettings(applicationSettingsEntity);
    result.fold((l) {
      setAppSettingsScreenUpdateState = AppSettingsScreenUpdateState.error;
      if (l is NetworkFailure) {
        showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        Future.delayed(Duration(milliseconds: 500), () {
          showErrorDialog(
              title: "Error",
              content: "No se han podido guardar los ajustes",
              context: startKey.currentContext);
        });
      }
    }, (r) {
      setAppSettingsScreenUpdateState = AppSettingsScreenUpdateState.done;
    });
  }

  @override
  void update() {
    updateSubscription =
        appSettingsController.updateDataController.stream.listen((event) {
      setAppSettingsScreenState = AppSettingsScreenState.loaded;
    }, onError: (error) {
      setAppSettingsScreenState = AppSettingsScreenState.error;
    });
  }

  @override
  void clearModuleData() {
    setAppSettingsScreenState = AppSettingsScreenState.loading;
    updateSubscription.cancel();
    appSettingsController.clearModuleData();
  }

  @override
  void initializeModuleData() {
    // TODO: implement initializeModuleData
  }
}
