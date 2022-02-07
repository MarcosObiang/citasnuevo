import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/data/daraSources/HomeDataSource/homeScreenDataSources.dart';
import 'package:citasnuevo/data/daraSources/authDataSources/authDataSourceImpl.dart';
import 'package:citasnuevo/data/daraSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/data/repositoryImpl/authRepoImpl/authRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/homeScreenRepoImpl.dart/homeScreenRepoImpl.dart';
import 'package:citasnuevo/domain/controller/authScreenController.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/repository/authRepo/authRepo.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:citasnuevo/presentation/HomeScreenPresentation/homeScrenPresentation.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:citasnuevo/core/platform/networkInfo.dart';

class Dependencies {
  static late final ChangeNotifierProvider<AuthScreenPresentation>
      userDataContainerProvider;
  static late final StateProvider<AuthScreenPresentation>
      userDataContainerNotifier;
  static late final ChangeNotifierProvider<HomeScreenPresentation>
      homeScreenProvider;
  static late final StateProvider<HomeScreenPresentation> homeScreenNotifier;
  static Future<void> startAuth() async {
    AuthDataSource externalUserDataSourceContract = AuthDataSourceImpl();
    // ignore: unused_local_variable
    NetworkInfoContract networkInfoContract = NetworkInfoImpl();
    AuthRepository _userContractRepository =
        AuthRepositoryImpl(authDataSource: externalUserDataSourceContract);

       AuthScreenController authScreenController= AuthScreenController(authRepository: _userContractRepository);


    AuthScreenPresentation authScreenPresentation = AuthScreenPresentation(authScreenController: authScreenController
    
    );

    await authScreenPresentation.checkSignedInUser();

    userDataContainerProvider = ChangeNotifierProvider<AuthScreenPresentation>(
        (ref) => authScreenPresentation);
    userDataContainerNotifier = StateProvider<AuthScreenPresentation>((ref) {
      return ref.read(userDataContainerProvider);
    });
  }

  static Future<void> startDependencies() async {
    ApplicationDataSource applicationDataSource =
        ApplicationDataSource(userId: GlobalDataContainer.userId);

    await applicationDataSource.initializeMainDataSource();
    HomeScreenDataSource homeScreenDataSource =
        HomeScreenDataSourceImpl(source: applicationDataSource);
    HomeScreenRepository homeScreenRepository =
        HomeScreenRepositoryImpl(homeScreenDataSource: homeScreenDataSource);
    HomeScreenController homeScreenController =
        HomeScreenController(homeScreenRepository: homeScreenRepository);
  
    homeScreenProvider = ChangeNotifierProvider<HomeScreenPresentation>((ref) =>
        HomeScreenPresentation( homeScreenController:homeScreenController));
    homeScreenNotifier = StateProvider<HomeScreenPresentation>(
        (ref) => ref.read(homeScreenProvider));
  }

  static void startUtilDependencies() {
    // ignore: unused_local_variable
    GetProfileImage getProfileImage = new GetProfileImage();
  }
}
