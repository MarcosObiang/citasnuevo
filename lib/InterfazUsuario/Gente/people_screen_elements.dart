import 'dart:convert';
import 'dart:io' as Io;
import 'dart:math';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Directo/live_screen_elements.dart';
import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import 'package:intl/intl.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:ocarina/ocarina.dart';

class Mensajes extends StatefulWidget {
  String mensaje;
  DateTime horaMensaje;
  String idMensaje;
  String idEmisor;
  String tipoMensaje;
  int duracionMensaje = 0;
  double posicion = 0;
  final Key clave = GlobalKey();
  String idRemitente;
  static bool reproduciendoOtro = false;
  bool reproduciendo;
  AudioPlayer player = AudioPlayer();
  static List<Mensajes> mensajesEnReproduccion = new List();
  static AudioPlayerState estado;
  static bool turno;
  String directorioAudio;
  double prueba = 0;
  bool cargandoAudio = false;

  String directoriofinal;

  final f = new DateFormat('HH:mm');
  final dia = new DateFormat("yMMMMEEEEd");

  void cargarAudio() async {
    if (player == null) {
      print("vacioestaaaaaaaas");
    }
    Uint8List Audio;
    var response = await http.readBytes(mensaje);

    Audio = response;

    final directorio = await getApplicationDocumentsDirectory();

    directorioAudio = "${directorio.path}/${DateTime.now()}";
    await Io.Directory(directorioAudio)
        .create(recursive: true)
        .then((valor) async {
      print(valor.path);
      directoriofinal = "${valor.path}/${DateTime.now()}.aac";
      Io.File puntero = new Io.File(directoriofinal);
      puntero.writeAsBytesSync(Audio, mode: FileMode.write, flush: true);
      print("${valor.path}.aac");
    });
  }

  obtenerDuracionMensaje() async {
    cargandoAudio = true;
    Conversacion.conversaciones.notifyListeners();
    print("obteniendo duracion");
    if (mensaje != null) {
      int status = await player.setUrl(mensaje);
      print(
          " este es el estatus de la operacion $status ********************************************");
      if (player != null && status == 1) {
        duracionMensaje = await Future.delayed(
            Duration(milliseconds: 2000), () => player.getDuration());
        if (duracionMensaje < 0) {
          await player.setUrl(mensaje);
          duracionMensaje = await Future.delayed(
              Duration(milliseconds: 2000), () => player.getDuration());
        }
      }
      Conversacion.conversaciones.notifyListeners();
      cargandoAudio = false;
      print("$duracionMensaje este mensaje dura muuuuuuuuuuucho");
    }
  }

  reproducirAudio() async {
    player.state = estado;

    await player.setUrl(mensaje);
    if (mensajesEnReproduccion.length != 0 && mensajesEnReproduccion != null) {
      mensajesEnReproduccion[0].pararAudio();
      mensajesEnReproduccion.clear();
    }

    mensajesEnReproduccion.add(this);

    if (duracionMensaje == null) {
      duracionMensaje = await Future.delayed(
          Duration(milliseconds: 2), () => player.getDuration());
      print(duracionMensaje);
    }
    print(duracionMensaje);
    player.play(mensaje);

    player.onAudioPositionChanged.listen((Duration p) {
      posicion = ((p.inMilliseconds / duracionMensaje) * 0.1 * 10);
      print("${p.inMilliseconds} de ${duracionMensaje}    esto es lo que dura");
      Conversacion.conversaciones.notifyListeners();
      print(posicion);
    });

    player.onPlayerCompletion.listen((event) {
      posicion = 0;
    });
    player.onPlayerStateChanged.listen((AudioPlayerState s) {
      print('Current player state: $s');
    });
  }

  void pararAudio() {
    player.stop();
  }

  void pausarAudio() {
    player.pause();
  }

  void resumirAudio() {
    player.resume();
  }

  void posicionAudio(double valor) {
    Duration duracion = Duration(milliseconds: valor.toInt());
    //Conversacion.conversaciones.notifyListeners();
    player.seek(duracion);
  }

  Mensajes(
      {@required this.idMensaje,
      @required this.idEmisor,
      @required this.mensaje,
      @required this.horaMensaje,
      @required this.tipoMensaje});
  Mensajes.Audio(
      {@required this.idMensaje,
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
      obtenerDuracionMensaje();
    }
  }
  Mensajes.Localaudio(
      {@required this.idEmisor,
      @required this.horaMensaje,
      @required this.tipoMensaje});
  Mensajes.separadorHora({
    @required this.horaMensaje,
    @required this.idEmisor,
  }) {
    this.tipoMensaje = "SeparadorHora";
  }

  @override
  _MensajesState createState() => _MensajesState();
}

