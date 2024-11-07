import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../Utils/getImageFile.dart';
import '../../../Utils/routes.dart';
import '../../../core/dependencies/dependencyCreator.dart';
import '../../ApplicationSettings/appSettingsPresentation/appSettingsScreen.dart';
import '../../PurchaseSystem/purchaseSystemPresentation/purchaseScreen.dart';
import '../../UserSettings/userSettingsPresentation/userSettingsScreen.dart';
import 'settingsScreenPresentation.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/SettingsScreen';
  Uint8List? imageData;

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
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Consumer<SettingsScreenPresentation>(builder:
              (BuildContext context,
                  SettingsScreenPresentation settingsScreenPresentation,
                  Widget? child) {
            return Container(
        color: Theme.of(context).colorScheme.surface,
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
                                  label: Text(AppLocalizations.of(context)!.settings_title),
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
                                  label: Text(AppLocalizations.of(context)!.settings_editProfile),
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
                                label: Text(AppLocalizations.of(context)!
                                    .try_again)),
                          ))
                      : Container(
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!.loading),
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
                          AppLocalizations.of(context)!.settings_hottyPlus,
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 90.sp),
                        ),
                        Text(
                          AppLocalizations.of(context)!.settings_hottyPlus_infiniteCoins,
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 60.sp),
                        ),
                        Text(
                          AppLocalizations.of(context)!.settings_hottyPlus_infiniteCoinsDescription,
                          style: GoogleFonts.lato(color: Colors.white),
                        ),
                        Text(
                          AppLocalizations.of(context)!.settings_hottyPlus_noAds,
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 60.sp),
                        ),
                        Text(
                          AppLocalizations.of(context)!.settings_hottyPlus_noAdsDescription,
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
                          Text(AppLocalizations.of(context)!.settings_hottyPlus_from),
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
                          AppLocalizations.of(context)!.settings_hottyPlus,
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 90.sp),
                        ),
                        Divider(
                          height: 50.h,
                          color: Colors.transparent,
                        ),
                        Text(
                          AppLocalizations.of(context)!.settings_hottyPlus_thanksForUsing,
                          style: GoogleFonts.lato(
                              color: Colors.white, fontSize: 60.sp),
                        ),
                        Divider(
                          height: 50.h,
                          color: Colors.transparent,
                        ),
                        Text(
                          AppLocalizations.of(context)!.settings_hottyPlus_manageSubscription,
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
                      child: Text(AppLocalizations.of(context)!.settings_hottyPlus_manageSubscriptionButton))
                ],
              ),
      ),
    );
  }
}
