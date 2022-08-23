import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/sanctionsDataSource.dart/sanctionsDataSource.dart';
import 'package:citasnuevo/domain/entities/SanctionsEntity.dart';
import 'package:citasnuevo/domain/repository/sanctionsRepo/sanctionsRepo.dart';
import 'package:dartz/dartz.dart';

import '../../../core/dependencies/error/Exceptions.dart';

class SanctionsRepoImpl implements SanctionsRepository {
  @override
  SanctionsDataSource sanctionsDataSource;
  SanctionsRepoImpl({
    required this.sanctionsDataSource,
  });

  @override
  void clearModuleData() {
    sanctionsDataSource.clearModuleData();
  }

  @override
  StreamController<SanctionsEntity>? get getSanctionsUpdate =>
      sanctionsDataSource.sanctionsUpdate;

  @override
  void initializeModuleData() {
    sanctionsDataSource.initializeModuleData();
  }

  @override
  Future<Either<Failure, bool>> logOut() async {
    // TODO: implement logOut
    try {
      bool authData = await sanctionsDataSource.logOut();

      return Right(authData);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      }
      if (e is AuthException) {
        return Left(AuthFailure(message: e.toString()));
      } else {
        return Left(ServerFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> unlockProfile() async {
    try {
      bool authData = await sanctionsDataSource.unlockProfile();

      return Right(authData);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(SanctionFailure(message: e.toString()));
      }
    }
  }
}