class _MensajesState extends State<Mensajes> {
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Conversacion.conversaciones,
      child: Consumer<Conversacion>(
        builder: (BuildContext context, conversacion, Widget child) {
          widget.prueba += 0.000001;
          // print("**************************************************************************************${widget.posicion}");
          return widget.idEmisor == Usuario.esteUsuario.idUsuario
              ? Column(
                  children: <Widget>[
                    widget.tipoMensaje == "Audio"
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 10, left: 50, bottom: 20, top: 20),
                              child: Container(
                                height: ScreenUtil().setHeight(450),
                                width: ScreenUtil().setWidth(900),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        color: Colors.blue,
                                        child: widget.duracionMensaje == null ||
                                                widget.duracionMensaje <= 0
                                            ? Row(
                                                children: <Widget>[
                                                  Container(
                                                    child: Center(
                                                      child: FlatButton(
                                                        onPressed: () {
                                                          widget
                                                              .obtenerDuracionMensaje();
                                                        },
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.play_arrow,
                                                          size: ScreenUtil()
                                                              .setSp(150),
                                                        )),
                                                      ),
                                                    ),
                                                  ),
                                                  widget.cargandoAudio
                                                      ? Container(
                                                          height: ScreenUtil()
                                                              .setHeight(100),
                                                          width: ScreenUtil()
                                                              .setWidth(100),
                                                          child:
                                                              CircularProgressIndicator(),
                                                        )
                                                      : Container(
                                                          child: Text(
                                                              "Reproducir Audio"))
                                                ],
                                              )
                                            : Row(
                                                children: <Widget>[
                                                  Flexible(
                                                    fit: FlexFit.tight,
                                                    flex: 3,
                                                    child: Container(
                                                      child: Center(
                                                        child: FlatButton(
                                                          onPressed: () {
                                                            widget
                                                                .reproducirAudio();
                                                          },
                                                          child: Center(
                                                              child: Icon(
                                                            Icons.play_arrow,
                                                            size: ScreenUtil()
                                                                .setSp(150),
                                                          )),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.tight,
                                                    flex: 11,
                                                    child: Container(
                                                      child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          15.0,
                                                                      right:
                                                                          15),
                                                              child:
                                                                  LinearPercentIndicator(
                                                                lineHeight:
                                                                    ScreenUtil()
                                                                        .setHeight(
                                                                            70),
                                                                percent: widget
                                                                    .posicion,
                                                              ),
                                                            ),
                                                            SliderTheme(
                                                              data:
                                                                  SliderThemeData(
                                                                thumbColor: Colors
                                                                    .transparent,
                                                                activeTickMarkColor:
                                                                    Colors
                                                                        .transparent,
                                                                activeTrackColor:
                                                                    Colors
                                                                        .transparent,
                                                                disabledActiveTickMarkColor:
                                                                    Colors
                                                                        .transparent,
                                                                disabledActiveTrackColor:
                                                                    Colors
                                                                        .transparent,
                                                                disabledInactiveTickMarkColor:
                                                                    Colors
                                                                        .transparent,
                                                                disabledInactiveTrackColor:
                                                                    Colors
                                                                        .transparent,
                                                                disabledThumbColor:
                                                                    Colors
                                                                        .transparent,
                                                                inactiveTickMarkColor:
                                                                    Colors
                                                                        .transparent,
                                                                inactiveTrackColor:
                                                                    Colors
                                                                        .transparent,
                                                                overlappingShapeStrokeColor:
                                                                    Colors
                                                                        .transparent,
                                                                overlayColor: Colors
                                                                    .transparent,
                                                                valueIndicatorColor:
                                                                    Colors
                                                                        .transparent,
                                                              ),
                                                              child: Slider(
                                                                value: widget
                                                                    .posicion,
                                                                max: widget
                                                                    .duracionMensaje
                                                                    .toDouble(),
                                                                min: 0,
                                                                onChanged:
                                                                    (val) {
                                                                  widget
                                                                      .posicionAudio(
                                                                          val);
                                                                },
                                                              ),
                                                            ),
                                                          ]),
                                                    ),
                                                  )
                                                ],
                                              ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          child: Text(
                                              widget.f
                                                  .format(widget.horaMensaje),
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(50))),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : widget.tipoMensaje == "Texto"
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10, left: 50, bottom: 20, top: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                          color: Colors.blue,
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            widget.mensaje,
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(50)),
                                          )),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          child: Text(
                                              widget.f
                                                  .format(widget.horaMensaje),
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(50))),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : widget.tipoMensaje == "SeparadorHora"
                                ? Container(
                                    child: Text(widget.horaMensaje.day ==
                                            DateTime.now().day
                                        ? "Hoy"
                                        : widget.dia
                                            .format(widget.horaMensaje)),
                                  )
                                : Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10,
                                          left: 50,
                                          bottom: 20,
                                          top: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              color: Colors.transparent,
                                            ),
                                            height:
                                                ScreenUtil().setHeight(1200),
                                            width: ScreenUtil().setWidth(900),
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                child: CachedNetworkImage(
                                                  imageUrl: widget.mensaje,
                                                  progressIndicatorBuilder:
                                                      (context, url,
                                                              downloadProgress) =>
                                                          Center(
                                                    child: Container(
                                                      height: ScreenUtil()
                                                          .setHeight(300),
                                                      width: ScreenUtil()
                                                          .setWidth(300),
                                                      child: CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                )),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              child: Text(
                                                  widget.f.format(
                                                      widget.horaMensaje),
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(50))),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                  ],
                )
              : Column(
                  children: <Widget>[
                    widget.tipoMensaje == "Audio"
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 50, left: 10, bottom: 20, top: 20),
                              child: Container(
                                height: ScreenUtil().setHeight(450),
                                width: ScreenUtil().setWidth(900),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        color: Colors.green,
                                        child: widget.duracionMensaje == null ||
                                                widget.duracionMensaje <= 0
                                            ? Row(
                                                children: <Widget>[
                                                  Container(
                                                    child: Center(
                                                      child: FlatButton(
                                                        onPressed: () {
                                                          widget
                                                              .obtenerDuracionMensaje();
                                                        },
                                                        child: Center(
                                                            child: Icon(
                                                          Icons.play_arrow,
                                                          size: ScreenUtil()
                                                              .setSp(150),
                                                        )),
                                                      ),
                                                    ),
                                                  ),
                                                  widget.cargandoAudio
                                                      ? Container(
                                                          height: ScreenUtil()
                                                              .setHeight(100),
                                                          width: ScreenUtil()
                                                              .setWidth(100),
                                                          child:
                                                              CircularProgressIndicator(),
                                                        )
                                                      : Container(
                                                          child: Text(
                                                              "Reproducir Audio"))
                                                ],
                                              )
                                            : Row(
                                                children: <Widget>[
                                                  Flexible(
                                                    fit: FlexFit.tight,
                                                    flex: 3,
                                                    child: Container(
                                                      child: Center(
                                                        child: FlatButton(
                                                          onPressed: () {
                                                            widget
                                                                .reproducirAudio();
                                                          },
                                                          child: Center(
                                                              child: Icon(
                                                            Icons.play_arrow,
                                                            size: ScreenUtil()
                                                                .setSp(150),
                                                          )),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.tight,
                                                    flex: 11,
                                                    child: Container(
                                                      child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          15.0,
                                                                      right:
                                                                          15),
                                                              child:
                                                                  LinearPercentIndicator(
                                                                lineHeight:
                                                                    ScreenUtil()
                                                                        .setHeight(
                                                                            70),
                                                                percent: widget
                                                                    .posicion,
                                                              ),
                                                            ),
                                                            SliderTheme(
                                                              data:
                                                                  SliderThemeData(
                                                                thumbColor: Colors
                                                                    .transparent,
                                                                activeTickMarkColor:
                                                                    Colors
                                                                        .transparent,
                                                                activeTrackColor:
                                                                    Colors
                                                                        .transparent,
                                                                disabledActiveTickMarkColor:
                                                                    Colors
                                                                        .transparent,
                                                                disabledActiveTrackColor:
                                                                    Colors
                                                                        .transparent,
                                                                disabledInactiveTickMarkColor:
                                                                    Colors
                                                                        .transparent,
                                                                disabledInactiveTrackColor:
                                                                    Colors
                                                                        .transparent,
                                                                disabledThumbColor:
                                                                    Colors
                                                                        .transparent,
                                                                inactiveTickMarkColor:
                                                                    Colors
                                                                        .transparent,
                                                                inactiveTrackColor:
                                                                    Colors
                                                                        .transparent,
                                                                overlappingShapeStrokeColor:
                                                                    Colors
                                                                        .transparent,
                                                                overlayColor: Colors
                                                                    .transparent,
                                                                valueIndicatorColor:
                                                                    Colors
                                                                        .transparent,
                                                              ),
                                                              child: Slider(
                                                                value: widget
                                                                    .posicion,
                                                                max: widget
                                                                        .duracionMensaje
                                                                        .toDouble() ??
                                                                    0,
                                                                min: 0,
                                                                onChanged:
                                                                    (val) {
                                                                  widget
                                                                      .posicionAudio(
                                                                          val);
                                                                },
                                                              ),
                                                            ),
                                                          ]),
                                                    ),
                                                  )
                                                ],
                                              ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          child: Text(
                                              widget.f
                                                  .format(widget.horaMensaje),
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(50))),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : widget.tipoMensaje == "Texto"
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 50, left: 10, bottom: 20, top: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          color: Colors.green,
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            widget.mensaje,
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(50)),
                                          )),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          child: Text(
                                              widget.f
                                                  .format(widget.horaMensaje),
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(50))),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : widget.tipoMensaje == "SeparadorHora"
                                ? Container(
                                    child: Text(widget.horaMensaje.day ==
                                            DateTime.now().day
                                        ? "Hoy"
                                        : widget.dia
                                            .format(widget.horaMensaje)),
                                  )
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 50,
                                          left: 10,
                                          bottom: 20,
                                          top: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              color: Colors.transparent,
                                            ),
                                            height:
                                                ScreenUtil().setHeight(1200),
                                            width: ScreenUtil().setWidth(900),
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                child: CachedNetworkImage(
                                                  imageUrl: widget.mensaje,
                                                  progressIndicatorBuilder:
                                                      (context, url,
                                                              downloadProgress) =>
                                                          Center(
                                                    child: Container(
                                                      height: ScreenUtil()
                                                          .setHeight(300),
                                                      width: ScreenUtil()
                                                          .setWidth(300),
                                                      child: CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                )),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              child: Text(
                                                  widget.f.format(
                                                      widget.horaMensaje),
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(50))),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                  ],
                );
        },
      ),
    );
  }
}

