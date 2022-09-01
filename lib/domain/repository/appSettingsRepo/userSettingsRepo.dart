import 'dart:async';

import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:dartz/dartz.dart';

import '../../../core/dependencies/error/Failure.dart';
import '../../../data/dataSources/userSettingsDataSource/userSettingsDataSource.dart';
import '../../controller/controllerDef.dart';
import '../DataManager.dart';

abstract class UserSettingsRepository implements ModuleCleanerRepository {
  late UserSettingsDataSource appSettingsDataSource;
  Future<Either<Failure, bool>> updateSettings(UserSettingsEntity userSettingsEntity);

  StreamController<UserSettingsInformationSender> get appSettingsStream;

  Future<Either<Failure, bool>> revertChanges();

}
