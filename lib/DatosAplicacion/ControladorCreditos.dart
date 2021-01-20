import 'dart:async';

import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';

import 'ControladorSanciones.dart';
import 'Usuario.dart';

class ControladorCreditos {
  static ControladorCreditos instancia = new ControladorCreditos();
  static int precioSolicitud;
  static int precioValoracion;
   StreamSubscription<DocumentSnapshot> escuchadorUsuario;
  final HttpsCallable llamarDarCreditos = CloudFunctions.instance
      .getHttpsCallable(functionName: "darCreditosUsuario");
  final HttpsCallable llamarSolicitarCreditosDiarios = CloudFunctions.instance
      .getHttpsCallable(functionName: "solcitarCreditosDiarios");
  final HttpsCallable llamarRestarCreditos = CloudFunctions.instance
      .getHttpsCallable(functionName: "quitarCreditosUsuario");
  final HttpsCallable llamarRestarCreditosSolicitud = CloudFunctions.instance
      .getHttpsCallable(functionName: "quitarCreditosUsuarioSolicitudes");
  void sumar(int creditos) async {
    await llamarDarCreditos.call(<String, dynamic>{
      "creditos": 500,
      "idUsuario": Usuario.esteUsuario.idUsuario
    });

    // print(respuesta.data);

    Solicitudes.instancia.notifyListeners();
  }

  Future<void> restarCreditosValoracion(
      int creditos, String idValoracion) async {
    DateTime fechaActual = await NTP.now();
    int fechaEnSegundos = (fechaActual.millisecondsSinceEpoch ~/ 1000);
    if (Usuario.esteUsuario.creditosUsuario >= creditos) {
      HttpsCallableResult resultado =
          await llamarRestarCreditos.call(<String, dynamic>{
        "idUsuario": Usuario.esteUsuario.idUsuario,
        "idValoracion": idValoracion,
        "primeraSolicitud": false,
        "fechaActual": fechaEnSegundos,
      }).catchError((onError) => print("Error actual::: $onError"));
    }

    Solicitudes.instancia.notifyListeners();
  }

  Future<void> restarCreditosSolicitud(int creditos, String idSolicitud) async {
    if (Usuario.esteUsuario.creditosUsuario >= creditos) {
      HttpsCallableResult resultado =
          await llamarRestarCreditosSolicitud.call(<String, dynamic>{
        "primeraSolicitud": false,
        "idUsuario": Usuario.esteUsuario.idUsuario,
        "idSolicitud": idSolicitud,
      });
      print("${resultado.data} resultado funcion");
    }
  }

  void obtenerPrecioSolicitud() async {
    HttpsCallableResult resultado =
        await llamarRestarCreditosSolicitud.call(<String, dynamic>{
      "primeraSolicitud": true,
      "idUsuario": Usuario.esteUsuario.idUsuario,
      "idSolicitud": "0000000",
    }).catchError((onError) => print("Error con creditos:: $onError"));

    precioSolicitud = resultado.data;
  }

  void obtenerPrecioValoracion() async {
    DateTime fechaActual = await NTP.now();
    int fechaEnSegundos = (fechaActual.millisecondsSinceEpoch ~/ 1000);

    HttpsCallableResult resultado =
        await llamarRestarCreditos.call(<String, dynamic>{
      "primeraSolicitud": true,
      "idUsuario": Usuario.esteUsuario.idUsuario,
      "idValoracion": "0000000",
      "fechaActual": fechaEnSegundos,
    });

    precioValoracion = resultado.data;
  }

  void recompensaDiaria() async {
    await llamarSolicitarCreditosDiarios.call(<String, dynamic>{
      "idUsuario": Usuario.esteUsuario.idUsuario,
    }).then((value) => print(value.data));
  }

  void escucharCreditos() {
    FirebaseFirestore referenciaCreditos = FirebaseFirestore.instance;
    escuchadorUsuario = referenciaCreditos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .snapshots()
        .listen((event) async {
      if (event != null) {
        int creditosEnNube = (event.data()["creditos"]);
        Usuario.esteUsuario.creditosUsuario = creditosEnNube;
        Usuario.esteUsuario.verificado =
            event.data()["verificado"]["estadoVerificacion"];
              bool notificado=
            event.data()["verificado"]["verificacionNotificada"];
            if(Usuario.esteUsuario.verificado=="Verificado"&&notificado==false){
              ControladorNotificacion.instancia.mostrarNotificacionVerificacion();
            }

        Usuario.esteUsuario.mapaSanciones = event.data()["sancionado"];
      

        if (Usuario.esteUsuario.usuarioBloqueado !=
            event.data()["sancionado"]["usuarioSancionado"]) {
          await SancionesUsuario.instancia.obtenerSanciones().then((valor) {
            if (Usuario.esteUsuario.usuarioBloqueado == true) {
              SancionesUsuario.instancia.finSancion = false;
              ControladorInicioSesion.instancia.cerrarSesion().then((val) {
                if (val) {
                  Navigator.pop(BaseAplicacion.claveBase.currentContext);
                }
              });
            }
          });
        }

        if (Usuario.esteUsuario.tiempoEstimadoRecompensa !=
            event.data()["siguienteRecompensa"]) {
          Usuario.esteUsuario.tiempoEstimadoRecompensa =
              event.data()["siguienteRecompensa"];
          Usuario.esteUsuario.contadorHastaRecompensa();
        }

        // ignore: invalid_use_of_protected_member
        Solicitudes.instancia.notifyListeners();
      }
    });
  }


   void cerrarEscuchadorUsuario(){
     if(escuchadorUsuario!=null){
escuchadorUsuario.cancel();
     }
    
    escuchadorUsuario=null;
  }
}