class TituloChat extends StatefulWidget {
  List<Mensajes> listadeMensajes = new List();
  String idRemitente;
  String idConversacion;
  String estadoConversacion;
  String imagen;
  String nombre;
  String ultimoMensaje;
  String mensajeId;
  Firestore baseDatosRef = Firestore.instance;
  Conversacion conversacion;

  TituloChat(
      {@required this.conversacion,
      @required this.idConversacion,
      @required this.estadoConversacion,
      @required this.idRemitente,
      @required this.listadeMensajes,
      @required this.nombre,
      @required this.imagen,
      this.mensajeId});

  Future<List<Mensajes>> obtenerMensajes(
      String identificadorMensajes, String rutaRemitente) async {
    List<Mensajes> temp = new List();

    await baseDatosRef
        .collection("usuarios")
        .document(rutaRemitente)
        .collection("mensajes")
        .where("idMensaje", isEqualTo: identificadorMensajes)
        .limit(100)
        .getDocuments()
        .then((dato) async {
          if(dato!=null){
      print("${dato.documents.length} mensajes para el en firebase");
      print(rutaRemitente);
      print(identificadorMensajes);
      for (int a = 0; a < dato.documents.length; a++) {
        print(dato.documents[a].data["Tipo Mensaje"]);
        if (dato.documents[a].data["Tipo Mensaje"] == "Texto" ||
            dato.documents[a].data["Tipo Mensaje"] == "Imagen") {
          Mensajes mensaje = new Mensajes(
            idEmisor: dato.documents[a].data["idEmisor"],
            mensaje: dato.documents[a].data["Mensaje"],
            idMensaje: dato.documents[a].data["idMensaje"],
            horaMensaje: (dato.documents[a].data["Hora mensaje"]).toDate(),
            tipoMensaje: dato.documents[a].data["Tipo Mensaje"],
          );
          temp = List.from(temp)..add(mensaje);
        }
        if (dato.documents[a].data["Tipo Mensaje"] == "Audio") {
          Mensajes mensaje = new Mensajes.Audio(
            idEmisor: dato.documents[a].data["idEmisor"],
            mensaje: dato.documents[a].data["Mensaje"],
            idMensaje: dato.documents[a].data["idMensaje"],
            horaMensaje: (dato.documents[a].data["Hora mensaje"]).toDate(),
            tipoMensaje: dato.documents[a].data["Tipo Mensaje"],
          );

          temp = List.from(temp)..add(mensaje);
        }
      }}
    }).then((val) async {
      await baseDatosRef
          .collection("usuarios")
          .document(Usuario.esteUsuario.idUsuario)
          .collection("mensajes")
          .where("idMensaje", isEqualTo: identificadorMensajes)
          .limit(100)
          .getDocuments(source: Source.serverAndCache)
          .then((dato) 
          
          async {
            if(dato!=null){
        for (int a = 0; a < dato.documents.length; a++) {
          if (dato.documents[a].data["Tipo Mensaje"] == "Texto" ||
              dato.documents[a].data["Tipo Mensaje"] == "Imagen") {
            Mensajes mensaje = new Mensajes(
              idEmisor: dato.documents[a].data["idEmisor"],
              mensaje: dato.documents[a].data["Mensaje"],
              idMensaje: dato.documents[a].data["idMensaje"],
              horaMensaje: (dato.documents[a].data["Hora mensaje"]).toDate(),
              tipoMensaje: dato.documents[a].data["Tipo Mensaje"],
            );

            temp = List.from(temp)..add(mensaje);
          }
          if (dato.documents[a].data["Tipo Mensaje"] == "Audio") {
            Mensajes mensaje = new Mensajes.Audio(
              idEmisor: dato.documents[a].data["idEmisor"],
              mensaje: dato.documents[a].data["Mensaje"],
              idMensaje: dato.documents[a].data["idMensaje"],
              horaMensaje: (dato.documents[a].data["Hora mensaje"]).toDate(),
              tipoMensaje: dato.documents[a].data["Tipo Mensaje"],
            );

            temp = List.from(temp)..add(mensaje);
          }
        }}
      });
    });
    temp = await insertarHoras(temp);
    return temp;
  }

