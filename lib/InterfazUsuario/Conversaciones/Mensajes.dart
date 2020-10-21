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
import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
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
