import 'dart:async';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:flutter/material.dart';

import '../../../Utils/dialogs.dart';
import '../../../main.dart';
import '../../DataManager.dart';
import '../../../Utils/presentationDef.dart';
import '../../../core/error/Exceptions.dart';
import '../purchaseSystemController.dart';

enum PurchaseSystemScreenState { LOADED, LOADING, ERROR }

enum PurchaseOperationState {
  WAITING,
  NOT_WAITING,
}

class PurchaseSystemPresentation extends ChangeNotifier
    implements ShouldUpdateData, Presentation, ModuleCleanerPresentation {
  PurchaseSystemScreenState purchaseSystemScreenState =
      PurchaseSystemScreenState.LOADING;
  StreamSubscription? updateSubscription;
  PurchaseSystemController purchaseSystemController;
  PurchaseOperationState purchaseOperationState =
      PurchaseOperationState.NOT_WAITING;
  PurchaseOperationState get getPurchaseOperationState =>
      this.purchaseOperationState;

  set setPurchaseOperationState(PurchaseOperationState purchaseOperationState) {
    this.purchaseOperationState = purchaseOperationState;
    notifyListeners();
  }

  set setPurchaseSystemScreenState(
      PurchaseSystemScreenState purchaseSystemScreenState) {
    this.purchaseSystemScreenState = purchaseSystemScreenState;
    notifyListeners();
  }

  PurchaseSystemPresentation({required this.purchaseSystemController});
  @override
  @override
  void clearModuleData() {
    try {
      updateSubscription?.cancel();
      updateSubscription = null;
      purchaseSystemController.clearModuleData();
      setPurchaseOperationState = PurchaseOperationState.NOT_WAITING;
      setPurchaseSystemScreenState = PurchaseSystemScreenState.LOADING;
    } catch (e) {
      setPurchaseSystemScreenState = PurchaseSystemScreenState.ERROR;

      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  void initializeModuleData() {
    try {
      update();

      purchaseSystemController.initializeModuleData();
    } catch (e) {
      setPurchaseSystemScreenState = PurchaseSystemScreenState.ERROR;

      throw ModuleInitializeException(message: e.toString());
    }
  }

  @override
  void restart() {
    try {
      setPurchaseSystemScreenState = PurchaseSystemScreenState.LOADING;

      clearModuleData();
      initializeModuleData();
    } catch (e) {
      setPurchaseSystemScreenState = PurchaseSystemScreenState.ERROR;

      throw ModuleInitializeException(message: e.toString());
    }
  }

  @override
  void update() {
    try {
      updateSubscription =
          purchaseSystemController.updateDataController?.stream.listen((event) {
        setPurchaseSystemScreenState = PurchaseSystemScreenState.LOADED;
      }, onError: (mesage) {
        setPurchaseSystemScreenState = PurchaseSystemScreenState.ERROR;
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void makePurchase({required String offerId}) async {
    setPurchaseOperationState = PurchaseOperationState.WAITING;

    var result = await purchaseSystemController.makePurchase(offerId: offerId);

    result.fold((l) {
      setPurchaseOperationState = PurchaseOperationState.NOT_WAITING;
      if (l is NetworkFailure) {
        PresentationDialogs.instance.showErrorDialog(
            content: "Hotty npuede conectarse a internet",
            context: startKey.currentContext,
            title: "Error");
      } else {
        PresentationDialogs.instance.showErrorDialog(
            content: "No se pudo realizar la operacion",
            context: startKey.currentContext,
            title: "Error");
      }
    }, (r) {
      setPurchaseOperationState = PurchaseOperationState.NOT_WAITING;
    });
  }

  void openSubscriptionMenu() async {
    var result = await purchaseSystemController.openSubscriptionMenu();

    result.fold((l) => null, (r) => null);
  }

  void restorePurchases() async {
    setPurchaseOperationState = PurchaseOperationState.WAITING;

    var result = await purchaseSystemController.restorePurchases();

    result.fold((l) {
      setPurchaseOperationState = PurchaseOperationState.NOT_WAITING;
      if (l is NetworkFailure) {
        PresentationDialogs.instance.showErrorDialog(
            content: "Hotty npuede conectarse a internet",
            context: startKey.currentContext,
            title: "Error");
      } else {
        PresentationDialogs.instance.showErrorDialog(
            content: "No se pudo realizar la operacion",
            context: startKey.currentContext,
            title: "Error");
      }
    }, (r) {
      setPurchaseOperationState = PurchaseOperationState.NOT_WAITING;
      PresentationDialogs.instance.showErrorDialog(
          content: "La compra ha sido restaurada",
          context: startKey.currentContext,
          title: "Compra restaurada");
    });
  }
}
