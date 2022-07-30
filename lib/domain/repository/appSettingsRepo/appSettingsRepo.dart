import 'dart:async';

import 'package:citasnuevo/data/dataSources/appSettings/ApplicationSettingsDataSource.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';

import '../../../core/dependencies/error/Failure.dart';

abstract class AppSettingsRepository implements ModuleCleaner {
  late ApplicationSettingsDataSource appSettingsDataSource;
  Future<Either<Failure, bool>> updateSettings(Map<String,dynamic> data);
    Future<Either<Failure, bool>> deleteAccount();
    Future<Either<Failure,bool>> logOut();


  StreamController<ApplicationSettingsInformationSender>? get appSettingsStream;

}
