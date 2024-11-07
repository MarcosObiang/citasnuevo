import 'SettingsEntity.dart';

class SettingsMapper {
  static SettingsEntity fromMap(Map<String, dynamic> latestSettings) {
   
     
     

   
    SettingsEntity settingsEntity = SettingsEntity(
        userName: latestSettings["name"],
        userPicture: latestSettings["userPicture1"]["imageData"],
        userAge: latestSettings["age"],
      );



    return settingsEntity;
  }
}
