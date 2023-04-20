class SettingsEntity {
  String userName;
  String userPicture;
  int userAge;
  String subscriptionPrice = "";
  bool isUserPremium=false;

  SettingsEntity({
    required this.userName,
    required this.userPicture,
    required this.userAge,
  });
}
