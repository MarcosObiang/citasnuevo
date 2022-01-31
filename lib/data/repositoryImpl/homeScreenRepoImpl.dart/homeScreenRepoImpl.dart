import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/daraSources/HomeDataSource/homeScreenDataSources.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:dartz/dartz.dart';

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
      var profilesList = await compute(mapToProfile, profileData);
      return Right(profilesList);
    } catch (e) {
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
  List<Profile> mapToProfile(List<Map<dynamic, dynamic>> data) {
    List<Profile> profilesList = [];
    for (int i = 0; i < data.length; i++) {
      profilesList.add(Profile(
          id: data[i]["identificador"],
          name: data[i]["nombre"],
          age: data[i]["Edad"],
          profileImage1: data[i]["IMAGENPERFIL1"],
          profileImage2: data[i]["IMAGENPERFIL2"],
          profileImage3: data[i]["IMAGENPERFIL3"],
          profileImage4: data[i]["IMAGENPERFIL4"],
          profileImage5: data[i]["IMAGENPERFIL5"],
          profileImage6: data[i]["IMAGENPERFIL6"],
          verified: false,
          distance: data[i]["distancia"],
          bio: data[i]["Descripcion"]));
    }
    return profilesList;
  }}