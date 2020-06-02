import 'dart:ui';
import 'package:citasnuevo/DatosAplicacion/actividad.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import 'live_screen_elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';

class live extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return live_screen().build(context);
  }
}

class live_screen extends State<start> with SingleTickerProviderStateMixin {
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
    return ChangeNotifierProvider.value(
        value: Valoraciones.Puntuaciones, child: live_screen_widget());
  }

  Widget live_screen_widget() {
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
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(65.0),
                child: AppBar(
                  backgroundColor: Colors.white,
                  bottom: getTabBar(),
                ),
              ),
              body: Consumer<Valoraciones>(
                builder: (BuildContext context, valoraciones, Widget child) {
                  return getTabBarView();
                },
              )),
        ));
  }

  TabBar getTabBar() {
    return TabBar(
      isScrollable: false,
      tabs: <Widget>[
        Tab(
          text: "Le Gustas",
        ),
       
        Tab(
          text: "Invitacion",
        ),
      ],
      controller: controller,
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
      children: <Widget>[
        list_live(),
       
        InvitacionesEventos(),
      ],
      controller: controller,
    );
  }
}

class list_live extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemCount: Valoraciones.puntuaciones.length,
      itemBuilder: (BuildContext context, int indice) {
        print( Valoraciones.puntuaciones[indice].valorWidget.puntuacionUsuario);
        return Dismissible(
          child: Valoraciones.puntuaciones[indice].valorWidget,
          key: UniqueKey(),
          onDismissed: (d) {
            if (d == DismissDirection.endToStart) {
              Solicitud.instancia.rechazarSolicitud(
                  
                  Valoraciones
                      .puntuaciones[indice].valorWidget.idValoracion,
                  indice);
            }
            if (d == DismissDirection.startToEnd) {
              Solicitud.instancia.aceptarSolicitud(
                  Valoraciones
                      .puntuaciones[indice].valorWidget.mensajeUsuario,
                  Valoraciones
                      .puntuaciones[indice].valorWidget.nombreEmisor,
                  Valoraciones
                      .puntuaciones[indice].valorWidget.imagenUsuario,
                  Valoraciones.puntuaciones[indice].valorWidget
                      .idEmisorValoracion,indice,Valoraciones
                      .puntuaciones[indice].valorWidget.idValoracion,);
            }
            
          },
          background: Container(
            color: Colors.green,
            child: Row(
              children: <Widget>[
                Text("Me gusta"),
                Icon(Icons.person_add)
              ],
            ),
          ),
          secondaryBackground:  Container(
            color: Colors.red,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text("Descartar"),
                Icon(Icons.delete)
              ],
            ),
          ),
        );
      },
    );
  }
}


class InvitacionesEventos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(body: TarjetaSolicitudEvento());
  }
}
