import 'dart:async';

import '../DataManager.dart';
import '../../core/streamParser/streamPareser.dart';

import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import 'sanctionsDataSource.dart';

abstract class SanctionsRepository implements ModuleCleanerRepository,StreamParser{
  late SanctionsDataSource sanctionsDataSource;
    Future<Either<Failure,bool>> logOut();
    Future<Either<Failure,bool>> unlockProfile();

  
}