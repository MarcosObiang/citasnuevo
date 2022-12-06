import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/common/profileCharacteristics.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/core/location_services/locatio_service.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/UserCreatorMapper.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/globalData.dart';
import '../../../domain/repository/DataManager.dart';

abstract class UserCreatorDataSource
    implements
        DataSource,
        AuthenticationSignOutCapacity,
        ModuleCleanerDataSource {
  Future<bool> createUser({required Map<String, dynamic> userData});
  // ignore: close_sinks
  late StreamController<Map<String, dynamic>>? userCreatorDataStream;

  Future<void> getBlankUserProfile();
}

class UserCreatorDataSourceImpl implements UserCreatorDataSource {
  @override
  ApplicationDataSource source;
  @override
  late StreamController<Map<String, dynamic>>? userCreatorDataStream =
      StreamController.broadcast();
  @override
  StreamSubscription? sourceStreamSubscription;
  StreamSubscription? userCreatorDataStreamSubscription;
  @override
  AuthService authService;
  UserCreatorDataSourceImpl({required this.source, required this.authService});

  @override
  void clearModuleData() {
    try {
      sourceStreamSubscription?.cancel();
      userCreatorDataStream?.close();
      userCreatorDataStream = null;
      userCreatorDataStreamSubscription = null;
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  Future<bool> createUser({required Map<String, dynamic> userData}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected == true) {
      try {
        Map<String, dynamic> locationData =
            await LocationService.instance.locationServicesState();
        if (locationData["status"] == "correct") {
          Storage appwriteStorage = Storage(Dependencies.serverAPi.client!);
          Functions functions = Functions(Dependencies.serverAPi.client!);
          List<Map<String, dynamic>> userPictureList = userData["images"];
          Map<String, dynamic> dataToCloud = Map();
          dataToCloud["userPicture1"] = jsonEncode({
            "imageId": "empty",
            "hash": "empty",
            "index": "empty",
            "removed": true,
          });
          dataToCloud["userPicture2"] = jsonEncode({
            "imageId": "empty",
            "hash": "empty",
            "index": "empty",
            "removed": true,
          });
          dataToCloud["userPicture3"] = jsonEncode({
            "imageId": "empty",
            "hash": "empty",
            "index": "empty",
            "removed": true,
          });
          dataToCloud["userPicture4"] = jsonEncode({
            "imageId": "empty",
            "hash": "empty",
            "index": "empty",
            "removed": true,
          });
          dataToCloud["userPicture5"] = jsonEncode({
            "imageId": "empty",
            "hash": "empty",
            "index": "empty",
            "removed": true,
          });
          dataToCloud["userPicture6"] = jsonEncode({
            "imageId": "empty",
            "hash": "empty",
            "index": "empty",
            "removed": true,
          });
          String userBio = userData["userBio"];
          Map<String, dynamic> userFilters = userData["userFilters"];
          String userName = userData["userName"];
          int userAgeMills = userData["userAgeMills"];
          bool showWoman = userData["showWoman"];
          bool userPrefersBothSexes = userData["userPreferesBothSexes"];
          bool userIsWoman = userData["isUserWoman"];
          int maxDistance = userData["maxDistance"];
          int minAge = userData["minAge"];
          int maxAge = userData["maxAge"];
          bool useMeters = userData["useMeters"];
          bool useMilles = userData["useMilles"];

          for (int i = 0; i < userPictureList.length; i++) {
            UserPicutreBoxState userPicutreBoxState =
                userPictureList[i]["type"];
            String pictureIndex = userPictureList[i]["index"];

            if (userPicutreBoxState == UserPicutreBoxState.pictureFromBytes) {
              Uint8List imageFile = userPictureList[i]["data"];
              String pictureHash = userPictureList[i]["hash"];

              File result = await appwriteStorage.createFile(
                  bucketId: "63712fd65399f32a5414",
                  fileId:
                      "${GlobalDataContainer.userId}_image$pictureIndex",
                  file: InputFile(
                      bytes: imageFile,
                      filename:
                          "${GlobalDataContainer.userId}_image$pictureIndex.jpg"));

              String downloadUrl = result.$id;

              dataToCloud["userPicture$pictureIndex"] = jsonEncode({
                "imageId": downloadUrl,
                "hash": pictureHash,
                "index": pictureIndex,
                "removed": false,
              });
            }
          }
          dataToCloud["userId"] = GlobalDataContainer.userId;
          dataToCloud["userName"] = userName;
          dataToCloud["userSex"] = userIsWoman ? "female" : "male";
          dataToCloud["birthDateInMilliseconds"] = userAgeMills;
          dataToCloud["userBio"] = userBio;
          dataToCloud["email"] = GlobalDataContainer.userEmail;
          dataToCloud["positionLon"] = locationData["lon"];
          dataToCloud["positionLat"] = locationData["lat"];
          dataToCloud["userCharacteristics"] = jsonEncode(userFilters);
          dataToCloud["userSettings"] = jsonEncode({
            "maxDistance": maxDistance,
            "maxAge": maxAge,
            "minAge": minAge,
            "showCentimeters": useMeters,
            "showKilometers": useMilles,
            "showBothSexes": userPrefersBothSexes,
            "showWoman": showWoman,
            "showProfile": true
          });

          String json = jsonEncode(dataToCloud);
          Execution execution = await functions.createExecution(
              functionId: "createUser", data: json,xasync: false);

          if (execution.status == "correct") {
            return true;
          } else {
            throw Exception("USER_CREATOR_EXCEPTION");
          }
        } else {
          throw LocationServiceException(message: locationData["status"]);
        }
      } catch (e) {
        if (e is LocationServiceException) {
          throw LocationServiceException(message: e.toString());
        } else {
          throw UserCreatorException(message: e.toString());
        }
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void initializeModuleData() async {
    try {
      await getBlankUserProfile();
    } catch (e) {
      throw ModuleInitializeException(message: e.toString());
    }
  }

  @override
  void subscribeToMainDataSource() {
    // TODO: implement subscribeToMainDataSource
  }

  @override
  Future<void> getBlankUserProfile() async {
    DateTime dateTime = await _createMinDatetime();
    kUserCreatorMockData["minBirthDate"] = dateTime;
    userCreatorDataStream?.add(kUserCreatorMockData);
  }

  Future<DateTime> _createMinDatetime() async {
    DateTime actualTime = await DateNTP.instance.getTime();
    return actualTime.subtract(const Duration(days: 365 * 18));
  }

  @override
  Future<bool> logOut() async {
    try {
      Map<String, dynamic> userData = await authService.logOut();
      return true;
    } catch (e, s) {
      print(s);
      throw e;
    }
  }
}
