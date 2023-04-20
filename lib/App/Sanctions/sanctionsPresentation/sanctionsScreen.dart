import 'package:citasnuevo/App/Sanctions/SanctionsEntity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../main.dart';
import 'sanctionsPresentation.dart';

class SanctionsScreen extends StatefulWidget {
  static const routeName = '/SanctionsScreen';

  const SanctionsScreen();

  @override
  State<SanctionsScreen> createState() => _SanctionsScreenState();
}

class _SanctionsScreenState extends State<SanctionsScreen> {
  var endOfSanctionFormatter = DateFormat.yMEd();
  var sanctionTimeRemainingDays = DateFormat.d();
  var sanctionTimeRemainingHours = DateFormat.H();
  var sanctionTimeRemainingMinutes = DateFormat.m();
  var sanctionTimeRemainingSeconds = DateFormat.s();
  var testing = DateFormat.d().add_Hms();

  DateTime time = DateTime.fromMillisecondsSinceEpoch(Dependencies
      .sanctionsPresentation
      .sanctionsController
      .sanctionsEntity
      ?.sanctionTimeStamp as int);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      key: sanctionKey,
      value: Dependencies.sanctionsPresentation,
      child: Consumer<SanctionsPresentation>(builder: (BuildContext context,
          SanctionsPresentation sanctionsPresentation, Widget? child) {
        return Material(
          child: WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: SafeArea(
                child: Container(
                    child: sanctionsPresentation.getSanctionScreenMode ==
                            SanctionScreenMode.waitingModeration
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Estamos revisando su perfil",
                                  style: GoogleFonts.lato(
                                      color: Colors.black,
                                      fontSize: 70.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Divider(
                                  color: Colors.transparent,
                                  height: 60.h,
                                ),
                                Text(
                                  "Hemos recibido varias denuncias sobre ti. \nPor precaución tu perfil será bloqueado mientras esta siendo revisado por nuestros moderadores.\nEste proceso puede durar hasta 48 horas, disculpa las molestias",
                                  style: GoogleFonts.lato(
                                      color: Colors.black, fontSize: 60.sp),
                                ),
                                TextButton(
                                    onPressed: () {
                                      sanctionsPresentation.logOut();
                                    },
                                    child: Text("Cerrar sesion"))
                              ],
                            ),
                          )
                        : sanctionsPresentation.getSanctionScreenMode ==
                                SanctionScreenMode.sanctioned
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Perfil bloqueado",
                                      style: GoogleFonts.lato(
                                          color: Colors.black,
                                          fontSize: 70.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Divider(
                                      color: Colors.transparent,
                                      height: 60.h,
                                    ),
                                    Text(
                                      "Tu perfil ha sido bloqueado 30 dias por incumplir las normas de nuestra comunidad",
                                      style: GoogleFonts.lato(
                                          color: Colors.black, fontSize: 60.sp),
                                    ),
                                    Divider(
                                        height: 100.h,
                                        color: Colors.transparent),
                                    Text(
                                      "Perfil bloqueado hasta:",
                                      style: GoogleFonts.lato(
                                          color: Colors.black, fontSize: 60.sp),
                                    ),
                                    Text(
                                      endOfSanctionFormatter.format(time),
                                      style: GoogleFonts.lato(
                                          color: Colors.black, fontSize: 60.sp),
                                    ),
                                    Divider(
                                        height: 100.h,
                                        color: Colors.transparent),
                                    sanctionCounter(sanctionsPresentation),
                                    TextButton(
                                        onPressed: () {
                                          sanctionsPresentation.logOut();
                                        },
                                        child: Text("Cerrar sesion")),
                                  ],
                                ),
                              )
                            : sanctionsPresentation.getSanctionScreenMode ==
                                    SanctionScreenMode.sanctionEnded
                                ? Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Ya puedes desbloquear tu perfil",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 70.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Divider(
                                              color: Colors.transparent,
                                              height: 60.h,
                                            ),
                                            Text(
                                              "Revisa tu perfil y asegurate de que cumple con nuestras reglas lo antes posible para evitar otra sancion o el bloqueo permanente y la eliminacion de tu cuenta",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 60.sp),
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  sanctionsPresentation
                                                      .logOut();
                                                },
                                                child: Text("Cerrar sesion")),
                                            ElevatedButton(
                                                onPressed: () {
                                                  sanctionsPresentation
                                                      .unlockProfile();
                                                },
                                                child:
                                                    Text("Desbloquear perfil"))
                                          ],
                                        ),
                                      ),
                                      sanctionsPresentation
                                                  .getUnlockProcessState ==
                                              UnlockProcessState.inProcess
                                          ? Container(
                                              height: ScreenUtil().screenHeight,
                                              width: ScreenUtil().screenWidth,
                                              color:
                                                  Color.fromARGB(184, 0, 0, 0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text("Espere",
                                                      style: GoogleFonts.lato(
                                                          color: Colors.white,
                                                          fontSize: 60.sp)),
                                                  Container(
                                                    height: 200.h,
                                                    width: 200.h,
                                                    child: LoadingIndicator(
                                                        indicatorType:
                                                            Indicator.orbit),
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container()
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Ya puedes desbloquear tu perfil",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 70.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Divider(
                                              color: Colors.transparent,
                                              height: 60.h,
                                            ),
                                            Text(
                                              "Hemos revisado tu perfil y todo parece estar en orden, sentimos las molestias",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 60.sp),
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  sanctionsPresentation
                                                      .logOut();
                                                },
                                                child: Text("Cerrar sesion")),
                                            ElevatedButton(
                                                onPressed: () {
                                                  sanctionsPresentation
                                                      .unlockProfile();
                                                },
                                                child:
                                                    Text("Desbloquear perfil"))
                                          ],
                                        ),
                                      ),
                                      sanctionsPresentation
                                                  .getUnlockProcessState ==
                                              UnlockProcessState.inProcess
                                          ? Container(
                                              height: ScreenUtil().screenHeight,
                                              width: ScreenUtil().screenWidth,
                                              color:
                                                  Color.fromARGB(184, 0, 0, 0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text("Espere",
                                                      style: GoogleFonts.lato(
                                                          color: Colors.white,
                                                          fontSize: 60.sp)),
                                                  Container(
                                                    height: 200.h,
                                                    width: 200.h,
                                                    child: LoadingIndicator(
                                                        indicatorType:
                                                            Indicator.orbit),
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ))),
          ),
        );
      }),
    );
  }

  StreamBuilder<int> sanctionCounter(
      SanctionsPresentation sanctionsPresentation) {
    return StreamBuilder(
        initialData: sanctionsPresentation
            .sanctionsController.sanctionsEntity!.timeRemaining,
        stream: sanctionsPresentation.sanctionsController.sanctionsEntity
            ?.sanctionStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.data != null) {
            if (snapshot.data! <= 0) {
              if (sanctionsPresentation
                      .sanctionsController.sanctionsEntity!.penalizationState ==
                  PenalizationState.PENALIZED) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  sanctionsPresentation.setSanctionScreenMode =
                      SanctionScreenMode.sanctionEnded;
                });
              }
            }
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              snapshot.data! > 86400000
                  ? Column(
                      children: [
                        Text(
                          sanctionTimeRemainingDays.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  snapshot.data as int,
                                  isUtc: true)),
                          style: GoogleFonts.lato(
                              color: Colors.black, fontSize: 60.sp),
                        ),
                        Text(
                          " Dias ",
                          style: GoogleFonts.lato(
                              color: Colors.black, fontSize: 60.sp),
                        )
                      ],
                    )
                  : Container(),
              snapshot.data! > 3600000
                  ? Column(
                      children: [
                        Text(
                          sanctionTimeRemainingHours.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  snapshot.data as int,
                                  isUtc: true)),
                          style: GoogleFonts.lato(
                              color: Colors.black, fontSize: 60.sp),
                        ),
                        Text(
                          " Horas ",
                          style: GoogleFonts.lato(
                              color: Colors.black, fontSize: 60.sp),
                        )
                      ],
                    )
                  : Container(),
              snapshot.data! > 60000
                  ? Column(
                      children: [
                        Text(
                          sanctionTimeRemainingMinutes.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  snapshot.data as int,
                                  isUtc: true)),
                          style: GoogleFonts.lato(
                              color: Colors.black, fontSize: 60.sp),
                        ),
                        Text(
                          " Minutos ",
                          style: GoogleFonts.lato(
                              color: Colors.black, fontSize: 60.sp),
                        )
                      ],
                    )
                  : Container(),
              snapshot.data! > 1000
                  ? Column(
                      children: [
                        Text(
                          sanctionTimeRemainingSeconds.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  snapshot.data as int,
                                  isUtc: true)),
                          style: GoogleFonts.lato(
                              color: Colors.black, fontSize: 60.sp),
                        ),
                        Text(
                          " Segundos ",
                          style: GoogleFonts.lato(
                              color: Colors.black, fontSize: 60.sp),
                        )
                      ],
                    )
                  : Container(),
            ],
          );
        });
  }
}
