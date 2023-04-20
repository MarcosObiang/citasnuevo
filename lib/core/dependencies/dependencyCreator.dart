import 'package:citasnuevo/App/ControllerBridges/PurchseSystemControllerBridge.dart';
import 'package:flutter/material.dart';

import 'package:citasnuevo/App/ApplicationSettings/ApplicationSettingsDataSource.dart';
import 'package:citasnuevo/App/ApplicationSettings/appSettingsController.dart';
import 'package:citasnuevo/App/ApplicationSettings/appSettingsPresentation/appSettingsPresentation.dart';
import 'package:citasnuevo/App/ApplicationSettings/appSettingsRepo.dart';
import 'package:citasnuevo/App/ApplicationSettings/appSettingsRepoImpl.dart';
import 'package:citasnuevo/App/Auth/authDataSourceImpl.dart';
import 'package:citasnuevo/App/Auth/authRepo.dart';
import 'package:citasnuevo/App/Auth/authRepoImpl.dart';
import 'package:citasnuevo/App/Auth/authScreenController.dart';
import 'package:citasnuevo/App/Auth/authScreenPresentation/authPresentation.dart';
import 'package:citasnuevo/App/Chat/chatController.dart';
import 'package:citasnuevo/App/Chat/chatDataSource.dart';
import 'package:citasnuevo/App/Chat/chatPresentation/chatPresentation.dart';
import 'package:citasnuevo/App/Chat/chatRepo.dart';
import 'package:citasnuevo/App/Chat/chatRepoImpl.dart';
import 'package:citasnuevo/App/ControllerBridges/ChatToMessagesController.dart';
import 'package:citasnuevo/App/ControllerBridges/HomeScreenCotrollerBridge.dart';
import 'package:citasnuevo/App/MainDatasource/principalDataSource.dart';
import 'package:citasnuevo/App/ControllerBridges/MessagesToChatControllerBridge.dart';
import 'package:citasnuevo/App/ProfileViewer/homeScreenController.dart';
import 'package:citasnuevo/App/ProfileViewer/homeScreenDataSources.dart';
import 'package:citasnuevo/App/ProfileViewer/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:citasnuevo/App/ProfileViewer/homeScreenRepo.dart';
import 'package:citasnuevo/App/ProfileViewer/homeScreenRepoImpl.dart';
import 'package:citasnuevo/App/PurchaseSystem/purchaseSystemDataSource.dart';
import 'package:citasnuevo/App/PurchaseSystem/purchaseSystemController.dart';
import 'package:citasnuevo/App/PurchaseSystem/purchaseSystemPresentation/purchaseSystemPresentation.dart';
import 'package:citasnuevo/App/PurchaseSystem/purchasesystemRepository.dart';
import 'package:citasnuevo/App/PurchaseSystem/purchaseSystemRepoImpl.dart';
import 'package:citasnuevo/App/Reactions/reactionDataSource.dart';
import 'package:citasnuevo/App/Reactions/reactionPresentation/reactionPresentation.dart';
import 'package:citasnuevo/App/Reactions/reactionRepoImpl.dart';
import 'package:citasnuevo/App/Reactions/reactionRepository.dart';
import 'package:citasnuevo/App/Reactions/reactionsController.dart';
import 'package:citasnuevo/App/ReportUsers/homeReportScreenPresentation.dart';
import 'package:citasnuevo/App/ReportUsers/reportController.dart';
import 'package:citasnuevo/App/ReportUsers/reportDataSource.dart';
import 'package:citasnuevo/App/ReportUsers/reportRepo.dart';
import 'package:citasnuevo/App/ReportUsers/reportRepoImpl.dart';
import 'package:citasnuevo/App/Rewards/RewardScreenControllerBridge.dart';
import 'package:citasnuevo/App/Rewards/rewardController.dart';
import 'package:citasnuevo/App/Rewards/rewardDataSource.dart';
import 'package:citasnuevo/App/Rewards/rewardRepoImpl.dart';
import 'package:citasnuevo/App/Rewards/rewardRepository.dart';
import 'package:citasnuevo/App/Rewards/rewardScreenPresentation/rewardScreenPresentation.dart';
import 'package:citasnuevo/App/Sanctions/sanctionsController.dart';
import 'package:citasnuevo/App/Sanctions/sanctionsDataSource.dart';
import 'package:citasnuevo/App/Sanctions/sanctionsPresentation/sanctionsPresentation.dart';
import 'package:citasnuevo/App/Sanctions/sanctionsRepo.dart';
import 'package:citasnuevo/App/Sanctions/sanctionsRepoImpl.dart';
import 'package:citasnuevo/App/Settings/SettingsController.dart';
import 'package:citasnuevo/App/Settings/SettingsRepository.dart';
import 'package:citasnuevo/App/Settings/SettingsToAppSettingsControllerBridge.dart';
import 'package:citasnuevo/App/Settings/settingsDataSource.dart';
import 'package:citasnuevo/App/Settings/settingsPresentation/settingsScreenPresentation.dart';
import 'package:citasnuevo/App/Settings/settingsRepoImpl.dart';
import 'package:citasnuevo/App/UserCreator/userCreator.DataSource.dart';
import 'package:citasnuevo/App/UserCreator/userCreatorController.dart';
import 'package:citasnuevo/App/UserCreator/userCreatorPresentation/userCreatorPresentation.dart';
import 'package:citasnuevo/App/UserCreator/userCreatorRepo.dart';
import 'package:citasnuevo/App/UserCreator/userCreatorRepoImpl.dart';
import 'package:citasnuevo/App/UserSettings/UserSettingsToSettingsControllerBridge.dart';
import 'package:citasnuevo/App/UserSettings/userSettingsController.dart';
import 'package:citasnuevo/App/UserSettings/userSettingsDataSource.dart';
import 'package:citasnuevo/App/UserSettings/userSettingsPresentation/userPresentation.dart';
import 'package:citasnuevo/App/UserSettings/userSettingsRepo.dart';
import 'package:citasnuevo/App/UserSettings/userSettingsRepoImpl.dart';
import 'package:citasnuevo/App/Verification/verificationController.dart';
import 'package:citasnuevo/App/Verification/verificationDataSource.dart';
import 'package:citasnuevo/App/Verification/verificationPresentation/verificationPresentation.dart';
import 'package:citasnuevo/App/Verification/verificationRepoImpl.dart';
import 'package:citasnuevo/App/Verification/verificationRepository.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/App/principalScreenPresentation.dart';
import '../services/Ads.dart';
import '../appwrite_services/appwrite_services.dart';
import '../common/commonUtils/getUserImage.dart';
import '../services/firebase_auth.dart';
import '../globalData.dart';
import '../iapPurchases/iapPurchases.dart';
import '../notifications/notifications_service.dart';
import '../platform/networkInfo.dart';

