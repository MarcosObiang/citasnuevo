import 'dart:async';

import 'package:citasnuevo/App/ControllerBridges/PurchseSystemControllerBridge.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/Failure.dart';
import '../DataManager.dart';
import '../Rewards/RewardScreenControllerBridge.dart';
import '../UserSettings/UserSettingsToSettingsControllerBridge.dart';
import '../controllerDef.dart';
import 'SettingsEntity.dart';
import 'SettingsRepository.dart';
import 'SettingsToAppSettingsControllerBridge.dart';

abstract class SettingsController
    implements
        ShouldControllerUpdateData<SettingsInformationSender>,
        ModuleCleanerController {
  late SettingsEntity? settingsEntity;
  late SettingsRepository settingsRepository;
  void initialize();
}

class SettingsControllerImpl implements SettingsController {
  @override
  SettingsEntity? settingsEntity;

  @override
  StreamController<SettingsInformationSender>? updateDataController =
      StreamController.broadcast();

  AppSettingsToSettingsControllerBridge appSettingstoSettingscontrollerBridge;
  UserSettingsToSettingsControllerBridge userSettingsToSettingsControllerBridge;
  PurchaseSystemControllerBridge purchaseSystemControllerBridge;

  @override
  SettingsRepository settingsRepository;
  bool isAppSettingsUpdating = false;
  bool isUserSettingsUpdating = false;
  SettingsControllerImpl(
      {required this.settingsRepository,
      required this.appSettingstoSettingscontrollerBridge,
      required this.userSettingsToSettingsControllerBridge,
      required this.purchaseSystemControllerBridge});

  @override
  void initialize() {
    settingsRepository.getStreamParserController?.stream.listen((event) {
      String payloadType = event["payloadType"];
      settingsEntity = event["payload"];
      appSettingstoSettingscontrollerBridge.initializeStream();
      userSettingsToSettingsControllerBridge.initializeStream();
      externalInformationRecieverFromAppSettings();
      externalInformationRecieverFromUserSettings();
      externalInformationRecieverPurchaseSystem();
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
  Either<Failure, bool> clearModuleData() {
    try {
      updateDataController?.close();
      updateDataController = new StreamController.broadcast();
      var result = settingsRepository.clearModuleData();
      return result;
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      initialize();

      return settingsRepository.initializeModuleData();
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
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

  void externalInformationRecieverPurchaseSystem() {
    purchaseSystemControllerBridge
        .controllerBridgeInformationSenderStream?.stream
        .listen((event) {
      String data = event["data"]["price"];
      bool isPremium=event["data"]["isUserPremium"];

      if (settingsEntity != null) {
        settingsEntity!.subscriptionPrice = data;
        settingsEntity!.isUserPremium=isPremium;
        updateDataController?.add(SettingsInformationSender(
            isAppSettingsUpdating: false,
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
