import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/data/daraSources/HomeDataSource/homeScreenDataSources.dart';
import 'package:citasnuevo/data/daraSources/authDataSources/authDataSourceImpl.dart';
import 'package:citasnuevo/data/daraSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/data/repositoryImpl/authRepoImpl/authRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/homeScreenRepoImpl.dart/homeScreenRepoImpl.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/repository/authRepo/authRepo.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:citasnuevo/domain/usecases/HomeScreenUseCases/homeScreenUseCases.dart';
import 'package:citasnuevo/domain/usecases/authUseCases/authUseCases.dart';
import 'package:citasnuevo/presentation/HomeScreenPresentation/homeScrenPresentation.dart';
import 'package:citasnuevo/presentation/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:citasnuevo/core/platform/networkInfo.dart';

class Dependencies {
  static late final ChangeNotifierProvider<AuthScreenPresentation>
      userDataContainerProvider;
  static late final StateProvider<AuthScreenPresentation> userDataContainerNotifier;
  static late final ChangeNotifierProvider<HomeScreenPresentation>
      homeScreenProvider;
  static late final StateProvider<HomeScreenPresentation> homeScreenNotifier;
  static void startAuth() async {
    AuthDataSource externalUserDataSourceContract = AuthDataSourceImpl();
    // ignore: unused_local_variable
    NetworkInfoContract networkInfoContract = NetworkInfoImpl();
    AuthStateRepository _userContractRepository =
        AuthStateRepositoryImpl(authDataSource: externalUserDataSourceContract);
    LogInUseCase useCaseGetUserPublic =
        LogInUseCase(authStateRepository: _userContractRepository);
    CheckSignedInUserUseCase checkSignedInUserUseCase =
        CheckSignedInUserUseCase(authStateRepository: _userContractRepository);
    userDataContainerProvider =
        ChangeNotifierProvider<AuthScreenPresentation>((ref) => AuthScreenPresentation(
              logInUseCase: useCaseGetUserPublic,
              checkSignedInUserUseCase: checkSignedInUserUseCase,
            ));
    userDataContainerNotifier = StateProvider<AuthScreenPresentation>((ref) {
      return ref.read(userDataContainerProvider);
    });
  }
  static void startDependencies() {
    ApplicationDataSource applicationDataSource =
        ApplicationDataSource(userId: GlobalDataContainer.userId);
    HomeScreenDataSource homeScreenDataSource =
        HomeScreenDataSourceImpl(source: applicationDataSource);
    HomeScreenRepository homeScreenRepository =
        HomeScreenRepositoryImpl(homeScreenDataSource: homeScreenDataSource);
    HomeScreenController homeScreenController =
        HomeScreenController(homeScreenRepository: homeScreenRepository);
    FetchProfilesUseCases fetchProfilesUseCases =
        FetchProfilesUseCases(controller: homeScreenController);
        RateProfileUseCases rateProfileUseCases =
        RateProfileUseCases(controller: homeScreenController);
        ReportUserUseCase reportUserUseCase= ReportUserUseCase(controller: homeScreenController);
    homeScreenProvider = ChangeNotifierProvider<HomeScreenPresentation>((ref) =>
        HomeScreenPresentation(fetchProfilesUseCases: fetchProfilesUseCases,rateProfileUseCases:rateProfileUseCases,reportUserUseCase:reportUserUseCase ));
    homeScreenNotifier = StateProvider<HomeScreenPresentation>(
        (ref) => ref.read(homeScreenProvider));
  }
    static void startUtilDependencies(){
      // ignore: unused_local_variable
      GetProfileImage getProfileImage= new GetProfileImage();
    }
  }
  