  List<Mensajes> insertarHoras(List<Mensajes> datos) {
    List<Mensajes> lista = datos;
    if (lista != null) {
      print("ordenado");
      lista.sort((b, c) => b.horaMensaje.compareTo(c.horaMensaje));
    }

    DateTime cacheTiempo = lista[0].horaMensaje;
    int cacheDia = lista[0].horaMensaje.day;
    Mensajes horaSeparador;

    horaSeparador = Mensajes.separadorHora(
      horaMensaje: cacheTiempo,
      idEmisor: lista[0].idEmisor,
    );
    lista.insert(0, horaSeparador);
    for (int i = 0; i < lista.length; i++) {
      if (cacheDia != lista[i].horaMensaje.day) {
        horaSeparador = Mensajes.separadorHora(
          horaMensaje: lista[i].horaMensaje,
          idEmisor: lista[i].idEmisor,
        );

        cacheTiempo = lista[i].horaMensaje;
        cacheDia = lista[i].horaMensaje.day;
        lista.insert(i, horaSeparador);
      }
    }
    return lista;
  }

  String crearCodigo() {
    List<String> letras = [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    ];
    List<String> numero = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
    var random = Random();
    int primeraLetra = random.nextInt(26);
    String codigo_final = letras[primeraLetra];

    for (int i = 0; i <= 20; i++) {
      int selector_aleatorio_num_letra = random.nextInt(20);
      int aleatorio_letra = random.nextInt(27);
      int aleatorio_numero = random.nextInt(9);
      if (selector_aleatorio_num_letra <= 2) {
        selector_aleatorio_num_letra = 2;
      }
      if (selector_aleatorio_num_letra % 2 == 0) {
        codigo_final = "${codigo_final}${(numero[aleatorio_numero])}";
      }
      if (aleatorio_letra % 3 == 0) {
        int mayuscula = random.nextInt(9);
        if (selector_aleatorio_num_letra <= 2) {
          int suerte = random.nextInt(2);
          suerte == 0
              ? selector_aleatorio_num_letra = 3
              : selector_aleatorio_num_letra = 2;
        }
        if (mayuscula % 2 == 0) {
          codigo_final =
              "${codigo_final}${(letras[aleatorio_letra]).toUpperCase()}";
        }
        if (mayuscula % 3 == 0) {
          codigo_final =
              "${codigo_final}${(letras[aleatorio_letra]).toLowerCase()}";
        }
      }
    }
    return codigo_final;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TituloChatState(imagen, nombre, ultimoMensaje);
  }

