import 'dart:math';

import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/GeneradorCodigos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatosPerfiles {
  static String nombreUsuarioLocal = Usuario.esteUsuario.nombre;
  static String aliasUsuarioLocal = Usuario.esteUsuario.alias;
  static String idUsuarioLocal = Usuario.esteUsuario.idUsuario;

  String nombreusuaio;
  String mensaje;
  int distancia;
  int edad;
  String idUsuario;
  bool imagenAdquirida;
  String imagen;
  double valoracion;
  bool verificado;
  List<Widget> carrete = new List();
  bool visible=true;
  List<Map<String, dynamic>> linksHistorias = new List();
  FirebaseFirestore baseDatosRef;
  Map<String, dynamic> datosValoracion = new Map();
  
  void crearDatosValoracion() {
    imagenAdquirida = false;
    if (Usuario.esteUsuario.imagenUrl1["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl1["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.imagenUrl2["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl2["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.imagenUrl3["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl3["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.imagenUrl4["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl4["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.imagenUrl5["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl5["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.imagenUrl6["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.imagenUrl6["Imagen"];
      imagenAdquirida = true;
    }
    String idValor=GeneradorCodigos.instancia.crearCodigo();

    datosValoracion["Imagen Usuario"] = imagen;
    datosValoracion["Nombre emisor"] = nombreUsuarioLocal;
    datosValoracion["Alias Emisor"] = aliasUsuarioLocal;
    datosValoracion["Id emisor"] = idUsuarioLocal;
    datosValoracion["Valoracion"] = valoracion;
    datosValoracion["Mensaje"] = this.mensaje;
    datosValoracion["Time"] = DateTime.now();
    datosValoracion["caducidad"]=DateTime.now().add(Duration(days: 1));
    datosValoracion["idDestino"] = idUsuario;
    datosValoracion["revelada"] = false;
    datosValoracion["id valoracion"] = idValor;
    datosValoracion["visible"]=visible;
    _enviarValoracion(idValor);
  }

  DatosPerfiles();
  DatosPerfiles.citas(
      {@required this.carrete,
      @required this.edad,
      @required this.distancia,
      @required this.verificado,

      @required this.linksHistorias,
      @required this.valoracion,
      @required this.nombreusuaio,
      @required this.idUsuario});
  DatosPerfiles.amistad(
      {@required this.carrete,
      @required this.nombreusuaio,
      @required this.linksHistorias,
      @required this.idUsuario});
  void _enviarValoracion(String idvalor) async {
    baseDatosRef = FirebaseFirestore.instance;
    if(valoracion>=5){

    await baseDatosRef.collection("valoraciones").doc(idvalor).set(datosValoracion);
    }
    if(valoracion<5){
      await baseDatosRef.collection("valoraciones negativas").doc(idvalor).set(datosValoracion);
    }
    
  }
}
