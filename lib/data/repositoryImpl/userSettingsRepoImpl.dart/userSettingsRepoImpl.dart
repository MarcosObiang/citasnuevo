import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/userSettingsDataSource/userSettingsDataSource.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/repository/appSettingsRepo/userSettingsRepo.dart';

class UserSettingsRepoImpl implements UserSettingsRepository {
  @override
  UserSettingsDataSource appSettingsDataSource;
  UserSettingsRepoImpl({
    required this.appSettingsDataSource,
  });

  @override
  StreamController<UserSettingsInformationSender> get appSettingsStream =>
      appSettingsDataSource.listenAppSettingsUpdate;

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
      var datas = await appSettingsDataSource.updateAppSettings(data);
      if (datas) {
        return Right(datas);
      } else {
        return Left(UserSettingsFailure());
      }
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(UserSettingsFailure());
      }
    }
  }
}
