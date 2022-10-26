import 'package:citasnuevo/core/ads_services/Ads.dart';
import 'package:citasnuevo/core/common/commonUtils/getUserImage.dart';
import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/data/Mappers/ReactionsMappers.dart';
import 'package:citasnuevo/data/dataSources/HomeDataSource/homeScreenDataSources.dart';
import 'package:citasnuevo/data/dataSources/appSettings/ApplicationSettingsDataSource.dart';
import 'package:citasnuevo/data/dataSources/authDataSources/authDataSourceImpl.dart';
import 'package:citasnuevo/data/dataSources/chatDataSource/chatDataSource.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/data/dataSources/reactionDataSources/reactionDataSource.dart';
import 'package:citasnuevo/data/dataSources/reportDataSource/reportDataSource.dart';
import 'package:citasnuevo/data/dataSources/rewardsDataSource/rewardDataSource.dart';
import 'package:citasnuevo/data/dataSources/sanctionsDataSource.dart/sanctionsDataSource.dart';
import 'package:citasnuevo/data/dataSources/settingsDataSource/settingsDataSource.dart';
import 'package:citasnuevo/data/dataSources/userCreatorDataSource/userCreator.DataSource.dart';
import 'package:citasnuevo/data/dataSources/userSettingsDataSource/userSettingsDataSource.dart';
import 'package:citasnuevo/data/dataSources/verificationDataSource/verificationDataSource.dart';
import 'package:citasnuevo/data/repositoryImpl/appSettingsRepoImpl/appSettingsRepo.dart';
import 'package:citasnuevo/data/repositoryImpl/authRepoImpl/authRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/chatRepoImpl/chatRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/homeScreenRepoImpl.dart/homeScreenRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/reactionRepoImpl/reactionRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/reportRepoImpl/reportRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/rewardRepoImpl/rewardRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/sanctionsRepoImpl/sanctionsRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/settingsRepoImpl/settingsRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/userCreatorRepoImpl/userCreatorRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/userSettingsRepoImpl.dart/userSettingsRepoImpl.dart';
import 'package:citasnuevo/data/repositoryImpl/verificationRepoImpl/verificationRepoImpl.dart';
import 'package:citasnuevo/domain/controller/SettingsController.dart';
import 'package:citasnuevo/domain/controller/appSettingsController.dart';
import 'package:citasnuevo/domain/controller/authScreenController.dart';
import 'package:citasnuevo/domain/controller/chatController.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/domain/controller/reactionsController.dart';
import 'package:citasnuevo/domain/controller/reportController.dart';
import 'package:citasnuevo/domain/controller/rewardController.dart';
import 'package:citasnuevo/domain/controller/sanctionsController.dart';
import 'package:citasnuevo/domain/controller/userCreatorController.dart';
import 'package:citasnuevo/domain/controller/userSettingsController.dart';
import 'package:citasnuevo/domain/controller/verificationController.dart';
import 'package:citasnuevo/domain/controller_bridges/ChatToMessagesController.dart';
import 'package:citasnuevo/domain/controller_bridges/HomeScreenCotrollerBridge.dart';
import 'package:citasnuevo/domain/controller_bridges/MessagesToChatControllerBridge.dart';
import 'package:citasnuevo/domain/controller_bridges/RewardScreenControllerBridge.dart';
import 'package:citasnuevo/domain/controller_bridges/SettingsToAppSettingsControllerBridge.dart';
import 'package:citasnuevo/domain/controller_bridges/UserSettingsToSettingsControllerBridge.dart';
import 'package:citasnuevo/domain/repository/appSettingsRepo/appSettingsRepo.dart';
import 'package:citasnuevo/domain/repository/appSettingsRepo/userSettingsRepo.dart';
import 'package:citasnuevo/domain/repository/authRepo/authRepo.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';
import 'package:citasnuevo/domain/repository/homeScreenRepo/homeScreenRepo.dart';
import 'package:citasnuevo/domain/repository/reactionRepository/reactionRepository.dart';
import 'package:citasnuevo/domain/repository/reportRepo/reportRepo.dart';
import 'package:citasnuevo/domain/repository/rewardRepository/rewardRepository.dart';
import 'package:citasnuevo/domain/repository/sanctionsRepo/sanctionsRepo.dart';
import 'package:citasnuevo/domain/repository/settingsRepository/SettingsRepository.dart';
import 'package:citasnuevo/domain/repository/userCreatorRepo/userCreatorRepo.dart';
import 'package:citasnuevo/domain/repository/verificationRepository/verificationRepository.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/appSettingsPresentation/appSettingsPresentation.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/auth.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatPresentation.dart';
import 'package:citasnuevo/presentation/homeReportScreenPresentation/homeReportScreenPresentation.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:citasnuevo/presentation/reactionPresentation/reactionPresentation.dart';

