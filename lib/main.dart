import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/presentation/Routes.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/Screens/authScreen.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/auth.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Screens/HomeScreen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

GlobalKey startKey = new GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBm3rwlrV7qshSIgASobNLoeb5RgdwwSMI",
          appId: "1:151798284057:android:2f9b0eec10be91eb5e8f88",
          messagingSenderId: "",
          projectId: "hotty-189c7"));

  await Dependencies.startAuth();
  if (GlobalDataContainer.userId != null) {
    await Dependencies.startDependencies();
  }

  Dependencies.startUtilDependencies();
  runApp(MultiProvider(providers: [
    Provider(create: (_) => Dependencies.authScreenPresentation),
    Provider(create: (_) => Dependencies.homeScreenPresentation),
    Provider(create: (_) => Dependencies.reactionPresentation)
  ], child: MaterialApp(debugShowCheckedModeBanner: false, home: Start())));
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
    Dependencies.authScreenPresentation.checkSignedInUser();

    Dependencies.reactionPresentation.initializeReactionsListener();
    //  ref.read(Dependencies.reactionProvider).initializeDataReciever();
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
            Start.done == false) {
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            Navigator.push(context, GoToRoute(page: HomeAppScreen()));
          });
          Start.done = true;
        }
        return ScreenUtilInit(
            designSize: Size(1080, 1920),
            builder: () {
              return AuthScreen();
            });
      }),
    );
  }
}
