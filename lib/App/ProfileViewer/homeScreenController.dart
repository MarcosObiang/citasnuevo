import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../ControllerBridges/HomeScreenCotrollerBridge.dart';
import '../DataManager.dart';
import '../controllerDef.dart';
import '../../core/error/Failure.dart';
import 'ProfileEntity.dart';
import 'homeScreenRepo.dart';

abstract class HomeScreenController
    implements
        ModuleCleanerController,
        ShouldControllerUpdateData<HomeScreenInformationSender> {
  List<Profile> profilesList = [];
  late HomeScreenRepository homeScreenRepository;
  late HomeScreenControllerBridge homeScreenControllerBridge;
  late StreamSubscription? controllerBridgeSubscription;
  Profile removeProfileFromList({required int profileIndex});
  Future<Either<Failure, void>> fetchProfileList();
  Future<Either<Failure, void>> sendRating(
      {required ReactionType reactionType, required String idProfileRated});
  Future<Either<Failure, LocationPermission>> requestPermission();
  Future<Either<Failure, bool>> goToLocationSettings();
  void insertAtList({required Profile profile});
}

class HomeScreenControllerImpl implements HomeScreenController {
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
  HomeScreenControllerImpl(
      {required this.homeScreenRepository,
      required this.homeScreenControllerBridge});
  get getProfilesList => this.profilesList;

  /// this method calls the fetchProfiles method from the repository,
  ///
  /// it handels fails

  Future<Either<Failure, void>> fetchProfileList() async {
    var response = await homeScreenRepository.fetchProfiles();
    response.fold((fail) {}, (profileData) {
      profileData.forEach((element) {
        bool profileExists = profileAlreadyExists(element);
        if (profileExists == false) {
          profilesList.add(element);
        }
      });
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

  /// Removes profiel from the [profilesList]
  Profile removeProfileFromList({required int profileIndex}) {
    return profilesList.removeAt(profileIndex);
  }

  /// Inserts [profiles] objects into [profileList]
  ///
  ///
  void insertAtList({required Profile profile}) {
    profilesList.insert(0, profile);
  }

  /// Sends rating
  ///
  /// Sends rating after the user has rated the user in the [homeScreen]
  ///
  ///
  Future<Either<Failure, void>> sendRating(
      {required ReactionType reactionType,
      required String idProfileRated}) async {
    profilesList.removeWhere((element) => element.id == idProfileRated);
    return await homeScreenRepository.sendRating(
        reactionType: reactionType, idProfileRated: idProfileRated);
  }

  ///
  ///
  /// Request location permission to the user
  ///

  Future<Either<Failure, LocationPermission>> requestPermission() async {
    return await homeScreenRepository.requestLocationPermission();
  }

  /// Opens the system settings to activate location
  ///
  /// When the user has permanently denied the location service to the app
  ///
  /// the location must permission must be given to the app in the system settings

  Future<Either<Failure, bool>> goToLocationSettings() async {
    return await homeScreenRepository.goToAppSettings();
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      profilesList.clear();
      updateDataController?.close();
      controllerBridgeSubscription?.cancel();
      homeScreenControllerBridge.reinitializeStream();
      updateDataController = StreamController.broadcast();

      var result = homeScreenRepository.clearModuleData();

      return result;
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      listenControllerBridge();

      var result = homeScreenRepository.initializeModuleData();
      return result;
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  /// Recieves information from other controllers
  ///
  /// Information like the number of new chats, new reactions or new messages are needed in the [HomeScreenPresentation],
  ///
  /// to ascces to that information, instead of accesing directly to the variables of other controllers
  ///
  /// we listen to the information those controllers send via [ControllerBridge]
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
