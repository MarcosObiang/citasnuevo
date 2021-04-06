import 'dart:ui';

import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';

import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/EstadoConexion.dart';
import 'package:citasnuevo/DatosAplicacion/WrapperLikes.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/WidgetError.dart';
import 'package:flash/flash.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart' as xd;
import 'package:loading_indicator/loading_indicator.dart';

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
  Animation animacionCreditos;
  AnimationController controladorAnimacionCreditos;

  Widget barraExito() {
    return ChangeNotifierProvider.value(
        value: Valoracion.instanciar,
        child: Consumer<Valoracion>(
          builder: (context, myType, child) {
            return Container(
              decoration: BoxDecoration(color: Colors.deepPurple),
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
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${Valoracion.instanciar.visitasTotales}",
                                  style: TextStyle(
                                      color: Colors.white,
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
                                    percent:
                                        Valoracion.instanciar.mediaUsuario / 10,
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
    showFlash(
        duration: Duration(seconds: 3),
        context: context,
        builder: (context, controller) {
          return Flash.dialog(
            controller: controller,
            alignment: Alignment.topCenter,
            borderColor: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            backgroundColor: Colors.deepPurple,
            margin: EdgeInsets.only(top: 150.h),
            child: Container(
              width: ScreenUtil().setWidth(900),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Valoracion revelada",
                      style: GoogleFonts.lato(
                          fontSize: 55.sp, color: Colors.white),
                    ),
                    Icon(Icons.check_circle, color: Colors.green)
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: todo
    // TODO: implement build
    return ChangeNotifierProvider.value(
        value: Valoracion.instanciar,
        child: Consumer<Valoracion>(
          builder: (context, myType, child) {
            return Scaffold(
              backgroundColor: Colors.deepPurple,
              appBar: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Valoraciones"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("${Usuario.esteUsuario.creditosUsuario}"),
                        Icon(
                          xd.LineAwesomeIcons.coins,
                          color: Colors.white,
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
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedList(
                          key: ListaDeValoraciones.llaveListaValoraciones,
                          initialItemCount:
                              Valoracion.instanciar.listaDeValoraciones.length,
                          itemBuilder:
                              (BuildContext context, int indice, animation) {
                            return buildSlideTransition(
                                context,
                                animation,
                                indice,
                                Valoracion
                                    .instanciar.listaDeValoraciones[indice]);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget buildSlideTransition(BuildContext context, Animation animation,
      int indice, Valoracion valoracion) {
    return ValueListenableBuilder(
        valueListenable: valoracion.notificadorEliminacion,
        builder: (BuildContext context, bool valor, child) {
          if (valoracion.valoracionVisible == false) {
            valoracion.notificadorFinTiempo.close();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              valoracion.valoracionVisible = true;

              // Add Your Code here.
              eliimnarSolicitud(indice, valoracion.idValoracion, valoracion);
            });
          }
          return SizeTransition(
            sizeFactor: animation,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: ScreenUtil().setHeight(400),
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.grey, blurRadius: 10)
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.white),
                  child: Container(
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              flex: 4,
                              fit: FlexFit.tight,
                              child: GestureDetector(
                                  onTap: () {
                                    mostrarPerfilRemitente(context, valoracion);
                                  },
                                  child: fotoSolicitud(valoracion)),
                            ),
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
                                    if (EstadoConexionInternet
                                            .estadoConexion.conexion ==
                                        EstadoConexion.conectado) {
                                      if (Usuario.esteUsuario.creditosUsuario <
                                          200) {
                                        ManejadorErroresAplicacion
                                            .erroresInstancia
                                            .mostrarErrorCreditosInsuficientes(
                                                context);
                                      }
                                      if (Usuario.esteUsuario.creditosUsuario >=
                                          200) {
                                        valoracion.estadoRevelacion =
                                            RevelarValoracionEstado.revelando;
                                        Valoracion.instanciar.notifyListeners();
                                        await ControladorCreditos.instancia
                                            .restarCreditosValoracion(
                                                100, valoracion.idValoracion);
                                      }
                                    } else {
                                      ManejadorErroresAplicacion
                                          .erroresInstancia
                                          .mostrarErrorValoracion(context);
                                      valoracion.estadoRevelacion =
                                          RevelarValoracionEstado.noRevelada;
                                      Valoracion.instanciar.notifyListeners();
                                    }
                                  },
                                  child: RepaintBoundary(
                                    child: valoracion.estadoRevelacion ==
                                            RevelarValoracionEstado.revelando
                                        ? Container(
                                            height: 400.h,
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    "Revelando...",
                                                    style: GoogleFonts.lato(
                                                        color: Colors.white,
                                                        fontSize: 80.sp),
                                                  ),
                                                  Container(
                                                    height: 120.h,
                                                    width: 120.h,
                                                    child:
                                                        CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 400.h,
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                            ),
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  cuentaAtrasValoracion(
                                                      indice, valoracion),
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
        });
  }

  void mostrarPerfilRemitente(
      BuildContext context, Valoracion valoracion) async {
    DatosPerfiles perfilRemitente = valoracion.perfilRemitente;

    showDialog(
        useRootNavigator: false,
        useSafeArea: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            if (perfilRemitente == null) {
              for (int i = 0;
                  i < Valoracion.instanciar.listaDeValoraciones.length;
                  i++) {
                if (valoracion.idValoracion ==
                    Valoracion.instanciar.listaDeValoraciones[i].idValoracion) {
                  Perfiles.cargarIsolatePerfilDeterminado(valoracion.idEmisor)
                      .then((value) {
                    perfilRemitente = value.first;
                    Valoracion.instanciar.listaDeValoraciones[i]
                        .perfilRemitente = value.first;

                    setState(() {});
                  });
                }
              }
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    height: ScreenUtil.screenHeight,
                    width: ScreenUtil.screenWidth,
                    child: perfilRemitente != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Expanded(
                                  child: ListView(
                                    children: perfilRemitente.carrete,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    color: Colors.red,
                                    icon: Icon(Icons.cancel),
                                    iconSize: 160.sp,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                              ])
                        : Container(
                            height: 50.h,
                            width: 50.h,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                LoadingIndicator(
                                  colors: [
                                    Colors.white,
                                    Colors.purple,
                                    Colors.red
                                  ],
                                  indicatorType: Indicator.ballScaleMultiple,
                                ),
                                Text("Por favor, espere",
                                    style: GoogleFonts.lato(
                                        color: Colors.white, fontSize: 60.sp)),
                              ],
                            )),
                    color: Colors.transparent,
                  ),
                ),
              ),
            );
          });
        });
  }

  Flexible botonRevelarValoracion() {
    return Flexible(
      fit: FlexFit.tight,
      flex: 2,
      child: Container(
        color: Colors.deepPurple[900],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text(
              "Ver",
              style: TextStyle(fontSize: 50.sp, color: Colors.white),
            ),
            Row(
              children: [
                Text(
                  "${ControladorCreditos.precioValoracion}",
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
                ),
                Icon(
                  xd.LineAwesomeIcons.coins,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            xd.LineAwesomeIcons.clock,
            color: Colors.white,
            size: 120.sp,
          ),
          StreamBuilder(
            stream: valoracion.notificadorFinTiempo.stream,
            initialData: valoracion.segundosRestantes,
            builder: (BuildContext context, AsyncSnapshot<int> dato) {
              if (dato.data == 0 && valoracion.valoracionRevelada == false) {
                valoracion.notificadorFinTiempo.close().then((value) =>
                    eliimnarSolicitud(
                        indice, valoracion.idValoracion, valoracion));
              }
              if (valoracion.valoracionRevelada) {
                valoracion.notificadorFinTiempo.close();
              }

              return Container(
                  child: Text(
                      Valoracion.formatoTiempo
                          .format(DateTime(0, 0, 0, 0, 0, dato.data)),
                      style: GoogleFonts.lato(
                          fontSize: 90.sp, color: Colors.white)));
            },
          ),
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
                      decoration: BoxDecoration(color: Colors.deepPurple),
                      child: FlatButton(
                          onPressed: () {
                            if (EstadoConexionInternet
                                    .estadoConexion.conexion ==
                                EstadoConexion.conectado) {
                              aceptarSolicitud(
                                  indice,
                                  valoracion.mensaje,
                                  valoracion.nombreEmisor,
                                  valoracion.imagenEmisor,
                                  valoracion.idEmisor,
                                  valoracion.idValoracion,
                                  valoracion.imagenEmisor,
                                  valoracion.valoracion);
                            } else {
                              ManejadorErroresAplicacion.erroresInstancia
                                  .mostrarErrorValoracion(context);
                            }
                          },
                          child: Text(
                            "Si",
                            style: GoogleFonts.lato(
                                fontSize: 45.sp, color: Colors.white),
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
                            if (EstadoConexionInternet
                                    .estadoConexion.conexion ==
                                EstadoConexion.conectado) {
                              eliimnarSolicitud(
                                  indice,
                                  Valoracion.instanciar
                                      .listaDeValoraciones[indice].idValoracion,
                                  valoracion);
                            } else {
                              ManejadorErroresAplicacion.erroresInstancia
                                  .mostrarErrorValoracion(context);
                            }
                          },
                          child: Text(
                            "No",
                            style: GoogleFonts.lato(
                                fontSize: 45.sp, color: Colors.white),
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
                              
                                fontWeight: FontWeight.bold),
                          )
                        : Text(" ")),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 6,
                child: Container(
                  height: ScreenUtil().setHeight(40),
                  child: valoracion.valoracionRevelada
                      ? LinearPercentIndicator(
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          //  progressColor: Colors.deepPurple,
                          percent: valoracion.valoracion / 10,
                          animationDuration: 300,
                          lineHeight: ScreenUtil().setHeight(60),
                          linearGradient: LinearGradient(colors: [
                            Colors.deepPurple,
                            Colors.deepPurple[900]
                          ]),
                          center: Text(
                            "${(valoracion.valoracion).toStringAsFixed(1)}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil()
                                    .setSp(40, allowFontScalingSelf: true),
                                color: Colors.white),
                          ),
                        )
                      : Container(),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 4,
                child: Container(
                  child: Center(
                      child: Text(
                    "¿Enviar solicitud de chat?",
                    style: GoogleFonts.lato(fontSize: 40.sp),
                    overflow: TextOverflow.clip,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget fotoSolicitud(Valoracion valoracion) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(valoracion.imagenEmisor), fit: BoxFit.cover)),
    );
  }

  void eliimnarSolicitud(int index, String id, Valoracion valoracionEliminar) {
    Valoracion valoracionQuitada =
        Valoracion.instanciar.listaDeValoraciones.removeAt(index);

    if (!Valoracion.instanciar.listaDeValoraciones
        .contains(valoracionEliminar)) {
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
