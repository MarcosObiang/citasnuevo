import 'rewardScreenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PromotionalRewardWidget extends StatefulWidget {
  RewardScreenPresentation rewardScreenPresentation;
  PromotionalRewardWidget({
    required this.rewardScreenPresentation,
  });

  @override
  State<PromotionalRewardWidget> createState() =>
      _PromotionalRewardWidgetState();
}

class _PromotionalRewardWidgetState extends State<PromotionalRewardWidget>
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
    return Stack(
      children: [
        Card(
            child: Padding(
          padding: EdgeInsets.all(30.h),
          child: Container(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.promotional_reward,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.apply(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                        Row(
                          children: [
                            Text('5000',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface)),
                            Icon(LineAwesomeIcons.coins,
                                color: Theme.of(context).colorScheme.onSurface)
                          ],
                        )
                      ],
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 50.h,
                    ),
                    Text(
                     AppLocalizations.of(context)!.promotional_reward_description,
                      style: Theme.of(context).textTheme.bodyLarge?.apply(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 50.h,
                    ),
                    FilledButton.tonal(
                        onPressed: () {
                          widget.rewardScreenPresentation.usePromotionalCode();
                        },
                        child: Text(
                         AppLocalizations.of(context)!.claim_bonus,
                        )),
                  ],
                ),
              ],
            ),
          ),
        )),
        widget.rewardScreenPresentation.getPromotionalCodeState ==
                PromotionalCodeState.inProcess
            ? Container(
                height: 600.h,
                width: ScreenUtil().screenWidth,
                color: Color.fromARGB(228, 100, 24, 135),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.wait,
                      style: GoogleFonts.roboto(
                          color: Colors.white, fontSize: 60.sp),
                    ),
                    Center(
                        child: Container(
                      height: 200.h,
                      width: 200.h,
                      child: LoadingIndicator(indicatorType: Indicator.orbit),
                    ))
                  ],
                ),
              )
            : Container()
      ],
    );
  }
}
