import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/iapPurchases/iapPurchases.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/data/dataSources/authDataSources/authDataSourceImpl.dart';
import 'package:citasnuevo/presentation/Routes.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/Screens/authScreen.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/auth.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Screens/HomeScreen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'core/notifications/notifications_service.dart';

GlobalKey startKey = new GlobalKey();
final RouteObserver<PageRoute> routeObserver = new RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBm3rwlrV7qshSIgASobNLoeb5RgdwwSMI",
          appId: "1:151798284057:android:2f9b0eec10be91eb5e8f88",
          messagingSenderId: "",
          projectId: "hotty-189c7"));

  await Dependencies.startAuthDependencies();
  await Dependencies.authScreenPresentation.checkSignedInUser();
 await PurchasesServices.purchasesServices.initService();
 NotificationService instance = new NotificationService();
  runApp(MultiProvider(
      providers: [
        Provider(create: (_) => Dependencies.settingsScreenPresentation),
        Provider(create: (_) => Dependencies.chatPresentation),
        Provider(create: (_) => Dependencies.homeReportScreenPresentation),
        Provider(create: (_) => Dependencies.authScreenPresentation),
        Provider(create: (_) => Dependencies.homeScreenPresentation),
        Provider(create: (_) => Dependencies.reactionPresentation),
        Provider(create: (_) => Dependencies.appSettingsPresentation),
        Provider(create: (_) => Dependencies.userSettingsPresentation)
      ],
      child: MaterialApp(
          navigatorObservers: [routeObserver],
          debugShowCheckedModeBanner: false,
          home: Start())));
}

class Start extends StatefulWidget {
  static bool done = false;

  @override
  State<StatefulWidget> createState() {
    return _StartState();
  }
}

class _StartState extends State<Start> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Dependencies.reactionPresentation.clearModuleData();
      Dependencies.reactionPresentation.initializeModuleData();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return ChangeNotifierProvider.value(
      value: Dependencies.authScreenPresentation,
      child: Consumer<AuthScreenPresentation>(builder: (BuildContext context,
          AuthScreenPresentation authScreenPresentation, Widget? child) {
        if (authScreenPresentation.authState == AuthState.succes &&
            Start.done == false) {}
        return ScreenUtilInit(
            key: startKey,
            designSize: Size(1080, 1920),
            builder: () {
              return AuthScreen();
            });
      }),
    );
  }
}
