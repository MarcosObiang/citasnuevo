import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../main.dart';
import '../ApplicationSettingsEntity.dart';
import 'appSettingsPresentation.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen();

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> with RouteAware {
  bool logOutOrDeleteUser = false;
  @override
  void didChangeDependencies() {
    print("Change dependencies!!!!");
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPush() {
    // Route was pushed onto navigator and is now topmost route.
    print("Did Push!");
  }

  @override
  void didPopNext() {
    print("Did Pop Next");
  }

  @override
  void didPushNext() {
    print("Did Push Next");

    super.didPushNext();
  }

  @override
  void didPop() {
    super.didPop();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exit = true;

        if (Dependencies.appSettingsPresentation.appSettingsScreenState ==
                AppSettingsScreenState.loaded &&
            logOutOrDeleteUser == false) {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("¿Guardar cambios?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Dependencies.appSettingsPresentation.updateSettings(
                              ApplicationSettingsEntity(
                                  distance: Dependencies.appSettingsPresentation
                                      .applicationSettingsEntity.distance
                                      .toInt(),
                                  maxAge: Dependencies.appSettingsPresentation.applicationSettingsEntity.maxAge
                                      .toInt(),
                                  minAge: Dependencies.appSettingsPresentation
                                      .applicationSettingsEntity.minAge
                                      .toInt(),
                                  inCm: Dependencies.appSettingsPresentation
                                      .applicationSettingsEntity.inCm,
                                  inKm: Dependencies.appSettingsPresentation
                                      .applicationSettingsEntity.inKm,
                                  showBothSexes: Dependencies
                                      .appSettingsPresentation
                                      .applicationSettingsEntity
                                      .showBothSexes,
                                  showWoman: Dependencies
                                      .appSettingsPresentation
                                      .applicationSettingsEntity
                                      .showWoman,
                                  showProfile: Dependencies
                                      .appSettingsPresentation
                                      .applicationSettingsEntity
                                      .showProfile),
                              false);
                          Navigator.pop(context);
                        },
                        child: Text("No",
                            style: GoogleFonts.lato(color: Colors.black))),
                    ElevatedButton(
                        onPressed: () {
                          Dependencies.appSettingsPresentation.updateSettings(
                              ApplicationSettingsEntity(
                                  distance: Dependencies.appSettingsPresentation
                                      .applicationSettingsEntity.distance
                                      .toInt(),
                                  maxAge: Dependencies.appSettingsPresentation.applicationSettingsEntity.maxAge
                                      .toInt(),
                                  minAge: Dependencies.appSettingsPresentation
                                      .applicationSettingsEntity.minAge
                                      .toInt(),
                                  inCm: Dependencies.appSettingsPresentation
                                      .applicationSettingsEntity.inCm,
                                  inKm: Dependencies.appSettingsPresentation
                                      .applicationSettingsEntity.inKm,
                                  showBothSexes: Dependencies
                                      .appSettingsPresentation
                                      .applicationSettingsEntity
                                      .showBothSexes,
                                  showWoman: Dependencies
                                      .appSettingsPresentation
                                      .applicationSettingsEntity
                                      .showWoman,
                                  showProfile: Dependencies
                                      .appSettingsPresentation
                                      .applicationSettingsEntity
                                      .showProfile),
                              true);
                          Navigator.pop(context);
                        },
                        child: Text("Si")),
                  ],
                );
              });
        }
        Dependencies.homeScreenPresentation.restart();

        return exit;
      },
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: ChangeNotifierProvider.value(
            value: Dependencies.appSettingsPresentation,
            child: Consumer<AppSettingsPresentation>(builder:
                (BuildContext context,
                    AppSettingsPresentation appSettingsPresentation,
                    Widget? child) {
              return Column(
                children: [
                  AppBar(
                    title: Text(
                      "Ajustes",
                      style: GoogleFonts.lato(fontSize: 65.sp),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: appSettingsPresentation.appSettingsScreenState ==
                              AppSettingsScreenState.loaded
                          ? Padding(
                              padding: EdgeInsets.all(20.h),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: Padding(
                                  padding: EdgeInsets.all(20.h),
                                  child: ListView(
                                    children: [
                                      Divider(
                                          height: 50.h,
                                          color: Colors.transparent),
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text("Ajustes de busqueda"),
                                            Icon(LineAwesomeIcons.search)
                                          ],
                                        ),
                                      ),
                                      Divider(
                                          height: 50.h,
                                          color: Colors.transparent),
                                      Center(
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Distancia de busqueda"),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      flex: 9,
                                                      fit: FlexFit.tight,
                                                      child: Container(
                                                        child: Slider(
                                                          divisions: 14,
                                                          value: appSettingsPresentation
                                                              .applicationSettingsEntity
                                                              .distance
                                                              .toDouble(),
                                                          onChanged: (value) {
                                                            appSettingsPresentation
                                                                    .applicationSettingsEntity
                                                                    .distance =
                                                                value.toInt();
                                                            setState(() {});
                                                          },
                                                          min: 10,
                                                          max: 150,
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      flex: 2,
                                                      fit: FlexFit.loose,
                                                      child: Text(
                                                          appSettingsPresentation
                                                              .applicationSettingsEntity
                                                              .distance
                                                              .toStringAsFixed(
                                                                  0)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Rango de edad"),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    flex: 9,
                                                    fit: FlexFit.tight,
                                                    child: Container(
                                                      child: FlutterSlider(
                                                        touchSize: 50.w,
                                                        rangeSlider: true,
                                                        values: [
                                                          appSettingsPresentation
                                                              .applicationSettingsEntity
                                                              .minAge
                                                              .toDouble(),
                                                          appSettingsPresentation
                                                              .applicationSettingsEntity
                                                              .maxAge
                                                              .toDouble()
                                                        ],
                                                        max: 70,
                                                        min: 18,
                                                        onDragging: (index,
                                                            minValue,
                                                            maxValue) {
                                                          appSettingsPresentation
                                                                  .applicationSettingsEntity
                                                                  .minAge =
                                                              minValue.toInt();
                                                          appSettingsPresentation
                                                                  .applicationSettingsEntity
                                                                  .maxAge =
                                                              maxValue.toInt();
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 2,
                                                    fit: FlexFit.tight,
                                                    child: Container(
                                                      child: Text(
                                                          "${appSettingsPresentation.applicationSettingsEntity.minAge.toStringAsFixed(0)} - ${appSettingsPresentation.applicationSettingsEntity.maxAge.toStringAsFixed(0)}"),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Mostrar ambos sexos"),
                                              Switch.adaptive(
                                                  value: appSettingsPresentation
                                                      .applicationSettingsEntity
                                                      .showBothSexes,
                                                  onChanged: (value) {
                                                    appSettingsPresentation
                                                        .applicationSettingsEntity
                                                        .showBothSexes = value;
                                                    setState(() {});
                                                  })
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Mostrar mujeres"),
                                              Switch.adaptive(
                                                  value: appSettingsPresentation
                                                      .applicationSettingsEntity
                                                      .showWoman,
                                                  onChanged: (value) {
                                                    appSettingsPresentation
                                                        .applicationSettingsEntity
                                                        .showWoman = value;
                                                    setState(() {});
                                                  })
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Mostrar perfil"),
                                              Switch.adaptive(
                                                  value: appSettingsPresentation
                                                      .applicationSettingsEntity
                                                      .showProfile,
                                                  onChanged: (value) {
                                                    appSettingsPresentation
                                                        .applicationSettingsEntity
                                                        .showProfile = value;
                                                    setState(() {});
                                                  })
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Mostrar distancia en Km"),
                                              Switch.adaptive(
                                                  value: appSettingsPresentation
                                                      .applicationSettingsEntity
                                                      .inKm,
                                                  onChanged: (value) {
                                                    appSettingsPresentation
                                                        .applicationSettingsEntity
                                                        .inKm = value;
                                                    setState(() {});
                                                  })
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(
                                          height: 50.h,
                                          color: Colors.transparent),
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text("Ajustes de sesion"),
                                            Icon(Icons.key)
                                          ],
                                        ),
                                      ),
                                      Divider(
                                          height: 50.h,
                                          color: Colors.transparent),
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.logout),
                                        onPressed: () {
                                          logOutOrDeleteUser = true;

                                          appSettingsPresentation.logOut();
                                        },
                                        label: Text("Cerrar sesion"),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          logOutOrDeleteUser = true;
                                          appSettingsPresentation
                                              .deleteAccount();
                                        },
                                        label: Text("Borrar cuenta"),
                                        icon: Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : appSettingsPresentation.appSettingsScreenState ==
                                  AppSettingsScreenState.loading
                              ? Container(
                                  height: 300.h,
                                  child: LoadingIndicator(
                                      indicatorType: Indicator.ballGridPulse))
                              : Column(
                                  children: [
                                    Text("Error"),
                                    ElevatedButton.icon(
                                        onPressed: () =>
                                            appSettingsPresentation.restart(),
                                        icon: Icon(Icons.refresh),
                                        label: Text("Restart"))
                                  ],
                                ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
