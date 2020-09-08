import 'dart:async';
import 'dart:isolate';
import 'dart:isolate';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/InterfazUsuario/Directo/live_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';

import "package:citasnuevo/InterfazUsuario/Gente/people_screen_elements.dart";
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/base_app.dart';


import 'Usuario.dart';

class Solicitud {
  static Solicitud instancia = Solicitud();

  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
 HttpsCallable llamadaFuncionAceptarSolicitud=CloudFunctions.instance.getHttpsCallable(functionName: "aceptarLikeIniciarConversacion");
 Future<void>aceptarLike(String nombreRemitente,String imagenRemitente,String idRemitente,String mensajeRemitente)async{
  String idMensajes=crearCodigo();
  HttpsCallableResult  respuesta=await llamadaFuncionAceptarSolicitud.call([<String,dynamic>{
    "nombreSolicitante":nombreRemitente,"imagenSolicitante":imagenRemitente,"idSolicitante":idRemitente,
    "nombreAceptador":Usuario.esteUsuario.nombre,"imagenAceptador":VideoLlamada.obtenerImagenUsuarioLocal(),
    "idAceptador":Usuario.esteUsuario.idUsuario,
    "idMensajes":idMensajes,"idConversacion":idMensajes,"hora":"DateTime.now().toString()"


  }]).catchError((onError){
    print(onError);
    print("object");
  });
  print(respuesta);
 }

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
      
