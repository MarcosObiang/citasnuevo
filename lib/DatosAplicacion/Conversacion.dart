import 'dart:isolate';
import 'dart:math';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'Usuario.dart';
import "package:citasnuevo/InterfazUsuario/Gente/people_screen_elements.dart";
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:intl/intl.dart';
import 'dart:isolate';

class Solicitud {
  static Solicitud instancia = Solicitud();

  Firestore baseDatosRef = Firestore.instance;
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

  Solicitud();
  void aceptarSolicitud(
      String mensajeRemitente,
      String nombreRemitente,
      String imagenRemitente,
      String idRemitente,
      int indice,
      String idVal) async {
    String idMensaje = crearCodigo();
    String idConversacion = crearCodigo();
    Map<String, dynamic> mensajeInicial = Map();
    if (mensajeRemitente != null && mensajeRemitente != " ") {
      mensajeInicial["Hora mensaje"] = DateTime.now();
      mensajeInicial["Mensaje"] = mensajeRemitente;
      mensajeInicial["idMensaje"] = idMensaje;
      mensajeInicial["idEmisor"] = idRemitente;
      mensajeInicial["Tipo Mensaje"] = "Texto";
      print(idRemitente);
      baseDatosRef
          .collection("usuarios")
          .document(Usuario.esteUsuario.idUsuario)
          .collection("mensajes")
          .document()
          .setData(mensajeInicial);
    }

    Map<String, dynamic> estadoConexionUsuario = Map();
    estadoConexionUsuario["Escribiendo"] = false;
    estadoConexionUsuario["Conectado"] = false;
    estadoConexionUsuario["IdConversacion"] = idConversacion;
    estadoConexionUsuario["Hora Conexion"] = DateTime.now();

    Map<String, String> solicitudParaRemitente = Map();
    solicitudParaRemitente["IdConversacion"] = idConversacion;
    solicitudParaRemitente["IdMensajes"] = idMensaje;
    solicitudParaRemitente["IdRemitente"] = idRemitente;
    solicitudParaRemitente["Nombre Remitente"] = nombreRemitente;
    solicitudParaRemitente["Imagen Remitente"] = imagenRemitente;
    Map<String, String> solicitudLocal = Map();
    solicitudLocal["idConversacion"] = idConversacion;
    solicitudLocal["IdMensajes"] = idMensaje;
    solicitudLocal["IdRemitente"] = Usuario.esteUsuario.idUsuario;
    solicitudLocal["Nombre Remitente"] = Usuario.esteUsuario.nombre;
    solicitudLocal["Imagen Remitente"] =
        Usuario.esteUsuario.ImageURL1["Imagen"];
    await baseDatosRef
        .collection("usuarios")
        .document(idRemitente)
        .collection("conversaciones")
        .document(idConversacion)
        .setData(solicitudLocal);
    await baseDatosRef
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .document(idConversacion)
        .setData(solicitudParaRemitente);
    await baseDatosRef
        .collection("usuarios")
        .document(idRemitente)
        .collection("estados conversacion")
        .document(idConversacion)
        .setData(estadoConexionUsuario);
    await baseDatosRef
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion")
        .document(idConversacion)
        .setData(estadoConexionUsuario);
    rechazarSolicitud(idVal, indice);
  }

  void rechazarSolicitud(String idValoracion, int indice) {
    print(idValoracion);

    print(indice);
    Firestore baseDatosRef = Firestore.instance;
    baseDatosRef
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("valoraciones")
        .where("id valoracion", isEqualTo: idValoracion)
        .getDocuments()
        .then((value) {
      var referencia = value.documents[0].reference.delete();
    });

    if (indice != null) {
      Valoraciones.puntuaciones.removeAt(indice);
    }
  }
}




class Conversacion extends ChangeNotifier {
  String idConversacion;
  List<String> estadosEscribiendoConversacion = [
    " ",
    "Escribiendo",
    "Grabando Audio"
  ];
  List<String> estadoConexionConversacion = ["En Linea", " "];
  String nombreRemitente;
  String idRemitente;
  String idMensajes;
  String imagenRemitente;
  TituloChat ventanaChat;
  static Firestore baseDatosRef = Firestore.instance;
  static Conversacion conversaciones = new Conversacion.Instancia();
  List<Conversacion> listaDeConversaciones = new List();

