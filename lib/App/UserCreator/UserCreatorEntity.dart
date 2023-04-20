import '../UserSettings/UserSettingsEntity.dart';
import '../../core/common/commonUtils/DateNTP.dart';


class UserCreatorEntity {
  int? age;
  late String userBio="";
  late bool showWoman = false;
  late String userName;
  late bool showBothSexes = false;
  late bool isUserWoman=false;
  late int birthDateMilliseconds;
  late bool useMiles = false;
  late bool useMeters = true;
  late String promotionalCode="";

  int minRangeSearchingAge=18;
  int maxRangeSearchingAge=30;
  int maxDistanceForSearching=60;
  DateTime minBirthDate;
  DateTime? date;

  List<UserPicture> userPicruresList;
  List<UserCharacteristic> userCharacteristics;
  UserCreatorEntity({
    required this.userBio,
    required this.minBirthDate,
    required this.userPicruresList,
    required this.userCharacteristics,
  });

  void setAge({required int value}) {
    this.age = value;
  }

  void setSexes({required bool value}) {
    this.isUserWoman = value;
  }

  void setUserPreference({required bool value, required bool showBothSexes}) {
    if (value) {
      showWoman = value;
    }

    if (showBothSexes == true) {
      showWoman = false;
      showBothSexes = true;
    }
  }

  Future<void> addUserDate({required DateTime dateTime}) async {
    DateTime dateNow = await DateNTP.instance.getTime();

    var dd =
        (dateNow.millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch) ~/
            31536000000;

    if (dd >= 18) {
      this.age = dd;
      date = dateTime;
      birthDateMilliseconds = dateTime.millisecondsSinceEpoch;
    }
  }
}
