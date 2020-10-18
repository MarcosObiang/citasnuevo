import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/Gente/people_screen_elements.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:provider/provider.dart';

import '../base_app.dart';

class VideoLlamada {
  static String usaurioId = Usuario.esteUsuario.idUsuario;
  static String imagenUsuaerio = obtenerImagenUsuarioLocal();
  static const String idAplicacion = "89a6508f23d34bdeb3cb998a5642c770";
  String canalUsuario;
  static FirebaseFirestore basedatos = FirebaseFirestore.instance;
  static FirebaseFirestore escuchadorEstadoLLamada = FirebaseFirestore.instance;

  // ignore: unused_element
  Future<void> _initAgoraRtcEngine() async {
    AgoraRtcEngine.create(idAplicacion);

    AgoraRtcEngine.enableVideo();
    AgoraRtcEngine.enableAudio();

    AgoraRtcEngine.setChannelProfile(ChannelProfile.Communication);

    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.orientationMode = VideoOutputOrientationMode.FixedPortrait;
    AgoraRtcEngine.setVideoEncoderConfiguration(config);
  }

  static String obtenerImagenUsuarioLocal() {
    bool imagenAdquirida = false;
    String imagen;
    if (Usuario.esteUsuario.ImageURL1["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL1["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL2["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL2["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL3["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL3["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL4["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL4["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL5["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL5["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL6["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL6["Imagen"];
      imagenAdquirida = true;
    }
    return imagen;
  }

  static void establecerEstadoLLamada() async {
    Map<String, dynamic> datosLLamada = new Map();
    datosLLamada["Estado"] = "Disponible";

    await basedatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estadoLlamada")
        .doc("estadoLlamada")
        .set(datosLLamada)
        .then((value) {
      escucharLLamadasEntrantes();
    });
  }

  static void ponerStatusOcupado() async {
    Map<String, dynamic> datosLLamada = new Map();
    datosLLamada["Estado"] = "Ocpuado";
    await basedatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estadoLlamada")
        .doc("estadoLlamada")
        .set(datosLLamada);
  }

  static void ponerStatusDisponible() async {
    Map<String, dynamic> datosLLamada = new Map();
    datosLLamada["Estado"] = "Disponible";
    await basedatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estadoLlamada")
        .doc("estadoLlamada")
        .set(datosLLamada);
  }

  static void iniciarComunicacionLlamada(
      String usuario, BuildContext context) async {
    String resultado;

    await basedatos
        .collection("usuarios")
        .doc(usuario)
        .collection("estadoLlamada")
        .doc("estadoLlamada")
        .get()
        .then((value) {
      if (value.get("Estado") == "Disponible") {
        resultado = "Disponible";
      }
      if (value.get("Estado") == "Desconectado") {
        resultado = "Desconectado";
      }
      if (value.get("Estado") == "Ocupado") {
        resultado = "Ocupado";
      }
    });

    if (resultado == "Disponible") {
      iniciarLLamadaVideo(usuario, context);
    } else {
      print("No se piuede llamar al usuario");
    }
  }

  static void colgarLLamadaVideo(
      String usuario, Map<String, dynamic> datosLLamada) async {
    print(datosLLamada["StatusLLamada"]);

    datosLLamada.update("StatusLLamada", (value) => "Rechazada",
        ifAbsent: () => "Rechazada");

    datosLLamada["StatusLLamada"] = "Rechazada";

    await basedatos
        .collection("usuarios")
        .doc(usuario)
        .collection("llamadas")
        .doc(datosLLamada["id LLamada"])
        .set(datosLLamada)
        .then((value) async {
      await basedatos
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("llamadas")
          .doc(datosLLamada["id LLamada"])
          .set(datosLLamada);
    });
  }

  static void contestarLLamadaVideo(String usuarioId, BuildContext context,
      Map<String, dynamic> datosLLamada) async {
    Map<String, dynamic> estadoLLamada = new Map();
    estadoLLamada["Estado"] = "Ocpuado";
    datosLLamada["StatusLLamada"] = "Conectado";
    await basedatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estadoLlamada")
        .doc("estadoLlamada")
        .set(estadoLLamada)
        .then((value) async {
      await basedatos
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("llamadas")
          .doc(datosLLamada["id LLamada"])
          .set(datosLLamada)
          .then((value) async {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CallPage(
                    datosLLamada: datosLLamada,
                    usuario: usuarioId,
                    channelName: usuarioId,
                    role: ClientRole.Broadcaster)));
      });
    });
  }

  static void iniciarLLamadaVideo(String usuario, BuildContext context) async {
    Map<String, dynamic> datosLLamada = new Map();
    String idLLamadaVideo = Solicitud.instancia.crearCodigo();
    datosLLamada["ImagenLlamadaEntrante"] =
        VideoLlamada.obtenerImagenUsuarioLocal();
    datosLLamada["Nombre"] = Usuario.esteUsuario.nombre;
    datosLLamada["idCanalLLamada"] = Usuario.esteUsuario.idUsuario;
    datosLLamada["StatusLLamada"] = "Conectando";
    datosLLamada["id LLamante"] = Usuario.esteUsuario.idUsuario;
    datosLLamada["DuracionLLamada"] = DateTime.now();
    datosLLamada["idRemitente"] = usuario;
    datosLLamada["id LLamada"] = idLLamadaVideo;
    datosLLamada["tipoLlamada"] = "Video";

    await basedatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("llamadas")
        .doc(idLLamadaVideo)
        .set(datosLLamada)
        .then((valor) async {
      await basedatos
          .collection("usuarios")
          .doc(usuario)
          .collection("llamadas")
          .doc(idLLamadaVideo)
          .set(datosLLamada)
          .then((value) async {
        escuchadorEstadoLLamada
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("llamadas")
            .doc(idLLamadaVideo)
            .snapshots()
            .listen((event) async {
          if (event.get("StatusLLamada") == "Rechazada") {
            await escuchadorEstadoLLamada
                .collection("usuarios")
                .doc(Usuario.esteUsuario.idUsuario)
                .collection("llamadas")
                .doc(idLLamadaVideo)
                .snapshots()
                .listen((event) {})
                .cancel()
                .then((value) {
              CallPageState.onCallEnd(context);
            });
          }
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CallPage(
                    datosLLamada: datosLLamada,
                    usuario: usuario,
                    channelName: Usuario.esteUsuario.idUsuario,
                    role: ClientRole.Broadcaster)));
      });
    });

    print("Llamada iniciada");
  }

  static void escucharLLamadasEntrantes() {
    basedatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("llamadas")
        .where("StatusLLamada", isEqualTo: "Conectando")
        .snapshots()
        .listen((event) {
      if (event.docs.length > 0) {
        for (DocumentSnapshot llamada in event.docs) {
          if (llamada.get("id LLamante") != Usuario.esteUsuario.idUsuario) {
            notificarLLamada(
                BaseAplicacion.claveNavegacion.currentContext,
                llamada.get("ImagenLlamadaEntrante"),
                llamada.get("Nombre"),
                llamada.get("id LLamada"),
                llamada.get("idCanalLLamada"),
                llamada.get("StatusLLamada"),
                llamada.get("id LLamante"),
                llamada.get("idRemitente"),
                llamada.get("tipoLlamada"));
          } else {
            print("llamadaPropia");
          }
        }
      }
    });
  }

  static void notificarLLamada(
      BuildContext context,
      String imagen,
      String nombreUsuario,
      String idLLamada,
      String canalLLamada,
      String statusLLamasda,
      String idLLamante,
      String idRemitente,
      String tipoLLamada) async {
    Map<String, dynamic> datosLLamada = new Map();
    datosLLamada["ImagenLlamadaEntrante"] = imagen;
    datosLLamada["Nombre"] = nombreUsuario;
    datosLLamada["idCanalLLamada"] = canalLLamada;
    datosLLamada["StatusLLamada"] = "Conectando";
    datosLLamada["id LLamante"] = idLLamante;
    datosLLamada["DuracionLLamada"] = DateTime.now();
    datosLLamada["idRemitente"] = idRemitente;
    datosLLamada["id LLamada"] = idLLamada;
    datosLLamada["tipoLlamada"] = "Video";
    showGeneralDialog(
        barrierDismissible: true,
        barrierLabel: "",
        transitionDuration: const Duration(milliseconds: 200),
        context: BaseAplicacion.claveNavegacion.currentContext,
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondanimation) {
          // cargarPerfil();

          return ChangeNotifierProvider.value(
            value: Usuario.esteUsuario,
            child: SafeArea(child: Consumer<Usuario>(
              builder: (context, myType, child) {
                return Container(
                  height: ScreenUtil().setHeight(1000),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Color.fromRGBO(20, 20, 20, 50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Text(
                                    "Videollamada entrante",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(60)),
                                  )),
                            ),
                            Expanded(
                                child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      image: DecorationImage(
                                          image: NetworkImage(imagen),
                                          fit: BoxFit.cover)),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Container(
                                          height: ScreenUtil().setHeight(150),
                                          width: ScreenUtil().setWidth(150),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red),
                                          child: IconButton(
                                            color: Colors.white,
                                            icon: Icon(Icons.call_end),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              colgarLLamadaVideo(
                                                  idLLamante, datosLLamada);
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Container(
                                          height: ScreenUtil().setHeight(150),
                                          width: ScreenUtil().setWidth(150),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green),
                                          child: IconButton(
                                              color: Colors.white,
                                              icon: Icon(Icons.call),
                                              onPressed: () {
                                                // Navigator.pop(context);
                                                contestarLLamadaVideo(
                                                    canalLLamada,
                                                    context,
                                                    datosLLamada);
                                              }),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )),
          );
        });
  }
}