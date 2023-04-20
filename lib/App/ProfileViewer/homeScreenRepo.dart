import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../DataManager.dart';
import '../../core/error/Failure.dart';
import 'ProfileEntity.dart';
import 'homeScreenDataSources.dart';

abstract class HomeScreenRepository implements ModuleCleanerRepository {
  late HomeScreenDataSource homeScreenDataSource;
  Future<Either<Failure, List<Profile>>> fetchProfiles();
  Future<Either<Failure, LocationPermission>> requestLocationPermission();
  Future<Either<Failure, bool>> goToAppSettings();
  Future<Either<Failure, void>> sendRating(
      {required double ratingValue, required String idProfileRated});
}
