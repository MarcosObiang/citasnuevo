import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/iapPurchases/iapPurchases.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/presentation/appSettingsPresentation/appSettingsScreen.dart';
import 'package:citasnuevo/presentation/settingsPresentation/settingsScreenPresentation.dart';
import 'package:citasnuevo/presentation/userSettingsPresentation/userSettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../Routes.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/SettingsScreen';
  Uint8List? imageData;
  final storage = Storage(Dependencies.serverAPi.client!);

  SettingsScreen();

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.imageData == null) {
      _getImageData();
    }
  }

  void _getImageData() async {
    try {
      widget.imageData = await widget.storage.getFileDownload(
        bucketId: '63712fd65399f32a5414',
        fileId:
            Dependencies.settingsScreenPresentation.settingsEntity.userPicture,
      );
      setState(() {});
    } catch (e) {
      if (e is AppwriteException) {
      } else {}
    }
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
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Container(
                          child: Row(
                            children: [
                              Flexible(
                                flex: 4,
                                fit: FlexFit.tight,
                                child: Container(
                                    child: widget.imageData != null
                                        ? Image.memory(
                                            widget.imageData!,
                                          )
                                        : CircularProgressIndicator()),
                              ),
                              Flexible(
                                  flex: 7,
                                  fit: FlexFit.tight,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        settingsScreenPresentation
                                            .settingsEntity.userName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(settingsScreenPresentation
                                          .settingsEntity.userAge
                                          .toString()),
                                      Container(
                                        width: 500.w,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  GoToRoute(
                                                      page:
                                                          AppSettingsScreen()));
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  settingsScreenPresentation
                                                          .getIsAppSettingsUpdating
                                                      ? MainAxisAlignment
                                                          .spaceAround
                                                      : MainAxisAlignment
                                                          .center,
                                              children: [
                                                Text("Ajustes"),
                                                settingsScreenPresentation
                                                        .getIsAppSettingsUpdating
                                                    ? Container(
                                                        height: 50.h,
                                                        width: 50.h,
                                                        child: LoadingIndicator(
                                                          indicatorType:
                                                              Indicator.orbit,
                                                          colors: [
                                                            Colors.white
                                                          ],
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            )),
                                      ),
                                      Container(
                                        width: 500.w,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  GoToRoute(
                                                      page:
                                                          UserSettingsScreen()));
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  settingsScreenPresentation
                                                          .getIsUserSettingsUpdating
                                                      ? MainAxisAlignment
                                                          .spaceAround
                                                      : MainAxisAlignment
                                                          .center,
                                              children: [
                                                Text("Editar perfil"),
                                                settingsScreenPresentation
                                                        .getIsUserSettingsUpdating
                                                    ? Container(
                                                        height: 50.h,
                                                        width: 50.h,
                                                        child: LoadingIndicator(
                                                          indicatorType:
                                                              Indicator.orbit,
                                                          colors: [
                                                            Colors.white
                                                          ],
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            )),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 8,
                        fit: FlexFit.tight,
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(50.h),
                            child: Container(
                              width: ScreenUtil().screenWidth,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey, blurRadius: 10.h)
                                  ],
                                  border: Border.all(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Column(
                                children: [
                                  Flexible(
                                    flex: 5,
                                    fit: FlexFit.tight,
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              "Hotty Plus",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 90.sp),
                                            ),
                                            Text(
                                              "-Monedas Infinitas",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 60.sp),
                                            ),
                                            Text(
                                              "Revela reacciones sin parar, tú pones el límite",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              "-Sin anuncios",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 60.sp),
                                            ),
                                            Text(
                                              "Disfruta de una experiencia mas fluida sin anuncios",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                      flex: 5,
                                      fit: FlexFit.tight,
                                      child: Container(
                                          child: Column(
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    GoToRoute(
                                                        page:
                                                            SubscriptionsMenu()));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text("Desde solo"),
                                                  Text(
                                                      settingsScreenPresentation
                                                          .settingsEntity
                                                          .weekSubscription
                                                          .productPrice),
                                                ],
                                              )),
                                        ],
                                      )))
                                ],
                              ),
                            ),
                          ),
                        ),
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
}

class SubscriptionsMenu extends StatefulWidget {
  const SubscriptionsMenu({Key? key}) : super(key: key);

  @override
  State<SubscriptionsMenu> createState() => _SubscriptionsMenuState();
}

