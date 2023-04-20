import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'rewardScreenPresentation.dart';

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
          return Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: widget
                                      .rewardScreenPresentation
                                      .rewardController
                                      .secondsUntilDailyReward ==
                                  0
                              ? animation.value as Color
                              : Colors.white,
                          width: 20.h),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: EdgeInsets.all(30.h),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Text('Recompensa diaria',
                                    style: GoogleFonts.roboto(
                                        color: Colors.black, fontSize: 70.sp)),
                              ],
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 50.h,
                            ),
                            Text(
                              'Cuando tengas menos de 200 creditos, en 24 horas te reponemos hasta los 600 creditos',
                              style: GoogleFonts.roboto(
                                  color: Colors.black, fontSize: 50.sp),
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 50.h,
                            ),
                            widget.rewardScreenPresentation.rewardController
                                        .secondsUntilDailyReward !=
                                    0
                                ? Text(
                                    " Tiempo restante: ${dateFormat.format(DateTime(
                                        0, 0, 0, 0, 0, (data.data ?? 0)))}",
                                    style: GoogleFonts.roboto(
                                        color: Colors.black, fontSize: 50.sp),
                                  )
                                : TextButton(
                                    onPressed: () {
                                      if (widget.rewardScreenPresentation
                                                  .rewards.coins <
                                              200 &&
                                          data.data! <= 0) {
                                        widget.rewardScreenPresentation
                                            .askDailyReward(showAd: true);
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: widget.rewardScreenPresentation
                                                          .rewards.coins >=
                                                      200 &&
                                                  data.data == 0
                                              ? Color.fromARGB(
                                                  138, 158, 158, 158)
                                              : Colors.deepPurple,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      child: Padding(
                                        padding: EdgeInsets.all(40.h),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              'Reclamar recompensa',
                                              style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 50.sp),
                                            ),
                                            Icon(
                                              LineAwesomeIcons.film,
                                              color: Colors.white,
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                          ],
                        ),
                      ],
                    ),
                  )),
              widget.rewardScreenPresentation.getDayliRewardState ==
                      DailyRewardState.inProcess
                  ? Container(
                      height: 600.h,
                      width: ScreenUtil().screenWidth,
                      color: Color.fromARGB(228, 100, 24, 135),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Espere",
                            style: GoogleFonts.roboto(
                                color: Colors.white, fontSize: 60.sp),
                          ),
                          Center(
                              child: Container(
                            height: 200.h,
                            width: 200.h,
                            child: LoadingIndicator(
                                indicatorType: Indicator.orbit),
                          ))
                        ],
                      ),
                    )
                  : Container()
            ],
          );
        });
  }
}
