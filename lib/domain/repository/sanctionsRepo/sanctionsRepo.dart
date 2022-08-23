import 'dart:async';

import 'package:citasnuevo/data/dataSources/sanctionsDataSource.dart/sanctionsDataSource.dart';
import 'package:citasnuevo/domain/entities/SanctionsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';

import '../../../core/dependencies/error/Failure.dart';

abstract class SanctionsRepository implements ModuleCleaner{
  late SanctionsDataSource sanctionsDataSource;
    Future<Either<Failure,bool>> logOut();
    Future<Either<Failure,bool>> unlockProfile();

  StreamController<SanctionsEntity>? get getSanctionsUpdate;
  
}