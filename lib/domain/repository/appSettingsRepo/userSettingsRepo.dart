import 'dart:async';

import 'package:citasnuevo/core/streamParser/streamPareser.dart';
import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../../../data/dataSources/userSettingsDataSource/userSettingsDataSource.dart';
import '../../controller/controllerDef.dart';
import '../DataManager.dart';

abstract class UserSettingsRepository implements ModuleCleanerRepository,StreamParser {
  late UserSettingsDataSource appSettingsDataSource;
  Future<Either<Failure, bool>> updateSettings(UserSettingsEntity userSettingsEntity);


  Future<Either<Failure, bool>> revertChanges();

}