class Dependencies {
  static late Server serverAPi = new Server();
  static late final AdvertisingServices advertisingServices =
      new AdvertisingServices();

  static late final AuthScreenPresentation authScreenPresentation;
  static late final ApplicationDataSource applicationDataSource =
      ApplicationDataSource();

  static late final AuthService authService = AuthServiceImpl();
  static late final AuthScreenDataSource authDataSource =
      AuthScreenDataSourceImpl(
          authService: authService, source: applicationDataSource);

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
  static late final PurchaseSystemControllerBridge
      purchaseSystemControllerBridge = PurchaseSystemControllerBridge();

  static late final MessagesToChatControllerBridge
      messagesToChatControllerBridge = new MessagesToChatControllerBridge();

  static late final AppSettingsToSettingsControllerBridge
      settingsControllerBridge = new AppSettingsToSettingsControllerBridge();
  static late final UserSettingsToSettingsControllerBridge
      userSettingsToSettingsControllerBridge =
      UserSettingsToSettingsControllerBridge();

  static late final ChatToMessagesControllerBridge
      chatToMessagesControllerBridge = ChatToMessagesControllerBridge();

  static late final VerificationDataSource verificationDataSource =
      new VerificationDataSourceImpl(source: applicationDataSource);
  static late final VerificationRepository verificationRepository =
      VerificationRepoImpl(verificationDataSource: verificationDataSource);
  static late final VerificationController verificationController =
      VerificationControllerImpl(
          verificationRepository: verificationRepository);
  static late final VerificationPresentation verificationPresentation =
      VerificationPresentation(verificationController: verificationController);

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
      purchaseSystemControllerBridge: purchaseSystemControllerBridge,
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
    advertisingServices: advertisingServices,
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
    purchaseSystemControllerBridge: purchaseSystemControllerBridge,
  );
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

  /// PRINCIPAL SCREEN
  ///
  ///
  ///
  ///
  ///
  static late final PrincipalScreenPresentation principalScreenPresentation =
      PrincipalScreenPresentation(
          reactionScreenPresentation: reactionPresentation,
          chatPresentation: chatPresentation,
          rewardScreenPresentation: rewardScreenPresentation);

  /// PURCHASE PRESENTATION
  ///
  ///
  ///
  static late final PurchaseSystemDataSource purchaseSystemDataSource =
      PurchaseSystemDataSourceImplementation(source: applicationDataSource);
  static late final PurchaseSystemRepository purchaseSystemRepository =
      PurchaseSystemRepoImpl(
          purchaseSystemDataSource: purchaseSystemDataSource);
  static late final PurchaseSystemController purchaseSystemController =
      PurchaseSystemControllerImpl(
          purchaseSystemControllerBridge: purchaseSystemControllerBridge,
          purchaseSystemRepository: purchaseSystemRepository);

  static late final PurchaseSystemPresentation purchaseSystemPresentation =
      PurchaseSystemPresentation(
          purchaseSystemController: purchaseSystemController);
  static void startUtilDependencies() {
    // ignore: unused_local_variable
    GetProfileImage getProfileImage = new GetProfileImage();
  }

  static void clearDependenciesAndUserIdentifiers() async {
    reactionPresentation.clearModuleData();
    homeScreenPresentation.clearModuleData();
    authScreenPresentation.clearModuleData();
    homeReportScreenPresentation.clearModuleData();
    chatPresentation.clearModuleData();
    settingsScreenPresentation.clearModuleData();
    appSettingsPresentation.clearModuleData();
    userSettingsPresentation.clearModuleData();
    sanctionsPresentation.clearModuleData();
    userCreatorPresentation.clearModuleData();
    applicationDataSource.clearAppDataSource();
    rewardScreenPresentation.clearModuleData();
    purchaseSystemPresentation.clearModuleData();

    GlobalDataContainer.clearGlobalDataContainer();
  }

  static void clearDependenciesOnly() async {
    reactionPresentation.clearModuleData();
    verificationPresentation.clearModuleData();

    homeScreenPresentation.clearModuleData();
    authScreenPresentation.clearModuleData();
    homeReportScreenPresentation.clearModuleData();
    chatPresentation.clearModuleData();
    settingsScreenPresentation.clearModuleData();
    appSettingsPresentation.clearModuleData();
    userSettingsPresentation.clearModuleData();
    sanctionsPresentation.clearModuleData();
    userCreatorPresentation.clearModuleData();
    applicationDataSource.clearAppDataSource();
    rewardScreenPresentation.clearModuleData();
    purchaseSystemPresentation.clearModuleData();
  }

  static void clearDependenciesForSanction() async {
    reactionPresentation.clearModuleData();
    verificationPresentation.clearModuleData();

    homeScreenPresentation.clearModuleData();
    authScreenPresentation.clearModuleData();
    homeReportScreenPresentation.clearModuleData();
    chatPresentation.clearModuleData();
    settingsScreenPresentation.clearModuleData();
    appSettingsPresentation.clearModuleData();
    userSettingsPresentation.clearModuleData();
    userCreatorPresentation.clearModuleData();
    applicationDataSource.clearAppDataSource();
    rewardScreenPresentation.clearModuleData();
    purchaseSystemPresentation.clearModuleData();
  }

  static void clearDependenciesAfterCreateUser() {
    userCreatorPresentation.clearModuleData();
  }

  ///RETURN TRUE IF THE USER EXISTS IN THE DATABASE, IF NOT IT RETURNS FALSE AND ONLY THE USERCREATOR MODULE IS INITIALIZED
  static Future<void> initializeDependencies() async {
    try {
      //    await PurchasesServices.purchasesServices.initService();

      homeScreenPresentation.initializeModuleData();
      chatPresentation.initializeModuleData();
      reactionPresentation.initializeModuleData();

      authScreenPresentation.clearModuleData();
      homeReportScreenPresentation.initializeModuleData();
      settingsScreenPresentation.initializeModuleData();
      appSettingsPresentation.initializeModuleData();
      userSettingsPresentation.initializeModuleData();
      rewardScreenPresentation.initializeModuleData();
      purchaseSystemPresentation.initializeModuleData();
      verificationPresentation.initializeModuleData();
      userCreatorPresentation.initializeModuleData();

      await applicationDataSource.initializeMainDataSource();
      NotificationService instance = new NotificationService();
      await instance.startBackgroundNotificationHandler();
      sanctionsPresentation.initializeModuleData();
            advertisingServices.initializeAdsService();

    } catch (e, s) {
      print(s);
      throw e;
    }
  }

  static void initializeUserCreatorModuleDepenencies() {
    userCreatorPresentation.initializeModuleData();
  }
}
