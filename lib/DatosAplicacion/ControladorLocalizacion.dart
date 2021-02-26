import 'dart:async';

import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/models/DistanceDocSnapshot.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/point.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/geoflutterfire.dart';


class ControladorLocalizacion with ChangeNotifier {
  static ControladorLocalizacion instancia = new ControladorLocalizacion();

  Position posicion;
  var geo = Geoflutterfire();
  static final firestore = FirebaseFirestore.instance;
  GeoFirePoint miPosicion;
  double edadInicial = 19;
  double distanciaMaxima = 60;
  double edadFinal = 25;
  bool visualizarDistanciaEnMillas = false;
  bool mostrarmeEnHotty = true;
  bool mostrarMujeres = true;

  List<int> activadorEdadesDeseadas = new List();
  List<List<int>> grupoActivadorEdadesDeseadas = new List();
  Map<String, dynamic> mapaAjustes = new Map();
  List<Map<String, dynamic>> listaPerfilesNube = new List();

  Future<bool> guardarAjustes() async {
    rangoEdad();
    bool acabado = false;
    mapaAjustes["edadInicial"] = edadInicial.toInt();
    mapaAjustes["edadFinal"] = edadFinal.toInt();
    mapaAjustes["enMillas"] = visualizarDistanciaEnMillas;
    mapaAjustes["mostrarMujeres"] = mostrarMujeres;
    mapaAjustes["distanciaMaxima"] = distanciaMaxima;
    mapaAjustes["rangoEdades"] = activadorEdadesDeseadas;
    mapaAjustes["mostrarPerfil"] = mostrarmeEnHotty;

    FirebaseFirestore instanciaBaseDatos = FirebaseFirestore.instance;
    await instanciaBaseDatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .update({"Ajustes": mapaAjustes})
        .then((value) => acabado = true)
        .catchError((onError) =>
            print("Ha ocurrido un error guardando los ajustes: $onError"));

    return acabado;
  }

  ///
  ///
  ///
  ///
  ///GETTERS Y SETTERS
  bool get getMostrarMujeres => mostrarMujeres;

  set setMostrarMujeres(bool mostrarMujeres) {
    this.mostrarMujeres = mostrarMujeres;
    notifyListeners();
  }

  bool get getMostrarmeEnHotty => mostrarmeEnHotty;

  set setMostrarmeEnHotty(bool mostrarmeEnHotty) {
    this.mostrarmeEnHotty = mostrarmeEnHotty;
    notifyListeners();
  }

  bool get getVisualizarDistanciaEnMillas => visualizarDistanciaEnMillas;

  set setVisualizarDistanciaEnMillas(bool visualizarDistanciaEnMillas) {
    this.visualizarDistanciaEnMillas = visualizarDistanciaEnMillas;
    notifyListeners();
  }

  double get getEdadFinal => edadFinal;

  set setEdadFinal(double edadFinal) {
    this.edadFinal = edadFinal;

    notifyListeners();
  }

  double get getEdadInicial => edadInicial;

  set setEdadInicial(double edadInicial) {
    this.edadInicial = edadInicial;
    notifyListeners();
  }

  double get getDiistanciaMaxima => distanciaMaxima;

  set setDiistanciaMaxima(double diistanciaMaxima) {
    this.distanciaMaxima = diistanciaMaxima;
    notifyListeners();
  }
  ////////

  ///Metodos
  ///
  ///
  ///

  void rangoEdad() {
    activadorEdadesDeseadas.clear();
    int edadInicio = edadInicial.toInt();
    int edadFin = edadFinal.toInt();
    for (int i = 0; edadInicio <= edadFin; i++) {
      activadorEdadesDeseadas.add(edadInicio);
      edadInicio += 1;
    }
  }

  Future<GeoFirePoint> obtenerLocalizacionPorPrimeraVez() async {
    ControladorLocalizacion.instancia.rangoEdad();
    this.posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    miPosicion =
        geo.point(latitude: posicion.latitude, longitude: posicion.longitude);
    firestore
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .set({"posicion": miPosicion.data});

    return miPosicion;
  }

  void cargaPerfiles() async {
    int contadorPosicionesListaTemporal = 0;
    List<int> edadesTemporales = new List();
    List<List<int>> grupoListaEdadesTemporales = new List();
    int diferenciaPosicionLista = activadorEdadesDeseadas.length;
    for (int a = 0;
        a < activadorEdadesDeseadas.length;
        a++, contadorPosicionesListaTemporal++) {
      if (contadorPosicionesListaTemporal < 10) {
        edadesTemporales.add(activadorEdadesDeseadas[a]);
        if (a == activadorEdadesDeseadas.length - 1) {
          contadorPosicionesListaTemporal++;
        }
      }

      if (contadorPosicionesListaTemporal == 10 ||
          (contadorPosicionesListaTemporal == edadesTemporales.length &&
              edadesTemporales.length < 10)) {
        diferenciaPosicionLista = activadorEdadesDeseadas.length - a;
        List<int> cacheEdades = new List();
        cacheEdades = edadesTemporales;

        grupoListaEdadesTemporales = List.from(grupoListaEdadesTemporales)
          ..add(cacheEdades.toList());
        contadorPosicionesListaTemporal = 0;
        edadesTemporales.clear();
        cacheEdades.clear();
        edadesTemporales.add(activadorEdadesDeseadas[a]);
      }
    }
    grupoActivadorEdadesDeseadas.addAll(grupoListaEdadesTemporales);
    QueryPerfiles.canalesCerrados();
    for (int c = 0; c < grupoActivadorEdadesDeseadas.length; c++) {
      cargarPerfiles(grupoActivadorEdadesDeseadas[c], c);
    }
  }

