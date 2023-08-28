import 'package:camera/camera.dart';
import 'package:citasnuevo/Utils/appThemes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:provider/provider.dart';

import 'App/Auth/authScreenPresentation/Screens/authScreen.dart';
import 'App/Chat/chatPresentation/Widgets/chatTilesScreen.dart';
import 'App/PrincipalScreen.dart';
import 'App/ProfileViewer/homeScreenPresentation/Screens/HomeScreen.dart';
import 'App/Reactions/reactionPresentation/Screens/ReactionScreen.dart';
import 'App/ReportUsers/ReportScreen.dart';
import 'App/Rewards/rewardScreenPresentation/rewardScreen.dart';
import 'App/Sanctions/sanctionsPresentation/sanctionsScreen.dart';
import 'App/UserCreator/userCreatorPresentation/Widgets/userCreatorScreen.dart';
import 'App/UserSettings/userSettingsPresentation/userSettingsScreen.dart';
import 'App/Verification/verificationPresentation/verificationScreen.dart';
import 'core/dependencies/dependencyCreator.dart';

GlobalKey startKey = new GlobalKey();
GlobalKey sanctionKey = new GlobalKey();
GlobalKey verificationScreenKey = new GlobalKey();
List<CameraDescription> cameras = [];

final RouteObserver<PageRoute> routeObserver = new RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  Intl.defaultLocale = await findSystemLocale();
  await initializeDateFormatting(Intl.defaultLocale as String);
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBm3rwlrV7qshSIgASobNLoeb5RgdwwSMI",
          appId: "1:151798284057:android:2f9b0eec10be91eb5e8f88",
          messagingSenderId: "",
          projectId: "hotty-189c7"));

//FirebaseFunctions.instance.useFunctionsEmulator("localhost", 5001);

  await Dependencies.startAuthDependencies();

  runApp(MultiProvider(
      providers: [
        Provider(create: (_) => Dependencies.settingsScreenPresentation),
        Provider(create: (_) => Dependencies.rewardScreenPresentation),
        Provider(create: (_) => Dependencies.chatPresentation),
        Provider(create: (_) => Dependencies.verificationPresentation),
        Provider(create: (_) => Dependencies.homeReportScreenPresentation),
        Provider(create: (_) => Dependencies.authScreenPresentation),
        Provider(create: (_) => Dependencies.homeScreenPresentation),
        Provider(create: (_) => Dependencies.reactionPresentation),
        Provider(create: (_) => Dependencies.appSettingsPresentation),
        Provider(create: (_) => Dependencies.userSettingsPresentation),
        Provider(create: (_) => Dependencies.principalScreenPresentation),
        Provider(create: (_) => Dependencies.purchaseSystemPresentation),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        initialRoute: Start.routeName,
        theme: ligthThemeData,
        routes: {
          Start.routeName: (context) => Start(),
          HomeAppScreen.routeName: (context) => HomeAppScreen(),
          UserSettingsScreen.routeName: (context) => UserSettingsScreen(),
          BioEditingScreen.routeName: (context) => BioEditingScreen(),
          UserCreatorScreen.routeName: (context) => UserCreatorScreen(),
          SanctionsScreen.routeName: (context) => SanctionsScreen(),
          ChatScreen.routeName: (context) => ChatScreen(),
          ReactionScreen.routeName: (context) => ReactionScreen(),
          ReportScreen.routeName: (context) => ReportScreen(),
          RewardScreen.routeName: (context) => RewardScreen(),
          VerificationScreen.routeName: (context) => VerificationScreen(),
          PrincipalScreen.routeName: (context) => PrincipalScreen(),
        },
        debugShowCheckedModeBanner: false,
      )));
}

class Start extends StatefulWidget {
  static const routeName = '/Start';
  static bool done = false;

  @override
  State<StatefulWidget> createState() {
    return _StartState();
  }
}

class _StartState extends State<Start> {
  bool userStatcusChecked = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return ScreenUtilInit(
        key: startKey,
        designSize: Size(1080, 1920),
        builder: (BuildContext context, Widget? child) {
          return AuthScreen();
        });
  }
}
