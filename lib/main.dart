import 'package:camera/camera.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';

import 'package:citasnuevo/presentation/authScreenPresentation/Screens/authScreen.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/auth.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTilesScreen.dart';
import 'package:citasnuevo/presentation/homeReportScreenPresentation/ReportScreen.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Screens/HomeScreen.dart';
import 'package:citasnuevo/presentation/reactionPresentation/Screens/ReactionScreen.dart';
import 'package:citasnuevo/presentation/rewardScreenPresentation/rewardScreen.dart';
import 'package:citasnuevo/presentation/sanctionsPresentation/sanctionsScreen.dart';
import 'package:citasnuevo/presentation/userCreatorPresentation/userCreatorScreen.dart';
import 'package:citasnuevo/presentation/userSettingsPresentation/userSettingsScreen.dart';
import 'package:citasnuevo/presentation/verificationPresentation/verificationScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:provider/provider.dart';

GlobalKey startKey = new GlobalKey();
GlobalKey sanctionKey = new GlobalKey();
GlobalKey verificationScreenKey= new GlobalKey();
List<CameraDescription> cameras=[];

final RouteObserver<PageRoute> routeObserver = new RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras= await availableCameras();

  Intl.defaultLocale = await findSystemLocale();
  await initializeDateFormatting(Intl.defaultLocale);
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
        Provider(create: (_) => Dependencies.userCreatorPresentation)
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        initialRoute: Start.routeName,

        /// Only for "Screen" ended Widget, because these are the principal screens we will be Navigating
        ///
        /// The widgets ended in "Screen" are the first route of every module,
        /// they are accesed from other module "screen" ending widget
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


