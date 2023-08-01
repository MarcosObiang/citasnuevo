import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../core/error/Exceptions.dart';
import '../../core/error/Failure.dart';
import 'VerificationTicketMapper.dart';
import 'verificationDataSource.dart';
import 'verificationRepository.dart';

class VerificationRepoImpl implements VerificationRepository {
  VerificationRepoImpl({
    required this.verificationDataSource,
  });
  @override
  Either<Failure, bool> clearModuleData() {
    try {
      streamParserController?.close();
      streamParserSubscription?.cancel();
      streamParserController = null;
      streamParserSubscription = null;
      streamParserController =  StreamController();
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
    }, onError: (error) {
      streamParserController!.addError(error);
    });
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      parseStreams();
      verificationDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestVerificationProcess() async {
    try {
      var result = await verificationDataSource.requestVerificationProcess();

      return Right(result);
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
      var result = await verificationDataSource.submitVerificationData(
          pictureBytes: byteData);

      return Right(result);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(VerificationFailure(message: e.toString()));
      }
    }
  }

  @override
  VerificationDataSource verificationDataSource;
}
