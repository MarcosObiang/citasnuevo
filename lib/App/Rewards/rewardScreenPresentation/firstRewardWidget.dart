import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'rewardScreenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FirstRewardWidget extends StatefulWidget {
  RewardScreenPresentation rewardScreenPresentation;
  FirstRewardWidget({
    required this.rewardScreenPresentation,
  });

  @override
  State<FirstRewardWidget> createState() => _FirstRewardWidgetState();
}

class _FirstRewardWidgetState extends State<FirstRewardWidget>
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
          child: Container(
            height: 400.h,
            child: Padding(
              padding: EdgeInsets.all(30.h),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.welcome_bonus,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.apply(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "3000",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                              ),
                              Icon(LineAwesomeIcons.coins,
                                  color:
                                      Theme.of(context).colorScheme.onSurface)
                            ],
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(   AppLocalizations.of(context)!.free_coins_to_register,
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.apply(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                      ),
                      FilledButton.tonal(
                          onPressed: () {
                            widget.rewardScreenPresentation.askFirstReward();
                          },
                          child: Text(
                              AppLocalizations.of(context)!.claim_bonus,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        widget.rewardScreenPresentation.getFirstRewards ==
                FirstRewards.inProcess
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
