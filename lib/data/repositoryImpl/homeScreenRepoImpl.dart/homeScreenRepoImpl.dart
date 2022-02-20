import 'dart:ffi';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/Mappers/ProfilesMapper.dart';
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
      Map<dynamic, dynamic> profileData =
          await homeScreenDataSource.fetchProfiles();


      List<Profile> profilesList = await compute(
        ProfileMapper.fromMap,
        (profileData),
      );
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

}