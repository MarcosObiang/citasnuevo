import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../Utils/getImageFile.dart';
import '../../../Utils/routes.dart';
import '../../../core/dependencies/dependencyCreator.dart';
import '../../../core/iapPurchases/iapPurchases.dart';
import '../../ApplicationSettings/appSettingsPresentation/appSettingsScreen.dart';
import '../../PurchaseSystem/purchaseSystemPresentation/purchaseScreen.dart';
import '../../UserSettings/userSettingsPresentation/userSettingsScreen.dart';
import 'settingsScreenPresentation.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/SettingsScreen';
  Uint8List? imageData;
  final storage = Storage(Dependencies.serverAPi.client!);

  SettingsScreen();

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<Uint8List> remitentImageData;

  @override
  void initState() {
    super.initState();

    remitentImageData = ImageFile.getFile(
        fileId:
            Dependencies.settingsScreenPresentation.settingsEntity.userPicture);
  }

  @override
  void didChangeDependencies() {
    remitentImageData = ImageFile.getFile(
        fileId:
            Dependencies.settingsScreenPresentation.settingsEntity.userPicture);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    remitentImageData = ImageFile.getFile(
        fileId:
            Dependencies.settingsScreenPresentation.settingsEntity.userPicture);

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.settingsScreenPresentation,
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Consumer<SettingsScreenPresentation>(builder:
              (BuildContext context,
                  SettingsScreenPresentation settingsScreenPresentation,
                  Widget? child) {
            return Container(
              color: Colors.white,
              child: settingsScreenPresentation.settingsScreenState ==
                      SettingsScreenState.loaded
                  ? Column(children: [
                      Flexible(
                        flex: 5,
                        fit: FlexFit.tight,
                        child: FutureBuilder(
                            future: remitentImageData,
                            builder: (BuildContext context,
                                AsyncSnapshot<Uint8List> snapshot) {
                              remitentImageData = ImageFile.getFile(
                                  fileId: Dependencies
                                      .settingsScreenPresentation
                                      .settingsEntity
                                      .userPicture);
                              return Column(
                                children: [
                                  snapshot.hasData
                                      ? ClipOval(
                                          child: Image.memory(
                                            snapshot.data!,
                                            height: 150,
                                            width: 150,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        )
                                      : CircularProgressIndicator(),
                                  Text(
                                    settingsScreenPresentation
                                        .settingsEntity.userName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(settingsScreenPresentation
                                      .settingsEntity.userAge
                                      .toString()),
                                ],
                              );
                            }),
                      ),
                      Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                  label: Text("Ajustes"),
                                  onPressed: () {
                                    Navigator.push(context,
                                        GoToRoute(page: AppSettingsScreen()));
                                  },
                                  icon: Row(
                                    mainAxisAlignment:
                                        settingsScreenPresentation
                                                .getIsAppSettingsUpdating
                                            ? MainAxisAlignment.spaceAround
                                            : MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.settings),
                                      settingsScreenPresentation
                                              .getIsAppSettingsUpdating
                                          ? Container(
                                              height: 50.h,
                                              width: 50.h,
                                              child: LoadingIndicator(
                                                indicatorType: Indicator.orbit,
                                                colors: [Colors.white],
                                              ),
                                            )
                                          : Container()
                                    ],
                                  )),
                              TextButton.icon(
                                  label: Text("Editar perfil"),
                                  onPressed: () {
                                    Navigator.push(context,
                                        GoToRoute(page: UserSettingsScreen()));
                                  },
                                  icon: Row(
                                    mainAxisAlignment:
                                        settingsScreenPresentation
                                                .getIsUserSettingsUpdating
                                            ? MainAxisAlignment.spaceAround
                                            : MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.edit),
                                      settingsScreenPresentation
                                              .getIsUserSettingsUpdating
                                          ? Container(
                                              height: 50.h,
                                              width: 50.h,
                                              child: LoadingIndicator(
                                                indicatorType: Indicator.orbit,
                                                colors: [Colors.white],
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ))
                            ],
                          )),
                      Flexible(
                        flex: 9,
                        fit: FlexFit.tight,
                        child: subscriptionDescriptionCard(
                            context, settingsScreenPresentation),
                      )
                    ])
                  : settingsScreenPresentation.settingsScreenState ==
                          SettingsScreenState.error
                      ? Container(
                          color: Colors.red,
                          child: Center(
                            child: ElevatedButton.icon(
                                onPressed: () =>
                                    settingsScreenPresentation.restart(),
                                icon: Icon(Icons.refresh),
                                label: Text("Intentar de nuevo")),
                          ))
                      : Container(
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Cargando"),
                              Container(
                                height: 300.h,
                                width: 300.h,
                                child: LoadingIndicator(
                                    indicatorType:
                                        Indicator.ballSpinFadeLoader),
                              )
                            ],
                          ),
                        ),
            );
          }),
        ),
      ),
    );
  }

  Card subscriptionDescriptionCard(BuildContext context,
      SettingsScreenPresentation settingsScreenPresentation) {
    return Card(
      color: Colors.deepPurple,
      child: Padding(
        padding: EdgeInsets.all(30.h),
        child: settingsScreenPresentation.settingsEntity.isUserPremium == false
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Hotty Plus",
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 90.sp),
                        ),
                        Text(
                          "-Monedas Infinitas",
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 60.sp),
                        ),
                        Text(
                          "Revela reacciones sin parar, tú pones el límite",
                          style: GoogleFonts.lato(color: Colors.white),
                        ),
                        Text(
                          "-Sin anuncios",
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 60.sp),
                        ),
                        Text(
                          "Disfruta de una experiencia mas fluida sin anuncios",
                          style: GoogleFonts.lato(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context, GoToRoute(page: SubscriptionsMenu()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Desde solo"),
                          Text(settingsScreenPresentation
                              .settingsEntity.subscriptionPrice),
                        ],
                      ))
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Hotty Plus",
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 90.sp),
                        ),
                        Divider(
                          height: 50.h,
                          color: Colors.transparent,
                        ),
                        Text(
                          "Gracias por usar Hotty+",
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 60.sp),
                        ),
                        Divider(
                          height: 50.h,
                          color: Colors.transparent,
                        ),
                        Text(
                          "Puedes gestionar tu suscription pulsando 'Gestionar suscripción'",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context, GoToRoute(page: SubscriptionsMenu()));
                      },
                      child: Text("Gestionar suscripción"))
                ],
              ),
      ),
    );
  }
}
