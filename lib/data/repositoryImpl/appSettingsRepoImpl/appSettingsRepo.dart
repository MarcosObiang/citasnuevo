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
  StreamController<ApplicationSettingsInformationSender>?
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
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(AppSettingsFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAccount()async {
try {
      var result = await appSettingsDataSource.deleteAccount();
      return Right(result);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(AppSettingsFailure(message: e.toString()));
      }
    }  }

  @override
  Future<Either<Failure, bool>> logOut()async {
    // TODO: implement logOut
   try {
      bool authData =
          await appSettingsDataSource.logOut();

      return Right(authData);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      }
      if (e is AuthException) {
        return Left(AuthFailure(message: e.toString()));
      } else {
        return Left(ServerFailure(message: e.toString()));
      }
    }  }
}
