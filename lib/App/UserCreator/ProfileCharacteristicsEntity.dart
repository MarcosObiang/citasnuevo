import 'package:flutter/widgets.dart';

class ProfileCharacteristics {

  final Function characteristicValue;
  final int characteristicIndex;
  final bool sameAsUser;
  final IconData iconData;
  ProfileCharacteristics({
    required this.characteristicValue,
    required this.characteristicIndex,
    required this.sameAsUser,
    required this.iconData,
  });
}
