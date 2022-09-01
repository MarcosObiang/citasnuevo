import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
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
  Either<Failure,bool>  initializeModuleData()  {
    try {
      appSettingsDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
      
    }
  }

   @override
  Either<Failure,bool>  clearModuleData()  {
    try {
      appSettingsDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
      
    }
  }

  @override
  Future<Either<Failure, bool>> updateSettings(
      UserSettingsEntity userSettingsEntity) async {
    try {
      var datas = await appSettingsDataSource.updateAppSettings(userSettingsEntity);
      if (datas) {
        return Right(datas);
      } else {
        return Left(UserSettingsFailure(message: "Error"));
      }
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(UserSettingsFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> revertChanges() async {
    try {
      var datas = await appSettingsDataSource.revertChanges();

      return Right(datas);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(UserSettingsFailure(message: e.toString()));
      }
    }
  }
}
