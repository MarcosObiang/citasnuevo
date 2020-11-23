import 'dart:async';
import 'dart:ui';

import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart' as xd;
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'live_screen_elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';
import 'dart:ui' as ui;
import 'package:blurred/blurred.dart';

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
        value: Valoracion.instanciar,
        child: Consumer<Valoracion>(
          builder: (context, myType, child) {
            return live_screen_widget();
          },
        ));
  }

  Widget live_screen_widget() {
    return DefaultTabController(
        length: 2,
        child: MaterialApp(
          color: Colors.white,
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
              body: Consumer<Valoracion>(
                builder: (BuildContext context, valoraciones, Widget child) {
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(child: ListaDeValoraciones()),
                      ],
                    ),
                  );
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
        ListaDeValoraciones(),
        InvitacionesEventos(),
      ],
      controller: controller,
    );
  }
}

class ListaDeValoraciones extends StatefulWidget {
  static final GlobalKey<AnimatedListState> llaveListaValoraciones =
      GlobalKey<AnimatedListState>();

  @override
  _ListaDeValoracionesState createState() => _ListaDeValoracionesState();
}

class _ListaDeValoracionesState extends State<ListaDeValoraciones> {
  Widget barraExito() {
    return ChangeNotifierProvider.value(
        value: Valoracion.instanciar,
        child: Consumer<Valoracion>(
          builder: (context, myType, child) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(

                  color: Colors.white
                ),
                height: ScreenUtil().setHeight(250),
                child: Container(
                    child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                flex: 5,
                                fit: FlexFit.tight,
                                child: Text(
                                  "Esta Semana",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.bold),
                                )),
                            Flexible(
                                fit: FlexFit.tight,
                                flex: 9,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LayoutBuilder(builder:
                                      (BuildContext context,
                                          BoxConstraints altura) {
                                    return LinearPercentIndicator(
                                      lineHeight: ScreenUtil().setHeight(80),
                                      backgroundColor: Colors.grey,
                                      linearStrokeCap: LinearStrokeCap.roundAll,
                                      animation: true,
                                      animationDuration: 300,
                                      animateFromLastPercent: true,
                                      percent: Valoracion.mediaUsuario / 10,
                                      progressColor: Colors.deepPurple[900],
                                      center: Text(
                                        Valoracion.mediaUsuario.toStringAsFixed(2),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(40),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }),
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 2,
                              fit: FlexFit.loose,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Visitas   ",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: ScreenUtil().setSp(40),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${Valoracion.visitasTotales}",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: ScreenUtil().setSp(40),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              flex: 4,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    flex: 4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        
                                         color: Colors.green,
                                        borderRadius: BorderRadius.all(Radius.circular(20))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Boost"),
                                            Icon(LineAwesomeIcons.rocket),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    flex: 2,
                                    child: FlatButton(
                                      onPressed: () => {},
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text("${Usuario.creditosUsuario}"),
                                          Icon(
                                            xd.LineAwesomeIcons.coins,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
        value: Valoracion.instanciar,
        child: Consumer<Valoracion>(
          builder: (context, myType, child) {
            return Material(
              child: SafeArea(
                child: Column(
                  children: [
                    AppBar(
                      title: Text("Valoraciones"),
                      elevation: 0,
                    ),
                    barraExito(),
                    Expanded(
                      child: Container(
                        child: AnimatedList(
                          key: ListaDeValoraciones.llaveListaValoraciones,
                          initialItemCount:
                              Valoracion.listaDeValoraciones.length,
                          itemBuilder:
                              (BuildContext context, int indice, animation) {
                            return buildSlideTransition(context, animation,
                                indice, Valoracion.listaDeValoraciones[indice]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  SizeTransition buildSlideTransition(BuildContext context, Animation animation,
      int indice, Valoracion valoracion) {
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: ScreenUtil().setHeight(400),
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10)],
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.white),
            child: Container(
              child: Stack(
                children: [
                  Row(
                    children: [
                      fotoSolicitud(valoracion),
                      cuadroOpcionesSolicitud(valoracion, indice),
                    ],
                  ),
                  !valoracion.valoracionRevelada
                      ? Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          height: 400.h,
                          child: Center(
                              child: GestureDetector(
                            onTap: () async {
                              print("guapo");
                               await ControladorCreditos.instancia.restarCreditosValoracion(100,valoracion.idValoracion);
                            },
                            child: Container(
                              height: 400.h,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[900],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 5,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Revelar",
                                                style:
                                                    TextStyle(fontSize: 60.sp,color: Colors.white),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "100",
                                                    style: GoogleFonts.lato(
                                                      color: Colors.white,
                                                        fontSize: 60.sp),
                                                  ),
                                                  Icon(xd
                                                      .LineAwesomeIcons.coins,color: Colors.white,),
                                                ],
                                              )
                                            ]),
                                      ),
                                      Flexible(
                                        fit: FlexFit.tight,
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              RepaintBoundary(child: CuentaAtrasValoracion(tiempo: valoracion.fechaValoracion)),
                                              Icon(xd
                                                  .LineAwesomeIcons.clock,color: Colors.white,),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )))
                      : Container()
                ],
              ),
            )),
      ),
    );
  }

  Flexible cuadroOpcionesSolicitud(Valoracion valoracion, int indice) {
    return Flexible(
      flex: 5,
      fit: FlexFit.tight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cuadroSuperiorValoracion(valoracion),
          cuadroOpcionesValoracion(indice, valoracion),
        ],
      ),
    );
  }

  Flexible cuadroOpcionesValoracion(int indice, Valoracion valoracion) {
    return Flexible(
        flex: 4,
        fit: FlexFit.tight,
        child: LayoutBuilder(
          builder: (BuildContext contex, BoxConstraints limites) {
            return Container(
              decoration: BoxDecoration(),
              height: limites.maxHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Container(
                      height: limites.maxHeight,
                      decoration: BoxDecoration(color: Colors.green),
                      child: FlatButton(
                          onPressed: () {
                            aceptarSolicitud(
                                indice,
                                valoracion.mensaje,
                                valoracion.nombreEmisor,
                                valoracion.imagenEmisor,
                                valoracion.idEmisor,
                                valoracion.idValoracion,
                                valoracion.imagenEmisor,
                                valoracion.valoracion);
                          },
                          child: Icon(
                            LineAwesomeIcons.heart_o,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.red),
                      height: limites.maxHeight,
                      child: FlatButton(
                          onPressed: () {
                            eliimnarSolicitud(
                                indice,
                                Valoracion
                                    .listaDeValoraciones[indice].idValoracion);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          )),
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }

  Flexible cuadroSuperiorValoracion(Valoracion valoracion) {
    return Flexible(
      flex: 14,
      fit: FlexFit.tight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                      child: valoracion.nombreEmisor != null
                          ? Text(
                              "${valoracion.nombreEmisor}",
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(40),
                                  fontWeight: FontWeight.bold),
                            )
                          : Text(" ")),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 5,
                  child: Container(
                      child: valoracion.mensaje == null ||
                              valoracion.mensaje == "null"
                          ? Text("")
                          : Text(
                              valoracion.mensaje,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(40),
                              ),
                            )),
                ),
                Container(
                  height: ScreenUtil().setHeight(50),
                  child: Center(
                    child: LinearPercentIndicator(
                      linearStrokeCap: LinearStrokeCap.butt,
                      //  progressColor: Colors.deepPurple,
                      percent: valoracion.valoracion / 10,
                      animationDuration: 300,
                      lineHeight: ScreenUtil().setHeight(60),
                      linearGradient: LinearGradient(
                          colors: [Colors.pink, Colors.pinkAccent[100]]),
                      center: Text(
                        "${(valoracion.valoracion).toStringAsFixed(1)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(40, allowFontScalingSelf: true),
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Flexible fotoSolicitud(Valoracion valoracion) {
    return Flexible(
      flex: 4,
      fit: FlexFit.tight,
      child: Container(
        decoration: BoxDecoration(
          
            image: DecorationImage(
                image: NetworkImage(valoracion.imagenEmisor),
                fit: BoxFit.cover)),
      ),
    );
  }

  void eliimnarSolicitud(int indice, String id) {
    Valoracion valoracionQuitada =
        Valoracion.listaDeValoraciones.removeAt(indice);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return buildSlideTransition(
          context, animation, indice, valoracionQuitada);
    };
    ListaDeValoraciones.llaveListaValoraciones.currentState
        .removeItem(indice, builder);

    Valoracion.instanciar.rechazarValoracion(id);
  }

  void aceptarSolicitud(
      int indice,
      String mensaje,
      String nombreEmisor,
      String imagenEmisor,
      String idEmisor,
      String idValoracion,
      String imagenRemitente,
      double nota) {
    Valoracion valoracionAceptada =
        Valoracion.listaDeValoraciones.removeAt(indice);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return buildSlideTransition(
          context, animation, indice, valoracionAceptada);
    };
    ListaDeValoraciones.llaveListaValoraciones.currentState
        .removeItem(indice, builder);

    Valoracion.instanciar.enviarSolicitudConversacion(
        idEmisor, nombreEmisor, imagenEmisor, nota, idValoracion);
  }
}

class InvitacionesEventos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(body: Container());
  }
}


// ignore: must_be_immutable
class CuentaAtrasValoracion extends StatefulWidget {
  final DateTime tiempo;
   int duracionSegundos;
  
  
  CuentaAtrasValoracion({@required this.tiempo});
  @override
  _CuentaAtrasValoracionState createState() => _CuentaAtrasValoracionState();
}

class _CuentaAtrasValoracionState extends State<CuentaAtrasValoracion> {
  Timer cuentaAtras;
  int segundos;
  int minutos;
  int horas;
  String tiempoPasado="";
   bool estaContanto=false;
 
  var formatoTiempo=new DateFormat("HH:mm:ss");

@override
  void initState() {
    // TODO: implement initState
      widget.duracionSegundos=widget.tiempo.difference(Valoracion.tiempoReferencia).inSeconds;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
   
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
 
    return Container(

      child: Countdown(
     
        seconds: widget.duracionSegundos,
        build: (BuildContext context,double time){
          int tiempo=time.toInt();
          
          return Text(formatoTiempo.format(DateTime(0,0,0,0,0,tiempo)), style:
                                                    GoogleFonts.lato(fontSize: 60.sp,color: Colors.white));
        },
      )
      
    );
  }
}