import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

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
          String firebaseImage = FirebaseStorage.instance
              .refFromURL(userImages[i]!["Imagen"])
              .fullPath;

          FirebaseCacheManager().getSingleFile(firebaseImage);
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

    response["images"] = await hashImage(userPictureList);
    response["userBio"] = userSettingsEntity.userBio;
    response["userFilters"] = userCharacteristicsToMap(userCharacteristicList);

    return response;
  }

  static Map<String, dynamic> userCharacteristicsToMap(
      List<UserCharacteristic> data) {
    Map<String, dynamic> response = Map<String, dynamic>();

    for (int i = 0; i < data.length; i++) {
      response[data[i].characteristicName] = data[i].characteristicValueIndex;
    }
    print("object");
    return response;
  }

  static Future<List<Map<String, dynamic>>> hashImage(
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
        Uint8List dataFromNetwork = file.readAsBytesSync();
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
        "empty": false,
        "type": data[i]["type"]
      });
    }

    return blredImagesHashes;
  }

  static List<UserCharacteristic> userCharacteristicParser(
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
                .value[bmw
                    .firstWhere((element) =>
                        element.key ==
                        kProfileCharacteristics_ES[i].entries.first.key)
                    .value]
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
                .value[bmw
                    .firstWhere((element) =>
                        element.key ==
                        kProfileCharacteristics_ES[i].entries.first.key)
                    .value]
                .values
                .first));
      }
    }
    return userCharacteristics;
  }
}
