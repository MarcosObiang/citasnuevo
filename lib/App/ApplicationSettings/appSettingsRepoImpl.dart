import 'dart:async';

import 'package:async/async.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/Exceptions.dart';
import '../../core/error/Failure.dart';
import '../../core/params_types/params_and_types.dart';
import '../../core/platform/networkInfo.dart';
import 'AplicationDataSettingsMapper.dart';
import 'ApplicationSettingsDataSource.dart';
import 'ApplicationSettingsEntity.dart';
import 'appSettingsRepo.dart';

class ApplicationSettingsRepositoryImpl implements AppSettingsRepository {
  @override
  ApplicationSettingsDataSource appSettingsDataSource;
  Mapper<ApplicationSettingsEntity> mapper;
  ApplicationSettingsRepositoryImpl(
      {required this.appSettingsDataSource, required this.mapper});

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
        try {
          ApplicationSettingsEntity applicationSettingsEntity =
              mapper.fromMap(event);
          streamParserController?.add({
            "payloadType": "applicationSettingsEntity",
            "payload": applicationSettingsEntity
          });
        } catch (e) {
          streamParserController?.addError(e);
        }
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
      streamParserController?.close();

      streamParserController = null;
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
      parseStreams();
      appSettingsDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateSettings(
      ApplicationSettingsEntity applicationSettingsEntity) async {
    try {
      var userData = mapper.toMap(applicationSettingsEntity);
      var result = await appSettingsDataSource.updateAppSettings(userData);
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
