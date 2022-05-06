import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/domain/entities/ApplicationSettingsEntity.dart';
import 'package:citasnuevo/presentation/appSettingsPresentation/appSettingsPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:another_xlider/another_xlider.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen();

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late double distance;
  late double maxAge;
  late double minAge;
  late bool inCm;
  late bool inKm;
  late bool showBothSexes;
  late bool showWoman;
  late bool showProfile;
  late bool showProfilePoints;

  @override
  void initState() {
    super.initState();
    distance = Dependencies.appSettingsPresentation.appSettingsController
        .applicationSettingsEntity.distance
        .toDouble();
    maxAge = Dependencies.appSettingsPresentation.appSettingsController
        .applicationSettingsEntity.maxAge
        .toDouble();
    minAge = Dependencies.appSettingsPresentation.appSettingsController
        .applicationSettingsEntity.minAge
        .toDouble();
    inCm = Dependencies.appSettingsPresentation.appSettingsController
        .applicationSettingsEntity.inCm;
    inKm = Dependencies.appSettingsPresentation.appSettingsController
        .applicationSettingsEntity.inKm;
    showBothSexes = Dependencies.appSettingsPresentation.appSettingsController
        .applicationSettingsEntity.showBothSexes;
    showWoman = Dependencies.appSettingsPresentation.appSettingsController
        .applicationSettingsEntity.showWoman;
    showProfile = Dependencies.appSettingsPresentation.appSettingsController
        .applicationSettingsEntity.showProfile;
    showProfilePoints = Dependencies.appSettingsPresentation
        .appSettingsController.applicationSettingsEntity.showProfilePoints;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Dependencies.appSettingsPresentation.updateSettings(
            ApplicationSettingsEntity(
                distance: distance.toInt(),
                maxAge: maxAge.toInt(),
                minAge: minAge.toInt(),
                inCm: inCm,
                inKm: inKm,
                showBothSexes: showBothSexes,
                showWoman: showWoman,
                showProfilePoints: showProfilePoints,
                showProfile: showProfile));

        return true;
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
                  Container(
                    height: kToolbarHeight,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              Dependencies.appSettingsPresentation
                                  .updateSettings(ApplicationSettingsEntity(
                                      distance: distance.toInt(),
                                      maxAge: maxAge.toInt(),
                                      minAge: minAge.toInt(),
                                      inCm: inCm,
                                      inKm: inKm,
                                      showBothSexes: showBothSexes,
                                      showWoman: showWoman,
                                      showProfilePoints: showProfilePoints,
                                      showProfile: showProfile));

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
                                            value: distance,
                                            onChanged: (value) {
                                              distance = value;
                                              setState(() {});
                                            },
                                            min: 10,
                                            max: 150,
                                          ),
                                        ],
                                      ),
                                      Text(distance.toStringAsFixed(0)),
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
                                            values: [minAge, maxAge],
                                            max: 70,
                                            min: 18,
                                            onDragging:
                                                (index, minValue, maxValue) {
                                              minAge = minValue;
                                              maxAge = maxValue;
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
                                              "${minAge.toStringAsFixed(0)} - ${maxAge.toStringAsFixed(0)}"),
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
                                          value: inCm,
                                          onChanged: (value) {
                                            inCm = value;
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
                                          value: inKm,
                                          onChanged: (value) {
                                            inKm = value;
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
                                      Text("Mostrar ambos seos"),
                                      Switch.adaptive(
                                          value: showBothSexes,
                                          onChanged: (value) {
                                            showBothSexes = value;
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
                                          value: showWoman,
                                          onChanged: (value) {
                                            showWoman = value;
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
                                      Text("Mostrar nota perfil"),
                                      Switch.adaptive(
                                          value: showProfilePoints,
                                          onChanged: (value) {
                                            showProfilePoints = value;
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
                                          value: showProfile,
                                          onChanged: (value) {
                                            showProfile = value;
                                            setState(() {});
                                          })
                                    ],
                                  ),
                                ),
                                Container(
                                    height: 100.h,
                                    child: ElevatedButton(
                                      onPressed: () {
Dependencies.authScreenPresentation.signOut();                                      },
                                      child: Text("Cerrar sesion"),
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
      ),
    );
  }
}
