import 'package:badges/badges.dart' as badges;
import 'package:citasnuevo/App/principalScreenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              automaticallyImplyLeading: false,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hotty",
                      style: Theme.of(context).textTheme.titleLarge?.apply(
                          fontWeightDelta: 3,
                          color: Theme.of(context).colorScheme.primary)),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _page = 3;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Row(
                          children: [
                            principalScreenPresentation.isPremium
                                ? Icon(
                                    LineAwesomeIcons.infinity,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )
                                : Text(
                                    principalScreenPresentation.coins
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.apply(
                                            fontWeightDelta: 3,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary)),
                            Icon(
                              LineAwesomeIcons.coins,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
                elevation: 0,
                type: BottomNavigationBarType.shifting,
                key: PrincipalScreen.bottomNavigationKey,
                backgroundColor: Theme.of(context).colorScheme.surface,
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
                    Icons.crop_square_outlined,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  )),
                  reactionsButton(
                      icon: Icon(
                        LineAwesomeIcons.heart,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      reactionCount: principalScreenPresentation.newReactions),
                  chatButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
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
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      )),
                  settingsButton(
                      icon: Icon(
                    LineAwesomeIcons.user_edit,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  )),
                ]),
            body: Padding(
              padding: EdgeInsets.all(20.w),
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                height: ScreenUtil.defaultSize.height,
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        icon: badges.Badge(
          child: icon,
          badgeContent: Text(
            reactionCount.toString(),
          ),
          badgeStyle: badges.BadgeStyle(
              badgeColor: Theme.of(context).colorScheme.error),
          showBadge: reactionCount > 0 ? true : false,
        ),
        label: "");
  }

  BottomNavigationBarItem chatButton(
      {required Icon icon,
      required int newMesagesCount,
      required int newChatsCount}) {
    return BottomNavigationBarItem(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        icon: badges.Badge(
          badgeStyle: badges.BadgeStyle(
              badgeColor: Theme.of(context).colorScheme.error),
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
    return BottomNavigationBarItem(
      icon: icon,
      label: "",
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  BottomNavigationBarItem homeScreen({required Icon icon}) {
    return BottomNavigationBarItem(
      backgroundColor: Theme.of(context).colorScheme.surface,
      icon: icon,
      label: "",
    );
  }
}
