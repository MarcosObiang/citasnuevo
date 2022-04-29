import 'dart:async';
import 'dart:core';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';

import '../../../core/common/commonUtils/getUserImage.dart';

abstract class HomeScreenDataSource implements DataSource {
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

  Future<void> sendRating(
      {required double ratingValue, required String idProfileRated});

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
 late StreamSubscription sourceStreamSubscription;
  HomeScreenDataSourceImpl({
    required this.source,
  });

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
        Map<dynamic, dynamic> functionResult = Map();
        List<Map<dynamic, dynamic>> profilesCache = [];
        HttpsCallableResult result = await fetchProfilesCloudFunction.call({
          "edadFinal": dataSourceStreamData["Ajustes"]["edadFinal"],
          "edadInicial": dataSourceStreamData["Ajustes"]["edadInicial"],
          "ambosSexos": source.getData["Ajustes"]["mostrarAmbosSexos"],
          "sexo": dataSourceStreamData["Ajustes"]["mostrarMujeres"],
          "latitud": dataSourceStreamData["posicionLat"],
          "longitud": dataSourceStreamData["posicionLon"],
          "distancia": dataSourceStreamData["Ajustes"]["distanciaMaxima"]
        });
        if (result.data["estado"] == "correcto") {
          List<Object?> objectResult = result.data["mensaje"];
          objectResult.forEach((element) {
            profilesCache.add(element as Map<dynamic, dynamic>);
          });

          functionResult["userCharacteristicsData"] =
              source.getData["filtros usuario"];
          functionResult["profilesList"] = profilesCache;
          return functionResult;
        } else {
          throw FetchProfilesException(message: "PROFILES_FETCHING_FAILED");
        }
      } catch (e) {
        throw FetchProfilesException(message: e.toString());
      }
    } else {
      throw NetworkException();
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
      throw NetworkException();
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
      throw NetworkException();
    }
  }

  @override
  void clearModuleData() {
    dataSourceStreamData = Map();
    sourceStreamSubscription.cancel();
  }

  @override
  void initializeModuleData() {
    subscribeToMainDataSource();
  }


}