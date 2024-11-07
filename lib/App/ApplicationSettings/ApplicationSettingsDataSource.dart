import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import '../DataManager.dart';
import '../controllerDef.dart';
import '../../core/error/Exceptions.dart';
import '../../core/services/AuthService.dart';
import '../../core/globalData.dart';
import '../../core/platform/networkInfo.dart';
import '../MainDatasource/principalDataSource.dart';

abstract class ApplicationSettingsDataSource
    implements
        DataSource,
        AuthenticationSignOutCapacity,
        ModuleCleanerDataSource,
        NetwrokServices {
  /// Send the current state of app settings
  StreamController<Map<String, dynamic>>?
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
  StreamController<Map<String, dynamic>>? listenAppSettingsUpdate =
      new StreamController.broadcast();
  @override
  @override
  StreamSubscription? sourceStreamSubscription;
  @override
  NetworkInfoContract networkInfoContract;
  ApplicationDataSourceImpl(
      {required this.source,
      required this.authService,
      required this.networkInfoContract});

  @override
  void clearModuleData() {
    try {
      sourceStreamSubscription?.cancel();
      sourceStreamSubscription = null;

      listenAppSettingsUpdate?.close();
      listenAppSettingsUpdate = null;
      listenAppSettingsUpdate = new StreamController.broadcast();
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  void initializeModuleData() {
    try {
      subscribeToMainDataSource();
    } catch (e) {
      listenAppSettingsUpdate?.addError(e);

      throw ModuleInitializeException(message: e.toString());
    }
  }

  void _addDataToStream(Map<String, dynamic> data) {
    listenAppSettingsUpdate?.add({
      "maxDistance": data["userSettings"]["maxDistance"],
      "maxAge": data["userSettings"]["maxAge"],
      "minAge": data["userSettings"]["minAge"],
      "showCentimeters": data["userSettings"]["showCentimeters"],
      "showKilometers": data["userSettings"]["showKilometers"],
      "showBothSexes": data["userSettings"]["showBothSexes"],
      "showWoman": data["userSettings"]["showWoman"],
      "showProfile": data["userSettings"]["showProfile"]
    });
  }

  @override
  void subscribeToMainDataSource() {
    try {
      _addDataToStream(source.getData);
    } catch (e) {
      throw AppSettingsException(message: e.toString());
    }

    sourceStreamSubscription = source.dataStream?.stream.listen((event) {
      try {
        _addDataToStream(event);
      } catch (e) {
        listenAppSettingsUpdate?.addError(e);
      }
    }, onError: (error) {
      listenAppSettingsUpdate?.addError(error);
    });
  }

  @override
  Future<bool> updateAppSettings(Map<String, dynamic> data) async {
    if (await networkInfoContract.isConnected) {
      try {
        //)
          var response = await Dependencies.serverAPi.functions.createExecution(
            functionId: "appSettingsUpdate", body: jsonEncode(data));


        int status = response.responseStatusCode;
        String message = response.responseBody;
        if (status == 200) {
          return true;
        } else {
          throw AppSettingsException(message: message);
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
    listenAppSettingsUpdate?.add({
      "maxDistance": source.getData["userSettings"]["maxDistance"],
      "maxAge": source.getData["userSettings"]["maxAge"],
      "minAge": source.getData["userSettings"]["minAge"],
      "showCentimeters": source.getData["userSettings"]["showCentimeters"],
      "showKilometers": source.getData["userSettings"]["showKilometers"],
      "showBothSexes": source.getData["userSettings"]["showBothSexes"],
      "showWoman": source.getData["userSettings"]["showWoman"],
      "showProfile": source.getData["userSettings"]["showProfile"]
    });
  }

  @override
  Future<bool> deleteAccount() async {
    if (await networkInfoContract.isConnected == true) {
      try {

         Execution execution = await Dependencies.serverAPi.functions.createExecution(
            functionId: "deleteUser",
            body: jsonEncode({"userId": GlobalDataContainer.userId}));

       

    var response = jsonDecode(execution.responseBody);
        int status = response["executionCode"];
        String message = response["message"];
        if (status == 200) {
          await Dependencies.serverAPi.account.deleteIdentity(identityId: GlobalDataContainer.userId);
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
