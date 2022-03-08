import 'package:citasnuevo/core/common/profileCharacteristics.dart';
import 'package:citasnuevo/data/Mappers/ConverterDefinition.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/ProfileCharacteristicsEntity.dart';

class ProfileMapper {
  static List<Profile> fromMap(Map data) {
    List<Profile> profilesList = [];
    List<Map<dynamic, dynamic>> profilesFromBackend = data["profilesList"];
    Map userCharacteristicsData = data["userCharacteristicsData"];
    for (int i = 0; i < profilesFromBackend.length; i++) {
      Map<dynamic, dynamic> profileCharacteristics =
          profilesFromBackend[i]["filtrosUsuario"];
      List<ProfileCharacteristics> characteristicsCoparationResults = [];
      characteristicsCoparationResults = characteristicsParser(
          profileData: profileCharacteristics,
          userData: userCharacteristicsData);

      profilesList.add(Profile(
          id: profilesFromBackend[i]["identificador"],
          name: profilesFromBackend[i]["nombre"],
          age: profilesFromBackend[i]["Edad"],
          profileImage1: profilesFromBackend[i]["IMAGENPERFIL1"],
          profileImage2: profilesFromBackend[i]["IMAGENPERFIL1"],
          profileImage3: profilesFromBackend[i]["IMAGENPERFIL1"],
          profileImage4: profilesFromBackend[i]["IMAGENPERFIL1"],
          profileImage5: profilesFromBackend[i]["IMAGENPERFIL1"],
          profileImage6: profilesFromBackend[i]["IMAGENPERFIL1"],
          verified: false,
          distance: 30,
          profileCharacteristics: characteristicsCoparationResults,
          bio: profilesFromBackend[i]["Descripcion"]));
    }
    return profilesList;
  }

  static List<ProfileCharacteristics> characteristicsParser(
      {required Map profileData, required Map userData}) {
    List<ProfileCharacteristics> characteristicsList = [];

    profileData.keys.forEach((characteristicKey) {
      if (characteristicKey != "orientacionSexual" &&
          characteristicKey != "Altura" &&
          characteristicKey != "Vegetariano") {
        IconData? iconData = kProfileCharacteristics_Icons.firstWhere(
            (iconElement) =>
                iconElement.containsKey(characteristicKey))[characteristicKey];
        List<Map<String, String>>? characteristicDataList =
            kProfileCharacteristics_ES.firstWhere((characteristicDataElement) =>
                characteristicDataElement
                    .containsKey(characteristicKey))[characteristicKey];

        int index = profileData[characteristicKey];

        String? characteristicData =
            characteristicDataList?[profileData[characteristicKey]]
                .values
                .toList()[index];
        characteristicsList.add(ProfileCharacteristics(
            sameAsUser:
                profileData[characteristicKey] == userData[characteristicKey]
                    ? true
                    : false,
            characteristicValue: characteristicData as String,
            characteristicIndex: profileData[characteristicKey],
            iconData: iconData as IconData));
      }
    });
    return characteristicsList;
  }

  
  Map<String, dynamic> toMap(List<Profile> data) {
    throw UnimplementedError();
  }
}
