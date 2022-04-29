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
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/appSettingsPresentation/appSettingsPresentation.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/auth.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatPresentation.dart';
import 'package:citasnuevo/presentation/homeReportScreenPresentation/homeReportScreenPresentation.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:citasnuevo/presentation/reactionPresentation/reactionPresentation.dart';

import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/presentation/settingsPresentation/settingsScreenPresentation.dart';
import 'package:citasnuevo/presentation/userSettingsPresentation/userPresentation.dart';
import 'package:flutter/material.dart';

class Dependencies {
      static late final AdvertisingServices advertisingServices= new AdvertisingServices()..adsServiceInit();

  static late final AuthScreenPresentation authScreenPresentation;
  static late final ApplicationDataSource applicationDataSource=ApplicationDataSource(userId: GlobalDataContainer.userId as String);

  static late final AuthDataSource authDataSource;
  static late final AuthRepository authRepository;

  ///HOME_SCREEN
  ///
  ///
  static late final HomeScreenDataSource homeScreenDataSource =
      HomeScreenDataSourceImpl(source: applicationDataSource);
  static late final HomeScreenRepository homeScreenRepository =
      HomeScreenRepositoryImpl(homeScreenDataSource: homeScreenDataSource);
  static late final HomeScreenController homeScreenController =
      HomeScreenController(homeScreenRepository: homeScreenRepository);
  static late final HomeScreenPresentation homeScreenPresentation =
      HomeScreenPresentation(homeScreenController: homeScreenController);

  ///REACTIONS
  ///
  ///

  static late final ReactionDataSource reactionDataSource =
      ReactionDataSourceImpl(
    source: applicationDataSource,
  );
  static late final ReactionRepository reactionRepository =
      ReactionRepositoryImpl(reactionDataSource: reactionDataSource);
  static late final ReactionsControllerImpl reactionsController =
      ReactionsControllerImpl(reactionRepository: reactionRepository);

  static late final ReactionPresentation reactionPresentation =
      new ReactionPresentation(reactionsController: reactionsController);

  ///REPORT_USER
  ///
  ///

  static late final ReportDataSource reportDataSource =
      new ReportDataSourceImpl(source: applicationDataSource);
  static late final ReportRepository reportRepository =
      new ReportRepositoryImpl(reportDataSource: reportDataSource);
  static late final ReportController reportController =
      new ReportController(reportRepository: reportRepository);
  static late final homeReportScreenPresentation =
      new HomeReportScreenPresentation(reportController: reportController);

  ///CHAT
  ///
  ///

  static late final ChatDataSource chatDataSource =
      new ChatDatsSourceImpl(source: applicationDataSource);

  static late final ChatRepository chatRepository =
      new ChatRepoImpl(chatDataSource: chatDataSource);
  static late final ChatControllerImpl chatController =
      new ChatControllerImpl(chatRepository: chatRepository);
  static late final chatPresentation =
      new ChatPresentation(chatController: chatController);

  ///SETTINGS
  ///
  ///

  static late final SettingsDataSource settingsDataSource =
      new SettingsDataSourceImpl(source: applicationDataSource);
  static late final SettingsRepository settingsRepository =
      new SettingsRepoImpl(settingsDataSource: settingsDataSource);
  static late final SettingsController settingsController =
      new SettingsControllerImpl(settingsRepository: settingsRepository);
  static late final SettingsScreenPresentation settingsScreenPresentation =
      new SettingsScreenPresentation(settingsController: settingsController);

  ///APP_SETTINGS
  ///
  ///

  static late final ApplicationSettingsDataSource
      applicationSettingsDataSource =
      new ApplicationDataSourceImpl(source: applicationDataSource);
  static late final AppSettingsRepository appSettingsRepository =
      ApplicationSettingsRepositoryImpl(
          appSettingsDataSource: applicationSettingsDataSource);
  static late final AppSettingsController appSettingsController =
      AppSettingsController(appSettingsRepository: appSettingsRepository);
  static late final AppSettingsPresentation appSettingsPresentation =
      new AppSettingsPresentation(appSettingsController: appSettingsController);

  ///USER_SETTINGS
  ///
  ///

  static late final UserSettingsDataSource userSettingsDataSource =
      new UserSettingsDataSourceImpl(source: applicationDataSource);
  static late final UserSettingsRepository userSettingsRepository =
      new UserSettingsRepoImpl(appSettingsDataSource: userSettingsDataSource);
  static late final UserSettingsController userSettingsController =
      new UserSettingsController(
          userSettingsRepository: userSettingsRepository);
  static late final UserSettingsPresentation userSettingsPresentation = new UserSettingsPresentation(
      userSettingsController: userSettingsController);

  static Future<void> startAuthDependencies() async {
    // ignore: unused_local_variable
    NetworkInfoContract networkInfoContract = NetworkInfoImpl();

    authDataSource = new AuthDataSourceImpl();
    authRepository = AuthRepositoryImpl(authDataSource: authDataSource);

    AuthScreenController authScreenController =
        AuthScreenController(authRepository: authRepository);

    authScreenPresentation =
        AuthScreenPresentation(authScreenController: authScreenController);
  }

  static Future<void> startDependencies({required bool restart}) async {
    if (restart == false) {
      
    }
    if (restart == true) {
      restartDependencies();
    }
  }

  static void startUtilDependencies() {
    // ignore: unused_local_variable
    GetProfileImage getProfileImage = new GetProfileImage();
  }

  static Future<void> clearDependencies() async {
    reactionPresentation.clearModuleData();
    homeScreenPresentation.clearModuleData();
    // authScreenPresentation.clearModuleData();
    homeReportScreenPresentation.clearModuleData();
    chatPresentation.clearModuleData();
    applicationDataSource.clearAppDataSource();
    settingsScreenPresentation.clearModuleData();
    appSettingsPresentation.clearModuleData();
    userSettingsPresentation.clearModuleData();
    Navigator.of(startKey.currentContext as BuildContext)
        .popUntil((route) => route.isFirst);
  }

  static Future<void> restartDependencies() async {
       applicationDataSource.userId=GlobalDataContainer.userId as String;

    applicationDataSource.initializeMainDataSource();

    reactionPresentation.initialize();
    homeScreenPresentation.initialize();
    // authScreenPresentation.clearModuleData();
    homeReportScreenPresentation.initialize();
    chatPresentation.initialize();
    settingsScreenPresentation.initialize();
    appSettingsPresentation.initialize();
    userSettingsPresentation.initialize();
  }
 static void initializeDependencies()async{
   applicationDataSource.userId=GlobalDataContainer.userId as String;
        applicationDataSource.initializeMainDataSource();

    reactionPresentation.initialize();
    homeScreenPresentation.initialize();
    // authScreenPresentation.clearModuleData();
    homeReportScreenPresentation.initialize();
    chatPresentation.initialize();
    settingsScreenPresentation.initialize();
    appSettingsPresentation.initialize();
    userSettingsPresentation.initialize();
  }
}