  void enviarMensaje(String mensajeTexto, String idMensaje) {
    if (mensajeTexto != null) {
      Map<String, dynamic> mensaje = Map();
      DateTime horaMensaje = DateTime.now();
      mensaje["Hora mensaje"] = horaMensaje;
      mensaje["Mensaje"] = mensajeTexto;
      mensaje["idMensaje"] = idMensaje;
      mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
      mensaje["Tipo Mensaje"] = "Texto";
      print(idRemitente);
      baseDatosRef
          .collection("usuarios")
          .document(idRemitente)
          .collection("mensajes")
          .document()
          .setData(mensaje);
      Mensajes nuevo = new Mensajes.local(
        horaMensaje: horaMensaje,
        idEmisor: Usuario.esteUsuario.idUsuario,
        mensaje: mensajeTexto,
        tipoMensaje: "Texto",
      );
      listadeMensajes = List.from(listadeMensajes)..add(nuevo);
      Conversacion.conversaciones.notifyListeners();
    }
  }

  void enviarMensajeAudio(Uint8List audio, String idMensaje) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    String ruta = "${idRemitente}/Perfil/NotasVoz/${crearCodigo()}.aac";
    StorageReference referenciaArchivo = reference.child(ruta);

    StorageUploadTask task = referenciaArchivo.putData(audio);
    var url = await (await task.onComplete).ref.getDownloadURL();
    if (audio != null) {
      Map<String, dynamic> mensaje = Map();
      DateTime horaMensaje = DateTime.now();
      mensaje["Hora mensaje"] = horaMensaje;
      mensaje["Mensaje"] = url;
      mensaje["idMensaje"] = idMensaje;
      mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
      mensaje["Tipo Mensaje"] = "Audio";
      print(idRemitente);
      baseDatosRef
          .collection("usuarios")
          .document(idRemitente)
          .collection("mensajes")
          .document()
          .setData(mensaje);
      Mensajes nuevo = new Mensajes.local(
        mensaje: url,
        idMensaje: idMensaje,
        horaMensaje: horaMensaje,
        idEmisor: Usuario.esteUsuario.idUsuario,
        tipoMensaje: "Audio",
      );
      listadeMensajes = List.from(listadeMensajes)..add(nuevo);
      Conversacion.conversaciones.notifyListeners();
    }
  }

  void enviarMensajeImagen(File imagen, String idMensaje) async {
    if (imagen != null) {
      FirebaseStorage storage = FirebaseStorage.instance;
      StorageReference reference = storage.ref();
      String ruta =
          "${idRemitente}/Perfil/ImagenesConversaciones/${crearCodigo()}.jpg";
      StorageReference referenciaArchivo = reference.child(ruta);

      StorageUploadTask task = referenciaArchivo.putFile(imagen);
      var url = await (await task.onComplete).ref.getDownloadURL();
      if (imagen != null) {
        Map<String, dynamic> mensaje = Map();
        DateTime horaMensaje = DateTime.now();
        mensaje["Hora mensaje"] = horaMensaje;
        mensaje["Mensaje"] = url;
        mensaje["idMensaje"] = idMensaje;
        mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
        mensaje["Tipo Mensaje"] = "Imagen";
        print(idRemitente);
        baseDatosRef
            .collection("usuarios")
            .document(idRemitente)
            .collection("mensajes")
            .document()
            .setData(mensaje);
        Mensajes nuevo = new Mensajes.local(
          mensaje: url,
          idMensaje: idMensaje,
          horaMensaje: horaMensaje,
          idEmisor: Usuario.esteUsuario.idUsuario,
          tipoMensaje: "Imagen",
        );
        listadeMensajes = List.from(listadeMensajes)..add(nuevo);
        Conversacion.conversaciones.notifyListeners();
      }
    }
  }

  void actualizarEstadoConversacion(bool estaEscribiendo) {
    if (estaEscribiendo) {
      print("Esta escribiendo");
      Map<String, dynamic> estadoConexionUsuario = Map();
      estadoConexionUsuario["Escribiendo"] = true;
      estadoConexionUsuario["Conectado"] = true;
      estadoConexionUsuario["IdConversacion"] = idConversacion;
      estadoConexionUsuario["Hora Conexion"] = DateTime.now();
      baseDatosRef
          .collection("usuarios")
          .document(idRemitente)
          .collection("estados conversacion")
          .document(idConversacion)
          .updateData(estadoConexionUsuario);
    }
    if (!estaEscribiendo) {
      print("No esta escribiendo");
      Map<String, dynamic> estadoConexionUsuario = Map();
      estadoConexionUsuario["Escribiendo"] = false;
      estadoConexionUsuario["Conectado"] = true;
      estadoConexionUsuario["IdConversacion"] = idConversacion;
      estadoConexionUsuario["Hora Conexion"] = DateTime.now();
      baseDatosRef
          .collection("usuarios")
          .document(idRemitente)
          .collection("estados conversacion")
          .document(idConversacion)
          .updateData(estadoConexionUsuario);
    }
  }
}

