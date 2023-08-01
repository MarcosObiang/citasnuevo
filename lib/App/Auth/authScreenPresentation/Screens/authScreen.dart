import 'dart:ui';

import 'package:citasnuevo/App/controllerDef.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../../core/params_types/params_and_types.dart';
import '../../../../main.dart';
import '../authPresentation.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> implements RouteAware {
  @override
  void initState() {
    if (startKey.currentContext != null) {
      routeObserver.subscribe(this,
          ModalRoute.of(startKey.currentContext as BuildContext) as PageRoute);
    }

    super.initState();
  }

  @override
  void didPop() {
    print("didPop");
  }

  @override
  void didPopNext() {
    Dependencies.authScreenPresentation.restart();
    print("didPopNext");
  }

  @override
  void didPush() {
    checkIfUserIsSignedIn();
    print("didPush");
  }

  @override
  void didPushNext() {
    print("didPushNext");
  }

  void checkIfUserIsSignedIn() {
    if (startKey.currentContext != null) {
      Dependencies.authScreenPresentation.checkSignedInUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.authScreenPresentation,
      child: Consumer<AuthScreenPresentation>(builder: (BuildContext context,
          AuthScreenPresentation authScreenPresentation, Widget? child) {
        return Material(
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Colors.red,
                Colors.deepOrange,
                Colors.orange,
                Colors.green
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Hotty",
                    style: GoogleFonts.lato(
                        color: Colors.black,
                        fontSize: 90.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  if (authScreenPresentation.authState ==
                      AuthState.signingIn) ...[
                    Container(
                      height: 600.h,
                      width: 600.h,
                      child: LoadingIndicator(
                        indicatorType: Indicator.lineSpinFadeLoader,
                        colors: [Colors.red, Colors.orange, Colors.green],
                      ),
                    ),
                  ],
                  if (authScreenPresentation.authState == AuthState.error)
                    ...[],
                  if (authScreenPresentation.authState == AuthState.succes) ...[
                    Text("Dentro"),
                  ],
                  Column(
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(LineAwesomeIcons.facebook),
                        onPressed: () async {
                          authScreenPresentation.signIn(
                              signInProviders: SignInProviders.facebook);
                        },
                        label: const Text("Iniciar sesion con Facebook"),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(LineAwesomeIcons.google_logo),
                        onPressed: () async {
                          authScreenPresentation.signIn(
                              signInProviders: SignInProviders.google);
                        },
                        label: const Text("Iniciar sesion con Google"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
