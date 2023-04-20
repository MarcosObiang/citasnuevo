import 'rewardScreenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

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
        Container(
            decoration: BoxDecoration(
                border:
                    Border.all(color: animation.value as Color, width: 20.h),
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
                          Text('Recompensa promocional',
                              style: GoogleFonts.roboto(
                                  color: Colors.black, fontSize: 70.sp)),
                        ],
                      ),
                      Divider(
                        color: Colors.transparent,
                        height: 50.h,
                      ),
                      Text(
                        '"Has usado un codigo promocional y ahora te regalamos 5000 creditos gratis',
                        style: GoogleFonts.roboto(
                            color: Colors.black, fontSize: 50.sp),
                      ),
                      Divider(
                        color: Colors.transparent,
                        height: 50.h,
                      ),
                      TextButton(
                          onPressed: () {
                            widget.rewardScreenPresentation
                                .usePromotionalCode();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Padding(
                              padding: EdgeInsets.all(40.h),
                              child: Text(
                                'Reclamar bono',
                                style: GoogleFonts.roboto(
                                    color: Colors.black, fontSize: 50.sp),
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
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
                      "Espere",
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
