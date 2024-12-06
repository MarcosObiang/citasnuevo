import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:citasnuevo/Utils/getImageFile.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../../core/common/profileCharacteristics.dart';
import '../../../core/dependencies/dependencyCreator.dart';
import 'UserSettingsEntity.dart';


class UserSettingsMapper {

  static Future<UserSettingsEntity> fromMap(Map<String, dynamic> data) async {
    List<UserCharacteristic> userCharacteristics =
        _userCharacteristicParser(data);

    Map<String, dynamic>? profileImage1 = data["userPicture1"];
    Map<String, dynamic>? profileImage2 = data["userPicture2"];
    Map<String, dynamic>? profileImage3 = data["userPicture3"];
    Map<String, dynamic>? profileImage4 = data["userPicture4"];
    Map<String, dynamic>? profileImage5 = data["userPicture5"];
    Map<String, dynamic>? profileImage6 = data["userPicture6"];

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
        if (userImages[i]!["imageData"] != kNotAvailable&&userImages[i]!["imageData"] != null) {
          list.add(UserPicture(index: i)
            ..setNetworkPicture(
                imageBytes: await ImageFile.getFile(fileId:userImages[i]!["imageData"],bucketId: kUserPicturesBucketId  ),
                pictureUrlData: userImages[i]!["imageData"]));
        } else {
          list.add(UserPicture(index: i));
        }
      } else {
        list.add(UserPicture(index: i));
      }
    }

    UserSettingsEntity userSettingsEntity = new UserSettingsEntity(
        userBio: data["userBio"],
        userPicruresList: list,
        userCharacteristics: userCharacteristics);

    return userSettingsEntity;
  }



  static Future<Map<String, dynamic>> toMap(
      UserSettingsEntity userSettingsEntity) async {
    Map<String, dynamic> response = new Map();
    List<UserPicture> userPictureList = userSettingsEntity.userPicruresList;
    List<UserCharacteristic> userCharacteristicList =
        userSettingsEntity.userCharacteristics;

    response["images"] = await _hashImage(userPictureList);
    response["userBio"] = userSettingsEntity.userBio;
    response.addAll(_userCharacteristicsToMap(userCharacteristicList));

    return response;
  }

  static Map<String, dynamic> _userCharacteristicsToMap(
      List<UserCharacteristic> data) {
    Map<String, dynamic> response = Map<String, dynamic>();

    for (int i = 0; i < data.length; i++) {
      response[data[i].characteristicCode] = data[i].characteristicValueIndex;
    }
    return response;
  }

  static Future<List<Map<String, dynamic>>> _hashImage(
      List<UserPicture> userPictureList) async {
    List<Map<String, dynamic>> bytesList = [];
    List<Map<String, dynamic>> response = [];

    userPictureList.sort((a, b) => a.index.compareTo(b.index));

    for (int i = 0; i < userPictureList.length; i++) {
      if (userPictureList[i].getUserPictureBoxstate ==
          UserPicutreBoxState.pictureFromBytes) {
        if (userPictureList[i].getPictureUrl != "vacio") {}
        img.Image? imagex = img.decodeImage(userPictureList[i].getImageFile);
        bytesList.add({
          "Bytes": imagex,
          "index": (userPictureList[i].index + 1).toString(),
          "data": userPictureList[i].getImageFile,
          "empty": false,
          "type": UserPicutreBoxState.pictureFromBytes
        });
      }

      if (userPictureList[i].getUserPictureBoxstate ==
          UserPicutreBoxState.empty) {
        bytesList.add({
          "index": (userPictureList[i].index + 1).toString(),
          "data": userPictureList[i].getImageFile,
          "empty": true,
          "type": UserPicutreBoxState.empty
        });
      }
      if (userPictureList[i].getUserPictureBoxstate ==
          UserPicutreBoxState.pictureFromNetwork) {
        Uint8List dataFromNetwork =
            await ImageFile.getFile(fileId:userPictureList[i].getPictureUrl,bucketId: kUserPicturesBucketId);
        img.Image? imagex = img.decodeImage(dataFromNetwork);
        bytesList.add({
          "Bytes": imagex,
          "index": (userPictureList[i].index + 1).toString(),
          "data": dataFromNetwork,
          "empty": false,
          "type": UserPicutreBoxState.pictureFromNetwork
        });
      }
    }

 
    return bytesList;
  }

  static List<Map<String, dynamic>> _blurHashImage(
      List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> blredImagesHashes = [];

    return blredImagesHashes;
  }

  static List<UserCharacteristic> _userCharacteristicParser(
      Map<String, dynamic> data) {
    List<UserCharacteristic> userCharacteristics = [];

    List<String> attributes = [];

    kProfileCharacteristics_ES.forEach((element) {
      attributes.add(element.keys.first);
    });

    for (int i = 0; i < attributes.length; i++) {
      int characterisitcValue = data[attributes[i]];

      Function characteristicName = kProfileCharacteristicsNames_ES[i].values.first;
      List<Map<int, dynamic>> kProfileCharacteristicsCopy =
          kProfileCharacteristics_ES[i].values.first;
      Function characteristicStringValue =
          kProfileCharacteristicsCopy[characterisitcValue].values.first;

      userCharacteristics.add(UserCharacteristic(
                    characteristicCode:kProfileCharacteristicsNames_ES[i].keys.first ,

          characteristicValueIndex: characterisitcValue,
          positionIndex: 0,
          userHasValue: characterisitcValue != 0 ? true : false,
          valuesList: kProfileCharacteristicsCopy,
          characteristicName: characteristicName,
          characteristicValue: characteristicStringValue,
          characteristicIcon: kProfileCharacteristics_Icons[i].values.first));
    }

    return userCharacteristics;
  }
}
