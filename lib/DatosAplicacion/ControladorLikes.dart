import 'dart:math';

import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'Usuario.dart';

class Solicitud {
  static Solicitud instancia = Solicitud();

  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
  HttpsCallable llamadaFuncionAceptarSolicitud = CloudFunctions.instance
      .getHttpsCallable(functionName: "aceptarLikeIniciarConversacion");
  Future<void> aceptarLike(String nombreRemitente, String imagenRemitente,
      String idRemitente, String mensajeRemitente) async {
    String idMensajes = crearCodigo();
    HttpsCallableResult respuesta = await llamadaFuncionAceptarSolicitud.call([
      <String, dynamic>{
        "nombreSolicitante": nombreRemitente,
        "imagenSolicitante": imagenRemitente,
        "idSolicitante": idRemitente,
        "nombreAceptador": Usuario.esteUsuario.nombre,
        "imagenAceptador": VideoLlamada.obtenerImagenUsuarioLocal(),
        "idAceptador": Usuario.esteUsuario.idUsuario,
        "idMensajes": idMensajes,
        "idConversacion": idMensajes,
        "hora": "DateTime.now().toString()"
      }
    ]).catchError((onError) {
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
  void aceptarSolicitud(String mensajeRemitente, String nombreRemitente,
      String imagenRemitente, String idRemitente, String idVal) async {
    String idMensaje = crearCodigo();
    String idConversacion = crearCodigo();
    Map<String, dynamic> mensajeInicial = Map();
    if (mensajeRemitente != null &&
        mensajeRemitente != " " &&
        mensajeRemitente != "null") {
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
    solicitudParaRemitente["idUsuario"] = Usuario.esteUsuario.idUsuario;
    solicitudParaRemitente["IdMensajes"] = idMensaje;
    solicitudParaRemitente["IdRemitente"] = idRemitente;
    solicitudParaRemitente["ultimoMensaje"] = {
      "mensaje": mensajeRemitente ?? " ",
      "tipoMensaje": "texto",
      "duracionMensaje": 0
    };
    solicitudParaRemitente["nombreRemitente"] = nombreRemitente;
    solicitudParaRemitente["imagenRemitente"] = imagenRemitente;
    solicitudParaRemitente["Grupo"] = false;
    Map<String, dynamic> solicitudLocal = Map();
    solicitudLocal["Hora"] = DateTime.now();
    solicitudLocal["IdConversacion"] = idConversacion;
    solicitudLocal["idUsuario"] = idRemitente;
    solicitudLocal["IdMensajes"] = idMensaje;
    solicitudLocal["IdRemitente"] = Usuario.esteUsuario.idUsuario;
    solicitudLocal["nombreRemitente"] = Usuario.esteUsuario.nombre;
    solicitudLocal["imagenRemitente"] = Usuario.esteUsuario.ImageURL1["Imagen"];
    solicitudLocal["ultimoMensaje"] = {
      "mensaje": mensajeRemitente ?? "null",
      "tipoMensaje": "texto",
      "duracionMensaje": 0
    };
    solicitudLocal["Grupo"] = false;
    WriteBatch batch = baseDatosRef.batch();
    DocumentReference valoracionEliminar = baseDatosRef
       
        
        .collection("valoraciones")
        .doc(idVal);
    DocumentReference conversacionesRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);

    DocumentReference conversacionesLocal = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(idConversacion);

    DocumentReference estadoConversacionesRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("estados conversacion")
        .doc(idConversacion);

    DocumentReference estadoConversacionesLocal = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion")
        .doc(idConversacion);

    batch.set(conversacionesRemitente, solicitudLocal);
    batch.set(conversacionesLocal, solicitudParaRemitente);
    batch.set(estadoConversacionesRemitente, estadoConexionUsuario);
    batch.set(estadoConversacionesLocal, estadoConexionUsuario);
    batch.delete(valoracionEliminar);
    await batch.commit().then((value) {
      rechazarSolicitud(
        idVal,
      );

      print("value");
    }).catchError((onError) => print(onError));
  }

  void rechazarSolicitud(
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
}
