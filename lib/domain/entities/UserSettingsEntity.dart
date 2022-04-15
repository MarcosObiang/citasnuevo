import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

enum UserPicutreBoxState { empty, pictureFromBytes, pictureFromNetwork }

class UserSettingsEntity {
  List<UserPicture> userPicruresList;
  String userBio;
  List<UserCharacteristic>userCharacteristics;
  UserSettingsEntity({required this.userBio, required this.userPicruresList, required this.userCharacteristics});
}

@protected
class UserPicture {
  String _pictureUrl = "vacio";
  String _pictureHash = "vacio";
  bool useFile = false;
  late Uint8List _imageFile = Uint8List(0);
  int index;
  late UserPicutreBoxState _userPicutreBoxState = UserPicutreBoxState.empty;

  String get getPictureUrl => _pictureUrl;

  String get getPictureHash => _pictureHash;

  Uint8List get getImageFile => _imageFile;

  UserPicutreBoxState get getUserPictureBoxstate => _userPicutreBoxState;

  void setNetworkPicture(
      {required String pictureUrlData, required String pictureHashData}) {
    if (pictureUrlData != "vacio") {
      _pictureUrl = pictureUrlData;
      _pictureHash = pictureHashData;
      _userPicutreBoxState = UserPicutreBoxState.pictureFromNetwork;
    } else {
      _pictureHash = "vacio";
      _pictureUrl = "vacio";
      _userPicutreBoxState = UserPicutreBoxState.empty;
    }
  }

  void deleteImage() {
    if (_imageFile.isNotEmpty) {
      _imageFile = new Uint8List(0);
    }
    _pictureHash = "vacio";
    _pictureUrl = "vacio";
    _userPicutreBoxState = UserPicutreBoxState.empty;
  }

  void setBytesPicture({required Uint8List uint8list}) {
    if (uint8list.isNotEmpty) {
      _imageFile = uint8list;
      _userPicutreBoxState = UserPicutreBoxState.pictureFromBytes;
    } else {
      _imageFile.clear();
      _userPicutreBoxState = UserPicutreBoxState.empty;
    }
  }

  UserPicture({required this.index});
}

class UserCharacteristic {
  int characteristicValueIndex;
  int positionIndex;
  bool userHasValue;
  String characteristicName;
  String characteristicValue;
  List<Map<String,dynamic>> valuesList;
  IconData characteristicIcon;
  UserCharacteristic({
    required this.characteristicValueIndex,
    required this.positionIndex,
    required this.userHasValue,
    required this.valuesList,
    required this.characteristicName,
    required this.characteristicValue,
    required this.characteristicIcon
  });


}
