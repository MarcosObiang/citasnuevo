import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/pantalla_Actividades_elements.dart';
import 'package:citasnuevo/InterfazUsuario/Descubrir/descubir.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as nube;

import 'package:firebase_storage/firebase_storage.dart' as almacenamiento;
import 'package:flutter/foundation.dart';

/*class SolicitudesChatDirecto {
  String idEmisor;
  String aliasEmisor;
  String imagenEmisor;
  String mensaje;
  String nombreEmisor;
  DateTime horaSolicitud;
  String idSolicitud;
  static List<SolicitudChat> solicitudesChat = new List();
  SolicitudesChatDirecto({
    @required this.idEmisor,
    @required this.aliasEmisor,
    @required this.imagenEmisor,
    @required this.horaSolicitud,
    @required this.idSolicitud,
    @required this.mensaje,
    @required this.nombreEmisor,
  });

  static void obtenerSolicitudesChatDirecto() {
    nube.Firestore baseDatos = nube.Firestore.instance;

    baseDatos
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("solicitudes chat directos")
        .getDocuments()
        .then((value) {
      if (value != null) {
        for (int i = 0; i < value.documents.length; i++) {
          SolicitudChat widgetSolicitud;
          SolicitudesChatDirecto solicitud = new SolicitudesChatDirecto(
              idEmisor: value.documents[i].data["Id emisor"],
              aliasEmisor: value.documents[i].data["Alias Emisor"],
              imagenEmisor: value.documents[i].data["Imagen Usuario"],
              horaSolicitud: value.documents[i].data["Time"].toDate(),
              idSolicitud: value.documents[i].data["id SolicituChatDirecto"],
              mensaje: value.documents[i].data["Mensaje"],
              nombreEmisor: value.documents[i].data["Nombre emisor"]);
          widgetSolicitud = new SolicitudChat(solicitud: solicitud);
          solicitudesChat.add(widgetSolicitud);
        }
        print("Solicitudes ${solicitudesChat.length}");
      }
    }).catchError((e) => print(e));
  }

  static String crearCodigo() {
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

  static void aceptarSolicitud(
    String mensajeRemitente,
    String nombreRemitente,
    String imagenRemitente,
    String idRemitente,
  ) async {
    String idMensaje = crearCodigo();
    String idConversacion = crearCodigo();
    Map<String, dynamic> mensajeInicial = Map();
    nube.Firestore baseDatosRef = nube.Firestore.instance;
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

    Map<String, dynamic> solicitudParaRemitente = Map();
    solicitudParaRemitente["Hora"] = DateTime.now();
    solicitudParaRemitente["IdConversacion"] = idConversacion;
    solicitudParaRemitente["IdMensajes"] = idMensaje;
    solicitudParaRemitente["IdRemitente"] = idRemitente;
    solicitudParaRemitente["Nombre Remitente"] = nombreRemitente;
    solicitudParaRemitente["Imagen Remitente"] = imagenRemitente;
    Map<String, dynamic> solicitudLocal = Map();
    solicitudLocal["Hora"] = DateTime.now();
    solicitudLocal["IdConversacion"] = idConversacion;
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
    // rechazarSolicitud(idVal, indice);
  }
}*/

