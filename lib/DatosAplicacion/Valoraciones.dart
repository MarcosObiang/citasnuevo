import 'dart:async';

import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/GeneradorCodigos.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/ObtenerImagenPerfil.dart';

import 'package:citasnuevo/InterfazUsuario/Valoraciones/ListaValoraciones.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Usuario.dart';

import 'package:ntp/ntp.dart';

enum RevelarValoracionEstado { noRevelada, revelando, revelada }

class Valoracion extends ChangeNotifier {
  static Valoracion instanciar = Valoracion();
   bool errorObtenerValoraciones = false;
  static DateTime tiempoReferencia;
  String imagenEmisor;
  String idEmisor;
  String aliasEmisor;
  String nombreEmisor;
  DateTime fechaValoracion;
  DateTime fechaCaducidad;
  int segundosRestantes;
  String mensaje;
  double valoracion;
  String idValoracion;
  bool valoracionRevelada = false;
  bool valoracionVisible = true;
  RevelarValoracionEstado estadoRevelacion = RevelarValoracionEstado.noRevelada;
  ValueNotifier<bool> notificadorEliminacion;
  static StreamSubscription<QuerySnapshot> escuchadorValoraciones;
  static StreamSubscription<QuerySnapshot> escuchadorMedia;
  bool get getValoracionRevelada => valoracionRevelada;

  set setValoracionRevelada(bool valoracionRevelada) {
    this.valoracionRevelada = valoracionRevelada;
    if(valoracionRevelada){
      this.estadoRevelacion=RevelarValoracionEstado.revelada;
      Valoracion.instanciar.notifyListeners();
    }

    if (this.valoracionRevelada &&
        ListaDeValoraciones.llaveListaValoraciones.currentContext != null) {
      ListaDeValoracionesState.notifiacionValoracionRevelada(
          ListaDeValoraciones.llaveListaValoraciones.currentContext);
    }
  }

  StreamController<int> notificadorFinTiempo = StreamController.broadcast();

  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
  DateTime fechaParaQuery;
  static var formatoTiempo = new DateFormat("HH:mm:ss");
  double mediaUsuario;
  List<Valoracion> listaDeValoraciones = new List();
  int visitasTotales;
  static String idUsuarioDestino = Usuario.esteUsuario.idUsuario;

  void limpiarValoraciones() {
    for (int i = 0; i < Valoracion.instanciar.listaDeValoraciones.length; i++) {
      Valoracion.instanciar.listaDeValoraciones[i].notificadorFinTiempo.close();
    }
    if (escuchadorMedia != null) {
      escuchadorMedia.cancel();
      escuchadorMedia = null;
    }

    if (escuchadorValoraciones != null) {
      escuchadorValoraciones.cancel().catchError((error) {
        print(error);
      });
      escuchadorValoraciones = null;
    }
  }

  Valoracion.crear({
    @required this.idValoracion,
    @required this.fechaValoracion,
    @required this.idEmisor,
    @required this.imagenEmisor,
    @required this.aliasEmisor,
    @required this.nombreEmisor,
    @required this.mensaje,
    @required this.valoracion,
    @required this.valoracionRevelada,
    @required this.fechaCaducidad,
  }) {
    notificadorEliminacion = new ValueNotifier(this.valoracionVisible);
    segundosRestantes = fechaCaducidad.difference(tiempoReferencia).inSeconds;
    if (segundosRestantes > 86400) {
      segundosRestantes = 86400;
    }
    contadorTiempoSolicitudes();
  }
  Valoracion();
  Valoracion.instancia();

  void contadorTiempoSolicitudes() async {
    Timer flutterTimer;

    flutterTimer = new Timer.periodic(Duration(seconds: 1), (valor) {
      if (segundosRestantes > 0 &&
          this.valoracionRevelada == false &&
          this.notificadorFinTiempo.isClosed == false) {
        segundosRestantes = segundosRestantes - 1;

        notificadorFinTiempo.add(segundosRestantes);
      }

      if (notificadorFinTiempo.isClosed) {
        flutterTimer.cancel();
      }
      if (segundosRestantes == 0 &&
          this.valoracionRevelada == false &&
          this.notificadorFinTiempo.isClosed == false) {
        flutterTimer.cancel();
        if (ListaDeValoraciones.llaveListaValoraciones.currentState == null) {
          listaDeValoraciones.removeWhere(
              (element) => element.idValoracion == this.idValoracion);
          rechazarValoracion(this.idValoracion);
        }
      }
    });
  }

