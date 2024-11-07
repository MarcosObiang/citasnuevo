import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/App/controllerDef.dart';
import '../DataManager.dart';
import '../../core/error/Exceptions.dart';
import '../../core/globalData.dart';
import '../../core/location_services/locatio_service.dart';
import '../MainDatasource/principalDataSource.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/dependencies/dependencyCreator.dart';

abstract class HomeScreenDataSource
    implements DataSource, ModuleCleanerDataSource {
  /// Fetch profiles from the backend
  ///
  /// Throws [FetchProfilesException] when no users are found
  ///
  /// Throws [FetchProfilesException] when a generic error occurs during the process
  ///
  /// Throws [NetworkException] if there is no actual connection
  Future<Map<dynamic, dynamic>> fetchProfiles();

  /// Sends ratings to the backend
  ///
  /// RETURNS: Returns a map with information about a new match if the profile that has been rated 5.0 points or more
  ///
  /// had also rated the user with 5.0 points or more
  ///
  /// Throws [RatingProfilesException] when a generic error occurs during the process
  ///
  /// Throws [NetworkException] if there is no actual connection
  ///
  ///
  Future<LocationPermission> requestPermission();
  Future<bool> goToLocationSettings();

  /// Sends the profile rating the user has given to a profile
  ///
  Future<void> sendRating(
      {required int reactionValue, required String idProfileRated});

  Future<bool> setConsent({required bool cosent});
}

class HomeScreenDataSourceImpl implements HomeScreenDataSource {
  @override
  ApplicationDataSource source;

  Map<String, dynamic> dataSourceStreamData = Map();
  @override
  StreamSubscription? sourceStreamSubscription;
  HomeScreenDataSourceImpl({
    required this.source,
  });

  Future<Map<dynamic, dynamic>> _callProfilesFromTheServer({
    required Map<String, dynamic> positionData,
  }) async {
   /* Map<dynamic, dynamic> functionResult = Map();

    List<dynamic> profilesCache;

    final response = await Dependencies.serverAPi.app!.currentUser!.functions
        .call("fetchProfiles", [
      jsonEncode({
        "lat": positionData["lat"],
        "distance": 60,
        "lon": positionData["lon"],
        "userId": GlobalDataContainer.userId
      })
    ]);

    if (jsonDecode(response)["executionCode"] == 200) {
      profilesCache = jsonDecode(response)["payload"];

      functionResult["userData"] = source.getData;
      functionResult["profilesList"] = profilesCache;
      functionResult["todayDateTime"] = DateTime.now();
      return functionResult;
    } else if (response.status == "error") {
      if (response.status == "error_perfil_invisible") {
        throw FetchProfilesException(message: "PROFILE_NOT_VISIBLE");
      } else {
        throw FetchProfilesException(message: "INTERNAL_ERROR");
      }
    } else {
      throw FetchProfilesException(message: "PROFILES_FETCHING_FAILED");
    }*/ return {};
  }

  /// Fetch profiles from the backend, make sure to call [subscribeToMainDataSource] first in the same object
  ///
  /// where you are going to call the [fetchProfiles] function
  ///
  /// Throws [FetchProfilesException] when there are no more profiles to show or if there is any error
  ///
  /// Throws [NetworkException] if there is no connection
  @override
  Future<Map<dynamic, dynamic>> fetchProfiles() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        Map<String, dynamic> locationServicesStatus =
            await LocationService.instance.locationServicesState();

        if (locationServicesStatus["status"] == "correct") {
          Map<dynamic, dynamic> profileData = await _callProfilesFromTheServer(
              positionData: locationServicesStatus);
          return profileData;
        } else {
          throw LocationServiceException(
              message: locationServicesStatus["status"]);
        }
      } catch (e) {
        throw e;
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void subscribeToMainDataSource() {
    try {
      dataSourceStreamData = source.getData;
      sourceStreamSubscription = source.dataStream?.stream.listen((event) {
        dataSourceStreamData = event;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> sendRating(
      {required int reactionValue,
      required String idProfileRated}) async {
   /* if (await Dependencies.networkInfoContract.isConnected) {
      try {
        final response = await Dependencies
            .serverAPi.app!.currentUser!.functions
            .call("rateUsers", [
          jsonEncode({
            "recieverId": idProfileRated,
            "senderName": dataSourceStreamData["userName"],
            "userId": dataSourceStreamData["userId"],
            "reactionValue": reactionValue,
          })
        ]);
var responseParsed = jsonDecode(response);
        int statusCode = responseParsed["executionCode"];
        String message = responseParsed["message"];
        if (statusCode != 200) {
          throw Exception(message
          
          );
        }
      } catch (e) {
        if (e is AppwriteException) {
          throw RatingProfilesException(
              message: e.message ?? "PROFILE_RATING_FAILED");
        } else {
          throw RatingProfilesException(message: 'PROFILE_RATING_FAILED');
        }
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/
  }

  @override
  void clearModuleData() {
    try {
      dataSourceStreamData = Map();
      sourceStreamSubscription?.cancel();
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  void initializeModuleData() {
    try {
      subscribeToMainDataSource();
    } catch (e) {
      throw ModuleInitializeException(message: e.toString());
    }
  }

  @override
  Future<LocationPermission> requestPermission() async {
    try {
      LocationPermission locationPermission =
          await LocationService.instance.requestLocationPermission();
      return locationPermission;
    } catch (e) {
      throw LocationServiceException(message: e.toString());
    }
  }

  @override
  Future<bool> goToLocationSettings() async {
    try {
      bool openSettings = await LocationService.instance.gotoLocationSettings();
      return openSettings;
    } catch (e) {
      throw LocationServiceException(message: e.toString());
    }
  }

  @override
  Future<bool> setConsent({required bool cosent}) async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
       /* Functions functions = Functions(Dependencies.serverAPi.client!);

        Execution execution = await functions.createExecution(
            functionId: "setAdConsentStatus",
            body: jsonEncode({
              "userHasGivenConsent": cosent,
              "userId": GlobalDataContainer.userId
            }));*/

        int status = 200;

        if (status != 200) {
          throw Exception(["FAILED"]);
        } else {
          return true;
        }
      } catch (e) {
        throw ReactionException(
          message: e.toString(),
        );
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }
}