/*class Chat {
  static final String idEsteUsuario = Usuario.esteUsuario.idUsuario;

  String idPerfil;
  String nombrePerfil;
  String bioPerfil;
  String imagenPerfil;
  bool tieneHistorias;

  List<String> linksHistorias = new List();
  static List<PerfilChat> listaDeChats = new List();
  static nube.DocumentSnapshot documentoInicial;
  static nube.DocumentSnapshot documentoFinal;
  static bool perfilesObtenidos = false;
  static Map<String, dynamic> datosValoracion = new Map();
  Chat(
      {@required this.idPerfil,
      @required this.nombrePerfil,
      @required this.bioPerfil,
      @required this.imagenPerfil,
      @required this.linksHistorias,
      @required this.tieneHistorias});

  /// [obtenerChatsDirecto] con este metodo obtendremos los chats la primera vez y el resto de vezes mediante el bool [perfilesObtenidos],
  /// si es [true] entonces hara una peticion desde el ultimo documento, si es [false] hace una peticion desde el inicio

  static void obtenerChatsDirecto() {
    nube.Firestore baseDatos = nube.Firestore.instance;
    Chat directo;
    PerfilChat chat;
    if (!perfilesObtenidos) {
      baseDatos
          .collection("directo conversaciones")
          .getDocuments()
          .then((value) {
        if (value != null) {
          documentoInicial = value.documents.first;
          documentoFinal = value.documents.last;
          perfilesObtenidos = true;

          for (int i = 0; i < value.documents.length; i++) {
            directo = new Chat(
                idPerfil: value.documents[i].data["idPerfil"],
                nombrePerfil: value.documents[i].data["Nombre"],
                bioPerfil: value.documents[i].data["BioPerfil"],
                imagenPerfil: value.documents[i].data["Imagen"],
                linksHistorias: null,
                tieneHistorias: null);
            chat = new PerfilChat(chat: directo);
            listaDeChats.add(chat);
          }
        }
      });
    } else {
      baseDatos
          .collection("directo conversaciones")
          .where("Conectado", isEqualTo: true)
          .startAtDocument(documentoFinal)
          .limit(10)
          .getDocuments()
          .then((value) {
        if (value != null) {
          documentoFinal = value.documents.last;

          for (int i = 0; i < value.documents.length; i++) {
            directo = new Chat(
                idPerfil: value.documents[i].data["idPerfil"],
                nombrePerfil: value.documents[i].data["Nombre"],
                bioPerfil: value.documents[i].data["BioPerfil"],
                imagenPerfil: value.documents[i].data["Imagen"],
                linksHistorias: null,
                tieneHistorias: null);
            chat = new PerfilChat(chat: directo);
            listaDeChats.add(chat);
          }
        }
      });
    }
  }

  static String crearCodigo() {
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

  void aceptarSolicitud(
      String mensajeRemitente,
      String nombreRemitente,
      String imagenRemitente,
      String idRemitente,
      int indice,
      String idVal) async {
    nube.Firestore baseDatosref = nube.Firestore.instance;
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
      baseDatosref
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

    Map<String, dynamic> solicitudParaRemitente = Map();
    solicitudParaRemitente["Hora"] = DateTime.now();
    solicitudParaRemitente["IdConversacion"] = idConversacion;
    solicitudParaRemitente["IdMensajes"] = idMensaje;
    solicitudParaRemitente["IdRemitente"] = idRemitente;
    solicitudParaRemitente["Nombre Remitente"] = nombreRemitente;
    solicitudParaRemitente["Imagen Remitente"] = imagenRemitente;
    solicitudParaRemitente["Grupo"]=false;
    
    Map<String, dynamic> solicitudLocal = Map();
    solicitudLocal["Hora"] = DateTime.now();
    solicitudLocal["idConversacion"] = idConversacion;
    solicitudLocal["IdMensajes"] = idMensaje;
    solicitudLocal["IdRemitente"] = Usuario.esteUsuario.idUsuario;
    solicitudLocal["Nombre Remitente"] = Usuario.esteUsuario.nombre;
    solicitudLocal["Imagen Remitente"] =
        Usuario.esteUsuario.ImageURL1["Imagen"];
        solicitudLocal["Grupo"]=false;
    await baseDatosref
        .collection("usuarios")
        .document(idRemitente)
        .collection("conversaciones")
        .document(idConversacion)
        .setData(solicitudLocal);
    await baseDatosref
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .document(idConversacion)
        .setData(solicitudParaRemitente);
    await baseDatosref
        .collection("usuarios")
        .document(idRemitente)
        .collection("estados conversacion")
        .document(idConversacion)
        .setData(estadoConexionUsuario);
    await baseDatosref
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion")
        .document(idConversacion)
        .setData(estadoConexionUsuario);
    //rechazarSolicitud(idVal, indice);
  }

  ///[crearSolicitudChatDirecto] metodo estatico al que le pasamos el mensaje y el [idPerfil] para que sepa donde debe mandar nuestra solicitud
  static void crearSolicitudChatDirecto(String mensaje, String idPerfil) {
    bool imagenAdquirida = false;

    nube.Firestore baseDatosref = nube.Firestore.instance;
    datosValoracion["Imagen Usuario"] =
        StatusDirectos.obtenerImagenUsuarioLocal();
    datosValoracion["Nombre emisor"] = Usuario.esteUsuario.nombre;
    datosValoracion["Alias Emisor"] = Usuario.esteUsuario.alias;
    datosValoracion["Id emisor"] = Usuario.esteUsuario.idUsuario;
    datosValoracion["Valoracion"] = 0;
    datosValoracion["Mensaje"] = mensaje;
    datosValoracion["Time"] = DateTime.now();
    datosValoracion["id SolicitudChatDirecto"] = crearCodigo();
    _enviarValoracion(idPerfil);
  }

  static void _enviarValoracion(String idPerfil) {
    nube.Firestore baseDatosref = nube.Firestore.instance;
    baseDatosref
        .collection("usuarios")
        .document(idPerfil)
        .collection("solicitudes chat directos")
        .document()
        .setData(datosValoracion);
  }
}*/

