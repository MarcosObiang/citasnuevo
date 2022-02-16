import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/daraSources/HomeDataSource/homeScreenDataSources.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:dartz/dartz.dart';
abstract class HomeScreenRepository{
  late HomeScreenDataSource homeScreenDataSource;
  Future<Either<Failure,List<Profile>>> fetchProfiles();
  Future<Either<Failure,void>> sendRating( {required double ratingValue, required String idProfileRated});
  Future<Either<Failure,bool>> sendReport({required String reporterId,required String userReportedId,required String reportDetails});
  
  }