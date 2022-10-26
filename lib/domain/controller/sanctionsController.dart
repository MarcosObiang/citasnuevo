import 'dart:async';

import 'package:citasnuevo/data/repositoryImpl/sanctionsRepoImpl/sanctionsRepoImpl.dart';
import 'package:citasnuevo/domain/entities/SanctionsEntity.dart';
import 'package:citasnuevo/domain/repository/sanctionsRepo/sanctionsRepo.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/Failure.dart';
import '../repository/DataManager.dart';
import 'controllerDef.dart';

abstract class SanctionsController
    implements
        ShouldControllerUpdateData<SanctionsEntity>,
        ModuleCleanerController {
  late SanctionsEntity? sanctionsEntity;
  Future<Either<Failure, bool>> logOut();
  Future<Either<Failure, bool>> unlockProfile();

  late SanctionsRepository sanctionsRepository;
}

class SanctionsControllerImpl implements SanctionsController {
  SanctionsControllerImpl({required this.sanctionsRepository});
  @override
  SanctionsEntity? sanctionsEntity;
  @override
  SanctionsRepository sanctionsRepository;

  @override
  StreamController<SanctionsEntity>? updateDataController =
      StreamController.broadcast();

  StreamSubscription? streamSubscription;
  @override
  Either<Failure, bool> clearModuleData() {
    try {
      updateDataController?.close();
      streamSubscription?.cancel();
      streamSubscription = null;
      sanctionsEntity = null;
            updateDataController = StreamController.broadcast();

      var result = sanctionsRepository.clearModuleData();
      return result;
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  void listenSanctionsData() {
    streamSubscription =
        sanctionsRepository.getStreamParserController?.stream.listen((event) {
String payloadType=event["payloadType"];

if(payloadType=="sanctions"){
  
}

      if (sanctionsEntity == null) {
        sanctionsEntity = event;
        updateDataController?.add(event);
      }
      if ((sanctionsEntity?.isUserSanctioned != event.isUserSanctioned) ||
          (sanctionsEntity?.sanctionConfirmed != event.sanctionConfirmed) ||
          (sanctionsEntity?.sanctionTimeStamp != event.sanctionTimeStamp)) {
        sanctionsEntity?.disposeSanctionObject();
        sanctionsEntity = event;

        updateDataController?.add(event);
      }
    });
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      listenSanctionsData();
      var result = sanctionsRepository.initializeModuleData();
      return result;
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logOut() async {
    var result = await sanctionsRepository.logOut();
    result.fold((l) {}, (r) {
      //    Dependencies.authRepository.logOut();
    });
    return result;
  }

  @override
  Future<Either<Failure, bool>> unlockProfile() async {
    var result = await sanctionsRepository.unlockProfile();

    return result;
  }
}
