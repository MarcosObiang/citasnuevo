import 'dart:async';

import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/ApplicationSettingsEntity.dart';
import 'package:citasnuevo/domain/repository/appSettingsRepo/appSettingsRepo.dart';
import 'package:dartz/dartz.dart';

import '../../core/dependencies/error/Failure.dart';
import '../repository/DataManager.dart';

class AppSettingsController
    implements
        ShouldControllerUpdateData<ApplicationSettingsInformationSender>,
        ModuleCleaner {
  AppSettingsRepository appSettingsRepository;
  late ApplicationSettingsEntity applicationSettingsEntity;

  @override
  late StreamController<ApplicationSettingsInformationSender>
      updateDataController = StreamController.broadcast();
  AppSettingsController({
    required this.appSettingsRepository,
  });

  void initializeListener() {
    appSettingsRepository.appSettingsStream.stream.listen((event) {
      applicationSettingsEntity = new ApplicationSettingsEntity(
          distance: event.distance,
          maxAge: event.maxAge,
          minAge: event.minAge,
          inCm: event.inCm,
          inKm: event.inKm,
          showBothSexes: event.showBothSexes,
          showWoman: event.showWoman,
          showProfilePoints: event.showProfilePoints,
          showProfile: event.showProfile);
      updateDataController.add(event);
    });
  }

  Future<Either<Failure, bool>> updateAppSettings(
      ApplicationSettingsEntity applicationSettingsEntity) async {
    var result = await appSettingsRepository.updateSettings({
      "distanciaMaxima": applicationSettingsEntity.distance,
      "edadFinal": applicationSettingsEntity.maxAge,
      "edadInicial": applicationSettingsEntity.minAge,
      "enCm": applicationSettingsEntity.inCm,
      "enMillas": applicationSettingsEntity.inKm,
      "mostrarAmbosSexos": applicationSettingsEntity.showBothSexes,
      "mostrarMujeres": applicationSettingsEntity.showWoman,
      "mostrarNotaPerfil": applicationSettingsEntity.showProfilePoints,
      "mostrarPerfil": applicationSettingsEntity.showProfile
    });
    return result;
  }

  @override
  void clearModuleData() {
    updateDataController.close();
    updateDataController = new StreamController.broadcast();
  }

  @override
  void initializeModuleData() {
    appSettingsRepository.initializeModuleData();
    initializeListener();
  }
}