  void obtenerValoraciones() async {
    FirebaseFirestore instanciaBaseDatos = FirebaseFirestore.instance;

    print(Usuario.esteUsuario.idUsuario);

    DateTime value = await NTP.now();
    if(value!=null){
      value=DateTime.now();
    }
    tiempoReferencia = value;
    fechaParaQuery = tiempoReferencia.subtract(Duration(days: 1));

    QuerySnapshot dato = await instanciaBaseDatos
        .collection("valoraciones")
        .where("Time", isGreaterThanOrEqualTo: fechaParaQuery)
        .where("idDestino", isEqualTo: Usuario.esteUsuario.idUsuario)
        .get().catchError((error){
          print("Error al recuperar valoraciones con tiempo de la base de datos");
        });
if(dato!=null){
    if (dato.docs.length > 0) {
      print("escuchado a ${dato.docs.length} valoraciones");

      print(dato.docs.length);
      for (int i = 0; i < dato.docs.length; i++) {
        print("Creando");
        if (dato.docs[i].id != "mediaPuntos") {
          crearValoracion(
              (dato.docs[i].get("Id emisor").toString()),
              (dato.docs[i].get("Nombre emisor").toString()).toString(),
              (dato.docs[i].get("Alias Emisor").toString()).toString(),
              (dato.docs[i].get("Imagen Usuario").toString()).toString(),
              (dato.docs[i].get("Mensaje").toString()).toString(),
              double.parse(
                  (dato.docs[i].get("Valoracion").toString()).toString()),
              (dato.docs[i].get("Time")).toDate(),
              (dato.docs[i].get("caducidad")).toDate(),
              (dato.docs[i].get("id valoracion").toString()).toString(),
              dato.docs[i].get("revelada"));
        }
        if (dato.docs[i].id == "mediaPuntos") {
          mediaUsuario = dato.docs[i].get("mediaTotal");
          visitasTotales = dato.docs[i].get("cantidadValoraciones");
        }
      }

      instanciar.notifyListeners();
    }
}


    QuerySnapshot datos = await instanciaBaseDatos
        .collection("valoraciones")
        .where("idDestino", isEqualTo: Usuario.esteUsuario.idUsuario)
        .where("revelada", isEqualTo: true)
        .where("Time", isLessThan: fechaParaQuery)
        .get().catchError((error){
          print("Error al recuperar valoraciones de la base de datos");
        });

        if(datos!=null){
if (datos.docs.length > 0) {
     

      print(datos.docs.length);
      for (int i = 0; i < datos.docs.length; i++) {
        print("Creando");
        if (datos.docs[i].id != "mediaPuntos") {
          crearValoracion(
              (datos.docs[i].get("Id emisor").toString()),
              (datos.docs[i].get("Nombre emisor").toString()).toString(),
              (datos.docs[i].get("Alias Emisor").toString()).toString(),
              (datos.docs[i].get("Imagen Usuario").toString()).toString(),
              (datos.docs[i].get("Mensaje").toString()).toString(),
              double.parse(
                  (datos.docs[i].get("Valoracion").toString()).toString()),
              (datos.docs[i].get("Time")).toDate(),
              (datos.docs[i].get("caducidad")).toDate(),
              (datos.docs[i].get("id valoracion").toString()).toString(),
              datos.docs[i].get("revelada"));
        }
        if (datos.docs[i].id == "mediaPuntos") {
          mediaUsuario = datos.docs[i].get("mediaTotal");
          visitasTotales = datos.docs[i].get("cantidadValoraciones");
        }
      }

      instanciar.notifyListeners();
    }
        }

        escucharValoraciones();

    
  }

  void obtenerMedia() async {
    FirebaseFirestore instanciaBaseDatos = FirebaseFirestore.instance;

    await instanciaBaseDatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("valoraciones")
        .get()
        .then((dato) {
      if (dato.docs.length > 0) {
        for (int a = 0; a < dato.docs.length; a++) {
          if (dato.docs[a].id == "mediaPuntos") {
            mediaUsuario = dato.docs[a].get("mediaTotal").toDouble();
            visitasTotales = dato.docs[a].get("cantidadValoraciones");
          }
        }
      }
    }).then((value) => escucharMedia());
  }

  void escucharMedia() async {
    FirebaseFirestore instanciaBaseDatos = FirebaseFirestore.instance;
    bool coincidencias;

    print(Usuario.esteUsuario.idUsuario);
    escuchadorMedia = instanciaBaseDatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("valoraciones")
        .snapshots()
        .listen((dato) {
      if (dato.docs.length > 0) {
        for (int a = 0; a < dato.docs.length; a++) {
          if (dato.docs[a].id == "mediaPuntos") {
            mediaUsuario = dato.docs[a].get("mediaTotal").toDouble();
            visitasTotales = dato.docs[a].get("cantidadValoraciones");
          }
        }

        instanciar.notifyListeners();
      }
    });
  }