  void cargarPerfiles(List<int> edades, int cantidadEdades) async {
    Query referenciaColeccion = firestore
        .collection("usuarios")
        .where("Ajustes.mostrarPerfil", isEqualTo: true)
        .where("Sexo", isEqualTo: mostrarMujeres)
        .where("Edades", arrayContainsAny: edades)
        .limit(10);
    QueryPerfiles(
        referenciaColeccion: referenciaColeccion, indiceStream: cantidadEdades);

    // Perfiles.perfilesCitas.cargarIsolate(listaPerfilesNube);
    // recibirPerfiles.cancel();
  }

  Future<void> obtenerLocalizacion() async {
    posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    miPosicion =
        geo.point(latitude: posicion.latitude, longitude: posicion.longitude);
    firestore.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).update(
        {"posicion": miPosicion.data}).catchError((onError) => print(onError));
  }
}

class QueryPerfiles {
  static cerrarConvexionesQuery() {
    queryPerfiles.clear();
    flujo = null;
    streamsCreeados = false;

    contadorStreamsCerrados = 0;

    flujo = new StreamController<bool>();
  }

  static StreamController<bool> flujo = new StreamController<bool>();
  List<int> listaEdades = new List();
  bool streamCerrado = false;
  static bool streamsCreeados = false;
  static List<QueryPerfiles> queryPerfiles = new List();
  StreamSubscription<List<DistanceDocSnapshot>> recibirPerfiles;
  static var geo = Geoflutterfire();
  Query referenciaColeccion;
  int indiceStream = 0;
  static List<bool> listaStreamsCerrados = new List();
  static int contadorStreamsCerrados = 0;

  ///En en constructor añadimos el mismo objeto a una lista de streams creados y iniciamos el stream de geoflutterfire
  ///si creams tres streams de [GeoFlutterfire], hay un stream llamado [flujo] el cual escucha los valores booleanos que emiten los tres streams cuand hayan
  ///acabado, si creamos tres streams y flujo recibe tres booleanos con valor [false] entonces sabremos que todos los streams ya estan competos

  QueryPerfiles(
      {@required this.referenciaColeccion, @required this.indiceStream}) {
    queryPerfiles.add(this);
    recibirPerfiles = geo
        .collection(
          collectionRef: referenciaColeccion,
        )
        .within(
            center: ControladorLocalizacion.instancia.miPosicion,
            radius: ControladorLocalizacion.instancia.distanciaMaxima,
            field: "posicion",
            strictMode: true)
        .listen((event) {
      if (event.length > 0) {
        for (DistanceDocSnapshot documento in event) {
          if (documento.documentSnapshot.id != Usuario.esteUsuario.idUsuario) {
            Map<String, dynamic> mapaDatos = documento.documentSnapshot.data();
            mapaDatos["distancia"] = documento.distance;
            if (perfilExiste(mapaDatos["Id"]) == 0) {
              ControladorLocalizacion.instancia.listaPerfilesNube
                  .add(mapaDatos);
            }
          }
        }
        recibirPerfiles.cancel().then((value) {
          this.streamCerrado = true;
          flujo.add(this.streamCerrado);
        });
      }
      if (event.length == 0) {
        recibirPerfiles.cancel().then((value) {
          this.streamCerrado = true;
          flujo.add(this.streamCerrado);
        });
      }
    });
  }

  int perfilExiste(String idPerfil) {
    int idPerfilExiste = 0;
    if (ControladorLocalizacion.instancia.listaPerfilesNube.length > 0) {
      for (int i = 0;
          i < ControladorLocalizacion.instancia.listaPerfilesNube.length;
          i++) {
        if (ControladorLocalizacion.instancia.listaPerfilesNube[i]["Id"] ==
            idPerfil) {
          idPerfilExiste++;
        }
      }
    }

    return idPerfilExiste;
  }

  ///Este metodo tiene como objetivo escuchar las señales que mandan los diversos objetos [QueryPerfiles] cuando han terminado de obtener los perfiles con las edades deseadas para que sean procesadas por el isolate y hacer que sean perfiles
  static void canalesCerrados() async {
    flujo.stream.listen((event) {
      listaStreamsCerrados.add(event);
      if (listaStreamsCerrados.length ==
          ControladorLocalizacion
              .instancia.grupoActivadorEdadesDeseadas.length) {
        if (Usuario.esteUsuario.perfilesBloqueados != null) {
          if (Usuario.esteUsuario.perfilesBloqueados.length > 0) {
            for (int a = 0;
                a < Usuario.esteUsuario.perfilesBloqueados.length;
                a++) {
              for (int b = 0;
                  b <
                      ControladorLocalizacion
                          .instancia.listaPerfilesNube.length;
                  b++) {
                if (ControladorLocalizacion.instancia.listaPerfilesNube[b]
                        ["Id"] ==
                    Usuario.esteUsuario.perfilesBloqueados[a]) {
                  ControladorLocalizacion.instancia.listaPerfilesNube
                      .removeAt(b);
                }
              }
            }
          }
        }

        flujo.close().then((value) => Perfiles.cargarPerfilesCitas(
            ControladorLocalizacion.instancia.listaPerfilesNube));
      }
    });
  }
}
