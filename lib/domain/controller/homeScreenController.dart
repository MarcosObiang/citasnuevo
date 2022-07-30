import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreenController
    implements
        Controller,
        ExteralControllerDataReciever<HomeScreenController>,
        ShouldControllerUpdateData<HomeScreenInformationSender> {
  List<Profile> profilesList = [];
  HomeScreenRepository homeScreenRepository;
  @override
  StreamController<HomeScreenInformationSender>? updateDataController =
      StreamController.broadcast();
  @override
  ControllerBridgeInformationReciever<HomeScreenController>
      controllerBridgeInformationReciever;
  StreamSubscription? controllerBridgeSubscription;
  int newReactions = 0;
  int newChats = 0;
  int newMessages = 0;
  HomeScreenController(
      {required this.homeScreenRepository,
      required this.controllerBridgeInformationReciever});
  get getProfilesList => this.profilesList;

  Future<Either<Failure, void>> fetchProfileList() async {
    bool succes = false;
    Failure failure = ServerFailure();
    var response = await homeScreenRepository.fetchProfiles();
    response.fold((fail) {
      succes = false;
      failure = fail;
    }, (profileData) {
      profileData.forEach((element) {
        bool profileExists = profileAlreadyExists(element);
        if (profileExists == false) {
          profilesList.add(element);
        }
      });

      succes = true;
    });
    if (succes) {
      return Right(profilesList);
    } else {
      return Left(failure);
    }
  }

  bool profileAlreadyExists(Profile profile) {
    bool exists = false;
    if (profilesList.isNotEmpty == true) {
      int index =
          profilesList.indexWhere((element) => element.id == profile.id);
      if (index >= 0) {
        exists = true;
      }
    }
    return exists;
  }

  Profile removeProfileFromList({required int profileIndex}) {
    return profilesList.removeAt(profileIndex);
  }

  void insertAtList({required Profile profile}) {
    profilesList.insert(0, profile);
  }

  Future<Either<Failure, void>> sendRating(
      {required double ratingValue, required String idProfileRated}) async {
    profilesList.removeWhere((element) => element.id == idProfileRated);
    return await homeScreenRepository.sendRating(
        ratingValue: ratingValue, idProfileRated: idProfileRated);
  }

  Future<Either<Failure, LocationPermission>> requestPermission() async {
    return await homeScreenRepository.requestLocationPermission();
  }

  Future<Either<Failure, bool>> goToLocationSettings() async {
    return await homeScreenRepository.goToAppSettings();
  }

  @override
  void clearModuleData() {
    profilesList.clear();
    updateDataController?.close();
    controllerBridgeSubscription?.cancel();
    controllerBridgeInformationReciever.closeStream();
    homeScreenRepository.clearModuleData();
  }

  @override
  void initializeModuleData() {
    updateDataController = StreamController.broadcast();
    controllerBridgeInformationReciever.initializeStream();

    homeScreenRepository.initializeModuleData();
    listenControllerBridge();
  }

  void listenControllerBridge() {
    controllerBridgeSubscription = controllerBridgeInformationReciever
        .controllerBridgeInformationSenderStream.stream
        .listen((event) {
      if (event["header"] == "reaction") {
        newReactions = event["data"];
        updateDataController?.add(HomeScreenInformationSender(
            information: {"reaction": newReactions}));
      }
      if (event["header"] == "chat") {
        newChats = event["data"];
        updateDataController?.add(HomeScreenInformationSender(information: {
          "chat": newChats,
        }));
      }
      if (event["header"] == "message") {
        newMessages = event["data"];
        updateDataController?.add(HomeScreenInformationSender(information: {
          "message": newMessages,
        }));
      }
    });
  }
}
