import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/repository/appSettingsRepo/appSettingsRepo.dart';

import '../../dataSources/appSettings/ApplicationSettingsDataSource.dart';

class ApplicationSettingsRepositoryImpl implements AppSettingsRepository {
  @override
  ApplicationSettingsDataSource appSettingsDataSource;
  ApplicationSettingsRepositoryImpl({
    required this.appSettingsDataSource,
  });

  @override
  // TODO: implement appSettingsStream
  StreamController<ApplicationSettingsInformationSender>
      get appSettingsStream => appSettingsDataSource.listenAppSettingsUpdate;

  @override
  void clearModuleData() {
    appSettingsDataSource.clearModuleData();
  }

  @override
  void initializeModuleData() {
    appSettingsDataSource.initializeModuleData();
  }

  @override
  Future<Either<Failure, bool>> updateSettings(
      Map<String, dynamic> data) async {
    try {
      var result = await appSettingsDataSource.updateAppSettings(data);
      return Right(result);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(AppSettingsFailure());
      }
    }
  }
}
