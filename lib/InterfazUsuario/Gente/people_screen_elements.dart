import 'dart:convert';

import 'dart:io' as Io;
import 'dart:math';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';
import 'package:citasnuevo/DatosAplicacion/Directo.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:typed_data';
import 'package:citasnuevo/base_app.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter/cupertino.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

class Mensajes extends StatefulWidget {
  String mensaje;
  DateTime horaMensaje;
  String idMensaje;
  String idEmisor;
  String tipoMensaje;
  String nombreEmisor;
  int duracionMensaje = 0;
  double posicion = 0;
  bool mensajeLeido;
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
  bool leido = false;
  bool mensajeLeidoRemitente = false;
  String identificadorUnicoMensaje;
  String idConversacion;

  String directoriofinal;

  final f = new DateFormat('HH:mm');
  final dia = new DateFormat("yMMMMEEEEd");

  void cargarAudio() async {
    if (player == null) {
      print("vacioestaaaaaaaas");
    }
    Uint8List audio;
    var response = await http.readBytes(mensaje);

    audio = response;

    final directorio = await getApplicationDocumentsDirectory();

    directorioAudio = "${directorio.path}/${DateTime.now()}";
    await Io.Directory(directorioAudio)
        .create(recursive: true)
        .then((valor) async {
      print(valor.path);
      directoriofinal = "${valor.path}/${DateTime.now()}.aac";
      Io.File puntero = new Io.File(directoriofinal);
      puntero.writeAsBytesSync(audio, mode: FileMode.write, flush: true);
      print("${valor.path}.aac");
    });
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
      @required this.identificadorUnicoMensaje,
      @required this.mensajeLeido,
      @required this.nombreEmisor,
      @required this.idEmisor,
      @required this.idConversacion,
      @required this.mensajeLeidoRemitente,
      @required this.mensaje,
      @required this.horaMensaje,
      @required this.tipoMensaje});
  Mensajes.Audio(
      {@required this.idMensaje,
      @required this.mensajeLeido,
      @required this.identificadorUnicoMensaje,
      @required this.duracionMensaje,
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
      @required this.duracionMensaje,
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
          return widget.idEmisor == Usuario.esteUsuario.idUsuario
              ? Column(
                  children: <Widget>[
                    widget.tipoMensaje == "Audio"
                        ? mensajeAudioUsuario()
                        : widget.tipoMensaje == "Texto"
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
                    widget.tipoMensaje == "Audio"
                        ? mensajeAudioRemitente()
                        : widget.tipoMensaje == "Texto"
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.transparent,
                ),
                height: ScreenUtil().setHeight(600),
                width: ScreenUtil().setWidth(600),
                child: Image.network(widget.mensaje,
                    headers: {'accept': 'image/*'}),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(widget.f.format(widget.horaMensaje),
                      style: TextStyle(fontSize: ScreenUtil().setSp(35))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Align mensajeImagenRemitente(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.transparent,
                ),
                height: ScreenUtil().setHeight(600),
                width: ScreenUtil().setWidth(600),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: CachedNetworkImage(
                      imageUrl: widget.mensaje,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: Container(
                          height: ScreenUtil().setHeight(300),
                          width: ScreenUtil().setWidth(300),
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(widget.f.format(widget.horaMensaje),
                      style: TextStyle(fontSize: ScreenUtil().setSp(35))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container separadorHoraRemitente() {
    return Container(
      child: Text(widget.horaMensaje.day == DateTime.now().day
          ? "Hoy"
          : widget.dia.format(widget.horaMensaje)),
    );
  }

  Align mensajeTextoRemitente() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding:
            const EdgeInsets.only(right: 50, left: 10, bottom: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15))),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 3, bottom: 3),
                            child: Text(widget.nombreEmisor),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.mensaje,
                        style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                      ),
                    ),
                  ],
                )),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  child: Text(widget.f.format(widget.horaMensaje),
                      style: TextStyle(fontSize: ScreenUtil().setSp(35))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Align mensajeAudioRemitente() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding:
            const EdgeInsets.only(right: 50, left: 10, bottom: 20, top: 20),
        child: Container(
          height: ScreenUtil().setHeight(300),
          width: ScreenUtil().setWidth(600),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.green,
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 3,
                        child: Container(
                          child: Center(
                            child: FlatButton(
                              onPressed: () {
                                widget.reproducirAudio();
                              },
                              child: Center(
                                  child: Icon(
                                Icons.play_arrow,
                                size: ScreenUtil().setSp(100),
                              )),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 11,
                        child: Container(
                          child: Stack(alignment: Alignment.center, children: <
                              Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 15.0, right: 15),
                              child: LinearPercentIndicator(
                                lineHeight: ScreenUtil().setHeight(70),
                                percent: widget.posicion,
                              ),
                            ),
                            SliderTheme(
                              data: SliderThemeData(
                                thumbColor: Colors.transparent,
                                activeTickMarkColor: Colors.transparent,
                                activeTrackColor: Colors.transparent,
                                disabledActiveTickMarkColor: Colors.transparent,
                                disabledActiveTrackColor: Colors.transparent,
                                disabledInactiveTickMarkColor:
                                    Colors.transparent,
                                disabledInactiveTrackColor: Colors.transparent,
                                disabledThumbColor: Colors.transparent,
                                inactiveTickMarkColor: Colors.transparent,
                                inactiveTrackColor: Colors.transparent,
                                overlappingShapeStrokeColor: Colors.transparent,
                                overlayColor: Colors.transparent,
                                valueIndicatorColor: Colors.transparent,
                              ),
                              child: Slider(
                                value: widget.posicion,
                                max: widget.duracionMensaje.toDouble() ?? 0,
                                min: 0,
                                onChanged: (val) {
                                  widget.posicionAudio(val);
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
                    child: Text(widget.f.format(widget.horaMensaje),
                        style: TextStyle(fontSize: ScreenUtil().setSp(35))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Align mensajeGifUsuario(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.transparent,
                ),
                height: ScreenUtil().setHeight(600),
                width: ScreenUtil().setWidth(600),
                child: Image.network(widget.mensaje,
                    headers: {'accept': 'image/*'}),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(widget.f.format(widget.horaMensaje),
                          style: TextStyle(fontSize: ScreenUtil().setSp(35))),
                    ),
                    widget.mensajeLeidoRemitente
                        ? Icon(Icons.check_circle,
                            color: Colors.white, size: 50.sp)
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

  Align mensajeImagenUsuario(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.transparent,
                ),
                height: ScreenUtil().setHeight(600),
                width: ScreenUtil().setWidth(600),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: CachedNetworkImage(
                      imageUrl: widget.mensaje,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                        child: Container(
                          height: ScreenUtil().setHeight(300),
                          width: ScreenUtil().setWidth(300),
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(widget.f.format(widget.horaMensaje),
                          style: TextStyle(fontSize: ScreenUtil().setSp(35))),
                    ),
                    widget.mensajeLeidoRemitente
                        ? Icon(Icons.check_circle,
                            color: Colors.white, size: 50.sp)
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

  Container separadorHoraUsuario() {
    return Container(
      child: Text(widget.horaMensaje.day == DateTime.now().day
          ? "Hoy"
          : widget.dia.format(widget.horaMensaje)),
    );
  }

  Align mensajeTextoUsuario() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding:
            const EdgeInsets.only(right: 10, left: 50, bottom: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Colors.blue),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 3, bottom: 3),
                    child: Text("Yo"),
                  )),
            ),
            Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
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
                      Container(
                        child: Text(
                          widget.mensaje,
                          style: TextStyle(fontSize: ScreenUtil().setSp(40)),
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
                    child: Text(widget.f.format(widget.horaMensaje),
                        style: TextStyle(fontSize: ScreenUtil().setSp(35))),
                  ),
                  widget.mensajeLeidoRemitente
                      ? Icon(Icons.check_circle,
                          color: Colors.white, size: 50.sp)
                      : Container()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Align mensajeAudioUsuario() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding:
            const EdgeInsets.only(right: 10, left: 50, bottom: 20, top: 20),
        child: Container(
          height: ScreenUtil().setHeight(300),
          width: ScreenUtil().setWidth(600),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                          bottomLeft: Radius.circular(3))),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 3,
                        child: Container(
                          child: Center(
                            child: FlatButton(
                              onPressed: () {
                                widget.reproducirAudio();
                              },
                              child: Center(
                                  child: Icon(
                                Icons.play_arrow,
                                size: ScreenUtil().setSp(100),
                              )),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 11,
                        child: Container(
                          child: Stack(alignment: Alignment.center, children: <
                              Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 15.0, right: 15),
                              child: LinearPercentIndicator(
                                lineHeight: ScreenUtil().setHeight(70),
                                percent: widget.posicion,
                              ),
                            ),
                            SliderTheme(
                              data: SliderThemeData(
                                thumbColor: Colors.transparent,
                                activeTickMarkColor: Colors.transparent,
                                activeTrackColor: Colors.transparent,
                                disabledActiveTickMarkColor: Colors.transparent,
                                disabledActiveTrackColor: Colors.transparent,
                                disabledInactiveTickMarkColor:
                                    Colors.transparent,
                                disabledInactiveTrackColor: Colors.transparent,
                                disabledThumbColor: Colors.transparent,
                                inactiveTickMarkColor: Colors.transparent,
                                inactiveTrackColor: Colors.transparent,
                                overlappingShapeStrokeColor: Colors.transparent,
                                overlayColor: Colors.transparent,
                                valueIndicatorColor: Colors.transparent,
                              ),
                              child: Slider(
                                value: widget.posicion,
                                max: widget.duracionMensaje.toDouble(),
                                min: 0,
                                onChanged: (val) {
                                  widget.posicionAudio(val);
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: Text(widget.f.format(widget.horaMensaje),
                            style: TextStyle(fontSize: ScreenUtil().setSp(35))),
                      ),
                      widget.mensajeLeidoRemitente
                          ? Icon(Icons.check_circle,
                              color: Colors.white, size: 50.sp)
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
}

class TituloChat extends StatefulWidget {
  List<Mensajes> listadeMensajes = new List();
  String idRemitente;
  String idConversacion;
  String estadoConversacion;
  bool estadoConexion;
  String imagen;
  String nombre;
  PantallaConversacion pantalla;
  int mensajesSinLeer;

  Map<String, dynamic> ultimoMensaje = new Map();
  String mensajeId;
  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
  Conversacion conversacion;

  TituloChat(
      {@required this.conversacion,
      @required this.estadoConexion,
      @required this.idConversacion,
      @required this.estadoConversacion,
      @required this.idRemitente,
      @required this.listadeMensajes,
      @required this.ultimoMensaje,
      @required this.nombre,
      @required this.imagen,
      this.mensajeId}) {
    if (listadeMensajes != null && listadeMensajes.length > 0) {}
  }

  Future<List<Mensajes>> obtenerMensajes(
      String identificadorMensajes, String rutaRemitente) async {
    List<Mensajes> temp = new List();

    if (!this.conversacion.grupo) {
      await baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("mensajes")
          .where("idMensaje", isEqualTo: identificadorMensajes)
          .limit(100)
          .get()
          .then((dato) async {
        if (dato.docs.length > 0) {
          print("${dato.docs.length} mensajes para el en firebase");
          print(rutaRemitente);
          print(identificadorMensajes);
          for (int a = 0; a < dato.docs.length; a++) {
            print(dato.docs[a].get("Tipo Mensaje"));
            if (dato.docs[a].get("Tipo Mensaje") == "Texto" ||
                dato.docs[a].get("Tipo Mensaje") == "Imagen"||   dato.docs[a].get("Tipo Mensaje") == "Gif") {
              Mensajes mensaje = new Mensajes(
                mensajeLeido: dato.docs[a].get("mensajeLeido"),
                nombreEmisor: dato.docs[a].get("Nombre emisor"),
                identificadorUnicoMensaje:
                    dato.docs[a].get("identificadorUnicoMensaje"),
                idEmisor: dato.docs[a].get("idEmisor"),
                idConversacion: dato.docs[a].get("idConversacion"),
                mensajeLeidoRemitente:
                    dato.docs[a].get("mensajeLeidoRemitente"),
                mensaje: dato.docs[a].get("Mensaje"),
                idMensaje: dato.docs[a].get("idMensaje"),
                horaMensaje: (dato.docs[a].get("Hora mensaje")).toDate(),
                tipoMensaje: dato.docs[a].get("Tipo Mensaje"),
              );
              temp = List.from(temp)..add(mensaje);
            }
            if (dato.docs[a].get("Tipo Mensaje") == "Audio") {
              Mensajes mensaje = new Mensajes.Audio(
                duracionMensaje: dato.docs[a].get("duracion"),
                mensajeLeido: dato.docs[a].get("mensajeLeido"),
                idConversacion: dato.docs[a].get("idConversacion"),
                nombreEmisor: dato.docs[a].get("Nombre emisor"),
                idEmisor: dato.docs[a].get("idEmisor"),
                mensajeLeidoRemitente:
                    dato.docs[a].get("mensajeLeidoRemitente"),
                identificadorUnicoMensaje:
                    dato.docs[a].get("identificadorUnicoMensaje"),
                mensaje: dato.docs[a].get("Mensaje"),
                idMensaje: dato.docs[a].get("idMensaje"),
                horaMensaje: (dato.docs[a].get("Hora mensaje")).toDate(),
                tipoMensaje: dato.docs[a].get("Tipo Mensaje"),
              );

              temp = List.from(temp)..add(mensaje);
            }
          }
        }
      });
    }

    if (temp.length > 0) {
      temp = insertarHoras(temp);
    }

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

  void enviarMensaje(
    String mensajeTexto,
    String idMensaje,
  ) async {
    WriteBatch escrituraMensajes = baseDatosRef.batch();
    String idMensajeUnico = Solicitud.instancia.crearCodigo();
    DocumentReference direccionMensajes = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("mensajes")
        .doc(idMensajeUnico);
    DocumentReference direccionMensajesUsuario = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .doc(idMensajeUnico);
    DocumentReference referenciaConversacionRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);
    DocumentReference referenciaConversacionUsuario = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(idConversacion);

    if (!this.conversacion.grupo) {
      if (mensajeTexto != null) {
        Map<String, dynamic> mensaje = Map();
        DateTime horaMensaje = DateTime.now();
        mensaje["Hora mensaje"] = horaMensaje;
        mensaje["Mensaje"] = mensajeTexto;
        mensaje["idMensaje"] = idMensaje;
        mensaje["mensajeLeido"] = false;
        mensaje["mensajeLeidoRemitente"] = false;
        mensaje["Nombre emisor"] = Usuario.esteUsuario.nombre;
        mensaje["idConversacion"] = idConversacion;
        mensaje["identificadorUnicoMensaje"] = idMensajeUnico;
        mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
        mensaje["Tipo Mensaje"] = "Texto";

        escrituraMensajes.update(referenciaConversacionRemitente, {
          "ultimoMensaje": {
            "mensaje": mensaje["Mensaje"],
            "tipoMensaje": "texto",
            "duracion": 0
          }
        });
        escrituraMensajes.update(referenciaConversacionUsuario, {
          "ultimoMensaje": {
            "mensaje": mensaje["Mensaje"],
            "tipoMensaje": "texto",
            "duracion": 0
          }
        });
        escrituraMensajes.set(direccionMensajes, mensaje);
        escrituraMensajes.set(direccionMensajesUsuario, mensaje);
        await escrituraMensajes.commit();
      }
    }
    if (this.conversacion.grupo) {
      if (mensajeTexto != null) {
        Map<String, dynamic> mensaje = Map();
        DateTime horaMensaje = DateTime.now();
        mensaje["Hora mensaje"] = horaMensaje;
        mensaje["Mensaje"] = mensajeTexto;
        mensaje["Nombre emisor"] = Usuario.esteUsuario.nombre;
        mensaje["mensajeLeido"] = false;
        mensaje["idMensaje"] = idMensaje;
        mensaje["mensajeLeidoRemitente"] = false;
        mensaje["identificadorUnicoMensaje"] = idMensajeUnico;
        mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
        mensaje["Tipo Mensaje"] = "Texto";
        print(idRemitente);
        baseDatosRef
            .collection("grupos directo")
            .doc(idConversacion)
            .collection("mensajes")
            .doc()
            .set(mensaje);
      }
    }
  }

  void enviarMensajeAudio(
      Uint8List audio, String idMensaje, int duracion) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    String idMensajeUnico = Solicitud.instancia.crearCodigo();
    String ruta = "${idRemitente}/Perfil/NotasVoz/${crearCodigo()}.aac";
    StorageReference referenciaArchivo = reference.child(ruta);
    WriteBatch escrituraMensajes = baseDatosRef.batch();
    DocumentReference direccionMensajes = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("mensajes")
        .doc(idMensajeUnico);

    DocumentReference direccionMensajesUsuario = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .doc(idMensajeUnico);
    DocumentReference referenciaConversacionRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);
    DocumentReference referenciaConversacionUsuario = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(idConversacion);

    StorageUploadTask task = referenciaArchivo.putData(audio);
    var url = await (await task.onComplete).ref.getDownloadURL();
    if (audio != null) {
      Map<String, dynamic> mensaje = Map();
      DateTime horaMensaje = DateTime.now();
      mensaje["Hora mensaje"] = horaMensaje;
      mensaje["Mensaje"] = url;
      mensaje["idMensaje"] = idMensaje;
      mensaje["mensajeLeido"] = false;
      mensaje["mensajeLeidoRemitente"] = false;
      mensaje["idConversacion"] = idConversacion;
      mensaje["identificadorUnicoMensaje"] = idMensajeUnico;
      mensaje["Nombre emisor"] = Usuario.esteUsuario.nombre;
      mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
      mensaje["duracion"] = duracion;
      mensaje["Tipo Mensaje"] = "Audio";
      print(idRemitente);
      if (this.conversacion.grupo) {
        await baseDatosRef
            .collection("grupos directo")
            .doc(this.conversacion.idConversacion)
            .collection("mensajes")
            .doc()
            .set(mensaje);
      }
      if (!this.conversacion.grupo) {
        escrituraMensajes.update(referenciaConversacionRemitente, {
          "ultimoMensaje": {
            "mensaje": mensaje["Mensaje"],
            "tipoMensaje": "audio",
            "duracion": duracion
          }
        });
        escrituraMensajes.update(referenciaConversacionUsuario, {
          "ultimoMensaje": {
            "mensaje": mensaje["Mensaje"],
            "tipoMensaje": "audio",
            "duracion": duracion
          }
        });
        escrituraMensajes.set(direccionMensajes, mensaje);
        escrituraMensajes.set(direccionMensajesUsuario, mensaje);
        await escrituraMensajes.commit();
      }
    }
  }

  void enviarMensajeImagen(File imagen, String idMensaje) async {
    if (imagen != null) {
      FirebaseStorage storage = FirebaseStorage.instance;
      String idMensajeUnico = Solicitud.instancia.crearCodigo();
      StorageReference reference = storage.ref();
      String ruta =
          "${idRemitente}/Perfil/ImagenesConversaciones/${crearCodigo()}.jpg";
      StorageReference referenciaArchivo = reference.child(ruta);
      WriteBatch escrituraMensajes = baseDatosRef.batch();
      DocumentReference direccionMensajes = baseDatosRef
          .collection("usuarios")
          .doc(idRemitente)
          .collection("mensajes")
          .doc(idMensajeUnico);
      DocumentReference direccionMensajesUsuario = baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("mensajes")
          .doc(idMensajeUnico);
      DocumentReference referenciaConversacionRemitente = baseDatosRef
          .collection("usuarios")
          .doc(idRemitente)
          .collection("conversaciones")
          .doc(idConversacion);
      DocumentReference referenciaConversacionUsuario = baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("conversaciones")
          .doc(idConversacion);

      StorageUploadTask task = referenciaArchivo.putFile(imagen);
      var url = await (await task.onComplete).ref.getDownloadURL();
      if (imagen != null) {
        Map<String, dynamic> mensaje = Map();
        DateTime horaMensaje = DateTime.now();
        mensaje["Hora mensaje"] = horaMensaje;
        mensaje["Mensaje"] = url;
        mensaje["idMensaje"] = idMensaje;
        mensaje["mensajeLeido"] = false;
        mensaje["mensajeLeidoRemitente"] = false;
        mensaje["idConversacion"] = idConversacion;
        mensaje["identificadorUnicoMensaje"] = idMensajeUnico;
        mensaje["Nombre emisor"] = Usuario.esteUsuario.nombre;
        mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
        mensaje["Tipo Mensaje"] = "Imagen";
        print(idRemitente);
        if (conversacion.grupo) {
          await baseDatosRef
              .collection("grupos directo")
              .doc(idRemitente)
              .collection("mensajes")
              .doc()
              .set(mensaje)
              .then((value) {
            print("ImagenEnviada");
          });
        }
        if (!conversacion.grupo) {
          escrituraMensajes.update(referenciaConversacionRemitente, {
            "ultimoMensaje": {
              "mensaje": mensaje["Mensaje"],
              "tipoMensaje": "imagen",
              "duracion": 0
            }
          });
          escrituraMensajes.update(referenciaConversacionUsuario, {
            "ultimoMensaje": {
              "mensaje": mensaje["Mensaje"],
              "tipoMensaje": "imagen",
              "duracion": 0
            }
          });
          escrituraMensajes.set(direccionMensajes, mensaje);
          escrituraMensajes.set(direccionMensajesUsuario, mensaje);

          await escrituraMensajes.commit();
        }
      }
    }
  }

  void enviarMensajeImagenGif(String urlImagen, String idMensaje) async {
    http.get(urlImagen).then((value) async {
      if (urlImagen != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        String idMensajeUnico = Solicitud.instancia.crearCodigo();
        StorageReference reference = storage.ref();
        String ruta =
            "${idRemitente}/Perfil/ImagenesConversaciones/${crearCodigo()}.gif";
        StorageReference referenciaArchivo = reference.child(ruta);
        WriteBatch escrituraMensajes = baseDatosRef.batch();
        DocumentReference direccionMensajes = baseDatosRef
            .collection("usuarios")
            .doc(idRemitente)
            .collection("mensajes")
            .doc(idMensajeUnico);
        DocumentReference direccionMensajesUsuario = baseDatosRef
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("mensajes")
            .doc(idMensajeUnico);
        DocumentReference referenciaConversacionRemitente = baseDatosRef
            .collection("usuarios")
            .doc(idRemitente)
            .collection("conversaciones")
            .doc(idConversacion);
        DocumentReference referenciaConversacionUsuario = baseDatosRef
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("conversaciones")
            .doc(idConversacion);

        if (urlImagen != null) {
          Map<String, dynamic> mensaje = Map();
          DateTime horaMensaje = DateTime.now();
          mensaje["Hora mensaje"] = horaMensaje;
          mensaje["Mensaje"] = urlImagen;
          mensaje["idMensaje"] = idMensaje;
          mensaje["mensajeLeido"] = false;
          mensaje["mensajeLeidoRemitente"] = false;
          mensaje["idConversacion"] = idConversacion;
          mensaje["identificadorUnicoMensaje"] = idMensajeUnico;
          mensaje["Nombre emisor"] = Usuario.esteUsuario.nombre;
          mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
          mensaje["Tipo Mensaje"] = "Gif";
          print(idRemitente);
          if (conversacion.grupo) {
            await baseDatosRef
                .collection("grupos directo")
                .doc(idRemitente)
                .collection("mensajes")
                .doc()
                .set(mensaje)
                .then((value) {
              print("ImagenEnviada");
            });
          }
          if (!conversacion.grupo) {
            escrituraMensajes.update(referenciaConversacionRemitente, {
              "ultimoMensaje": {
                "mensaje": mensaje["Mensaje"],
                "tipoMensaje": "gif",
                "duracion": 0
              }
            });
            escrituraMensajes.update(referenciaConversacionUsuario, {
              "ultimoMensaje": {
                "mensaje": mensaje["Mensaje"],
                "tipoMensaje": "gif",
                "duracion": 0
              }
            });
            escrituraMensajes.set(direccionMensajes, mensaje);
            escrituraMensajes.set(direccionMensajesUsuario, mensaje);

            await escrituraMensajes.commit();
          }
        }
      }
    });
  }

  void actualizarEstadoConversacion(bool estaEscribiendo) async {
    if (estaEscribiendo) {
      print("estaEscribiendo");
      print("Esta escribiendo para ${conversacion.idConversacion}");
      Map<String, dynamic> estadoConexionUsuario = Map();
      estadoConexionUsuario["Escribiendo"] = true;
      estadoConexionUsuario["Conectado"] = true;
      estadoConexionUsuario["IdConversacion"] = conversacion.idConversacion;
      estadoConexionUsuario["Hora Conexion"] = DateTime.now();
      await baseDatosRef
          .collection("usuarios")
          .doc(idRemitente)
          .collection("estados conversacion")
          .doc(idConversacion)
          .update(estadoConexionUsuario);
    }
    if (!estaEscribiendo) {
      print("No esta escribiensssssdo");
      Map<String, dynamic> estadoConexionUsuario = Map();
      estadoConexionUsuario["Escribiendo"] = false;
      estadoConexionUsuario["Conectado"] = true;
      estadoConexionUsuario["IdConversacion"] = conversacion.idConversacion;
      estadoConexionUsuario["Hora Conexion"] = DateTime.now();
      await baseDatosRef
          .collection("usuarios")
          .doc(idRemitente)
          .collection("estados conversacion")
          .doc(conversacion.idConversacion)
          .update(estadoConexionUsuario);
    }
  }
}

class TituloChatState extends State<TituloChat> {
  String imagen;
  String nombre;
  Map<String, dynamic> ultimoMensaje = Map();
  
  int cantidadMensajesSinLeer = 0;
  TituloChatState(
      String imagen, String nombre, Map<String, dynamic> ultimoMensaje) {
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

  bool estadoConexionUsuario() {
    return widget.estadoConexion;
  }




  void crearPantalla(){
    widget.pantalla = PantallaConversacion(
              estadoConexion: estadoConexionUsuario,
              enviarMensajeImagenGif: widget.enviarMensajeImagenGif,
              idConversacion: widget.idConversacion,
              imagenId: widget.imagen,
              marcarMensajeLeidoRemitente: dejarMensajeLeidoRemitente,
              esGrupo: widget.conversacion.grupo,
              idRemitente: widget.idRemitente,
              marcarLeidoMensaje: dejarMensajesEnLeido,
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
               Navigator.push(context,
                        MaterialPageRoute(builder: (context) => widget.pantalla));
  }

  void dejarMensajesEnLeido() async {
    FirebaseFirestore referenciaBaseDatos = FirebaseFirestore.instance;
    WriteBatch escrituraLeidoMensajes = referenciaBaseDatos.batch();
    DocumentReference referenciaMensaje;
    if (widget.listadeMensajes != null) {
      for (int i = 0; i < widget.listadeMensajes.length; i++) {
        if (widget.listadeMensajes[i].mensajeLeido == false &&
            widget.listadeMensajes[i].mensaje != null) {
          widget.listadeMensajes[i].mensajeLeido = true;
          referenciaMensaje = referenciaBaseDatos
              .collection("usuarios")
              .doc(widget.idRemitente)
              .collection("mensajes")
              .doc(widget.listadeMensajes[i].identificadorUnicoMensaje);
          escrituraLeidoMensajes
              .update(referenciaMensaje, {"mensajeLeido": true});
        }
      }
      await escrituraLeidoMensajes.commit().catchError((onError) {
        print(onError);
      });
    }
  }

  void dejarMensajeLeidoRemitente() async {
    FirebaseFirestore referenciaBaseDatos = FirebaseFirestore.instance;
    WriteBatch escrituraLeidoMensajes = referenciaBaseDatos.batch();
    DocumentReference referenciaMensaje;
    if (widget.listadeMensajes != null) {
      for (int i = 0; i < widget.listadeMensajes.length; i++) {
        if (widget.listadeMensajes[i].mensajeLeidoRemitente == false &&
            widget.listadeMensajes[i].idEmisor !=
                Usuario.esteUsuario.idUsuario &&
            widget.listadeMensajes[i].mensaje != null) {
          widget.listadeMensajes[i].mensajeLeidoRemitente = true;
          referenciaMensaje = referenciaBaseDatos
              .collection("usuarios")
              .doc(widget.idRemitente)
              .collection("mensajes")
              .doc(widget.listadeMensajes[i].identificadorUnicoMensaje);

          escrituraLeidoMensajes
              .update(referenciaMensaje, {"mensajeLeidoRemitente": true});
        }
      }
      await escrituraLeidoMensajes.commit().catchError((onError) {
        print(onError);
      });
    }
  }

  int hayMensajesSinLeer() {
    int mensajeSinLeer = 0;
    if (widget.listadeMensajes != null) {
      for (int i = 0; i < widget.listadeMensajes.length; i++) {
        if (widget.listadeMensajes[i].mensajeLeido == false) {
          mensajeSinLeer++;
          
        }
      }
    }
  widget.mensajesSinLeer=mensajeSinLeer;
  print(widget.mensajesSinLeer);
 
    return mensajeSinLeer;
  }

  String mostrarDuracion(int duracion) {
    Duration duracionMensajeVoz = new Duration(milliseconds: duracion);
    String dosDigitos(int n) => n.toString().padLeft(2, "0");
    String dosDigitosMinutos =
        dosDigitos(duracionMensajeVoz.inMinutes.remainder(60));
    String dosDigitosSegundos =
        dosDigitos(duracionMensajeVoz.inSeconds.remainder(60));
    return "$dosDigitosMinutos:$dosDigitosSegundos";
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: Conversacion.conversaciones,
        child: Consumer<Conversacion>(
          builder: (BuildContext context, conversacion, Widget child) {
            cantidadMensajesSinLeer = hayMensajesSinLeer();
            widget.mensajesSinLeer=cantidadMensajesSinLeer;
            widget.pantalla = PantallaConversacion(
              estadoConexion: estadoConexionUsuario,
              enviarMensajeImagenGif: widget.enviarMensajeImagenGif,
              idConversacion: widget.idConversacion,
              imagenId: widget.imagen,
              marcarMensajeLeidoRemitente: dejarMensajeLeidoRemitente,
              esGrupo: widget.conversacion.grupo,
              idRemitente: widget.idRemitente,
              marcarLeidoMensaje: dejarMensajesEnLeido,
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
              padding: const EdgeInsets.all(10.0),
              child: FlatButton(
                onPressed: () async {
                  if (widget.listadeMensajes == null) {
                    widget.listadeMensajes = await widget.obtenerMensajes(
                        widget.mensajeId, widget.idRemitente);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => widget.pantalla));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => widget.pantalla));
                  }
                },
                child: Container(
                    height: ScreenUtil().setHeight(250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 200.h,
                            width: 200.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                    widget.imagen,
                                  ),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Flexible(
                            flex: 6,
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
                                    Flexible(
                                      flex: 5,
                                      fit: FlexFit.tight,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              height:
                                                  ScreenUtil().setHeight(100),
                                              child: nombre == null
                                                  ? Text("")
                                                  : Text(
                                                      widget.nombre,
                                                      style: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(40),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                          widget.estadoConexion
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Container(
                                                    height: 50.w,
                                                    width: ScreenUtil()
                                                        .setWidth(50),
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.green,
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: ScreenUtil()
                                                                .setWidth(5))),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 5,
                                      fit: FlexFit.tight,
                                      child: Container(
                                          child: widget.estadoConversacion ==
                                                  "Escribiendo"
                                              ? Text(
                                                  "Escribiendo.....",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(40),
                                                      fontWeight:
                                                          cantidadMensajesSinLeer >
                                                                  0
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal),
                                                )
                                              : widget.ultimoMensaje == null
                                                  ? Container()
                                                  : widget.ultimoMensaje[
                                                              "tipoMensaje"] ==
                                                          "texto"
                                                      ? Text(widget.ultimoMensaje[
                                                                      "mensaje"] ==
                                                                  null ||
                                                              widget.ultimoMensaje[
                                                                      "mensaje"] ==
                                                                  "null"
                                                          ? ""
                                                          : widget.ultimoMensaje[
                                                              "mensaje"])
                                                      : widget.ultimoMensaje[
                                                                  "tipoMensaje"] ==
                                                              "audio"
                                                          ? Row(children: [
                                                              Icon(Icons.mic,
                                                                  color: Colors
                                                                      .black),
                                                              Text(mostrarDuracion(
                                                                  widget.ultimoMensaje[
                                                                      "duracion"]))
                                                            ])
                                                          : widget.ultimoMensaje[
                                                                      "tipoMensaje"] ==
                                                                  "imagen"
                                                              ? Row(
                                                                  children: [
                                                                    Icon(Icons
                                                                        .image),
                                                                    Text(
                                                                        "Imagen")
                                                                  ],
                                                                )
                                                              : widget.ultimoMensaje[
                                                                      "tipoMensaje"] ==
                                                                  "gif"
                                                              ? Row(
                                                                  children: [
                                                                    Icon(Icons
                                                                        .image),
                                                                    Text(
                                                                        "Gif")
                                                                  ],
                                                                ):Container()),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 80.w,
                                  width: 80.w,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cantidadMensajesSinLeer > 0
                                          ? Colors.purple
                                          : Colors.transparent),
                                  child: Center(
                                    child: Text(
                                      "$cantidadMensajesSinLeer",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil().setSp(30)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
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
  Function marcarLeidoMensaje;
  Function marcarMensajeLeidoRemitente;
  Function enviarMensajeImagenGif;
  String estadoEscribiendoRemitente;
  Function estadoConexion;

  String nombre;
  String imagenId;
  String mensajeId;
  String idConversacion;
  Function mensajesEnviar;
  String idRemitente;
  int cantidadMensajes;

  bool esGrupo;
  bool estadoConexionRemitente = false;
  List<Mensajes> mensajesTemporales = new List();

  PantallaConversacion({
    @required this.estadoConexion,
    @required this.enviarMensajeImagenGif,
    @required this.idConversacion,
    @required this.marcarLeidoMensaje,
    @required this.marcarMensajeLeidoRemitente,
    @required this.recibirEstadoConversacionActualizado,
    @required this.estadoEscribiendoRemitente,
    @required this.estadoConversacion,
    @required this.mensajesImagen,
    @required this.mensajesTexto,
    @required this.mensajesAudio,
    @required this.nombre,
    @required this.idRemitente,
    @required this.mensajesEnviar,
    @required this.mensajeId,
    @required this.esGrupo,
    @required this.imagenId,
  });
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PantallaConversacionState();
  }
}

class PantallaConversacionState extends State<PantallaConversacion>
    with SingleTickerProviderStateMixin {
  String mensajeTemp;
  bool construido = false;
  bool mostrarBotonBajarRapido = true;
  bool mostrarBotonEnvio = false;
  bool estaGrabando = false;
  FlutterAudioRecorder recorder;
  Io.File punteroGrabacion;
  String estado = " ";
  File imagen;
  bool primerosMensajesAudioCargados = false;
  bool continuaEscribiendo = false;
  ImagePicker imagePicker = new ImagePicker();
  bool conversacionExiste;
  DatosPerfiles perfilRemitente;
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    Conversacion.calcularCantidadMensajesSinLeer();
    super.dispose();
  }

  void detectarConversacionExiste() {
    conversacionExiste = false;

    for (int i = 0;
        i < Conversacion.conversaciones.listaDeConversaciones.length;
        i++) {
      if (Conversacion.conversaciones.listaDeConversaciones[i].idConversacion ==
          widget.idConversacion) {
        conversacionExiste = true;
      }
    }
  }

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

  void dialogoConversacionEliminada(BuildContext context) {
    showDialog(
        useSafeArea: true,
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 1000.h,
                  width: ScreenUtil.screenWidth,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Conversacion eliminada",
                          style: TextStyle(
                              fontSize: 90.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70),
                        ),
                        Divider(height: 100.h),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Container(
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Entendido",
                                            style: TextStyle(
                                                fontSize: 60.sp,
                                                color: Colors.white)),
                                        Icon(Icons.check_circle,
                                            color: Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ),
                      ]),
                  color: Colors.transparent,
                ),
              ),
            ),
          );
        });
  }

  void mostrarOpcionesConversacion(BuildContext context) {
    showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 1000.h,
                  width: ScreenUtil.screenWidth,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Opciones chat",
                          style: TextStyle(
                              fontSize: 90.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70),
                        ),
                        Divider(height: 100.h),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);

                                mostrarOpcionesEliminacionConversacion(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Container(
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Eliminar conversacion",
                                            style: TextStyle(
                                                fontSize: 60.sp,
                                                color: Colors.white)),
                                        Icon(Icons.delete, color: Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: GestureDetector(
                              onTap: () {
                                if (perfilRemitente != null) {
                                  mostrarPerfilRemitente(
                                      context, perfilRemitente);
                                }
                                if (perfilRemitente == null) {
                                  Perfiles.cargarIsolatePerfilDeterminado(
                                          widget.idRemitente)
                                      .then((value) {
                                    perfilRemitente = value;
                                    mostrarPerfilRemitente(
                                        context, perfilRemitente);
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Container(
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Ver perfil remitente",
                                            style: TextStyle(
                                                fontSize: 60.sp,
                                                color: Colors.white)),
                                        Icon(Icons.image, color: Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20),
                                child: Container(
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, right: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Denunciar usuario",
                                            style: TextStyle(
                                                fontSize: 60.sp,
                                                color: Colors.white)),
                                        Icon(Icons.report, color: Colors.white)
                                      ],
                                    ),
                                  ),
                                ),
                              )),
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
                      ]),
                  color: Colors.transparent,
                ),
              ),
            ),
          );
        });
  }

  void mostrarPerfilRemitente(BuildContext context, DatosPerfiles perfil) {
    showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: ScreenUtil.screenHeight,
                  width: ScreenUtil.screenWidth,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ListView(
                            children: perfil.carrete,
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
                      ]),
                  color: Colors.transparent,
                ),
              ),
            ),
          );
        });
  }

  void mostrarOpcionesEliminacionConversacion(BuildContext context) {
    showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 1000.h,
                  width: ScreenUtil.screenWidth,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Eliminar conversacion",
                          style: TextStyle(
                              fontSize: 90.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70),
                        ),
                        Divider(height: 100.h),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15.0, right: 15),
                              child: Text("¿Eliminar conversacion?",
                                  style: TextStyle(
                                      fontSize: 60.sp, color: Colors.white)),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Conversacion.eliminarConversaciones(
                                        widget.idConversacion,
                                        widget.idRemitente,
                                        widget.mensajeId);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Container(
                                      height: 100.h,
                                      width: 400.w,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Si",
                                                style: TextStyle(
                                                    fontSize: 60.sp,
                                                    color: Colors.white)),
                                            Icon(Icons.delete,
                                                color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Container(
                                      height: 100.h,
                                      width: 400.w,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, right: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("No",
                                                style: TextStyle(
                                                    fontSize: 60.sp,
                                                    color: Colors.white)),
                                            Icon(Icons.arrow_back,
                                                color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                            ),
                          ],
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
                      ]),
                  color: Colors.transparent,
                ),
              ),
            ),
          );
        });
  }

  void confirmarVideoLLamada() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Videollamada"),
            content: Text("¿Quieres llamar a ${widget.nombre}?"),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        llamadaVideo();
                      },
                      child: Row(
                        children: <Widget>[
                          Text("Llamar"),
                          Icon(LineAwesomeIcons.video_camera)
                        ],
                      )),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: <Widget>[
                          Text("Cancelar"),
                          Icon(Icons.cancel)
                        ],
                      )),
                ],
              )
            ],
          );
        });
  }

  abrirGaleria(BuildContext context) async {
    var status = await Permission.storage.status;
    if (status.isUndetermined) {
      Permission.storage.request().then((value) async {
        if (value.isGranted) {
          var archivoImagen =
              await imagePicker.getImage(source: ImageSource.gallery);
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
        } else {
          Permission.storage.request();
        }
      });
    }
    if (status.isGranted) {
      var archivoImagen =
          await imagePicker.getImage(source: ImageSource.gallery);
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
      if (status.isDenied) {
        Navigator.pop(context);
      }
    }
  }

  abrirCamara(BuildContext context) async {
    var status = await Permission.camera.status;
    if (status.isUndetermined) {
      Permission.storage.request().then((value) async {
        if (value.isGranted) {
          var archivoImagen =
              await imagePicker.getImage(source: ImageSource.camera);
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
        } else {
          Permission.storage.request();
        }
      });
    }
    if (status.isGranted) {
      var archivoImagen =
          await imagePicker.getImage(source: ImageSource.camera);
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
      if (status.isDenied) {
        Navigator.pop(context);
      }
    }
  }

  ScrollController controlador = new ScrollController();
  void emprezarListaAbajo() {
    print("Construido");
    var timer = Timer(Duration(milliseconds: 50), () {
      print("Construido");
      construido = true;
      controlador.jumpTo(controlador.position.maxScrollExtent);
      Conversacion.conversaciones.notifyListeners();
    });
    if (construido) {
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
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      });
    }
  }

  void mostrarBotonAbajo() {
    if (controlador.positions.isNotEmpty &&
        controlador.position.maxScrollExtent != null) {
      if (controlador.position.pixels <
              controlador.position.maxScrollExtent * 0.80 &&
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
    if (mostrarBotonEnvio) {
      mostrarBotonEnvio = false;
      Conversacion.conversaciones.notifyListeners();
    }
  }

  void iniciarGrabacionAudio() async {
    bool permisoAudio = false;
    await Permission.microphone.status.then((value) async {
      if (!value.isGranted) {
        await Permission.microphone.request().then((value) {
          if (value.isGranted) {
            permisoAudio = true;
          }
          if (!value.isGranted) {
            permisoAudio = false;
          }
        });
      }
      if (value.isGranted) {
        permisoAudio = true;
      }
    });

    if (permisoAudio) {
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

  void pararGrabacion(bool completada, int duracion) async {
    if (completada) {
      await recorder.stop();

      Uint8List audio = punteroGrabacion.readAsBytesSync();
      print(audio);
      widget.mensajesAudio(audio, widget.mensajeId, duracion);
    }
    if (!completada) {
      await recorder.stop().then((value) async {
        await punteroGrabacion.delete();
      });
    }
  }

  void llamadaVideo() async {
    bool video = false;
    bool audio = false;
    await Permission.microphone.status.then((value) async {
      if (!value.isGranted) {
        await Permission.microphone.request().then((value) {
          if (value.isGranted) {
            audio = true;
          }
          if (!value.isGranted) {
            audio = false;
          }
        });
      }
      if (value.isGranted) {
        audio = true;
      }
    });

    await Permission.camera.status.then((value) async {
      if (!value.isGranted) {
        await Permission.camera.request().then((value) {
          if (value.isGranted) {
            video = true;
          }
          if (!value.isGranted) {
            video = false;
          }
        });
      }
      if (value.isGranted) {
        video = true;
      }
    });
    if (video && audio) {
      VideoLlamada.iniciarComunicacionLlamada(widget.idRemitente, context);
    }
  }

  TextEditingController controladorTexto = new TextEditingController();

  Widget build(BuildContext context) {
    bool empezarListaAbajo = true;
    if (controlador.hasClients) {
      SchedulerBinding.instance.addPostFrameCallback((_) {});
    }

    return ChangeNotifierProvider.value(
      value: Conversacion.conversaciones,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Consumer<Conversacion>(
            builder: (BuildContext context, conversacion, Widget child) {
              detectarConversacionExiste();
              widget.marcarMensajeLeidoRemitente();

              widget.marcarLeidoMensaje();
              widget.cantidadMensajes = widget.mensajesTemporales.length;
              widget.mensajesTemporales = widget.mensajesTexto();

              if (widget.mensajesTemporales.isEmpty) {
                emprezarListaAbajo();
              }
              if (widget.mensajesTemporales.length > widget.cantidadMensajes) {
                moverChatAbajo();
              }

              if (!primerosMensajesAudioCargados &&
                  widget.mensajesTemporales != null) {
                for (int i = 0; i < widget.mensajesTemporales.length; i++) {
                  if (widget.mensajesTemporales[i].tipoMensaje == "Audio" &&
                      widget.mensajesTemporales[i].duracionMensaje == null) {}
                }
                primerosMensajesAudioCargados = true;
              }
              print(estado);
              estado = widget.recibirEstadoConversacionActualizado();
              widget.estadoConexionRemitente = widget.estadoConexion();

              return Stack(
                
                children: [
                 
                  Scaffold(
                    appBar: AppBar(
                        elevation: 0,
                        iconTheme: IconThemeData(color: Colors.black),
                        backgroundColor: Colors.white,
                        shadowColor: Colors.black,
                        title: Center(
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  widget.nombre,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(40),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    height: ScreenUtil()
                                                        .setWidth(35),
                                                    width: ScreenUtil()
                                                        .setWidth(35),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: widget
                                                                  .estadoConexionRemitente
                                                              ? Colors
                                                                  .transparent
                                                              : Colors
                                                                  .transparent,
                                                          width: ScreenUtil()
                                                              .setSp(5)),
                                                      color: widget
                                                              .estadoConexionRemitente
                                                          ? Colors.green
                                                          : Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              estado == " " &&
                                                      widget
                                                          .estadoConexionRemitente
                                                  ? "En linea"
                                                  : estado,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(30),
                                                  color: Colors.black),
                                            )
                                          ]),
                                    ),
                                  ],
                                ),
                                IconButton(
                                    icon: Icon(
                                      LineAwesomeIcons.video_camera,
                                      color: Colors.black,
                                    ),
                                    onPressed: () async {
                                      confirmarVideoLLamada();
                                    }),
                                IconButton(
                                    icon: Icon(
                                      Icons.menu,
                                      color: Colors.black,
                                    ),
                                    onPressed: () async {
                                      mostrarOpcionesConversacion(context);
                                    })
                              ],
                            ),
                          ),
                        )),
                    resizeToAvoidBottomPadding: true,
                    resizeToAvoidBottomInset: true,
                    primary: false,
                    backgroundColor: Color.fromRGBO(20, 20, 10, 100),
                    body: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints limites) {
                      return SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        reverse: true,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                                Container(
                                  
                                  
                    height: limites.maxHeight,
                    width: limites.maxWidth,
                    decoration: BoxDecoration(
                      
                        image: DecorationImage(
                            image: NetworkImage(
                              widget.imagenId,
                            ),
                            fit: BoxFit.cover)),
                  ),
                    
                            Container(
                              height: limites.biggest.height,
                              color: Color.fromRGBO(20, 20, 20, 60),
                              child: Column(children: [
                                Container(
                                  
                                  height: limites.biggest.height -
                                      ScreenUtil().setHeight(200),
                                  child: Stack(children: [
                                    NotificationListener<ScrollUpdateNotification>(
                                      // ignore: missing_return
                                      onNotification: (val) {
                                        mostrarBotonAbajo();
                                      },
                                      child: ListView.builder(
                                        controller: controlador,
                                        itemCount: widget.mensajesTemporales.length,
                                        itemBuilder:
                                            (BuildContext context, indice) {
                                          if (empezarListaAbajo) {
                                            emprezarListaAbajo();
                                            empezarListaAbajo = false;
                                          }
                                          mostrarBotonAbajo();
                                          return widget.mensajesTemporales[indice];
                                        },
                                      ),
                                    ),
                                    mostrarBotonBajarRapido
                                        ? botonBajarChatRapido()
                                        : Container(),
                                  ]),
                                ),
                                Container(
                                    color: Colors.transparent,
                                    height: ScreenUtil().setHeight(200),
                                    child: entradaMensajes(context))
                              ]),
                            ),
                                 
                          ],
                        ),
                      );
                    }),
                  ),
                  !conversacionExiste
                      ? Material(
                          color: Color.fromRGBO(20, 20, 20, 50),
                          child: Container(
                            height: ScreenUtil.screenHeight -
                                kBottomNavigationBarHeight,
                            width: ScreenUtil.screenWidth,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Esta conversacion ha sido eliminada",
                                        style: TextStyle(
                                            fontSize: 50.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      Divider(height: 200.h),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20.0, right: 20),
                                        child: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0, right: 20),
                                              child: Container(
                                                height: 100.h,
                                                decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15.0,
                                                          right: 15),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text("Entendido",
                                                          style: TextStyle(
                                                              fontSize: 60.sp,
                                                              color: Colors
                                                                  .white)),
                                                      Icon(Icons.check_circle,
                                                          color: Colors.white)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ]),
                              ),
                            ),
                            color: Color.fromRGBO(20, 20, 20, 50),
                          ),
                        )
                      : Container()
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Padding botonBajarChatRapido() {
    return Padding(
      padding: const EdgeInsets.only(right: 25.0, bottom: 10),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          height: ScreenUtil().setHeight(200),
          decoration:
              BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(Icons.arrow_downward),
            onPressed: () => moverChatAbajoLento(),
          ),
        ),
      ),
    );
  }

  Flexible visorMensajes(BuildContext context,
      List<Mensajes> mensajesTemporales, bool empezarListaAbajo) {
    return Flexible(
      flex: 25,
      fit: FlexFit.tight,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          child: ListView.builder(
            controller: controlador,
            itemCount: mensajesTemporales.length,
            itemBuilder: (BuildContext context, indice) {
              if (empezarListaAbajo) {
                emprezarListaAbajo();
                empezarListaAbajo = false;
              }
              mostrarBotonAbajo();
              return mensajesTemporales[indice];
            },
          ),
        ),
      ),
    );
  }

  Positioned botonBajarFinal() {
    return Positioned(
        left: ScreenUtil().setWidth(1100),
        bottom: ScreenUtil().setHeight(400),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: Colors.grey),
          width: ScreenUtil().setWidth(200),
          child: FlatButton(
            onPressed: () {
              moverChatAbajoLento();
            },
            child: Center(child: Icon(Icons.arrow_downward)),
          ),
        ));
  }

  Widget entradaMensajes(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: IconButton(
                    iconSize: 90.sp,
                    color: Colors.white,
                    onPressed: () async {
                      final gif = await GiphyPicker.pickGif(
                          context: context,
                          apiKey: "vP5aepaZgPJxh3uVvRjYPcm2cWoFmJpd");
                      print(gif.images.original.url);
                      widget.enviarMensajeImagenGif(
                          gif.images.original.url, widget.mensajeId);
                    },
                    icon: Icon(LineAwesomeIcons.smile_o),
                  ),
                ),
                Flexible(
                  flex: 9,
                  fit: FlexFit.tight,
                  child: GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Colors.white,
                      ),
                      child: RawKeyboardListener(
                        onKey: (tecla) {
                          setState(() {
                            print("cambio teclado");
                          });
                        },
                        focusNode: _focusNode,
                        autofocus: true,
                        child: TextField(
                          
                          controller: controladorTexto,
                       
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(3000)
                          ],
                          decoration: InputDecoration(),
                          minLines: null,
                          maxLines: null,
                          onChanged: (valor) {
                            if ((valor != null ||
                                valor != " " ||
                                valor.isNotEmpty ||
                                valor.length > 0)) {
                              mostrarBotontexto();

                              if (mostrarBotonEnvio && !continuaEscribiendo) {
                                widget.estadoConversacion(true);
                                continuaEscribiendo = true;
                              }
                            }
                            if (valor == null ||
                                valor == " " ||
                                valor.isEmpty) {
                              ocultarBotonEnvio();
                              if (!mostrarBotonEnvio) {
                                widget.estadoConversacion(false);
                                continuaEscribiendo = false;

                                mostrarBotonEnvio = false;
                              }
                            }
                            mensajeTemp = valor;
                          },
                          textInputAction: TextInputAction.done,
                          onSubmitted: (valor) {
                            widget.estadoConversacion(false);

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
                  ),
                ),
                mostrarBotonEnvio
                    ? Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: FlatButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();

                              widget.mensajesEnviar(
                                  mensajeTemp, widget.mensajeId);
                              controladorTexto.clear();
                              print("enviando");

                              widget.estadoConversacion(false);
                            },
                            child: Icon(
                              LineAwesomeIcons.send,
                              color: Colors.white,
                            ),
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
                              child: IconButton(
                                iconSize: 90.sp,
                                color: Colors.white,
                                onPressed: () {
                                  iniciarGrabacionAudio();
                                  dialogoIniciarGrabacion(context);
                                },
                                icon: Icon(LineAwesomeIcons.microphone),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: IconButton(
                                color: Colors.white,
                                icon:Icon(Icons.add_photo_alternate) ,
                                iconSize: 90.sp,
                                onPressed: () {
                                  opcionesImagenPerfil();
                                },
                               
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void dialogoIniciarGrabacion(BuildContext context) {
    showGeneralDialog(
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 100),
        context: context,
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondanimation) {
          return DialogoGrabacion(pararGrabacion: pararGrabacion);
        });
  }
}

