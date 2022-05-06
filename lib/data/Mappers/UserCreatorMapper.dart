import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/UserCreatorEntity.dart';

import '../../core/common/profileCharacteristics.dart';
import '../../domain/entities/UserSettingsEntity.dart';

class UserCreatorMapper {
  static toMap({required UserCreatorEntity userCreatorEntity}) async {}
  static UserCreatorInformationSender fromMap(
      Map<String, dynamic> data)  {
    List<UserCharacteristic> userCharacteristics =
        _userCharacteristicParser(data["filtros usuario"]);

        DateTime minDateMilliseconds=data["minBirthDate"];

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

    UserCreatorInformationSender userSettingsEntity =
        new UserCreatorInformationSender(
            minBirthDayInMilliseconds:minDateMilliseconds ,
            userBio: data["Descripcion"],
            userPicruresList: list,
            userCharacteristic: userCharacteristics);

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
            characteristicValueIndex: bmw[i].value,
            userHasValue: true,
            positionIndex: i,
            valuesList: kProfileCharacteristics_ES[i].entries.first.value,
            characteristicName: kProfileCharacteristics_ES[i].entries.first.key,
            characteristicValue: kProfileCharacteristics_ES[i]
                .entries
                .first
                .value[bmw[i].value]
                .values
                .first));
      } else {
        userCharacteristics.add(UserCharacteristic(
            characteristicIcon: kProfileCharacteristics_Icons[i].values.first,
            characteristicValueIndex: bmw[i].value,
            positionIndex: i,
            userHasValue: false,
            valuesList: kProfileCharacteristics_ES[i].entries.first.value,
            characteristicName: kProfileCharacteristics_ES[i].entries.first.key,
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
