import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/usecases/usecases.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';

class FetchProfilesUseCases implements UseCase<List<Profile>, GetUserParams> {
  HomeScreenController controller;
  FetchProfilesUseCases({
    required this.controller,
  });
  @override
  Future<Either<Failure, List<Profile>>> call(GetUserParams params) {
    // TODO: implement call
    return controller.fetchProfileList();
  }
}

class RateProfileUseCases implements UseCase<void, RatingParams> {
  HomeScreenController controller;
  RateProfileUseCases({
    required this.controller,
  });

  @override
  Future<Either<Failure, void>> call(RatingParams params) {
    // TODO: implement call
    return controller.sendRating(
        ratingValue: params.rating, idProfileRated: params.profileId);
  }
}

class ReportUserUseCase implements UseCase<bool, ReportParams> {
  HomeScreenController controller;
  ReportUserUseCase({
    required this.controller,
  });

  @override
  Future<Either<Failure, bool>> call(ReportParams params) {
    return controller.sendUserReport(
        idUserReported: params.idUserReported,
        idReporter: params.idReporter,
        reportDetails: params.reportDetails);
  }
}
