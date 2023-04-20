import 'verificationCameraScreen.dart';
import 'verificationPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../main.dart';

class VerificationScreen extends StatefulWidget {
  static final String routeName = "/VerificationScreen";
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.verificationPresentation,
      child: Material(
        key: verificationScreenKey,
        color: Colors.white,
        child: SafeArea(child: Container(
          child: Consumer<VerificationPresentation>(
            builder: (BuildContext context,
                VerificationPresentation verificationPresentation,
                Widget? child) {
              return verificationPresentation.getVerificationScreenState ==
                      VerificationScreenState.LOADING
                  ? verificationLoadingStatePage()
                  : verificationPresentation.getVerificationScreenState ==
                          VerificationScreenState.ERROR
                      ? verificationErrorStatePage()
                      : verificationPresentation.getVerificationScreenState ==
                              VerificationScreenState.REVIEW_ERROR
                          ? verificationFailedStatePage(
                              verificationPresentation)
                          : verificationPresentation
                                      .getVerificationScreenState ==
                                  VerificationScreenState.REVIEW_IN_PROCESS
                              ? verificationInProcessStatePage(
                                  verificationPresentation)
                              : verificationPresentation
                                          .getVerificationScreenState ==
                                      VerificationScreenState.REVIEW_NOT_STARTED
                                  ? verificationNotStartedPageState(
                                      verificationPresentation)
                                  : verificationSuccesfullStatePage();
            },
          ),
        )),
      ),
    );
  }

  Container verificationSuccesfullStatePage() {
    return Container(
      child: Column(
        children: [Text("perfil verificado")],
      ),
    );
  }

  Container verificationNotStartedPageState(
      VerificationPresentation verificationPresentation) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Center(
                child: faceWidget(
                    isFemale: verificationPresentation.verificationController
                        .verificationTicketEntity!.isFemale),
              ),
            ),
            Text(
              "Verifica que eres tu",
              style: GoogleFonts.lato(
                  fontSize: 70.sp, fontWeight: FontWeight.bold),
            ),
            verificationPresentation.getVerificationGestureLoadingState ==
                    VerificationGestureLoadingState.LOADED
                ? handGestureContainer(verificationPresentation)
                : verificationPresentation.getVerificationGestureLoadingState ==
                        VerificationGestureLoadingState.LOADING
                    ? Container(
                        height: 300.h,
                        width: 300.h,
                        child: Column(
                          children: [
                            LoadingIndicator(indicatorType: Indicator.orbit),
                            Text("Cargando")
                          ],
                        ),
                      )
                    : verificationPresentation
                                .getVerificationGestureLoadingState ==
                            VerificationGestureLoadingState.ERROR
                        ? Column(
                            children: [
                              Text("Ha habido un error"),
                              ElevatedButton(
                                  onPressed: () {},
                                  child: Text("Intentar de nuevo"))
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () {
                              verificationPresentation
                                  .requestNewVerificationProcess();
                            },
                            child: Text("Empezar"))
          ],
        ),
      ),
    );
  }

  Container verificationInProcessStatePage(
      VerificationPresentation verificationPresentation) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: faceWidget(
                isFemale: verificationPresentation
                    .verificationController.verificationTicketEntity!.isFemale),
          ),
          Text("Verifivacion en proceso"),
          ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text("Atras"))
        ],
      ),
    );
  }

  Container verificationFailedStatePage(
      VerificationPresentation verificationPresentation) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: faceWidget(
                isFemale: verificationPresentation
                    .verificationController.verificationTicketEntity!.isFemale),
          ),
          Text("No se pudo verificar, intentalo de nuevo"),
          
          ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text("Atras"))
        ],
      ),
    );
  }

  Container verificationErrorStatePage() {
    return Container(
      child: Column(
        children: [Text("Error")],
      ),
    );
  }

  Container verificationLoadingStatePage() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Cargando"),
          Container(
            height: 200.h,
            width: 200.h,
            child: LoadingIndicator(indicatorType: Indicator.orbit),
          )
        ],
      ),
    );
  }

  Column handGestureContainer(
      VerificationPresentation verificationPresentation) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(
        children: [
          Divider(
            height: 100.h,
            color: Colors.transparent,
          ),
          Text(
            "-Solo tomará unos segundos",
            style: GoogleFonts.lato(
              fontSize: 60.sp,
            ),
          ),
          Divider(
            height: 100.h,
            color: Colors.transparent,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => CameraWidget(
                              gestureName:
                                  "assets/${verificationPresentation.verificationController.verificationTicketEntity!.handGesture}.svg",
                              faceFileName: "assets/woman_face.svg",
                            )));
              },
              child: Text("Continuar"))
        ],
      ),
    ]);
  }

  Stack faceWidget({required bool isFemale}) {
    return Stack(
      children: [
        isFemale
            ? Container(
                height: 300.h,
                width: 300.h,
                child: SvgPicture.asset("assets/woman_face.svg"),
              )
            : Container(
                height: 300.h,
                width: 300.h,
                child: SvgPicture.asset("assets/man_face.svg"),
              ),
        Container(
          height: 300.h,
          width: 300.h,
          child: Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Icon(
                LineAwesomeIcons.check_circle,
                color: Colors.blue,
              )),
        ),
      ],
    );
  }
}
