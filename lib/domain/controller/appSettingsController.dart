import 'dart:async';

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/domain/controller/SettingsController.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/controller_bridges/SettingsToAppSettingsControllerBridge.dart';
import 'package:citasnuevo/domain/entities/ApplicationSettingsEntity.dart';
import 'package:citasnuevo/domain/repository/appSettingsRepo/appSettingsRepo.dart';
import 'package:dartz/dartz.dart';

import '../../core/dependencies/error/Failure.dart';
import '../repository/DataManager.dart';

enum AppSettingsState { loading, updating, loaded, noLoaded }

class AppSettingsController
    implements
        ShouldControllerUpdateData<ApplicationSettingsInformationSender>,
        ModuleCleanerController {
  AppSettingsRepository appSettingsRepository;
   ApplicationSettingsEntity? applicationSettingsEntity;
  AppSettingsToSettingsControllerBridge? settingsToAppSettingsControllerBridge;

  @override
  late StreamController<ApplicationSettingsInformationSender>?
      updateDataController = StreamController.broadcast();
  AppSettingsController(
      {required this.appSettingsRepository,
      required this.settingsToAppSettingsControllerBridge});

  void initializeListener() {
    appSettingsRepository.appSettingsStream?.stream.listen((event) {
      applicationSettingsEntity = new ApplicationSettingsEntity(
          distance: event.distance,
          maxAge: event.maxAge,
          minAge: event.minAge,
          inCm: event.inCm,
          inKm: event.inKm,
          showBothSexes: event.showBothSexes,
          showWoman: event.showWoman,
          showProfile: event.showProfile);
      updateDataController?.add(event);
    }, onError: (error) {
      updateDataController?.addError(error);
    });
  }

  Future<Either<Failure, bool>> updateAppSettings(
      ApplicationSettingsEntity applicationSettingsEntity) async {
    sendInfo(updatingSettings: true);

    var result = await appSettingsRepository.updateSettings({
      "distanciaMaxima": applicationSettingsEntity.distance,
      "edadFinal": applicationSettingsEntity.maxAge,
      "edadInicial": applicationSettingsEntity.minAge,
      "enCm": applicationSettingsEntity.inCm,
      "enMillas": applicationSettingsEntity.inKm,
      "mostrarAmbosSexos": applicationSettingsEntity.showBothSexes,
      "mostrarMujeres": applicationSettingsEntity.showWoman,
      "mostrarPerfil": applicationSettingsEntity.showProfile
    });
    result.fold((l) {
      sendInfo(updatingSettings: false);
    }, (r) {
      sendInfo(updatingSettings: false);
    });
    return result;
  }

  Future<Either<Failure, bool>> deleteAccount() async {
    var result = await appSettingsRepository.deleteAccount();
    result.fold((l) {}, (r) {
      //    Dependencies.authRepository.logOut();
    });
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
