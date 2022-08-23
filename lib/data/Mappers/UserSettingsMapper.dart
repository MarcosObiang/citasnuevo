import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_compare/image_compare.dart';
import '../../core/common/profileCharacteristics.dart';
import '../../domain/controller/controllerDef.dart';
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter_cache_manager_firebase/flutter_cache_manager_firebase.dart';

class UserSettingsMapper {
  static Future<UserSettingsInformationSender> fromMap(
      Map<String, dynamic> data) async {
    List<UserCharacteristic> userCharacteristics =
        userCharacteristicParser(data["filtros usuario"]);

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
        if (userImages[i]!["Imagen"] != "vacio") {
          list.add(UserPicture(index: i)
            ..setNetworkPicture(
                pictureHashData: userImages[i]!["hash"],
                pictureUrlData: userImages[i]!["Imagen"]));
        } else {
          list.add(UserPicture(index: i));
        }
      } else {
        list.add(UserPicture(index: i));
      }
    }

    UserSettingsInformationSender userSettingsEntity =
        new UserSettingsInformationSender(
            userBio: data["Descripcion"],
            userPicruresList: list,
            userCharacteristic: userCharacteristics);

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
    response["userFilters"] = _userCharacteristicsToMap(userCharacteristicList);

    return response;
  }

  static Map<String, dynamic> _userCharacteristicsToMap(
      List<UserCharacteristic> data) {
    Map<String, dynamic> response = Map<String, dynamic>();

    for (int i = 0; i < data.length; i++) {
      response[data[i].characteristicName] = data[i].characteristicValueIndex;
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
        if (userPictureList[i].getPictureUrl != "vacio") {
          String firebaseImage = FirebaseStorage.instance
              .refFromURL(userPictureList[i].getPictureUrl)
              .fullPath;

          await FirebaseCacheManager().removeFile(firebaseImage);
        }
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
        response.add({
          "index": (userPictureList[i].index + 1).toString(),
          "data": userPictureList[i].getImageFile,
          "empty": true,
          "type": UserPicutreBoxState.empty
        });
      }
      if (userPictureList[i].getUserPictureBoxstate ==
          UserPicutreBoxState.pictureFromNetwork) {
        String firebaseImage = FirebaseStorage.instance
            .refFromURL(userPictureList[i].getPictureUrl)
            .fullPath;

        File file = await FirebaseCacheManager().getSingleFile(firebaseImage);
        Uint8List dataFromNetwork = await file.readAsBytes();
        await FirebaseCacheManager().removeFile(firebaseImage);
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

    List<Map<String, dynamic>> computedImages =
        await compute(blurHashImage, bytesList);
    response.addAll(computedImages);
    return response;
  }

  static List<Map<String, dynamic>> blurHashImage(
      List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> blredImagesHashes = [];
    for (int i = 0; i < data.length; i++) {
      blredImagesHashes.add({
        "hash": BlurHash.encode(data[i]["Bytes"]).hash,
        "index": data[i]["index"],
        "data": data[i]["data"],
        "empty": data[i]["empty"],
        "type": data[i]["type"]
      });
    }

    return blredImagesHashes;
  }

  static List<UserCharacteristic> userCharacteristicParser(
      Map<String, dynamic> data) {
    List<UserCharacteristic> userCharacteristics = [];

    Iterable<MapEntry<String, dynamic>> characteristicData = data.entries;
    List<MapEntry<String, dynamic>> rawUserCharacteristicsList =
        characteristicData.toList();

    rawUserCharacteristicsList
        .removeWhere((element) => element.key == "Altura");
    rawUserCharacteristicsList
        .removeWhere((element) => element.key == "Vegetariano");
    rawUserCharacteristicsList
        .removeWhere((element) => element.key == "orientacionSexual");

    for (int i = 0; i < rawUserCharacteristicsList.length; i++) {

      Map<String, IconData> characteristicIcon =
          kProfileCharacteristics_Icons.firstWhere((element) =>
              element.containsKey(rawUserCharacteristicsList[i].key));
      IconData characteristicIconData = characteristicIcon.values.first;
      Map<String, dynamic> characteristicValueMap =
          kProfileCharacteristics_ES.firstWhere((element) =>
              element.containsKey(rawUserCharacteristicsList[i].key));
      List<Map<String, String>> listCharacteristics =
          characteristicValueMap.entries.first.value;
      String characteristicValue =
          listCharacteristics[rawUserCharacteristicsList[i].value]
              .entries
              .first
              .value;
      if (rawUserCharacteristicsList[i].value != 0) {
        userCharacteristics.add(UserCharacteristic(
          characteristicIcon: characteristicIconData,
          characteristicValueIndex: rawUserCharacteristicsList[i].value,
          userHasValue: true,
          positionIndex: i,
          valuesList: listCharacteristics,
          characteristicName: characteristicValueMap.entries.first.key,
          characteristicValue: characteristicValue,
        ));
      }
      if (rawUserCharacteristicsList[i].value == 0) {
      userCharacteristics.add(UserCharacteristic(
          characteristicIcon: characteristicIconData,
          characteristicValueIndex: rawUserCharacteristicsList[i].value,
          userHasValue: false,
          positionIndex: i,
          valuesList: listCharacteristics,
          characteristicName: characteristicValueMap.entries.first.key,
          characteristicValue: characteristicValue,
        ));
      }
    }
    return userCharacteristics;
  }
}
