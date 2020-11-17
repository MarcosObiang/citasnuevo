import 'dart:async';

import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/models/DistanceDocSnapshot.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/point.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:citasnuevo/DatosAplicacion/QueriesLocalizacion/geoflutterfire.dart';
import 'package:provider/provider.dart';

class ControladorLocalizacion with ChangeNotifier {
  static ControladorLocalizacion instancia = new ControladorLocalizacion();
  StreamSubscription<List<DistanceDocSnapshot>> recibirPerfiles;
  static Position posicion;
  static var geo = Geoflutterfire();
  static final firestore = FirebaseFirestore.instance;
  static GeoFirePoint miPosicion;
  double edadInicial = 19;
  double distanciaMaxima = 10;
  double edadFinal = 25;
  bool visualizarDistanciaEnMillas = false;
  bool mostrarmeEnHotty = true;
  bool mostrarMujeres = true;
   static List<int> activadorEdadesDeseadas = new List();
  Map<String, dynamic> mapaAjustes = new Map();

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
    print(distanciaMaxima.toInt());
    print(activadorEdadesDeseadas);
  }

  static Future<GeoFirePoint> obtenerLocalizacionPorPrimeraVez() async {
    posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    miPosicion =
        geo.point(latitude: posicion.latitude, longitude: posicion.longitude);
    firestore
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .update({"posicion": miPosicion.data});

    print(posicion.toString());
    return miPosicion;
  }

  void cargarPerfiles() {
    miPosicion =
        geo.point(latitude: posicion.latitude, longitude: posicion.longitude);
    Query referenciaColeccion = firestore
        .collection("usuarios").where("Ajustes.mostrarPerfil",isEqualTo:true)
      
        .where("Edades", arrayContainsAny: activadorEdadesDeseadas).limit(10);
    List<Map<String, dynamic>> listaPerfilesNube = new List();
    recibirPerfiles = geo
        .collection(
          collectionRef: referenciaColeccion,
        )
        .within(
            center: miPosicion,
            radius: distanciaMaxima,
            field: "posicion",
            strictMode: true)
        .listen((event) {
      for (DistanceDocSnapshot documento in event) {
        Map<String, dynamic> mapaDatos = documento.documentSnapshot.data();
        mapaDatos["distancia"] = documento.distance;

        listaPerfilesNube.add(mapaDatos);
      }
      Perfiles.perfilesCitas.cargarIsolate(listaPerfilesNube);
      recibirPerfiles.cancel();
    });
  }

  Future<void> obtenerLocalizacion() async {
    posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    miPosicion =
        geo.point(latitude: posicion.latitude, longitude: posicion.longitude);
    firestore.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).update(
        {"posicion": miPosicion.data}).catchError((onError) => print(onError));
    print(instancia);
  }
}
