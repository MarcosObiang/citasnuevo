import 'dart:async';

import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/data/Mappers/UserSettingsMapper.dart';
import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/userSettingsDataSource/userSettingsDataSource.dart';
import 'package:citasnuevo/domain/repository/appSettingsRepo/userSettingsRepo.dart';

class UserSettingsRepoImpl implements UserSettingsRepository {
  @override
  UserSettingsDataSource appSettingsDataSource;
  UserSettingsRepoImpl({
    required this.appSettingsDataSource,
  });


        @override
  StreamController? streamParserController=StreamController();
  
  @override
  StreamSubscription? streamParserSubscription;
  
  @override
  StreamController? get getStreamParserController => streamParserController;

   @override
  Either<Failure,bool>  initializeModuleData()  {
    try {
      parseStreams();
      appSettingsDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
      
    }
  }

   @override
  Either<Failure,bool>  clearModuleData()  {
    try {
      streamParserController?.close();
      streamParserSubscription?.cancel();
      streamParserController=null;
      streamParserSubscription=null;
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
      var datas = await appSettingsDataSource.updateAppSettings( await UserSettingsMapper.toMap(userSettingsEntity));
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
streamParserSubscription=this.appSettingsDataSource.listenAppSettingsUpdate?.stream.listen((event) {
  streamParserController?.add(UserSettingsMapper.fromMap(event));
  
},onError: (error){
        streamParserController!.addError(error);
      });  }
}
