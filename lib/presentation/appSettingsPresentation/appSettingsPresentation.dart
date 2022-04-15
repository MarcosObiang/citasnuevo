import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/appSettingsController.dart';
import 'package:citasnuevo/domain/entities/ApplicationSettingsEntity.dart';
import 'package:citasnuevo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../domain/controller/controllerDef.dart';
import '../presentationDef.dart';

enum AppSettingsScreenState { loading, loaded, error }
enum AppSettingsScreenUpdateState { loading, loaded, error, done }

class AppSettingsPresentation extends ChangeNotifier
    implements
        ShouldUpdateData<ApplicationSettingsInformationSender>,
        Presentation {
  AppSettingsController appSettingsController;
  late AppSettingsScreenState appSettingsScreenState;
  late AppSettingsScreenUpdateState appSettingsScreenUpdateState =
      AppSettingsScreenUpdateState.done;

  AppSettingsPresentation({required this.appSettingsController}) {
    initialize();
  }
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
}
