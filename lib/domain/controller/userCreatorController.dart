import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/data/Mappers/UserCreatorMapper.dart';
import 'package:citasnuevo/data/repositoryImpl/userCreatorRepoImpl/userCreatorRepoImpl.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/UserCreatorEntity.dart';
import 'package:citasnuevo/domain/repository/userCreatorRepo/userCreatorRepo.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/Exceptions.dart';
import '../../core/error/Failure.dart';
import '../repository/DataManager.dart';

abstract class UserCreatorController
    implements ShouldControllerUpdateData, ModuleCleanerController {
  late UserCreatorEntity userCreatorEntity;
  void insertImageFile(Uint8List imageBytes, int index);
  void deleteImage(int index);
  Future<Either<Failure, bool>> createUser();
  Future<Either<Failure, bool>> logOut();
}

class UserCreatorControllerImpl implements UserCreatorController {
  UserCreatorRepo userCreatorRepo;
  late UserCreatorEntity userCreatorEntity;
  StreamSubscription? streamSubscription;

  @override
  StreamController? updateDataController = StreamController();
  UserCreatorControllerImpl({
    required this.userCreatorRepo,
  });

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      updateDataController?.close();
      streamSubscription?.cancel();
      updateDataController = null;
      streamSubscription = null;
      updateDataController = StreamController.broadcast();

      var result = userCreatorRepo.clearModuleData();
      return result;
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createUser() async {
    var result = await userCreatorRepo.createUser(
        userData: await UserCreatorMapper.toMap(this.userCreatorEntity));

    result.fold((l) {}, (r) {});
    return result;
  }

  void insertImageFile(Uint8List imageBytes, int index) {
    this
        .userCreatorEntity
        .userPicruresList[index]
        .setBytesPicture(uint8list: imageBytes);
    this.userCreatorEntity.userPicruresList[index].useFile = true;
  }

  void deleteImage(int index) {
    this.userCreatorEntity.userPicruresList[index].deleteImage();
  }

  void initializeListener() {
    streamSubscription =
        userCreatorRepo.getStreamParserController?.stream.listen((event) {
      String payloadType = event["payload"];

      if (payloadType == "userCreatorEntity") {
        this.userCreatorEntity = event["data"];
        updateDataController?.add(this.userCreatorEntity);
      }
    }, onError: (e) {
      updateDataController?.addError(e);
    });
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      initializeListener();

      var result = userCreatorRepo.initializeModuleData();

      return result;
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logOut() {
    return userCreatorRepo.logOut();
  }
}
