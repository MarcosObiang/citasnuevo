import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/Failure.dart';
import '../DataManager.dart';
import '../../core/streamParser/streamPareser.dart';
import 'UserSettingsEntity.dart';
import 'userSettingsDataSource.dart';

abstract class UserSettingsRepository implements ModuleCleanerRepository,StreamParser {
  late UserSettingsDataSource appSettingsDataSource;
  Future<Either<Failure, bool>> updateSettings(UserSettingsEntity userSettingsEntity);


  Future<Either<Failure, bool>> revertChanges();

}