  void escucharValoraciones() {
    FirebaseFirestore instanciaBaseDatos = FirebaseFirestore.instance;
    bool coincidencias;

    print(Usuario.esteUsuario.idUsuario);
    escuchadorValoraciones = instanciaBaseDatos
        .collection("valoraciones")
        .where("Time", isGreaterThanOrEqualTo: fechaParaQuery)
        .where("idDestino", isEqualTo: Usuario.esteUsuario.idUsuario)
        .snapshots()
        .listen((dato) {
          if(dato!=null){
      if (dato.docChanges.length > 0) {
        for (int a = 0; a < dato.docChanges.length; a++) {
          if (dato.docChanges[a].type != DocumentChangeType.removed) {
            for (int b = 0; b < dato.docChanges.length; b++) {
              coincidencias = false;
              int indice = 0;
              for (int i = 0; i < listaDeValoraciones.length; i++) {
                if (dato.docs[b].id != "mediaPuntos") {
                  if (dato.docChanges[b].doc.id ==
                      listaDeValoraciones[i].idValoracion) {
                    coincidencias = true;
                    indice = i;
                  }
                }
              }

              if (coincidencias) {
                if (dato.docChanges[b].doc.get("Nombre emisor") !=
                    listaDeValoraciones[indice].nombreEmisor) {
                  listaDeValoraciones[indice].nombreEmisor =
                      dato.docChanges[b].doc.get("Nombre emisor");
                }
                if (dato.docChanges[b].doc.get("Imagen Usuario") !=
                    listaDeValoraciones[indice].imagenEmisor) {
                  listaDeValoraciones[indice].imagenEmisor =
                      dato.docChanges[b].doc.get("Imagen Usuario");
                }
                if (dato.docChanges[b].doc.get("revelada") !=
                    listaDeValoraciones[indice].valoracionRevelada) {
                  listaDeValoraciones[indice].setValoracionRevelada =
                      dato.docChanges[b].doc.get("revelada");
                }
              }

              instanciar.notifyListeners();

              if (!coincidencias) {
                print("Creando");
                if (dato.docs[b].id != "mediaPuntos") {
                  sumarValoracion(
                      (dato.docChanges[b].doc.get("Id emisor").toString()),
                      (dato.docChanges[b].doc.get("Nombre emisor").toString())
                          .toString(),
                      (dato.docChanges[b].doc.get("Alias Emisor").toString())
                          .toString(),
                      (dato.docChanges[b].doc.get("Imagen Usuario").toString())
                          .toString(),
                      (dato.docChanges[b].doc.get("Mensaje").toString())
                          .toString(),
                      double.parse(
                          (dato.docChanges[b].doc.get("Valoracion").toString())
                              .toString()),
                      (dato.docChanges[b].doc.get("Time")).toDate(),
                      (dato.docChanges[b].doc.get("caducidad")).toDate(),
                      (dato.docChanges[b].doc.get("id valoracion").toString())
                          .toString(),
                      (dato.docChanges[b].doc.get("revelada")));
                }
              }
            }
          }

          if (dato.docChanges[a].type == DocumentChangeType.removed) {
            String idValoracionEliminar =
                dato.docChanges[a].doc.get("id valoracion");

            for (int z = 0;
                z < Valoracion.instanciar.listaDeValoraciones.length;
                z++) {
              if (Valoracion.instanciar.listaDeValoraciones[z].idValoracion ==
                  idValoracionEliminar) {
                if (ListaDeValoraciones.llaveListaValoraciones.currentState !=
                    null)
                  Valoracion.instanciar.listaDeValoraciones[z]
                      .valoracionVisible = false;
                Valoracion
                    .instanciar.listaDeValoraciones[z].notificadorEliminacion
                    .notifyListeners();
              }
              if (ListaDeValoraciones.llaveListaValoraciones.currentState ==
                  null) {
                int indiceValoracionEliminar = Valoracion
                    .instanciar.listaDeValoraciones
                    .indexWhere((valoracion) =>
                        valoracion.idValoracion == idValoracionEliminar);
                if (indiceValoracionEliminar >= 0) {
                  Valoracion.instanciar.listaDeValoraciones
                      .removeAt(indiceValoracionEliminar);
                }
              }
            }
          }
          if (dato.docs[a].id == "mediaPuntos") {
            mediaUsuario = dato.docChanges[a].doc.get("mediaTotal").toDouble();
            visitasTotales = dato.docChanges[a].doc.get("cantidadValoraciones");
          }
        }
      }
          }

      instanciar.notifyListeners();
    });
  }

