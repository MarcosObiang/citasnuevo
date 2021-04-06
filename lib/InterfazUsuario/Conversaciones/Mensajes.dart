import 'dart:io' as Io;

import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/TiempoAplicacion.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/PantallaConversacion.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:path_provider/path_provider.dart';

import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/cupertino.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:intl/intl.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';

import 'package:provider/provider.dart';

import 'dart:async';
import 'package:http/http.dart' as http;

class Mensajes extends StatefulWidget {
  String mensaje;
  String horaMensaje;
  DateTime horaMensajeFormatoDate;
  String idMensaje;
  String idEmisor;
  String tipoMensaje;
  String nombreEmisor;

  bool mensajeLeido;

  String idRemitente;

  bool leido = false;
  bool mensajeLeidoRemitente = false;
  String identificadorUnicoMensaje;
  String idConversacion;
  bool mostrarOpcionesMensaje = false;

  bool respuesta;
  Map<String, dynamic> respuestaMensaje = new Map();
  String nombreRemitente;
  Widget widgetRespuesta;
  int diaMensaje;
 

  int anioMesMensaje;
  int mesMensaje;

  Mensajes(
      {@required this.idMensaje,
      @required this.respuesta,
      @required this.horaMensajeFormatoDate,
      @required this.identificadorUnicoMensaje,
      @required this.respuestaMensaje,
      @required this.mensajeLeido,
      @required this.nombreEmisor,
      @required this.idEmisor,
      @required this.idConversacion,
      @required this.mensajeLeidoRemitente,
      @required this.mensaje,
      @required this.horaMensaje,
      @required this.tipoMensaje});
  Mensajes.audio(
      {@required this.idMensaje,
      @required this.mensajeLeido,
      @required this.identificadorUnicoMensaje,
      @required this.respuesta,
      @required this.respuestaMensaje,
      @required this.mensajeLeidoRemitente,
      @required this.idConversacion,
      @required this.nombreEmisor,
      @required this.idEmisor,
      @required this.mensaje,
      @required this.horaMensaje,
      @required this.tipoMensaje}) {
    // obtenerDuracionMensaje();
  }
  Mensajes.local(
      {@required this.idMensaje,
      @required this.idEmisor,
      @required this.mensaje,
      @required this.horaMensaje,
      @required this.tipoMensaje}) {
    if (tipoMensaje == "Audio") {
      //  obtenerDuracionMensaje();
    }
  }
  Mensajes.Localaudio(
      {@required this.idEmisor,
      @required this.horaMensaje,
      @required this.tipoMensaje});
  Mensajes.separadorHora({
    @required this.horaMensajeFormatoDate,
    @required this.horaMensaje,
    @required this.idEmisor,
  }) {
    this.tipoMensaje = "SeparadorHora";
  }

  @override
  _MensajesState createState() => _MensajesState();
}