/*class StatusDirectos {
  static String nombre = Usuario.esteUsuario.idUsuario;
  static String imagen;
  static String bio;
  static String idPerfil = Usuario.esteUsuario.idUsuario;
  static int edad = Usuario.esteUsuario.edad;
  static bool estado = false;

  ///[statusChatDirecto] esta funcion recibe [bool status] y segun sea  [true] o [false] modificara el status del usuario para que sea borrado si ya no esta en directo el usuario
  ///para que este desaparezca de la lista

  static void statusChatDirecto(bool status) {
    estado = status;
    nube.Firestore baseDatos = nube.Firestore.instance;
    Map<String, dynamic> statusChatDirecto = new Map();
    statusChatDirecto["idPerfil"] = Usuario.esteUsuario.idUsuario;
    statusChatDirecto["Nombre"] = Usuario.esteUsuario.nombre;
    statusChatDirecto["BioPerfil"] = bio;
    statusChatDirecto["Imagen"] = obtenerImagenUsuarioLocal();
    statusChatDirecto["Conectado"] = estado;
    statusChatDirecto["Hora"] = DateTime.now();
    statusChatDirecto["Sexo"] = Usuario.esteUsuario.sexo;

    baseDatos
        .collection("directo conversaciones")
        .document(idPerfil)
        .setData(statusChatDirecto)
        .catchError((e) => print(e));
  }

  ///[obtenerImagenesUsuarioLocal] con esta funcion vamos pasando por todas las imagenes del usuario y si encontramos una se elige y se usa como foto del chat online
  ///
  ///

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
}*/

