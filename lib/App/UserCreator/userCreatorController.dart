import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../DataManager.dart';
import '../controllerDef.dart';
import 'UserCreatorEntity.dart';
import 'UserCreatorMapper.dart';
import 'userCreatorRepo.dart';

abstract class UserCreatorController
    implements ShouldControllerUpdateData, ModuleCleanerController {
  late UserCreatorEntity userCreatorEntity;
  void insertImageFile(Uint8List imageBytes, int index);
  void deleteImage(int index);
  Future<Either<Failure, bool>> createUser();
  Future<Either<Failure, bool>> logOut();

  ///
  ///
  /// Request location permission to the user
  ///
  Future<Either<Failure, Map<String,dynamic>>> requestPermission();

  /// Opens the system settings to activate location
  ///
  /// When the user has permanently denied the location service to the app
  ///
  /// the location must permission must be given to the app in the system settings
  Future<Either<Failure, bool>> goToLocationSettings();
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
      updateDataController = StreamController();

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
  Future<Either<Failure, Map<String,dynamic>>> requestPermission() async {
    return await userCreatorRepo.requestLocationPermission();
  }

  @override
  Future<Either<Failure, bool>> goToLocationSettings() async {
    return await userCreatorRepo.goToAppSettings();
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
