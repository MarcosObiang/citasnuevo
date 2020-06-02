import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'people_screen_elements.dart';

class people extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1440, height: 3120, allowFontScaling: true);
    // TODO: implement build
    return people_screen().build(context);
  }
}

class people_screen extends State<start> with SingleTickerProviderStateMixin {
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
    return people();
  }

  Widget people() {
    return DefaultTabController(
        length: 2,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: new ThemeData(
              highlightColor: Colors.deepPurple,
              tabBarTheme: TabBarTheme(
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.black87,
                  labelStyle: TextStyle(
                      fontSize:
                          ScreenUtil().setSp(60, allowFontScalingSelf: true),
                      fontWeight: FontWeight.bold)),
              primaryColor: Colors.white,
              accentColor: Colors.deepPurple),
          home: Scaffold(
              backgroundColor: Colors.white,
              //////////////////////////////////////////////////////////////////*********************************AppBar*********************************************************************************
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(65.0),
                child: AppBar(
                  backgroundColor: Colors.white,
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
          text: "Conversaciones",
        ),
        Tab(
          text: "Planes",
        ),

      ],
      controller: controller,
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
      children: <Widget>[list_date(), list_global()],
      controller: controller,
    );
  }
}

class grupo_date extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Column(
        children: <Widget>[],
      ),
    );
  }
}

class grupo_friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Column(
        children: <Widget>[],
      ),
    );
  }
}

class list_date extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Conversacion.conversaciones,
      child: Scaffold(body: Consumer<Conversacion>(
        builder: (BuildContext context, conversacion, Widget child) {
          print("cambio");
          return Stack(
                      children:<Widget>[ ListView.builder(
         itemCount: conversacion.listaDeConversaciones.length,
              itemBuilder: (BuildContext context,indice){
             return conversacion.listaDeConversaciones[indice].ventanaChat;
              },

            ),]
          );
        },
      )),
    );
  }
}

class list_global extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: ScreenUtil().setHeight(120),
          width: ScreenUtil().setWidth(500),
          color: Colors.deepPurple.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: ScreenUtil().setWidth(400),
                child: Text(
                  "Sara Gomez, 28",
                  style: TextStyle(
                      fontSize:
                          ScreenUtil().setSp(50, allowFontScalingSelf: true),
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(1000),
                child: Container(
                  color: Colors.deepPurple.shade100,
                  child: Text(
                    "Mostoles, Madrid, a 8 km de ti,",
                    style: TextStyle(
                        fontSize:
                            ScreenUtil().setSp(50, allowFontScalingSelf: true),
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 36,
          child: ListView.builder(
            itemBuilder: (_, index) => grupo_date(),
            itemCount: 3,
          ),
        ),
      ],
    );
    ;
  }
}


