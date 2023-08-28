import 'dart:async';

import 'package:dartz/dartz.dart';

import '../DataManager.dart';
import '../Settings/SettingsToAppSettingsControllerBridge.dart';
import '../controllerDef.dart';
import '../../core/error/Failure.dart';
import 'ApplicationSettingsEntity.dart';
import 'appSettingsRepo.dart';

enum AppSettingsState { loading, updating, loaded, noLoaded }

abstract class AppSettingsController
    implements ShouldControllerUpdateData, ModuleCleanerController {
  late AppSettingsRepository appSettingsRepository;
  ApplicationSettingsEntity? applicationSettingsEntity;
  AppSettingsToSettingsControllerBridge? settingsToAppSettingsControllerBridge;
  StreamSubscription? streamParserSubscription;
  void initializeListener();
  Future<Either<Failure, bool>> updateAppSettings(
      ApplicationSettingsEntity applicationSettingsEntity);
  Future<Either<Failure, bool>> deleteAccount();
  Future<Either<Failure, bool>> logOut();
}

class AppSettingsControllerImpl implements AppSettingsController {
  AppSettingsRepository appSettingsRepository;
  ApplicationSettingsEntity? applicationSettingsEntity;
  AppSettingsToSettingsControllerBridge? settingsToAppSettingsControllerBridge;
  StreamSubscription? streamParserSubscription;

  @override
  late StreamController? updateDataController = StreamController.broadcast();
  AppSettingsControllerImpl(
      {required this.appSettingsRepository,
      required this.settingsToAppSettingsControllerBridge});

  void initializeListener() {
    try {
      streamParserSubscription = appSettingsRepository
          .getStreamParserController?.stream
          .listen((event) {
        try {
          String payloadType = event["payloadType"];
          if (payloadType == "applicationSettingsEntity") {
            applicationSettingsEntity = event["payload"];
            updateDataController?.add(applicationSettingsEntity);
          }
        } catch (e) {
          updateDataController?.addError(Exception(e.toString()));
        }
      }, onError: (error) {
        updateDataController?.addError(Exception(error.toString()));
      });
    } catch (e) {
      updateDataController?.addError(Exception(e.toString()));
      throw Exception();
    }
  }

  Future<Either<Failure, bool>> updateAppSettings(
      ApplicationSettingsEntity applicationSettingsEntity) async {
    sendInfo(updatingSettings: true);

    var result =
        await appSettingsRepository.updateSettings(applicationSettingsEntity);
    result.fold((l) {
      sendInfo(updatingSettings: false);
    }, (r) {
      sendInfo(updatingSettings: true);
    });
    return result;
  }

  Future<Either<Failure, bool>> deleteAccount() async {
    var result = await appSettingsRepository.deleteAccount();
    result.fold((l) {}, (r) {});
    return result;
  }

  Future<Either<Failure, bool>> logOut() async {
    var result = await appSettingsRepository.logOut();
    result.fold((l) {}, (r) {
      //    Dependencies.authRepository.logOut();
    });
    return result;
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      streamParserSubscription?.cancel();
      streamParserSubscription = null;
      updateDataController?.close();
      updateDataController = new StreamController.broadcast();

      var result = appSettingsRepository.clearModuleData();

      return result;
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      initializeListener();

      var result = appSettingsRepository.initializeModuleData();

      return result;
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  void sendInfo({required bool updatingSettings}) {
    settingsToAppSettingsControllerBridge
        ?.addInformation(information: {"updatingSettings": updatingSettings});
  }
}
