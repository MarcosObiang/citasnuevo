import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../controller_bridges/HomeScreenCotrollerBridge.dart';

class HomeScreenController
    implements
        Controller,
        ShouldControllerUpdateData<HomeScreenInformationSender> {
  @override
  StreamController<HomeScreenInformationSender>? updateDataController =
      StreamController.broadcast();
  List<Profile> profilesList = [];
  HomeScreenRepository homeScreenRepository;
  HomeScreenControllerBridge homeScreenControllerBridge;
  StreamSubscription? controllerBridgeSubscription;
  int newReactions = 0;
  int newChats = 0;
  int newMessages = 0;
  HomeScreenController(
      {required this.homeScreenRepository,
      required this.homeScreenControllerBridge});
  get getProfilesList => this.profilesList;

  /// this method calls the fetchProfiles method from the repository,
  ///
  /// it handels fails

  Future<Either<Failure, void>> fetchProfileList() async {
    bool succes = false;
    var response = await homeScreenRepository.fetchProfiles();
    response.fold((fail) {
      succes = false;
    }, (profileData) {
      profileData.forEach((element) {
        bool profileExists = profileAlreadyExists(element);
        if (profileExists == false) {
          profilesList.add(element);
        }
      });

      succes = true;
    });
    return response;
  
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
    homeScreenControllerBridge.closeStream();
    homeScreenRepository.clearModuleData();
  }

  @override
  void initializeModuleData() {
    updateDataController = StreamController.broadcast();
    homeScreenControllerBridge.initializeStream();

    homeScreenRepository.initializeModuleData();
    listenControllerBridge();
  }

  void listenControllerBridge() {
    controllerBridgeSubscription = homeScreenControllerBridge
        .controllerBridgeInformationSenderStream?.stream
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
