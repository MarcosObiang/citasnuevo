class ApplicationSettingsEntity {
  int distance;
  int maxAge;
  int minAge;
  bool inCm;
  bool inKm;
  bool showBothSexes;
  bool showWoman;
  bool showProfilePoints;
  bool showProfile;
  ApplicationSettingsEntity({
    required this.distance,
    required this.maxAge,
    required this.minAge,
    required this.inCm,
    required this.inKm,
    required this.showBothSexes,
    required this.showWoman,
    required this.showProfilePoints,
    required this.showProfile,
  });
}
