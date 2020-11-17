import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/GeneradorCodigos.dart';
import 'package:citasnuevo/InterfazUsuario/Directo/live_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'Usuario.dart';
import 'dart:math';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/Mensajes.dart';

class Valoracion extends ChangeNotifier {
  static Valoracion instanciar = Valoracion();
  String imagenEmisor;
  String idEmisor;
  String aliasEmisor;
  String nombreEmisor;
  DateTime fechaValoracion;
  String mensaje;
  double valoracion;
  String idValoracion;
  bool valoracionRevelada;
  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;

  static double mediaUsuario;
  static List<Valoracion> listaDeValoraciones = new List();
  static int visitasTotales;
  static String idUsuarioDestino = Usuario.esteUsuario.idUsuario;

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
  });
  Valoracion();
  Valoracion.instancia();

  static Valoracion Puntuaciones = new Valoracion();
  static List<ValoracionWidget> puntuaciones = new List();

  void obtenerValoraciones() {
    FirebaseFirestore instanciaBaseDatos = FirebaseFirestore.instance;

    print(Usuario.esteUsuario.idUsuario);
    instanciaBaseDatos
        .collection("valoraciones")
        .where("Valoracion", isGreaterThanOrEqualTo: 5)
        .where("idDestino", isEqualTo: Usuario.esteUsuario.idUsuario)
        .get()
        .then((dato) {
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
    }).then((val) => escucharValoraciones());
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
    instanciaBaseDatos
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
    instanciaBaseDatos
        .collection("valoraciones")
        .where("Valoracion", isGreaterThanOrEqualTo: 5)
        .where("idDestino", isEqualTo: Usuario.esteUsuario.idUsuario)
        .snapshots()
        .listen((dato) {
      if (dato.docs.length > 0) {
        for (int a = 0; a < dato.docs.length; a++) {
          if (dato.docs[a].id == "mediaPuntos") {
            mediaUsuario = dato.docs[a].get("mediaTotal").toDouble();
            visitasTotales = dato.docs[a].get("cantidadValoraciones");
          }
        }

        for (int b = 0; b < dato.docs.length; b++) {
          coincidencias = false;
            int indice=0;
          for (int i = 0; i < listaDeValoraciones.length; i++) {
          
            if (dato.docs[b].id != "mediaPuntos") {
              if (dato.docs[b].id ==
                  listaDeValoraciones[i].idValoracion) {
                  
                   
                coincidencias = true;
                indice=i;
              
                  }}}

                if(coincidencias){
                  if (dato.docs[b].get("Nombre emisor") !=
                    listaDeValoraciones[indice].nombreEmisor) {
                  listaDeValoraciones[indice].nombreEmisor =
                      dato.docs[b].get("Nombre emisor");
                }
                if (dato.docs[b].get("Imagen Usuario") !=
                    listaDeValoraciones[indice].imagenEmisor) {
                  listaDeValoraciones[indice].imagenEmisor =
                      dato.docs[b].get("Imagen Usuario");
                }
                if (dato.docs[b].get("revelada") !=
                    listaDeValoraciones[indice].valoracionRevelada) {
                  listaDeValoraciones[indice].valoracionRevelada =
                      dato.docs[b].get("revelada");
                }
                }

                

                instanciar.notifyListeners();
   
            
          
          if (!coincidencias) {
            print("Creando");
            if (dato.docs[b].id != "mediaPuntos") {
              sumarValoracion(
                  (dato.docs[b].get("Id emisor").toString()),
                  (dato.docs[b].get("Nombre emisor").toString()).toString(),
                  (dato.docs[b].get("Alias Emisor").toString()).toString(),
                  (dato.docs[b].get("Imagen Usuario").toString()).toString(),
                  (dato.docs[b].get("Mensaje").toString()).toString(),
                  double.parse(
                      (dato.docs[b].get("Valoracion").toString()).toString()),
                  (dato.docs[b].get("Time")).toDate(),
                  (dato.docs[b].get("id valoracion").toString()).toString(),
                  (dato.docs[b].get("revelada")));
            }
          }
        }
      }
      instanciar.notifyListeners();
    }).onError((e) => print(e));
  }

  void crearValoracion(
      String idEmisor,
      String nombreUsuario,
      String aliasUsuario,
      String imagenURl,
      String mensajeUsuario,
      double puntuacion,
      DateTime fechaValoraciones,
      String valoracionId,
      bool revelada) {
    print(puntuacion);
    Valoracion valoracion = new Valoracion.crear(
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
      String valoracionId,
      bool revelar) {
    print(puntuacion);
    Valoracion valoracion = new Valoracion.crear(
        idValoracion: valoracionId,
        idEmisor: idEmisor,
        nombreEmisor: nombreUsuario,
        aliasEmisor: aliasUsuario,
        imagenEmisor: imagenURl,
        fechaValoracion: fechaValoraciones,
        mensaje: mensajeUsuario,
        valoracion: puntuacion,
        valoracionRevelada: revelar);
    int i = listaDeValoraciones.length > 0 ? listaDeValoraciones.length : 0;
   listaDeValoraciones.insert(0, valoracion);
    listaDeValoraciones
        .sort((a, b) => b.fechaValoracion.compareTo(a.fechaValoracion));
        if( list_live.llaveListaValoraciones.currentState!=null){
 list_live.llaveListaValoraciones.currentState.insertItem(0);
        }
   

    //listaDeValoraciones = List.from(listaDeValoraciones)..add(valoracion);

    //instanciar.notifyListeners();
  }

void rechazarValoracion(
    String id,
  ) async {
    QuerySnapshot documento = await baseDatosRef
        .collection("valoraciones")
        .where("id valoracion", isEqualTo: id)
        .get();
    for (DocumentSnapshot elemento in documento.docs) {
      if (elemento.get("id valoracion") == id) {
        String idVal = elemento.id;
        await baseDatosRef
            .collection("valoraciones")
            .doc(idVal)
            .delete()
            .then((value) {
          print("valoracion eliminada");
        }).catchError((onError) {
          print(onError);
        });
      }
    }
  }

  void enviarSolicitudConversacion(String idRemitente, String nombreRemitente,
      String imagenRemitente, double calificacion, String idValoracion) async {
    String codigoSolicitud =  GeneradorCodigos.instancia.crearCodigo();
    WriteBatch batchSolicitud = baseDatosRef.batch();
    DocumentReference referenciaColeccionSolicitud = baseDatosRef
        .collection("solicitudes conversaciones")
        .doc(codigoSolicitud);
    DocumentReference referenciaColeccionValoracion =
        baseDatosRef.collection("valoraciones").doc(idValoracion);
    batchSolicitud.set(referenciaColeccionSolicitud, {
      "idDestino": idRemitente,
      "solicitudRevelada": false,
      "nombreEmisor": Usuario.esteUsuario.nombre,
      "idEmisor": Usuario.esteUsuario.idUsuario,
      "imagenEmisor": Usuario.esteUsuario.ImageURL1["Imagen"],
      "calificacion": calificacion,
      "idSolicitudConversacion": codigoSolicitud
    });
    batchSolicitud.delete(referenciaColeccionValoracion);
    batchSolicitud.commit().catchError(
        (onError) => print("No se pudo envial la solicitud::$onError"));
  }



}

// ignore: must_be_immutable
class ValoracionWidget extends StatelessWidget {
  String idValoracion;
  String idEmisorValoracion;
  String nombreEmisor;
  String aliasEmisor;
  String imagenUsuario;
  String mensajeUsuario;
  double puntuacionUsuario;
  double porciento;
  Key clave;
  DateTime fechaValoracion;
  Animation animation;

  ValoracionWidget(
      {@required this.idValoracion,
      @required this.fechaValoracion,
      @required this.idEmisorValoracion,
      @required this.nombreEmisor,
      @required this.aliasEmisor,
      @required this.imagenUsuario,
      @required this.mensajeUsuario,
      @required this.puntuacionUsuario});

  Widget build(BuildContext context) {}
}