class CallPage extends StatefulWidget {
  static FirebaseFirestore basedatos = FirebaseFirestore.instance;
  static bool canalIniciado = false;
  final Map<String, dynamic> datosLLamada;
  final String usuario;

  /// non-modifiable channel name of the page
  final String channelName;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  CallPage(
      {Key key,
      @required this.channelName,
      @required this.role,
      @required this.datosLLamada,
      @required this.usuario});

  @override
  CallPageState createState() => CallPageState();
}

class CallPageState extends State<CallPage> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  Future<void> initialize() async {
    if (VideoLlamada.idAplicacion.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = Size(640, 320);
    await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(VideoLlamada.idAplicacion);
    await AgoraRtcEngine.enableVideo();
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
        VideoLlamada.ponerStatusDisponible();
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        VideoLlamada.ponerStatusOcupado();
        final info = 'onJoinChannel: $channel, uid: $uid';
        CallPage.canalIniciado = true;
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        VideoLlamada.ponerStatusDisponible();
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        print("Usuario en el canal^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        VideoLlamada.ponerStatusDisponible();
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        // Navigator.pop(context);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(AgoraRenderWidget(0, local: true, preview: true));
    }
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
              onCallEnd(context);
              VideoLlamada.colgarLLamadaVideo(
                  widget.usuario, widget.datosLLamada);

              print(widget.datosLLamada);
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static void onCallEnd(BuildContext context) {
    Navigator.pop(context);
    CallPage.canalIniciado = false;
    print("LLamada colgada y rechazasda que triste");
    VideoLlamada.ponerStatusDisponible();
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: <Widget>[
              _viewRows(),
              _panel(),
              Container(
                color: Colors.transparent,
                child: !CallPage.canalIniciado
                    ? Center(
                        child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white),
                        height: ScreenUtil().setHeight(300),
                        width: ScreenUtil().setWidth(600),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            Text("Cargando llamada"),
                          ],
                        ),
                      ))
                    : null,
              ),
              _toolbar(),
            ],
          ),
        ),
      ),
    );
  }
}

class DialogoGrabacion extends StatefulWidget {
  Function pararGrabacion;
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

    print("solamente tu");
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
    return Container(
        color: Colors.white,
        child: LayoutBuilder(builder: (
          BuildContext context,
          BoxConstraints limites,
        ) {
          return Container(
            height: limites.biggest.height,
            width: limites.biggest.width,
            color: Colors.black,
            child: Image.network(imagen),
          );
        }));
  }
}
