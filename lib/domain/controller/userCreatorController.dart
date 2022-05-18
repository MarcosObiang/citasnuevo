import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/data/Mappers/UserCreatorMapper.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/UserCreatorEntity.dart';
import 'package:citasnuevo/domain/repository/userCreatorRepo/userCreatorRepo.dart';
import 'package:dartz/dartz.dart';

import '../../core/dependencies/error/Failure.dart';
import '../repository/DataManager.dart';

abstract class UserCreatorController
    implements
        ShouldControllerUpdateData<UserCreatorInformationSender>,
        ModuleCleaner {
  late UserCreatorEntity userCreatorEntity;
  StreamController<UserCreatorInformationSender> get getDataStream;
  void insertImageFile(Uint8List imageBytes, int index);
  void deleteImage(int index);
  Future<Either<Failure, bool>> createUser();
  Future<Either<Failure, bool>> logOut();
}

class UserCreatorControllerImpl implements UserCreatorController {
  UserCreatorRepo userCreatorRepo;
  late UserCreatorEntity userCreatorEntity;
  late StreamSubscription streamSubscription;

  @override
  late StreamController<UserCreatorInformationSender> updateDataController;
  UserCreatorControllerImpl({
    required this.userCreatorRepo,
  });

  @override
  void clearModuleData() {
    updateDataController.close();
    streamSubscription.cancel();
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
    streamSubscription = getDataStream.stream.listen((event) {
      this.userCreatorEntity = new UserCreatorEntity(
          minBirthDate: event.minBirthDayInMilliseconds,
          userBio: event.userBio,
          userCharacteristics: event.userCharacteristic,
          userPicruresList: event.userPicruresList);
      updateDataController.add(event);
    });
  }

  @override
  void initializeModuleData() {
    initializeListener();

    userCreatorRepo.initializeModuleData();
    updateDataController = StreamController.broadcast();
  }

  @override
  StreamController<UserCreatorInformationSender> get getDataStream =>
      userCreatorRepo.getUserCreatorDataStream;

  @override
  Future<Either<Failure, bool>> logOut() {
    return userCreatorRepo.logOut();
  }
}