  void crearValoracion(
      String idEmisor,
      String nombreUsuario,
      String aliasUsuario,
      String imagenURl,
      String mensajeUsuario,
      double puntuacion,
      DateTime fechaValoraciones,
      DateTime caducidad,
      String valoracionId,
      bool revelada) {
    print(puntuacion);
    Valoracion valoracion = new Valoracion.crear(
        fechaCaducidad: caducidad,
        idValoracion: valoracionId,
        idEmisor: idEmisor,
        nombreEmisor: nombreUsuario,
        aliasEmisor: aliasUsuario,
        imagenEmisor: imagenURl,
        fechaValoracion: fechaValoraciones,
        mensaje: mensajeUsuario,
        valoracionRevelada: revelada,
        valoracion: puntuacion);
    int i = listaDeValoraciones.length > 0 ? listaDeValoraciones.length : 0;
    listaDeValoraciones.insert(i, valoracion);
    listaDeValoraciones
        .sort((a, b) => b.fechaValoracion.compareTo(a.fechaValoracion));
    // list_live.llaveListaValoraciones.currentState.(i);

    //listaDeValoraciones = List.from(listaDeValoraciones)..add(valoracion);

    instanciar.notifyListeners();
  }

  void revelarValoracion() {
    FirebaseFirestore referenciaValoraciones = FirebaseFirestore.instance;
    referenciaValoraciones
        .collection("valoraciones")
        .doc(this.idValoracion)
        .update({"revelada": true});
  }

  void sumarValoracion(
      String idEmisor,
      String nombreUsuario,
      String aliasUsuario,
      String imagenURl,
      String mensajeUsuario,
      double puntuacion,
      DateTime fechaValoraciones,
      DateTime caducidad,
      String valoracionId,
      bool revelar) {
    print(puntuacion);
    Valoracion valoracion = new Valoracion.crear(
        fechaCaducidad: caducidad,
        idValoracion: valoracionId,
        idEmisor: idEmisor,
        nombreEmisor: nombreUsuario,
        aliasEmisor: aliasUsuario,
        imagenEmisor: imagenURl,
        fechaValoracion: fechaValoraciones,
        mensaje: mensajeUsuario,
        valoracion: puntuacion,
        valoracionRevelada: revelar);
    int i = listaDeValoraciones.length >= 0 ? listaDeValoraciones.length : 0;
    listaDeValoraciones.insert(i, valoracion);

    if (ListaDeValoraciones.llaveListaValoraciones.currentState != null) {
      ListaDeValoraciones.llaveListaValoraciones.currentState.insertItem(i);
    }

    //listaDeValoraciones = List.from(listaDeValoraciones)..add(valoracion);

    //instanciar.notifyListeners();
  }

  void rechazarValoracion(
    String id,
  ) async {
    baseDatosRef.collection("valoraciones").doc(id).delete().then((value) {
      print("valoracion eliminada");
    }).catchError((onError) {
      print(onError);
    });
  }

  void enviarSolicitudConversacion(String idRemitente, String nombreRemitente,
      String imagenRemitente, double calificacion, String idValoracion) async {
    String codigoSolicitud = GeneradorCodigos.instancia.crearCodigo();
    WriteBatch batchSolicitud = baseDatosRef.batch();
    DocumentReference referenciaColeccionSolicitud = baseDatosRef
        .collection("solicitudes conversaciones")
        .doc(codigoSolicitud);
    DocumentReference referenciaColeccionValoracion =
        baseDatosRef.collection("valoraciones").doc(idValoracion);
    batchSolicitud.set(referenciaColeccionSolicitud, {
      "idDestino": idRemitente,
      "tiemmpo": DateTime.now(),
      "solicitudRevelada": false,
      "caducidad": DateTime.now().add(Duration(days: 1)),
      "nombreEmisor": Usuario.esteUsuario.nombre,
      "idEmisor": Usuario.esteUsuario.idUsuario,
      "imagenEmisor": ObtenerImagenPerfl.instancia.obtenerImagenUsuarioLocal(),
      "calificacion": calificacion,
      "idSolicitudConversacion": codigoSolicitud
    });
    batchSolicitud.delete(referenciaColeccionValoracion);
    batchSolicitud.commit().catchError(
        (onError) => print("No se pudo envial la solicitud::$onError"));
  }
}
