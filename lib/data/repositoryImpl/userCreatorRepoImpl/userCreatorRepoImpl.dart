import 'dart:async';

import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/data/Mappers/UserCreatorMapper.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/UserCreatorEntity.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/domain/repository/userCreatorRepo/userCreatorRepo.dart';

import '../../dataSources/userCreatorDataSource/userCreator.DataSource.dart';

class UserCreatorRepoImpl implements UserCreatorRepo {
  UserCreatorDataSource userCreatorDataSource;
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
        return Left(UserCreatorFailure(message: e.toString()));
      } else {
        return Left(NetworkFailure(message: e.toString()));
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
      if (e is UserCreatorException) {
        return Left(UserCreatorFailure(message: e.toString()));
      } else {
        return Left(NetworkFailure(message: e.toString()));
      }
    }
  }


  
  @override
  StreamController? streamParserController = new StreamController();
  
  @override
  StreamSubscription? streamParserSubscription;
  
  @override
  // TODO: implement getStreamParserController
  StreamController? get getStreamParserController => streamParserController;
  
  @override
  void parseStreams() {
    if(userCreatorDataSource.userCreatorDataStream!=null){
    streamParserSubscription= userCreatorDataSource.userCreatorDataStream!.stream.listen((event) {
      UserCreatorEntity userCreatorEntity = UserCreatorMapper.fromMap(event);

      streamParserController?.add({"payload":"userCreatorEntity","data":userCreatorEntity});

    }, onError: (e){
      streamParserController?.addError(e);
    });
      
    }
  }
}
