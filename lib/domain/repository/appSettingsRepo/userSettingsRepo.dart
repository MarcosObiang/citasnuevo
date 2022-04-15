import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../core/dependencies/error/Failure.dart';
import '../../../data/dataSources/userSettingsDataSource/userSettingsDataSource.dart';
import '../../controller/controllerDef.dart';
import '../DataManager.dart';

abstract class UserSettingsRepository implements ModuleCleaner {
  late UserSettingsDataSource appSettingsDataSource;
  Future<Either<Failure, bool>> updateSettings(Map<String,dynamic> data);

  StreamController<UserSettingsInformationSender> get appSettingsStream;

}