class _MensajesState extends State<Mensajes> {
   final formatoFecha=DateFormat("yMEd");

  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Conversacion.conversaciones,
      child: Consumer<Conversacion>(
        builder: (BuildContext context, conversacion, Widget child) {
          return widget.idEmisor == Usuario.esteUsuario.idUsuario
              ? Column(
                  children: <Widget>[
                    widget.tipoMensaje == "Texto"
                        ? mensajeTextoUsuario()
                        : widget.tipoMensaje == "SeparadorHora"
                            ? separadorHoraUsuario()
                            : widget.tipoMensaje == "Imagen"
                                ? mensajeImagenUsuario(context)
                                : mensajeGifUsuario(context)
                  ],
                )
              : Column(
                  children: <Widget>[
                    widget.tipoMensaje == "Texto"
                        ? mensajeTextoRemitente()
                        : widget.tipoMensaje == "SeparadorHora"
                            ? separadorHoraRemitente()
                            : widget.tipoMensaje == "Imagen"
                                ? mensajeImagenRemitente(context)
                                : mensajeGifRemitente(context)
                  ],
                );
        },
      ),
    );
  }

  Align mensajeGifRemitente(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          if (widget.respuesta == false) {
            widget.mostrarOpcionesMensaje = true;
            setState(() {});
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.only(right: 50, left: 10, bottom: 20, top: 20),
          child: GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        VisorImagenesPerfiles(imagen: widget.mensaje))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.mostrarOpcionesMensaje
                    ? opcionesMensaje()
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.deepPurple,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        widget.respuesta
                            ? widget.widgetRespuesta
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                        Container(
                          height: 700.w,
                          width: 700.w,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(widget.mensaje,
                                    scale: 1, headers: {'accept': 'image/*'})),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text(
                      widget.horaMensaje,
                      style: GoogleFonts.lato(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Align mensajeImagenRemitente(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          if (!widget.respuesta) {
            widget.mostrarOpcionesMensaje = true;
            setState(() {});
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.only(right: 50, left: 10, bottom: 20, top: 20),
          child: GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        VisorImagenesPerfiles(imagen: widget.mensaje))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.mostrarOpcionesMensaje
                    ? opcionesMensaje()
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.deepPurple,
                  ),
                  child: Column(
                    children: [
                      widget.respuesta
                          ? widget.widgetRespuesta
                          : Container(
                              width: 0,
                              height: 0,
                            ),
                      Container(
                        height: 500.w,
                        width: 500.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                widget.mensaje,
                                scale: 1,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text(
                      widget.horaMensaje,
                      style: GoogleFonts.lato(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container separadorHoraRemitente() {
    return Container(
      child: Text(
        widget.diaMensaje ==
                    TiempoAplicacion
                        .tiempoAplicacion.marcaTiempoAplicacion.day &&
                widget.mesMensaje ==
                    TiempoAplicacion
                        .tiempoAplicacion.marcaTiempoAplicacion.month &&
                widget.anioMesMensaje ==
                    TiempoAplicacion.tiempoAplicacion.marcaTiempoAplicacion.year
            ? "Hoy"
            :formatoFecha.format(widget.horaMensajeFormatoDate),
        style: GoogleFonts.lato(color: Colors.white),
      ),
    );
  }

  Container mensajeTextoRemitente() {
    return Container(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onLongPress: () {
                if (!widget.respuesta) {
                  widget.mostrarOpcionesMensaje = true;
                  setState(() {});
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 50, left: 10, bottom: 20, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    widget.mostrarOpcionesMensaje
                        ? opcionesMensaje()
                        : Container(
                            height: 0,
                            width: 0,
                          ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15))),
                        padding: EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            widget.respuesta
                                ? widget.widgetRespuesta
                                : Container(
                                    width: 0,
                                    height: 0,
                                  ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.mensaje,
                                style: GoogleFonts.lato(color: Colors.white),
                              ),
                            ),
                          ],
                        )),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          child: Text(widget.horaMensaje,
                              style: GoogleFonts.lato(color: Colors.white)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Align mensajeGifUsuario(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onLongPress: () {
          if (widget.respuesta == false) {
            widget.mostrarOpcionesMensaje = true;
            setState(() {});
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.only(right: 10, left: 50, bottom: 20, top: 20),
          child: GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        VisorImagenesPerfiles(imagen: widget.mensaje))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                widget.mostrarOpcionesMensaje
                    ? opcionesMensaje()
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.deepPurple,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        widget.respuesta
                            ? widget.widgetRespuesta
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                        Container(
                          height: 700.w,
                          width: 700.w,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(widget.mensaje,
                                    scale: 1, headers: {'accept': 'image/*'})),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: Text(widget.horaMensaje,
                            style: GoogleFonts.lato(
                              color: Colors.white,
                            )),
                      ),
                      widget.mensajeLeidoRemitente
                          ? Icon(Icons.check_circle,
                              color: Colors.deepPurple[200])
                          : Container()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Align mensajeImagenUsuario(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onLongPress: () {
          if (widget.respuesta == false) {
            widget.mostrarOpcionesMensaje = true;
            setState(() {});
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.only(right: 10, left: 50, bottom: 20, top: 20),
          child: GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        VisorImagenesPerfiles(imagen: widget.mensaje))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                widget.mostrarOpcionesMensaje
                    ? opcionesMensaje()
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.deepPurple,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        widget.respuesta
                            ? widget.widgetRespuesta
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                        Container(
                          height: 700.w,
                          width: 700.w,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  widget.mensaje,
                                  scale: 1,
                                )),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: Text(widget.horaMensaje,
                            style: GoogleFonts.lato(color: Colors.white)),
                      ),
                      widget.mensajeLeidoRemitente
                          ? Icon(Icons.check_circle,
                              color: Colors.deepPurple[200])
                          : Container()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding opcionesMensaje() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: 600.w,
          height: 150.h,
          decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15))),
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      widget.mostrarOpcionesMensaje = false;
                      PantallaConversacion.responderMensaje = true;
                      PantallaConversacion.tipoMensaje = widget.tipoMensaje;
                      PantallaConversacion.idEmisorMensajeResponder =
                          widget.idEmisor;
                      PantallaConversacion.idMensajeResponder =
                          widget.identificadorUnicoMensaje;
                      PantallaConversacion.mensajeResponder = widget.mensaje;
                      PantallaConversacion.nombreEmisorMensajeResponder =
                          widget.nombreEmisor;
                      Conversacion.conversaciones.notifyListeners();
                    },
                    icon: Icon(
                      Icons.reply,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.mostrarOpcionesMensaje = false;
                      setState(() {});
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Cancelar"),
                      ),
                    ),
                  )
                ],
              ),
            ],
          )),
    );
  }

  Container separadorHoraUsuario() {
    return Container(
      child: Text(
        widget.diaMensaje ==
                    TiempoAplicacion
                        .tiempoAplicacion.marcaTiempoAplicacion.day &&
                widget.mesMensaje ==
                    TiempoAplicacion
                        .tiempoAplicacion.marcaTiempoAplicacion.month &&
                widget.anioMesMensaje ==
                    TiempoAplicacion.tiempoAplicacion.marcaTiempoAplicacion.year
            ? "Hoy":
           formatoFecha.format(widget.horaMensajeFormatoDate),
        style: GoogleFonts.lato(color: Colors.white),
      ),
    );
  }

  Align mensajeTextoUsuario() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onLongPress: () {
          if (widget.respuesta == false) {
            widget.mostrarOpcionesMensaje = true;
          }

          setState(() {});
        },
        child: Padding(
          padding:
              const EdgeInsets.only(right: 10, left: 50, bottom: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              widget.mostrarOpcionesMensaje
                  ? opcionesMensaje()
                  : Container(
                      height: 0,
                      width: 0,
                    ),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15))),
                  padding: EdgeInsets.all(5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        widget.respuesta
                            ? widget.widgetRespuesta
                            : Container(
                                width: 0,
                                height: 0,
                              ),
                        Container(
                          child: Text(
                            widget.mensaje,
                            style: GoogleFonts.lato(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        child: Text(
                      widget.horaMensaje,
                      style: GoogleFonts.lato(color: Colors.white),
                    )),
                    widget.mensajeLeidoRemitente
                        ? Icon(Icons.check_circle,
                            color: Colors.deepPurple[200])
                        : Container()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Padding cajaRespuestaMensajes() {
    Mensajes mensajeRespuestaAudio;
    if (widget.respuesta && widget.respuestaMensaje["tipoMensaje"] == "Audio") {
      for (int z = 0;
          z < Conversacion.conversaciones.listaDeConversaciones.length;
          z++) {
        if (Conversacion.conversaciones.listaDeConversaciones[z].idMensajes ==
            widget.idMensaje) {
          for (int i = 0;
              i <
                  Conversacion.conversaciones.listaDeConversaciones[z]
                      .ventanaChat.listadeMensajes.length;
              i++) {
            if (widget.respuestaMensaje["idMensaje"] ==
                Conversacion.conversaciones.listaDeConversaciones[z].ventanaChat
                    .listadeMensajes[i].identificadorUnicoMensaje) {
              mensajeRespuestaAudio = Conversacion.conversaciones
                  .listaDeConversaciones[z].ventanaChat.listadeMensajes[i];
            }
          }
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Container(
          decoration: BoxDecoration(
              color: widget.idEmisor == Usuario.esteUsuario.idUsuario
                  ? Colors.green
                  : Colors.blue,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15))),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.respuestaMensaje["idEmisorMensaje"] ==
                        Usuario.esteUsuario.idUsuario
                    ? Text("Yo")
                    : Text(PantallaConversacion.nombreExponer),
                widget.respuestaMensaje["tipoMensaje"] == "Texto"
                    ? Text(widget.respuestaMensaje["mensaje"])
                    : widget.respuestaMensaje["tipoMensaje"] == "Imagen"
                        ? Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    widget.respuestaMensaje["mensaje"],
                                    scale: 1,
                                  )),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.transparent,
                            ),
                            height: 500.w,
                            width: 500.w,
                          )
                        : widget.respuestaMensaje["tipoMensaje"] == "Gif"
                            ? Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          widget.respuestaMensaje["mensaje"],
                                          scale: 1,
                                          headers: {'accept': 'image/*'})),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Colors.transparent,
                                ),
                                height: 700.w,
                                width: 700.w,
                              )
                            : Container()
              ],
            ),
          )),
    );
  }
}

