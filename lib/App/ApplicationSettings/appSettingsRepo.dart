import 'dart:async';

import '../../core/platform/networkInfo.dart';
import '../DataManager.dart';
import '../../core/streamParser/streamPareser.dart';

import 'package:dartz/dartz.dart';

import '../../core/error/Failure.dart';
import 'ApplicationSettingsDataSource.dart';
import 'ApplicationSettingsEntity.dart';

abstract class AppSettingsRepository
    implements
        ModuleCleanerRepository,
        StreamParser,
        UsesMapper<ApplicationSettingsEntity> {
  late ApplicationSettingsDataSource appSettingsDataSource;
  Future<Either<Failure, bool>> updateSettings(
      ApplicationSettingsEntity applicationSettingsEntity);
  Future<Either<Failure, bool>> deleteAccount();
  Future<Either<Failure, bool>> logOut();
}
