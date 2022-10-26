import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/data/Mappers/VerificationTicketMapper.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/verificationDataSource/verificationDataSource.dart';
import 'package:citasnuevo/domain/repository/verificationRepository/verificationRepository.dart';

class VerificationRepoImpl implements VerificationRepository {
  @override
  Either<Failure, bool> clearModuleData() {
    try {
            streamParserController?.close();
      streamParserSubscription?.cancel();
      streamParserController = null;
      streamParserSubscription = null;
      streamParserController = new StreamController();
      verificationDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  StreamController? streamParserController = StreamController();

  @override
  StreamSubscription? streamParserSubscription;

  @override
  StreamController? get getStreamParserController => streamParserController;

  @override
  void parseStreams() {
    streamParserSubscription =
        verificationDataSource.dataStream?.stream.listen((event) {
      streamParserController
          ?.add(VerificationTIcketMapper.fromMap(data: event!));
    },onError: (error){
        streamParserController!.addError(error);
      });
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      verificationDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  VerificationDataSource verificationDataSource;
  VerificationRepoImpl({
    required this.verificationDataSource,
  });

  @override
  Future<Either<Failure, bool>> requestVerificationProcess() async {
    try {
      await verificationDataSource.requestVerificationProcess();

      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(VerificationFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> submitVerificationPicture(
      {required Uint8List byteData}) async {
    try {
      await verificationDataSource.submitVerificationData(
          pictureBytes: byteData);

      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(VerificationFailure(message: e.toString()));
      }
    }
  }
}
