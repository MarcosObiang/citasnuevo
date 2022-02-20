import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/authScreenPresentation/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
   return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
  

    return ChangeNotifierProvider.value(
      value: Dependencies.authScreenPresentation,
      child: Consumer<AuthScreenPresentation>(
        builder: (BuildContext context,AuthScreenPresentation authScreenPresentation,Widget? child) {
          return Material(
            key: startKey,
            child: SafeArea(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hotty",
                      style: GoogleFonts.roboto(color: Colors.black, fontSize: 90.sp),
                    ),
                    if (authScreenPresentation.authState == AuthState.signingIn) ...[
                      LoadingIndicator(
                        indicatorType: Indicator.ballPulse,
                        colors: [Colors.red, Colors.orange, Colors.green],
                      ),
                    ],
                    if (authScreenPresentation.authState  == AuthState.error) ...[],
                    if (authScreenPresentation.authState  == AuthState.succes) ...[
                      Text("Dentro"),
                    ],
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          authScreenPresentation.signInWithGoogle();
                 
                        },
                        child: const Text("Iniciar sesion"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
    
  }
}
