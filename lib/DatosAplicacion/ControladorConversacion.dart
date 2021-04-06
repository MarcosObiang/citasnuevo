import 'dart:async';
import 'dart:isolate';

import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/MetodosIsolates.dart/MetodosIsolatesConversacion.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/TituloChat.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:citasnuevo/InterfazUsuario/Conversaciones/Mensajes.dart";
import 'package:flutter_screenutil/screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Usuario.dart';

class ExcepcionesConversaciones implements Exception {
  String mensaje;
  ExcepcionesConversaciones(mensaje);
  String leerMensaje() => this.mensaje;
}

enum EstadoModuloConversaciones {
  cargando,
  cagradoCorrectamente,
  cargadoIncorrectamete,
  noCargado
}
enum EscribiRemitente { escribiendo, noEscribiendo }

class Conversacion extends ChangeNotifier {
  static Isolate isoladoConversaciones;
  static FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
  static Conversacion conversaciones = new Conversacion.instancia();
  bool cargarConversacion = true;
  StreamController<String> conversacionEliminada;
  String conversacionAbierta;
  EstadoModuloConversaciones estadoModuloConversacion =
      EstadoModuloConversaciones.noCargado;
  int cantidadMensajesNoLeidos = 0;
  String idConversacion;
  String nombreRemitente;
  bool estadoConexionConversacion = false;
  String idRemitente;
  String idMensajes;
  String imagenRemitente;
  bool grupo;
  int mensajesSinLeerConversaciones = 0;
  int mensajesPropiosSinLeerConversaciones = 0;
  TituloChat ventanaChat;
  List<Mensajes> listaMensajes = new List();

  Map<String, dynamic> ultimoMensage = new Map();
  List<Conversacion> listaDeConversaciones = [];
  List<String> estadosEscribiendoConversacion = [
    " ",
    "Escribiendo",
    "Grabando Audio"
  ];

  StreamSubscription<QuerySnapshot> escuchadorMensajes;
  StreamSubscription<QuerySnapshot> escuchadorEstadoConversacion;
  StreamSubscription<QuerySnapshot> escuchadorConversacion;

  ///Calculamos la cantidad de mensajes uevos que tiene el usuario
  ///
  ///
  ///
  ///POSIBLES ERRORES: Ninguno

  void calcularCantidadMensajesSinLeer() {
    int mensajesSInLeerTemporal = 0;
    for (Conversacion conversacion in conversaciones.listaDeConversaciones) {
      mensajesSInLeerTemporal =
          mensajesSInLeerTemporal + conversacion.ventanaChat.mensajesSinLeer;
    }
    cantidadMensajesNoLeidos = mensajesSInLeerTemporal;
  }

  ///Iniciamos un isolado para procesar las conversaciones
  ///
  ///
  ///
  ///POSIBLES ERRORES: lista de conversaciones vacia o [null], o algun error encuanto a abrir y cerrar isolados

  Future<List<Conversacion>> isolateConversaciones(
      List<Map<String, dynamic>> datosConversaciones) async {
    List<Conversacion> conversacionesIsolado = [];
    ReceivePort puertoRecepcion = ReceivePort();
    WidgetsFlutterBinding.ensureInitialized();
    Conversacion.conversaciones.estadoModuloConversacion =
        EstadoModuloConversaciones.cargando;
    cargarConversacion = false;
    notifyListeners();

    if (datosConversaciones != null) {
      if (datosConversaciones.length > 0) {
        isoladoConversaciones = await Isolate.spawn(
            listaConversaciones, puertoRecepcion.sendPort,
            debugName: "IsolateConversaciones");

        SendPort puertoEnvio = await puertoRecepcion.first;
        await enviarRecibirConversaciones(puertoEnvio, datosConversaciones)
            .then((value) {
          Conversacion.conversaciones.estadoModuloConversacion =
              EstadoModuloConversaciones.cagradoCorrectamente;
          conversacionesIsolado = value;
          cargarConversacion = true;
          notifyListeners();
        }).onError((error, stackTrace) {
          Conversacion.conversaciones.estadoModuloConversacion =
              EstadoModuloConversaciones.cargadoIncorrectamete;
          cargarConversacion = true;
          Conversacion.conversaciones.listaDeConversaciones.clear();
          notifyListeners();

          isoladoConversaciones.kill();
          throw ExcepcionesConversaciones("Error al cargar las conversaciones");
        });

        isoladoConversaciones.kill();
      }
    }

    return conversacionesIsolado;
  }

