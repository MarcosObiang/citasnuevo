import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/repository/userCreatorRepo/userCreatorRepo.dart';

import '../../dataSources/userCreatorDataSource/userCreator.DataSource.dart';

class UserCreatorRepoImpl implements UserCreatorRepo {
  UserCreatorDataSource userCreatorDataSource;
  UserCreatorRepoImpl({
    required this.userCreatorDataSource,
  });


  @override
  void clearModuleData() {
    userCreatorDataSource.clearModuleData();
  }

  @override
  Future<Either<Failure, bool>> createUser(
      {required Map<String, dynamic> userData}) async {
    try {
      bool result = await userCreatorDataSource.createUser(userData: userData);
      return Right(result);
    } catch (e) {
      if (e is UserCreatorException) {
        return Left(UserCreatorFailure());
      } else {
        return Left(NetworkFailure());
      }
    }
  }

  @override
  void initializeModuleData()async {
    userCreatorDataSource.initializeModuleData();
  }

  @override
  StreamController<UserCreatorInformationSender> get getUserCreatorDataStream => userCreatorDataSource.userCreatorDataStream;

  @override
  Future<Either<Failure, bool>> logOut() async{
    try {
      bool result = await userCreatorDataSource.logOut();
      return Right(result);
    } catch (e) {
      if (e is UserCreatorException) {
        return Left(UserCreatorFailure());
      } else {
        return Left(NetworkFailure());
      }
    }  }
}
