import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'Usuario.dart';

class CrontroladorCreditos{

static final HttpsCallable llamable=CloudFunctions.instance.getHttpsCallable(functionName: "darCreditosUsuario");


static void sumar(int creditos)async{

 await llamable.call(<String,dynamic>{
"creditos":500,"idUsuario":Usuario.esteUsuario.idUsuario
  });

 // print(respuesta.data);
  
 Solicitudes.instancia.notifyListeners();
}


static void restarCreditos(int creditos)async{

   HttpsCallableResult respuesta=await llamable.call(<String,dynamic>{
"creditos":500,"idUsuario":Usuario.esteUsuario.idUsuario
  });

  print(respuesta.data);
  Usuario.creditosUsuario=respuesta.data;
 Solicitudes.instancia.notifyListeners();
}

static void escucharCreditos(){
    FirebaseFirestore referenciaCreditos=FirebaseFirestore.instance;
    referenciaCreditos.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).snapshots().listen((event) { 


if(event!=null){
  int creditosEnNube=(event.data()["creditos"]);
  Usuario.creditosUsuario=creditosEnNube;
  
print((event.data()["creditos"]).toString());
   Solicitudes.instancia.notifyListeners();
  
  
}

    });
  }
}