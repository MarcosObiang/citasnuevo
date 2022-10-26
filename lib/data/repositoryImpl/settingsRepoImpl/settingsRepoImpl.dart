import 'dart:async';

import 'package:citasnuevo/data/Mappers/SettingsMapper.dart';
import 'package:citasnuevo/data/dataSources/settingsDataSource/settingsDataSource.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/settingsRepository/SettingsRepository.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';

class SettingsRepoImpl implements SettingsRepository {
  @override
  SettingsDataSource settingsDataSource;
   @override
  StreamController? streamParserController;
  
  @override
  StreamSubscription? streamParserSubscription;
  
  @override
  StreamController? get getStreamParserController => streamParserController;
  SettingsRepoImpl({
    required this.settingsDataSource,
  });


  @override
  Either<Failure,bool>  initializeModuleData()  {
    try {
      parseStreams();
      settingsDataSource.initializeModuleData();
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
      settingsDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
      
    }
  }

  @override
  void purchase(String productId) {
    settingsDataSource.purchaseSubscription(productId);
  } 
  
 
  
  @override
  void parseStreams() {
    if(this.settingsDataSource.onUserSettingsUpdate!=null&&streamParserController!=null){
      streamParserSubscription=settingsDataSource.onUserSettingsUpdate!.stream.listen((event) {
              SettingsEntity settingsEntity= SettingsMapper.fromMap(event);
              streamParserController!.add({"payloadType":"settingsEntity","settingsEntity":settingsEntity});

      },onError: (error){
        streamParserController!.addError(error);
      });
    }
  }
}
