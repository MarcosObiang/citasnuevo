import 'dart:async';

import 'package:citasnuevo/data/repositoryImpl/sanctionsRepoImpl/sanctionsRepoImpl.dart';
import 'package:citasnuevo/domain/entities/SanctionsEntity.dart';
import 'package:citasnuevo/domain/repository/sanctionsRepo/sanctionsRepo.dart';
import 'package:dartz/dartz.dart';

import '../../core/dependencies/error/Failure.dart';
import '../repository/DataManager.dart';
import 'controllerDef.dart';

abstract class SanctionsController
    implements ShouldControllerUpdateData<SanctionsEntity>, ModuleCleaner {
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
  void clearModuleData() {
    updateDataController?.close();
    sanctionsRepository.clearModuleData();
    streamSubscription?.cancel();
    streamSubscription = null;
    sanctionsEntity = null;
  }

  void listenSanctionsData() {
    streamSubscription =
        sanctionsRepository.getSanctionsUpdate?.stream.listen((event) {
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
  void initializeModuleData() {
    updateDataController = StreamController.broadcast();
    sanctionsRepository.initializeModuleData();

    listenSanctionsData();
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
