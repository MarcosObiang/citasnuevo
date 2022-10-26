import 'dart:async';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/data/Mappers/SanctionsMapper.dart';
import 'package:citasnuevo/data/dataSources/sanctionsDataSource.dart/sanctionsDataSource.dart';
import 'package:citasnuevo/domain/entities/SanctionsEntity.dart';
import 'package:citasnuevo/domain/repository/sanctionsRepo/sanctionsRepo.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Exceptions.dart';

class SanctionsRepoImpl implements SanctionsRepository {
  @override
  SanctionsDataSource sanctionsDataSource;
  SanctionsRepoImpl({
    required this.sanctionsDataSource,
  });

  @override
  StreamController? streamParserController = StreamController();

  @override
  StreamSubscription? streamParserSubscription;

  @override
  StreamController? get getStreamParserController =>
      this.streamParserController;

  @override
  void parseStreams() {
    if (this.sanctionsDataSource.sanctionsUpdate != null &&
        streamParserController != null) {
      streamParserSubscription =
          sanctionsDataSource.sanctionsUpdate!.stream.listen((event) {
        SanctionsEntity sanctionsEntity = SanctionMapper.fromMap(event);
        streamParserController!.add({
          "payloadType": "sanctionsEntity",
          "settingsEntity": sanctionsEntity
        });
      }, onError: (error) {
        streamParserController!.addError(error);
      });
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      parseStreams();
      sanctionsDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      streamParserController?.close();
      streamParserSubscription?.cancel();
      streamParserController = null;
      streamParserSubscription = null;
      streamParserController = new StreamController();
      sanctionsDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
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
