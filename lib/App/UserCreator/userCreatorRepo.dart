import 'dart:async';

import '../../core/streamParser/streamPareser.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../DataManager.dart';

abstract class UserCreatorRepo
    implements ModuleCleanerRepository, StreamParser {
  Future<Either<Failure, bool>> createUser(
      {required Map<String, dynamic> userData});
  Future<Either<Failure, bool>> logOut();
  Future<Either<Failure, Map<String,dynamic>>> requestLocationPermission();
  Future<Either<Failure, bool>> goToAppSettings();
}
