import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTilesScreen.dart';
import 'package:citasnuevo/presentation/reactionPresentation/Screens/ReactionScreen.dart';
import 'package:citasnuevo/presentation/rewardScreenPresentation/rewardScreen.dart';
import 'package:citasnuevo/presentation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../settingsPresentation/SettingsScreen.dart';

class HomeNavigationBar extends StatefulWidget {
  int newChats = 0;
  int newMessages = 0;
  int newReactions = 0;
  HomeNavigationBar(
      {required this.newChats,
      required this.newMessages,
      required this.newReactions});

  @override
  State<StatefulWidget> createState() {
    return _NavigationBarState();
  }
}

class _NavigationBarState extends State<HomeNavigationBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return botonesLateralesCitas(context);
  }

  Widget reactionsButton({required Icon icon}) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 150.h,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: GestureDetector(
              onTap: () {
                Navigator.push(context, GoToRoute(page: ReactionScreen()));
              },
              child: Container(
                child: icon,
              )),
        ),
        widget.newReactions > 0
            ? Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 120.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.deepPurple),
                  child: Padding(
                    padding: EdgeInsets.all(5.h),
                    child: Row(
                      children: [
                        Text(
                          widget.newReactions.toString(),
                              style: GoogleFonts.roboto(color: Colors.white,fontSize:25.sp),
                        ),
                        Icon(
                          LineAwesomeIcons.heart,
                          color: Colors.white,
                          size: 50.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget chatButton({required Icon icon}) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 150.h,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: GestureDetector(
              onTap: () {
                Navigator.push(context, GoToRoute(page: ChatScreen()));
              },
              child: Container(
                child: icon,
              )),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.newMessages > 0
                  ? Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.deepPurple),
                      child: Padding(
                        padding: EdgeInsets.all(5.h),
                        child: Row(
                          children: [
                            Text(
                               widget.newMessages.toString(),
                              style: GoogleFonts.roboto(color: Colors.white,fontSize:25.sp),
                            ),
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 50.sp,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              widget.newChats > 0
                  ? Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.deepPurple),
                      padding: EdgeInsets.all(5.h),
                      child: Row(
                        children: [
                          Text(
                            widget.newChats.toString(),
                              style: GoogleFonts.roboto(color: Colors.white,fontSize:25.sp),
                          ),
                          Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 50.sp,
                          ),
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ],
    );
  }

  Container settingsButton({required Icon icon}) {
    return Container(
      height: 150.h,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: GestureDetector(
          onTap: () {
            Navigator.push(context, GoToRoute(page: SettingsScreen()));
          },
          child: Container(
            child: icon,
          )),
    );
  }

  
  Container rewardsButton({required Icon icon}) {
    return Container(
      height: 150.h,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: GestureDetector(
          onTap: () {
            Navigator.push(context, GoToRoute(page: RewardScreen()));
          },
          child: Container(
            child: icon,
          )),
    );
  }

  Align botonesLateralesCitas(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 150.h,
        decoration: BoxDecoration(
            color: Color.fromRGBO(36, 28, 41, 100),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: reactionsButton(
                    icon: Icon(
                  LineAwesomeIcons.heart,
                  color: Colors.white,
                )),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: chatButton(
                    icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                )),
              ),
               Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: rewardsButton(
                    icon: Icon(
                  LineAwesomeIcons.coins,
                  color: Colors.white,
                )),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: settingsButton(
                    icon: Icon(
                  LineAwesomeIcons.user_edit,
                  color: Colors.white,
                )),
              ), 
            ]),
      ),
    );
  }
}