  void escucharMensajes() {
    Mensajes nuevo;
    escuchadorMensajes = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .orderBy("Hora mensaje", descending: true)
        .snapshots()
        .listen((dato) {
      if (dato.docChanges != null) {
        for (int a = 0; a < dato.docChanges.length; a++) {
          if (dato.docChanges[a].type == DocumentChangeType.added) {
            for (int i = 0;
                i < conversaciones.listaDeConversaciones.length;
                i++) {
              if (dato.docChanges[a].doc.get("idMensaje") != null &&
                  dato.docChanges[a].doc.get("idMensaje") is String &&
                  dato.docChanges[a].doc.get("Tipo Mensaje") != null &&
                  dato.docChanges[a].doc.get("Tipo Mensaje") is String &&
                  dato.docChanges[a].doc.get("respuesta") != null &&
                  dato.docChanges[a].doc.get("respuesta") is bool &&
                  dato.docChanges[a].doc.get("mensajeRespuesta") != null &&
                  dato.docChanges[a].doc.get("mensajeRespuesta")
                      is Map<dynamic, dynamic> &&
                  dato.docChanges[a].doc.get("mensajeLeidoRemitente") != null &&
                  dato.docChanges[a].doc.get("mensajeLeidoRemitente") is bool &&
                  dato.docChanges[a].doc.get("Nombre emisor") != null &&
                  dato.docChanges[a].doc.get("Nombre emisor") is String &&
                  dato.docChanges[a].doc.get("idConversacion") != null &&
                  dato.docChanges[a].doc.get("idConversacion") is String &&
                  dato.docChanges[a].doc.get("mensajeLeido") != null &&
                  dato.docChanges[a].doc.get("mensajeLeido") is bool &&
                  dato.docChanges[a].doc.get("identificadorUnicoMensaje") !=
                      null &&
                  dato.docChanges[a].doc.get("identificadorUnicoMensaje")
                      is String &&
                  dato.docChanges[a].doc.get("idEmisor") != null &&
                  dato.docChanges[a].doc.get("idEmisor") is String &&
                  dato.docChanges[a].doc.get("Hora mensaje") != null &&
                  dato.docChanges[a].doc.get("Hora mensaje") is Timestamp &&
                  dato.docChanges[a].doc.get("Mensaje") != null &&
                  dato.docChanges[a].doc.get("Mensaje") is String) {
                try {
                  if (conversaciones.listaDeConversaciones[i].idMensajes ==
                      dato.docChanges[a].doc.get("idMensaje")) {
                    if (dato.docChanges[a].doc.get("Tipo Mensaje") == "Texto" ||
                        dato.docChanges[a].doc.get("Tipo Mensaje") ==
                            "Imagen" ||
                        dato.docChanges[a].doc.get("Tipo Mensaje") == "Gif") {
                      nuevo = new Mensajes(
                        respuesta: dato.docs[a].get("respuesta"),
                        respuestaMensaje: dato.docs[a].get("mensajeRespuesta"),
                        mensajeLeidoRemitente:
                            dato.docChanges[a].doc.get("mensajeLeidoRemitente"),
                        nombreEmisor:
                            dato.docChanges[a].doc.get("Nombre emisor"),
                        idConversacion:
                            dato.docChanges[a].doc.get("idConversacion"),
                        mensajeLeido:
                            dato.docChanges[a].doc.get("mensajeLeido"),
                        tipoMensaje: dato.docChanges[a].doc.get("Tipo Mensaje"),
                        idMensaje: dato.docChanges[a].doc.get("idMensaje"),
                        identificadorUnicoMensaje: dato.docChanges[a].doc
                            .get("identificadorUnicoMensaje"),
                        idEmisor: dato.docChanges[a].doc.get("idEmisor"),
                        horaMensajeFormatoDate:
                            (dato.docChanges[a].doc.get("Hora mensaje"))
                                .toDate(),
                        horaMensaje:
                            ("${((dato.docChanges[a].doc.get("Hora mensaje")).toDate()).hour}:${((dato.docChanges[a].doc.get("Hora mensaje")).toDate()).minute}"),
                        mensaje: dato.docChanges[a].doc.get("Mensaje"),
                      );
                    }

                    if (conversaciones.listaDeConversaciones[i].ventanaChat
                            .listadeMensajes ==
                        null) {
                      conversaciones.listaDeConversaciones[i].ventanaChat
                          .listadeMensajes = new List();

                      conversaciones
                          .listaDeConversaciones[i].ventanaChat.listadeMensajes
                          .add(nuevo);
                    } else {
                      if (nuevo.tipoMensaje != "SeparadorHora") {
                        if (nuevo.respuesta) {
                          if (nuevo.respuestaMensaje["tipoMensaje"] ==
                              "Texto") {
                            nuevo.widgetRespuesta = Container(
                              color:
                                  nuevo.respuestaMensaje["idEmisorMensaje"] ==
                                          Usuario.esteUsuario.idUsuario
                                      ? Colors.blue
                                      : Colors.green,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  nuevo.respuestaMensaje["idEmisorMensaje"] ==
                                          Usuario.esteUsuario.idUsuario
                                      ? Text("Yo")
                                      : Text(conversaciones
                                          .listaDeConversaciones[i]
                                          .ventanaChat
                                          .nombre),
                                  Text(nuevo.respuestaMensaje["mensaje"])
                                ],
                              ),
                            );
                          }
                          if (nuevo.respuestaMensaje["tipoMensaje"] ==
                              "Imagen") {
                            nuevo.widgetRespuesta = Container(
                              color:
                                  nuevo.respuestaMensaje["idEmisorMensaje"] ==
                                          Usuario.esteUsuario.idUsuario
                                      ? Colors.blue
                                      : Colors.green,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  nuevo.respuestaMensaje["idEmisorMensaje"] ==
                                          Usuario.esteUsuario.idUsuario
                                      ? Text("Yo")
                                      : Text(conversaciones
                                          .listaDeConversaciones[i]
                                          .ventanaChat
                                          .nombre),
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            nuevo.respuestaMensaje["mensaje"],
                                            scale: 1,
                                          )),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Colors.transparent,
                                    ),
                                    height: ScreenUtil().setHeight(500),
                                    width: ScreenUtil().setWidth(500),
                                  )
                                ],
                              ),
                            );
                          }
                          if (nuevo.respuestaMensaje["tipoMensaje"] == "Gif") {
                            nuevo.widgetRespuesta = Container(
                              color:
                                  nuevo.respuestaMensaje["idEmisorMensaje"] ==
                                          Usuario.esteUsuario.idUsuario
                                      ? Colors.blue
                                      : Colors.green,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  nuevo.respuestaMensaje["idEmisorMensaje"] ==
                                          Usuario.esteUsuario.idUsuario
                                      ? Text("Yo")
                                      : Text(conversaciones
                                          .listaDeConversaciones[i]
                                          .ventanaChat
                                          .nombre),
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              nuevo.respuestaMensaje["mensaje"],
                                              scale: 1,
                                              headers: {'accept': 'image/*'})),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Colors.transparent,
                                    ),
                                    height: ScreenUtil().setHeight(700),
                                    width: ScreenUtil().setWidth(700),
                                  )
                                ],
                              ),
                            );
                          }
                        }
                      }
                      conversaciones
                          .listaDeConversaciones[i].ventanaChat.listadeMensajes
                          .insert(0, nuevo);
                    }
                    ControladorNotificacion.instancia
                        .sumarMensajeNuevoEnNotificacion(
                            dato.docChanges[a].doc);

                    notifyListeners();
                    calcularCantidadMensajesSinLeer();
                  }
                } on Exception {
                  if (nuevo.idMensaje != null && nuevo.idEmisor != null) {
                    WriteBatch batchEliminacion = baseDatosRef.batch();

                    DocumentReference referenciaRemitente = baseDatosRef
                        .collection("usuarios")
                        .doc(nuevo.idEmisor)
                        .collection("mensajes")
                        .doc(nuevo.idMensaje);
                    DocumentReference referenciaUsuario = baseDatosRef
                        .collection("usuarios")
                        .doc(Usuario.esteUsuario.idUsuario)
                        .collection("mensajes")
                        .doc(nuevo.idMensaje);

                    batchEliminacion.delete(referenciaRemitente);
                    batchEliminacion.delete(referenciaUsuario);
                    batchEliminacion.commit();
                  }
                }
              }
            }
          }

          if (dato.docChanges[a].type == DocumentChangeType.modified) {
            if (dato.docChanges[a].doc.get("idMensaje") != null &&
                dato.docChanges[a].doc.get("idMensaje") is String &&
                dato.docChanges[a].doc.get("Tipo Mensaje") != null &&
                dato.docChanges[a].doc.get("Tipo Mensaje") is String &&
                dato.docChanges[a].doc.get("respuesta") != null &&
                dato.docChanges[a].doc.get("respuesta") is bool &&
                dato.docChanges[a].doc.get("mensajeRespuesta") != null &&
                dato.docChanges[a].doc.get("mensajeRespuesta")
                    is Map<dynamic, dynamic> &&
                dato.docChanges[a].doc.get("mensajeLeidoRemitente") != null &&
                dato.docChanges[a].doc.get("mensajeLeidoRemitente") is bool &&
                dato.docChanges[a].doc.get("Nombre emisor") != null &&
                dato.docChanges[a].doc.get("Nombre emisor") is String &&
                dato.docChanges[a].doc.get("idConversacion") != null &&
                dato.docChanges[a].doc.get("idConversacion") is String &&
                dato.docChanges[a].doc.get("mensajeLeido") != null &&
                dato.docChanges[a].doc.get("mensajeLeido") is bool &&
                dato.docChanges[a].doc.get("identificadorUnicoMensaje") !=
                    null &&
                dato.docChanges[a].doc.get("identificadorUnicoMensaje")
                    is String &&
                dato.docChanges[a].doc.get("idEmisor") != null &&
                dato.docChanges[a].doc.get("idEmisor") is String &&
                dato.docChanges[a].doc.get("Hora mensaje") != null &&
                dato.docChanges[a].doc.get("Hora mensaje") is Timestamp &&
                dato.docChanges[a].doc.get("Mensaje") != null &&
                dato.docChanges[a].doc.get("Mensaje") is String) {
              String idConversacion =
                  dato.docChanges[a].doc.get("idConversacion");
              String idMensajeUnico =
                  dato.docChanges[a].doc.get("identificadorUnicoMensaje");

              for (int s = 0;
                  s < conversaciones.listaDeConversaciones.length;
                  s++) {
                if (conversaciones.listaDeConversaciones[s].idConversacion ==
                    idConversacion) {
                  for (int x = 0;
                      x <
                          conversaciones.listaDeConversaciones[s].ventanaChat
                              .listadeMensajes.length;
                      x++) {
                    if (conversaciones.listaDeConversaciones[s].ventanaChat
                            .listadeMensajes[x].identificadorUnicoMensaje ==
                        idMensajeUnico) {
                      conversaciones.listaDeConversaciones[s].ventanaChat
                              .listadeMensajes[x].mensajeLeidoRemitente =
                          dato.docChanges[a].doc.get("mensajeLeidoRemitente");
                    }
                    notifyListeners();
                  }
                }
              }
            }
          }
        }
      }
    });
  }

  void escucharEstadoConversacion() async {
    await baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion")
        .get()
        .then((dato) {
      if (dato != null) {
        for (int i = 0; i < dato.docs.length; i++) {
          for (int b = 0; b < listaDeConversaciones.length; b++) {
            if (dato.docs[i].get("IdConversacion") != null &&
                dato.docs[i].get("Escribiendo") != null &&
                dato.docs[i].get("Escribiendo") != null &&
                dato.docs[i].get("Conectado") != null &&
                dato.docs[i].get("Conectado") != null) {
              if (dato.docs[i].get("IdConversacion") ==
                  listaDeConversaciones[b].idConversacion) {
                try {
                  if (dato.docs[i].get("Escribiendo") == true) {
                    listaDeConversaciones[b].ventanaChat.estadoConversacion =
                        estadosEscribiendoConversacion[1];
                    notifyListeners();
                  }
                  if (dato.docs[i].get("Escribiendo") == false) {
                    listaDeConversaciones[b].ventanaChat.estadoConversacion =
                        estadosEscribiendoConversacion[0];
                    notifyListeners();
                  }

                  if (dato.docs[i].get("Conectado") == true) {
                    listaDeConversaciones[b].ventanaChat.estadoConexion = true;
                    notifyListeners();
                  }
                  if (dato.docs[i].get("Conectado") == false) {
                    listaDeConversaciones[b].ventanaChat.estadoConexion = false;
                    notifyListeners();
                  }
                } on Exception {}
              }
            }
          }
        }
      }
    }).then((value) async {
      escuchadorEstadoConversacion = baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("estados conversacion")
          .snapshots()
          .listen((dato) {
        if (dato != null) {
          for (int i = 0; i < dato.docs.length; i++) {
            for (int b = 0; b < listaDeConversaciones.length; b++) {
              if (dato.docs[i].get("IdConversacion") != null &&
                  dato.docs[i].get("Escribiendo") != null &&
                  dato.docs[i].get("Conectado") != null) {
                if (dato.docs[i].get("IdConversacion") ==
                    listaDeConversaciones[b].idConversacion) {
                  try {
                    if (dato.docs[i].get("Escribiendo") == true) {
                      listaDeConversaciones[b].ventanaChat.estadoConversacion =
                          estadosEscribiendoConversacion[1];
                      Conversacion.conversaciones.notifyListeners();
                    }
                    if (dato.docs[i].get("Escribiendo") == false) {
                      listaDeConversaciones[b].ventanaChat.estadoConversacion =
                          estadosEscribiendoConversacion[0];
                      notifyListeners();
                    }

                    if (dato.docs[i].get("Conectado") == true) {
                      listaDeConversaciones[b].ventanaChat.estadoConexion =
                          true;
                      notifyListeners();
                    }
                    if (dato.docs[i].get("Conectado") == false) {
                      listaDeConversaciones[b].ventanaChat.estadoConexion =
                          false;
                      notifyListeners();
                    }
                  } on Exception {}
                }
              }
            }
          }
        }
      });
    });
  }

  Future<void> obtenerConversaciones() async {
    Conversacion.conversaciones.estadoModuloConversacion =
        EstadoModuloConversaciones.cargando;
    notifyListeners();
    await baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .get()
        .then((datos) async {
      List<Map<String, dynamic>> listaconversacionesSinProcesar = [];

      if (datos.docs.length > 0) {
        for (int a = 0; a < datos.docs.length; a++) {
          Map<String, dynamic> conversacion = new Map();
          Map<String, dynamic> mensajes = new Map();
          if (datos.docs[a].get("ultimoMensaje") != null &&
              datos.docs[a].get("cantidadMensajesSinLeer") != null &&
              datos.docs[a].get("IdConversacion") != null &&
              datos.docs[a].get("nombreRemitente") != null &&
              datos.docs[a].get("imagenRemitente") != null &&
              datos.docs[a].get("IdRemitente") != null &&
              datos.docs[a].get("IdMensajes") != null) {
            mensajes["nombre"] = datos.docs[a].get("nombreRemitente");
            conversacion["ultimoMensaje"] = datos.docs[a].get("ultimoMensaje");
            conversacion["cantidadMensajesSinLeer"] =
                datos.docs[a].get("cantidadMensajesSinLeer");
            conversacion["IdConversacion"] =
                datos.docs[a].get("IdConversacion");
            conversacion["nombreRemitente"] =
                datos.docs[a].get("nombreRemitente");
            conversacion["imagenRemitente"] =
                datos.docs[a].get("imagenRemitente");
            conversacion["IdRemitente"] = datos.docs[a].get("IdRemitente");
            conversacion["IdMensajes"] = datos.docs[a].get("IdMensajes");
            await baseDatosRef
                .collection("usuarios")
                .doc(Usuario.esteUsuario.idUsuario)
                .collection("mensajes")
                .where("idMensaje", isEqualTo: datos.docs[a].get("IdMensajes"))
                .orderBy("Hora mensaje", descending: true)
                .limit(25)
                .get()
                .then((dato) {
              if (dato != null) {
                List<Map<String, dynamic>> lista = [];
                for (int i = 0; i < dato.docs.length; i++) {
                  lista.add(dato.docs[i].data());
                  DateTime fechaTemp = (lista[i]["Hora mensaje"]).toDate();

                  lista[i]["Hora mensaje"] = fechaTemp.millisecondsSinceEpoch;
                }

                mensajes["listaMensajes"] = lista;
                mensajes["dimensionesImagen"] = 500.w;
                mensajes["dimensionesGif"] = 700.w;
                mensajes["idUsuario"] = Usuario.esteUsuario.idUsuario;
              }
            });

            listaconversacionesSinProcesar
                .add({"conversacion": conversacion, "mensajes": mensajes});
          }
        }
        Conversacion.conversaciones.listaDeConversaciones =
            await isolateConversaciones(listaconversacionesSinProcesar);
      } else {
        Conversacion.conversaciones.estadoModuloConversacion =
            EstadoModuloConversaciones.noCargado;
        notifyListeners();
      }
    }).then((value) async {
      calcularCantidadMensajesSinLeer();
      escucharEstadoConversacion();
      escucharConversaciones();
    });
  }

  void escucharConversaciones() {
    conversacionEliminada = StreamController.broadcast();

    escuchadorConversacion = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .orderBy("Hora", descending: true)
        .snapshots()
        .listen((datos) {
      if (Conversacion.conversaciones.estadoModuloConversacion ==
          EstadoModuloConversaciones.cagradoCorrectamente) {
        for (int s = 0; s < datos.docChanges.length; s++) {
          if (datos.docChanges[s].type == DocumentChangeType.removed) {
            for (int z = 0;
                z < Conversacion.conversaciones.listaDeConversaciones.length;
                z++) {
              if (datos.docChanges[s].doc.get("IdConversacion") ==
                  Conversacion
                      .conversaciones.listaDeConversaciones[z].idConversacion) {
                Conversacion.conversaciones.listaDeConversaciones.removeAt(z);
                String conversacionEliminadaId =
                    datos.docChanges[s].doc.get("IdConversacion");
                conversacionEliminada.add(conversacionEliminadaId);
                notifyListeners();
              }
            }
          }
        }

        for (int a = 0; a < datos.docs.length; a++) {
          bool existeConversacion = false;
          if (Conversacion.conversaciones.listaDeConversaciones != null) {
            for (int k = 0; k < datos.docs.length; k++) {
              for (int g = 0;
                  g < Conversacion.conversaciones.listaDeConversaciones.length;
                  g++) {
                if (datos.docs[k].get("IdConversacion") != null &&
                    datos.docs[k].get("nombreRemitente") != null &&
                    datos.docs[k].get("imagenRemitente") != null &&
                    datos.docs[k].get("cantidadMensajesSinLeer") != null) {
                  if (datos.docs[k].get("IdConversacion") ==
                      Conversacion.conversaciones.listaDeConversaciones[g]
                          .idConversacion) {
                    if (Conversacion.conversaciones.listaDeConversaciones[g]
                            .ultimoMensage !=
                        datos.docs[k].get("ultimoMensaje")) {
                      Conversacion.conversaciones.listaDeConversaciones[g]
                          .ultimoMensage = datos.docs[k].get("ultimoMensaje");
                      Conversacion.conversaciones.listaDeConversaciones[g]
                              .ventanaChat.ultimoMensaje =
                          Conversacion.conversaciones.listaDeConversaciones[g]
                              .ultimoMensage;
                    }
                    if (Conversacion.conversaciones.listaDeConversaciones[g]
                            .nombreRemitente !=
                        datos.docs[k].get("nombreRemitente")) {
                      Conversacion.conversaciones.listaDeConversaciones[g]
                              .nombreRemitente =
                          datos.docs[k].get("nombreRemitente");
                      Conversacion.conversaciones.listaDeConversaciones[g]
                              .ventanaChat.nombre =
                          Conversacion.conversaciones.listaDeConversaciones[g]
                              .nombreRemitente;
                    }

                    if (Conversacion.conversaciones.listaDeConversaciones[g]
                            .imagenRemitente !=
                        datos.docs[k].get("imagenRemitente")) {
                      Conversacion.conversaciones.listaDeConversaciones[g]
                              .imagenRemitente =
                          datos.docs[k].get("imagenRemitente");
                      Conversacion.conversaciones.listaDeConversaciones[g]
                              .ventanaChat.imagen =
                          Conversacion.conversaciones.listaDeConversaciones[g]
                              .imagenRemitente;
                    }
                    if (Conversacion.conversaciones.listaDeConversaciones[g]
                            .mensajesSinLeerConversaciones !=
                        datos.docs[k].get("cantidadMensajesSinLeer")) {
                      Conversacion.conversaciones.listaDeConversaciones[g]
                              .mensajesSinLeerConversaciones =
                          datos.docs[k].get("cantidadMensajesSinLeer");
                      Conversacion.conversaciones.listaDeConversaciones[g]
                              .ventanaChat.mensajesSinLeer =
                          Conversacion.conversaciones.listaDeConversaciones[g]
                              .mensajesSinLeerConversaciones;
                    }
                  }
                }
              }
            }
          }

          Conversacion.conversaciones.notifyListeners();

          for (int z = 0;
              z < Conversacion.conversaciones.listaDeConversaciones.length;
              z++) {
            if (Conversacion
                    .conversaciones.listaDeConversaciones[z].idConversacion ==
                datos.docs[a].get("IdConversacion")) {
              existeConversacion = true;
            }
          }

          if (!existeConversacion) {
            TituloChat chatVentana;
            if (datos.docs[a].get("ultimoMensaje") != null &&
                datos.docs[a].get("cantidadMensajesSinLeer") != null &&
                datos.docs[a].get("IdConversacion") != null &&
                datos.docs[a].get("nombreRemitente") != null &&
                datos.docs[a].get("imagenRemitente") != null &&
                datos.docs[a].get("IdRemitente") != null &&
                datos.docs[a].get("IdMensajes") != null) {
              chatVentana = new TituloChat(
                ultimoMensaje: datos.docs[a].get("ultimoMensaje"),
                estadoConexion: estadoConexionConversacion,
                mensajesSinLeer: datos.docs[a].get("cantidadMensajesSinLeer"),
                conversacion: null,
                idConversacion: datos.docs[a].get("IdConversacion"),
                estadoConversacion: " ",
                listadeMensajes: null,
                nombre: datos.docs[a].get("nombreRemitente"),
                imagen: datos.docs[a].get("imagenRemitente"),
                idRemitente: datos.docs[a].get("IdRemitente"),
                mensajeId: datos.docs[a].get("IdMensajes"),
              );
            }

            Conversacion nueva;
            if (datos.docs[a].get("ultimoMensaje") != null &&
                datos.docs[a].get("Grupo") != null &&
                datos.docs[a].get("IdConversacion") != null &&
                datos.docs[a].get("cantidadMensajesSinLeerPropios") != null &&
                datos.docs[a].get("cantidadMensajesSinLeer") != null &&
                datos.docs[a].get("IdRemitente") != null &&
                datos.docs[a].get("IdMensajes") != null &&
                datos.docs[a].get("imagenRemitente") != null &&
                chatVentana != null) {
              try {
                nueva = new Conversacion(
                    grupo: datos.docs[a].get("Grupo"),
                    mensajesPropiosSinLeerConversaciones:
                        datos.docs[a].get("cantidadMensajesSinLeerPropios"),
                    mensajesSinLeerConversaciones:
                        datos.docs[a].get("cantidadMensajesSinLeer"),
                    ultimoMensage: datos.docs[a].get("ultimoMensaje"),
                    idConversacion: datos.docs[a].get("IdConversacion"),
                    nombreRemitente: datos.docs[a].get("nombreRemitente"),
                    idRemitente: datos.docs[a].get("IdRemitente"),
                    idMensajes: datos.docs[a].get("IdMensajes"),
                    imagenRemitente: datos.docs[a].get("imagenRemitente"),
                    ventanaChat: chatVentana);
                chatVentana.conversacion = nueva;

                nueva.ventanaChat.idConversacion = nueva.idConversacion;
                bool conversacionEnLista = false;

                for (int s = 0;
                    s <
                        Conversacion
                            .conversaciones.listaDeConversaciones.length;
                    s++) {
                  if (nueva.idConversacion ==
                      Conversacion.conversaciones.listaDeConversaciones[s]
                          .idConversacion) {
                    conversacionEnLista = true;
                  }
                }
                if (conversacionEnLista == false) {
                  conversaciones.listaDeConversaciones.add(nueva);
                }

                if (BaseAplicacion.notificadorEstadoAplicacion?.index == 2) {
                  ControladorNotificacion.instancia
                      .mostrarNotificacionNuevaConversacion(
                          nueva.nombreRemitente);
                }
                if (BaseAplicacion.notificadorEstadoAplicacion?.index != 0) {
                  if (BaseAplicacion.claveBase.currentContext != null) {
                    ControladorNotificacion.instancia
                        .notificacionConversacionCreada(
                            BaseAplicacion.claveBase.currentContext,
                            nueva.nombreRemitente);
                  }
                }
              } on Exception {}
            }
          }
        }
      }
    });
  }

  static Future<int> eliminarConversaciones(String idConversacion,
      String idRemitente, String idMensaje, bool bloquear) async {
    int estadoOperacion;
    if (idConversacion != null &&
        idRemitente != null &&
        idMensaje != null &&
        bloquear != null) {
      if (!bloquear) {
        WriteBatch opceracionEliminacion = baseDatosRef.batch();
        DocumentReference referenciaConversacionEnLocal = baseDatosRef
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("conversaciones")
            .doc(idConversacion);
        DocumentReference referenciaConversacionEnRemitente = baseDatosRef
            .collection("usuarios")
            .doc(idRemitente)
            .collection("conversaciones")
            .doc(idConversacion);
        DocumentReference referenciaEstadoConversacionEnLocal = baseDatosRef
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("estados conversacion")
            .doc(idConversacion);
        DocumentReference referenciaEstadoConversacionEnRemitente = baseDatosRef
            .collection("usuarios")
            .doc(idRemitente)
            .collection("estados conversacion")
            .doc(idConversacion);

        opceracionEliminacion.delete(referenciaConversacionEnLocal);
        opceracionEliminacion.delete(referenciaEstadoConversacionEnLocal);
        opceracionEliminacion.delete(referenciaConversacionEnRemitente);
        opceracionEliminacion.delete(referenciaEstadoConversacionEnRemitente);
        await opceracionEliminacion.commit().then((value) {
          estadoOperacion = 0;
          for (int i = 0;
              i < Conversacion.conversaciones.listaDeConversaciones.length;
              i++) {
            if (Conversacion
                    .conversaciones.listaDeConversaciones[i].idConversacion ==
                idConversacion) {
              Conversacion.conversaciones.listaDeConversaciones.removeAt(i);
              Conversacion.conversaciones.notifyListeners();
            }
          }
        }).catchError((onError) {
          print(onError);
          estadoOperacion = 1;
        });
        Conversacion.conversaciones.notifyListeners();
      }
      if (bloquear) {
        WriteBatch opceracionEliminacion = baseDatosRef.batch();
        DocumentReference referenciaUsuarioBloquear =
            baseDatosRef.collection("usuarios").doc(idRemitente);
        DocumentReference referenciaUsuarioLocal = baseDatosRef
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario);
        DocumentReference referenciaConversacionEnLocal = baseDatosRef
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("conversaciones")
            .doc(idConversacion);
        DocumentReference referenciaConversacionEnRemitente = baseDatosRef
            .collection("usuarios")
            .doc(idRemitente)
            .collection("conversaciones")
            .doc(idConversacion);
        DocumentReference referenciaEstadoConversacionEnLocal = baseDatosRef
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("estados conversacion")
            .doc(idConversacion);
        DocumentReference referenciaEstadoConversacionEnRemitente = baseDatosRef
            .collection("usuarios")
            .doc(idRemitente)
            .collection("estados conversacion")
            .doc(idConversacion);

        opceracionEliminacion.update(referenciaUsuarioBloquear, {
          "bloqueados": FieldValue.arrayUnion([Usuario.esteUsuario.idUsuario])
        });
        opceracionEliminacion.update(referenciaUsuarioLocal, {
          "bloqueados": FieldValue.arrayUnion([idRemitente])
        });
        opceracionEliminacion.delete(referenciaConversacionEnLocal);
        opceracionEliminacion.delete(referenciaEstadoConversacionEnLocal);
        opceracionEliminacion.delete(referenciaConversacionEnRemitente);
        opceracionEliminacion.delete(referenciaEstadoConversacionEnRemitente);
        await opceracionEliminacion.commit().then((value) {
          estadoOperacion = 0;
          for (int i = 0;
              i < Conversacion.conversaciones.listaDeConversaciones.length;
              i++) {
            if (Conversacion
                    .conversaciones.listaDeConversaciones[i].idConversacion ==
                idConversacion) {
              Conversacion.conversaciones.listaDeConversaciones.removeAt(i);
              Conversacion.conversaciones.notifyListeners();
            }
          }
        }).catchError((onError) {
          print(onError);
          estadoOperacion = 1;
        });
        Conversacion.conversaciones.notifyListeners();
      }
    }
    return estadoOperacion;
  }

  Conversacion(
      {@required this.grupo,
      @required this.ultimoMensage,
      @required this.mensajesPropiosSinLeerConversaciones,
      @required this.idConversacion,
      @required this.mensajesSinLeerConversaciones,
      @required this.nombreRemitente,
      @required this.idRemitente,
      @required this.idMensajes,
      @required this.imagenRemitente,
      @required this.ventanaChat});

  Conversacion.instancia();

  void cerrarConexionesConversacion() {
    if (conversacionEliminada != null) {
      conversacionEliminada.close();
    }
    if (escuchadorConversacion != null) {
      escuchadorConversacion.cancel();
    }
    if (escuchadorMensajes != null) {
      escuchadorMensajes.cancel();
    }

    if (escuchadorEstadoConversacion != null) {
      escuchadorEstadoConversacion.cancel();
    }

    escuchadorEstadoConversacion = null;
    escuchadorMensajes = null;
    escuchadorConversacion = null;
  }
}
