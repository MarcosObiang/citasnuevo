import 'dart:async';

import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'Usuario.dart';



class ControladorCreditos {
  static ControladorCreditos instancia = new ControladorCreditos();
  final HttpsCallable llamarDarCreditos = CloudFunctions.instance
      .getHttpsCallable(functionName: "darCreditosUsuario");
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

 Future<void> restarCreditosValoracion(int creditos,String idValoracion) async {

   if(Usuario.creditosUsuario>=creditos){
HttpsCallableResult resultado=await llamarRestarCreditos.call(<String, dynamic>{
      "creditos": creditos,
      "idUsuario": Usuario.esteUsuario.idUsuario,
      "idValoracion":idValoracion
    });
    print("${resultado.data} resultado funcion");


   }

   
   

   

    
    Solicitudes.instancia.notifyListeners();
    
  }



   Future<void> restarCreditosSolicitud(int creditos,String idSolicitud) async {

   if(Usuario.creditosUsuario>=creditos){
HttpsCallableResult resultado=await llamarRestarCreditosSolicitud.call(<String, dynamic>{
      "creditos": creditos,
      "idUsuario": Usuario.esteUsuario.idUsuario,
      "idSolicitud":idSolicitud
    });
    print("${resultado.data} resultado funcion");


   }

   
   

   

    
    Solicitudes.instancia.notifyListeners();
    
  }

  void escucharCreditos() {
    FirebaseFirestore referenciaCreditos = FirebaseFirestore.instance;
    referenciaCreditos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .snapshots()
        .listen((event) {
      if (event != null) {
        int creditosEnNube = (event.data()["creditos"]);
        Usuario.creditosUsuario = creditosEnNube;

        print((event.data()["creditos"]).toString());
        Solicitudes.instancia.notifyListeners();
      }
    });
  }
}
