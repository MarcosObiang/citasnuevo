import 'dart:async';

import 'userSettingsRepo.dart';

import '../../core/error/Exceptions.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/Failure.dart';
import 'UserSettingsEntity.dart';
import 'UserSettingsMapper.dart';
import 'userSettingsDataSource.dart';

class UserSettingsRepoImpl implements UserSettingsRepository {
  @override
  UserSettingsDataSource appSettingsDataSource;
  UserSettingsRepoImpl({
    required this.appSettingsDataSource,
  });

  @override
  StreamController? streamParserController = StreamController();

  @override
  StreamSubscription? streamParserSubscription;

  @override
  StreamController? get getStreamParserController => streamParserController;

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
  Either<Failure, bool> clearModuleData() {
    try {
      streamParserController?.close();
      streamParserSubscription?.cancel();
      streamParserController = null;
      streamParserSubscription = null;
      streamParserController = StreamController();

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
      var datas = await appSettingsDataSource.updateAppSettings(
          await UserSettingsMapper.toMap(userSettingsEntity));
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

  @override
  void parseStreams() {
    streamParserSubscription = this
        .appSettingsDataSource
        .listenAppSettingsUpdate
        ?.stream
        .listen((event) async {
      UserSettingsEntity userSettingsEntity =
          await UserSettingsMapper.fromMap(event);
      streamParserController?.add(
          {"payloadType": "UserSettingsEntity", "payload": userSettingsEntity});
    }, onError: (error) {
      streamParserController!.addError(error);
    });
  }
}
