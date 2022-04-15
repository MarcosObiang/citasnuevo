import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTilesScreen.dart';
import 'package:citasnuevo/presentation/reactionPresentation/Screens/ReactionScreen.dart';
import 'package:citasnuevo/presentation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../settingsPresentation/SettingsScreen.dart';

class HomeNavigationBar extends StatefulWidget {
  const HomeNavigationBar({Key? key}) : super(key: key);

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

  Container reactionsButton({required Icon icon}) {
    return Container(
      height: 150.h,
      width: 150.w,
      decoration: BoxDecoration(
          gradient: RadialGradient(
              focalRadius: 50.h, colors: [Colors.black, Colors.transparent]),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: GestureDetector(
          onTap: () {
            Navigator.push(context, GoToRoute(page: ReactionScreen()));
          },
          child: Container(
            child: icon,
          )),
    );
  }
    Container chatButton({required Icon icon}) {
    return Container(
      height: 150.h,
      width: 150.w,
      decoration: BoxDecoration(
          gradient: RadialGradient(
              focalRadius: 50.h, colors: [Colors.black, Colors.transparent]),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: GestureDetector(
          onTap: () {
            Navigator.push(context, GoToRoute(page: ChatScreen()));
          },
          child: Container(
            child: icon,
          )),
    );
  }

      Container settingsButton({required Icon icon}) {
    return Container(
      height: 150.h,
      width: 150.w,
      decoration: BoxDecoration(
          gradient: RadialGradient(
              focalRadius: 50.h, colors: [Colors.black, Colors.transparent]),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: GestureDetector(
          onTap: () {
            Navigator.push(context, GoToRoute(page: SettingsScreen()));
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
        height: 130.h,
        decoration: BoxDecoration(
            color: Color.fromRGBO(36, 28, 41, 100),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:[reactionsButton(icon: Icon(LineAwesomeIcons.heart,color: Colors.white,)),chatButton(icon: Icon(Icons.chat_bubble,color: Colors.white,)),settingsButton(icon: Icon(Icons.settings,color: Colors.white,))]),
      ),
    );
  }

}
