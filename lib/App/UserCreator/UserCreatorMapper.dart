
import '../../core/common/profileCharacteristics.dart';
import '../UserSettings/UserSettingsEntity.dart';
import 'UserCreatorEntity.dart';

class UserCreatorMapper {
  static Future<Map<String, dynamic>> toMap(
      UserCreatorEntity? userCreatorEntity) async {
    Map<String, dynamic> response = new Map();
    List<UserPicture> userPictureList = userCreatorEntity!.userPicruresList;
    List<UserCharacteristic> userCharacteristicList =
        userCreatorEntity.userCharacteristics;

    response["images"] = formatImageData(userPictureList);
    response["userBio"] = userCreatorEntity.userBio;
    response["userFilters"] = userCharacteristicsToMap(userCharacteristicList);
    response["userName"] = userCreatorEntity.userName;
    response["userAgeMills"] = userCreatorEntity.birthDateMilliseconds;
    response["userAge"] = userCreatorEntity.age;
    response["showWoman"] = userCreatorEntity.showWoman;
    response["userPreferesBothSexes"] = userCreatorEntity.showBothSexes;
    response["isUserWoman"] = userCreatorEntity.isUserWoman;
    response["maxDistance"] = userCreatorEntity.maxDistanceForSearching;
    response["minAge"] = userCreatorEntity.minRangeSearchingAge;
    response["maxAge"] = userCreatorEntity.maxRangeSearchingAge;
    response["useMeters"] = userCreatorEntity.useMeters;
    response["useMilles"] = userCreatorEntity.useMiles;
    response["promotionalCode"]=userCreatorEntity.promotionalCode;
    return response;
  }

  static Map<String, dynamic> userCharacteristicsToMap(
      List<UserCharacteristic> data) {
    Map<String, dynamic> response = Map<String, dynamic>();

    for (int i = 0; i < data.length; i++) {
      response[data[i].characteristicCode] = data[i].characteristicValueIndex;
    }
    return response;
  }

  static List<Map<String, dynamic>> formatImageData(
      List<UserPicture> userPictureList) {
    List<Map<String, dynamic>> bytesList = [];
    List<Map<String, dynamic>> response = [];

    userPictureList.sort((a, b) => a.index.compareTo(b.index));

    for (int i = 0; i < userPictureList.length; i++) {
      if (userPictureList[i].getUserPictureBoxstate ==
          UserPicutreBoxState.pictureFromBytes) {
        response.add({
          "index": (userPictureList[i].index + 1).toString(),
          "data": userPictureList[i].getImageFile,
          "empty": false,
          "type": UserPicutreBoxState.pictureFromBytes
        });
      }

      if (userPictureList[i].getUserPictureBoxstate ==
          UserPicutreBoxState.empty) {
        response.add({
          "index": (userPictureList[i].index + 1).toString(),
          "data": userPictureList[i].getImageFile,
          "empty": true,
          "type": UserPicutreBoxState.empty
        });
      }
    }

    return response;
  }

  static UserCreatorEntity fromMap(Map<String, dynamic> data) {
    List<UserCharacteristic> userCharacteristics =
        _userCharacteristicParser(data["filtros usuario"]);

    DateTime minDateMilliseconds = data["minBirthDate"];

    Map<String, dynamic>? profileImage1 = data["IMAGENPERFIL1"];
    Map<String, dynamic>? profileImage2 = data["IMAGENPERFIL2"];

    Map<String, dynamic>? profileImage3 = data["IMAGENPERFIL3"];
    Map<String, dynamic>? profileImage4 = data["IMAGENPERFIL4"];
    Map<String, dynamic>? profileImage5 = data["IMAGENPERFIL5"];
    Map<String, dynamic>? profileImage6 = data["IMAGENPERFIL6"];

    List<UserPicture> list = [];
    List<Map<String, dynamic>?> userImages = [
      profileImage1,
      profileImage2,
      profileImage3,
      profileImage4,
      profileImage5,
      profileImage6
    ];

    for (int i = 0; i < userImages.length; i++) {
      if (userImages[i] != null) {
        if (userImages[i]!["Imagen"] == "vacio") {
          list.add(UserPicture(index: i));
        }
      } else {
        list.add(UserPicture(index: i));
      }
    }

    UserCreatorEntity userSettingsEntity = new UserCreatorEntity(
        minBirthDate: minDateMilliseconds,
        userBio: data["Descripcion"],
        userPicruresList: list,
        userCharacteristics: userCharacteristics);

    return userSettingsEntity;
  }

  static List<UserCharacteristic> _userCharacteristicParser(
      Map<String, dynamic> data) {
    List<UserCharacteristic> userCharacteristics = [];

    Iterable<MapEntry<String, dynamic>> characteristicData = data.entries;
    List<MapEntry<String, dynamic>> bmw = characteristicData.toList();

    bmw.removeWhere((element) => element.key == "Altura");
    bmw.removeWhere((element) => element.key == "Vegetariano");
    bmw.removeWhere((element) => element.key == "orientacionSexual");

    for (int i = 0; i < bmw.length; i++) {
      if (bmw[i].value != 0) {
        userCharacteristics.add(UserCharacteristic(
            characteristicIcon: kProfileCharacteristics_Icons[i].values.first,
            characteristicCode:kProfileCharacteristicsNames_ES[i].keys.first ,
            characteristicValueIndex: bmw[i].value,
            userHasValue: true,
            positionIndex: i,
            valuesList: kProfileCharacteristics_ES[i].entries.first.value,
            characteristicName: kProfileCharacteristicsNames_ES[i].values.first,
            characteristicValue: kProfileCharacteristics_ES[i]
                .entries
                .first
                .value[bmw[i].value]
                .values
                .first));
      } else {
        userCharacteristics.add(UserCharacteristic(
            characteristicIcon: kProfileCharacteristics_Icons[i].values.first,
                        characteristicCode:kProfileCharacteristicsNames_ES[i].keys.first ,

            characteristicValueIndex: bmw[i].value,
            positionIndex: i,
            userHasValue: false,
            valuesList: kProfileCharacteristics_ES[i].entries.first.value,
            characteristicName: kProfileCharacteristicsNames_ES[i].values.first,
            characteristicValue: kProfileCharacteristics_ES[i]
                .entries
                .first
                .value[bmw[i].value]
                .values
                .first));
      }
    }
    return userCharacteristics;
  }
}
