import 'dart:async';

import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/EstadoConexion.dart';

import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/GeneradorCodigos.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/TiempoAplicacion.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/WidgetError.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:flash/flash.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart' as xd;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:ntp/ntp.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import 'Usuario.dart';

class ExcepcionLikes implements Exception {
  String mensaje;
  ExcepcionLikes(mesaje);
}

enum RevelarSolicitudEstado { noRevelada, revelando, revelada }

class Solicitudes with ChangeNotifier {
  static Solicitudes instancia = Solicitudes();
  List<SolicitudConversacion> listaSolicitudesConversacion = new List();

  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;

  Solicitudes();
}

class SolicitudConversacion with ChangeNotifier {
  static SolicitudConversacion instancia = SolicitudConversacion();
  String nombreEmisor;
  String idEmisor;
  String idDestino;
  String imagenEmisor;
  double calificacion;
  String idSolicitudConversacion;
  DateTime fechaSolicitud;
  DateTime fechaCaducidadSolicitud;
  int segundosRestantes;
  bool solicitudVisible = true;
  RevelarSolicitudEstado estadoRevelacion = RevelarSolicitudEstado.noRevelada;
  ValueNotifier<bool> notificarEliminacion;
  var formatoTiempo = new DateFormat("HH:mm:ss");
  StreamController<int> notificadorFinTiempo = StreamController.broadcast();
  StreamSubscription<QuerySnapshot> escuchadorSolicitudes;

  DateTime fechaReferenciaSolicitudes;
  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
  bool solicitudRevelada;
  bool get getSolicitudRevelada => solicitudRevelada;

  set setSolicitudRevelada(bool solicitudRevelada) {
    this.solicitudRevelada = solicitudRevelada;
    if (this.solicitudRevelada &&
        WidgetSolicitudConversacion.llaveListaSolicitudes.currentContext !=
            null) {
      notificacionSolicitudRevelada(
          WidgetSolicitudConversacion.llaveListaSolicitudes.currentContext);
    }
  }

