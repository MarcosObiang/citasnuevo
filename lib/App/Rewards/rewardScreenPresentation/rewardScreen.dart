import 'package:citasnuevo/App/PurchaseSystem/purchaseSystemPresentation/purchaseScreen.dart';
import 'package:citasnuevo/App/Verification/verificationPresentation/verificationScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
                                             AppLocalizations.of(context)!.free_coins,
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
                                                          true
                                                      ? RepaintBoundary(
                                                          child: FirstRewardWidget(
                                                              rewardScreenPresentation:
                                                                  rewardScreenPresentation),
                                                        )
                                                      : Container(),
                                                  rewardScreenPresentation
                                                              .rewards
                                                              .promotionalCodePendingOfUse ==
                                                          true
                                                      ? RepaintBoundary(
                                                          child: PromotionalRewardWidget(
                                                              rewardScreenPresentation:
                                                                  rewardScreenPresentation),
                                                        )
                                                      : Container(),
                                                  rewardScreenPresentation
                                                              .rewards
                                                              .rewardTicketSuccesfulShares >
                                                          0
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
                                  child: Text(AppLocalizations.of(context)!.you_are_a_premium_user,
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
                                  Text(AppLocalizations.of(context)!.loading,
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
                              Text(AppLocalizations.of(context)!.loading_error,
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
                                  label: Text(AppLocalizations.of(context)!.try_again))
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
              AppLocalizations.of(context)!.ad_incomplete,
              style: Theme.of(context).textTheme.headlineSmall?.apply(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
            Text(
              AppLocalizations.of(context)!.you_must_complete_the_ad_to_get_your_reward,
              style: Theme.of(context).textTheme.bodyLarge?.apply(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
            ElevatedButton(
                onPressed: () {
                  rewardScreenPresentation.setRewardedAdShowingstate =
                      RewardedAdShowingState.adNotShowing;
                },
                child: Text(
                AppLocalizations.of(context)!.understood,
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
                 AppLocalizations.of(context)!.error_displaying_ad,
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
              AppLocalizations.of(context)!.dont_worry_you_can_claim_your_reward,
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
                AppLocalizations.of(context)!.claim_reward,
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
            AppLocalizations.of(context)!.loading,
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
              AppLocalizations.of(context)!.hotty_premium,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.apply(color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
              AppLocalizations.of(context)!.get_infinite_coins,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.apply(color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
             AppLocalizations.of(context)!.ad_free_experience,
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
                  AppLocalizations.of(context)!.from(rewardScreenPresentation.premiumPrice)
           ,
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
                  Text(AppLocalizations.of(context)!.verify_your_profile_and_win,
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
              Text(AppLocalizations.of(context)!.win_2000_coins_for_verifying_your_profile,
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
                    AppLocalizations.of(context)!.verify,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
