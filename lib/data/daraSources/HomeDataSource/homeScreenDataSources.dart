import 'dart:core';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/data/daraSources/principalDataSource/principalDataSource.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:dartz/dartz_unsafe.dart';
abstract class HomeScreenDataSource implements DataSource {
  /// Fetch profiles from the backend
  ///
  /// Throws [FetchProfilesException] when no users are found
  ///
  /// Throws [FetchProfilesException] when a generic error occurs during the process
  ///
  /// Throws [NetworkException] if there is no actual connection
  Future<List<Map<dynamic, dynamic>>> fetchProfiles();
  void subscribeToDataSourceStream();}
class HomeScreenDataSourceImpl implements HomeScreenDataSource {
  @override
  ApplicationDataSource source;
  HttpsCallable fetchProfilesCloudFunction =
      FirebaseFunctions.instance.httpsCallable("solicitarUsuarios");
  Map<String, dynamic> dataSourceStreamData = Map();
  HomeScreenDataSourceImpl({
    required this.source,
  }) {
    subscribeToDataSourceStream();
  }
  /// Fetch profiles from the backend, make sure to call [subscribeToDataSourceStream] first in the same object
  ///
  /// where you are going to call the [fetchProfiles] function
  ///
  /// Throws [FetchProfilesException] when there are no more profiles to show or if there is any error
  ///
  /// Throws [NetworkException] if there is no connection
  @override
  Future<List<Map<dynamic, dynamic>>> fetchProfiles() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        List<Map<dynamic, dynamic>> functionResult = [];
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
            functionResult.add(element as Map<dynamic, dynamic>);
          });
          return functionResult;
        } else {
          throw FetchProfilesException(message: "no_profiles_found");
        }
      } catch (e) {
        throw FetchProfilesException(message: e.toString());
      }
    } else {
      throw NetworkException();
    }
  }
  @override
  void subscribeToDataSourceStream() {
    dataSourceStreamData = source.getData;
    source.dataStream.stream.listen((event) {
      dataSourceStreamData = event;
    });
  }}
class FetchProfilesException implements Exception {
  String message;
  FetchProfilesException({
    required this.message,
  }) {
    print(message);
  }}