      String idVal) async {
    String idMensaje = crearCodigo();
    String idConversacion = crearCodigo();
    Map<String, dynamic> mensajeInicial = Map();
    if (mensajeRemitente != null && mensajeRemitente != " ") {
      mensajeInicial["Hora mensaje"] = DateTime.now();
      mensajeInicial["Mensaje"] = mensajeRemitente;
      mensajeInicial["idMensaje"] = idMensaje;
      mensajeInicial["idEmisor"] = idRemitente;
      mensajeInicial["Nombre emisor"] = Usuario.esteUsuario.idUsuario;
      mensajeInicial["Tipo Mensaje"] = "Texto";
      print(idRemitente);
      baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("mensajes")
          .doc()
          .set(mensajeInicial);
    }

    Map<String, dynamic> estadoConexionUsuario = Map();
    estadoConexionUsuario["Escribiendo"] = false;
    estadoConexionUsuario["Conectado"] = false;
    estadoConexionUsuario["IdConversacion"] = idConversacion;
    estadoConexionUsuario["Hora Conexion"] = DateTime.now();

    Map<String, dynamic> solicitudParaRemitente = Map();
    solicitudParaRemitente["Hora"] = DateTime.now();
    solicitudParaRemitente["IdConversacion"] = idConversacion;
    solicitudParaRemitente["IdMensajes"] = idMensaje;
    solicitudParaRemitente["IdRemitente"] = idRemitente;
    solicitudParaRemitente["nombreRemitente"] = nombreRemitente;
    solicitudParaRemitente["imagenRemitente"] = imagenRemitente;
    solicitudParaRemitente["Grupo"] = false;
    Map<String, dynamic> solicitudLocal = Map();
    solicitudLocal["Hora"] = DateTime.now();
    solicitudLocal["IdConversacion"] = idConversacion;
    solicitudLocal["IdMensajes"] = idMensaje;
    solicitudLocal["IdRemitente"] = Usuario.esteUsuario.idUsuario;
    solicitudLocal["nombreRemitente"] = Usuario.esteUsuario.nombre;
    solicitudLocal["imagenRemitente"] = Usuario.esteUsuario.ImageURL1["Imagen"];
    solicitudLocal["Grupo"] = false;
    WriteBatch batch=baseDatosRef.batch();
    DocumentReference valoracionEliminar=baseDatosRef.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).collection("valoraciones").doc(idVal);
    DocumentReference conversacionesRemitente=baseDatosRef.collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);

      //  .set(solicitudLocal);
     DocumentReference conversacionesLocal= baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(idConversacion);
       // .set(solicitudParaRemitente);
     DocumentReference estadoConversacionesRemitente= baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("estados conversacion")
        .doc(idConversacion);
       // .set(estadoConexionUsuario);
   DocumentReference estadoConversacionesLocal= baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion")
        .doc(idConversacion);
     //   .set(estadoConexionUsuario);


      batch.set(conversacionesRemitente, solicitudLocal);
      batch.set(conversacionesLocal, solicitudParaRemitente);
      batch.set(estadoConversacionesRemitente, estadoConexionUsuario);
      batch.set(estadoConversacionesLocal, estadoConexionUsuario);
      batch.delete(valoracionEliminar);
      await batch.commit().then((value) {
       rechazarSolicitud(idVal, );
     
        print("value");
      }).catchError((onError)=>print(onError));
    
  }

  void rechazarSolicitud(String id,)async{
    QuerySnapshot documento = await baseDatosRef.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).collection("valoraciones").where("id valoracion",isEqualTo: id).get();
    for(DocumentSnapshot elemento in documento.docs){
      if(elemento.get("id valoracion")==id){
String idVal=elemento.id;
await baseDatosRef.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).collection("valoraciones").doc(idVal).delete().then((value) {
  print("valoracion eliminada");
}).catchError((onError){
  print(onError);
});


      }

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

  String nombreRemitente;
  bool estadoConexionConversacion = false;
  String idRemitente;
  String idMensajes;
  String imagenRemitente;
  bool grupo;
  TituloChat ventanaChat;
  static FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
  static Conversacion conversaciones = new Conversacion.instancia();
  List<Conversacion> listaDeConversaciones = new List();

  void escucharMensajes() {
    Mensajes nuevo;
    baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .limit(1)
        .orderBy("Hora mensaje", descending: true)
        .snapshots()
        .listen((dato) {
      for (int a = 0; a < dato.docs.length; a++) {
        for (int i = 0; i < conversaciones.listaDeConversaciones.length; i++) {
          if (conversaciones.listaDeConversaciones[i].idMensajes ==
              dato.docs[a].get("idMensaje")) {
            if (  dato.docs[a].get("Tipo Mensaje") == "Texto" ||
                 dato.docs[a].get("Tipo Mensaje") == "Imagen") {
              nuevo = new Mensajes(
                nombreEmisor:  dato.docs[a].get("Nombre Emisor"),
                tipoMensaje:   dato.docs[a].get("Tipo Mensaje"),
                idMensaje:  dato.docs[a].get("idMensaje"),
                idEmisor:  dato.docs[a].get("idEmisor"),
                horaMensaje: ( dato.docs[a].get("Hora Mensaje")).toDate(),
                mensaje:  dato.docs[a].get("Mensaje"),
              );
            }
            if ( dato.docs[a].get("Tipo Mensaje") == "Audio") {
              nuevo = new Mensajes.Audio(
                duracionMensaje:  dato.docs[a].get("duracionMensaje"),
                nombreEmisor:  dato.docs[a].get("Nombre Emisor"),
                tipoMensaje:  dato.docs[a].get("Tipo Mensaje"),
                idMensaje:  dato.docs[a].get("idMensaje"),
                idEmisor:  dato.docs[a].get("idEmisor"),
                horaMensaje: ( dato.docs[a].get("Hora Mensaje")).toDate(),
                mensaje:  dato.docs[a].get("Mensaje"),
              );
            }

            conversaciones
                    .listaDeConversaciones[i].ventanaChat.listadeMensajes =
                List.from(conversaciones
                    .listaDeConversaciones[i].ventanaChat.listadeMensajes)
                  ..add(nuevo);

            notifyListeners();
          }
        }
      }
    });
  }

  void escucharEstadoConversacion() async {
    print("Escuchando estado");
    await baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion")
        .get()
        .then((dato) {
      for (int i = 0; i < dato.docs.length; i++) {
        for (int b = 0; b < listaDeConversaciones.length; b++) {
          if (dato.docs[i].get("IdConversacion") ==
              listaDeConversaciones[b].idConversacion) {
            print(listaDeConversaciones[b].idConversacion);
            if (dato.docs[i].get("Escribiendo") == true) {
              print("Escuchando estado");
              listaDeConversaciones[b].ventanaChat.estadoConversacion =
                  estadosEscribiendoConversacion[1];
              notifyListeners();
            }
            if (dato.docs[i].get("Escribiendo") == false) {
              print("No Escuchando estado");
              listaDeConversaciones[b].ventanaChat.estadoConversacion =
                  estadosEscribiendoConversacion[0];
              notifyListeners();
            }
            print(listaDeConversaciones[b].idConversacion);
            if (dato.docs[i].get("Conectado") == true) {
              print("Escuchando conexion");
              listaDeConversaciones[b].ventanaChat.estadoConexion = true;
              notifyListeners();
            }
            if (dato.docs[i].get("Conectado") == false) {
              print("No Escuchando conexion");
              listaDeConversaciones[b].ventanaChat.estadoConexion = false;
              notifyListeners();
            }
          }
        }
      }
    }).then((value) {
      baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("estados conversacion")
          .snapshots()
          .listen((dato) {
        for (int i = 0; i < dato.docs.length; i++) {
          for (int b = 0; b < listaDeConversaciones.length; b++) {
            if (dato.docs[i].get("IdConversacion") ==
                listaDeConversaciones[b].idConversacion) {
              print(listaDeConversaciones[b].idConversacion);
              if (dato.docs[i].get("Escribiendo") == true) {
                print("Escuchando estado");
                listaDeConversaciones[b].ventanaChat.estadoConversacion =
                    estadosEscribiendoConversacion[1];
                notifyListeners();
              }
              if (dato.docs[i].get("Escribiendo") == false) {
                print("No Escuchando estado");
                listaDeConversaciones[b].ventanaChat.estadoConversacion =
                    estadosEscribiendoConversacion[0];
                notifyListeners();
              }
              print(listaDeConversaciones[b].idConversacion);
              if (dato.docs[i].get("Conectado") == true) {
                print("Escuchando conexion");
                listaDeConversaciones[b].ventanaChat.estadoConexion = true;
                notifyListeners();
              }
              if (dato.docs[i].get("Conectado") == false) {
                print("No Escuchando conexion");
                listaDeConversaciones[b].ventanaChat.estadoConexion = false;
                notifyListeners();
              }
            }
          }
        }
      });
    });
  }

  void obtenerConversaciones() async {
    await baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .get()
        .then((datos) async {
      for (int a = 0; a < datos.docs.length; a++) {
        print("${datos.docs.length} total de conversaciones");
        TituloChat chatVentana = new TituloChat(
          estadoConexion: estadoConexionConversacion,
          conversacion: null,
          idConversacion: datos.docs[a].get("IdConversacion"),
          estadoConversacion: " ",
          listadeMensajes: null,
          nombre: datos.docs[a].get("nombreRemitente"),
          imagen: datos.docs[a].get("imagenRemitente"),
          idRemitente: datos.docs[a].get("IdRemitente"),
          mensajeId: datos.docs[a].get("IdMensajes"),
        );

        Conversacion nueva = new Conversacion(
            grupo: datos.docs[a].get("Grupo"),
            idConversacion: datos.docs[a].get("IdConversacion"),
            nombreRemitente: datos.docs[a].get("nombreRemitente"),
            idRemitente: datos.docs[a].get("IdRemitente"),
            idMensajes: datos.docs[a].get("IdMensajes"),
            imagenRemitente: datos.docs[a].get("imagenRemitente"),
            ventanaChat: chatVentana);
        chatVentana.conversacion = nueva;

        print("${nueva.idConversacion}este es mi compañero");
        nueva.ventanaChat.idConversacion = nueva.idConversacion;

        print(
            "${nueva.ventanaChat.idConversacion}este es miffff compañero en el chat");

        conversaciones.listaDeConversaciones =
            List.from(conversaciones.listaDeConversaciones)..add(nueva);
      }
    }).then((value) async {
      escucharEstadoConversacion();
      escucharConversaciones();
    });
  }

  void escucharConversaciones() {
    bool igual;
    baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .orderBy("Hora", descending: true)
        .snapshots()
        .listen((datos) {
      for (int a = 0; a < datos.docs.length; a++) {
        igual = false;
        for (int b = 0;
            b < Conversacion.conversaciones.listaDeConversaciones.length;
            b++) {
          if (datos.docs[a].get("IdConversacion") ==
              Conversacion
                  .conversaciones.listaDeConversaciones[b].idConversacion) {
            igual = true;
          }
        }
        if (!igual) {
          print("${datos.docs.length} total de conversaciones");
          TituloChat chatVentana = new TituloChat(
            estadoConexion: estadoConexionConversacion,
            conversacion: null,
            idConversacion: datos.docs[a].get("IdConversacion"),
            estadoConversacion: " ",
            listadeMensajes: null,
            nombre: datos.docs[a].get("nombreRemitente"),
            imagen: datos.docs[a].get("imagenRemitente"),
            idRemitente: datos.docs[a].get("IdRemitente"),
            mensajeId: datos.docs[a].get("IdMensajes"),
          );

          Conversacion nueva = new Conversacion(
              grupo: datos.docs[a].get("Grupo"),
              idConversacion: datos.docs[a].get("IdConversacion"),
              nombreRemitente: datos.docs[a].get("nombreRemitente"),
              idRemitente: datos.docs[a].get("IdRemitente"),
              idMensajes: datos.docs[a].get("IdMensajes"),
              imagenRemitente: datos.docs[a].get("imagenRemitente"),
              ventanaChat: chatVentana);
          chatVentana.conversacion = nueva;

          nueva.ventanaChat.idConversacion = nueva.idConversacion;

          conversaciones.listaDeConversaciones =
              List.from(conversaciones.listaDeConversaciones)..add(nueva);
              Conversacion.conversaciones.notifyListeners();
        }
      }
    });
  }

  Conversacion(
      {@required this.grupo,
      @required this.idConversacion,
      @required this.nombreRemitente,
      @required this.idRemitente,
      @required this.idMensajes,
      @required this.imagenRemitente,
      @required this.ventanaChat});

  Conversacion.instancia();
}

