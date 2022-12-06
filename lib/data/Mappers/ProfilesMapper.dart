import 'dart:convert';

import 'package:citasnuevo/core/common/profileCharacteristics.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/ProfileCharacteristicsEntity.dart';

class ProfileMapper {
  static List<Profile> fromMap(Map data) {
    List<Profile> profilesList = [];
    List<dynamic> profilesFromBackend = jsonDecode(data["profilesList"]);

    Map userData = data["userData"];
    for (int i = 0; i < profilesFromBackend.length; i++) {
      int userAge = profilesFromBackend[i]["userAge"];

      Map<dynamic, dynamic> profileCharacteristics =
          profilesFromBackend[i];
      List<ProfileCharacteristics> characteristicsCoparationResults = [];
      characteristicsCoparationResults = _characteristicsParser(
          profileData: profileCharacteristics, userData: userData);

      profilesList.add(Profile(
          id: profilesFromBackend[i]["userId"],
          name: profilesFromBackend[i]["userName"],
          age: userAge,
          profileImage1: profilesFromBackend[i]["userPicture1"],
          profileImage2: profilesFromBackend[i]["userPicture2"],
          profileImage3: profilesFromBackend[i]["userPicture3"],
          profileImage4: profilesFromBackend[i]["userPicture4"],
          profileImage5: profilesFromBackend[i]["userPicture5"],
          profileImage6: profilesFromBackend[i]["userPicture6"],
          verified: false,
          distance: profilesFromBackend[i]["distance"],
          profileCharacteristics: characteristicsCoparationResults,
          bio: profilesFromBackend[i]["userBio"]));
    }
    return profilesList;
  }

  static List<ProfileCharacteristics> _characteristicsParser(
      {required Map profileData, required Map userData}) {
    List<ProfileCharacteristics> characteristicsList = [];
    List<String> attributes = [];

    kProfileCharacteristics_ES.forEach((element) {
      attributes.add(element.keys.first);
    });

    for (int i = 0; i < attributes.length; i++) {
      int characterisitcValue = profileData[attributes[i]];

      String characteristicName = attributes[i];
      List<Map<String, dynamic>> kProfileCharacteristicsCopy =
          kProfileCharacteristics_ES[i].values.first;
      String characteristicStringValue =
          kProfileCharacteristicsCopy[characterisitcValue].values.first;

      characteristicsList.add(ProfileCharacteristics(
          sameAsUser:
              profileData[characteristicName] == userData[characteristicName]
                  ? true
                  : false,
          characteristicValue: characteristicStringValue,
          characteristicIndex: characterisitcValue,
          iconData: kProfileCharacteristics_Icons[i].values.first));
    }

    return characteristicsList;
  }

  Map<String, dynamic> toMap(List<Profile> data) {
    throw UnimplementedError();
  }
}
