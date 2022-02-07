import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

class AuthScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final authState =
        ref.watch(Dependencies.userDataContainerProvider).authState;

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
    
  }
}
