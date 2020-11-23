import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
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
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              title: Text("Conversaciones"),
         
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
                   
                    Expanded(
                    
                  
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
                        Row(
                          children: [
                            Text("${Usuario.creditosUsuario}",
                    style:
                        GoogleFonts.lato(fontSize: 60.sp, color: Colors.white)),
                            Icon(LineAwesomeIcons.money,color: Colors.white,),
                          ],
                        )
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
