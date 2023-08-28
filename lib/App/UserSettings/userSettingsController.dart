import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../DataManager.dart';
import '../controllerDef.dart';
import 'UserSettingsEntity.dart';
import 'UserSettingsToSettingsControllerBridge.dart';
import 'userSettingsRepo.dart';

abstract class UserSettingsController
    implements ShouldControllerUpdateData, ModuleCleanerController {
  late UserSettingsRepository userSettingsRepository;
  late UserSettingsToSettingsControllerBridge
      userSettingsToSettingsControllerBridge;
  late UserSettingsEntity userSettingsEntity;
  late UserSettingsEntity userSettingsEntityUpdate;
  void insertImageFile(Uint8List imageBytes, int index);
  void deleteImage(int index);
  Future<Either<Failure, bool>> updateSettings();
  void sendInformationViaBridge();
  void revertChanges();
}

class UserSettingsControllerImpl implements UserSettingsController {
  UserSettingsRepository userSettingsRepository;

  UserSettingsControllerImpl(
      {required this.userSettingsRepository,
      required this.userSettingsToSettingsControllerBridge});
  late UserSettingsEntity userSettingsEntity;
  late UserSettingsEntity userSettingsEntityUpdate;
  bool userSettingsUpdating = false;

  @override
  late StreamController<dynamic>? updateDataController =
      StreamController.broadcast();

  UserSettingsToSettingsControllerBridge userSettingsToSettingsControllerBridge;

  void insertImageFile(Uint8List imageBytes, int index) {
    this
        .userSettingsEntity
        .userPicruresList[index]
        .setBytesPicture(uint8list: imageBytes);
    this.userSettingsEntity.userPicruresList[index].useFile = true;
  }

  void deleteImage(int index) {
    this.userSettingsEntity.userPicruresList[index].deleteImage();
  }

  Future<Either<Failure, bool>> updateSettings() async {
    userSettingsUpdating = true;
    sendInformationViaBridge();

    Either<Failure, bool> settings =
        await userSettingsRepository.updateSettings(userSettingsEntity);

    settings.fold((l) {
      userSettingsUpdating = false;
      sendInformationViaBridge();

      revertChanges();
    }, (r) {
      userSettingsUpdating = false;
      sendInformationViaBridge();
    });

    return settings;
  }

  void initializeListener() async {
    userSettingsRepository.getStreamParserController?.stream.listen(
        (event) async {
      UserSettingsEntity userSettingsEntityData = event["payload"];
      userSettingsEntity = userSettingsEntityData;

      updateDataController!.add(event);
      userSettingsEntityUpdate = userSettingsEntity;
    }, onError: (error) {
      updateDataController!.addError(error);
    });
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      updateDataController?.close();
      updateDataController = null;
      updateDataController = new StreamController.broadcast();
      var result = userSettingsRepository.clearModuleData();
      return result;
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      initializeListener();
      var result = userSettingsRepository.initializeModuleData();
      return result;
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  void sendInformationViaBridge() {
    userSettingsToSettingsControllerBridge
        .addInformation(information: {"isUpdating": userSettingsUpdating});
  }

  void revertChanges() async {
    await userSettingsRepository.revertChanges();
  }
}
