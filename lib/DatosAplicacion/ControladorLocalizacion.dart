import 'dart:async';

import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/models/DistanceDocSnapshot.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/point.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/EstadoConexion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/geoflutterfire.dart';

class ControladorAjustes with ChangeNotifier {
  static ControladorAjustes instancia = new ControladorAjustes();

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
  bool mostrarCm = true;
  bool get getMostrarCm => this.mostrarCm;

  set setMostrarCm(bool mostrarCm) {
    this.mostrarCm = mostrarCm;
    notifyListeners();
  }

  List<int> activadorEdadesDeseadas = [];
  List<List<int>> grupoActivadorEdadesDeseadas = [];
  Map<String, dynamic> mapaAjustes = new Map();
  List<Map<String, dynamic>> listaPerfilesNube = [];

  Future<bool> guardarAjustes() async {
    rangoEdad();
    bool acabado = false;
    mapaAjustes["edadInicial"] = edadInicial.toInt();
    mapaAjustes["enCm"] = mostrarCm;
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
        .catchError((onError) {});

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
    ControladorAjustes.instancia.rangoEdad();
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
    List<int> edadesTemporales = [];
    List<List<int>> grupoListaEdadesTemporales = [];
    // ignore: unused_local_variable
    int diferenciaPosicionLista = activadorEdadesDeseadas.length;
    grupoActivadorEdadesDeseadas.clear();

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
        List<int> cacheEdades = [];
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

  void cargarPerfiles(List<int> edades, int cantidadEdades,) async {
    Query referenciaColeccion = firestore
        .collection("usuarios")
        .where("Ajustes.mostrarPerfil", isEqualTo: true)
        .where("Sexo", isEqualTo: mostrarMujeres)
        .where("Edades", arrayContainsAny: edades)
        .limit(15);
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
    queryPerfiles=null;
    queryPerfiles= [];
    flujo = null;
    streamsCreeados = false;
     listaStreamsCerrados=new List();

    contadorStreamsCerrados = 0;

    flujo = new StreamController.broadcast();
  }

  static StreamController<bool> flujo = new StreamController.broadcast();

  static bool streamsCreeados = false;
  static List<QueryPerfiles> queryPerfiles = [];
  static Geoflutterfire geo = Geoflutterfire();
  static List<bool> listaStreamsCerrados = [];
  static int contadorStreamsCerrados = 0;
  List<int> listaEdades = [];
  bool streamCerrado = false;
 var recibirPerfiles;
  Query referenciaColeccion;
  int indiceStream = 0;

  ///En en constructor añadimos el mismo objeto a una lista de streams creados e iniciamos el stream de geoflutterfire
  ///si creams tres streams de [GeoFlutterfire], hay un stream llamado [flujo] el cual escucha los valores booleanos que emiten los tres streams cuand hayan
  ///acabado, si creamos tres streams y flujo recibe tres booleanos con valor [false] entonces sabremos que todos los streams ya estan competos

  QueryPerfiles(
      {@required this.referenciaColeccion, @required this.indiceStream}) {
    try {
      queryPerfiles.add(this);
   
      recibirPerfiles = geo
          .collection(
            collectionRef: referenciaColeccion,
          )
          .within(
              center: ControladorAjustes.instancia.miPosicion,
              radius: ControladorAjustes.instancia.distanciaMaxima,
              field:  "posicion",
              strictMode: true).handleError((onError){
              recibirPerfiles.cancel().then((value) {
            this.streamCerrado = true;
            flujo.add(this.streamCerrado);
          });
              })
          .listen((event) {
        if (event.length > 0) {
          for (DistanceDocSnapshot documento in event) {
            if (documento.documentSnapshot.id !=
                Usuario.esteUsuario.idUsuario) {
              Map<String, dynamic> mapaDatos =
                  documento.documentSnapshot.data();
              mapaDatos["distancia"] = documento.distance;
            /*  if (_perfilExiste(mapaDatos["Id"]) == 0) {
                ControladorAjustes.instancia.listaPerfilesNube.add(mapaDatos);
              }*/

                  ControladorAjustes.instancia.listaPerfilesNube.add(mapaDatos);
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

  
    } on Exception {
      cerrarConvexionesQuery();
      QueryPerfiles.listaStreamsCerrados = null;
      Perfiles.perfilesCitas.estadoLista = EstadoListaPerfiles.errorCargarLista;
      Usuario.esteUsuario.notifyListeners();
    }

    if (EstadoConexionInternet.estadoConexion.conexion !=
        EstadoConexion.conectado) {
          Perfiles.perfilesCitas.estadoLista=EstadoListaPerfiles.listaVacia;
          Perfiles.perfilesCitas.notifyListeners();
      throw Exception("Error al obtener perfiles");
    }
  }

  handleError() {
    throw Exception("No se pueden cargar los perfiles");
  }

  /// Con este metodo probamos que no exista otro igual
  /// probamos que no exista otro perfil igual

  int _perfilExiste(String idPerfil) {
    int idPerfilExiste = 0;
    if (ControladorAjustes.instancia.listaPerfilesNube.length > 0) {
      for (int i = 0;
          i < ControladorAjustes.instancia.listaPerfilesNube.length;
          i++) {
        if (ControladorAjustes.instancia.listaPerfilesNube[i]["Id"] ==
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
          ControladorAjustes.instancia.grupoActivadorEdadesDeseadas.length) {
        if (Usuario.esteUsuario.perfilesBloqueados != null) {
          if (Usuario.esteUsuario.perfilesBloqueados.length > 0) {
            for (int a = 0;
                a < Usuario.esteUsuario.perfilesBloqueados.length;
                a++) {
              for (int b = 0;
                  b < ControladorAjustes.instancia.listaPerfilesNube.length;
                  b++) {
                if (ControladorAjustes.instancia.listaPerfilesNube[b]["Id"] ==
                    Usuario.esteUsuario.perfilesBloqueados[a]) {
                  ControladorAjustes.instancia.listaPerfilesNube.removeAt(b);
                }
              }
            }
          }
        }

        flujo.close().then((value) {
          if (ControladorAjustes.instancia.listaPerfilesNube.isNotEmpty) {
            Perfiles.cargarPerfilesCitas(
                ControladorAjustes.instancia.listaPerfilesNube);
          } else {
            Perfiles.perfilesCitas.estadoLista = EstadoListaPerfiles.listaVacia;
              Usuario.esteUsuario.notifyListeners();
          }
        });
      } else{
      

      }
    });
  }
}