class TituloChatState extends State<TituloChat> {
  String imagen;
  String nombre;
  String ultimoMensaje;
  PantallaConversacion pantalla;
  TituloChatState(String imagen, String nombre, String ultimoMensaje) {
    this.imagen = imagen;
    this.nombre = nombre;
    this.ultimoMensaje = ultimoMensaje;
  }
  List<Mensajes> mensajes() {
    return widget.listadeMensajes;
  }

  String estadoEscribiendo() {
    return widget.estadoConversacion;
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: Conversacion.conversaciones,
        child: Consumer<Conversacion>(
          builder: (BuildContext context, conversacion, Widget child) {
            pantalla = PantallaConversacion(
              recibirEstadoConversacionActualizado: estadoEscribiendo,
              estadoEscribiendoRemitente: widget.estadoConversacion,
              estadoConversacion: widget.actualizarEstadoConversacion,
              mensajesImagen: widget.enviarMensajeImagen,
              mensajesTexto: mensajes,
              nombre: nombre,
              mensajesEnviar: widget.enviarMensaje,
              mensajesAudio: widget.enviarMensajeAudio,
              mensajeId: widget.mensajeId,
            );

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                onPressed: () async {
                  if (widget.listadeMensajes == null) {
                    widget.listadeMensajes = await widget.obtenerMensajes(
                        widget.mensajeId, widget.idRemitente);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => pantalla));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => pantalla));
                  }
                },
                child: Container(
                    height: ScreenUtil().setHeight(330),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color.fromRGBO(0, 0, 0, 100)),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: ClipRRect(
                            child: Container(
                                height: ScreenUtil().setHeight(300),
                                child: imagen == null
                                    ? Container()
                                    : CachedNetworkImage(
                                        imageUrl: imagen,
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      )),
                          ),
                        ),
                        Flexible(
                          flex: 9,
                          fit: FlexFit.tight,
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                      height: ScreenUtil().setHeight(100),
                                      child: nombre == null
                                          ? Text("")
                                          : Text(
                                              nombre,
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(60),
                                                  fontWeight: FontWeight.bold),
                                            )),
                                  Container(
                                    height: ScreenUtil().setHeight(130),
                                    child: Text(
                                      "",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(50)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Text(
                                  "1000",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40)),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            );
          },
        ));
  }
}

class PantallaConversacion extends StatefulWidget {
  Function mensajesTexto;
  Function mensajesAudio;
  Function mensajesImagen;
  Function estadoConversacion;
  Function recibirEstadoConversacionActualizado;
  String estadoEscribiendoRemitente;
  String nombre;
  String mensajeId;
  Function mensajesEnviar;
  String idRemitente;

  bool estaEscribiendo = false;

  PantallaConversacion(
      {@required this.recibirEstadoConversacionActualizado,
      @required this.estadoEscribiendoRemitente,
      @required this.estadoConversacion,
      @required this.mensajesImagen,
      @required this.mensajesTexto,
      @required this.mensajesAudio,
      @required this.nombre,
      @required this.mensajesEnviar,
      @required this.mensajeId});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PantallaConversacionState();
  }
}

