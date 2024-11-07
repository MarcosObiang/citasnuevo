import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'rewardScreenPresentation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RewardCardWidget extends StatefulWidget {
  RewardScreenPresentation rewardScreenPresentation;
  RewardCardWidget({
    required this.rewardScreenPresentation,
  });

  @override
  State<RewardCardWidget> createState() => _RewardCardWidgetState();
}

class _RewardCardWidgetState extends State<RewardCardWidget>
    with SingleTickerProviderStateMixin {
  late Animation<Color?> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reverse();
        }
        if (status == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });
    animation = ColorTween(begin: Colors.white, end: Colors.deepPurple)
        .animate(animationController);

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  DateFormat dateFormat = DateFormat("HH:mm:ss");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: widget
            .rewardScreenPresentation.rewardController.secondsUntilDailyReward,
        stream: widget
            .rewardScreenPresentation.dailyRewardTieRemainingStream?.stream,
        builder: (BuildContext context, AsyncSnapshot<int> data) {
          return Card(
              child: Container(
            height: 500.h,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.rewardScreenPresentation.getDayliRewardState ==
                      DailyRewardState.done
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!.daily_reward,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface)),
                            Row(
                              children: [
                                Text('600',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface)),
                                Icon(LineAwesomeIcons.coins,
                                    color:
                                        Theme.of(context).colorScheme.onSurface)
                              ],
                            )
                          ],
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 50.h,
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .daily_reward_description,
                          style: Theme.of(context).textTheme.bodyMedium?.apply(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 50.h,
                        ),
                        widget.rewardScreenPresentation.rewardController
                                    .secondsUntilDailyReward >
                                1
                            ? Text(
                                AppLocalizations.of(context)!.time_remaining(
                                    "${dateFormat.format(DateTime(0, 0, 0, 0, 0, (data.data ?? 0)))}"),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                              )
                            : FilledButton.tonalIcon(
                                onPressed: () {
                                  if (widget.rewardScreenPresentation.rewards
                                              .coins <=
                                          200 &&
                                      data.data! <= 0) {
                                    widget.rewardScreenPresentation
                                        .askDailyReward(showAd: true);
                                  }
                                },
                                icon: Icon(
                                  LineAwesomeIcons.film,
                                ),
                                label: Text(
                                  AppLocalizations.of(context)!.claim_reward,
                                )),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.loading,
                          style: Theme.of(context).textTheme.bodyMedium?.apply(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        Divider(
                          height: 50.h,
                          color: Colors.transparent,
                        ),
                        Center(
                            child: Container(
                          height: 100.h,
                          width: 100.h,
                          child: LoadingIndicator(
                            indicatorType: Indicator.circleStrokeSpin,
                            colors: [Theme.of(context).colorScheme.primary],
                          ),
                        ))
                      ],
                    ),
            ),
          ));
        });
  }
}
