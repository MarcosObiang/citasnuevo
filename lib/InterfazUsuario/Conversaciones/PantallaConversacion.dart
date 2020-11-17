import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:io' as Io;

import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/WrapperLikes.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/Mensajes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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
                                  
                                    Conversacion.eliminarConversaciones(
                                        widget.idConversacion,
                                        widget.idRemitente,
                                        widget.mensajeId).then((value) {
                                          if(value==0){
                                            Navigator.pop(context);
                                            
                                          }
                                          if(value==1){
                                              Navigator.pop(context);
                                            print("error");
                                          }
                                        });
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
      child: WillPopScope(
        onWillPop: ()async{
           widget.estadoConversacion(false);
            return true;
        },
              child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Consumer<Conversacion>(
              builder: (BuildContext context, conversacion, Widget child) {
                detectarConversacionExiste();
                widget.marcarMensajeLeidoRemitente();

               
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
                                  Flexible(
                                    flex: 5,
                                    fit: FlexFit.tight,
                                                                      child: Row(
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
                                  ),
                                  Flexible(
                                    flex:2,
                                    fit: FlexFit.tight,
                                                                      child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                            icon: Icon(
                                              LineAwesomeIcons.video_camera,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              confirmarVideoLLamada();
                                            }),
                                      ],
                                    ),
                                  ),
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