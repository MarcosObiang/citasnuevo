import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

abstract class ApplicationSettingsDataSource
    implements DataSource, AuthenticationSignOutCapacity {
  /// Send the current state of app settings
  StreamController<ApplicationSettingsInformationSender>?
      // ignore: close_sinks
      listenAppSettingsUpdate;

  /// Updates the app setings in the server
  ///

  Future<bool> updateAppSettings(Map<String, dynamic> data);

  /// Reverts settings to it initial state
  ///
  /// If somethng goes wrong when trying to update the settings using [updateAppSettings]
  ///
  /// this method will revert the app settings to the state before attempting to update settings
  void revertChanges();

  /// Call to the server to delete the user
  Future<bool> deleteAccount();
}

class ApplicationDataSourceImpl implements ApplicationSettingsDataSource {
  @override
  ApplicationDataSource source;
  @override
  AuthService authService;
  @override
  StreamController<ApplicationSettingsInformationSender>?
      listenAppSettingsUpdate = new StreamController.broadcast();

  @override
  StreamSubscription? sourceStreamSubscription;
  ApplicationDataSourceImpl({required this.source, required this.authService});

  @override
  void clearModuleData() {
    sourceStreamSubscription?.cancel();
    sourceStreamSubscription = null;

    listenAppSettingsUpdate?.close();
    listenAppSettingsUpdate = null;
    listenAppSettingsUpdate = new StreamController.broadcast();
  }

  @override
  void initializeModuleData() {
    subscribeToMainDataSource();
  }

  @override
  void subscribeToMainDataSource() {
    try {
      listenAppSettingsUpdate?.add(ApplicationSettingsInformationSender(
          distance: source.getData["Ajustes"]["istanciaMaxima"],
          maxAge: source.getData["Ajustes"]["edadFinal"],
          minAge: source.getData["Ajustes"]["edadInicial"],
          inCm: source.getData["Ajustes"]["enCm"],
          inKm: source.getData["Ajustes"]["enMillas"],
          showBothSexes: source.getData["Ajustes"]["mostrarAmbosSexos"],
          showWoman: source.getData["Ajustes"]["mostrarMujeres"],
          showProfile: source.getData["Ajustes"]["mostrarPerfil"]));
    } catch (e) {
      throw AppSettingsException(message: e.toString());
    }

    sourceStreamSubscription = source.dataStream.stream.listen((event) {
      listenAppSettingsUpdate?.add(ApplicationSettingsInformationSender(
          distance: event["Ajustes"]["distanciaMaxima"],
          maxAge: event["Ajustes"]["edadFinal"],
          minAge: event["Ajustes"]["edadInicial"],
          inCm: event["Ajustes"]["enCm"],
          inKm: event["Ajustes"]["enMillas"],
          showBothSexes: event["Ajustes"]["mostrarAmbosSexos"],
          showWoman: event["Ajustes"]["mostrarMujeres"],
          showProfile: event["Ajustes"]["mostrarPerfil"]));
    }, onError: (error) {
      listenAppSettingsUpdate?.addError(error);
    });
  }

  @override
  Future<bool> updateAppSettings(Map<String, dynamic> data) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable appSettingsUpdateCloudFunction =
            FirebaseFunctions.instance.httpsCallable("editarAjustes");

        HttpsCallableResult httpsCallableResult =
            await appSettingsUpdateCloudFunction.call(data);
        if (httpsCallableResult.data["estado"] == "correcto") {
          return true;
        } else {
          throw AppSettingsException(message: "CLOUD_FUNCTION_ERROR");
        }
      } catch (e) {
        revertChanges();

        throw AppSettingsException(message: e.toString());
      }
    } else {
      revertChanges();

      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void revertChanges() {
    listenAppSettingsUpdate?.add(ApplicationSettingsInformationSender(
        distance: source.getData["Ajustes"]["distanciaMaxima"],
        maxAge: source.getData["Ajustes"]["edadFinal"],
        minAge: source.getData["Ajustes"]["edadInicial"],
        inCm: source.getData["Ajustes"]["enCm"],
        inKm: source.getData["Ajustes"]["enMillas"],
        showBothSexes: source.getData["Ajustes"]["mostrarAmbosSexos"],
        showWoman: source.getData["Ajustes"]["mostrarMujeres"],
        showProfile: source.getData["Ajustes"]["mostrarPerfil"]));
  }

  @override
  Future<bool> deleteAccount() async {
    if (await NetworkInfoImpl.networkInstance.isConnected == true) {
      try {
        HttpsCallable borrarUsuario =
            FirebaseFunctions.instance.httpsCallable("borrarUsuario");

        HttpsCallableResult httpsCallableResult =
            await borrarUsuario.call({"id": GlobalDataContainer.userId});
        if (httpsCallableResult.data["estado"] == "correcto") {
          await authService.logOut();
          return true;
        } else {
          throw AppSettingsException(message: "SERVER_ERROR");
        }
      } catch (e) {
        if (e is AuthException) {
          throw AuthException(message: e.toString());
        } else {
          throw AppSettingsException(message: e.toString());
        }
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> logOut() async {
    try {
      await authService.logOut();
      return true;
    } catch (e, s) {
      print(s);
      throw AuthException(message: e.toString());
    }
  }
}
