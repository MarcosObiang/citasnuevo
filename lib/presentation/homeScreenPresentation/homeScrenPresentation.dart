import 'dart:async';

import 'package:citasnuevo/core/common/common_widgets.dart/errorWidget.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/dialogs.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';

import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/profileWidget.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreenPresentation extends ChangeNotifier
    implements
        ShouldUpdateData<HomeScreenInformationSender>,
        Presentation,
        ModuleCleaner {
  HomeScreenPresentation({required this.homeScreenController});

  @override
  StreamSubscription<HomeScreenInformationSender>? updateSubscription;
  ProfileListState _profileListState = ProfileListState.empty;
  HomeScreenController homeScreenController;

  int _newChats = 0;
  int _newMessages = 0;
  int _newReactions = 0;

  set setNewChats(int value) {
    this._newChats = value;
    notifyListeners();
  }

  set profileListState(profileState) {
    _profileListState = profileState;
    notifyListeners();
  }

  set setNewMessages(int value) {
    this._newMessages = value;
    notifyListeners();
  }

  set setNewreactions(int value) {
    this._newReactions = value;
    notifyListeners();
  }

  int get getNewMessages => this._newMessages;

  int get getNewReactions => this._newReactions;

  int get getNewChats => this._newChats;

  ProfileListState get profileListState => this._profileListState;

  ///Call this method from widgets to send a reaction to a user
  ///
  ///Parameters:
  ///
  ///reactionValue: represented by a double between 1-10, it is how the user rates a profile
  ///
  ///
  ///
  ///listIndex: after reacting to a profile, we should know the index of the reaction in the reaction list
  ///
  ///so we can remove it from the reactionList in the controller and remove it also from the Screen
  ///
  ///constrains: to remove the reaction from the animated list, we need the reaction card size

  void sendReaction(
      double reactionValue, int listIndex, BoxConstraints constraints) async {
    Profile removedProfile =
        homeScreenController.removeProfileFromList(profileIndex: listIndex);

    HomeAppScreen.profilesKey.currentState?.removeItem(
        listIndex,
        (context, animation) => ProfileWidget(
              profile: removedProfile,
              boxConstraints: constraints,
              listIndex: listIndex,
              needRatingWidget: true,
              showDistance: true,
            ),
        duration: Duration(milliseconds: 300));

    if (homeScreenController.profilesList.length == 0) {
      getProfiles();
    }
    var result = await homeScreenController.sendRating(
        ratingValue: reactionValue, idProfileRated: removedProfile.id);
    result.fold((failure) {
      homeScreenController.insertAtList(profile: removedProfile);
      HomeAppScreen.profilesKey.currentState?.insertItem(0);

      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        PresentationDialogs.instance.showErrorDialog(
            title: "Error",
            content: "Error enviar reaccion",
            context: startKey.currentContext);
      }
    }, (succes) {});
  }

  /// Once the app checks for location permission and is denied, we could use this method to request permission
  ///
  /// to use the location services of the device.
  ///
  /// Caution:if the succes parameter is equal  to [LocationPermission.deniedForever]
  ///
  /// we cant ask for permission again,we should aswk the user to go into settings and give
  ///
  /// the location permission from there
  ///
  ///
  void requestPermission() async {
    var result = await homeScreenController.requestPermission();
    result.fold((failure) {}, (succes) {
      if (succes == LocationPermission.always ||
          succes == LocationPermission.whileInUse) {
        getProfiles();
      } else {
        if (succes == LocationPermission.deniedForever) {
          profileListState = ProfileListState.location_forever_denied;
          print("LOCATION_PERMISSION_DENIED_FOREVER");
          PresentationDialogs.instance.showErrorDialog(
              title: "Permiso de localizacion",
              content:
                  "La aplicacion no tiene permiso para acceder su ubicacion",
              context: startKey.currentContext);
        }

        if (succes == LocationPermission.denied) {
          profileListState = ProfileListState.location_denied;
          PresentationDialogs.instance.showErrorDialog(
              title: "Permiso de localizacion",
              content:
                  "La aplicacion no tiene permiso para acceder su ubicacion",
              context: startKey.currentContext);

          print("LOCATION_PERMISSION_DENIED");
        }

        if (succes == LocationPermission.unableToDetermine) {
          print("UNABLE_TO_DETERMINE_LOCATION_STATUS");
        }
      }
    });
  }

  /// When asking for location permission an the user denies it for ever, we should
  ///
  /// ask the user to go into settings and give the permission from there
  ///
  /// with this method we take the user to location settings

  void openLocationSettings() async {
    var result = await homeScreenController.goToLocationSettings();
    result.fold((failure) {
      PresentationDialogs.instance.showErrorDialog(
          title: "No se puede acceder a los ajustes de ubicacion",
          content:
              "Debes ir manualmente a los ajustes de localizacion de tu telefono y dar permiso a Hotty",
          context: startKey.currentContext);
    }, (succes) {
      if (succes == true) {
      } else {
        PresentationDialogs.instance.showErrorDialog(
            title: "No se puede acceder a los ajustes de ubicacion",
            content:
                "Debes ir manualmente a los ajustes de localizacion de tu telefono y dar permiso a Hotty",
            context: startKey.currentContext);
      }
    });
  }

  /// Method used go get users from the servers,
  ///
  /// this method also checks the location and the profile visibility, it returns error if
  ///
  /// location services are not enabled or if the app does not have permission to use it
  ///
  ///
  void getProfiles() async {
    profileListState = ProfileListState.loading;

    var fetchedList = await homeScreenController.fetchProfileList();

    fetchedList.fold((fail) {
      profileListState = ProfileListState.error;
      if (fail is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      }
      if (fail is LocationServiceFailure) {
        if (fail.message == "LOCATION_PERMISSION_DENIED_FOREVER") {
          profileListState = ProfileListState.location_forever_denied;
        }

        if (fail.message == "LOCATION_PERMISSION_DENIED") {
          profileListState = ProfileListState.location_denied;
          PresentationDialogs.instance.showErrorDialog(
              title: "Permiso de localizacion",
              content:
                  "La aplicacion no tiene permiso para acceder su ubicacion",
              context: startKey.currentContext);
        }

        if (fail.message == "UNABLE_TO_DETERMINE_LOCATION_STATUS") {
          profileListState = ProfileListState.location_status_unknown;
        }
        if (fail.message == "LOCATION_SERVICE_DISABLED") {
          profileListState = ProfileListState.location_disabled;
        }
      }
      if (fail is FetchUserFailure) {
        if (fail.message == "PROFILE_NOT_VISIBLE") {
          profileListState = ProfileListState.profile_not_visible;
        }
      }
    }, (succes) {
      if (homeScreenController.profilesList.isNotEmpty == true) {
        for (int a = 0; a < homeScreenController.profilesList.length; a++) {
          HomeAppScreen.profilesKey.currentState?.insertItem(0);
        }
        profileListState = ProfileListState.ready;
      } else {
        profileListState = ProfileListState.empty;
      }
    });
  }

  @override
  void restart() {
    clearModuleData();
    initializeModuleData();
  }

  @override
  void clearModuleData() {
    profileListState = ProfileListState.empty;
    updateSubscription?.cancel();
    updateSubscription = null;

    homeScreenController.clearModuleData();
  }

  @override
  void update() {
    updateSubscription =
        homeScreenController.updateDataController?.stream.listen((event) {
      if (event.information["chat"] != null) {
        setNewChats = event.information["chat"];
      }
      if (event.information["message"] != null) {
        setNewMessages = event.information["message"];
      }
      if (event.information["reaction"] != null) {
        setNewreactions = event.information["reaction"];
      }
    });
  }

  @override
  void initializeModuleData() {
    homeScreenController.initializeModuleData();
    update();
    getProfiles();
  }
}
