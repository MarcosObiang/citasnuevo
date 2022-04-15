import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/data/Mappers/UserSettingsMapper.dart';

import '../entities/UserSettingsEntity.dart';
import '../repository/DataManager.dart';
import '../repository/appSettingsRepo/userSettingsRepo.dart';
import 'controllerDef.dart';

class UserSettingsController
    implements
        ShouldControllerUpdateData<UserSettingsInformationSender>,
        ModuleCleaner {
  UserSettingsRepository userSettingsRepository;

  UserSettingsController({required this.userSettingsRepository});
  late UserSettingsEntity userSettingsEntity;
  late UserSettingsEntity userSettingsEntityUpdate;

  @override
  late StreamController<UserSettingsInformationSender> updateDataController =
      StreamController.broadcast();

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

  void updateSettings() async {
    var data = await UserSettingsMapper.toMap(userSettingsEntity);

    userSettingsRepository.updateSettings(data);
  }

  void initializeListener() async {
    userSettingsRepository.appSettingsStream.stream.listen((event) async {
      userSettingsEntity = new UserSettingsEntity(
          userCharacteristics: event.userCharacteristic,
          userBio: event.userBio,
          userPicruresList: event.userPicruresList);
      updateDataController.add(event);
      userSettingsEntityUpdate = userSettingsEntity;

      
    }, onError: (error) {
      updateDataController.addError(error);
    });
  }

  @override
  void clearModuleData() {
    updateDataController.close();
    updateDataController = new StreamController.broadcast();
  }

  @override
  void initializeModuleData() {
    userSettingsRepository.initializeModuleData();
    initializeListener();
  }
}
