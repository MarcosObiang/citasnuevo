import 'dart:async';

import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/settingsRepository/SettingsRepository.dart';

abstract class SettingsController
    implements
        ShouldControllerUpdateData<SettingsInformationSender>,
        ModuleCleaner {
  late SettingsEntity settingsEntity;
  late SettingsRepository settingsRepository;
  void initialize();
  void purchase(String productId,bool renewPurchase);
}

class SettingsControllerImpl implements SettingsController {
  @override
  late SettingsEntity settingsEntity;

  @override
  late StreamController<SettingsInformationSender> updateDataController =
      StreamController.broadcast();

  @override
  SettingsRepository settingsRepository;
  SettingsControllerImpl({
    required this.settingsRepository,
  });

  @override
  void initialize() {
    settingsRepository.settingsStream.stream.listen((event) {
      settingsEntity = event;
      updateDataController
          .add(SettingsInformationSender(settingsEntity: settingsEntity));
    }, onError: (error) {
      updateDataController.addError(error);
    });
  }

  @override
  void clearModuleData() {
    updateDataController.close();
    updateDataController = new StreamController.broadcast();
    settingsRepository.clearModuleData();
  }

  @override
  void initializeModuleData() {
    initialize();
    settingsRepository.initializeModuleData();
  }

  void purchase(String productId,bool renewPurchase) {
    bool makePurchase = true;

    settingsEntity.productInfoList.forEach((element) {
      if (productId == element.offerId) {
        if (element.productIsActive&&renewPurchase==false) {
          makePurchase = false;
        }
      }
    });

    if (makePurchase) {
      settingsRepository.purchase(productId);
    }
  }
}
