import 'package:citasnuevo/core/ads_services/Ads.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/data/Mappers/ReactionsMappers.dart';
import 'package:citasnuevo/data/daraSources/HomeDataSource/homeScreenDataSources.dart';
import 'package:citasnuevo/data/daraSources/authDataSources/authDataSourceImpl.dart';
import 'package:citasnuevo/data/daraSources/chatDataSource/chatDataSource.dart';
import 'package:citasnuevo/data/daraSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/data/daraSources/reactionDataSources/reactionDataSource.dart';
import 'package:citasnuevo/data/daraSources/reportDataSource/reportDataSource.dart';
import 'package:citasnuevo/data/repositoryImpl/authRepoImpl/authRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/chatRepoImpl/chatRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/homeScreenRepoImpl.dart/homeScreenRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/reactionRepoImpl/reactionRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/reportRepoImpl/reportRepoImpl.dart';
import 'package:citasnuevo/domain/controller/authScreenController.dart';
import 'package:citasnuevo/domain/controller/chatController.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/controller/reactionsController.dart';
import 'package:citasnuevo/domain/controller/reportController.dart';
import 'package:citasnuevo/domain/repository/authRepo/authRepo.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:citasnuevo/domain/repository/reactionRepository/reactionRepository.dart';
import 'package:citasnuevo/domain/repository/reportRepo/reportRepo.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/auth.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatPresentation.dart';
import 'package:citasnuevo/presentation/homeReportScreenPresentation/homeReportScreenPresentation.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:citasnuevo/presentation/reactionPresentation/reactionPresentation.dart';

import 'package:citasnuevo/core/platform/networkInfo.dart';

class Dependencies {
  static late final ReactionPresentation reactionPresentation;
  static late final HomeScreenPresentation homeScreenPresentation;
  static late final AuthScreenPresentation authScreenPresentation;
  static late final HomeReportScreenPresentation homeReportScreenPresentation;
  static late final AdvertisingServices advertisingServices;
  static late final ChatPresentation chatPresentation;

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
    advertisingServices = new AdvertisingServices();
    advertisingServices.adsServiceInit();
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
      source: applicationDataSource,
    );
    ReactionRepository reactionRepository =
        ReactionRepositoryImpl(reactionDataSource: reactionDataSource);
    ReactionsController reactionsController =
        ReactionsController(reactionRepository: reactionRepository);

    reactionPresentation =
        new ReactionPresentation(reactionsController: reactionsController);

    ReportDataSource reportDataSource =
        new ReportDataSourceImpl(source: applicationDataSource);
    ReportRepository reportRepository =
        new ReportRepositoryImpl(reportDataSource: reportDataSource);
    ReportController reportController =
        new ReportController(reportRepository: reportRepository);
    homeReportScreenPresentation =
        new HomeReportScreenPresentation(reportController: reportController);

    ChatDataSource chatDataSource =
        new ChatDatsSourceImpl(source: applicationDataSource);

    ChatRepository chatRepository =
        new ChatRepoImpl(chatDataSource: chatDataSource);
    ChatController chatController =
        new ChatController(chatRepository: chatRepository);
    chatPresentation = new ChatPresentation(chatController: chatController);
  }

  static void startUtilDependencies() {
    // ignore: unused_local_variable
    GetProfileImage getProfileImage = new GetProfileImage();
  }
}
