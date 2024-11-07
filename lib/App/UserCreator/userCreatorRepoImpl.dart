import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../core/error/Exceptions.dart';
import '../../core/error/Failure.dart';
import 'UserCreatorEntity.dart';
import 'UserCreatorMapper.dart';
import 'userCreator.DataSource.dart';
import 'userCreatorRepo.dart';


class UserCreatorRepoImpl implements UserCreatorRepo {
  UserCreatorDataSource userCreatorDataSource;
  @override
  StreamController? streamParserController = new StreamController();

  @override
  StreamSubscription? streamParserSubscription;

  @override
  StreamController? get getStreamParserController => streamParserController;
  UserCreatorRepoImpl({
    required this.userCreatorDataSource,
  });

  @override
  Future<Either<Failure, bool>> createUser(
      {required Map<String, dynamic> userData}) async {
    try {
      bool result = await userCreatorDataSource.createUser(userData: userData);
      return Right(result);
    } catch (e) {
      if (e is UserCreatorException) {
        return Left(UserCreatorFailure(message: e.message));
      }
      if (e is LocationServiceException) {
        return Left(LocationServiceFailure(message: e.message));
      } else {
        return Left(NetworkFailure(message: kNetworkErrorMessage));
      }
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      parseStreams();
      userCreatorDataSource.initializeModuleData();
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
      userCreatorDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logOut() async {
    try {
      bool result = await userCreatorDataSource.logOut();
      return Right(result);
    } catch (e) {
      if (e is Exception) {
        return Left(UserCreatorFailure(message: e.toString()));
      } else {
        return Left(NetworkFailure(message: e.toString()));
      }
    }
  }

  @override
  void parseStreams() {
    if (userCreatorDataSource.userCreatorDataStream != null) {
      streamParserSubscription =
          userCreatorDataSource.userCreatorDataStream!.stream.listen((event) {
        UserCreatorEntity userCreatorEntity = UserCreatorMapper.fromMap(event);

        streamParserController
            ?.add({"payload": "userCreatorEntity", "data": userCreatorEntity});
      }, onError: (e) {
        streamParserController?.addError(e);
      });
    }
  }

  @override
  Future<Either<Failure, Map<String,dynamic>>>
      requestLocationPermission() async {
    try {
      var result = await userCreatorDataSource.requestPermission();
      return Right(result);
    } catch (e) {
      return Left(LocationServiceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> goToAppSettings() async {
    try {
      var result = await userCreatorDataSource.goToLocationSettings();
      return Right(result);
    } catch (e) {
      return Left(LocationServiceFailure(message: e.toString()));
    }
  }
}
