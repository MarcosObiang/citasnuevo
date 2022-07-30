import 'dart:async';

import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/controller/rewardController.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/settingsRepository/SettingsRepository.dart';

abstract class SettingsController
    implements
        ShouldControllerUpdateData<SettingsInformationSender>,
        ExternalControllerDataSender<RewardController>,
        ModuleCleaner {
  late SettingsEntity? settingsEntity;
  late SettingsRepository settingsRepository;
  void initialize();
  void purchase(String productId, bool renewPurchase);
}

class SettingsControllerImpl implements SettingsController {
  @override
  SettingsEntity? settingsEntity;

  @override
  StreamController<SettingsInformationSender>? updateDataController =
      StreamController.broadcast();

  @override
  SettingsRepository settingsRepository;
  SettingsControllerImpl(
      {required this.settingsRepository,
      required this.controllerBridgeInformationSender});

  @override
  void initialize() {
    settingsRepository.settingsStream.stream.listen((event) {
      settingsEntity = event;
      exteralInformationSender();
      if (settingsEntity != null) {
        updateDataController?.add(SettingsInformationSender(
            settingsEntity: settingsEntity as SettingsEntity));
      }
    }, onError: (error) {
      updateDataController?.addError(error);
    });
  }

  @override
  void clearModuleData() {
    updateDataController?.close();
    updateDataController = new StreamController.broadcast();
    settingsRepository.clearModuleData();
  }

  @override
  void initializeModuleData() {
    initialize();

    settingsRepository.initializeModuleData();
  }

  void purchase(String productId, bool renewPurchase) {
    bool makePurchase = true;

    settingsEntity?.productInfoList.forEach((element) {
      if (productId == element.offerId) {
        if (element.productIsActive && renewPurchase == false) {
          makePurchase = false;
        }
      }
    });

    if (makePurchase) {
      settingsRepository.purchase(productId);
    }
  }

  @override
  ControllerBridgeInformationSender<RewardController>?
      controllerBridgeInformationSender;

  void exteralInformationSender() {
    String? productInfo = settingsEntity?.productInfoList
        .where((element) => element.productId == "premiumsemanal")
        .first
        .productPrice;
    if (productInfo != null) {
      controllerBridgeInformationSender
          ?.addInformation(information: {"data": productInfo});
    }
  }
}
