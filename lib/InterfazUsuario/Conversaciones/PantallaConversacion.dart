import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:io' as Io;

import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorDenuncias.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorPermisos.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/WrapperLikes.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/pantalla_actividades_elements.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/ListaConversaciones.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/Mensajes.dart';
import 'package:citasnuevo/InterfazUsuario/WidgetError.dart';
import 'package:citasnuevo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
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
  static bool responderMensaje = false;
  static String idEmisorMensajeResponder;
  static String idMensajeResponder;
  static String nombreEmisorMensajeResponder;
  static String mensajeResponder;
  static String tipoMensaje;
  String nombre;
  String imagenId;
  String mensajeId;
  String idConversacion;
  Function mensajesEnviar;
  String idRemitente;
  int cantidadMensajes;
  static final GlobalKey llavePantallaConversacion = new GlobalKey();
  bool esGrupo;
  bool estadoConexionRemitente = false;
  List<Mensajes> mensajesTemporales = new List();
  static String nombreExponer;


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
    with SingleTickerProviderStateMixin,RouteAware {
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
    @override void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
      // TODO: implement didChangeDependencies
      super.didChangeDependencies();
    }





    void didPopNext() {
      
    debugPrint("didPopNext ${runtimeType}");

  
  }

  // Called when the current route has been pushed.
  void didPush() {
    debugPrint("didPush ${runtimeType}");
  }

  // Called when the current route has been popped off.
  void didPop() {
  


    debugPrint("didPop ${runtimeType}");
  }

  // Called when a new route has been pushed, and the current route is no longer visible.
  void didPushNext() {
    
    debugPrint("didPushNext ${runtimeType}");
  }

  @override
  void initState() {
    // TODO: implement initState
  for(int i=0;i<Conversacion.conversaciones.listaDeConversaciones.length;i++){
    if(Conversacion.conversaciones.listaDeConversaciones[i].idConversacion==widget.idConversacion){
      PantallaConversacion.nombreExponer=Conversacion.conversaciones.listaDeConversaciones[i].nombreRemitente;
      print(PantallaConversacion.nombreExponer);
    }
  }
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    Conversacion.conversaciones.calcularCantidadMensajesSinLeer();
    PantallaConversacion.responderMensaje = false;
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

                                mostrarOpcionesEliminacionConversacion(
                                    context, false);
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
                                                fontSize: 45.sp,
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
                                Navigator.pop(context);

                                mostrarOpcionesEliminacionConversacion(
                                    context, true);
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
                                        Text("Eliminar y bloquear",
                                            style: TextStyle(
                                                fontSize: 45.sp,
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
                                                fontSize: 45.sp,
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
                              onTap: () => mostrarOpcionesDenuncias(context),
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
                                                fontSize: 45.sp,
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

  void mostrarOpcionesEliminacionConversacion(
      BuildContext context, bool bloquear) {
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
                          !bloquear
                              ? "Eliminar conversacion"
                              : "Eliminar y bloquear",
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
                              child: Text(
                                  !bloquear
                                      ? "¿Eliminar conversacion?"
                                      : "¿Eliminar y bloquear?",
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
                                            widget.mensajeId,
                                            bloquear)
                                        .then((value) {
                                      if (value == 0) {
                                        Navigator.pop(context);
                                      }
                                      if (value == 1) {
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
            widget.mensajesImagen(imagen, widget.mensajeId,
                PantallaConversacion.responderMensaje, {
              "mensaje": PantallaConversacion.mensajeResponder,
              "tipoMensaje": PantallaConversacion.tipoMensaje,
              "idMensaje": PantallaConversacion.idMensajeResponder,
              "idEmisorMensaje": PantallaConversacion.idEmisorMensajeResponder
            });
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
        widget.mensajesImagen(
            imagen, widget.mensajeId, PantallaConversacion.responderMensaje, {
          "mensaje": PantallaConversacion.mensajeResponder,
          "tipoMensaje": PantallaConversacion.tipoMensaje,
          "idMensaje": PantallaConversacion.idMensajeResponder,
          "idEmisorMensaje": PantallaConversacion.idEmisorMensajeResponder
        });
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
            widget.mensajesImagen(imagen, widget.mensajeId,
                PantallaConversacion.responderMensaje, {
              "mensaje": PantallaConversacion.mensajeResponder,
              "tipoMensaje": PantallaConversacion.tipoMensaje,
              "idMensaje": PantallaConversacion.idMensajeResponder,
              "idEmisorMensaje": PantallaConversacion.idEmisorMensajeResponder
            });
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
        widget.mensajesImagen(
            imagen, widget.mensajeId, PantallaConversacion.responderMensaje, {
          "mensaje": PantallaConversacion.mensajeResponder,
          "tipoMensaje": PantallaConversacion.tipoMensaje,
          "idMensaje": PantallaConversacion.idMensajeResponder,
          "idEmisorMensaje": PantallaConversacion.idEmisorMensajeResponder
        });
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
            duration: const Duration(milliseconds: 900),
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

  Future<bool> iniciarGrabacionAudio() async {
    bool iniciarGrabacion = false;

    if (ControladorPermisos.instancia.getPermisoMicrofono == false ||
        ControladorPermisos.instancia.getPermisoMicrofono == null) {
      EstadosPermisos permisos =
          await ControladorPermisos.instancia.comprobarPermisoMicrofono();

      if (permisos == EstadosPermisos.permisoConcedido) {
        iniciarGrabacion = true;
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
      } else {
        iniciarGrabacion = false;
      }
    }
    if (ControladorPermisos.instancia.getPermisoMicrofono == true) {
      iniciarGrabacion = true;
    }
    return iniciarGrabacion;
  }

  void pararGrabacion(bool completada, int duracion) async {
    if (completada) {
      await recorder.stop();

      Uint8List audio = punteroGrabacion.readAsBytesSync();
      print(audio);
      widget.mensajesAudio(audio, widget.mensajeId, duracion,
          PantallaConversacion.responderMensaje, {
        "mensaje": PantallaConversacion.mensajeResponder,
        "tipoMensaje": PantallaConversacion.tipoMensaje,
        "idMensaje": PantallaConversacion.idMensajeResponder,
        "idEmisorMensaje": PantallaConversacion.idEmisorMensajeResponder
      });
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
        onWillPop: () async {
          widget.estadoConversacion(false);
          return true;
        },
        child: Container(
          color: Colors.white,
          child: SafeArea(
            key: PantallaConversacion.llavePantallaConversacion,
            child: Consumer<Conversacion>(
              builder: (BuildContext context, conversacion, Widget child) {
                detectarConversacionExiste();
                widget.marcarMensajeLeidoRemitente();

                widget.cantidadMensajes = widget.mensajesTemporales.length;
                widget.mensajesTemporales = widget.mensajesTexto();

                if (widget.mensajesTemporales.isEmpty) {
                  emprezarListaAbajo();
                }
                if (widget.mensajesTemporales.length >
                    widget.cantidadMensajes) {
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
                          title: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                flex: 7,
                                fit: FlexFit.tight,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10),
                                  child: Container(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.nombre,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign:
                                                TextAlign.start,
                                            style: TextStyle(
                                                fontSize: ScreenUtil()
                                                    .setSp(40),
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                estado == " " &&
                                                        widget
                                                            .estadoConexionRemitente
                                                    ? "En linea"
                                                    : estado,
                                                textAlign: TextAlign.start,
                                                 overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: ScreenUtil()
                                                        .setSp(30),
                                                    color: Colors.black),
                                              ),
                                                 Padding(
                                                padding:
                                                    const EdgeInsets.all(
                                                        8.0),
                                                child: Container(
                                                  height: ScreenUtil()
                                                      .setWidth(35),
                                                  width: ScreenUtil()
                                                      .setWidth(35),
                                                  decoration:
                                                      BoxDecoration(
                                                    shape:
                                                        BoxShape.circle,
                                                    border: Border.all(
                                                        color: widget
                                                                .estadoConexionRemitente
                                                            ? Colors
                                                                .transparent
                                                            : Colors
                                                                .transparent,
                                                        width:
                                                            ScreenUtil()
                                                                .setSp(
                                                                    5)),
                                                    color: widget
                                                            .estadoConexionRemitente
                                                        ? Colors.green
                                                        : Colors
                                                            .transparent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ]),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
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
                              Flexible(
                                    flex: 2,
                                fit: FlexFit.tight,
                                child: IconButton(
                                    icon: Icon(
                                      Icons.menu,
                                      color: Colors.black,
                                    ),
                                    onPressed: () async {
                                      mostrarOpcionesConversacion(context);
                                    }),
                              )
                            ],
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
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: PantallaConversacion
                                                .responderMensaje
                                            ? limites.biggest.height -
                                                ScreenUtil().setHeight(600)
                                            : limites.biggest.height - 250.h,
                                        child: Stack(children: [
                                          NotificationListener<
                                              ScrollUpdateNotification>(
                                            // ignore: missing_return
                                            onNotification: (val) {
                                              mostrarBotonAbajo();
                                            },
                                            child: ListView.builder(
                                              controller: controlador,
                                              itemCount: widget
                                                  .mensajesTemporales.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      indice) {
                                                if (empezarListaAbajo) {
                                                  emprezarListaAbajo();
                                                  empezarListaAbajo = false;
                                                }
                                                mostrarBotonAbajo();
                                                return widget
                                                    .mensajesTemporales[indice];
                                              },
                                            ),
                                          ),
                                          mostrarBotonBajarRapido
                                              ? botonBajarChatRapido()
                                              : Container(),
                                        ]),
                                      ),
                                      Expanded(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.white, blurRadius: 15.sp)],
              color: Color.fromRGBO(20, 20, 20, 50),
              shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(
              Icons.arrow_downward,
              color: Colors.white,
            ),
            onPressed: () => moverChatAbajoLento(),
          ),
        ),
      ),
    );
  }

  Flexible visorMensajes(BuildContext context,
      List<Mensajes> mensajesTemporales, bool empezarListaAbajo) {
    return Flexible(
      flex: 30,
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
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.transparent),
        child: Column(
          children: [
            PantallaConversacion.responderMensaje
                ? Flexible(
                  flex: 10,
                  fit: FlexFit.tight,
                  child: cuadroRespuesta())
                : Flexible(
                  fit:FlexFit.tight,
                  flex:0,
                  child: Container(height: 0,width: 0,)),
            Flexible(
              fit: FlexFit.tight,
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: IconButton(
                        iconSize: 70.sp,
                        color: Colors.white,
                        onPressed: () async {

if(Citas.estaConectado){
    final gif = await GiphyPicker.pickGif(
                              fullScreenDialog: false,
                              context: context,
                              apiKey: "vP5aepaZgPJxh3uVvRjYPcm2cWoFmJpd");

                          widget.enviarMensajeImagenGif(
                              gif.images.original.url,
                              widget.mensajeId,
                              PantallaConversacion.responderMensaje, {
                            "mensaje": PantallaConversacion.mensajeResponder,
                            "tipoMensaje": PantallaConversacion.tipoMensaje,
                            "idMensaje":
                                PantallaConversacion.idMensajeResponder,
                            "idEmisorMensaje":
                                PantallaConversacion.idEmisorMensajeResponder,
                                
                                
                          });
                               PantallaConversacion.responderMensaje = false;
      
                               

}
if(!Citas.estaConectado){
  ManejadorErroresAplicacion.erroresInstancia.mostrarErrorEnvioMensaje(context);
}

                        

                        },
                        icon: Icon(LineAwesomeIcons.smile_o),
                      ),
                    ),
                    Flexible(
                      flex: 9,
                      fit: FlexFit.tight,
                      child: Container(
                       
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30)),
                        ),
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            reverse: true,
                            scrollDirection:Axis.vertical,
                            child: TextField(
                              controller: controladorTexto,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(3000)
                              ],
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.all(10),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20)))),
                              minLines: 1,
                              maxLines: 9,
                              onChanged: (valor) {
                                if ((valor != null ||
                                    valor != " " ||
                                    valor.isNotEmpty ||
                                    valor.length > 0)) {
                                  mostrarBotontexto();

                                  if (mostrarBotonEnvio &&
                                      !continuaEscribiendo) {
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

                                if (mensajeTemp.isNotEmpty) {
                                  widget.mensajesEnviar(
                                      mensajeTemp,
                                      widget.mensajeId,
                                      PantallaConversacion.responderMensaje, {
                                    "mensaje":
                                        PantallaConversacion.mensajeResponder,
                                    "tipoMensaje":
                                        PantallaConversacion.tipoMensaje,
                                    "idMensaje":
                                        PantallaConversacion.idMensajeResponder,
                                    "idEmisorMensaje": PantallaConversacion
                                        .idEmisorMensajeResponder
                                  });
                                  controladorTexto.clear();
                                  mensajeTemp = "";
                                  moverChatAbajo();
                                  PantallaConversacion.tipoMensaje = "";
                                  PantallaConversacion.idMensajeResponder = "";
                                  PantallaConversacion
                                      .idEmisorMensajeResponder = "";
                                  PantallaConversacion.responderMensaje = false;
                                  PantallaConversacion
                                      .nombreEmisorMensajeResponder = "";
                                  PantallaConversacion.mensajeResponder = "";
                                }
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
                                  //   FocusScope.of(context).unfocus();

                                  widget.estadoConversacion(false);

                                  ocultarBotonEnvio();
                                  mensajeTemp = controladorTexto.text;

                                  if (mensajeTemp.isNotEmpty) {
                                    widget.mensajesEnviar(
                                        mensajeTemp,
                                        widget.mensajeId,
                                        PantallaConversacion.responderMensaje,
                                        {
                                          "mensaje": PantallaConversacion
                                              .mensajeResponder,
                                          "tipoMensaje": PantallaConversacion
                                              .tipoMensaje,
                                          "idMensaje": PantallaConversacion
                                              .idMensajeResponder,
                                          "idEmisorMensaje":
                                              PantallaConversacion
                                                  .idEmisorMensajeResponder
                                        });
                                    controladorTexto.clear();
                                    mensajeTemp = "";
                                    moverChatAbajo();
                                    PantallaConversacion.tipoMensaje = "";
                                    PantallaConversacion.idMensajeResponder =
                                        "";
                                    PantallaConversacion
                                        .idEmisorMensajeResponder = "";
                                    PantallaConversacion.responderMensaje =
                                        false;
                                    PantallaConversacion
                                        .nombreEmisorMensajeResponder = "";
                                    PantallaConversacion.mensajeResponder =
                                        "";
                                  }
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
                            child: Center(
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    flex: 2,
                                    fit: FlexFit.tight,
                                    child: IconButton(
                                      iconSize: 70.sp,
                                      color: Colors.white,
                                      onPressed: () {
                                        iniciarGrabacionAudio().then((value) {
                                          if (value) {
                                            dialogoIniciarGrabacion(context);
                                          }
                                        });
                                      },
                                      icon: Icon(LineAwesomeIcons.microphone),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    fit: FlexFit.tight,
                                    child: IconButton(
                                      color: Colors.white,
                                      icon: Icon(Icons.add_photo_alternate),
                                      iconSize: 70.sp,
                                      onPressed: () {
                                        opcionesImagenPerfil();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container cuadroRespuesta() {
    Mensajes mensajeAudio;
    if(PantallaConversacion.tipoMensaje=="Audio"){
      for(int i=0;i<widget.mensajesTemporales.length;i++){
        if(PantallaConversacion.idMensajeResponder==widget.mensajesTemporales[i].identificadorUnicoMensaje){
          mensajeAudio=widget.mensajesTemporales[i];
        }
      }
    }
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.red),
      height: 350.h,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints limites) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PantallaConversacion.idEmisorMensajeResponder ==
                              Usuario.esteUsuario.idUsuario
                          ? Text("Tu")
                          : Text(PantallaConversacion
                              .nombreEmisorMensajeResponder),
                      GestureDetector(
                        onTap: () {
                          PantallaConversacion.responderMensaje = false;
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
                  Expanded(
                      child: Container(
                          width: limites.biggest.width,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              border: Border.all(color: Colors.white)),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PantallaConversacion.tipoMensaje == "Texto"
                                  ? Text(PantallaConversacion.mensajeResponder)
                                  : PantallaConversacion.tipoMensaje == "Imagen"
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Imagen"),
                                            Image.network(PantallaConversacion
                                                .mensajeResponder)
                                          ],
                                        )
                                      : PantallaConversacion.tipoMensaje ==
                                              "Gif"
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Giphy"),
                                                Image.network(
                                                    PantallaConversacion
                                                        .mensajeResponder,
                                                    headers: {
                                                      'accept': 'image/*'
                                                    }),
                                              ],
                                            )
                                          :             Row(
                                            children: [
                                              Flexible(
                                                flex: 2,
                                                fit:FlexFit.tight,
                                                child: Text("Audio"),
                                              
                                              ),

                                              Flexible(
                                                flex: 5,
                                                fit:FlexFit.tight,

                                                child: Container(
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
                                mensajeAudio.reproducirAudio();
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
                                percent: mensajeAudio.posicion,
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
                                value: mensajeAudio.posicion,
                                max: mensajeAudio.duracionMensaje.toDouble(),
                                min: 0,
                                onChanged: (val) {
                                  mensajeAudio.posicionAudio(val);
                                },
                              ),
                            ),
                          ]),
                        ),
                      )
                    ],
                  ),
                ),
                                              ),
                                            ],
                                          ),))),
                ],
              ),
            ),
          );
        },
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

  void mostrarOpcionesDenuncias(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              height: 1200.h,
              width: ScreenUtil.screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
              child: Material(
                color: Color.fromRGBO(20, 20, 20, 50),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Denunciar",
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

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PantallaDenunciaVisorPerfiles(
                                              idDenunciado: Perfiles
                                                  .perfilesCitas
                                                  .listaPerfiles[
                                                      PerfilesGenteCitas
                                                          .indicePerfil]
                                                  .idUsuario,
                                              tipoDenuncia:
                                                  TipoDenuncia.perfilFalso)));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Container(
                                height: 100.h,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Perfil falso/SPAM",
                                          style: TextStyle(
                                              fontSize: 40.sp,
                                              color: Colors.white)),
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
                              Navigator.pop(context);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PantallaDenunciaVisorPerfiles(
                                              idDenunciado: Perfiles
                                                  .perfilesCitas
                                                  .listaPerfiles[
                                                      PerfilesGenteCitas
                                                          .indicePerfil]
                                                  .idUsuario,
                                              tipoDenuncia:
                                                  TipoDenuncia.menorEdad)));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Container(
                                height: 100.h,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Menor de edad",
                                          style: TextStyle(
                                              fontSize: 40.sp,
                                              color: Colors.white)),
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
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PantallaDenunciaVisorPerfiles(
                                              idDenunciado: Perfiles
                                                  .perfilesCitas
                                                  .listaPerfiles[
                                                      PerfilesGenteCitas
                                                          .indicePerfil]
                                                  .idUsuario,
                                              tipoDenuncia: TipoDenuncia
                                                  .fotosBiografiaInapropiada)));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Container(
                                height: 100.h,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Contenido inapropiado",
                                          style: TextStyle(
                                              fontSize: 40.sp,
                                              color: Colors.white)),
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
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PantallaDenunciaVisorPerfiles(
                                              idDenunciado: Perfiles
                                                  .perfilesCitas
                                                  .listaPerfiles[
                                                      PerfilesGenteCitas
                                                          .indicePerfil]
                                                  .idUsuario,
                                              tipoDenuncia: TipoDenuncia
                                                  .hacePublicidad)));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Container(
                                height: 100.h,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Hace Publicidad",
                                          style: TextStyle(
                                              fontSize: 40.sp,
                                              color: Colors.white)),
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
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PantallaDenunciaVisorPerfiles(
                                              idDenunciado: Perfiles
                                                  .perfilesCitas
                                                  .listaPerfiles[
                                                      PerfilesGenteCitas
                                                          .indicePerfil]
                                                  .idUsuario,
                                              tipoDenuncia:
                                                  TipoDenuncia.otroTipo)));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Container(
                                height: 100.h,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Mensajes Inapropiados",
                                          style: TextStyle(
                                              fontSize: 40.sp,
                                              color: Colors.white)),
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
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PantallaDenunciaVisorPerfiles(
                                              idDenunciado: Perfiles
                                                  .perfilesCitas
                                                  .listaPerfiles[
                                                      PerfilesGenteCitas
                                                          .indicePerfil]
                                                  .idUsuario,
                                              tipoDenuncia:
                                                  TipoDenuncia.otroTipo)));
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 20),
                              child: Container(
                                height: 100.h,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Otros",
                                          style: TextStyle(
                                              fontSize: 40.sp,
                                              color: Colors.white)),
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
              ),
            ),
          );
        });
  }
}
