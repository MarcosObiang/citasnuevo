import 'package:citasnuevo/core/common/common_widgets.dart/errorWidget.dart';
import 'package:citasnuevo/core/firebase_services/firebase_app.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/presentation/Routes.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Screens/HomeScreen.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/profileWidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';

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
  runApp(ProviderScope(child: MaterialApp(home: Start())));
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
          return Material(
            key: startKey,
            child: SafeArea(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hotty",
                      style: GoogleFonts.roboto(
                          color: Colors.black, fontSize: 90.sp),
                    ),
                    if (authState == AuthState.signingIn) ...[
                      LoadingIndicator(
                        indicatorType: Indicator.ballPulse,
                        colors: [Colors.red, Colors.orange, Colors.green],
                      ),
                    ],
                    if (authState == AuthState.error) ...[],
                    if (authState == AuthState.succes) ...[
                      Text("Dentro"),
                    ],
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(Dependencies.userDataContainerProvider)
                              .signInWithGoogle();
                        },
                        child: const Text("Iniciar sesion"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
