import 'dart:async';

import 'package:citasnuevo/core/streamParser/streamPareser.dart';
import 'package:citasnuevo/data/dataSources/sanctionsDataSource.dart/sanctionsDataSource.dart';
import 'package:citasnuevo/domain/entities/SanctionsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';

abstract class SanctionsRepository implements ModuleCleanerRepository,StreamParser{
  late SanctionsDataSource sanctionsDataSource;
    Future<Either<Failure,bool>> logOut();
    Future<Either<Failure,bool>> unlockProfile();

  
}