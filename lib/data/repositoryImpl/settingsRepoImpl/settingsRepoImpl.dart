import 'dart:async';

import 'package:citasnuevo/data/dataSources/settingsDataSource/settingsDataSource.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/settingsRepository/SettingsRepository.dart';
import 'package:dartz/dartz.dart';

import '../../../core/dependencies/error/Failure.dart';

class SettingsRepoImpl implements SettingsRepository {
  @override
  SettingsDataSource settingsDataSource;
  SettingsRepoImpl({
    required this.settingsDataSource,
  });

  @override
  StreamController<SettingsEntity> get settingsStream =>
      settingsDataSource.onUserSettingsUpdate;

  @override
  Either<Failure,bool>  initializeModuleData()  {
    try {
      settingsDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
      
    }
  }

   @override
  Either<Failure,bool>  clearModuleData()  {
    try {
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
}
