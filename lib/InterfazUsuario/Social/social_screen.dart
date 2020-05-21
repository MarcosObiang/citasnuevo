import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Directo/live_screen_elements.dart';
import 'social_screen_elements.dart';

class social_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return social_screen_build().build(context);
  }
}

class social_screen_build extends State<start> with SingleTickerProviderStateMixin {
  TabController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return social_screen_widget();
  }

  Widget social_screen_widget() {
    return DefaultTabController(
        length: 4,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: new ThemeData(
              highlightColor: Colors.deepPurple,
              tabBarTheme: TabBarTheme(
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.black87,
                  labelStyle:
                  TextStyle(fontSize: ScreenUtil().setSp(60,allowFontScalingSelf: true), fontWeight: FontWeight.bold)),
              primaryColor: Colors.white,
              accentColor: Colors.deepPurple),
          home: Scaffold(
              backgroundColor: Colors.white,
              //////////////////////////////////////////////////////////////////*********************************AppBar*********************************************************************************
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(65.0),
                child: AppBar(
                  backgroundColor: Colors.white,
                  title: Text(
                    "Buddy",
                    style: TextStyle(fontSize: ScreenUtil().setSp(60,allowFontScalingSelf: true), color: Colors.deepPurple),
                  ),
                  bottom: getTabBar(),
                ),
              ),
              body: getTabBarView()

            //***************************************************************************************Barra Baja

          ),
        ));
  }

  TabBar getTabBar() {
    return TabBar(
      tabs: <Widget>[
        Tab(
          text: "Album",
        ),
        Tab(
          text: "Chats",
        ),
        Tab(
          text: "Crush",
        ),
        Tab(
          text: "Grupos",
        )
      ],
      controller: controller,
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
      children: <Widget>[
        list_album(),
        list_chat(),
        list_crush(),
        list_group(),
      ],
      controller: controller,
    );
  }
}






class list_album extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemBuilder: (_, index) => album_box(),
      itemCount: 7,
    );
  }
}
class list_chat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemBuilder: (_, index) => chat_box(),
      itemCount: 7,
    );
  }
}

class list_group extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemBuilder: (_, index) => group_box(),
      itemCount: 7,
    );
  }
}
class list_crush extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemBuilder: (_, index) => crush_box(),
      itemCount: 7,
    );
  }
}