class PantallaConversacionState extends State<PantallaConversacion> {
  String mensajeTemp;
  bool Construido = false;
  bool mostrarBotonBajarRapido = true;
  bool mostrarBotonEnvio = false;
  bool estaGrabando = false;
  FlutterAudioRecorder recorder;
  Io.File punteroGrabacion;
  String estado = " ";
  File imagen;
  bool primerosMensajesAudioCargados = false;
  void opcionesImagenPerfil() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Añadir Imagen"),
            content: Text("¿Seleccione la fuente de la imagen?"),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        abrirGaleria(context);
                      },
                      child: Row(
                        children: <Widget>[Text("Galeria"), Icon(Icons.image)],
                      )),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        abrirCamara(context);
                      },
                      child: Row(
                        children: <Widget>[
                          Text("Camara"),
                          Icon(Icons.camera_enhance)
                        ],
                      )),
                ],
              )
            ],
          );
        });
  }

  abrirGaleria(BuildContext context) async {
    var archivoImagen =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    if (archivoImagen != null) {
      File imagenRecortada = await ImageCropper.cropImage(
          sourcePath: archivoImagen.path,
          maxHeight: 1280,
          maxWidth: 720,
          aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 3),
          compressQuality: 90,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio16x9,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));

      imagen = imagenRecortada;
      widget.mensajesImagen(imagen, widget.mensajeId);
    }
  }

  abrirCamara(BuildContext context) async {
    var archivoImagen = await ImagePicker.pickImage(source: ImageSource.camera);
    if (archivoImagen != null) {
      File imagenRecortada = await ImageCropper.cropImage(
          sourcePath: archivoImagen.path,

          // aspectRatio: CropAspectRatio(ratioX: 9,ratioY: 16),
          maxHeight: 1000,
          maxWidth: 720,
          compressQuality: 90,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));

      imagen = imagenRecortada;
      widget.mensajesImagen(imagen, widget.mensajeId);
    }
  }

  ScrollController controlador = new ScrollController();
  void emprezarListaAbajo() {
    print("Construido");
    var timer = Timer(Duration(milliseconds: 50), () {
      print("Construido");
      Construido = true;
      controlador.jumpTo(controlador.position.maxScrollExtent);
      Conversacion.conversaciones.notifyListeners();
    });
    if (Construido) {
      print("parado");
      timer.cancel();
    }

    //  timer.cancel();
  }

  void moverChatAbajo() {
    if (controlador.positions.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        controlador.animateTo(controlador.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic);
      });
    }
  }

  void moverChatAbajoLento() {
    if (controlador.positions.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        controlador.animateTo(controlador.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic);
      });
    }
  }

  void mostrarBotonAbajo() {
    if (controlador.positions.isNotEmpty &&
        controlador.position.maxScrollExtent != null) {
      if (controlador.position.pixels <
              controlador.position.maxScrollExtent * 0.96 &&
          mostrarBotonBajarRapido == false) {
        mostrarBotonBajarRapido = true;
        print("abajooo");
        Conversacion.conversaciones.notifyListeners();
      }
      if (controlador.position.pixels >
              controlador.position.maxScrollExtent * 0.96 &&
          mostrarBotonBajarRapido == true) {
        mostrarBotonBajarRapido = false;
        Conversacion.conversaciones.notifyListeners();
      }
    }
  }

  void mostrarBotontexto() {
    if (!mostrarBotonEnvio) {
      mostrarBotonEnvio = true;
      Conversacion.conversaciones.notifyListeners();
    }
  }

  void ocultarBotonEnvio() {
    print("DentroOcultaBoton");
    if (mostrarBotonEnvio) {
      print("OcultaBoton");
      mostrarBotonEnvio = false;
      Conversacion.conversaciones.notifyListeners();
    }
  }

  void iniciarGrabacionAudio() async {
    bool permiso = await FlutterAudioRecorder.hasPermissions;
    print(permiso);
    if (await FlutterAudioRecorder.hasPermissions == false) {
      Permission permiso = Permission.storage;
      await permiso.request();
    }

    if (await FlutterAudioRecorder.hasPermissions) {
      final directorio = await getApplicationDocumentsDirectory();
      String referenciaCompleta =
          "${directorio.path}'/'${DateTime.now().toUtc().toIso8601String()}";
      print(directorio.path);
      Io.Directory(referenciaCompleta)
          .create(recursive: true)
          .then((valor) async {
        punteroGrabacion = new Io.File("${valor.path}.aac");
        print(referenciaCompleta);
        recorder = FlutterAudioRecorder("${valor.path}.aac",
            audioFormat: AudioFormat.AAC);
        await recorder.initialized;
        await recorder.start();
      });
    }
  }

  void pararGrabacion() async {
    await recorder.stop();

    Uint8List audio = await punteroGrabacion.readAsBytesSync();
    print(audio);
    widget.mensajesAudio(audio, widget.mensajeId);
  }

  TextEditingController controladorTexto = new TextEditingController();
  Widget build(BuildContext context) {
    bool empezarListaAbajo = true;
    if (controlador.hasClients) {
      SchedulerBinding.instance.addPostFrameCallback((_) {});
    }

    return ChangeNotifierProvider.value(
      value: Conversacion.conversaciones,
      child: Consumer<Conversacion>(
        builder: (BuildContext context, conversacion, Widget child) {
          // moverChatAbajo();
          List<Mensajes> mensajesTemporales = widget.mensajesTexto();
          if (mensajesTemporales.isEmpty) {
            emprezarListaAbajo();
            print("Truee");
          }
          if (!primerosMensajesAudioCargados && mensajesTemporales != null) {
            for (int i = 0; i < mensajesTemporales.length; i++) {
              if (mensajesTemporales[i].tipoMensaje == "Audio" &&
                  mensajesTemporales[i].duracionMensaje == null) {
                mensajesTemporales[i].obtenerDuracionMensaje();
              }
            }
            primerosMensajesAudioCargados = true;
          }
          print(estado);
          estado = widget.recibirEstadoConversacionActualizado();

          return Scaffold(
              appBar: AppBar(
                title: Text(
                  "${widget.nombre}   ${estado}",
                  style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                ),
              ),
              body: Container(
                child: Column(
                  children: <Widget>[
                    mensajesTemporales == null
                        ? Flexible(
                            flex: 15,
                            fit: FlexFit.tight,
                            child: Container(
                              color: Colors.red,
                            ))
                        : Flexible(
                            flex: 15,
                            fit: FlexFit.tight,
                            child: Container(
                              color: Colors.red,
                              child: Stack(children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    NotificationListener<
                                        ScrollUpdateNotification>(
                                      child: ListView.builder(
                                        controller: controlador,
                                        itemCount: mensajesTemporales.length,
                                        itemBuilder:
                                            (BuildContext context, indice) {
                                          if (empezarListaAbajo) {
                                            emprezarListaAbajo();
                                            empezarListaAbajo = false;
                                          }
                                          mostrarBotonAbajo();
                                          return mensajesTemporales[indice];
                                        },
                                      ),
                                      onNotification: (valor) {
                                        // print("movido");
                                        mostrarBotonAbajo();
                                        return;
                                      },
                                    ),
                                    mostrarBotonBajarRapido
                                        ? Positioned(
                                            left: ScreenUtil().setWidth(1100),
                                            bottom: ScreenUtil().setHeight(100),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(3)),
                                                  color: Colors.grey),
                                              width: ScreenUtil().setWidth(200),
                                              child: FlatButton(
                                                onPressed: () {
                                                  moverChatAbajoLento();
                                                },
                                                child: Center(
                                                    child: Icon(
                                                        Icons.arrow_downward)),
                                              ),
                                            ))
                                        : Container(),
                                  ],
                                ),
                                Construido == true
                                    ? Container()
                                    : Container(
                                        color: Colors.black,
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              CircularProgressIndicator(),
                                              Text(
                                                "Cargando",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                              ]),
                            ),
                          ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                            color: Colors.white),
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              flex: 8,
                              fit: FlexFit.tight,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  controller: controladorTexto,
                                  decoration: InputDecoration(
                                    counter: Offstage(),
                                    labelText: "Mensaje",
                                  ),
                                  maxLength: 3000,
                                  onChanged: (valor) {
                                    if (valor != null ||
                                        valor != " " ||
                                        valor.isNotEmpty) {
                                      if (!widget.estaEscribiendo) {
                                        widget.estadoConversacion(true);
                                        widget.estaEscribiendo = true;
                                      }
                                      mostrarBotontexto();
                                    }
                                    if (valor == null ||
                                        valor == " " ||
                                        valor.isEmpty) {
                                      ocultarBotonEnvio();
                                      if (widget.estaEscribiendo) {
                                        widget.estadoConversacion(false);
                                        widget.estaEscribiendo = false;
                                      }
                                    }
                                    mensajeTemp = valor;
                                    print(valor);
                                  },
                                  onSubmitted: (valor) {
                                    widget.estadoConversacion(false);
                                    widget.estaEscribiendo = false;
                                    ocultarBotonEnvio();
                                    mensajeTemp = valor;
                                    widget.mensajesEnviar(
                                        mensajeTemp, widget.mensajeId);
                                    controladorTexto.clear();
                                    mensajeTemp = "";
                                    moverChatAbajo();
                                  },
                                ),
                              ),
                            ),
                            mostrarBotonEnvio
                                ? Flexible(
                                    flex: 3,
                                    fit: FlexFit.tight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3)),
                                        color: Colors.red,
                                      ),
                                      child: FlatButton(
                                        onPressed: () {
                                          widget.mensajesEnviar(
                                              mensajeTemp, widget.mensajeId);
                                          controladorTexto.clear();
                                          widget.estadoConversacion(false);
                                          widget.estaEscribiendo = false;
                                        },
                                        child: Icon(Icons.send),
                                      ),
                                    ),
                                  )
                                : Flexible(
                                    flex: 4,
                                    fit: FlexFit.tight,
                                    child: Row(
                                      children: <Widget>[
                                        Flexible(
                                          flex: 2,
                                          fit: FlexFit.tight,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3)),
                                              color: Colors.red,
                                            ),
                                            child: GestureDetector(
                                              onLongPress: () {
                                                iniciarGrabacionAudio();
                                              },
                                              onLongPressUp: () {
                                                pararGrabacion();
                                              },
                                              child: FlatButton(
                                                onPressed: () {},
                                                child: Icon(Icons.mic),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 2,
                                          fit: FlexFit.tight,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(2)),
                                              color: Colors.red,
                                            ),
                                            child: FlatButton(
                                              onPressed: () {
                                                opcionesImagenPerfil();
                                              },
                                              child: Icon(
                                                  Icons.add_photo_alternate),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ));
        },
      ),
    );
  }
}