import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/presentation/rewardScreenPresentation/rewardScreenPresentation.dart';
import 'package:citasnuevo/presentation/sanctionsPresentation/sanctionsPresentation.dart';
import 'package:citasnuevo/presentation/settingsPresentation/settingsScreenPresentation.dart';
import 'package:citasnuevo/presentation/userCreatorPresentation/userCreatorPresentation.dart';
import 'package:citasnuevo/presentation/userSettingsPresentation/userPresentation.dart';
import 'package:citasnuevo/presentation/verificationPresentation/verificationPresentation.dart';
import 'package:flutter/material.dart';

import '../iapPurchases/iapPurchases.dart';
import '../notifications/notifications_service.dart';

class Dependencies {
  static late final AdvertisingServices advertisingServices =
      new AdvertisingServices();

  static late final AuthScreenPresentation authScreenPresentation;
  static late final ApplicationDataSource applicationDataSource =
      ApplicationDataSource(userId: GlobalDataContainer.userId);

  static late final AuthService authService = AuthServiceImpl();
  static late final AuthScreenDataSource authDataSource =
      AuthScreenDataSourceImpl(authService: authService);

  static late final AuthRepository authRepository;

  ///--CONTROLLER BRIDGES
  ///
  ///
  ///
  static late final RewardScreenControllerBridge rewardScreenControllerBridge =
      new RewardScreenControllerBridge();
  static late final HomeScreenControllerBridge<HomeScreenController>
      homeScreenControllerBridge =
      new HomeScreenControllerBridge<HomeScreenController>();

  static late final MessagesToChatControllerBridge
      messagesToChatControllerBridge = new MessagesToChatControllerBridge();

  static late final AppSettingsToSettingsControllerBridge
      settingsControllerBridge = new AppSettingsToSettingsControllerBridge();
  static late final UserSettingsToSettingsControllerBridge
      userSettingsToSettingsControllerBridge =
      UserSettingsToSettingsControllerBridge();

      static late final ChatToMessagesControllerBridge chatToMessagesControllerBridge=ChatToMessagesControllerBridge();

static late final VerificationDataSource verificationDataSource= new VerificationDataSourceImpl(source: applicationDataSource);
static late final VerificationRepository verificationRepository = VerificationRepoImpl(verificationDataSource: verificationDataSource);
static late final VerificationController verificationController =VerificationControllerImpl(verificationRepository: verificationRepository);
static late final VerificationPresentation verificationPresentation= VerificationPresentation(verificationController: verificationController);







  ///SANCTIONS SCREEN
  ///
  ///
  ///
  ///
  static late final SanctionsDataSource sanctionsDataSource =
      SanctionsDataSourceImpl(
          source: applicationDataSource, authService: authService);
  static late final SanctionsRepository sanctionsRepository =
      SanctionsRepoImpl(sanctionsDataSource: sanctionsDataSource);
  static late final SanctionsController sanctionsController =
      SanctionsControllerImpl(sanctionsRepository: sanctionsRepository);
  static late final SanctionsPresentation sanctionsPresentation =
      SanctionsPresentation(sanctionsController: sanctionsController);

  /// REWARD SCREEN
  ///
  ///
  ///
  ///

  static late final RewardDataSource rewardDataSource =
      RewardDataSourceImpl(source: applicationDataSource);
  static late final RewardRepository rewardRepository =
      RewardRepoImpl(rewardDataSource: rewardDataSource);
  static late final RewardController rewardController = RewardControllerImpl(
      rewardRepository: rewardRepository,
      rewardScreenControlBridge: rewardScreenControllerBridge);
  static late final RewardScreenPresentation rewardScreenPresentation =
      RewardScreenPresentation(rewardController: rewardController);

  ///HOME_SCREEN
  ///
  ///
  ///

  static late final HomeScreenDataSource homeScreenDataSource =
      HomeScreenDataSourceImpl(source: applicationDataSource);
  static late final HomeScreenRepository homeScreenRepository =
      HomeScreenRepositoryImpl(homeScreenDataSource: homeScreenDataSource);
  static late final HomeScreenController homeScreenController =
      HomeScreenController(
          homeScreenRepository: homeScreenRepository,
          homeScreenControllerBridge: homeScreenControllerBridge);
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
      ReactionsControllerImpl(
          reactionRepository: reactionRepository,
          homeScreencontrollerbridge: homeScreenControllerBridge);

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
  static late final ChatControllerImpl chatController = new ChatControllerImpl(
      chatRepository: chatRepository,
      homeScreenControllreBridge: homeScreenControllerBridge);
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
      new SettingsControllerImpl(
          userSettingsToSettingsControllerBridge:
              userSettingsToSettingsControllerBridge,
          settingsRepository: settingsRepository,
          appSettingstoSettingscontrollerBridge: settingsControllerBridge,
          rewardScreenControllerBridge: rewardScreenControllerBridge);
  static late final SettingsScreenPresentation settingsScreenPresentation =
      new SettingsScreenPresentation(settingsController: settingsController);



