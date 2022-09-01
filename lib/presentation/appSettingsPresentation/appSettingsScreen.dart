import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/domain/entities/ApplicationSettingsEntity.dart';
import 'package:citasnuevo/presentation/appSettingsPresentation/appSettingsPresentation.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:another_xlider/another_xlider.dart';

import '../../main.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen();

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> with RouteAware {

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
    Dependencies.appSettingsPresentation.updateSettings(
        ApplicationSettingsEntity(
            distance:  Dependencies.appSettingsPresentation.applicationSettingsEntity.distance.toInt(),
            maxAge:  Dependencies.appSettingsPresentation.applicationSettingsEntity.maxAge.toInt(),
            minAge:  Dependencies.appSettingsPresentation.applicationSettingsEntity.minAge.toInt(),
            inCm:  Dependencies.appSettingsPresentation.applicationSettingsEntity.inCm,
            inKm:  Dependencies.appSettingsPresentation.applicationSettingsEntity.inKm,
            showBothSexes: Dependencies. appSettingsPresentation.applicationSettingsEntity.showBothSexes,
            showWoman:  Dependencies.appSettingsPresentation.applicationSettingsEntity.showWoman,
            showProfile:  Dependencies.appSettingsPresentation.applicationSettingsEntity.showProfile));
    Dependencies.homeScreenPresentation.restart();
    super.didPop();
  }

  @override
  void initState() {
    super.initState();



  }

 

  @override
  Widget build(BuildContext context) {
    return Material(
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
                Container(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () async {
                            Dependencies.appSettingsPresentation.updateSettings(
                                ApplicationSettingsEntity(
                                    distance: appSettingsPresentation.applicationSettingsEntity.distance.toInt() ,
                                    maxAge:  appSettingsPresentation.applicationSettingsEntity.maxAge.toInt(),
                                    minAge: appSettingsPresentation.applicationSettingsEntity.minAge.toInt(),
                                    inCm: appSettingsPresentation.applicationSettingsEntity.inCm,
                                    inKm: appSettingsPresentation.applicationSettingsEntity.inKm,
                                    showBothSexes: appSettingsPresentation.applicationSettingsEntity.showBothSexes,
                                    showWoman: appSettingsPresentation.applicationSettingsEntity.showWoman,
                                    showProfile: appSettingsPresentation.applicationSettingsEntity.showProfile));

                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back)),
                      Text(
                        "Ajustes",
                        style: GoogleFonts.lato(fontSize: 65.sp),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: appSettingsPresentation.appSettingsScreenState ==
                            AppSettingsScreenState.loaded
                        ? ListView(
                            children: [
                              Container(
                                height: 300.h,
                                child: Row(
                                  children: [
                                    Column(
                                      children: [
                                        Text("Distancia"),
                                        Slider(
                                          divisions: 14,
                                          value: appSettingsPresentation.applicationSettingsEntity.distance.toDouble(),
                                          onChanged: (value) {
                                            appSettingsPresentation.applicationSettingsEntity.distance = value.toInt();
                                            setState(() {});
                                          },
                                          min: 10,
                                          max: 150,
                                        ),
                                      ],
                                    ),
                                    Text(appSettingsPresentation.applicationSettingsEntity.distance.toStringAsFixed(0)),
                                  ],
                                ),
                              ),
                              Container(
                                height: 300.h,
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 8,
                                      fit: FlexFit.tight,
                                      child: Container(
                                        height: 200.h,
                                        child: FlutterSlider(
                                          rangeSlider: true,
                                          values: [appSettingsPresentation.applicationSettingsEntity.minAge.toDouble(), appSettingsPresentation.applicationSettingsEntity.maxAge.toDouble()],
                                          max: 70,
                                          min: 18,
                                          onDragging:
                                              (index, minValue, maxValue) {
                                            appSettingsPresentation.applicationSettingsEntity.minAge = minValue.toInt();
                                            appSettingsPresentation.applicationSettingsEntity.maxAge = maxValue.toInt();
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 4,
                                      fit: FlexFit.tight,
                                      child: Container(
                                        child: Text(
                                            "${appSettingsPresentation.applicationSettingsEntity.minAge.toStringAsFixed(0)} - ${appSettingsPresentation.applicationSettingsEntity.maxAge.toStringAsFixed(0)}"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 100.h,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Altura en cm"),
                                    Switch.adaptive(
                                        value: appSettingsPresentation.applicationSettingsEntity.inCm,
                                        onChanged: (value) {
                                          appSettingsPresentation.applicationSettingsEntity.inCm = value;
                                          setState(() {});
                                        })
                                  ],
                                ),
                              ),
                              Container(
                                height: 100.h,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("distancia en Km"),
                                    Switch.adaptive(
                                        value: appSettingsPresentation.applicationSettingsEntity.inKm,
                                        onChanged: (value) {
                                          appSettingsPresentation.applicationSettingsEntity.inKm = value;
                                          setState(() {});
                                        })
                                  ],
                                ),
                              ),
                              Container(
                                height: 100.h,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Mostrar ambos sexos"),
                                    Switch.adaptive(
                                        value: appSettingsPresentation.applicationSettingsEntity.showBothSexes,
                                        onChanged: (value) {
                                          appSettingsPresentation.applicationSettingsEntity.showBothSexes = value;
                                          setState(() {});
                                        })
                                  ],
                                ),
                              ),
                              Container(
                                height: 100.h,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Mostrar mujeres"),
                                    Switch.adaptive(
                                        value: appSettingsPresentation.applicationSettingsEntity.showWoman,
                                        onChanged: (value) {
                                          appSettingsPresentation.applicationSettingsEntity.showWoman = value;
                                          setState(() {});
                                        })
                                  ],
                                ),
                              ),
                              Container(
                                height: 100.h,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Mostrar perfil"),
                                    Switch.adaptive(
                                        value: appSettingsPresentation.applicationSettingsEntity.showProfile,
                                        onChanged: (value) {
                                          appSettingsPresentation.applicationSettingsEntity.showProfile = value;
                                          setState(() {});
                                        })
                                  ],
                                ),
                              ),
                              Container(
                                  height: 100.h,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      appSettingsPresentation.logOut();
                                    },
                                    child: Text("Cerrar sesion"),
                                  )),
                              Container(
                                  height: 100.h,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      appSettingsPresentation.deleteAccount();
                                    },
                                    child: Text("Borrar cuenta"),
                                  )),
                            ],
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
    );
  }
}
