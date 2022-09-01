import 'dart:async';
import 'dart:core';
import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/location_services/locatio_service.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:flutter/animation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/common/commonUtils/getUserImage.dart';
import '../../../domain/repository/DataManager.dart';

abstract class HomeScreenDataSource implements DataSource,ModuleCleanerDataSource {
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


  

  Future<Map<dynamic, dynamic>> callProfilesFromTheServer({
    required Map<String, dynamic> positionData,
  }) async {
    Map<dynamic, dynamic> functionResult = Map();

    List<Map<dynamic, dynamic>> profilesCache = [];
    HttpsCallableResult result = await fetchProfilesCloudFunction.call({
      "edadFinal": dataSourceStreamData["Ajustes"]["edadFinal"],
      "edadInicial": dataSourceStreamData["Ajustes"]["edadInicial"],
      "ambosSexos": source.getData["Ajustes"]["mostrarAmbosSexos"],
      "sexo": dataSourceStreamData["Ajustes"]["mostrarMujeres"],
      "latitud": positionData["lat"],
      "longitud": positionData["lon"],
      "distancia": dataSourceStreamData["Ajustes"]["distanciaMaxima"] / 10
    });
    if (result.data["estado"] == "correcto") {
      List<Object?> objectResult = result.data["mensaje"];
      objectResult.forEach((element) {
        profilesCache.add(element as Map<dynamic, dynamic>);
      });

      functionResult["userCharacteristicsData"] =
          source.getData["filtros usuario"];
      functionResult["profilesList"] = profilesCache;
      functionResult["todayDateTime"] = await DateNTP.instance.getTime();
      return functionResult;
    } else if (result.data["estado"] == "error") {
      if (result.data["mensaje"] == "error_perfil_invisible") {
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
        bool isLocationEnabled =
            await LocationService.instance.isLocationServiceEnabled();

        if (isLocationEnabled == true) {
          LocationPermission permission =
              await LocationService.instance.locationPermissionStatus();

          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            Map<String, dynamic> positionData =
                await LocationService.instance.determinePosition();
            Map<dynamic, dynamic> profileData =
                await callProfilesFromTheServer(positionData: positionData);
            return profileData;
          } else {
            if (permission == LocationPermission.deniedForever) {
              throw LocationServiceException(
                  message: "LOCATION_PERMISSION_DENIED_FOREVER");
            }
            if (permission == LocationPermission.denied) {
              throw LocationServiceException(
                  message: "LOCATION_PERMISSION_DENIED");
            } else {
              throw LocationServiceException(
                  message: "UNABLE_TO_DETERMINE_LOCATION_STATUS");
            }
          }
        } else {
          throw LocationServiceException(message: "LOCATION_SERVICE_DISABLED");
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
    dataSourceStreamData = source.getData;
    sourceStreamSubscription = source.dataStream.stream.listen((event) {
      dataSourceStreamData = event;
    });
  }

  @override
  Future<void> sendRating(
      {required double ratingValue, required String idProfileRated}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        await sendProfileRating.call({
          "idDestino": idProfileRated,
          "imagenEmisor": GetProfileImage.getProfileImage
              .getProfileImageMap(dataSourceStreamData)["image"],
          "nombreEmisor": dataSourceStreamData["Nombre"],
          "idEmisor": dataSourceStreamData["id"],
          "valoracion": ratingValue,
          "hash": GetProfileImage.getProfileImage
              .getProfileImageMap(dataSourceStreamData)["hash"]
        });
      } catch (e) {
        RatingProfilesException(message: 'PROFILE_RATING_FAILED');
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
