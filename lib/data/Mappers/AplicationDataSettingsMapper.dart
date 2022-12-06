import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/domain/entities/ApplicationSettingsEntity.dart';

class ApplicationSettingsMapper {
  static ApplicationSettingsEntity fromMap(
      {required Map<String, dynamic> data}) {
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

  static Map<String, dynamic> toMap(
      {required ApplicationSettingsEntity applicationSettingsEntity}) {
    return {
      "maxDistance": applicationSettingsEntity.distance,
      "maxAge": applicationSettingsEntity.maxAge,
      "minAge": applicationSettingsEntity.minAge,
      "showCentimeters": applicationSettingsEntity.inCm,
      "showKilometers": applicationSettingsEntity.inKm,
      "showBothSexes": applicationSettingsEntity.showBothSexes,
      "showWoman": applicationSettingsEntity.showWoman,
      "showProfile": applicationSettingsEntity.showProfile,
      "userId": GlobalDataContainer.userId
    };
  }
}
