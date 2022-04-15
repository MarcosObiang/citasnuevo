import 'package:citasnuevo/core/ads_services/Ads.dart';
import 'package:citasnuevo/core/common/commonUtils/getUserImage.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/data/Mappers/ReactionsMappers.dart';
import 'package:citasnuevo/data/dataSources/HomeDataSource/homeScreenDataSources.dart';
import 'package:citasnuevo/data/dataSources/appSettings/ApplicationSettingsDataSource.dart';
import 'package:citasnuevo/data/dataSources/authDataSources/authDataSourceImpl.dart';
import 'package:citasnuevo/data/dataSources/chatDataSource/chatDataSource.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/data/dataSources/reactionDataSources/reactionDataSource.dart';
import 'package:citasnuevo/data/dataSources/reportDataSource/reportDataSource.dart';
import 'package:citasnuevo/data/dataSources/settingsDataSource/settingsDataSource.dart';
import 'package:citasnuevo/data/dataSources/userSettingsDataSource/userSettingsDataSource.dart';
import 'package:citasnuevo/data/repositoryImpl/appSettingsRepoImpl/appSettingsRepo.dart';
import 'package:citasnuevo/data/repositoryImpl/authRepoImpl/authRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/chatRepoImpl/chatRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/homeScreenRepoImpl.dart/homeScreenRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/reactionRepoImpl/reactionRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/reportRepoImpl/reportRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/settingsRepoImpl/settingsRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/userSettingsRepoImpl.dart/userSettingsRepoImpl.dart';
import 'package:citasnuevo/domain/controller/SettingsController.dart';
import 'package:citasnuevo/domain/controller/appSettingsController.dart';
import 'package:citasnuevo/domain/controller/authScreenController.dart';
import 'package:citasnuevo/domain/controller/chatController.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/controller/reactionsController.dart';
import 'package:citasnuevo/domain/controller/reportController.dart';
import 'package:citasnuevo/domain/controller/userSettingsController.dart';
import 'package:citasnuevo/domain/repository/appSettingsRepo/appSettingsRepo.dart';
import 'package:citasnuevo/domain/repository/appSettingsRepo/userSettingsRepo.dart';
import 'package:citasnuevo/domain/repository/authRepo/authRepo.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:citasnuevo/domain/repository/reactionRepository/reactionRepository.dart';
import 'package:citasnuevo/domain/repository/reportRepo/reportRepo.dart';
import 'package:citasnuevo/domain/repository/settingsRepository/SettingsRepository.dart';
import 'package:citasnuevo/presentation/appSettingsPresentation/appSettingsPresentation.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/auth.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatPresentation.dart';
import 'package:citasnuevo/presentation/homeReportScreenPresentation/homeReportScreenPresentation.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:citasnuevo/presentation/reactionPresentation/reactionPresentation.dart';

import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/presentation/settingsPresentation/settingsScreenPresentation.dart';
import 'package:citasnuevo/presentation/userSettingsPresentation/userPresentation.dart';

class Dependencies {
  static late final ReactionPresentation reactionPresentation;
  static late final HomeScreenPresentation homeScreenPresentation;
  static late final AuthScreenPresentation authScreenPresentation;
  static late final HomeReportScreenPresentation homeReportScreenPresentation;
  static late final ChatPresentation chatPresentation;
  static late final ApplicationDataSource applicationDataSource;
  static late final SettingsScreenPresentation settingsScreenPresentation;
  static late final AppSettingsPresentation appSettingsPresentation;
    static late final UserSettingsPresentation userSettingsPresentation;


  static Future<void> startAuthDependencies() async {
    AuthDataSource externalUserDataSourceContract = AuthDataSourceImpl();
    // ignore: unused_local_variable
    NetworkInfoContract networkInfoContract = NetworkInfoImpl();
    AuthRepository _userContractRepository =
        AuthRepositoryImpl(authDataSource: externalUserDataSourceContract);

    AuthScreenController authScreenController =
        AuthScreenController(authRepository: _userContractRepository);

    authScreenPresentation =
        AuthScreenPresentation(authScreenController: authScreenController);
  }

  static Future<void> startDependencies() async {
    applicationDataSource =
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
    ReactionsControllerImpl reactionsController =
        ReactionsControllerImpl(reactionRepository: reactionRepository);

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
    ChatControllerImpl chatController =
        new ChatControllerImpl(chatRepository: chatRepository);
    chatPresentation = new ChatPresentation(chatController: chatController);

    SettingsDataSource settingsDataSource =
        new SettingsDataSourceImpl(source: applicationDataSource);
    SettingsRepository settingsRepository =
        new SettingsRepoImpl(settingsDataSource: settingsDataSource);
    SettingsController settingsController =
        new SettingsControllerImpl(settingsRepository: settingsRepository);
    settingsScreenPresentation =
        new SettingsScreenPresentation(settingsController: settingsController);
    ApplicationSettingsDataSource applicationSettingsDataSource =
        new ApplicationDataSourceImpl(source: applicationDataSource);
    AppSettingsRepository appSettingsRepository =
        ApplicationSettingsRepositoryImpl(
            appSettingsDataSource: applicationSettingsDataSource);
    AppSettingsController appSettingsController =
        AppSettingsController(appSettingsRepository: appSettingsRepository);
    appSettingsPresentation = new AppSettingsPresentation(
        appSettingsController: appSettingsController);


        UserSettingsDataSource userSettingsDataSource= new UserSettingsDataSourceImpl(source: applicationDataSource);
        UserSettingsRepository userSettingsRepository= new UserSettingsRepoImpl(appSettingsDataSource: userSettingsDataSource);
        UserSettingsController userSettingsController=new UserSettingsController(userSettingsRepository: userSettingsRepository);
        userSettingsPresentation= new UserSettingsPresentation(userSettingsController: userSettingsController);
  }

  static void startUtilDependencies() {
    // ignore: unused_local_variable
    GetProfileImage getProfileImage = new GetProfileImage();
  }

  static void restartChatDependencies() {
    ChatDataSource chatDataSource =
        new ChatDatsSourceImpl(source: applicationDataSource);

    ChatRepository chatRepository =
        new ChatRepoImpl(chatDataSource: chatDataSource);
    ChatControllerImpl chatController =
        new ChatControllerImpl(chatRepository: chatRepository);
    chatPresentation = new ChatPresentation(chatController: chatController);
  }
}
