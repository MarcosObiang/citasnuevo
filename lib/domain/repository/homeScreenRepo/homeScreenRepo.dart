import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/HomeDataSource/homeScreenDataSources.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

abstract class HomeScreenRepository implements ModuleCleaner {
  late HomeScreenDataSource homeScreenDataSource;
  Future<Either<Failure, List<Profile>>> fetchProfiles();
  Future<Either<Failure, LocationPermission>> requestLocationPermission();
  Future<Either<Failure, bool>> goToAppSettings();

  Future<Either<Failure, void>> sendRating(
      {required double ratingValue, required String idProfileRated});
}
