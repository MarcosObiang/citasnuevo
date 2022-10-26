import 'dart:async';

import 'package:async/async.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/data/Mappers/AplicationDataSettingsMapper.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/repository/appSettingsRepo/appSettingsRepo.dart';

import '../../../domain/repository/DataManager.dart';
import '../../dataSources/appSettings/ApplicationSettingsDataSource.dart';

class ApplicationSettingsRepositoryImpl implements AppSettingsRepository {
  @override
  ApplicationSettingsDataSource appSettingsDataSource;
  ApplicationSettingsRepositoryImpl({
    required this.appSettingsDataSource,
  });

  @override
  StreamController? streamParserController = new StreamController();

  @override
  StreamController? get getStreamParserController => streamParserController;

  @override
  StreamSubscription? streamParserSubscription;

  @override
  void parseStreams() {
    if (appSettingsDataSource.listenAppSettingsUpdate != null) {
      streamParserSubscription =
          appSettingsDataSource.listenAppSettingsUpdate?.stream.listen((event) {
        streamParserController
            ?.add(ApplicationSettingsMapper.fromMap(data: event));
      }, onError: (error) {
        streamParserController?.addError(error);
      });
    } else {
      throw AppSettingsException(message: kStreamParserNullError);
    }
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      streamParserSubscription?.cancel();
      streamParserController = null;
      streamParserController?.close();
      streamParserSubscription = null;
      streamParserController = new StreamController();
      appSettingsDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      appSettingsDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
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
  Future<Either<Failure, bool>> deleteAccount() async {
    try {
      var result = await appSettingsDataSource.deleteAccount();
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
  Future<Either<Failure, bool>> logOut() async {
    try {
      bool authData = await appSettingsDataSource.logOut();

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
    }
  }
}
