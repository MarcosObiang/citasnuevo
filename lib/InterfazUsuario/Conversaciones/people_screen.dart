import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/InterfazUsuario/Directo/live_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Mensajes.dart';

class ConversacionesLikes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
    controller = TabController(length: 2, vsync: this);
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
    return people(context);
  }

  Widget people(BuildContext context) {
    return SafeArea(
      child: Material(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                title: getTabBar(),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: getTabBarView(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget barraExito() {
    return Container(
      height: ScreenUtil().setHeight(400),
      padding: EdgeInsets.all(10),
      color: Colors.orange[100],
      child: Container(),
    );
  }

  TabBar getTabBar() {
    return TabBar(
      tabs: <Widget>[
        Tab(
          child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Chat"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.chat),
              ),
            ]),
          ),
        ),
        Tab(
          child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Like"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(LineAwesomeIcons.heart),
              ),
            ]),
          ),
        ),
      ],
      controller: controller,
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
      children: <Widget>[Conversaciones(), list_live()],
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

class Conversaciones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Conversacion.conversaciones,
      child: Container(
          color: Colors.white,
          child: Consumer<Conversacion>(
            builder: (BuildContext context, conversacion, Widget child) {
              return Stack(children: <Widget>[
                Column(
                  children: [
                    Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PantallaSolicitudesConversaciones())),
                          child: Container(
                            color: Colors.deepPurple[900],
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10, top: 0, bottom: 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text("Solicitudes",
                                            style: GoogleFonts.lato(
                                                fontSize: 60.sp,
                                                color: Colors.white)),
                                        Icon(
                                          Icons.inbox_outlined,
                                          color: Colors.white,
                                        )
                                      ]),
                                  Container(
                                    height: 90.w,
                                    width: 90.w,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: Center(child: Text("${Solicitudes.instancia.listaSolicitudesConversacion.length}")),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )),
                    Flexible(
                      flex: 8,
                      fit: FlexFit.tight,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        child: ListView.builder(
                          itemCount: conversacion.listaDeConversaciones.length,
                          itemBuilder: (BuildContext context, indice) {
                            return conversacion
                                .listaDeConversaciones[indice].ventanaChat;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ]);
            },
          )),
    );
  }
}

class PantallaSolicitudesConversaciones extends StatefulWidget {
  @override
  _PantallaSolicitudesConversacionesState createState() =>
      _PantallaSolicitudesConversacionesState();
}

class _PantallaSolicitudesConversacionesState
    extends State<PantallaSolicitudesConversaciones> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.deepPurple[900],
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              iconTheme: IconThemeData(color:Colors.white),
              backgroundColor: Colors.deepPurple[900],
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Text("Solicitudes",
                    style:
                        GoogleFonts.lato(fontSize: 60.sp, color: Colors.white)),
                        Icon(Icons.inbox_outlined,color: Colors.white,)
              ]),
            ),
            Expanded(
              child: Container(
                color: Colors.deepPurple[900],
                child: Center(
                    child:WidgetSolicitudConversacion()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
