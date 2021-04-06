import 'dart:async';

import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:citasnuevo/main.dart';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_database/firebase_database.dart';

enum EstadoConexion { noConectado, conectado, conectando,noDefinido }

class EstadoConexionInternet {
  static EstadoConexionInternet estadoConexion = new EstadoConexionInternet();
  EstadoConexion conexion = EstadoConexion.noDefinido;

  FirebaseDatabase baseDatosConexion = FirebaseDatabase(
      app: app, databaseURL: "https://citas-46a84.firebaseio.com/");
  FirebaseDatabase referenciaStatus = FirebaseDatabase(
      app: app, databaseURL: "https://citas-46a84.firebaseio.com/");
  




  /// En esta funcion comrpobamos si hay acceso a internet, si hay acceso a la primera solo se llamará una vez, al haber conexión se inicia un
  /// notificador que estaria alerta de cualquier cambio de conexion que perciba la aplicacion

  Future<void> confirmarEstadoConexion() async {

    bool estaConectado = await DataConnectionChecker().hasConnection;
    if (estaConectado) {
      
      baseDatosConexion
          .reference()
          .child(".info/connected")
          .onValue
          .listen((event) async {
        Map<String, dynamic> ultimaConexion = new Map();
        ultimaConexion["Status"] = "Conectado";
        ultimaConexion["Hora"] = DateTime.now().toString();
        ultimaConexion["idUsuario"] = Usuario.esteUsuario.idUsuario;
        Map<String, dynamic> ultimaDesconexion = new Map();
        ultimaDesconexion["Status"] = "Desconectado";
        ultimaDesconexion["Hora"] = DateTime.now().toString();
        ultimaDesconexion["idUsuario"] = Usuario.esteUsuario.idUsuario;

        referenciaStatus
            .reference()
            .child("/status/${Usuario.esteUsuario.idUsuario}")
            .set(ultimaConexion);

        referenciaStatus
            .reference()
            .child("/status/${Usuario.esteUsuario.idUsuario}")
            .onDisconnect()
            .set(ultimaDesconexion);

        if (event.snapshot.value) {
             conexion = EstadoConexion.conectado;

          Usuario.esteUsuario.notifyListeners();
          Conversacion.conversaciones.notifyListeners();
        } else {
          conexion = EstadoConexion.conectando;
          bool internet = await DataConnectionChecker().hasConnection;
          if (!internet) {
            conexion = EstadoConexion.noConectado;
            if(ControladorNotificacion.instancia.notificacionSinconexionMostrada==false){
               ControladorNotificacion.instancia.mostrarProcesoConexion(BaseAplicacion.claveBase.currentContext);

            }
           
          } else {
            conexion = EstadoConexion.conectado;
          }

          Usuario.esteUsuario.notifyListeners();
          Conversacion.conversaciones.notifyListeners();
         
        }
      });
    }
 
  }
  
}
