
import 'dart:ui';

import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';

import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:flushbar/flushbar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart' as xd;

import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';




class ListaDeValoraciones extends StatefulWidget {
  static final GlobalKey<AnimatedListState> llaveListaValoraciones =
      GlobalKey<AnimatedListState>();

  @override
  ListaDeValoracionesState createState() => ListaDeValoracionesState();
}

class ListaDeValoracionesState extends State<ListaDeValoraciones>
    with SingleTickerProviderStateMixin {
  AnimationController controladorAnimacionPocoTiempo;
  Animation animacionPocoTiempo;



  Widget barraExito() {
    return ChangeNotifierProvider.value(
        value: Valoracion.instanciar,
        child: Consumer<Valoracion>(
          builder: (context, myType, child) {
            return Container(
              decoration: BoxDecoration(color: Colors.white),
              height: ScreenUtil().setHeight(100),
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
                            flex: 3,
                            fit: FlexFit.tight,
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
                                  "${Valoracion.instanciar.visitasTotales}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
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
                                    percent: Valoracion.instanciar.mediaUsuario / 10,
                                    progressColor: Colors.deepPurple[900],
                                    center: Text(
                                      Valoracion.instanciar.mediaUsuario
                                          .toStringAsFixed(2),
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
                     
                    ],
                  ),
                ),
              )),
            );
          },
        ));
  }

  static void notifiacionValoracionRevelada(BuildContext context) {
    Flushbar(
      message: " ",
      duration: Duration(seconds:2),
        flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.purple,
      forwardAnimationCurve: Curves.linear,
      title: "Valoracion revelada",
      icon: Icon(Icons.check_circle,),
      reverseAnimationCurve: Curves.ease,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      borderRadius: 10,
    
      margin: EdgeInsets.all(5),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: todo
    // TODO: implement build
    return ChangeNotifierProvider.value(
        value: Valoracion.instanciar,
        child: Consumer<Valoracion>(
          builder: (context, myType, child) {
        
            return Material(
              child: SafeArea(
                child: Scaffold(
                  appBar:     AppBar(
                        title: Row(
                              mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Valoraciones"),
                            
                             Row(
                             
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        Text("${Usuario.esteUsuario.creditosUsuario}"),
                                        Icon(
                                          xd.LineAwesomeIcons.coins,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                          ],
                        ),
                        elevation: 0,
                      ),
                                  body: Column(
                    children: [
                  
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Container(child: barraExito())),
                      Flexible(
                         flex: 8,
                        fit: FlexFit.loose,

                        child: Container(
                          child: AnimatedList(
                            
                            key: ListaDeValoraciones.llaveListaValoraciones,
                            initialItemCount:
                                Valoracion.instanciar.listaDeValoraciones.length,
                            itemBuilder:
                                (BuildContext context, int indice, animation) {

                              return buildSlideTransition(context, animation,
                                  indice, Valoracion.instanciar.listaDeValoraciones[indice]);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      
                              await ControladorCreditos.instancia
                                  .restarCreditosValoracion(
                                      100, valoracion.idValoracion);
                            },
                            child: RepaintBoundary(
                                  child: Container(
                                    height: 400.h,
                                    decoration: BoxDecoration(
                                      color:Colors.deepPurple,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          cuentaAtrasValoracion(indice, valoracion),
                                          botonRevelarValoracion(),
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

  Flexible botonRevelarValoracion() {
    return Flexible(
                                          fit: FlexFit.tight,
                                          flex: 2,
                                          child: Container(
                                            color: Colors.greenAccent[700],
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      "Ver",
                                                      style: TextStyle(
                                                          fontSize: 60.sp,
                                                          color: Colors.white),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "${ControladorCreditos.precioValoracion}",
                                                          style:
                                                              GoogleFonts.lato(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      60.sp),
                                                        ),
                                                        Icon(
                                                          xd.LineAwesomeIcons
                                                              .coins,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    )
                                                  ]),
                                            ),
                                          ),
                                        );
  }

  Flexible cuentaAtrasValoracion(int indice, Valoracion valoracion) {
    return Flexible(
                                          fit: FlexFit.tight,
                                          flex: 5,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            mainAxisSize:
                                                MainAxisSize.max,
                                            children: [
                                                Icon(
                                                xd.LineAwesomeIcons.clock,
                                                color: Colors.white,
                                                size: 120.sp,
                                              ),
                                              StreamBuilder(
                                                stream: valoracion.notificadorFinTiempo.stream,

                                                initialData: valoracion.segundosRestantes,

                                                builder: (BuildContext context,AsyncSnapshot<int>dato){
                                                        if(dato.data==0&&valoracion.valoracionRevelada==false){
                valoracion.notificadorFinTiempo.close().then((value) =>     eliimnarSolicitud(indice, valoracion.idValoracion, valoracion));
            
              }
              if(valoracion.valoracionRevelada){
                valoracion.notificadorFinTiempo.close();
              }

              return      Container(
            child: Text(Valoracion.formatoTiempo.format(DateTime(0, 0, 0, 0, 0,  dato.data)),
                style: GoogleFonts.lato(fontSize: 90.sp, color: Colors.white)));
                                              },),
                                            
                                            ],
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
                          child: Text("Si",style: GoogleFonts.lato(fontSize: 45.sp,color: Colors.white),)),
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
                                Valoracion.instanciar
                                    .listaDeValoraciones[indice].idValoracion,valoracion);
                          },
                          child: Text("No",style: GoogleFonts.lato(fontSize: 45.sp,color: Colors.white),)),
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
                    height: ScreenUtil().setHeight(50),
                    child: Center(
                      child:valoracion.valoracionRevelada? LinearPercentIndicator(
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
                      ):Container(),
                    ),
                  ),
                ),
                       Flexible(
                  fit: FlexFit.tight,
                  flex: 5,
                                  child: Container(
                  
                    child: Center(
                      child:Text("¿Enviar solicitud de chat?",style: GoogleFonts.lato(fontSize: 45.sp),overflow: TextOverflow.clip,)
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

  void eliimnarSolicitud(int index, String id,Valoracion valoracionEliminar) {
    Valoracion valoracionQuitada =
        Valoracion.instanciar.listaDeValoraciones.removeAt(index);
       
      

        if(!Valoracion.instanciar.listaDeValoraciones.contains(valoracionEliminar)){
 AnimatedListRemovedItemBuilder builder = (context, animation) {
      return buildSlideTransition(
          context, animation, index, valoracionQuitada);
    };
    ListaDeValoraciones.llaveListaValoraciones.currentState
        .removeItem(index, builder);
        

    Valoracion.instanciar.rechazarValoracion(id);
        }
   
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
        Valoracion.instanciar.listaDeValoraciones.removeAt(indice);
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

