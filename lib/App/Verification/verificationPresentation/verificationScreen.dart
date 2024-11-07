import 'verificationCameraScreen.dart';
import 'verificationPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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
        child: SafeArea(
            child: Container(
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              scrolledUnderElevation: 0,
              elevation: 0,
              title: Text("Verificar tu perfil",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.apply(color: Theme.of(context).colorScheme.onSurface)),
            ),
            body: Padding(
              padding: EdgeInsets.all(40.h),
              child: Consumer<VerificationPresentation>(
                builder: (BuildContext context,
                    VerificationPresentation verificationPresentation,
                    Widget? child) {
                  return Column(
                    children: [
                      Flexible(
                        flex: 8,
                        fit: FlexFit.tight,
                        child: Container(
                          child: verificationPresentation
                                      .getVerificationScreenState ==
                                  VerificationScreenState.LOADING
                              ? verificationLoadingStatePage()
                              : verificationPresentation
                                          .getVerificationScreenState ==
                                      VerificationScreenState.ERROR
                                  ? verificationErrorStatePage(
                                      verificationPresentation)
                                  : verificationPresentation
                                              .getVerificationScreenState ==
                                          VerificationScreenState.REVIEW_ERROR
                                      ? verificationFailedStatePage(
                                          verificationPresentation)
                                      : verificationPresentation
                                                  .getVerificationScreenState ==
                                              VerificationScreenState
                                                  .REVIEW_IN_PROCESS
                                          ? verificationInProcessStatePage(
                                              verificationPresentation)
                                          : verificationPresentation
                                                      .getVerificationScreenState ==
                                                  VerificationScreenState
                                                      .REVIEW_NOT_STARTED
                                              ? verificationNotStartedPageState(
                                                  verificationPresentation)
                                              : verificationSuccesfullStatePage(),
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Container(
                          child: Center(
                            child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Atras")),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
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

  Widget verificationNotStartedPageState(
      VerificationPresentation verificationPresentation) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: faceWidget(
                  isFemale: verificationPresentation.verificationController
                      .verificationTicketEntity!.isFemale),
            ),
            Divider(height: 50.h, color: Colors.transparent),
            Text(
              "Verifica que eres tu",
              style: Theme.of(context).textTheme.headlineSmall?.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeightDelta: 2),
            ),
            Divider(height: 50.h, color: Colors.transparent),
            Text(
              "Vamos a hacerte una foto en la que debe salir tu cara y tu mano realizando el gesto que te indicaremos",
              style: Theme.of(context).textTheme.bodyMedium?.apply(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            Divider(height: 50.h, color: Colors.transparent),
            verificationPresentation.getVerificationGestureLoadingState ==
                    VerificationGestureLoadingState.LOADED
                ? handGestureContainer(verificationPresentation)
                : verificationPresentation.getVerificationGestureLoadingState ==
                        VerificationGestureLoadingState.LOADING
                    ? Container(
                        child: Column(
                          children: [
                            Container(
                              height: 100.h,
                              width: 100.h,
                              child: LoadingIndicator(
                                indicatorType: Indicator.circleStrokeSpin,
                                colors: [Theme.of(context).colorScheme.primary],
                              ),
                            ),
                            Divider(
                              height: 50.h,
                              color: Colors.transparent,
                            ),
                            Text(
                              "Cargando",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.apply(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                            )
                          ],
                        ),
                      )
                    : verificationPresentation
                                .getVerificationGestureLoadingState ==
                            VerificationGestureLoadingState.ERROR
                        ? Column(
                            children: [
                              Text(
                                "Ha habido un error",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 4,
            fit: FlexFit.loose,
            child: Text(
              "Verificacion en proceso...",
              style: Theme.of(context).textTheme.headlineMedium?.apply(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeightDelta: 2),
            ),
          ),
          Flexible(
            flex: 8,
            fit: FlexFit.loose,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(40.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Tu perfil esta siendo verificado por nuestro equipo",
                      style: Theme.of(context).textTheme.bodyLarge?.apply(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    Text(
                      "Te enviaremos una notificacion cuando la revision haya terminado",
                      style: Theme.of(context).textTheme.bodyLarge?.apply(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    Text(
                      "Si la verificacion es favorable recibiras tu recompensa automaticamente",
                      style: Theme.of(context).textTheme.bodyLarge?.apply(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    Text(
                      "Si la verificacion no es favorable te pediremos que vuelvas a repetir el proceso",
                      style: Theme.of(context).textTheme.bodyLarge?.apply(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
                Text(
                  "Error",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.apply(color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
          Divider(
            height: 20.h,
            color: Colors.transparent,
          ),
          Text(
            "No hemos podido verificar tu perfil, asegurate de que se te ve claramente al verificar el perfil e intentalo de nuevo",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.apply(color: Theme.of(context).colorScheme.onSurface),
          ),
          Divider(
            height: 50.h,
            color: Colors.transparent,
          ),
          FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text("Atras"))
        ],
      ),
    );
  }

  Container verificationErrorStatePage(
      VerificationPresentation verificationPresentation) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
                Text(
                  "Error",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.apply(color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
            Divider(
              height: 20.h,
              color: Colors.transparent,
            ),
            Text(
              "Ha ocurrido un error cargando la pagina, intentelo de nuevo o pongase en contacto con soporte",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.apply(color: Theme.of(context).colorScheme.onSurface),
            ),
            Divider(
              height: 50.h,
              color: Colors.transparent,
            ),
            FilledButton.icon(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  verificationPresentation.clearModuleData();
                  verificationPresentation.initializeModuleData();
                },
                label: Text("Intentar de nuevo"))
          ],
        ),
      ),
    );
  }

  Container verificationLoadingStatePage() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Cargando",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.apply(color: Theme.of(context).colorScheme.onSurface),
            ),
            Divider(
              height: 50.h,
              color: Colors.transparent,
            ),
            Container(
              height: 100.h,
              width: 100.h,
              child: LoadingIndicator(
                indicatorType: Indicator.circleStrokeSpin,
                colors: [Theme.of(context).colorScheme.primary],
              ),
            )
          ],
        ),
      ),
    );
  }

  Column handGestureContainer(
      VerificationPresentation verificationPresentation) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          child: Text("Continuar")),
    ]);
  }

  Stack faceWidget({required bool isFemale}) {
    return Stack(
      children: [
        isFemale
            ? Container(
                height: 200.h,
                width: 200.h,
                child: SvgPicture.asset("assets/woman_face.svg"),
              )
            : Container(
                height: 200.h,
                width: 200.h,
                child: SvgPicture.asset("assets/man_face.svg"),
              ),
        Container(
          height: 200.h,
          width: 200.h,
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
