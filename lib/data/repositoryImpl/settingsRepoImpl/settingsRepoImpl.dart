import 'dart:async';

import 'package:citasnuevo/data/dataSources/settingsDataSource/settingsDataSource.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/settingsRepository/SettingsRepository.dart';

class SettingsRepoImpl implements SettingsRepository {
  @override
  SettingsDataSource settingsDataSource;
  SettingsRepoImpl({
    required this.settingsDataSource,
  });

  @override
  StreamController<SettingsEntity> get settingsStream =>
      settingsDataSource.onUserSettingsUpdate;

  @override
  void clearModuleData() {
    settingsDataSource.clearModuleData();
  }

  @override
  void initializeModuleData() {
    settingsDataSource.initializeModuleData();
  }
}
