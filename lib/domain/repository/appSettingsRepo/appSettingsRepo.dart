import 'dart:async';

import 'package:citasnuevo/core/streamParser/streamPareser.dart';
import 'package:citasnuevo/data/dataSources/appSettings/ApplicationSettingsDataSource.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';

abstract class AppSettingsRepository implements ModuleCleanerRepository,StreamParser {
  late ApplicationSettingsDataSource appSettingsDataSource;
  Future<Either<Failure, bool>> updateSettings(Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteAccount();
  Future<Either<Failure, bool>> logOut();

}
