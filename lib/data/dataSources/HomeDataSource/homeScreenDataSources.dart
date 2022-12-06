import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/location_services/locatio_service.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:flutter/animation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/common/commonUtils/getUserImage.dart';
import '../../../core/dependencies/dependencyCreator.dart';
import '../../../domain/repository/DataManager.dart';

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
      {required double ratingValue, required String idProfileRated});

  /// Sned a report to the current profile the user is rating
  Future<bool> sendReport(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails});
}

class HomeScreenDataSourceImpl implements HomeScreenDataSource {
  @override
  ApplicationDataSource source;
  HttpsCallable fetchProfilesCloudFunction =
      FirebaseFunctions.instance.httpsCallable("solicitarUsuarios");
  HttpsCallable sendProfileRating =
      FirebaseFunctions.instance.httpsCallable("darValoraciones");
  HttpsCallable reportUser =
      FirebaseFunctions.instance.httpsCallable("enviarDenuncia");
  Map<String, dynamic> dataSourceStreamData = Map();
  @override
  StreamSubscription? sourceStreamSubscription;
  HomeScreenDataSourceImpl({
    required this.source,
  });

  Future<Map<dynamic, dynamic>> _callProfilesFromTheServer({
    required Map<String, dynamic> positionData,
  }) async {
    Map<dynamic, dynamic> functionResult = Map();

    String profilesCache;
    Functions functions = Functions(Dependencies.serverAPi.client!);

    Execution execution = await functions.createExecution(
        functionId: "fetchUserProfiles",
        data: jsonEncode({
          "lat": positionData["lat"],
          "lon": positionData["lon"],
          "distance": 6,
          "userId": GlobalDataContainer.userId
        }));
    if (jsonDecode(execution.response)["status"] == "correct") {
      profilesCache = jsonDecode(execution.response)["payload"];

      functionResult["userData"] = source.getData;
      functionResult["profilesList"] = profilesCache;
      functionResult["todayDateTime"] = await DateNTP.instance.getTime();
      return functionResult;
    } else if (execution.status == "error") {
      if (execution.status == "error_perfil_invisible") {
        throw FetchProfilesException(message: "PROFILE_NOT_VISIBLE");
      } else {
        throw FetchProfilesException(message: "INTERNAL_ERROR");
      }
    } else {
      throw FetchProfilesException(message: "PROFILES_FETCHING_FAILED");
    }
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
    if (await NetworkInfoImpl.networkInstance.isConnected) {
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
      sourceStreamSubscription = source.dataStream.stream.listen((event) {
        dataSourceStreamData = event;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> sendRating(
      {required double ratingValue, required String idProfileRated}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);

        Execution execution = await functions.createExecution(
            functionId: "rateUsers",
            data: jsonEncode({
              "recieverId": idProfileRated,
              "userPicture": GetProfileImage.getProfileImage
                  .getProfileImageMap(dataSourceStreamData)["image"],
              "senderName": dataSourceStreamData["userName"],
              "userId": dataSourceStreamData["userId"],
              "reactionValue": ratingValue,
              "hash": GetProfileImage.getProfileImage
                  .getProfileImageMap(dataSourceStreamData)["hash"]
            }));

        print(execution);
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
    }
  }

  @override
  Future<bool> sendReport(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        await reportUser.call({
          "idDenunciado": idUserReported,
          "idDenunciante": idReporter,
          "detalles": reportDetails
        });
        return true;
      } catch (e) {
        throw ReportException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
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
}
