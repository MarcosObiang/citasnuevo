import 'package:citasnuevo/domain/entities/ProfileCharacteristicsEntity.dart';


class Profile {
  String id;
  String name;
  int age;
  Map profileImage1;
  Map profileImage2;
  Map profileImage3;
  Map profileImage4;
  Map profileImage5;
  Map profileImage6;
  
  bool verified;
  num distance;
  String bio;
  List<ProfileCharacteristics> profileCharacteristics;
  Profile({
    required this.profileCharacteristics,
    required this.id,
    required this.name,
    required this.age,
    required this.profileImage1,
    required this.profileImage2,
    required this.profileImage3,
    required this.profileImage4,
    required this.profileImage5,
    required this.profileImage6,
    required this.verified,
    required this.distance,
    required this.bio,
  });}