class VideoLlamada {
  static String usaurioId = Usuario.esteUsuario.idUsuario;
  static String imagenUsuaerio = obtenerImagenUsuarioLocal();
  static const String idAplicacion = "89a6508f23d34bdeb3cb998a5642c770";
  String canalUsuario;
  static FirebaseFirestore basedatos = FirebaseFirestore.instance;
  static FirebaseFirestore escuchadorEstadoLLamada = FirebaseFirestore.instance;

  Future<void> _initAgoraRtcEngine() async {
    AgoraRtcEngine.create(idAplicacion);

    AgoraRtcEngine.enableVideo();
    AgoraRtcEngine.enableAudio();

    AgoraRtcEngine.setChannelProfile(ChannelProfile.Communication);

    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.orientationMode = VideoOutputOrientationMode.FixedPortrait;
    AgoraRtcEngine.setVideoEncoderConfiguration(config);
  }
    static String obtenerImagenUsuarioLocal() {
    bool imagenAdquirida = false;
    String imagen;
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
    return imagen;
  }

  static void establecerEstadoLLamada() async {
    Map<String, dynamic> datosLLamada = new Map();
    datosLLamada["Estado"] = "Disponible";

    await basedatos
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("estadoLlamada")
        .document("estadoLlamada")
        .setData(datosLLamada)
        .then((value) {
      escucharLLamadasEntrantes();
    });
  }

