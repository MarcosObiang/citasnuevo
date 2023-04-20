import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../DataManager.dart';
import '../controllerDef.dart';
import 'SanctionsEntity.dart';
import 'sanctionsRepo.dart';

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
      String payloadType = event["payloadType"];


      if (sanctionsEntity == null) {
        sanctionsEntity = event["data"];
        sanctionsEntity?.sanctionTimerStart(
            actualTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch);
        updateDataController?.add(sanctionsEntity!);
      } else {
        if ((sanctionsEntity?.penalizationState !=
                event["data"].penalizationState) ||
            (sanctionsEntity?.sanctionTimeStamp !=
                event["data"].sanctionTimeStamp)) {
          sanctionsEntity?.disposeSanctionObject();
          sanctionsEntity = null;

          sanctionsEntity = event["data"];
          sanctionsEntity?.sanctionTimerStart(
              actualTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch);
          updateDataController?.add(sanctionsEntity!);
        }
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
