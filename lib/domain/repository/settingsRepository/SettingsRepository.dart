import 'dart:async';

import 'package:citasnuevo/core/streamParser/streamPareser.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';

import '../../../data/dataSources/settingsDataSource/settingsDataSource.dart';

abstract class SettingsRepository implements ModuleCleanerRepository,StreamParser{

  late SettingsDataSource settingsDataSource;



  void purchase(String productId);


}