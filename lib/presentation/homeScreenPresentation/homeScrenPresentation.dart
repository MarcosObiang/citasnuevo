import 'dart:async';

import 'package:citasnuevo/core/common/common_widgets.dart/errorWidget.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/main.dart';
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
  ProfileListState _profileListState = ProfileListState.empty;
  HomeScreenController homeScreenController;
  int _newChats = 0;
  int _newMessages = 0;
  int _newReactions = 0;
  int get getNewChats => this._newChats;

  set setNewChats(int value) {
    this._newChats = value;
    notifyListeners();
  }

  int get getNewMessages => this._newMessages;

  set setNewMessages(int value) {
    this._newMessages = value;
    notifyListeners();
  }

  int get getNewReactions => this._newReactions;

  set setNewreactions(int value) {
    this._newReactions = value;
    notifyListeners();
  }

  @override
  late StreamSubscription<HomeScreenInformationSender>? updateSubscription;

  HomeScreenPresentation({required this.homeScreenController});
  get profileListState => this._profileListState;
  set profileListState(profileState) {
    _profileListState = profileState;
    notifyListeners();
  }

  ///Call this method from widgets to send a reaction to a user

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
        showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        showErrorDialog(
            title: "Error",
            content: "Error enviar reaccion",
            context: startKey.currentContext);
      }
    }, (succes) {});
  }

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
          showErrorDialog(
              title: "Permiso de localizacion",
              content:
                  "La aplicacion no tiene permiso para acceder su ubicacion",
              context: startKey.currentContext);
        }

        if (succes == LocationPermission.denied) {
          profileListState = ProfileListState.location_denied;
          showErrorDialog(
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

  void openLocationSettings() async {
    var result = await homeScreenController.goToLocationSettings();
    result.fold((failure) {
      showErrorDialog(
          title: "No se puede acceder a los ajustes de ubicacion",
          content:
              "Debes ir manualmente a los ajustes de localizacion de tu telefono y dar permiso a Hotty",
          context: startKey.currentContext);
    }, (succes) {
      if (succes == true) {
      } else {
        showErrorDialog(
            title: "No se puede acceder a los ajustes de ubicacion",
            content:
                "Debes ir manualmente a los ajustes de localizacion de tu telefono y dar permiso a Hotty",
            context: startKey.currentContext);
      }
    });
  }

  void getProfiles() async {
    showLoadingDialog();

    var fetchedList = await homeScreenController.fetchProfileList();

    fetchedList.fold((fail) {
      profileListState = ProfileListState.error;
      if (fail is NetworkFailure) {
        showNetworkErrorDialog(context: startKey.currentContext);
      }
      if (fail is LocationServiceFailure) {
        if (fail.message == "LOCATION_PERMISSION_DENIED_FOREVER") {
          profileListState = ProfileListState.location_forever_denied;
        }

        if (fail.message == "LOCATION_PERMISSION_DENIED") {
          profileListState = ProfileListState.location_denied;
          showErrorDialog(
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
      if(fail is FetchUserFailure){
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

  void showErrorDialogs(
      {required String errorName,
      required String errorMessage,
      required BuildContext context}) {
    showDialog(context: context, builder: (context) => NetwortErrorWidget());
  }

  @override
  void showLoadingDialog() {
    profileListState = ProfileListState.loading;
  }

  @override
  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }

  @override
  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {
    if (context != null) {
      showDialog(
          context: context,
          builder: (context) => GenericErrorDialog(
                content: content,
                title: title,
              ));
    }
  }

  @override
  void initialize() {
    initializeModuleData();
    getProfiles();
  }

  @override
  void restart() {
    clearModuleData();
    initialize();
  }

  @override
  void clearModuleData() {
    profileListState = ProfileListState.empty;
    updateSubscription?.cancel();

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
  }
}
