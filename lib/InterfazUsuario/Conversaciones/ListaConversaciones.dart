import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';

import '../../main.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Mensajes.dart';

class ConversacionesLikes extends StatelessWidget {
  static final GlobalKey claveListaConversaciones = new GlobalKey();
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
        child: ChangeNotifierProvider.value(
      value: Conversacion.conversaciones,
      child: Consumer<Conversacion>(
        builder: (context, myType, child) {
          return Material(
            key: ConversacionesLikes.claveListaConversaciones,
            child: Column(
              children: [
                Container(
                  height: kToolbarHeight,
                  width: ScreenUtil.defaultWidth.toDouble(),
                  child: Stack(
                    children: [
                      Citas.estaConectado == true
                          ? Container(
                              height: kToolbarHeight,
                              width: ScreenUtil.defaultWidth.toDouble(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Chats",
                                    style: GoogleFonts.lato(
                                        color: Colors.black,
                                        fontSize: 70.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.message_outlined,
                                      color: Colors.black)
                                ],
                              ),
                            )
                          : Container(
                              height: kToolbarHeight,
                              width: ScreenUtil.defaultWidth.toDouble(),
                              color: Colors.black,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "No tienes conexión",
                                    style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 70.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.network_check_rounded,
                                      color: Colors.white)
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Conversaciones(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ));
  }

  Widget barraExito() {
    return Container(
      height: ScreenUtil().setHeight(400),
      padding: EdgeInsets.all(10),
      color: Colors.orange[100],
      child: Container(),
    );
  }
}

class Conversaciones extends StatefulWidget {
  static bool enPantallaConversacion=true;
  @override
  _ConversacionesState createState() => _ConversacionesState();
}

class _ConversacionesState extends State<Conversaciones> with RouteAware {



  @override void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
      // TODO: implement didChangeDependencies
      super.didChangeDependencies();
    }





    void didPopNext() {
      Conversaciones.enPantallaConversacion=true;
    debugPrint("didPopNext ${runtimeType}");

  
  }

  // Called when the current route has been pushed.
  void didPush() {
    debugPrint("didPush ${runtimeType}");
  }

  // Called when the current route has been popped off.
  void didPop() {
  


    debugPrint("didPop ${runtimeType}");
  }

  // Called when a new route has been pushed, and the current route is no longer visible.
  void didPushNext() {
    Conversaciones.enPantallaConversacion=false;
    debugPrint("didPushNext ${runtimeType}");
  }

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
                    Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: conversacion.listaDeConversaciones.length > 0
                              ? ListView.builder(
                                  itemCount:
                                      conversacion.listaDeConversaciones.length,
                                  itemBuilder: (BuildContext context, indice) {
                                    return conversacion
                                        .listaDeConversaciones[indice]
                                        .ventanaChat;
                                  },
                                )
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 50, right: 50),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.message_outlined,
                                            color: Colors.black, size: 150.sp),
                                        Text(
                                            "Aun no tienes conversaciones, acepta o envia alguna solicitud para poder iniciar alguna")
                                      ],
                                    ),
                                  ),
                                )),
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
              leading: new Container(),
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: Colors.deepPurple[900],
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Solicitudes",
                        style: GoogleFonts.lato(
                            fontSize: 60.sp, color: Colors.white)),
                    Row(
                      children: [
                        Text("${Usuario.esteUsuario.creditosUsuario}",
                            style: GoogleFonts.lato(
                                fontSize: 60.sp, color: Colors.white)),
                        Icon(
                          LineAwesomeIcons.money,
                          color: Colors.white,
                        ),
                      ],
                    )
                  ]),
            ),
            Expanded(
              child: Container(
                color: Colors.deepPurple[900],
                child: Center(
                    child: Solicitudes
                                .instancia.listaSolicitudesConversacion.length >
                            0
                        ? WidgetSolicitudConversacion()
                        : Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.message_outlined,
                                    color: Colors.black, size: 150.sp),
                                Text(
                                  "Aún no tienes solicitudes de conversacion, sé paciente",
                                )
                              ],
                            ),
                          )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
