import 'dart:math';

import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatosPerfiles {
  static String nombreUsuarioLocal = Usuario.esteUsuario.nombre;
  static String aliasUsuarioLocal = Usuario.esteUsuario.alias;
  static String idUsuarioLocal = Usuario.esteUsuario.idUsuario;

  String nombreusuaio;
  String mensaje;
  String idUsuario;
  bool imagenAdquirida;
  String imagen;
  double valoracion;
  List<Widget> carrete = new List();

  List<Map<String, dynamic>> linksHistorias = new List();
  FirebaseFirestore baseDatosRef;
  Map<String, dynamic> datosValoracion = new Map();
  String crearCodigo() {
    List<String> letras = [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    ];
    List<String> numero = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
    var random = Random();
    int primeraLetra = random.nextInt(26);
    String codigo_final = letras[primeraLetra];

    for (int i = 0; i <= 20; i++) {
      int selector_aleatorio_num_letra = random.nextInt(20);
      int aleatorio_letra = random.nextInt(27);
      int aleatorio_numero = random.nextInt(9);
      if (selector_aleatorio_num_letra <= 2) {
        selector_aleatorio_num_letra = 2;
      }
      if (selector_aleatorio_num_letra % 2 == 0) {
        codigo_final = "${codigo_final}${(numero[aleatorio_numero])}";
      }
      if (aleatorio_letra % 3 == 0) {
        int mayuscula = random.nextInt(9);
        if (selector_aleatorio_num_letra <= 2) {
          int suerte = random.nextInt(2);
          suerte == 0
              ? selector_aleatorio_num_letra = 3
              : selector_aleatorio_num_letra = 2;
        }
        if (mayuscula % 2 == 0) {
          codigo_final =
              "${codigo_final}${(letras[aleatorio_letra]).toUpperCase()}";
        }
        if (mayuscula % 3 == 0) {
          codigo_final =
              "${codigo_final}${(letras[aleatorio_letra]).toLowerCase()}";
        }
      }
    }
    return codigo_final;
  }

  void crearDatosValoracion() {
    imagenAdquirida = false;
    if (Usuario.esteUsuario.ImageURL1["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL1["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL2["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL2["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL3["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL3["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL4["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL4["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL5["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL5["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL6["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL6["Imagen"];
      imagenAdquirida = true;
    }
    String idValor=crearCodigo();

    datosValoracion["Imagen Usuario"] = imagen;
    datosValoracion["Nombre emisor"] = nombreUsuarioLocal;
    datosValoracion["Alias Emisor"] = aliasUsuarioLocal;
    datosValoracion["Id emisor"] = idUsuarioLocal;
    datosValoracion["Valoracion"] = valoracion;
    datosValoracion["Mensaje"] = this.mensaje;
    datosValoracion["Time"] = DateTime.now();
    datosValoracion["idDestino"] = idUsuario;
    datosValoracion["revelada"] = false;
    datosValoracion["id valoracion"] = idValor;
    _enviarValoracion(idValor);
  }

  DatosPerfiles();
  DatosPerfiles.citas(
      {@required this.carrete,
      @required this.linksHistorias,
      @required this.valoracion,
      @required this.nombreusuaio,
      @required this.idUsuario}) {}
  DatosPerfiles.amistad(
      {@required this.carrete,
      @required this.nombreusuaio,
      @required this.linksHistorias,
      @required this.idUsuario});
  void _enviarValoracion(String idvalor) async {
    baseDatosRef = FirebaseFirestore.instance;
    await baseDatosRef.collection("valoraciones").doc(idvalor).set(datosValoracion);
  }
}
