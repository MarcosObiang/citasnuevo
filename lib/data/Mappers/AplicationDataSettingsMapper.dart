import 'package:citasnuevo/domain/entities/ApplicationSettingsEntity.dart';

class ApplicationSettingsMapper{

static ApplicationSettingsEntity fromMap({required Map<String,dynamic> data}){
  return new ApplicationSettingsEntity(
          distance: data["distance"],
          maxAge: data["maxAge"],
          minAge: data["minAge"],
          inCm: data["inCm"],
          inKm: data["inKm"],
          showBothSexes: data["showBothSexes"],
          showWoman: data["showWoman"],
          showProfile: data["showProfile"]);

}


}