  ///APP_SETTINGS
  ///
  ///
  ///

  static late final ApplicationSettingsDataSource
      applicationSettingsDataSource = new ApplicationDataSourceImpl(
          source: applicationDataSource, authService: authService);
  static late final AppSettingsRepository appSettingsRepository =
      ApplicationSettingsRepositoryImpl(
          appSettingsDataSource: applicationSettingsDataSource);
  static late final AppSettingsController appSettingsController =
      AppSettingsController(
          appSettingsRepository: appSettingsRepository,
          settingsToAppSettingsControllerBridge: settingsControllerBridge);
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
          userSettingsToSettingsControllerBridge:
              userSettingsToSettingsControllerBridge,
          userSettingsRepository: userSettingsRepository);
  static late final UserSettingsPresentation userSettingsPresentation =
      new UserSettingsPresentation(
          userSettingsController: userSettingsController);
/// USER CREATOR
/// 
/// 
/// 
  static late final UserCreatorDataSource userCreatorDataSource =
      new UserCreatorDataSourceImpl(
          source: applicationDataSource, authService: authService);
  static late final UserCreatorRepo userCreatorRepo =
      new UserCreatorRepoImpl(userCreatorDataSource: userCreatorDataSource);
  static late final UserCreatorController userCreatorController =
      new UserCreatorControllerImpl(userCreatorRepo: userCreatorRepo);

  static late final UserCreatorPresentation userCreatorPresentation =
      new UserCreatorPresentation(userCreatorController: userCreatorController);

  static Future<void> startAuthDependencies() async {
    // ignore: unused_local_variable
    NetworkInfoContract networkInfoContract = NetworkInfoImpl();

    authRepository = AuthRepositoryImpl(authDataSource: authDataSource);

    AuthScreenController authScreenController =
        AuthScreenController(authRepository: authRepository);

    authScreenPresentation =
        AuthScreenPresentation(authScreenController: authScreenController);
  }

  static Future<void> startDependencies({required bool restart}) async {
    if (restart == false) {}
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
    sanctionsPresentation.clearModuleData();
  }

  static Future<void> restartDependencies() async {
    applicationDataSource.userId = GlobalDataContainer.userId;

    applicationDataSource.initializeMainDataSource();

    reactionPresentation.initializeModuleData();
    homeScreenPresentation.initializeModuleData();
    // authScreenPresentation.clearModuleData();
    homeReportScreenPresentation.initializeModuleData();
    chatPresentation.initializeModuleData();
    settingsScreenPresentation.initializeModuleData();
    appSettingsPresentation.initializeModuleData();
    userSettingsPresentation.initializeModuleData();
    sanctionsPresentation.initializeModuleData();
        verificationPresentation.initializeModuleData();

  }

  static void clearDependenciesAfterCreateUser() {
    userCreatorPresentation.clearModuleData();
  }

  static Future<bool> initializeDependencies() async {
    try {
      applicationDataSource.userId = GlobalDataContainer.userId as String;
      bool userDataExists =
          await applicationDataSource.initializeMainDataSource();

      if (userDataExists == true) {
        await PurchasesServices.purchasesServices.initService();
        NotificationService instance = new NotificationService();
        await instance.startBackgroundNotificationHandler();
        homeScreenPresentation.initializeModuleData();
        chatPresentation.initializeModuleData();
        reactionPresentation.initializeModuleData();

        authScreenPresentation.clearModuleData();
        homeReportScreenPresentation.initializeModuleData();
        settingsScreenPresentation.initializeModuleData();
        appSettingsPresentation.initializeModuleData();
        userSettingsPresentation.initializeModuleData();
        advertisingServices.initializeAdsService();
        rewardScreenPresentation.initializeModuleData();
        sanctionsPresentation.initializeModuleData();
                verificationPresentation.initializeModuleData();


        return true;
      } else {
        userCreatorPresentation.initializeModuleData();
        advertisingServices.shouldUserGiveCosent();

        return false;
      }
    } catch (e) {
      throw e;
    }
  }
}