  static void ponerStatusOcupado() async {
    Map<String, dynamic> datosLLamada = new Map();
    datosLLamada["Estado"] = "Ocpuado";
    await basedatos
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("estadoLlamada")
        .document("estadoLlamada")
        .setData(datosLLamada);
  }

  static void ponerStatusDisponible() async {
    Map<String, dynamic> datosLLamada = new Map();
    datosLLamada["Estado"] = "Disponible";
    await basedatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estadoLlamada")
        .doc("estadoLlamada")
        .set(datosLLamada);
  }

  static void iniciarComunicacionLlamada(
      String usuario, BuildContext context) async {
    String resultado;

    await basedatos
        .collection("usuarios")
        .doc(usuario)
        .collection("estadoLlamada")
        .doc("estadoLlamada")
        .get()
        .then((value) {
      if (value.get("Estado") == "Disponible") {
        resultado = "Disponible";
      }
      if (value.get("Estado") == "Desconectado") {
        resultado = "Desconectado";
      }
      if (value.get("Estado") == "Ocupado") {
        resultado = "Ocupado";
      }
    });

    if (resultado == "Disponible") {
      iniciarLLamadaVideo(usuario, context);
    } else {
      print("No se piuede llamar al usuario");
    }
  }

  static void colgarLLamadaVideo(
      String usuario, Map<String, dynamic> datosLLamada) async {
    print(datosLLamada["StatusLLamada"]);

    datosLLamada.update("StatusLLamada", (value) => "Rechazada",
        ifAbsent: () => "Rechazada");

    datosLLamada["StatusLLamada"] = "Rechazada";

    await basedatos
        .collection("usuarios")
        .doc(usuario)
        .collection("llamadas")
        .doc(datosLLamada["id LLamada"])
        .set(datosLLamada)
        .then((value) async {
      await basedatos
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("llamadas")
          .doc(datosLLamada["id LLamada"])
          .set(datosLLamada);
    });
  }

