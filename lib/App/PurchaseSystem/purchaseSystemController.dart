import 'dart:async';

import 'package:citasnuevo/App/ControllerBridges/PurchseSystemControllerBridge.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../DataManager.dart';
import '../controllerDef.dart';
import 'purchaseEntity.dart';
import 'purchasesystemRepository.dart';

abstract class PurchaseSystemController
    implements ModuleCleanerController, ShouldControllerUpdateData {
  late PurchaseSystemRepository purchaseSystemRepository;
  Future<Either<Failure, bool>> makePurchase({required String offerId});
  Future<Either<Failure, void>> openSubscriptionMenu();
    Future<Either<Failure, bool>> restorePurchases();


  late PurchaseEntity purchaseEntity;
}

class PurchaseSystemControllerImpl implements PurchaseSystemController {
  @override
  late PurchaseEntity purchaseEntity;
  StreamSubscription? streamSubscription;
  @override
  StreamController? updateDataController = StreamController();
  PurchaseSystemControllerBridge purchaseSystemControllerBridge;
  

  @override
  PurchaseSystemRepository purchaseSystemRepository;
  PurchaseSystemControllerImpl(
      {required this.purchaseSystemRepository,
      required this.purchaseSystemControllerBridge});

  void processPurchaseEntity() {
    streamSubscription = purchaseSystemRepository
        .getStreamParserController?.stream
        .listen((event) {
      String payloadType = event["payloadType"];
      if (payloadType == "purchaseSystemEvent") {
        this.purchaseEntity = event["data"];
        sendUpdateData(event);
        addDataToPrchaseSytemControllerBridge(data: {
          "data": {
            "price": this.purchaseEntity.cheapestProfuct.productPriceString,
            "isUserPremium":this.purchaseEntity.isUserPremium
          }
        });
      }
    }, onError: (error) {
      sendError(error);
    });
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      streamSubscription?.cancel();
      streamSubscription = null;
      updateDataController?.close();
      updateDataController = StreamController();
      return purchaseSystemRepository.clearModuleData();
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      processPurchaseEntity();
      return purchaseSystemRepository.initializeModuleData();
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  void addDataToPrchaseSytemControllerBridge(
      {required Map<String, dynamic> data}) {
    purchaseSystemControllerBridge.addInformation(information: data);
  }

  void sendUpdateData(dynamic data) {
    updateDataController?.add(data);
  }

  void sendError(dynamic data) {
    updateDataController?.addError(data);
  }

  @override
  Future<Either<Failure, bool>> makePurchase({required String offerId}) {
    return purchaseSystemRepository.makePurchase(offerId: offerId);
  }

  @override
  Future<Either<Failure, void>> openSubscriptionMenu() async {
    return await purchaseSystemRepository.openSubscriptionMenu();
  }
  
  @override
  Future<Either<Failure, bool>> restorePurchases()async {
        return await purchaseSystemRepository.restorePurchases();

  }
}
