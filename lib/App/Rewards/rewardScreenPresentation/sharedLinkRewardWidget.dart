import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'rewardScreenPresentation.dart';

class SharedLinkRewardWidget extends StatefulWidget {
  RewardScreenPresentation rewardScreenPresentation;
  SharedLinkRewardWidget({
    required this.rewardScreenPresentation,
  });

  @override
  State<SharedLinkRewardWidget> createState() =>
       _SharedLinkRewardWidgetState();
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
                Text("Recompensa promocional",
                    style: GoogleFonts.roboto(
                        color: Colors.black, fontSize: 70.sp)),
                Text("Tu codigo de invitacion ha sido usado correctamente",
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                    )),
                Text(
                    "Tu recompensa: 2000 creditos * ${widget.rewardScreenPresentation.rewardController.rewards?.rewardTicketSuccesfulShares} = ${widget.rewardScreenPresentation.rewardController.rewards!.rewardTicketSuccesfulShares * 2000} ",
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                    )),
                TextButton(
                    onPressed: () {
                      widget.rewardScreenPresentation.rewardTicketSuccesfultShares();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.all(Radius.circular(30))),
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
            )
                ],
              ),
            )),
         widget.rewardScreenPresentation.getRewardTicketSuccessfulShareState ==
                RewardTicketSuccesfulSharesState.inProcess
            ? Container(
                height: 500.h,
                width: ScreenUtil().screenWidth,
                color: Color.fromARGB(228, 100, 24, 135),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Cargando",
                      style: GoogleFonts.roboto(color: Colors.white),
                    ),
                    Center(
                        child: Container(
                      height: 200.h,
                      width: 300.h,
                      child:
                          LoadingIndicator(indicatorType: Indicator.ballPulse),
                    ))
                  ],
                ),
              )
            : Container()
      ],
    );
  }
}