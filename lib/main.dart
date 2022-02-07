import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/presentation/Routes.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/Screens/authScreen.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Screens/HomeScreen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  await Dependencies.startDependencies();

  Dependencies.startUtilDependencies();
  runApp(ProviderScope(child: MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Start())));
}

class Start extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StartState();
  static bool done = false;
}

class _StartState extends ConsumerState<Start> {
  @override
  void initState() {
    super.initState();
    ref.read(Dependencies.userDataContainerProvider);
    ref.read(Dependencies.userDataContainerNotifier).checkSignedInUser();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final authState =
        ref.watch(Dependencies.userDataContainerProvider).authState;
    if (authState == AuthState.succes && Start.done == false) {
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
  }
}
