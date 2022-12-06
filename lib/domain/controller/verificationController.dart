import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/data/Mappers/VerificationTicketMapper.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/VerificationTicketEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/verificationRepository/verificationRepository.dart';

abstract class VerificationController
    implements ModuleCleanerController, ShouldControllerUpdateData {
  late VerificationRepository verificationRepository;
  VerificationTicketEntity? verificationTicketEntity;
  Future<Either<Failure,bool>> requestNewVerificationProcess();
   Future<Either<Failure,bool>> submitVerificationPicture({required Uint8List byteData});
}

class VerificationControllerImpl implements VerificationController {
  @override
  StreamController? updateDataController = StreamController();

  @override
  VerificationRepository verificationRepository;

  Uint8List? userVerificationPicture;

  @override
  VerificationTicketEntity? verificationTicketEntity;
  VerificationControllerImpl({
    required this.verificationRepository,
  });


  @override
  Either<Failure, bool> clearModuleData() {
    try {
      updateDataController?.close();
      updateDataController = null;
      verificationTicketEntity = null;
      userVerificationPicture=null;
      updateDataController = StreamController();

      return verificationRepository.clearModuleData();
    } catch (e) {
      return Left(ModuleClearFailure(message: "${this.runtimeType}: $e"));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      _dataListener();
      return verificationRepository.initializeModuleData();
    } catch (e) {
      return Left(ModuleInitializeFailure(message: "${this.runtimeType}: $e"));
    }
  }



  void _dataListener() {
    verificationRepository.getStreamParserController?.stream.listen((event) {
      if (event != null) {
        verificationTicketEntity =
            VerificationTIcketMapper.fromMap(data: event);

        this.updateDataController?.add(verificationTicketEntity);

        print(verificationTicketEntity.toString());
      }
    });
  }
  
  @override
  Future<Either<Failure, bool>> requestNewVerificationProcess() {
    return verificationRepository.requestVerificationProcess();
  }
  
  @override
  Future<Either<Failure, bool>> submitVerificationPicture({required Uint8List byteData})async {
    return await verificationRepository.submitVerificationPicture(byteData: byteData);
   
  }
}