  static void notificacionSolicitudRevelada(BuildContext context) {
    showFlash(
        duration: Duration(seconds: 3),
        context: context,
        builder: (context, controller) {
          return Flash.dialog(
            controller: controller,
            alignment: Alignment.topCenter,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderColor: Colors.white,
            backgroundColor: Colors.deepPurple,
            margin: EdgeInsets.only(bottom: 150.h),
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
                      "Solicitud revelada",
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

  WidgetSolicitudConversacion widgetSolicitud;

  SolicitudConversacion();
  SolicitudConversacion.crear(
      {@required this.nombreEmisor,
      @required this.fechaCaducidadSolicitud,
      @required this.fechaSolicitud,
      @required this.idDestino,
      @required this.imagenEmisor,
      @required this.solicitudRevelada,
      @required this.calificacion,
      @required this.idSolicitudConversacion,
      @required this.idEmisor}) {
    notificarEliminacion = new ValueNotifier(this.solicitudVisible);
    segundosRestantes = fechaCaducidadSolicitud
        .difference(instancia.fechaReferenciaSolicitudes)
        .inSeconds;

    if (segundosRestantes > 86400) {
      segundosRestantes = 86400;
    }

    print("construido");
    contadorTiempoSolicitudes();
  }

  void contadorTiempoSolicitudes() async {
    Timer flutterTimer;

    flutterTimer = new Timer.periodic(Duration(seconds: 1), (valor) {
      if (segundosRestantes > 0 &&
          this.solicitudRevelada == false &&
          this.notificadorFinTiempo.isClosed == false) {
        segundosRestantes = segundosRestantes - 1;
        Solicitudes.instancia.notifyListeners();
        notificadorFinTiempo.add(segundosRestantes);
      }

      if (this.notificadorFinTiempo.isClosed) {
        flutterTimer.cancel();
      }
      if (segundosRestantes == 0 &&
          this.solicitudRevelada == false &&
          this.notificadorFinTiempo.isClosed == false) {
        flutterTimer.cancel();

        if (WidgetSolicitudConversacion.llaveListaSolicitudes.currentState ==
            null) {
          Solicitudes.instancia.listaSolicitudesConversacion.removeWhere(
              (element) =>
                  element.idSolicitudConversacion ==
                  this.idSolicitudConversacion);
          eliminarSolicitudConversacion(this.idSolicitudConversacion);
        }
      }
    });
  }

  void obtenerSolicitudes() async {
    int indice = 0;

    this.fechaReferenciaSolicitudes =
        TiempoAplicacion.tiempoAplicacion.marcaTiempoAplicacion;
    DateTime fechaQuery = TiempoAplicacion
        .tiempoAplicacion.marcaTiempoAplicacion
        .subtract(Duration(days: 1));
    baseDatosRef
        .collection("solicitudes conversaciones")
        .where("tiemmpo", isGreaterThanOrEqualTo: fechaQuery)
        .where("idDestino", isEqualTo: Usuario.esteUsuario.idUsuario)
        .get()
        .then((value) {
      if (value != null) {
        for (QueryDocumentSnapshot documento in value.docs) {
          if (documento.get("tiemmpo") != null &&
              documento.get("idEmisor") != null &&
              documento.get("nombreEmisor") != null &&
              documento.get("caducidad") != null &&
              documento.get("idDestino") != null &&
              documento.get("imagenEmisor") != null &&
              documento.get("solicitudRevelada") != null &&
              documento.get("calificacion") != null &&
              documento.get("idSolicitudConversacion") != null) {
            SolicitudConversacion solicitud = new SolicitudConversacion.crear(
                fechaSolicitud: documento.get("tiemmpo").toDate(),
                idEmisor: documento.get("idEmisor"),
                nombreEmisor: documento.get("nombreEmisor"),
                fechaCaducidadSolicitud: documento.get("caducidad").toDate(),
                idDestino: documento.get("idDestino"),
                imagenEmisor: documento.get("imagenEmisor"),
                solicitudRevelada: documento.get("solicitudRevelada"),
                calificacion: documento.get("calificacion"),
                idSolicitudConversacion:
                    documento.get("idSolicitudConversacion"));
            // Solicitudes.instancia.listaSolicitudesConversacion.add(solicitud);
            Solicitudes.instancia.listaSolicitudesConversacion
                .insert(indice, solicitud);
          }
        }
      }
    }).then((value) => escucharSolicitudesConversacion());
  }

  void escucharSolicitudesConversacion() async {
    DateTime fechaQuery = TiempoAplicacion
        .tiempoAplicacion.marcaTiempoAplicacion
        .subtract(Duration(days: 1));
    escuchadorSolicitudes = baseDatosRef
        .collection("solicitudes conversaciones")
        .where("tiemmpo", isGreaterThanOrEqualTo: fechaQuery)
        .where("idDestino", isEqualTo: Usuario.esteUsuario.idUsuario)
        .snapshots()
        .listen((event) {
      bool coincidencias;
      if (event.docChanges.length > 0) {
        for (int a = 0; a < event.docChanges.length; a++) {
          if (event.docChanges[a].type != DocumentChangeType.removed) {
            coincidencias = false;
            int indice = 0;

            for (int b = 0;
                b < Solicitudes.instancia.listaSolicitudesConversacion.length;
                b++) {
              if (event.docChanges[a].doc.id ==
                  Solicitudes.instancia.listaSolicitudesConversacion[b]
                      .idSolicitudConversacion) {
                coincidencias = true;
                indice = b;
              }
            }

            if (coincidencias) {
              if (event.docChanges[a].doc.get("nombreEmisor") != null &&
                  event.docChanges[a].doc.get("imagenEmisor") != null &&
                  event.docChanges[a].doc.get("solicitudRevelada") != null &&
                  event.docChanges[a].doc.get("tiemmpo") != null &&
                  event.docChanges[a].doc.get("idDestino") != null &&
                  event.docChanges[a].doc.get("caducidad") != null &&
                  event.docChanges[a].doc.get("calificacion") != null &&
                  event.docChanges[a].doc.get("idSolicitudConversacion") !=
                      null &&
                  event.docChanges[a].doc.get("idEmisor") != null) {
                try {
                  if (event.docChanges[a].doc.get("nombreEmisor") !=
                      Solicitudes.instancia.listaSolicitudesConversacion[indice]
                          .nombreEmisor) {
                    Solicitudes.instancia.listaSolicitudesConversacion[indice]
                            .nombreEmisor =
                        event.docChanges[a].doc.get("nombreEmisor");
                  }
                  if (event.docs[a].get("imagenEmisor") !=
                      Solicitudes.instancia.listaSolicitudesConversacion[indice]
                          .imagenEmisor) {
                    Solicitudes.instancia.listaSolicitudesConversacion[indice]
                            .imagenEmisor =
                        event.docChanges[a].doc.get("imagenEmisor");
                  }
                  if (event.docChanges[a].doc.get("solicitudRevelada") !=
                      Solicitudes.instancia.listaSolicitudesConversacion[indice]
                          .solicitudRevelada) {
                    Solicitudes.instancia.listaSolicitudesConversacion[indice]
                            .setSolicitudRevelada =
                        event.docChanges[a].doc.get("solicitudRevelada");
                  }
                } on Exception {
                  /// aqui se devuelven los creditos gastados
                }

                Solicitudes.instancia.notifyListeners();
              }
            }

            if (!coincidencias) {
              if (event.docChanges[a].doc.get("nombreEmisor") != null &&
                  event.docChanges[a].doc.get("imagenEmisor") != null &&
                  event.docChanges[a].doc.get("solicitudRevelada") != null &&
                  event.docChanges[a].doc.get("tiemmpo") != null &&
                  event.docChanges[a].doc.get("idDestino") != null &&
                  event.docChanges[a].doc.get("caducidad") != null &&
                  event.docChanges[a].doc.get("calificacion") != null &&
                  event.docChanges[a].doc.get("idSolicitudConversacion") !=
                      null &&
                  event.docChanges[a].doc.get("idEmisor") != null) {
                try {
                  SolicitudConversacion solicitud = new SolicitudConversacion
                          .crear(
                      fechaSolicitud:
                          event.docChanges[a].doc.get("tiemmpo").toDate(),
                      idEmisor: event.docChanges[a].doc.get("idEmisor"),
                      nombreEmisor: event.docChanges[a].doc.get("nombreEmisor"),
                      idDestino: event.docChanges[a].doc.get("idDestino"),
                      fechaCaducidadSolicitud:
                          event.docChanges[a].doc.get("caducidad").toDate(),
                      imagenEmisor: event.docChanges[a].doc.get("imagenEmisor"),
                      solicitudRevelada:
                          event.docChanges[a].doc.get("solicitudRevelada"),
                      calificacion: event.docChanges[a].doc.get("calificacion"),
                      idSolicitudConversacion: event.docChanges[a].doc
                          .get("idSolicitudConversacion"));

                  Solicitudes.instancia.listaSolicitudesConversacion
                      .insert(0, solicitud);
                  if (WidgetSolicitudConversacion
                          .llaveListaSolicitudes.currentState !=
                      null) {
                    WidgetSolicitudConversacion
                        .llaveListaSolicitudes.currentState
                        .insertItem(0);
                  }
                  Solicitudes.instancia.notifyListeners();
                  Usuario.esteUsuario.notifyListeners();

                  if (BaseAplicacion.notificadorEstadoAplicacion?.index == 2) {
                    ControladorNotificacion.instancia
                        .mostrarNotificacionNuevaSolicitud();
                  }
                  if (BaseAplicacion.notificadorEstadoAplicacion?.index != 0) {
                    if (BaseAplicacion.claveBase.currentContext != null) {
                      ControladorNotificacion.instancia
                          .notificacionSolicitudAplicacionAbierta(
                        BaseAplicacion.claveBase.currentContext,
                      );
                    }
                  }
                } on Exception {
                  /// se devuelven los creditos

                }
              }
            }
          }
          if (event.docChanges[a].type == DocumentChangeType.removed) {
            String idSolicitudEliminar =
                event.docChanges[a].doc.get("idSolicitudConversacion");
            if (idSolicitudEliminar != null) {
              for (int z = 0;
                  z < Solicitudes.instancia.listaSolicitudesConversacion.length;
                  z++) {
                if (Solicitudes.instancia.listaSolicitudesConversacion[z]
                        .idSolicitudConversacion ==
                    idSolicitudEliminar) {
                  if (WidgetSolicitudConversacion
                          .llaveListaSolicitudes.currentState !=
                      null) {
                    Solicitudes.instancia.listaSolicitudesConversacion[z]
                        .solicitudVisible = false;
                    Solicitudes.instancia.listaSolicitudesConversacion[z]
                        .notificarEliminacion
                        .notifyListeners();
                  }
                  if (WidgetSolicitudConversacion
                          .llaveListaSolicitudes.currentState ==
                      null) {
                    int indiceSolicitudEliminar = Solicitudes
                        .instancia.listaSolicitudesConversacion
                        .indexWhere((valor) =>
                            valor.idSolicitudConversacion ==
                            idSolicitudEliminar);
                    if (indiceSolicitudEliminar >= 0) {
                      Solicitudes.instancia.listaSolicitudesConversacion
                          .removeAt(indiceSolicitudEliminar);
                    }
                  }
                }
              }
            }
          }
        }
      }
    });
  }

  void eliminarSolicitudConversacion(String idSolicitud) {
    FirebaseFirestore firebaseRef = FirebaseFirestore.instance;
    firebaseRef
        .collection("solicitudes conversaciones")
        .doc(idSolicitud)
        .delete();
  }

  void rechazarSolicitudConversacion(
    String id,
  ) async {
    await baseDatosRef
        .collection("solicitudes conversaciones")
        .doc(id)
        .delete();
  }

  void cerrarEscuchadorSolicitudes() {
    for (int i = 0;
        i < Solicitudes.instancia.listaSolicitudesConversacion.length;
        i++) {
      Solicitudes.instancia.listaSolicitudesConversacion[i].notificadorFinTiempo
          .close();
    }
    if (escuchadorSolicitudes != null) {
      escuchadorSolicitudes.cancel();
      escuchadorSolicitudes = null;
    }

    SolicitudConversacion.instancia.fechaReferenciaSolicitudes = null;

    if (Solicitudes.instancia.listaSolicitudesConversacion != null) {
      Solicitudes.instancia.listaSolicitudesConversacion.clear();
    }
  }

  void aceptarSolicitud(String nombreRemitente, String imagenRemitente,
      String idRemitente, String idVal) async {
    String idMensaje = GeneradorCodigos.instancia.crearCodigo();
    String idConversacion = GeneradorCodigos.instancia.crearCodigo();
    Map<String, dynamic> mensajeInicial = Map();

    mensajeInicial["Hora mensaje"] = DateTime.now();

    mensajeInicial["idMensaje"] = idMensaje;
    mensajeInicial["idEmisor"] = idRemitente;
    mensajeInicial["Nombre emisor"] = Usuario.esteUsuario.idUsuario;
    mensajeInicial["Tipo Mensaje"] = "Texto";

    Map<String, dynamic> estadoConexionUsuario = Map();

    estadoConexionUsuario["Escribiendo"] = false;
    estadoConexionUsuario["Conectado"] = false;
    estadoConexionUsuario["IdConversacion"] = idConversacion;
    estadoConexionUsuario["Hora Conexion"] = DateTime.now();

    Map<String, dynamic> solicitudParaRemitente = Map();
    solicitudParaRemitente["Hora"] = DateTime.now();
    solicitudParaRemitente["IdConversacion"] = idConversacion;
    solicitudParaRemitente["idUsuario"] = Usuario.esteUsuario.idUsuario;
    solicitudParaRemitente["IdMensajes"] = idMensaje;
    solicitudParaRemitente["cantidadMensajesSinLeer"] = 0;
    solicitudParaRemitente["cantidadMensajesSinLeerPropios"] = 0;
    solicitudParaRemitente["IdRemitente"] = idRemitente;
    solicitudParaRemitente["ultimoMensaje"] = {
      "mensaje": " ",
      "tipoMensaje": "texto",
      "duracionMensaje": 0
    };
    solicitudParaRemitente["nombreRemitente"] = nombreRemitente;
    solicitudParaRemitente["imagenRemitente"] = imagenRemitente;
    solicitudParaRemitente["Grupo"] = false;
    Map<String, dynamic> solicitudLocal = Map();
    solicitudLocal["Hora"] = DateTime.now();
    solicitudLocal["IdConversacion"] = idConversacion;
    solicitudLocal["idUsuario"] = idRemitente;
    solicitudLocal["IdMensajes"] = idMensaje;
    solicitudLocal["IdRemitente"] = Usuario.esteUsuario.idUsuario;
    solicitudLocal["nombreRemitente"] = Usuario.esteUsuario.nombre;
    solicitudLocal["cantidadMensajesSinLeer"] = 0;
    solicitudLocal["cantidadMensajesSinLeerPropios"] = 0;
    solicitudLocal["imagenRemitente"] =
        Usuario.esteUsuario.imagenUrl1["Imagen"];
    solicitudLocal["ultimoMensaje"] = {
      "mensaje": "null",
      "tipoMensaje": "texto",
      "duracionMensaje": 0
    };
    solicitudLocal["Grupo"] = false;
    WriteBatch batch = baseDatosRef.batch();

    DocumentReference valoracionEliminar =
        baseDatosRef.collection("solicitudes conversaciones").doc(idVal);
    DocumentReference conversacionesRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);

    DocumentReference conversacionesLocal = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(idConversacion);

    DocumentReference estadoConversacionesRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("estados conversacion")
        .doc(idConversacion);

    DocumentReference estadoConversacionesLocal = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion")
        .doc(idConversacion);

    batch.set(conversacionesRemitente, solicitudLocal);
    batch.set(conversacionesLocal, solicitudParaRemitente);
    batch.set(estadoConversacionesRemitente, estadoConexionUsuario);
    batch.set(estadoConversacionesLocal, estadoConexionUsuario);
    batch.delete(valoracionEliminar);
    await batch.commit().then((value) {
      print("value");
    }).catchError((onError) => print(onError));
  }
}

class WidgetSolicitudConversacion extends StatefulWidget {
  static final GlobalKey<AnimatedListState> llaveListaSolicitudes =
      GlobalKey<AnimatedListState>();

  @override
  _WidgetSolicitudConversacionState createState() =>
      _WidgetSolicitudConversacionState();
}

class _WidgetSolicitudConversacionState
    extends State<WidgetSolicitudConversacion>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
        value: Solicitudes.instancia,
        child: Consumer<Solicitudes>(
          builder: (context, myType, child) {
            return Container(
              child: AnimatedList(
                key: WidgetSolicitudConversacion.llaveListaSolicitudes,
                initialItemCount:
                    Solicitudes.instancia.listaSolicitudesConversacion.length,
                itemBuilder: (BuildContext context, int indice, animation) {
                  return buildSlideTransition(
                      context,
                      animation,
                      indice,
                      Solicitudes
                          .instancia.listaSolicitudesConversacion[indice]);
                },
              ),
            );
          },
        ));
  }