class DialogoGrabacion extends StatefulWidget {
  final Function pararGrabacion;
  DialogoGrabacion({@required this.pararGrabacion});
  @override
  _DialogoGrabacionState createState() => _DialogoGrabacionState();
}

class _DialogoGrabacionState extends State<DialogoGrabacion>
    with SingleTickerProviderStateMixin {
  AnimationController _animacionMicrofono;
  Animation animacion;

  Stopwatch cronometro = new Stopwatch();
  String mostradorCronometro = "00:00";
  bool grabando = false;
  bool parar = false;
  int duracionAudio;
  void initState() {
    _animacionMicrofono =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animacionMicrofono.repeat(reverse: true);
    animacion =
        Tween<double>(begin: 5.0, end: 40.0).animate(_animacionMicrofono)
          ..addListener(() {
            setState(() {});
          });
    super.initState();
  }

  void iniciarContador() {
    if (!grabando) {
      grabando = true;
      cronometro.start();
    }
    Timer(Duration(microseconds: 1), seguirContando);
  }

  void seguirContando() {
    if (cronometro.isRunning && grabando) {
      iniciarContador();
    }

    mostradorCronometro =
        cronometro.elapsed.inMinutes.toString().padLeft(2, "0") +
            ":" +
            cronometro.elapsed.inSeconds.toString().padLeft(2, "0");
    duracionAudio = cronometro.elapsedMilliseconds;
  }

  void pararCronometro() {
    if (grabando) {
      cronometro.stop();
      cronometro.reset();

      grabando = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    iniciarContador();
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: ScreenUtil().setHeight(900),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color.fromRGBO(20, 20, 20, 50),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Text("Grabando",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenUtil().setSp(70))),
                      ),
                    ),
                    Divider(
                      height: ScreenUtil().setHeight(50),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RepaintBoundary(
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.blue,
                                    spreadRadius:
                                        ScreenUtil().setSp(animacion.value),
                                    blurRadius:
                                        ScreenUtil().setSp(animacion.value))
                              ]),
                          child: TweenAnimationBuilder(
                              tween: Tween<double>(
                                  begin: ScreenUtil().setSp(0),
                                  end: ScreenUtil().setSp(250)),
                              duration: Duration(milliseconds: 250),
                              builder: (BuildContext context, double valor,
                                  Widget child) {
                                return Icon(
                                  LineAwesomeIcons.microphone,
                                  size: valor,
                                  color: Colors.yellow,
                                );
                              }),
                        ),
                      ),
                    ),
                    Divider(
                      height: ScreenUtil().setHeight(50),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: ScreenUtil().setHeight(100),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: ScreenUtil().setHeight(50),
                                width: ScreenUtil().setWidth(50),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              RepaintBoundary(
                                child: Text(
                                  mostradorCronometro,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: ScreenUtil().setHeight(30),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.transparent),
                          child: FlatButton(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Descartar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Icon(
                                    LineAwesomeIcons.trash,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                              onPressed: () {
                                _animacionMicrofono.stop();
                                Navigator.of(context).pop();
                                pararCronometro();
                                widget.pararGrabacion(false, duracionAudio);
                              }),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.green),
                          child: FlatButton(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Enviar"),
                                  Icon(LineAwesomeIcons.send)
                                ],
                              ),
                              onPressed: () {
                                _animacionMicrofono.stop();
                                Navigator.of(context).pop();
                                pararCronometro();
                                widget.pararGrabacion(true, duracionAudio);
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VisorImagenesPerfiles extends StatelessWidget {
  String imagen;
  VisorImagenesPerfiles({@required this.imagen});
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Container(
            color: Colors.white,
            child: LayoutBuilder(builder: (
              BuildContext context,
              BoxConstraints limites,
            ) {
              return Stack(
                children: [
                  InteractiveViewer(
                    child: Container(
                      height: limites.biggest.height,
                      width: limites.biggest.width,
                      color: Colors.black,
                      child: Image.network(imagen),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                                focalRadius: 50.w,
                                radius: 2.w,
                                colors: [
                                  Colors.deepPurple,
                                  Colors.transparent
                                ]),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context))),
                    ),
                  ),
                ],
              );
            })),
      ),
    );
  }
}
