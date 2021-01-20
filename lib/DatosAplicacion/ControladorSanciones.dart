import 'dart:async';

import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:ntp/ntp.dart';

class SancionesUsuario with ChangeNotifier {
  static SancionesUsuario instancia= new SancionesUsuario();
  bool perfilInapropiado = false;
  bool hacePublicidad = false;
  bool menorEdad = false;
  bool otros = false;
   StreamController<int> contador;
   int segundosRestantes = 0;
   bool finSancion = false;

   Future<void> obtenerSanciones() async {
    int unidadesSancion = Usuario.esteUsuario.mapaSanciones["tiempoSancion"];
    bool sancionadoUsuario =
        Usuario.esteUsuario.mapaSanciones["usuarioSancionado"];
    List<dynamic> listaSanciones =
        Usuario.esteUsuario.mapaSanciones["sanciones"];
        Usuario.esteUsuario.usuarioBloqueado = sancionadoUsuario;

    if (sancionadoUsuario) {
      Usuario.esteUsuario.bloqueadoHasta =
          Usuario.esteUsuario.mapaSanciones["finSancion"].toDate();
      await NTP.now().then((val) async {
        if (unidadesSancion > 0) {
          Usuario.esteUsuario.bloqueadoHasta = val;
          Usuario.esteUsuario.bloqueadoHasta = Usuario
              .esteUsuario.bloqueadoHasta
              .add(Duration(days: unidadesSancion));
          DateTime tiempo = new DateTime(
              Usuario.esteUsuario.bloqueadoHasta.year,
              Usuario.esteUsuario.bloqueadoHasta.month,
              Usuario.esteUsuario.bloqueadoHasta.day);

          for (int a = 0; a < listaSanciones.length; a++) {
            Sanciones.listaSanciones.add(Sanciones(
              sancion: listaSanciones[a],
            ));
          }

          Usuario.dbRef
              .collection("usuarios")
              .doc(Usuario.esteUsuario.idUsuario)
              .update({
            "sancionado": {
              "finSancion": val,
              "tiempoSancion": 5 * unidadesSancion,
              "sanciones": listaSanciones,
              "usuarioSancionado": true
            }
          });

          Usuario.esteUsuario.usuarioBloqueado = sancionadoUsuario;
          Conversacion.conversaciones.notifyListeners();
        } else {
          int diferencia =
              ((Usuario.esteUsuario.bloqueadoHasta.millisecondsSinceEpoch ~/
                      1000)) -
                  ((val.millisecondsSinceEpoch ~/ 1000));
          segundosRestantes = diferencia;
          if(diferencia>0){
 contadorHastaRecompensa();
        for (int a = 0; a < listaSanciones.length; a++) {
            Sanciones.listaSanciones.add(Sanciones(
              sancion: listaSanciones[a],
            ));
          }
          Usuario.esteUsuario.bloqueadoHasta =
              Usuario.esteUsuario.mapaSanciones["finSancion"].toDate();
          Usuario.esteUsuario.usuarioBloqueado = sancionadoUsuario;
          Conversacion.conversaciones.notifyListeners();
          }
          else{
 Usuario.esteUsuario.usuarioBloqueado = false;
            finSancion=true;
         //   finSancionUsuario();
          }

         
   
        }
      });
    }
 
    Conversacion.conversaciones.notifyListeners();
  }

   void contadorHastaRecompensa() async {
    contador = StreamController.broadcast();
    Timer flutterTimer;

    flutterTimer = new Timer.periodic(Duration(seconds: 1), (valor)async {
      if (segundosRestantes > 0) {
        segundosRestantes -= 1;
        contador.add(segundosRestantes);
      }
      if (segundosRestantes <= 0) {
     
    finSancion=true;
   
    Conversacion.conversaciones.notifyListeners();
       flutterTimer.cancel();
        contador.close();
 
        
      }
    });
  }

  static Future<bool> finSancionUsuario() async {
    bool sancionFinalizadaConExito = false;

    await Usuario.dbRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .update({
      "sancionado": {
        "finSancion": DateTime.now(),
        "tiempoSancion": 0,
        "sanciones": [],
        "usuarioSancionado": false
      }
    }).then((valor) {
      sancionFinalizadaConExito = true;
    }).catchError((error) {
      sancionFinalizadaConExito = false;
    });

    return sancionFinalizadaConExito;
  }





}
