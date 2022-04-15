import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:dartz/dartz.dart';

class HomeScreenController implements Controller {
  List<Profile> profilesList = [];
  HomeScreenRepository homeScreenRepository;
  HomeScreenController({required this.homeScreenRepository});
  get getProfilesList => this.profilesList;

  Future<Either<Failure, void>> fetchProfileList() async {
    bool succes = false;
    Failure failure = ServerFailure();
    var response = await homeScreenRepository.fetchProfiles();
    response.fold((fail) {
      succes = false;
      failure = fail;
    }, (profileData) {
      profilesList.addAll(profileData);
      succes = true;
    });
    if (succes) {
      return Right(profilesList);
    } else {
      return Left(failure);
    }
  }

  Profile removeProfileFromList({required int profileIndex}) {
    return profilesList.removeAt(profileIndex);
  }

  Future<Either<Failure, void>> sendRating(
      {required double ratingValue, required String idProfileRated}) async {
    profilesList.removeWhere((element) => element.id == idProfileRated);
    return await homeScreenRepository.sendRating(
        ratingValue: ratingValue, idProfileRated: idProfileRated);
  }

  @override
  void clearModuleData() {
    homeScreenRepository.clearModuleData();
  }

  @override
  void initializeModuleData() {
    homeScreenRepository.initializeModuleData();
  }
}
