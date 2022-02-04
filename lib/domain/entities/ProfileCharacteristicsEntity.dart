import 'package:flutter/widgets.dart';

class ProfileCharacteristics {

  final String characteristicValue;
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