class HistoriasDirecto {
  static List<HistoriaUsuarioDirecto> ventanasHistoriasDirecto = new List();
  static List<HistoriasPerfilesDirecto> pantallaHistoriaDirecto = new List();
  static String buscarPrimeraFoto(nube.DocumentSnapshot element) {
    bool imagenAdquirida;
    String imagen;
    imagenAdquirida = false;
    if (element.get("Historia 1")["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = element.get("Historia 1")["Imagen"] ;
      imagenAdquirida = true;
    }
    if (element.get("Historia 2")["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = element.get("Historia 2")["Imagen"] ;
      imagenAdquirida = true;
    }
    if (element.get("Historia 3")["Imagen"]  != null &&
        imagenAdquirida == false) {
      imagen =element.get("Historia 3")["Imagen"] ;
      imagenAdquirida = true;
    }
    if (element.get("Historia 4")["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = element.get("Historia 4")["Imagen"] ;
      imagenAdquirida = true;
    }
    if (element.get("Historia 5")["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = element.get("Historia 5")["Imagen"] ;
      imagenAdquirida = true;
    }
    if (element.get("Historia 6")["Imagen"]  != null &&
        imagenAdquirida == false) {
      imagen = element.get("Historia 6")["Imagen"] ;
      imagenAdquirida = true;
    }
    return imagen;
  }

  // ignore: missing_return
  static Future<int> buscarPantallaHistorias(String idHistoria) async {
    print(idHistoria);
    int indice = -1;
    for (int i = 0; i < pantallaHistoriaDirecto.length; i++) {
      if (idHistoria == pantallaHistoriaDirecto[i].idHistoria) {
        indice = i;
        return indice;
      }
    }
  }

  static void cargarHistoriasDirecto() async {
    nube.FirebaseFirestore baseDatosref = nube.FirebaseFirestore.instance;

    bool tieneHistorias = false;
    await baseDatosref
        .collection("directo historias")
        .get()
        .then((value) {
      print(value.docs[0].data);
      for (nube.DocumentSnapshot element in value.docs) {
        if (element != null) {
          List<Map<String, dynamic>> listaDeHistoriasRed = new List();
          HistoriaUsuarioDirecto historiaDirecto = new HistoriaUsuarioDirecto(
              idHistoria: element.get("id usuario"),
              imagenPerfilUsuario:element.get("Imagen Perfil"),
              imagenPrimeraHistoria: buscarPrimeraFoto(element),
              nombreUsuario: element.get("Nombre usuario"));
         
          ventanasHistoriasDirecto.add(historiaDirecto);

          if (element.get("Historia 1") != null) {
            if (element.get("Historia 1")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete1 = new Map();

              historiasPaquete1 = element.get("Historia 1");
              listaDeHistoriasRed.add(historiasPaquete1);
              tieneHistorias = true;
            }
          }
              if (element.get("Historia 2") != null) {
            if (element.get("Historia 2")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete1 = new Map();

              historiasPaquete1 = element.get("Historia 2");
              listaDeHistoriasRed.add(historiasPaquete1);
              tieneHistorias = true;
            }
          }
          if (element.get("Historia 3") != null) {
            if (element.get("Historia 3")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete1 = new Map();

              historiasPaquete1 = element.get("Historia 3");
              listaDeHistoriasRed.add(historiasPaquete1);
              tieneHistorias = true;
            }
          }
                 if (element.get("Historia 4") != null) {
            if (element.get("Historia 4")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete1 = new Map();

              historiasPaquete1 = element.get("Historia 4");
              listaDeHistoriasRed.add(historiasPaquete1);
              tieneHistorias = true;
            }
          }
                 if (element.get("Historia 5") != null) {
            if (element.get("Historia 5")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete1 = new Map();

              historiasPaquete1 = element.get("Historia 5");
              listaDeHistoriasRed.add(historiasPaquete1);
              tieneHistorias = true;
            }
          }
                 if (element.get("Historia 6") != null) {
            if (element.get("Historia 6")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete1 = new Map();

              historiasPaquete1 = element.get("Historia 6");
              listaDeHistoriasRed.add(historiasPaquete1);
              tieneHistorias = true;
            }
          }

          HistoriasPerfilesDirecto pantallaHistoria =
              new HistoriasPerfilesDirecto(
                  idHistoria:  element.get("id usuario"),
                  linksHistorias: listaDeHistoriasRed);
          pantallaHistoriaDirecto.add(pantallaHistoria);
        }
      }
    });
  }
}

/*class GruposDirecto extends ChangeNotifier {
  static String nombreGrupo;
  static GruposDirecto notificador = GruposDirecto();
  static String _nombreCreadorGrupo = Usuario.esteUsuario.nombre;
  static String idCreadorGrupo = Usuario.esteUsuario.idUsuario;
  static String imagenCreadorGrupo = StatusDirectos.obtenerImagenUsuarioLocal();
  static String imagenGrupo;
  static String temaGrupo;
  int _participantesGrupo = 15;
  static bool grupoAbierto = true;
  static List<Map<String,dynamic>> participantesGrupo = new List();
  static File archivoImagenGrupo;
  static String idGrupo;
  static List<PerfilGrupo> listaDeGrupos = new List();
  static Map<String, dynamic> datosValoracion = new Map();
  static List<SolicitudChatGrupo> listaDeSolicitdesGrupos = new List();

  Map<String, dynamic> documentoGrupo = new Map();

  static void crearIdGrupo() {
    idGrupo = Chat.crearCodigo();
  }

  static void subirImagenGrupo() async {
    almacenamiento.FirebaseStorage storage =
        almacenamiento.FirebaseStorage.instance;
    almacenamiento.StorageReference reference = storage.ref();
    crearIdGrupo();
    if (GruposDirecto.archivoImagenGrupo != null) {
      String image1 =
          "${Usuario.esteUsuario.idUsuario}/Perfil/Imagenes Grupos/${idGrupo}.jpg";
      almacenamiento.StorageReference referenciaImagenes =
          reference.child(image1);
      almacenamiento.StorageUploadTask uploadTask =
          referenciaImagenes.putFile(GruposDirecto.archivoImagenGrupo);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      GruposDirecto.imagenGrupo = URL;
      print(URL);
      publicarChatGrupo(crearDocumentoGrupo());
    }
  }

  static void borrarDatosCacheGrupo() {
    nombreGrupo = null;
    imagenGrupo = null;
    archivoImagenGrupo = null;
    idGrupo = null;
    temaGrupo = null;
    participantesGrupo.clear();
  }

  static Map<String, dynamic> crearDocumentoGrupo() {
    Map <String,dynamic>primerParticipante=new Map();
    
    primerParticipante["Nombre"]=Usuario.esteUsuario.nombre;
    primerParticipante["Edad"]=Usuario.esteUsuario.edad;
    primerParticipante["Imagen"]=StatusDirectos.obtenerImagenUsuarioLocal();
    primerParticipante["Id Usuario"]=Usuario.esteUsuario.idUsuario;
    primerParticipante["Admin"]=true;
    participantesGrupo.add(primerParticipante);
    Map<String, dynamic> documnetoGrupoProvisional = new Map();
    documnetoGrupoProvisional["Id grupo"] = idGrupo;
    documnetoGrupoProvisional["Id Creador"] = idCreadorGrupo;
    documnetoGrupoProvisional["Nombre"] = nombreGrupo;
    documnetoGrupoProvisional["Nombre creador"] = _nombreCreadorGrupo;
    documnetoGrupoProvisional["Imagen grupo"] = imagenGrupo;
    documnetoGrupoProvisional["Tema grupo"] = temaGrupo;
    documnetoGrupoProvisional["Imagen creador grupo"] = imagenCreadorGrupo;
    documnetoGrupoProvisional["Fecha creacion"] = DateTime.now();
    documnetoGrupoProvisional["Participantes"] = participantesGrupo;
    documnetoGrupoProvisional["Abierto"] = grupoAbierto;

    return documnetoGrupoProvisional;
  }

  static void enviarSolicitudGrupo(String idCreadorGrupo, String idGrupo,
      String nombreGrupo, String imagenGrupo) async {
    Map<String, dynamic> solicitudUnionGrupo = Map();
    solicitudUnionGrupo["IdSolicitante"] = Usuario.esteUsuario.idUsuario;
    solicitudUnionGrupo["Imagen solicitante"] =
        StatusDirectos.obtenerImagenUsuarioLocal();
    solicitudUnionGrupo["IdGrupo"] = idGrupo;
    solicitudUnionGrupo["NombreGrupo"] = nombreGrupo;
    solicitudUnionGrupo["Nombre"] = Usuario.esteUsuario.nombre;
    solicitudUnionGrupo["Id solicitud"] = Chat.crearCodigo();
    solicitudUnionGrupo["imagenGrupo"] = imagenGrupo;
    solicitudUnionGrupo["edad"]=Usuario.esteUsuario.edad;

    nube.Firestore baseDatos = nube.Firestore.instance;
    await baseDatos
        .collection("usuarios")
        .document(idCreadorGrupo)
        .collection("solicitud grupo")
        .document()
        .setData(solicitudUnionGrupo);
  }

  static void escucharSolicitudesGrupo() {
    nube.Firestore baseDatos = nube.Firestore.instance;
    bool igual;

    baseDatos
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("solicitud grupo")
        .snapshots()
        .listen((event) {
      if (event != null) {
        for (nube.DocumentSnapshot elemento in event.documents) {
          if (listaDeSolicitdesGrupos.length == 0) {
            SolicitudChatGrupo solicitudGrupo;
            print("GrupoSolicitudCreadoUnico");
            solicitudGrupo = new SolicitudChatGrupo(
              idGrupo: elemento.data["IdGrupo"],
              idSolicitante: elemento.data["IdSolicitante"],
              imagenSolicitante: elemento.data["Imagen solicitante"],
              nombreSolicitante: elemento.data["Nombre"],
              nombreGrupo: elemento.data["NombreGrupo"],
              idSolicitud: elemento.data["Id solicitud"],
              imagenGrupo: elemento.data["imagenGrupo"],
              edadSolicitante: elemento.data["Edad"],
            );

            listaDeSolicitdesGrupos = List.from(listaDeSolicitdesGrupos)
              ..add(solicitudGrupo);
          }
          if (listaDeSolicitdesGrupos.length > 0) {
            igual = false;
            for (SolicitudChatGrupo solicitud in listaDeSolicitdesGrupos) {
              if (elemento.data["Id solicitud"] == solicitud.idSolicitud) {
                igual = true;
              }
            }
            if (igual == false) {
              SolicitudChatGrupo solicitudGrupo;
              print("GrupoSolicitudCreado");
              solicitudGrupo = new SolicitudChatGrupo(
                imagenGrupo: elemento.data["imagenGrupo"],
                idGrupo: elemento.data["IdGrupo"],
                nombreGrupo: elemento.data["NombreGrupo"],
                idSolicitante: elemento.data["IdSolicitante"],
                imagenSolicitante: elemento.data["Imagen solicitante"],
                nombreSolicitante: elemento.data["Nombre"],
                idSolicitud: elemento.data["Id solicitud"],
                edadSolicitante: elemento.data["Edad"],
              );

              listaDeSolicitdesGrupos = List.from(listaDeSolicitdesGrupos)
                ..add(solicitudGrupo);
            }
          }
        }
      }
    });
  }

  static void publicarChatGrupo(Map<String, dynamic> grupo) async {
    nube.Firestore baseDatos = nube.Firestore.instance;
    await baseDatos
        .collection("grupos directo")
        .document(idGrupo)
        .setData(grupo).then((value) async{
      Map<String, dynamic> solicitudLocal = Map();
      solicitudLocal["Hora"] = DateTime.now();
      solicitudLocal["IdConversacion"] = idGrupo;
      solicitudLocal["IdMensajes"] = idGrupo;
      solicitudLocal["IdRemitente"] = idGrupo;
      solicitudLocal["Nombre Remitente"] = nombreGrupo;
      solicitudLocal["Imagen Remitente"] = imagenGrupo;
      solicitudLocal["Grupo"]=true;
      await baseDatos
          .collection("usuarios")
          .document(Usuario.esteUsuario.idUsuario)
          .collection("conversaciones")
          .document(idGrupo)
          .setData(solicitudLocal)
          .catchError((error) => print(error));
    })
        .then((value) => borrarDatosCacheGrupo());
  }

  static void obtenerGrupos() async {
    nube.Firestore baseDatos = nube.Firestore.instance;
    baseDatos.collection("grupos directo").getDocuments().then((value) {
      if (value != null) {
        for (nube.DocumentSnapshot elemento in value.documents) {
          PerfilGrupo grupo;
          grupo = new PerfilGrupo(
            imagenGrupo: elemento.data["Imagen grupo"],
            nombreGrupo: elemento.data["Nombre"],
            temaGrupo: elemento.data["Tema grupo"],
            plazasdisponibles: elemento.data["Participantes"] as List,
            idCreador: elemento.data["Id Creador"],
            idGrupo: elemento.data["Id grupo"],
          );
          print(elemento.data["Nombre"]);
          listaDeGrupos.add(grupo);
        }
      }
    }).then((value) => escucharGruposDirecto());
  }

  static void escucharGruposDirecto() async {
    bool igual;
    nube.Firestore baseDatos = nube.Firestore.instance;
    baseDatos.collection("grupos directo").snapshots().listen((value) {
      if (value != null) {
        for (nube.DocumentSnapshot elemento in value.documents) {
          igual = false;
          for (PerfilGrupo perfil in listaDeGrupos) {
            if (elemento.data["Id grupo"] == perfil.idGrupo) {
              igual = true;
            }
          }
          if (!igual) {
            PerfilGrupo grupo;
            grupo = new PerfilGrupo(
              imagenGrupo: elemento.data["Imagen grupo"],
              nombreGrupo: elemento.data["Nombre"],
              temaGrupo: elemento.data["Tema grupo"],
              plazasdisponibles: elemento.data["Participantes"] as List,
              idCreador: elemento.data["Id Creador"],
              idGrupo: elemento.data["Id grupo"],
            );
            print("otro grupo escuchadooooo");
            listaDeGrupos = List.from(listaDeGrupos)..add(grupo);
            Usuario.esteUsuario.notifyListeners();
          }
        }
      }
    });
  }

  static void aceptarSolicitudGrupo(String idGrupo, String idUsuario,
      String nombreUsuario, String imagenGrupo, String nombreGrupo,String imagenUsuario,int edad) async {
    nube.Firestore baseDatos = nube.Firestore.instance;
   
    Map<String, dynamic> solicitudLocal = Map();
    solicitudLocal["Hora"] = DateTime.now();
    solicitudLocal["IdConversacion"] = idGrupo;
    solicitudLocal["IdMensajes"] = idGrupo;
    solicitudLocal["IdRemitente"] = idGrupo;
    solicitudLocal["Nombre Remitente"] = nombreGrupo;
    solicitudLocal["Imagen Remitente"] = imagenGrupo;
    solicitudLocal["Grupo"]=true;
    await baseDatos
        .collection("usuarios")
        .document(idUsuario)
        .collection("conversaciones")
        .document(idGrupo)
        .setData(solicitudLocal).then((value) async {

          baseDatos.collection("grupos directo").document(idGrupo).get().then((value) async{
List <dynamic> listaParticipantesAhora=new List();
Map <String,dynamic>datosGrupo=new Map();
Map <String,dynamic>primerParticipante=new Map();
    datosGrupo=value.data;
    primerParticipante["Nombre"]=nombreUsuario;
    primerParticipante["Edad"]=edad;
    primerParticipante["Imagen"]=imagenUsuario;
    primerParticipante["Id Usuario"]=idUsuario;
    primerParticipante["Admin"]=false;

listaParticipantesAhora=datosGrupo["Participantes"];
listaParticipantesAhora.add(primerParticipante);
datosGrupo["Participantes"]=listaParticipantesAhora;
await baseDatos.collection("grupos directo").document(idGrupo).updateData(datosGrupo);

          });
        })
        .catchError((error) => print(error));
   
  }
}*/

/*class VideosEnDirecto{
static String usaurioId=Usuario.esteUsuario.idUsuario;
static String imagenUsuaerio=StatusDirectos.obtenerImagenUsuarioLocal();
static const String idAplicacion="89a6508f23d34bdeb3cb998a5642c770";
String canalUsuario;


  Future<void> _initAgoraRtcEngine() async {
    AgoraRtcEngine.create(idAplicacion);

    AgoraRtcEngine.enableVideo();
    AgoraRtcEngine.enableAudio();
    // AgoraRtcEngine.setParameters('{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}');
    AgoraRtcEngine.setChannelProfile(ChannelProfile.Communication);

    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.orientationMode = VideoOutputOrientationMode.FixedPortrait;
    AgoraRtcEngine.setVideoEncoderConfiguration(config);
  }

  


  
}*/