import 'dart:async';

import 'package:citasnuevo/domain/controller/appSettingsController.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/controller/rewardController.dart';
import 'package:citasnuevo/domain/controller/userSettingsController.dart';
import 'package:citasnuevo/domain/controller_bridges/UserSettingsToSettingsControllerBridge.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/settingsRepository/SettingsRepository.dart';

import '../controller_bridges/RewardScreenControllerBridge.dart';
import '../controller_bridges/SettingsToAppSettingsControllerBridge.dart';

abstract class SettingsController
    implements
        ShouldControllerUpdateData<SettingsInformationSender>,
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

  AppSettingsToSettingsControllerBridge appSettingstoSettingscontrollerBridge;
  UserSettingsToSettingsControllerBridge userSettingsToSettingsControllerBridge;

  RewardScreenControllerBridge rewardScreenControllerBridge;
  @override
  SettingsRepository settingsRepository;
  bool isAppSettingsUpdating = false;
  bool isUserSettingsUpdating = false;
  SettingsControllerImpl(
      {required this.settingsRepository,
      required this.appSettingstoSettingscontrollerBridge,
      required this.rewardScreenControllerBridge,
      required this.userSettingsToSettingsControllerBridge});

  @override
  void initialize() {
    settingsRepository.settingsStream.stream.listen((event) {
      settingsEntity = event;
      appSettingstoSettingscontrollerBridge.initializeStream();
      userSettingsToSettingsControllerBridge.initializeStream();
      exteralInformationSender();
      externalInformationRecieverFromAppSettings();
      externalInformationRecieverFromUserSettings();
      if (settingsEntity != null) {
        updateDataController?.add(SettingsInformationSender(
            isUserSettingsUpdating: null,
            isAppSettingsUpdating: null,
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

  void exteralInformationSender() {
    String? productInfo = settingsEntity?.productInfoList
        .where((element) => element.productId == "premiumsemanal")
        .first
        .productPrice;
    if (productInfo != null) {
      appSettingstoSettingscontrollerBridge
          .addInformation(information: {"data": productInfo});
    }
  }

  void externalInformationRecieverFromAppSettings() {
    appSettingstoSettingscontrollerBridge
        .controllerBridgeInformationSenderStream?.stream
        .listen((event) {
      bool data = event["updatingSettings"];

      isAppSettingsUpdating = data;
      if (settingsEntity != null) {
        updateDataController?.add(SettingsInformationSender(
            isAppSettingsUpdating: data,
            isUserSettingsUpdating: null,
            settingsEntity: settingsEntity as SettingsEntity));
      }
    });
  }

  void externalInformationRecieverFromUserSettings() {
    userSettingsToSettingsControllerBridge
        .controllerBridgeInformationSenderStream?.stream
        .listen((event) {
      bool data = event["isUpdating"];

      isUserSettingsUpdating = data;
      if (settingsEntity != null) {
        updateDataController?.add(SettingsInformationSender(
            isAppSettingsUpdating: null,
            isUserSettingsUpdating: isUserSettingsUpdating,
            settingsEntity: settingsEntity as SettingsEntity));
      }
    });
  }
}
