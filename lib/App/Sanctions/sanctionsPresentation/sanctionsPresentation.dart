import 'dart:async';

import 'sanctionsScreen.dart';

import '../../DataManager.dart';
import '../../../Utils/dialogs.dart';
import '../../../Utils/presentationDef.dart';
import '../../../main.dart';

import 'package:flutter/material.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../core/error/Failure.dart';
import '../SanctionsEntity.dart';
import '../sanctionsController.dart';

enum SanctionsScreenState { loading, loaded, error }

enum SanctionScreenMode {
  waitingModerationDone,
  waitingModeration,
  sanctioned,
  sanctionEnded
}

enum UnlockProcessState { done, inProcess }

class SanctionsPresentation extends ChangeNotifier
    implements
        ShouldUpdateData<SanctionsEntity>,
        Presentation,
        ModuleCleanerPresentation {
  SanctionsController sanctionsController;
  @override
  StreamSubscription<SanctionsEntity>? updateSubscription;

  SanctionsScreenState _sanctionsScreenState = SanctionsScreenState.loading;
  SanctionScreenMode _sanctionScreenMode = SanctionScreenMode.waitingModeration;
  UnlockProcessState _unlockProcessState = UnlockProcessState.done;
  PenalizationState? penalizationState;

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
      if (event.penalizationState == PenalizationState.IN_MODERATION_WAITING) {
        setSanctionScreenMode = SanctionScreenMode.waitingModeration;
      }
      if (event.penalizationState == PenalizationState.IN_MODERATION_DONE) {
        setSanctionScreenMode = SanctionScreenMode.waitingModerationDone;
      }
      if (event.penalizationState == PenalizationState.PENALIZED) {
        if (event.timeRemaining <= 0) {
          setSanctionScreenMode = SanctionScreenMode.sanctionEnded;
        }
        if (event.timeRemaining >= 0) {
          setSanctionScreenMode = SanctionScreenMode.sanctioned;
        }
      }
      if (event.penalizationState == PenalizationState.IN_MODERATION_WAITING ||
          event.penalizationState == PenalizationState.PENALIZED ||
          event.penalizationState == PenalizationState.IN_MODERATION_DONE) {
        Dependencies.clearDependenciesForSanction();
        if (sanctionKey.currentContext == null) {
          Navigator.pushNamed(startKey.currentContext as BuildContext,
              SanctionsScreen.routeName);
        }
      }
      if (event.penalizationState == PenalizationState.NOT_PENALIZED) {}
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
      Dependencies.clearDependenciesAndUserIdentifiers();
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
      Dependencies.clearDependenciesOnly();
      await Dependencies.initializeDependencies();

      Navigator.pop(startKey.currentContext as BuildContext);
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
