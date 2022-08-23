import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/data/Mappers/UserSettingsMapper.dart';
import 'package:citasnuevo/domain/controller_bridges/UserSettingsToSettingsControllerBridge.dart';
import 'package:dartz/dartz.dart';

import '../../core/dependencies/error/Failure.dart';
import '../entities/UserSettingsEntity.dart';
import '../repository/DataManager.dart';
import '../repository/appSettingsRepo/userSettingsRepo.dart';
import 'controllerDef.dart';

class UserSettingsController
    implements
        ShouldControllerUpdateData<UserSettingsInformationSender>,
        ModuleCleaner {
  UserSettingsRepository userSettingsRepository;

  UserSettingsController(
      {required this.userSettingsRepository,
      required this.userSettingsToSettingsControllerBridge});
  late UserSettingsEntity userSettingsEntity;
  late UserSettingsEntity userSettingsEntityUpdate;
  bool userSettingsUpdating = false;

  @override
  late StreamController<UserSettingsInformationSender>? updateDataController =
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
    userSettingsRepository.appSettingsStream.stream.listen((event) async {
      userSettingsEntity = new UserSettingsEntity(
          userCharacteristics: event.userCharacteristic,
          userBio: event.userBio,
          userPicruresList: event.userPicruresList);
      updateDataController!.add(event);
      userSettingsEntityUpdate = userSettingsEntity;
    }, onError: (error) {
      updateDataController!.addError(error);
    });
  }

  @override
  void clearModuleData() {
    updateDataController!.close();
    updateDataController = new StreamController.broadcast();
  }

  @override
  void initializeModuleData() {
    userSettingsRepository.initializeModuleData();
    initializeListener();
  }

  void sendInformationViaBridge() {
    userSettingsToSettingsControllerBridge
        .addInformation(information: {"isUpdating": userSettingsUpdating});
  }

  void revertChanges() async {
    await userSettingsRepository.revertChanges();
  }
}
