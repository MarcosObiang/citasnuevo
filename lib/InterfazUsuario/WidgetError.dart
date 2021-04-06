import 'dart:ui';

import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/EstadoConexion.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ManejadorErroresAplicacion {
  static ManejadorErroresAplicacion erroresInstancia =
      new ManejadorErroresAplicacion();

  /// Aqui manejamos los errores de red
  void mostrarErrorConexion(BuildContext context) {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: Color.fromRGBO(200, 20, 20, 100),
            child: SafeArea(
              child: Container(
                height: ScreenUtil.defaultHeight.toDouble(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: ScreenUtil.defaultHeight.toDouble() / 9,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Error de conexión",
                                  style: GoogleFonts.lato(
                                      fontSize: 70.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Icon(
                                      LineAwesomeIcons.broadcast_tower,
                                      size: ScreenUtil().setSp(100),
                                    ),
                                    Icon(
                                      Icons.cancel,
                                      size: ScreenUtil().setSp(50),
                                      color: Colors.red,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 70.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Hotty no puede conectarse a internet. Comprueba tu conexion e intentelo de nuevo",
                              style: GoogleFonts.lato(
                                  fontSize: 50.sp, color: Colors.white),
                            ),
                          ),
                          Divider(
                            height: 70.h,
                          ),
                          Center(
                            child: RaisedButton(
                              color: Colors.deepPurple,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Entendido",
                                  style: GoogleFonts.lato(
                                      fontSize: 50.sp, color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void mostrarErrorIniciarSesion(BuildContext context) {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: Color.fromRGBO(200, 20, 20, 100),
            child: SafeArea(
              child: Container(
                height: ScreenUtil.defaultHeight.toDouble(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: ScreenUtil.defaultHeight.toDouble() / 9,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Error al iniciar sesion",
                                  style: GoogleFonts.lato(
                                      fontSize: 70.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Icon(
                                      LineAwesomeIcons.broadcast_tower,
                                      size: ScreenUtil().setSp(100),
                                    ),
                                    Icon(
                                      Icons.cancel,
                                      size: ScreenUtil().setSp(50),
                                      color: Colors.red,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 70.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Ha habido un error al intentar iniciar sesion con esta cuenta, inicie sesion con otra cuenta o pruebe mas tarde",
                              style: GoogleFonts.lato(
                                  fontSize: 50.sp, color: Colors.white),
                            ),
                          ),
                          Divider(
                            height: 70.h,
                          ),
                          Center(
                            child: RaisedButton(
                              color: Colors.deepPurple,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Entendido",
                                  style: GoogleFonts.lato(
                                      fontSize: 50.sp, color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void mostrarAdvertenciaBorrarCuenta(BuildContext context) {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: Color.fromRGBO(20, 20, 20, 100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: SafeArea(
                child: Container(
                  height: ScreenUtil.defaultHeight.toDouble(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: ScreenUtil.defaultHeight.toDouble() / 5,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Borrar cuenta",
                                    style: GoogleFonts.lato(
                                        fontSize: 70.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Icon(
                                        LineAwesomeIcons.broadcast_tower,
                                        size: ScreenUtil().setSp(100),
                                      ),
                                      Icon(
                                        Icons.cancel,
                                        size: ScreenUtil().setSp(50),
                                        color: Colors.red,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "¿Seguro que quieres eliminar tu cuenta?.",
                                style: GoogleFonts.lato(
                                    fontSize: 50.sp, color: Colors.white),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  RaisedButton(
                                    color: Colors.deepPurple,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("No",
                                        style: GoogleFonts.lato(
                                            fontSize: 50.sp,
                                            color: Colors.white)),
                                  ),
                                  RaisedButton(
                                    color: Colors.transparent,
                                    onPressed: () {
                                      Usuario.esteUsuario
                                          .eliminarUsuario()
                                          .then((eliminado) {
                                        if (eliminado) {
                                          Navigator.of(context).popUntil(
                                              (route) => route.isFirst);
                                        }
                                      });
                                    },
                                    child: Text("Si",
                                        style: GoogleFonts.lato(
                                            fontSize: 50.sp,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void mostrarNoSePuedeAbrirConversacion(BuildContext context) {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: Color.fromRGBO(20, 20, 20, 100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: SafeArea(
                child: Container(
                  height: ScreenUtil.defaultHeight.toDouble(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: ScreenUtil.defaultHeight.toDouble() / 5,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      flex: 7,
                                      fit: FlexFit.tight,
                                      child: Container(
                                          child: Text(
                                        "No se puede abrir la conversación",
                                        style: GoogleFonts.lato(
                                            fontSize: 70.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ))),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: Container(
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Icon(
                                            LineAwesomeIcons.envelope_open_text,
                                            size: ScreenUtil().setSp(100),
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.cancel,
                                            size: ScreenUtil().setSp(50),
                                            color: Colors.red,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Ha ocurrido un error al abrir la conversacion, compruebe su conexion a internet e intentelo de nuevo",
                                style: GoogleFonts.lato(
                                    fontSize: 50.sp, color: Colors.white),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  RaisedButton(
                                    color: Colors.transparent,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Entendido",
                                        style: GoogleFonts.lato(
                                            fontSize: 50.sp,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void mostrarDialogoPermisosVideollamada(BuildContext context,) {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: Color.fromRGBO(20, 20, 20, 100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: SafeArea(
                child: Container(
                  height: ScreenUtil.defaultHeight.toDouble(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: ScreenUtil.defaultHeight.toDouble() / 3,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      flex: 7,
                                      fit: FlexFit.tight,
                                      child: Container(
                                          child: Text(
                                        "No se puede iniciar la videollamada",
                                        style: GoogleFonts.lato(
                                            fontSize: 70.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ))),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: Container(
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Icon(
                                            Icons.videocam_off_rounded,
                                            size: ScreenUtil().setSp(100),
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.cancel,
                                            size: ScreenUtil().setSp(50),
                                            color: Colors.red,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Hotty necesita acceso al microfono y a la camara del dispositivo para iniciar la llamada.",
                                style: GoogleFonts.lato(
                                    fontSize: 50.sp, color: Colors.white),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Para que Hotty pueda usar la camara y el microfono, pulsa el botón de videollamada y acepta los permisos",
                                style: GoogleFonts.lato(
                                    fontSize: 50.sp, color: Colors.white),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                          
                            Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                 
                                  RaisedButton(
                                    
                                    color: Colors.deepPurple,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Atrás",
                                        style: GoogleFonts.lato(
                                            fontSize: 50.sp,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void mostrarDialogoPermisosVideollamadaContestar(BuildContext context,) {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: Color.fromRGBO(20, 20, 20, 100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: SafeArea(
                child: Container(
                  height: ScreenUtil.defaultHeight.toDouble(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: ScreenUtil.defaultHeight.toDouble() / 3,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      flex: 7,
                                      fit: FlexFit.tight,
                                      child: Container(
                                          child: Text(
                                        "No se puede contestar la videollamada",
                                        style: GoogleFonts.lato(
                                            fontSize: 70.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ))),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: Container(
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Icon(
                                            Icons.videocam_off_rounded,
                                            size: ScreenUtil().setSp(100),
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.cancel,
                                            size: ScreenUtil().setSp(50),
                                            color: Colors.red,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Hotty necesita acceso al microfono y a la camara del dispositivo para contestar la llamada.",
                                style: GoogleFonts.lato(
                                    fontSize: 50.sp, color: Colors.white),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Para que Hotty pueda usar la camara y el microfono, pulsa el botón para contestar y acepta los permisos",
                                style: GoogleFonts.lato(
                                    fontSize: 50.sp, color: Colors.white),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                          
                            Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                 
                                  RaisedButton(
                                    
                                    color: Colors.deepPurple,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Atrás",
                                        style: GoogleFonts.lato(
                                            fontSize: 50.sp,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }








  void mostrarErrorEnvioMensaje(BuildContext context0) {
    showGeneralDialog(
        context: context0,
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: Color.fromRGBO(20, 20, 20, 100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: SafeArea(
                child: Container(
                  height: ScreenUtil.defaultHeight.toDouble(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: ScreenUtil.defaultHeight.toDouble() / 5,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                        flex: 7,
                                        fit: FlexFit.tight,
                                        child: Container(
                                            child: Text(
                                          "Salir del registro de usuario",
                                          style: GoogleFonts.lato(
                                              fontSize: 70.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ))),
                                    Flexible(
                                        flex: 2,
                                        fit: FlexFit.tight,
                                        child: Icon(
                                          Icons.cancel_schedule_send,
                                          size: ScreenUtil().setSp(100),
                                          color: Colors.red,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "¿Quiere volver a la pantalla principal?",
                                style: GoogleFonts.lato(
                                    fontSize: 50.sp, color: Colors.white),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  RaisedButton(
                                    color: Colors.deepPurple,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Si",
                                        style: GoogleFonts.lato(
                                            fontSize: 50.sp,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void mostrarErrorCreditosInsuficientes(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Material(
                color: Color.fromRGBO(20, 20, 20, 100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: SafeArea(
                    child: Container(
                      height: ScreenUtil.defaultHeight.toDouble(),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: ScreenUtil.defaultHeight.toDouble() / 2,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                            flex: 7,
                                            fit: FlexFit.tight,
                                            child: Container(
                                                child: Text(
                                              "No tienes creditos suficientes",
                                              style: GoogleFonts.lato(
                                                  fontSize: 70.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ))),
                                        Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Icon(
                                              LineAwesomeIcons.coins,
                                              size: ScreenUtil().setSp(100),
                                              color: Colors.red,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 70.h,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Creditos insuficientes, debes esperar el tiempo restante para obtener tus creditos gratuitos",
                                    style: GoogleFonts.lato(
                                        fontSize: 50.sp, color: Colors.white),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 5,
                                      fit: FlexFit.tight,
                                      child: Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Tiempo restante para creditos gratuitos",
                                            style: GoogleFonts.lato(
                                                fontSize: 50.sp,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 3,
                                      fit: FlexFit.tight,
                                      child: Container(
                                        child: StreamBuilder<int>(
                                          stream: Usuario.esteUsuario
                                              .tiempoHastaRecompensa.stream,
                                          initialData: Usuario.esteUsuario
                                              .segundosRestantesRecompensa,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<int> dato) {
                                            if (Usuario.esteUsuario
                                                    .segundosRestantesRecompensa ==
                                                0) {}

                                            return Container(
                                                child: Text(
                                                    Valoracion.formatoTiempo
                                                        .format(DateTime(
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            dato.data)),
                                                    style: GoogleFonts.lato(
                                                        fontSize: 55.sp,
                                                        color: Colors.white)));
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  height: 70.h,
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Usuario.esteUsuario
                                                      .segundosRestantesRecompensa <=
                                                  0 &&
                                              ControladorCreditos.instancia
                                                      .estadoSolicitudCreditos !=
                                                  EstadoSolicitudCreditosGratuitos
                                                      .solicitando
                                          ? RaisedButton(
                                              color: ControladorCreditos
                                                          .instancia
                                                          .estadoSolicitudCreditos ==
                                                      EstadoSolicitudCreditosGratuitos
                                                          .solicitando
                                                  ? Colors.grey
                                                  : Colors.deepPurple,
                                              onPressed: () {
                                                Navigator.pop(context);

                                                setState(() {});
                                                if (EstadoConexionInternet
                                                        .estadoConexion
                                                        .conexion ==
                                                    EstadoConexion.conectado) {
                                                  ControladorCreditos.instancia
                                                          .estadoSolicitudCreditos =
                                                      EstadoSolicitudCreditosGratuitos
                                                          .solicitando;
                                                  ControladorNotificacion
                                                      .mostrarNotificacionEsperandoRespuestaRecompensa(
                                                          BaseAplicacion
                                                              .claveBase
                                                              .currentContext);
                                                  ControladorCreditos.instancia
                                                      .recompensaDiaria();
                                                } else {
                                                  ManejadorErroresAplicacion
                                                      .erroresInstancia
                                                      .mostrarErrorValoracion(
                                                          BaseAplicacion
                                                              .claveBase
                                                              .currentContext);
                                                }
                                              },
                                              child: Text(
                                                  "Obtener creditos gratuito",
                                                  style: GoogleFonts.lato(
                                                      fontSize: 50.sp,
                                                      color: Colors.white)),
                                            )
                                          : ControladorCreditos.instancia
                                                      .estadoSolicitudCreditos ==
                                                  EstadoSolicitudCreditosGratuitos
                                                      .solicitando
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(
                                                          "Solicitando creditos...",
                                                          style:
                                                              GoogleFonts.lato(
                                                                  fontSize:
                                                                      50.sp,
                                                                  color: Colors
                                                                      .white)),
                                                      CircularProgressIndicator(),
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                  height: 0,
                                                  width: 0,
                                                ),
                                      RaisedButton(
                                        color: Colors.deepPurple,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Conseguir creditos",
                                            style: GoogleFonts.lato(
                                                fontSize: 50.sp,
                                                color: Colors.white)),
                                      )
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 100.h,
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      RaisedButton(
                                        color: Colors.deepPurple,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Atras",
                                            style: GoogleFonts.lato(
                                                fontSize: 50.sp,
                                                color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  void mostrarErrorValoracion(BuildContext context) {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: Color.fromRGBO(20, 20, 20, 100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: SafeArea(
                child: Container(
                  height: ScreenUtil.defaultHeight.toDouble(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: ScreenUtil.defaultHeight.toDouble() / 5,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                        flex: 7,
                                        fit: FlexFit.tight,
                                        child: Container(
                                            child: Text(
                                          "Error de conexion",
                                          style: GoogleFonts.lato(
                                              fontSize: 70.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ))),
                                    Flexible(
                                        flex: 2,
                                        fit: FlexFit.tight,
                                        child: Icon(
                                          Icons.cancel_schedule_send,
                                          size: ScreenUtil().setSp(100),
                                          color: Colors.red,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Ha ocurrido un error, compruebe su conexión a internet e intenta más tarde",
                                style: GoogleFonts.lato(
                                    fontSize: 50.sp, color: Colors.white),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  RaisedButton(
                                    color: Colors.deepPurple,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Entendido",
                                        style: GoogleFonts.lato(
                                            fontSize: 50.sp,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void mostrarErrorNombreVacioRegistro(BuildContext context) {
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext context, _, __) {
          return Material(
            color: Color.fromRGBO(20, 20, 20, 100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: SafeArea(
                child: Container(
                  height: ScreenUtil.defaultHeight.toDouble(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: ScreenUtil.defaultHeight.toDouble() / 5,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                        flex: 7,
                                        fit: FlexFit.tight,
                                        child: Container(
                                            child: Text(
                                          "Error al introducir el nombre",
                                          style: GoogleFonts.lato(
                                              fontSize: 70.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ))),
                                    Flexible(
                                        flex: 2,
                                        fit: FlexFit.tight,
                                        child: Icon(
                                          Icons.cancel_schedule_send,
                                          size: ScreenUtil().setSp(100),
                                          color: Colors.red,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "-El campo nombre no puede estar vacio",
                                style: GoogleFonts.lato(
                                    fontSize: 50.sp, color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "-El campo nombre no puede contener numeros ni caracteres especiales",
                                style: GoogleFonts.lato(
                                    fontSize: 50.sp, color: Colors.white),
                              ),
                            ),
                            Divider(
                              height: 70.h,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  RaisedButton(
                                    color: Colors.deepPurple,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Entendido",
                                        style: GoogleFonts.lato(
                                            fontSize: 50.sp,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
