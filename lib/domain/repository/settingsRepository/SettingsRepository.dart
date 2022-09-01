import 'dart:async';

import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';

import '../../../data/dataSources/settingsDataSource/settingsDataSource.dart';

abstract class SettingsRepository implements ModuleCleanerRepository{

  late SettingsDataSource settingsDataSource;


  StreamController<SettingsEntity> get settingsStream;

  void purchase(String productId);


}