  static void contestarLLamadaVideo(String usuarioId, BuildContext context,
      Map<String, dynamic> datosLLamada) async {
    Map<String, dynamic> estadoLLamada = new Map();
    estadoLLamada["Estado"] = "Ocpuado";
    datosLLamada["StatusLLamada"] = "Conectado";
    await basedatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estadoLlamada")
        .doc("estadoLlamada")
        .set(estadoLLamada)
        .then((value) async {
      await basedatos
          .collection("usuarios")
          .document(Usuario.esteUsuario.idUsuario)
          .collection("llamadas")
          .document(datosLLamada["id LLamada"])
          .setData(datosLLamada)
          .then((value) async {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CallPage(
                    datosLLamada: datosLLamada,
                    usuario: usuarioId,
                    channelName: usuarioId,
                    role: ClientRole.Broadcaster)));
      });
    });
  }

  static void iniciarLLamadaVideo(String usuario, BuildContext context) async {
    Map<String, dynamic> datosLLamada = new Map();
    String idLLamadaVideo = Solicitud.instancia.crearCodigo();
    datosLLamada["ImagenLlamadaEntrante"] =
        VideoLlamada.obtenerImagenUsuarioLocal();
    datosLLamada["Nombre"] = Usuario.esteUsuario.nombre;
    datosLLamada["idCanalLLamada"] = Usuario.esteUsuario.idUsuario;
    datosLLamada["StatusLLamada"] = "Conectando";
    datosLLamada["id LLamante"] = Usuario.esteUsuario.idUsuario;
    datosLLamada["DuracionLLamada"] = DateTime.now();
    datosLLamada["idRemitente"] = usuario;
    datosLLamada["id LLamada"] = idLLamadaVideo;
    datosLLamada["tipoLlamada"] = "Video";

    await basedatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("llamadas")
        .doc(idLLamadaVideo)
        .set(datosLLamada)
        .then((valor) async {
      await basedatos
          .collection("usuarios")
          .doc(usuario)
          .collection("llamadas")
          .doc(idLLamadaVideo)
          .set(datosLLamada)
          .then((value) async {
        escuchadorEstadoLLamada
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("llamadas")
            .doc(idLLamadaVideo)
            .snapshots()
            .listen((event) async {
          if (event.get("StatusLLamada") == "Rechazada") {
            await escuchadorEstadoLLamada
                .collection("usuarios")
                .doc(Usuario.esteUsuario.idUsuario)
                .collection("llamadas")
                .doc(idLLamadaVideo)
                .snapshots()
                .listen((event) {})
                .cancel()
                .then((value) {
              CallPageState.onCallEnd(context);
            });
          }
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CallPage(
                    datosLLamada: datosLLamada,
                    usuario: usuario,
                    channelName: Usuario.esteUsuario.idUsuario,
                    role: ClientRole.Broadcaster)));
      });
    });

    print("Llamada iniciada");
  }

  static void escucharLLamadasEntrantes() {
    basedatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("llamadas")
        .where("StatusLLamada", isEqualTo: "Conectando")
        .snapshots()
        .listen((event) {
      if (event.docs.length > 0) {
        for (DocumentSnapshot llamada in event.docs) {
          if (llamada.get("id LLamante") != Usuario.esteUsuario.idUsuario) {
            notificarLLamada(
                starter_app.claveNavegacion.currentContext,
                llamada.get("ImagenLLamadaEntrante"),
                llamada.get("Nombre"),
                llamada.get("id LLamada"),
                llamada.get("idCanalLLamada"),
                llamada.get("StatusLLamada"),
                llamada.get("id LLamante"),
                llamada.get("idRemitente"),
                llamada.get("tipoLlamada"));
          } else {
            print("llamadaPropia");
          }
        }
      }
    });
  }

  static void notificarLLamada(
      BuildContext context,
      String imagen,
      String nombreUsuario,
      String idLLamada,
      String canalLLamada,
      String statusLLamasda,
      String idLLamante,
      String idRemitente,
      String tipoLLamada) async {
    Map<String, dynamic> datosLLamada = new Map();
    datosLLamada["ImagenLlamadaEntrante"] = imagen;
    datosLLamada["Nombre"] = nombreUsuario;
    datosLLamada["idCanalLLamada"] = canalLLamada;
    datosLLamada["StatusLLamada"] = "Conectando";
    datosLLamada["id LLamante"] = idLLamante;
    datosLLamada["DuracionLLamada"] = DateTime.now();
    datosLLamada["idRemitente"] = idRemitente;
    datosLLamada["id LLamada"] = idLLamada;
    datosLLamada["tipoLlamada"] = "Video";
    showGeneralDialog(
        barrierDismissible: true,
        barrierLabel: "",
        transitionDuration: const Duration(milliseconds: 200),
        context: starter_app.claveNavegacion.currentContext,
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondanimation) {
          // cargarPerfil();

          return ChangeNotifierProvider.value(
            value: Usuario.esteUsuario,
            child: SafeArea(child: Consumer<Usuario>(
              builder: (context, myType, child) {
                return Container(
                  height: ScreenUtil().setHeight(1000),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Color.fromRGBO(20, 20, 20, 50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Text(
                                    "Videollamada entrante",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(60)),
                                  )),
                            ),
                            Expanded(
                                child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      image: DecorationImage(
                                          image: NetworkImage(imagen),
                                          fit: BoxFit.cover)),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Container(
                                          height: ScreenUtil().setHeight(150),
                                          width: ScreenUtil().setWidth(150),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red),
                                          child: IconButton(
                                            color: Colors.white,
                                            icon: Icon(Icons.call_end),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              colgarLLamadaVideo(
                                                  idLLamante, datosLLamada);
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Container(
                                          height: ScreenUtil().setHeight(150),
                                          width: ScreenUtil().setWidth(150),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green),
                                          child: IconButton(
                                              color: Colors.white,
                                              icon: Icon(Icons.call),
                                              onPressed: () {
                                                // Navigator.pop(context);
                                                contestarLLamadaVideo(
                                                    canalLLamada,
                                                    context,
                                                    datosLLamada);
                                              }),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )),
          );
        });
  }
}
