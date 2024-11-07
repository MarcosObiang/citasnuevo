import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../core/services/AuthService.dart';
import '../DataManager.dart';
import '../MainDatasource/principalDataSource.dart';
import '../UserSettings/UserSettingsEntity.dart';
import '../controllerDef.dart';
import '../../core/common/commonUtils/DateNTP.dart';
import '../../core/common/profileCharacteristics.dart';
import '../../core/dependencies/dependencyCreator.dart';
import '../../core/error/Exceptions.dart';
import '../../core/location_services/locatio_service.dart';
import '../../core/params_types/params_and_types.dart';

import 'package:geolocator/geolocator.dart';

import '../../../core/globalData.dart';

abstract class UserCreatorDataSource
    implements
        DataSource,
        AuthenticationSignOutCapacity,
        ModuleCleanerDataSource {
  Future<Map<String, dynamic>> requestPermission();
  Future<bool> goToLocationSettings();
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
      StreamController();
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
      userCreatorDataStreamSubscription?.cancel();
      userCreatorDataStream = null;
      userCreatorDataStreamSubscription = null;
      userCreatorDataStream = StreamController();
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  Future<bool> createUser({required Map<String, dynamic> userData}) async {
  /*  if (await Dependencies.networkInfoContract.isConnected == true) {
      try {
        Map<String, dynamic> locationData =
            await LocationService.instance.locationServicesState();
        if (locationData["status"] == "correct") {
          List<Map<String, dynamic>> userPictureList = userData["images"];
          Map<String, dynamic> dataToCloud = Map();
          dataToCloud["userPicture1"] = jsonEncode({
            "imageData": null,
            "index": 1,
          });
          dataToCloud["userPicture2"] = jsonEncode({
            "imageData": null,
            "index": 2,
          });
          dataToCloud["userPicture3"] = jsonEncode({
            "imageData": null,
            "index": 3,
          });
          dataToCloud["userPicture4"] = jsonEncode({
            "imageData": null,
            "index": 4,
          });
          dataToCloud["userPicture5"] = jsonEncode({
            "imageData": null,
            "index": 5,
          });
          dataToCloud["userPicture6"] = jsonEncode({
            "imageData": null,
            "index": 6,
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
          String promotionalCode = userData["promotionalCode"];

          for (int i = 0; i < userPictureList.length; i++) {
            UserPicutreBoxState userPicutreBoxState =
                userPictureList[i]["type"];
            String pictureIndex = userPictureList[i]["index"];

            if (userPicutreBoxState == UserPicutreBoxState.pictureFromBytes) {
              Uint8List imageFile = userPictureList[i]["data"];

              dataToCloud["userPicture$pictureIndex"] = jsonEncode({
                "imageData": base64Encode(imageFile.toList()),
                "index": int.parse(pictureIndex),
                "removed": false,
              });
            }
          }
          dataToCloud["userId"] = GlobalDataContainer.userId;
          dataToCloud["userName"] = userName;
          dataToCloud["userSex"] = userIsWoman ? "female" : "male";
          dataToCloud["userBirthDate"] = userAgeMills;
          dataToCloud["userBiography"] = userBio;
          dataToCloud["email"] = GlobalDataContainer.userEmail;
          dataToCloud["lon"] = locationData["lon"];
          dataToCloud["lat"] = locationData["lat"];

          dataToCloud["userCharacteristics_alcohol"] = userFilters["alcohol"];
          dataToCloud["userCharacteristics_what_he_looks_for"] =
              userFilters["im_looking_for"];
          dataToCloud["userCharacteristics_bodyType"] =
              userFilters["body_type"];
          dataToCloud["userCharacteristics_children"] = userFilters["children"];
          dataToCloud["userCharacteristics_pets"] = userFilters["pets"];
          dataToCloud["userCharacteristics_politics"] = userFilters["politics"];
          dataToCloud["userCharacteristics_lives_with"] =
              userFilters["im_living_with"];
          dataToCloud["userCharacteristics_smokes"] = userFilters["smoke"];
          dataToCloud["userCharacteristics_sexual_orientation"] =
              userFilters["sexual_orientation"];
          dataToCloud["userCharacteristics_zodiak"] =
              userFilters["zodiac_sign"];
          dataToCloud["userCharacteristics_personality"] =
              userFilters["personality"];
          dataToCloud["promotionalCodeUsedByUser"] = promotionalCode;
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

          final response = await Dependencies
              .serverAPi.app!.currentUser!.functions
              .call("createUser", [json]);

          int executionCode = jsonDecode(response)["executionCode"];
          String executionMessage = jsonDecode(response)["message"];

          if (executionCode == 200) {
            return true;
          } else {
            throw Exception(
                "USER_CREATOR_EXCEPTION $executionCode $executionMessage");
          }
        } else {
          throw LocationServiceException(message: locationData["status"]);
        }
      } catch (e) {
        if (e is LocationServiceException) {
          throw LocationServiceException(message: e.message);
        } else {
          throw UserCreatorException(message: e.toString());
        }
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/ return true;
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
      await authService.logOut();
      return true;
    } catch (e, s) {
      print(s);
      throw AuthException(message: e.toString());
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
  Future<Map<String, dynamic>> requestPermission() async {
    try {
      LocationPermission locationPermission =
          await LocationService.instance.requestLocationPermission();
      if (locationPermission == LocationPermission.always ||
          locationPermission == LocationPermission.whileInUse) {
        return {"status": "correct"};
      }
      if (locationPermission == LocationPermission.denied) {
        return {"status": kLocationPermissionDenied};
      }
      if (locationPermission == LocationPermission.deniedForever) {
        return {"status": kLocationPermissionDeniedForever};
      }
      if (locationPermission == LocationPermission.deniedForever) {
        return {"status": kLocationPermissionDeniedForever};
      } else {
        return {"status": kLocationUnknownStatus};
      }
    } catch (e) {
      throw LocationServiceException(message: e.toString());
    }
  }
}
