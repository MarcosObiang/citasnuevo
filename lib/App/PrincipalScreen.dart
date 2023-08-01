import 'package:badges/badges.dart' as badges;
import 'package:citasnuevo/App/principalScreenPresentation.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';
import 'Chat/chatPresentation/Widgets/chatTilesScreen.dart';
import 'ProfileViewer/homeScreenPresentation/Screens/HomeScreen.dart';
import 'Reactions/reactionPresentation/Screens/ReactionScreen.dart';
import 'Rewards/rewardScreenPresentation/rewardScreen.dart';
import '../core/dependencies/dependencyCreator.dart';
import 'Settings/settingsPresentation/SettingsScreen.dart';

class PrincipalScreen extends StatefulWidget {
  static const routeName = '/PrincipalScreen';
  static GlobalKey bottomNavigationKey =
      GlobalKey<State<BottomNavigationBar>>();

  int newChats = 0;
  int newMessages = 0;
  int newReactions = 0;
  PrincipalScreen();

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _page = 0;
  List<Widget> screens = [
    HomeAppScreen(),
    ReactionScreen(),
    ChatScreen(),
    RewardScreen(),
    SettingsScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: ChangeNotifierProvider.value(
        value: Dependencies.principalScreenPresentation,
        child: Consumer<PrincipalScreenPresentation>(builder:
            (BuildContext context,
                PrincipalScreenPresentation principalScreenPresentation,
                Widget? child) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hotty",
                      style: GoogleFonts.lato(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  Container(
                    child: Row(
                      children: [
                        principalScreenPresentation.isPremium
                            ? Icon(
                                LineAwesomeIcons.infinity,
                                color: Colors.black,
                              )
                            : Text(principalScreenPresentation.coins.toString(),
                                style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                        Icon(
                          LineAwesomeIcons.coins,
                          color: Colors.black,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
                key: PrincipalScreen.bottomNavigationKey,
                backgroundColor: Colors.white,
                currentIndex: _page,
                onTap: (value) {
                  setState(() {
                      _page = value;
                   // showAdConsentDialog();
                  });
                },
                items: <BottomNavigationBarItem>[
                  homeScreen(
                      icon: Icon(
                    LineAwesomeIcons.home,
                    color: Colors.black,
                  )),
                  reactionsButton(
                      icon: Icon(
                        LineAwesomeIcons.heart,
                        color: Colors.black,
                      ),
                      reactionCount: principalScreenPresentation.newReactions),
                  chatButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.black,
                      ),
                      newMesagesCount: principalScreenPresentation.newMessages,
                      newChatsCount: principalScreenPresentation.newChats),
                   

                  rewardsButton(
                      promotionalCodePendingOfUse: principalScreenPresentation
                          .promotionalCodePendingOfUse,
                      rewardTicketSuccesfultShares: principalScreenPresentation
                          .rewardTicketSuccesfulShares,
                      waitingDailyReward:
                          principalScreenPresentation.waitingDailyReward,
                      waitingFirstReward:
                          principalScreenPresentation.waitingFirstReward,
                      icon: Icon(
                        LineAwesomeIcons.coins,
                        color: Colors.black,
                      )),
                  settingsButton(
                      icon: Icon(
                    LineAwesomeIcons.user_edit,
                    color: Colors.black,
                  )),
                ]),
            body: Padding(
              padding: EdgeInsets.all(20.w),
              child: Container(
                height:ScreenUtil.defaultSize.height,
                child: IndexedStack(
                  children: screens,
                  index: _page,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  BottomNavigationBarItem reactionsButton(
      {required Icon icon, required int reactionCount}) {
    return BottomNavigationBarItem(
        icon: badges.Badge(
          child: icon,
          badgeContent: Text(
            reactionCount.toString(),
          ),
          badgeStyle: badges.BadgeStyle(badgeColor: Colors.deepPurple),
          showBadge: reactionCount > 0 ? true : false,
        ),
        label: "");
  }

  BottomNavigationBarItem chatButton(
      {required Icon icon,
      required int newMesagesCount,
      required int newChatsCount}) {
    return BottomNavigationBarItem(
        icon: badges.Badge(
          child: icon,
          badgeContent: newMesagesCount > 0
              ? Text(
                  newMesagesCount.toString(),
                )
              : Container(),
          showBadge: (newMesagesCount > 0 ? true : false) ||
              (newChatsCount > 0 ? true : false),
        ),
        label: "");
  }


  BottomNavigationBarItem rewardsButton(
      {required Icon icon,
      required bool waitingDailyReward,
      required bool waitingFirstReward,
      required int rewardTicketSuccesfultShares,
      required bool promotionalCodePendingOfUse}) {
    return BottomNavigationBarItem(
        icon: badges.Badge(
          child: icon,
          showBadge: (waitingDailyReward == true ||
                  waitingFirstReward == true ||
                  rewardTicketSuccesfultShares > 0 ||
                  promotionalCodePendingOfUse == true)
              ? true
              : false,
        ),
        label: "");
  }

  BottomNavigationBarItem settingsButton({required Icon icon}) {
    return BottomNavigationBarItem(icon: icon, label: "");
  }

  BottomNavigationBarItem homeScreen({required Icon icon}) {
    return BottomNavigationBarItem(
      icon: icon,
      label: "",
    );
  }

  
}
