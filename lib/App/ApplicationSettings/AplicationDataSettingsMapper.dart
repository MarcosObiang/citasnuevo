import '../../core/globalData.dart';
import '../../core/platform/networkInfo.dart';
import 'ApplicationSettingsEntity.dart';

class ApplicationSettingsMapper implements Mapper<ApplicationSettingsEntity> {
  ApplicationSettingsEntity fromMap(Map<String, dynamic> data) {
    return new ApplicationSettingsEntity(
        distance: data["maxDistance"],
        maxAge: data["maxAge"],
        minAge: data["minAge"],
        inCm: data["showCentimeters"],
        inKm: data["showKilometers"],
        showBothSexes: data["showBothSexes"],
        showWoman: data["showWoman"],
        showProfile: data["showProfile"]);
  }

  Map<String, dynamic> toMap(ApplicationSettingsEntity data) {
    return {
      "maxDistance": data.distance,
      "maxAge": data.maxAge,
      "minAge": data.minAge,
      "showCentimeters": data.inCm,
      "showKilometers": data.inKm,
      "showBothSexes": data.showBothSexes,
      "showWoman": data.showWoman,
      "showProfile": data.showProfile,
      "userId": GlobalDataContainer.userId
    };
  }
}
