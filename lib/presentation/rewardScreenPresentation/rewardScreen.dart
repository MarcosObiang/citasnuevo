import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/presentation/rewardScreenPresentation/rewardScreenPresentation.dart';
import 'package:citasnuevo/presentation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../settingsPresentation/SettingsScreen.dart';

class RewardScreen extends StatefulWidget {
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
                AppBar(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Gemas"),
                      Row(
                        children: [
                          Text("${rewardScreenPresentation.coins}"),
                          Icon(LineAwesomeIcons.gem)
                        ],
                      ),
                    ],
                  ),
                ),
                rewardScreenPresentation.getRewardScreenState ==
                        RewardScreenState.done
                    ? Container(
                        height: ScreenUtil.defaultSize.height,
                        color: Colors.white,
                        child: CustomScrollView(
                          slivers: [
                            SliverAppBar(
                              centerTitle: true,
                              backgroundColor: Colors.transparent,
                              expandedHeight: 700.h,
                              stretch: false,
                              elevation: 20,
                              automaticallyImplyLeading: false,
                              actions: [],
                              flexibleSpace: Card(
                                color: Colors.orange,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Hotty Premium',
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 70.sp),
                                    ),
                                    Text(
                                      'Consigue Monedas infinitas',
                                      style: GoogleFonts.roboto(
                                          color: Colors.black, fontSize: 50.sp),
                                    ),
                                    Text(
                                      'Olvidate de los anuncios',
                                      style: GoogleFonts.roboto(
                                          color: Colors.white, fontSize: 50.sp),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              GoToRoute(
                                                  page: SubscriptionScreen()));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.deepPurpleAccent,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30))),
                                          child: Padding(
                                            padding: EdgeInsets.all(40.h),
                                            child: Text(
                                              'Desde ${rewardScreenPresentation.premiumPrice}',
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 50.sp),
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              floating: true,
                              pinned: true,
                              collapsedHeight: 600.h,
                            ),
                            SliverList(
                              delegate: SliverChildListDelegate([
                                rewardScreenPresentation
                                            .rewards.waitingFirstReward ==
                                        true
                                    ? bonoBienvenida(rewardScreenPresentation)
                                    : Container(),
                                dailyReward(rewardScreenPresentation),
                                facebookShare(),
                                inviteFriendWidget(),
                                verifyProfileAndWindWidget()
                              ]),
                            ),
                          ],
                        ))
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
                style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 50.sp)),
            TextButton(
                onPressed: () {},
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

  Container inviteFriendWidget() {
    return Container(
      height: 500.h,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Invita a tu amigo y gana",
                style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 70.sp)),
            Text(
                "Invita a un amigo y gana 3000 monedas cuando se registre en Hotty",
                style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 50.sp)),
            TextButton(
                onPressed: () {},
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: EdgeInsets.all(40.h),
                    child: Text(
                      'Invitar',
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

  Container facebookShare() {
    return Container(
      height: 500.h,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Comparte en Facebook y gana",
                style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 70.sp)),
            Text(
                "Comparte un post de Hotty en tu perfil de facebook y gana 200 monedas",
                style:
                    GoogleFonts.roboto(color: Colors.black, fontSize: 50.sp)),
            TextButton(
                onPressed: () {},
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: EdgeInsets.all(40.h),
                    child: Text(
                      'Compartir',
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

  Stack dailyReward(RewardScreenPresentation rewardScreenPresentation) {
    return Stack(
      children: [
        StreamBuilder(
            initialData: rewardScreenPresentation
                .rewardController.secondsUntilDailyReward,
            stream:
                rewardScreenPresentation.dailyRewardTieRemainingStream.stream,
            builder: (BuildContext context, AsyncSnapshot<int> data) {
              return Stack(
                children: [
                  Container(
                      height: 600.h,
                      child: Padding(
                        padding: EdgeInsets.all(50.h),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Text('Recompensa diaria',
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontSize: 70.sp)),
                                  ],
                                ),
                                Text(
                                  'Cuando tengas menos de 200 creditos, en 24 horas te reponemos hasta los 600 creditos',
                                  style: GoogleFonts.roboto(
                                      color: Colors.black, fontSize: 50.sp),
                                ),
                                rewardScreenPresentation.rewardController
                                            .secondsUntilDailyReward !=
                                        0
                                    ? Text(
                                        dateFormat.format(DateTime(
                                            0, 0, 0, 0, 0, (data.data ?? 0))),
                                        style: GoogleFonts.roboto(
                                            color: Colors.black,
                                            fontSize: 50.sp),
                                      )
                                    : TextButton(
                                        onPressed: () {
                                          if (rewardScreenPresentation
                                                      .rewards.coins <
                                                  200 &&
                                              data.data! <= 0) {
                                            rewardScreenPresentation
                                                .askDailyReward();
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: rewardScreenPresentation
                                                              .rewards.coins >=
                                                          200 &&
                                                      data.data == 0
                                                  ? Color.fromARGB(
                                                      138, 158, 158, 158)
                                                  : Colors.deepPurple,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30))),
                                          child: Padding(
                                            padding: EdgeInsets.all(40.h),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  'Reclamar recompensa',
                                                  style: GoogleFonts.roboto(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                Icon(LineAwesomeIcons.film)
                                              ],
                                            ),
                                          ),
                                        )),
                              ],
                            ),
                          ],
                        ),
                      )),
                  rewardScreenPresentation.getDayliRewardState ==
                          DailyRewardState.inProcess
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
                                child: LoadingIndicator(
                                    indicatorType: Indicator.ballPulse),
                              ))
                            ],
                          ),
                        )
                      : Container()
                ],
              );
            }),
        rewardScreenPresentation.rewards.waitingFirstReward
            ? Container(
                height: 500.h,
                width: ScreenUtil().screenWidth,
                color: Color.fromARGB(182, 0, 0, 0),
                child: Center(
                    child: Text("Primero debes usar el Bono de bienvenida",
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: 60.sp))),
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
