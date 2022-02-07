import 'dart:ffi';

import 'package:citasnuevo/core/common/profileCharacteristics.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/daraSources/HomeDataSource/homeScreenDataSources.dart';
import 'package:citasnuevo/domain/entities/ProfileCharacteristicsEntity.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';

class HomeScreenRepositoryImpl implements HomeScreenRepository {
  @override
  HomeScreenDataSource homeScreenDataSource;
  HomeScreenRepositoryImpl({
    required this.homeScreenDataSource,
  });
  @override
  Future<Either<Failure, List<Profile>>> fetchProfiles() async {
    try {
      var profileData = await homeScreenDataSource.fetchProfiles();
      var profilesList = await compute(
        mapToProfile,
        (profileData),
      );
      return Right(profilesList);
    } catch (e) {
      print(e);
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else if (e is FetchProfilesException) {
        return Left(FetchUserFailure());
      } else {
        return Left(GenericModuleFailure());
      }
    }
  }

  @override
  List<Profile> mapToProfile(Map<dynamic, dynamic> data) {
    List<Profile> profilesList = [];
    List<Map<dynamic, dynamic>> profilesFromBackend = data["profilesList"];
    Map userCharacteristicsData = data["userCharacteristicsData"];
    for (int i = 0; i < profilesFromBackend.length; i++) {
      Map<dynamic, dynamic> profileCharacteristics =
          profilesFromBackend[i]["filtrosUsuario"];
      List<ProfileCharacteristics> characteristicsCoparationResults = [];
      characteristicsCoparationResults = characteristicsParser(
          profileData: profileCharacteristics,
          userData: userCharacteristicsData);

      profilesList.add(Profile(
          id: profilesFromBackend[i]["identificador"],
          name: profilesFromBackend[i]["nombre"],
          age: profilesFromBackend[i]["Edad"],
          profileImage1: profilesFromBackend[i]["IMAGENPERFIL1"],
          profileImage2: profilesFromBackend[i]["IMAGENPERFIL2"],
          profileImage3: profilesFromBackend[i]["IMAGENPERFIL3"],
          profileImage4: profilesFromBackend[i]["IMAGENPERFIL4"],
          profileImage5: profilesFromBackend[i]["IMAGENPERFIL5"],
          profileImage6: profilesFromBackend[i]["IMAGENPERFIL6"],
          verified: false,
          distance: profilesFromBackend[i]["distancia"],
          profileCharacteristics: characteristicsCoparationResults,
          bio: profilesFromBackend[i]["Descripcion"]));
    }
    return profilesList;
  }

  List<ProfileCharacteristics> characteristicsParser(
      {required Map profileData, required Map userData}) {
    List<ProfileCharacteristics> characteristicsList = [];

    profileData.keys.forEach((characteristicKey) {
      if (characteristicKey != "orientacionSexual" &&
          characteristicKey != "Altura" &&
          characteristicKey != "Vegetariano") {
        IconData? iconData = kProfileCharacteristics_Icons.firstWhere(
            (iconElement) =>
                iconElement.containsKey(characteristicKey))[characteristicKey];
        List<Map<String, String>>? characteristicDataList =
            kProfileCharacteristics_ES.firstWhere((characteristicDataElement) =>
                characteristicDataElement
                    .containsKey(characteristicKey))[characteristicKey];

        int index = profileData[characteristicKey];

        String? characteristicData =
            characteristicDataList?[profileData[characteristicKey]]
                .values
                .toList()[index];
        characteristicsList.add(ProfileCharacteristics(
            sameAsUser:
                profileData[characteristicKey] == userData[characteristicKey]
                    ? true
                    : false,
            characteristicValue: characteristicData as String,
            characteristicIndex: profileData[characteristicKey],
            iconData: iconData as IconData));
      }
    });
    return characteristicsList;
  }

  @override
  Future<Either<Failure, void>> sendRating(
      {required double ratingValue, required String idProfileRated}) async {
    try {
      await homeScreenDataSource.sendRating(
          ratingValue: ratingValue, idProfileRated: idProfileRated);
      return Right(Void);
    } catch (e) {
      if (e is RatingProfilesException) {
        return Left(RatingProfilesFailure());
      } else if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(ServerFailure());
      }
    }
  }

  @override
  Future<Either<Failure, bool>> sendReport(
      {required String reporterId,
      required String userReportedId,
      required String reportDetails}) async {
    try {
      await homeScreenDataSource.sendReport(
          idReporter: reporterId,
          idUserReported: userReportedId,
          reportDetails: reportDetails);
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else if (e is ReportException) {
        return Left(ReportFailure());
      } else {
        return Left(ReportFailure());
      }
    }
  }
}