class _SubscriptionsMenuState extends State<SubscriptionsMenu> {
  var format = DateFormat("EEEEE, M/d/y HH:mm");

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.settingsScreenPresentation,
      child: Consumer<SettingsScreenPresentation>(builder:
          (BuildContext context,
              SettingsScreenPresentation settingsScreenPresentation,
              Widget? child) {
        return SafeArea(
          child: Material(
            child: Container(
              child: Column(
                children: [
                  AppBar(
                    elevation: 0,
                    title: Text("Suscripciones"),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(50.h),
                      child: Column(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 6,
                            child: Container(
                                width: ScreenUtil().screenWidth,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 10,
                                          spreadRadius: 10,
                                          blurStyle: BlurStyle.outer)
                                    ]),
                                child: settingsScreenPresentation.settingsEntity
                                            .activeSubscription !=
                                        null
                                    ? Container(
                                        child: settingsScreenPresentation
                                                    .settingsEntity
                                                    .activeSubscription!
                                                    .subscriptionState ==
                                                SubscriptionState.ACTIVE
                                            ? subscriptionActiveText(
                                                settingsScreenPresentation)
                                            : settingsScreenPresentation
                                                        .settingsEntity
                                                        .activeSubscription!
                                                        .subscriptionState ==
                                                    SubscriptionState.CANCELED
                                                ? subscriptionCancelledText(
                                                    settingsScreenPresentation)
                                                : Container())
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "HOTTY +",
                                            style: GoogleFonts.lato(
                                                fontSize: 70.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Divider(
                                            height: 50.h,
                                            color: Colors.transparent,
                                          ),
                                          Text(
                                            "-Olvidate de los anuncios",
                                            style: GoogleFonts.lato(
                                                fontSize: 70.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Divider(
                                            height: 50.h,
                                            color: Colors.transparent,
                                          ),
                                          Text(
                                            "-Disfruta de una experiencia inmediata y sin anuncios",
                                            style: GoogleFonts.lato(
                                                fontSize: 50.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Divider(
                                            height: 50.h,
                                            color: Colors.transparent,
                                          ),
                                          Text(
                                            "-Revela reacciones sin limites",
                                            style: GoogleFonts.lato(
                                                fontSize: 70.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Divider(
                                            height: 50.h,
                                            color: Colors.transparent,
                                          ),
                                          Text(
                                            "-Monedas infinitas para no quedarte con las ganas",
                                            style: GoogleFonts.lato(
                                                fontSize: 50.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            flex: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                subscriptionButton(
                                  productInfo: settingsScreenPresentation
                                      .settingsEntity.productInfoList[0],
                                ),
                                subscriptionButton(
                                  productInfo: settingsScreenPresentation
                                      .settingsEntity.productInfoList[1],
                                ),
                                subscriptionButton(
                                  productInfo: settingsScreenPresentation
                                      .settingsEntity.productInfoList[2],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Column subscriptionCancelledText(
      SettingsScreenPresentation settingsScreenPresentation) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Suscripcion Cancelada:",
          style: GoogleFonts.lato(fontSize: 70.sp, fontWeight: FontWeight.bold),
        ),
        Divider(
          height: 50.h,
          color: Colors.transparent,
        ),
        Text(
          "${settingsScreenPresentation.settingsEntity.activeSubscription!.productName}",
          style: GoogleFonts.lato(fontSize: 70.sp, fontWeight: FontWeight.bold),
        ),
        Divider(
          height: 50.h,
          color: Colors.transparent,
        ),
        Text(
          "Tu suscripcion caduca el:",
          style: GoogleFonts.lato(fontSize: 50.sp, fontWeight: FontWeight.bold),
        ),
        Text(
            "${format.format(DateTime.fromMillisecondsSinceEpoch(settingsScreenPresentation.settingsEntity.activeSubscription!.subscriptionExpireTime))}"),
        ElevatedButton(
            onPressed: () {
              settingsScreenPresentation.purchase(
                  settingsScreenPresentation
                      .settingsEntity.activeSubscription!.offerId,
                  true);
            },
            child: Text("Volver a suscribirme"))
      ],
    );
  }

  Column subscriptionActiveText(
      SettingsScreenPresentation settingsScreenPresentation) {
    return Column(
      children: [
        Text(
          "Suscripcion Activa:",
          style: GoogleFonts.lato(fontSize: 70.sp, fontWeight: FontWeight.bold),
        ),
        Divider(
          height: 50.h,
          color: Colors.transparent,
        ),
        Text(
          "${settingsScreenPresentation.settingsEntity.activeSubscription!.productName}",
          style: GoogleFonts.lato(fontSize: 70.sp, fontWeight: FontWeight.bold),
        ),
        Divider(
          height: 50.h,
          color: Colors.transparent,
        ),
        Text(
          "Proximo Pago:",
          style: GoogleFonts.lato(fontSize: 70.sp, fontWeight: FontWeight.bold),
        ),
        Text(
            "${format.format(DateTime.fromMillisecondsSinceEpoch(settingsScreenPresentation.settingsEntity.activeSubscription!.subscriptionExpireTime))}"),
      ],
    );
  }

  Padding subscriptionButton({required ProductInfo productInfo}) {
    var format = DateFormat("EEEEE, M/d/y HH:mm");
    late Color buttonColor;
    late double elevation;
    if (productInfo.productIsActive) {
      buttonColor = Colors.grey;
      elevation = 0;
    } else {
      buttonColor = Colors.blue;
      elevation = 10;
    }
    return Padding(
      padding: EdgeInsets.only(top: 30.h, bottom: 30.h),
      child: Container(
        width: 900.w,
        child: Column(
          children: [
            ElevatedButton(
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(elevation),
                    backgroundColor: MaterialStateProperty.all(buttonColor)),
                onPressed: () async {
                  Dependencies.settingsScreenPresentation
                      .purchase(productInfo.offerId, false);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(productInfo.offerId),
                    Text(productInfo.productPrice)
                  ],
                )),
            productInfo.subscriptionState == SubscriptionState.ACTIVE
                ? Text("Suscripcion activa")
                : Container(),
            productInfo.subscriptionState == SubscriptionState.CANCELED
                ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color.fromARGB(255, 252, 138, 138)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Su suscripcion ha sido cancelada",
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold, fontSize: 50.sp),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
