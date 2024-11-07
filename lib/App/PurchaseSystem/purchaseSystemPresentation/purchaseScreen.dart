import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../purchaseEntity.dart';
import 'purchaseSystemPresentation.dart';

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
      value: Dependencies.purchaseSystemPresentation,
      child: Consumer<PurchaseSystemPresentation>(builder:
          (BuildContext context,
              PurchaseSystemPresentation purchaseSystemPresentation,
              Widget? child) {
        return Material(
          color: Colors.white,
          child: SafeArea(
            child: Container(
              child: Stack(
                children: [
                  Column(
                    children: [
                      AppBar(
                        elevation: 0,
                        title: Text(AppLocalizations.of(context)!.purchase_screen_subscriptions),
                      ),
                      purchaseSystemPresentation.purchaseSystemScreenState ==
                              PurchaseSystemScreenState.LOADED
                          ? Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(20.h),
                                child: Column(
                                  children: [
                                    Flexible(
                                      fit: FlexFit.tight,
                                      flex: 3,
                                      child: subscriptionStatusCard(
                                          purchaseSystemPresentation),
                                    ),
                                    Flexible(
                                      fit: FlexFit.loose,
                                      flex: 4,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          subscriptionButton(
                                            purchaseSystemPresentation:
                                                purchaseSystemPresentation,
                                            productInfo:
                                                purchaseSystemPresentation
                                                    .purchaseSystemController
                                                    .purchaseEntity
                                                    .offeringsList[0],
                                          ),
                                          subscriptionButton(
                                            purchaseSystemPresentation:
                                                purchaseSystemPresentation,
                                            productInfo:
                                                purchaseSystemPresentation
                                                    .purchaseSystemController
                                                    .purchaseEntity
                                                    .offeringsList[1],
                                          ),
                                          subscriptionButton(
                                            purchaseSystemPresentation:
                                                purchaseSystemPresentation,
                                            productInfo:
                                                purchaseSystemPresentation
                                                    .purchaseSystemController
                                                    .purchaseEntity
                                                    .offeringsList[2],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                        fit: FlexFit.loose,
                                        flex: 3,
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                child: ElevatedButton.icon(
                                                    onPressed: () {
                                                      showSubscriptionSettings(
                                                          context: context,
                                                          purchaseSystemPresentation:
                                                              purchaseSystemPresentation);
                                                    },
                                                    icon: Icon(Icons.settings),
                                                    label: Text(AppLocalizations.of(context)!
                                                        .purchase_screen_subscription_settings)),
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .purchase_screen_subscription_settings_description,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.lato(
                                                    fontSize: 35.sp),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            )
                          : purchaseSystemPresentation
                                      .purchaseSystemScreenState ==
                                  PurchaseSystemScreenState.LOADING
                              ? Center(
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        LoadingIndicator(
                                          indicatorType: Indicator.ballRotate,
                                          colors: [Colors.deepPurpleAccent],
                                        ),
                                        Text(AppLocalizations.of(context)!.purchase_screen_loading)
                                      ],
                                    ),
                                  ))
                              : Center(
                                  child: Container(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(AppLocalizations.of(context)!.purchase_screen_error_loading_module),
                                          ElevatedButton.icon(
                                              onPressed: () {
                                                purchaseSystemPresentation
                                                    .restart();
                                              },
                                              icon: Icon(Icons.refresh),
                                              label: Text(AppLocalizations.of(context)!.purchase_screen_try_again))
                                        ]),
                                  ),
                                ),
                    ],
                  ),
                  purchaseSystemPresentation.getPurchaseOperationState ==
                          PurchaseOperationState.WAITING
                      ? Container(
                          color: Color.fromARGB(184, 6, 6, 6),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.purchase_screen_please_wait,
                                  style: GoogleFonts.lato(
                                      color: Colors.white, fontSize: 50.sp),
                                ),
                                Container(
                                    height: 200.h,
                                    width: 200.h,
                                    child: LoadingIndicator(
                                        indicatorType: Indicator.orbit))
                              ],
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void showSubscriptionSettings(
      {required BuildContext context,
      required PurchaseSystemPresentation purchaseSystemPresentation}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Column(children: [
              Text(
                AppLocalizations.of(context)!.purchase_screen_subscription_settings_title,
                style: GoogleFonts.lato(fontSize: 70.sp),
              ),
              Container(
                child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      purchaseSystemPresentation.openSubscriptionMenu();
                    },
                    icon: Icon(Icons.settings),
                    label: Text(AppLocalizations.of(context)!.purchase_screen_google_play_settings)),
              ),
              Container(
                child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      purchaseSystemPresentation.restorePurchases();
                    },
                    icon: Icon(Icons.restore),
                    label: Text(AppLocalizations.of(context)!.purchase_screen_restore_purchase)),
              ),
            ]),
          );
        });
  }

  Container subscriptionStatusCard(
      PurchaseSystemPresentation purchaseSystemPresentation) {
    return Container(
        width: ScreenUtil().screenWidth,
        decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10,
                  spreadRadius: 10,
                  blurStyle: BlurStyle.outer)
            ]),
        child: purchaseSystemPresentation.purchaseSystemController
                    .purchaseEntity.subscriptionStatus !=
                SubscriptionStaus.NOT_SUBCRIBED
            ? Container(
                child: purchaseSystemPresentation.purchaseSystemController
                            .purchaseEntity.subscriptionStatus ==
                        SubscriptionStaus.SUBSCRIBED
                    ? subscriptionActiveText(purchaseSystemPresentation)
                    : purchaseSystemPresentation.purchaseSystemController
                                .purchaseEntity.subscriptionStatus ==
                            SubscriptionStaus.CANCELLED
                        ? subscriptionCancelledText(purchaseSystemPresentation)
                        : Container())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.purchase_screen_hotty_plus,
                    style: GoogleFonts.lato(
                        letterSpacing: 20.w,
                        fontSize: 80.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    height: 100.h,
                    color: Colors.transparent,
                  ),
                  Text(
                    AppLocalizations.of(context)!.purchase_screen_no_ads,
                    style: GoogleFonts.lato(
                        fontSize: 60.sp, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    height: 50.h,
                    color: Colors.transparent,
                  ),
                  Text(
                    AppLocalizations.of(context)!.purchase_screen_infinite_coins,
                    style: GoogleFonts.lato(
                        fontSize: 60.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ));
  }

  Column subscriptionCancelledText(
      PurchaseSystemPresentation purchaseSystemPresentation) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.purchase_screen_subscription_cancelled,
          style: GoogleFonts.lato(fontSize: 70.sp, fontWeight: FontWeight.bold),
        ),
        Divider(
          height: 20.h,
          color: Colors.transparent,
        ),
        Text(
          "${purchaseSystemPresentation.purchaseSystemController.purchaseEntity.activeSubscription?.productName}",
          style: GoogleFonts.lato(fontSize: 70.sp, fontWeight: FontWeight.bold),
        ),
        Divider(
          height: 30.h,
          color: Colors.transparent,
        ),
        Text(
          AppLocalizations.of(context)!.purchase_screen_subscription_expires_on,
          style: GoogleFonts.lato(fontSize: 50.sp, fontWeight: FontWeight.bold),
        ),
        Text(
            "${format.format(DateTime.fromMillisecondsSinceEpoch(purchaseSystemPresentation.purchaseSystemController.purchaseEntity.subscriptionExpirationTimestamp))}"),
        ElevatedButton(onPressed: () {}, child: Text(AppLocalizations.of(context)!.purchase_screen_subscribe_again))
      ],
    );
  }

  Column subscriptionActiveText(
      PurchaseSystemPresentation purchaseSystemPresentation) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.purchase_screen_active_subscription,
          style: GoogleFonts.lato(fontSize: 70.sp, fontWeight: FontWeight.bold),
        ),
        Divider(
          height: 50.h,
          color: Colors.transparent,
        ),
        Text(
          "${purchaseSystemPresentation.purchaseSystemController.purchaseEntity.activeSubscription?.productName}",
          style: GoogleFonts.lato(fontSize: 70.sp, fontWeight: FontWeight.bold),
        ),
        Divider(
          height: 50.h,
          color: Colors.transparent,
        ),
        Text(
          AppLocalizations.of(context)!.purchase_screen_next_payment,
          style: GoogleFonts.lato(fontSize: 70.sp, fontWeight: FontWeight.bold),
        ),
        Text(
            "${format.format(DateTime.fromMillisecondsSinceEpoch(purchaseSystemPresentation.purchaseSystemController.purchaseEntity.subscriptionExpirationTimestamp))}"),
      ],
    );
  }

  Padding subscriptionButton(
      {required PurchaseSystemPresentation purchaseSystemPresentation,
      required ProductInfo productInfo}) {
    var format = DateFormat("EEEEE, M/d/y HH:mm");
    late Color buttonColor;
    late double elevation;
    buttonColor = Colors.blue;
    elevation = 5;
    if (purchaseSystemPresentation
            .purchaseSystemController.purchaseEntity.activeSubscription !=
        null) {
      if (purchaseSystemPresentation.purchaseSystemController.purchaseEntity
              .activeSubscription!.productId ==
          productInfo.productId) {
        buttonColor = Colors.grey;
        elevation = 0;
      } else {
        buttonColor = Colors.blue;
        elevation = 5;
      }
    }

    return Padding(
      padding: EdgeInsets.only(top: 30.h, bottom: 30.h),
      child: Stack(
        children: [
          ElevatedButton(
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all(elevation),
                  backgroundColor: MaterialStateProperty.all(buttonColor)),
              onPressed: () async {
                if (productInfo.productId !=
                    purchaseSystemPresentation.purchaseSystemController
                        .purchaseEntity.activeSubscription?.productId) {
                  Dependencies.purchaseSystemPresentation
                      .makePurchase(offerId: productInfo.productId);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(productInfo.productName),
                  Text(productInfo.productPriceString),
                  productInfo.productId ==
                              purchaseSystemPresentation
                                  .purchaseSystemController
                                  .purchaseEntity
                                  .activeSubscription
                                  ?.productId &&
                          purchaseSystemPresentation.purchaseSystemController
                                  .purchaseEntity.subscriptionStatus ==
                              SubscriptionStaus.SUBSCRIBED
                      ? Text(AppLocalizations.of(context)!.purchase_screen_active)
                      : Text(""),
                  productInfo.productId ==
                              purchaseSystemPresentation
                                  .purchaseSystemController
                                  .purchaseEntity
                                  .activeSubscription
                                  ?.productId &&
                          purchaseSystemPresentation.purchaseSystemController
                                  .purchaseEntity.subscriptionStatus ==
                              SubscriptionStaus.CANCELLED
                      ? Text(AppLocalizations.of(context)!.purchase_screen_cancelled)
                      : Text(""),
                ],
              )),
        ],
      ),
    );
  }
}
