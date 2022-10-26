import 'dart:async';

import 'package:citasnuevo/domain/controller/sanctionsController.dart';
import 'package:citasnuevo/domain/entities/SanctionsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/Routes.dart';
import 'package:citasnuevo/presentation/dialogs.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:citasnuevo/presentation/sanctionsPresentation/sanctionsScreen.dart';
import 'package:flutter/material.dart';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../core/dependencies/dependencyCreator.dart';
import '../../core/error/Failure.dart';
import '../../domain/controller/controllerDef.dart';

enum SanctionsScreenState { loading, loaded, error }

enum SanctionScreenMode { waitingModeration, sanctioned, sanctionEnded }

enum UnlockProcessState { done, inProcess }

class SanctionsPresentation extends ChangeNotifier
    implements ShouldUpdateData<SanctionsEntity>, Presentation, ModuleCleanerPresentation {
  SanctionsController sanctionsController;
  @override
  StreamSubscription<SanctionsEntity>? updateSubscription;

  SanctionsScreenState _sanctionsScreenState = SanctionsScreenState.loading;
  SanctionScreenMode _sanctionScreenMode = SanctionScreenMode.waitingModeration;
  UnlockProcessState _unlockProcessState = UnlockProcessState.done;

  set setUnlockProcessState(UnlockProcessState unlockProcessState) {
    this._unlockProcessState = unlockProcessState;
    notifyListeners();
  }

  set setSanctionsScreenState(SanctionsScreenState sanctionsScreenState) {
    this._sanctionsScreenState = sanctionsScreenState;
    notifyListeners();
  }

  set setSanctionScreenMode(SanctionScreenMode sanctionScreenMode) {
    this._sanctionScreenMode = sanctionScreenMode;
    notifyListeners();
  }

  SanctionsScreenState get getSanctionScreenState => this._sanctionsScreenState;

  SanctionScreenMode get getSanctionScreenMode => this._sanctionScreenMode;

  UnlockProcessState get getUnlockProcessState => this._unlockProcessState;

  SanctionsPresentation({required this.sanctionsController});

  @override
  void update() async {
    updateSubscription =
        sanctionsController.updateDataController!.stream.listen((event) async {
      if (event.isUserSanctioned == true) {
        if (sanctionKey.currentContext == null) {
          Navigator.pushNamed(startKey.currentContext as BuildContext,
              SanctionsScreen.routeName);
        }

        if (event.sanctionConfirmed == true) {
          if (event.timeRemaining > 0) {
            setSanctionScreenMode = SanctionScreenMode.sanctioned;
          }
          if (event.timeRemaining <= 0) {
            setSanctionScreenMode = SanctionScreenMode.sanctionEnded;
          }
        } else {
          setSanctionScreenMode = SanctionScreenMode.waitingModeration;
        }
      }
      if (event.isUserSanctioned == false) {
        if (startKey.currentContext != null) {
          Navigator.popUntil(startKey.currentContext as BuildContext, (route) {
            if (route.settings.name == SanctionsScreen.routeName) {
              return false;
            } else {
              return true;
            }
          });
        }
      }
    });
  }

  void logOut() async {
    var authSate1 = await sanctionsController.logOut();
    authSate1.fold((failure) {
      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      }
    }, (authResponseEnity) async {
      Dependencies.clearDependencies();
      Navigator.of(startKey.currentContext as BuildContext)
          .popUntil((route) => route.isFirst);
    });
  }

  void unlockProfile() async {
    setUnlockProcessState = UnlockProcessState.inProcess;
    var result = await sanctionsController.unlockProfile();
    result.fold((failure) {
      setUnlockProcessState = UnlockProcessState.done;

      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        PresentationDialogs.instance.showErrorDialog(
            title: "Error",
            content: "Error de servidor",
            context: startKey.currentContext);
      }
    }, (success) async {
      setUnlockProcessState = UnlockProcessState.done;
      Dependencies.clearDependencies();
      await Dependencies.initializeDependencies();
    });
  }

  @override
  void clearModuleData() {
    _sanctionsScreenState = SanctionsScreenState.loading;
    _sanctionScreenMode = SanctionScreenMode.waitingModeration;
    _unlockProcessState = UnlockProcessState.done;

    sanctionsController.clearModuleData();
    updateSubscription?.cancel();
    updateSubscription = null;
  }

  @override
  void initializeModuleData() {
    sanctionsController.initializeModuleData();

    update();
  }

  @override
  void restart() {
    clearModuleData();
    initializeModuleData();
  }
}
