import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ntp/ntp.dart';

class ExcepcionTiempo implements Exception {
  String mensaje;
  ExcepcionTiempo(mensaje);
}

class TiempoAplicacion {
  static TiempoAplicacion tiempoAplicacion = new TiempoAplicacion();
  DateTime marcaTiempoAplicacion;
  Future<void> obtenerMarcaTiempo() async {
    await NTP.now().then((tiempoServidor) {
this.marcaTiempoAplicacion =tiempoServidor;

    }).catchError((error) {
      
      
      if (this.marcaTiempoAplicacion == null) {
        FirebaseFirestore.instance
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("controladorFechaInicioSesion")
            .doc("tiempoServidor")
            .set({"tiempoServidor": FieldValue.serverTimestamp}).then((value) {
          FirebaseFirestore.instance
              .collection("usuarios")
              .doc(Usuario.esteUsuario.idUsuario)
              .collection("controladorFechaInicioSesion")
              .doc("tiempoServidor")
              .get()
              .then((valor) {
            if (valor != null) {
              this.marcaTiempoAplicacion = valor.get("tiempoServidor").toDate();
            }
            else{

              throw ExcepcionTiempo("No se puede obtener el tiempo del servidor");
            }
          }).catchError((error){
             throw ExcepcionTiempo("No se puede obtener el tiempo del servidor");
          });
        }).catchError((error){
          throw ExcepcionTiempo("Error de tiempo");
        });
      }
    });
  }
}
