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
                      child:
                          rewardScreenPresentation.rewardController.isPremium ==
                                  false
                              ? Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    Container(
                                        child: Column(
                                      children: [
                                        premiumCard(
                                            context, rewardScreenPresentation),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Monedas gratis',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.apply(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface),
                                            ),
                                          ],
                                        ),
                                        Flexible(
                                          flex: 9,
                                          fit: FlexFit.tight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                              child: ListView(
                                                children: [
                                                  rewardScreenPresentation
                                                              .rewards
                                                              .waitingFirstReward ==
                                                          false
                                                      ? RepaintBoundary(
                                                          child: FirstRewardWidget(
                                                              rewardScreenPresentation:
                                                                  rewardScreenPresentation),
                                                        )
                                                      : Container(),
                                                  rewardScreenPresentation
                                                              .rewards
                                                              .promotionalCodePendingOfUse ==
                                                          false
                                                      ? RepaintBoundary(
                                                          child: PromotionalRewardWidget(
                                                              rewardScreenPresentation:
                                                                  rewardScreenPresentation),
                                                        )
                                                      : Container(),
                                                  rewardScreenPresentation
                                                              .rewards
                                                              .rewardTicketSuccesfulShares >
                                                          -1
                                                      ? RepaintBoundary(
                                                          child: SharedLinkRewardWidget(
                                                              rewardScreenPresentation:
                                                                  rewardScreenPresentation),
                                                        )
                                                      : Container(),
                                                  rewardScreenPresentation
                                                                  .rewards
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
                                          ),
                                        ),
                                      ],
                                    )),
                                    rewardScreenPresentation
                                                .getRewardedAdShowingState ==
                                            RewardedAdShowingState.adLoading
                                        ? adLoadingDialog()
                                        : rewardScreenPresentation
                                                    .getRewardedAdShowingState ==
                                                RewardedAdShowingState
                                                    .errorLoadingAd
                                            ? errorLoadingAdDialog(
                                                rewardScreenPresentation)
                                            : rewardScreenPresentation
                                                        .getRewardedAdShowingState ==
                                                    RewardedAdShowingState
                                                        .adIncomplete
                                                ? incompleteAdDialog(
                                                    rewardScreenPresentation)
                                                : Container(),
                                  ],
                                )
                              : Center(
                                  child: Text("Eres premium",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface)),
                                ),
                    )
                  : rewardScreenPresentation.getRewardScreenState ==
                          RewardScreenState.loading
                      ? Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                                child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Cargando",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.apply(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface)),
                                  Divider(
                                    height: 50.h,
                                    color: Colors.transparent,
                                  ),
                                  Container(
                                    height: 100.h,
                                    width: 100.h,
                                    child: LoadingIndicator(
                                      indicatorType: Indicator.circleStrokeSpin,
                                      colors: [
                                        Theme.of(context).colorScheme.primary
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )),
                          ),
                        )
                      : Expanded(
                          child: Container(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Error de carga",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              Divider(
                                height: 50.h,
                                color: Colors.transparent,
                              ),
                              FilledButton.icon(
                                  onPressed: () {
                                    rewardScreenPresentation.restart();
                                  },
                                  icon: Icon(Icons.refresh),
                                  label: Text("Cargar de nuevo"))
                            ],
                          )),
                        )
            ],
          );
        }),
      ),
    );
  }

  Container incompleteAdDialog(
      RewardScreenPresentation rewardScreenPresentation) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      width: ScreenUtil().screenWidth,
      child: Padding(
        padding: EdgeInsets.all(40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Anuncio incompleto",
              style: Theme.of(context).textTheme.headlineSmall?.apply(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
            Text(
              "Debes completar el anuncio para obtener tu recompensa",
              style: Theme.of(context).textTheme.bodyLarge?.apply(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
            ElevatedButton(
                onPressed: () {
                  rewardScreenPresentation.setRewardedAdShowingstate =
                      RewardedAdShowingState.adNotShowing;
                },
                child: Text(
                  "Entendido",
                ))
          ],
        ),
      ),
    );
  }

  Container errorLoadingAdDialog(
      RewardScreenPresentation rewardScreenPresentation) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      width: ScreenUtil().screenWidth,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
                Text(
                  "Error al mostrar anuncio",
                  style: Theme.of(context).textTheme.headlineSmall?.apply(
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
              ],
            ),
            Divider(
              height: 50.h,
              color: Colors.transparent,
            ),
            Text(
              "No te preocupes, podras reclamar tu recompensa",
              style: Theme.of(context).textTheme.bodyLarge?.apply(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
            Divider(
              height: 50.h,
              color: Colors.transparent,
            ),
            ElevatedButton(
              onPressed: () {
                rewardScreenPresentation.setRewardedAdShowingstate =
                    RewardedAdShowingState.adNotShowing;
                rewardScreenPresentation.askDailyReward(showAd: false);
              },
              child: Text(
                "Reclamar recompensa",
              ),
            )
          ],
        ),
      ),
    );
  }

  Container adLoadingDialog() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      width: ScreenUtil().screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Cargando anuncio",
            style: Theme.of(context).textTheme.titleMedium?.apply(
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
          Divider(
            color: Colors.transparent,
            height: 50.h,
          ),
          Container(
            height: 100.h,
            width: 100.h,
            child: LoadingIndicator(indicatorType: Indicator.circleStrokeSpin),
          )
        ],
      ),
    );
  }

  Flexible premiumCard(
      BuildContext context, RewardScreenPresentation rewardScreenPresentation) {
    return Flexible(
      flex: 4,
      fit: FlexFit.tight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Hotty Premium',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.apply(color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
              'Consigue monedas infinitas',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.apply(color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
              'Experiecia sin anuncios',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.apply(color: Theme.of(context).colorScheme.onSurface),
            ),
            FilledButton(
                onPressed: () {
                  Navigator.push(context, GoToRoute(page: SubscriptionsMenu()));
                },
                child: Text(
                  'Desde ${rewardScreenPresentation.premiumPrice}',
                )),
          ],
        ),
      ),
    );
  }

  Widget verifyProfileAndWindWidget() {
    return Card(
      child: Container(
        height: 400.h,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Verifica tu perfil y gana",
                      style: Theme.of(context).textTheme.titleMedium?.apply(
                          color: Theme.of(context).colorScheme.onSurface)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("2000",
                          style: Theme.of(context).textTheme.titleMedium?.apply(
                              color: Theme.of(context).colorScheme.onSurface)),
                      Icon(LineAwesomeIcons.coins,
                          color: Theme.of(context).colorScheme.onSurface)
                    ],
                  )
                ],
              ),
              Text("Gana 2000 monedas por verificar tu perfil",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(color: Theme.of(context).colorScheme.onSurface)),
              FilledButton.tonal(
                  onPressed: () {
                    Navigator.push(
                        context, GoToRoute(page: VerificationScreen()));
                  },
                  child: Text(
                    'Verificar',
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