  Widget buildSlideTransition(BuildContext context, Animation animation,
      int indice, SolicitudConversacion solicitud) {
    return ValueListenableBuilder(
      valueListenable: solicitud.notificarEliminacion,
      builder: (BuildContext context, bool valor, child) {
        if (solicitud.solicitudVisible == false) {
          solicitud.notificadorFinTiempo.close();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            solicitud.solicitudVisible = true;
            eliimnarSolicitud(
                indice, solicitud.idSolicitudConversacion, solicitud);
          });
        }

        return SizeTransition(
          sizeFactor: animation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
                height: ScreenUtil().setHeight(400),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white),
                child: Container(
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          fotoSolicitud(solicitud),
                          cuadroOpcionesSolicitud(solicitud, indice),
                        ],
                      ),
                      !solicitud.solicitudRevelada
                          ? Container(
                              decoration: BoxDecoration(
                                  color: solicitud.segundosRestantes <= 3600
                                      ? Colors.red
                                      : Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              height: 400.h,
                              child: Center(
                                  child: GestureDetector(
                                onTap: () async {
                                  if (EstadoConexionInternet
                                          .estadoConexion.conexion ==
                                      EstadoConexion.conectado) {
                                    if (Usuario.esteUsuario.creditosUsuario >=
                                        200) {
                                      solicitud.estadoRevelacion =
                                          RevelarSolicitudEstado.revelando;
                                      ControladorCreditos.instancia
                                          .restarCreditosSolicitud(
                                              200,
                                              solicitud
                                                  .idSolicitudConversacion);
                                    } else {
                                      solicitud.estadoRevelacion =
                                          RevelarSolicitudEstado.noRevelada;
                                      ManejadorErroresAplicacion
                                          .erroresInstancia
                                          .mostrarErrorCreditosInsuficientes(
                                              context);
                                    }
                                  } else {
                                    ManejadorErroresAplicacion.erroresInstancia
                                        .mostrarErrorValoracion(context);
                                    solicitud.estadoRevelacion =
                                        RevelarSolicitudEstado.noRevelada;
                                    Solicitudes.instancia.notifyListeners();
                                  }
                                },
                                child: RepaintBoundary(
                                  child: solicitud.estadoRevelacion ==
                                          RevelarSolicitudEstado.revelando
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
                                                  MainAxisAlignment.spaceAround,
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
                                            color:
                                                solicitud.segundosRestantes <=
                                                        3600
                                                    ? Colors.red
                                                    : Colors.deepPurple,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(1)),
                                          ),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Flexible(
                                                    flex: 4,
                                                    fit: FlexFit.tight,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        cuentaAtras(
                                                            solicitud, indice),
                                                        Icon(
                                                          LineAwesomeIcons
                                                              .clock_o,
                                                          color: Colors.white,
                                                          size: 120.sp,
                                                        )
                                                      ],
                                                    )),
                                                Flexible(
                                                  flex: 2,
                                                  fit: FlexFit.tight,
                                                  child: Container(
                                                      color: Colors
                                                          .greenAccent[400],
                                                      child: precioRevelar()),
                                                ),
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
      },
    );
  }

  Row precioRevelar() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Text(
        "Ver",
        style: GoogleFonts.lato(fontSize: 60.sp, color: Colors.black),
      ),
      Row(
        children: [
          Text(
            "${ControladorCreditos.precioSolicitud}",
            style: GoogleFonts.lato(fontSize: 60.sp, color: Colors.black),
          ),
          Icon(
            xd.LineAwesomeIcons.coins,
            color: Colors.black,
          ),
        ],
      )
    ]);
  }

  Widget cuentaAtras(SolicitudConversacion solicitud, int indice) {
    return RepaintBoundary(
      child: StreamBuilder(
        stream: solicitud.notificadorFinTiempo.stream,
        initialData: solicitud.segundosRestantes,
        builder: (BuildContext context, valor) {
          if (valor.data == 0) {
            solicitud.notificadorFinTiempo.close().then((value) =>
                eliimnarSolicitud(
                    indice, solicitud.idSolicitudConversacion, solicitud));
          }

          return Container(
              child: Text(
                  SolicitudConversacion.instancia.formatoTiempo
                      .format(DateTime(0, 0, 0, 0, 0, valor.data)),
                  style:
                      GoogleFonts.lato(fontSize: 90.sp, color: Colors.white)));
        },
      ),
    );
  }

  Flexible cuadroOpcionesSolicitud(
      SolicitudConversacion valoracion, int indice) {
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

  Flexible cuadroOpcionesValoracion(
      int indice, SolicitudConversacion valoracion) {
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
                            aceptarSolicitud(indice, valoracion);
                          },
                          child: Icon(
                            LineAwesomeIcons.heart_o,
                            color: Colors.white,
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
                            eliimnarSolicitud(
                                indice,
                                Solicitudes
                                    .instancia
                                    .listaSolicitudesConversacion[indice]
                                    .idSolicitudConversacion,
                                valoracion);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          )),
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }

  Flexible cuadroSuperiorValoracion(SolicitudConversacion valoracion) {
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
                              style: GoogleFonts.lato(
                                  fontSize: ScreenUtil().setSp(40),
                                  fontWeight: FontWeight.bold),
                            )
                          : Text(" ")),
                ),
                Container(child: Text("¿Aceptar solicitud de chat?")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Flexible fotoSolicitud(SolicitudConversacion valoracion) {
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

  void eliimnarSolicitud(
      int indice, String id, SolicitudConversacion solicitud) {
    SolicitudConversacion valoracionQuitada =
        Solicitudes.instancia.listaSolicitudesConversacion.removeAt(indice);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return buildSlideTransition(
          context, animation, indice, valoracionQuitada);
    };
    WidgetSolicitudConversacion.llaveListaSolicitudes.currentState
        .removeItem(indice, builder);

    solicitud.rechazarSolicitudConversacion(id);
  }

  void aceptarSolicitud(int indice, SolicitudConversacion solicitud) {
    SolicitudConversacion valoracionAceptada =
        Solicitudes.instancia.listaSolicitudesConversacion.removeAt(indice);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return buildSlideTransition(
          context, animation, indice, valoracionAceptada);
    };
    WidgetSolicitudConversacion.llaveListaSolicitudes.currentState
        .removeItem(indice, builder);

    solicitud.aceptarSolicitud(
      solicitud.nombreEmisor,
      solicitud.imagenEmisor,
      solicitud.idEmisor,
      solicitud.idSolicitudConversacion,
    );
  }
}

// ignore: must_be_immutable
