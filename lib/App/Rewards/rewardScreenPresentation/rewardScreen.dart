import 'package:citasnuevo/App/PurchaseSystem/purchaseSystemPresentation/purchaseScreen.dart';
import 'package:citasnuevo/App/Settings/settingsPresentation/SettingsScreen.dart';
import 'package:citasnuevo/App/Verification/verificationPresentation/verificationScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../Utils/routes.dart';
import 'dailyRewardWidget.dart';
import 'firstRewardWidget.dart';
import 'promotionalRewardWidget.dart';
import 'rewardScreenPresentation.dart';
import 'shareCodeRewardWidget.dart';
import 'sharedLinkRewardWidget.dart';

class RewardScreen extends StatefulWidget {
  static const routeName = '/RewardScreen';

  const RewardScreen();

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  DateFormat dateFormat = DateFormat("HH:mm:ss");
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: ChangeNotifierProvider.value(
          value: Dependencies.rewardScreenPresentation,
          child: Consumer<RewardScreenPresentation>(builder:
              (BuildContext context,
                  RewardScreenPresentation rewardScreenPresentation,
                  Widget? child) {
            return Column(
              children: [
                rewardScreenPresentation.getRewardScreenState ==
                        RewardScreenState.done
                    ? Expanded(
                        child: rewardScreenPresentation
                                    .rewardController.isPremium ==
                                false
                            ? Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Container(
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          premiumCard(context,
                                              rewardScreenPresentation),
                                          Flexible(
                                            flex: 9,
                                            fit: FlexFit.tight,
                                            child: ListView(
                                              children: [
                                                rewardScreenPresentation.rewards
                                                            .waitingFirstReward ==
                                                        true
                                                    ? RepaintBoundary(
                                                        child: FirstRewardWidget(
                                                            rewardScreenPresentation:
                                                                rewardScreenPresentation),
                                                      )
                                                    : Container(),
                                                rewardScreenPresentation.rewards
                                                            .promotionalCodePendingOfUse ==
                                                        true
                                                    ? RepaintBoundary(
                                                        child: PromotionalRewardWidget(
                                                            rewardScreenPresentation:
                                                                rewardScreenPresentation),
                                                      )
                                                    : Container(),
                                                rewardScreenPresentation.rewards
                                                            .rewardTicketSuccesfulShares >
                                                        0
                                                    ? RepaintBoundary(
                                                        child: SharedLinkRewardWidget(
                                                            rewardScreenPresentation:
                                                                rewardScreenPresentation),
                                                      )
                                                    : Container(),
                                                rewardScreenPresentation.rewards
                                                                .waitingFirstReward ==
                                                            false &&
                                                        rewardScreenPresentation
                                                                .rewards
                                                                .waitingReward ==
                                                            true
                                                    ? RepaintBoundary(
                                                        child: RewardCardWidget(
                                                            rewardScreenPresentation:
                                                                rewardScreenPresentation),
                                                      )
                                                    : Container(),
                                                RepaintBoundary(
                                                  child: ShareCodeRewardCard(
                                                      rewardScreenPresentation:
                                                          rewardScreenPresentation),
                                                ),
                                                verifyProfileAndWindWidget()
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  rewardScreenPresentation
                                              .getRewardedAdShowingState ==
                                          RewardedAdShowingState.adLoading
                                      ? Container(
                                          width: ScreenUtil().screenWidth,
                                          color:
                                              Color.fromARGB(217, 27, 22, 22),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Cargando anuncio",
                                                style: GoogleFonts.lato(
                                                    color: Colors.white,
                                                    fontSize: 65.sp),
                                              ),
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
                                      : rewardScreenPresentation
                                                  .getRewardedAdShowingState ==
                                              RewardedAdShowingState
                                                  .errorLoadingAd
                                          ? Container(
                                              width: ScreenUtil().screenWidth,
                                              color: Color.fromARGB(
                                                  217, 27, 22, 22),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Error al mostrar anuncio",
                                                    style: GoogleFonts.lato(
                                                        color: Colors.white,
                                                        fontSize: 75.sp),
                                                  ),
                                                  Text(
                                                    "No te preocupes, podras reclamar tu recompensa",
                                                    style: GoogleFonts.lato(
                                                        color: Colors.white,
                                                        fontSize: 65.sp),
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        rewardScreenPresentation
                                                                .setRewardedAdShowingstate =
                                                            RewardedAdShowingState
                                                                .adNotShowing;
                                                        rewardScreenPresentation
                                                            .askDailyReward(
                                                                showAd: false);
                                                      },
                                                      child: Text(
                                                          "Reclamar recompensa",
                                                          style:
                                                              GoogleFonts.lato(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      60.sp)))
                                                ],
                                              ),
                                            )
                                          : rewardScreenPresentation
                                                      .getRewardedAdShowingState ==
                                                  RewardedAdShowingState
                                                      .adIncomplete
                                              ? Container(
                                                  width:
                                                      ScreenUtil().screenWidth,
                                                  color: Color.fromARGB(
                                                      217, 27, 22, 22),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Anuncio incompleto",
                                                        style: GoogleFonts.lato(
                                                            color: Colors.white,
                                                            fontSize: 75.sp),
                                                      ),
                                                      Text(
                                                        "Debes completar el anuncio para obtener tu recompensa",
                                                        style: GoogleFonts.lato(
                                                            color: Colors.white,
                                                            fontSize: 55.sp),
                                                      ),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            rewardScreenPresentation
                                                                    .setRewardedAdShowingstate =
                                                                RewardedAdShowingState
                                                                    .adNotShowing;
                                                          },
                                                          child: Text(
                                                              "Entendido",
                                                              style: GoogleFonts.lato(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      60.sp)))
                                                    ],
                                                  ),
                                                )
                                              : Container(),
                                ],
                              )
                            : Center(
                                child: Text("Eres premium"),
                              ),
                      )
                    : rewardScreenPresentation.getRewardScreenState ==
                            RewardScreenState.loading
                        ? Container(
                            child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Cargando"),
                                Divider(
                                  height: 100.h,
                                  color: Colors.transparent,
                                ),
                                Container(
                                  height: 200.h,
                                  width: 200.h,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.ballPulse,
                                  ),
                                )
                              ],
                            ),
                          ))
                        : Container(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Error de carga"),
                              Divider(
                                height: 100.h,
                                color: Colors.transparent,
                              ),
                              ElevatedButton.icon(
                                  onPressed: () {
                                    rewardScreenPresentation.restart();
                                  },
                                  icon: Icon(Icons.refresh),
                                  label: Text("Cargar de nuevo"))
                            ],
                          ))
              ],
            );
          }),
        ),
      ),
    );
  }

  Flexible premiumCard(
      BuildContext context, RewardScreenPresentation rewardScreenPresentation) {
    return Flexible(
      flex: 4,
      fit: FlexFit.tight,
      child: Container(
        width: ScreenUtil.defaultSize.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          color: Colors.deepPurple,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Hotty+',
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 60.sp,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Consigue monedas infinitas',
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 50.sp,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Experiecia sin anuncios',
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 50.sp,
                    fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context, GoToRoute(page: SubscriptionsMenu()));
                  },
                  child: Text(
                    'Desde ${rewardScreenPresentation.premiumPrice}',
                    style: GoogleFonts.roboto(
                        color: Colors.deepPurple, fontSize: 45.sp),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Container verifyProfileAndWindWidget() {
    return Container(
      height: 500.h,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Verifica tu perfil y gana",
                style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 70.sp)),
            Text("Gana 2000 monedas por verificar tu perfil",
                style: GoogleFonts.roboto(color: Colors.black)),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context, GoToRoute(page: VerificationScreen()));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: EdgeInsets.all(40.h),
                    child: Text(
                      'Verificar',
                      style: GoogleFonts.roboto(
                          color: Colors.black, fontSize: 50.sp),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Stack sharedLinkrewardCard(
      RewardScreenPresentation rewardScreenPresentation) {
    return Stack(
      children: [
        Container(
          height: 700.h,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Recompensa promocional",
                    style: GoogleFonts.roboto(
                        color: Colors.black, fontSize: 70.sp)),
                Text("Tu codigo de invitacion ha sido usado correctamente",
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                    )),
                Text(
                    "Tu recompensa: 2000 creditos * ${rewardScreenPresentation.rewardController.rewards?.rewardTicketSuccesfulShares} = ${rewardScreenPresentation.rewardController.rewards!.rewardTicketSuccesfulShares * 2000} ",
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                    )),
                TextButton(
                    onPressed: () {
                      rewardScreenPresentation.rewardTicketSuccesfultShares();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Padding(
                        padding: EdgeInsets.all(40.h),
                        child: Text(
                          'Reclamar bono',
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 50.sp),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        rewardScreenPresentation.getRewardTicketSuccessfulShareState ==
                RewardTicketSuccesfulSharesState.inProcess
            ? Container(
                height: 500.h,
                width: ScreenUtil().screenWidth,
                color: Color.fromARGB(228, 100, 24, 135),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Cargando",
                      style: GoogleFonts.roboto(color: Colors.white),
                    ),
                    Center(
                        child: Container(
                      height: 200.h,
                      width: 300.h,
                      child:
                          LoadingIndicator(indicatorType: Indicator.ballPulse),
                    ))
                  ],
                ),
              )
            : Container()
      ],
    );
  }

  Stack promotionalRewardCard(
      RewardScreenPresentation rewardScreenPresentation) {
    return Stack(
      children: [
        Container(
          height: 500.h,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Recompensa promocional",
                    style: GoogleFonts.roboto(
                        color: Colors.black, fontSize: 70.sp)),
                Text(
                    "Has usado un codigo promocional y ahora te regalamos 5000 creditos gratis",
                    style: GoogleFonts.roboto(
                        color: Colors.black, fontSize: 50.sp)),
                TextButton(
                    onPressed: () {
                      rewardScreenPresentation.usePromotionalCode();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Padding(
                        padding: EdgeInsets.all(40.h),
                        child: Text(
                          'Reclamar bono',
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 50.sp),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        rewardScreenPresentation.getPromotionalCodeState ==
                PromotionalCodeState.inProcess
            ? Container(
                height: 500.h,
                width: ScreenUtil().screenWidth,
                color: Color.fromARGB(228, 100, 24, 135),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Cargando",
                      style: GoogleFonts.roboto(color: Colors.white),
                    ),
                    Center(
                        child: Container(
                      height: 200.h,
                      width: 300.h,
                      child:
                          LoadingIndicator(indicatorType: Indicator.ballPulse),
                    ))
                  ],
                ),
              )
            : Container()
      ],
    );
  }

  Stack bonoBienvenida(RewardScreenPresentation rewardScreenPresentation) {
    return Stack(
      children: [
        Container(
          height: 500.h,
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Bono de bienvenida",
                    style: GoogleFonts.roboto(
                        color: Colors.black, fontSize: 70.sp)),
                Text(
                    "Hotty te regala 30000 creditos para que conozcas y disfrutes.",
                    style: GoogleFonts.roboto(
                        color: Colors.black, fontSize: 50.sp)),
                TextButton(
                    onPressed: () {
                      rewardScreenPresentation.askFirstReward();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Padding(
                        padding: EdgeInsets.all(40.h),
                        child: Text(
                          'Reclamar bono',
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 50.sp),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        rewardScreenPresentation.getFirstRewards == FirstRewards.inProcess
            ? Container(
                height: 500.h,
                width: ScreenUtil().screenWidth,
                color: Color.fromARGB(228, 100, 24, 135),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Cargando",
                      style: GoogleFonts.roboto(color: Colors.white),
                    ),
                    Center(
                        child: Container(
                      height: 200.h,
                      width: 300.h,
                      child:
                          LoadingIndicator(indicatorType: Indicator.ballPulse),
                    ))
                  ],
                ),
              )
            : Container()
      ],
    );
  }

  List<Widget> rewardWidgets = [
    Card(child:
        StreamBuilder(builder: (BuildContext context, AsyncSnapshot<int> data) {
      return Container(
          height: 600.h,
          color: Colors.red,
          child: Padding(
            padding: EdgeInsets.all(50.h),
            child: Column(
              children: [
                Text(
                  'Recompensa diaria',
                  style:
                      GoogleFonts.roboto(color: Colors.black, fontSize: 70.sp),
                ),
                Divider(
                  color: Colors.transparent,
                  height: 100.h,
                ),
                Text(
                  '¿Monedas insuficientes?, no te preocupes porque en 24 horas te reponemos hasta 600 monedas',
                  style:
                      GoogleFonts.roboto(color: Colors.black, fontSize: 50.sp),
                ),
              ],
            ),
          ));
    }))
  ];

  Widget rewardCard(int timeUntilReward) {
    return Card(
      child: Container(
        height: 600.h,
        color: Colors.red,
      ),
    );
  }
}
