import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:citasnuevo/DatosAplicacion/actividad.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Directo/live_screen_elements.dart';

class search_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return search_screen_widget().build(context);
  }
}
class search_screen_widget extends State<start> with SingleTickerProviderStateMixin{
  TabController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 3, vsync: this);
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
    return search_screen_creator();
    }
  Widget search_screen_creator() {
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
          text: "Gente",
        ),
        Tab(
          text: "Media",
        ),
        Tab(
          text: "Grupos",
        )
        ,Tab(
          text: "Plan"
        )
      ],
      controller: controller,
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
      children: <Widget>[
        search_people(),
        search_people(),
        search_grupo(),
        search_actividades()
      ],
      controller: controller,
    );
  }


}
class search_actividades extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView(
        children : Actividad().listaEventos
    );
  }
}
class search_grupo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemBuilder: (_, index) => group_box(),
      itemCount: 20,
    );
  }
}
class search_people extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GridView.count(
      childAspectRatio:
      (ScreenUtil().setWidth(550) / ScreenUtil().setHeight(700)),
      mainAxisSpacing: ScreenUtil().setHeight(40),
      addRepaintBoundaries: false,
      crossAxisCount: 3,
      children: List.generate(9, (index) {
        return chat_view();
      }),
    );
  }
}