  void escucharMensajes() {
    Mensajes nuevo;
    baseDatosRef
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .limit(1)
        .orderBy("Hora mensaje", descending: true)
        .snapshots()
        .listen((dato) {
      for (int a = 0; a < dato.documents.length; a++) {
        for (int i = 0; i < conversaciones.listaDeConversaciones.length; i++) {
          if (conversaciones.listaDeConversaciones[i].idMensajes ==
              dato.documents[a].data["idMensaje"]) {
            if (dato.documents[a].data["Tipo Mensaje"] == "Texto" ||
                dato.documents[a].data["Tipo Mensaje"] == "Imagen") {
              nuevo = new Mensajes(
                tipoMensaje: dato.documents[a].data["Tipo Mensaje"],
                idMensaje: dato.documents[a].data["idMensaje"],
                idEmisor: dato.documents[a].data["idEmisor"],
                horaMensaje: (dato.documents[a].data["Hora mensaje"]).toDate(),
                mensaje: dato.documents[a].data["Mensaje"],
              );
            }
            if (dato.documents[a].data["Tipo Mensaje"] == "Audio") {
              nuevo = new Mensajes.Audio(
                tipoMensaje: dato.documents[a].data["Tipo Mensaje"],
                idMensaje: dato.documents[a].data["idMensaje"],
                idEmisor: dato.documents[a].data["idEmisor"],
                horaMensaje: (dato.documents[a].data["Hora mensaje"]).toDate(),
                mensaje: dato.documents[a].data["Mensaje"],
              );
            }

            conversaciones
                    .listaDeConversaciones[i].ventanaChat.listadeMensajes =
                List.from(conversaciones
                    .listaDeConversaciones[i].ventanaChat.listadeMensajes)
                  ..add(nuevo);
            print(
                "${conversaciones.listaDeConversaciones[i].ventanaChat.listadeMensajes.length} esta es la longitud de la lista a la hora del cambio");
            notifyListeners();
          }
        }
      }
    });
  }
init(){
  obtenerConversaciones();
  escucharEstadoConversacion();
}
  void escucharEstadoConversacion() {
   print("Escuchando estado");
    baseDatosRef
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion").where("Conectado",isEqualTo:true)
        .snapshots()
        .listen((dato) {
          
        
      for (int i = 0; i < listaDeConversaciones.length; i++) {
        if (dato.documents[0].data["IdConversacion"] ==
            listaDeConversaciones[i].idConversacion) {
          if (dato.documents[0].data["Escribiendo"] == true) {
            print("Escuchando estado");
            listaDeConversaciones[i].ventanaChat.estadoConversacion =
                estadosEscribiendoConversacion[1];
            notifyListeners();
          }
          if (dato.documents[0].data["Escribiendo"] == false) {
            listaDeConversaciones[i].ventanaChat.estadoConversacion =
                estadosEscribiendoConversacion[0];
            notifyListeners();
          }
        }
      }
    });
  }

 static void obtenerConversaciones()  {
    baseDatosRef
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .getDocuments()
        .then((datos) async {
      for (int a = 0; a < datos.documents.length; a++) {
        print("${datos.documents.length} total de conversaciones");
        TituloChat chatVentana = new TituloChat(
          conversacion: null,
          idConversacion: datos.documents[a].data["IdConversacion"],
          estadoConversacion: " ",
          listadeMensajes: null,
          nombre: datos.documents[a].data["Nombre Remitente"],
          imagen: datos.documents[a].data["Imagen Remitente"],
          idRemitente: datos.documents[a].data["IdRemitente"],
          mensajeId: datos.documents[a].data["IdMensajes"],
        );
        
        Conversacion nueva = new Conversacion(
            idConversacion: datos.documents[a].data["IdConversacion"],
            nombreRemitente: datos.documents[a].data["Nombre Remitente"],
            idRemitente: datos.documents[a].data["IdRemitente"],
            idMensajes: datos.documents[a].data["IdMensajes"],
            imagenRemitente: datos.documents[a].data["Imagen Remitente"],
            ventanaChat: chatVentana);
            
        print("${nueva.idRemitente}este es mi compañero");
        nueva.ventanaChat.idConversacion = nueva.idConversacion;
       
       
     //  nueva.ventanaChat.listadeMensajes = await obtenerMensajes(nueva);
        

        print(
            "${nueva.ventanaChat.idConversacion}este es miffff compañero en el chat");

        conversaciones.listaDeConversaciones =
            List.from(conversaciones.listaDeConversaciones)..add(nueva);
        print(
            "${nueva.ventanaChat.listadeMensajes.length} cantidad de mensajes para mi");
      }
    });
  }

 

  Conversacion(
      {@required this.idConversacion,
      @required this.nombreRemitente,
      @required this.idRemitente,
      @required this.idMensajes,
      @required this.imagenRemitente,
      @required this.ventanaChat});

  Conversacion.Instancia();
}
