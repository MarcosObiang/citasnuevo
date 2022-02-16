import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/data/Mappers/ReactionsMappers.dart';
import 'package:citasnuevo/data/daraSources/HomeDataSource/homeScreenDataSources.dart';
import 'package:citasnuevo/data/daraSources/authDataSources/authDataSourceImpl.dart';
import 'package:citasnuevo/data/daraSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/data/daraSources/reactionDataSources/reactionDataSource.dart';
import 'package:citasnuevo/data/repositoryImpl/authRepoImpl/authRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/homeScreenRepoImpl.dart/homeScreenRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/reactionRepoImpl/reactionRepoImpl.dart';
import 'package:citasnuevo/domain/controller/authScreenController.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/controller/reactionsController.dart';
import 'package:citasnuevo/domain/repository/authRepo/authRepo.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:citasnuevo/domain/repository/reactionRepository/reactionRepository.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/auth.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:citasnuevo/presentation/reactionPresentation/reactionPresentation.dart';

import 'package:citasnuevo/core/platform/networkInfo.dart';

class Dependencies {
  static late final ReactionPresentation reactionPresentation;
  static late final HomeScreenPresentation homeScreenPresentation;
  static late final AuthScreenPresentation authScreenPresentation;

  static Future<void> startAuth() async {
    AuthDataSource externalUserDataSourceContract = AuthDataSourceImpl();
    // ignore: unused_local_variable
    NetworkInfoContract networkInfoContract = NetworkInfoImpl();
    AuthRepository _userContractRepository =
        AuthRepositoryImpl(authDataSource: externalUserDataSourceContract);

    AuthScreenController authScreenController =
        AuthScreenController(authRepository: _userContractRepository);

    authScreenPresentation =
        AuthScreenPresentation(authScreenController: authScreenController);

    await authScreenPresentation.checkSignedInUser();
  }

  static Future<void> startDependencies() async {
    ApplicationDataSource applicationDataSource =
        ApplicationDataSource(userId: GlobalDataContainer.userId as String);

    await applicationDataSource.initializeMainDataSource();
    HomeScreenDataSource homeScreenDataSource =
        HomeScreenDataSourceImpl(source: applicationDataSource);
    HomeScreenRepository homeScreenRepository =
        HomeScreenRepositoryImpl(homeScreenDataSource: homeScreenDataSource);
    HomeScreenController homeScreenController =
        HomeScreenController(homeScreenRepository: homeScreenRepository);
    homeScreenPresentation =
        HomeScreenPresentation(homeScreenController: homeScreenController);

    ReactionDataSource reactionDataSource = ReactionDataSourceImpl(
        source: applicationDataSource,);
    ReactionRepository reactionRepository =
        ReactionRepositoryImpl(reactionDataSource: reactionDataSource);
    ReactionsController reactionsController =
        ReactionsController(reactionRepository: reactionRepository);

    reactionPresentation =
        new ReactionPresentation(reactionsController: reactionsController);
  }

  static void startUtilDependencies() {
    // ignore: unused_local_variable
    GetProfileImage getProfileImage = new GetProfileImage();
  }
}
