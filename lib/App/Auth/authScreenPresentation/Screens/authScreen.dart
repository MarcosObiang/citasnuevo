import 'package:citasnuevo/App/controllerDef.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../../core/params_types/params_and_types.dart';
import '../../../../main.dart';
import '../authPresentation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Hotty",
                    style: Theme.of(context).textTheme.displayLarge?.apply(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeightDelta: 2),
                  ),
                  authScreenPresentation.authState == AuthState.signingIn
                      ? Container(
                          height: 100.h,
                          width: 100.h,
                          child: LoadingIndicator(
                            indicatorType: Indicator.circleStrokeSpin,
                          ),
                        )
                      : Column(
                          children: [
                            SignInButton(
                              Buttons.facebookNew,
                              text: AppLocalizations.of(context)!.auth_log_in_with_facebook,
                              onPressed: () async {
                                authScreenPresentation.signIn(
                                    signInProviders: SignInProviders.facebook);
                              },
                            ),
                            SignInButton(
                              Buttons.googleDark,
                              text: AppLocalizations.of(context)!.auth_log_in_with_google,
                              onPressed: () async {
                                authScreenPresentation.signIn(
                                    signInProviders: SignInProviders.google);
                              },
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
