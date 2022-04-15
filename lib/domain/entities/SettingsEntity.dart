class SettingsEntity {
  String userName;
  String userPicture;
  String userPictureHash;
  int userAge;
  bool isPremium;
  SettingsEntity({
    required this.userName,
    required this.userPicture,
    required this.userPictureHash,
    required this.userAge,
    required this.isPremium,
  });
}
