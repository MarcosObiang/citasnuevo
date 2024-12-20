import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'rewardScreenPresentation.dart';

class SharedLinkRewardWidget extends StatefulWidget {
  RewardScreenPresentation rewardScreenPresentation;
  SharedLinkRewardWidget({
    required this.rewardScreenPresentation,
  });

  @override
  State<SharedLinkRewardWidget> createState() => _SharedLinkRewardWidgetState();
}

class _SharedLinkRewardWidgetState extends State<SharedLinkRewardWidget>
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

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      height: 400.h,
      child: Padding(
        padding: EdgeInsets.all(30.h),
        child: Stack(
          children: [
            widget.rewardScreenPresentation
                        .getRewardTicketSuccessfulShareState ==
                    RewardTicketSuccesfulSharesState.done
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.sharedLinkRewardWidget_bonusFirInviteFriendsTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface)),
                          Row(
                            children: [
                              Text(
                                  "${widget.rewardScreenPresentation.rewards.rewardTicketSuccesfulShares * 200}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              Icon(
                                LineAwesomeIcons.coins,
                                color: Theme.of(context).colorScheme.onSurface,
                              )
                            ],
                          ),
                        ],
                      ),
                      Text(
                          AppLocalizations.of(context)!.sharedLinkRewardWidget_bonusForInviteFriendsMessage,
                          style: Theme.of(context).textTheme.bodyMedium?.apply(
                              color: Theme.of(context).colorScheme.onSurface)),
                      FilledButton.tonal(
                          onPressed: () {
                            widget.rewardScreenPresentation
                                .rewardTicketSuccesfultShares();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.sharedLinkRewardWidget_bonusForInviteFriendsButtonText,
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
          ],
        ),
      ),
    ));
  }
}
