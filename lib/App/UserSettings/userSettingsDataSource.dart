import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../../core/globalData.dart';
import '../DataManager.dart';
import '../MainDatasource/principalDataSource.dart';
import '../../core/error/Exceptions.dart';
import '../../core/params_types/params_and_types.dart';
import 'UserSettingsEntity.dart';

abstract class UserSettingsDataSource
    implements DataSource, ModuleCleanerDataSource {
  // ignore: close_sinks
  late StreamController<Map<String, dynamic>>? listenAppSettingsUpdate;

  Future<bool> updateAppSettings(Map<String, dynamic> data);
  Future<bool> revertChanges();
}

class UserSettingsDataSourceImpl implements UserSettingsDataSource {
  @override
  StreamController<Map<String, dynamic>>? listenAppSettingsUpdate =
      StreamController.broadcast();
  String? userID;

  @override
  ApplicationDataSource source;

  @override
  StreamSubscription? sourceStreamSubscription;
  UserSettingsDataSourceImpl({
    required this.source,
  });

  @override
  void clearModuleData() {
    try {
      sourceStreamSubscription?.cancel();
      listenAppSettingsUpdate?.close();
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
      throw ModuleInitializeException(message: e.toString());
    }
  }

  void _addData({required dynamic data}) {
    if (listenAppSettingsUpdate != null) {
      listenAppSettingsUpdate!.add(data);
    } else {
      throw Exception(kStreamParserNullError);
    }
  }

  @override
  void subscribeToMainDataSource() async {
    try {
      bool firstInitialized = true;

      _addData(data: source.getData);
      sourceStreamSubscription =
          source.dataStream?.stream.listen((event) async {
        try {
          _addData(data: event);

          if (firstInitialized == true) {
            _addData(data: event);
            firstInitialized = false;
          }
        } catch (e) {
          _addData(data: e);
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> updateAppSettings(Map<String, dynamic> data) async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        // var data = await UserSettingsMapper.toMap(userSettingsEntity);

        List<Map<String, dynamic>> pictureData = data["images"];

        String userBio = data["userBio"];

        for (int i = 0; i < pictureData.length; i++) {
          UserPicutreBoxState userPicutreBoxState = pictureData[i]["type"];
          String pictureIndex = pictureData[i]["index"];

          if (userPicutreBoxState == UserPicutreBoxState.pictureFromBytes) {
            Uint8List imageFile = pictureData[i]["data"];

            var imageData = base64Encode(imageFile);

            data["userPicture$pictureIndex"] = jsonEncode({
              "imageData": imageData,
              "index": pictureIndex,
              "removed": false,
            });
          }

          if (userPicutreBoxState == UserPicutreBoxState.pictureFromNetwork) {
            Uint8List imageFile = pictureData[i]["data"];
            var imageData = base64Encode(imageFile);

            data["userPicture$pictureIndex"] = jsonEncode({
              "imageData": imageData,
              "index": pictureIndex,
              "removed": false,
            });
          }
          if (userPicutreBoxState == UserPicutreBoxState.empty) {
            data["userPicture$pictureIndex"] = jsonEncode({
              "imageData": kNotAvailable,
              "index": pictureIndex,
              "removed": true,
            });
          }
        }
        data.remove("images");

        data["userId"] = GlobalDataContainer.userId;

        Execution execution = await Dependencies.serverAPi.functions
            .createExecution(functionId: "updateUserData", body: jsonEncode(data));



        int status = execution.responseStatusCode;
        String message = jsonDecode(execution.responseBody)["message"];

        if (status == 200) {
          return true;
        } else {
          _addData(data: source.getData);

          throw UserSettingsException(message: message);
        }
      } catch (e) {
        _addData(data: source.getData);
        throw UserSettingsException(message: e.toString());
      }
    } else {
      _addData(data: source.getData);
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> revertChanges() async {
    try {
      _addData(data: source.getData);
    } catch (e) {
      throw UserSettingsException(message: e.toString());
    }
    return true;
  }
}
