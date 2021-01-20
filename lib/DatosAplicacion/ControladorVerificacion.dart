
import 'dart:typed_data';

import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_storage/firebase_storage.dart';

class ControladorVerificacion with ChangeNotifier{

static ControladorVerificacion instanciaVerificacion=new ControladorVerificacion.instancia();
static final String idUsuarioSolicitante=Usuario.esteUsuario.idUsuario;
Uint8List imagen1Bytes;

String urlImagen1;
String codigoImagenObjetivo1;

String codigoImagenObjetivo2;
String idSolicitudVerificacion;

 DateTime fechaSolicitudVerificacion;

ControladorVerificacion.instancia();
ControladorVerificacion.crear({@required this.idSolicitudVerificacion,@required this.fechaSolicitudVerificacion,@required this.imagen1Bytes,@required this.codigoImagenObjetivo1});

Future<void> cargarEnAlmacenamiento()async{
 FirebaseStorage storage = FirebaseStorage.instance;
  StorageReference reference = storage.ref();
        String imagen1 = "${Usuario.esteUsuario.idUsuario}/FotosVerificacion/verificacion1.jpg";
      StorageReference referenciaImagen = reference.child(imagen1);
      StorageUploadTask uploadTask =
          referenciaImagen.putData(this.imagen1Bytes);

     var url= await (await uploadTask.onComplete).ref.getDownloadURL();
      this.urlImagen1 = url;
      print(url);

      
}

///Antes de usar el metodo [enviarSolicitudCalificacion] es obligatorio llamar al metodo [cargarEnAlmacenamiento]
///ya que la la correcta ejecucion de este metodo nos asegura que las imagenes del usuario a verificar hayan sido almacenadas en los servidores

void enviarSolicitudVerificacion()async{
  final HttpsCallable funcionNube = CloudFunctions.instance
      .getHttpsCallable(functionName: "enviarSolicitudVerificacion");

await funcionNube.call({

    "imagen":this.urlImagen1,
    "obejtivo":this.codigoImagenObjetivo1,

 
  
 
  "idSolicitud":this.idSolicitudVerificacion,
  "idSolicitante":idUsuarioSolicitante,

  "imagenesPerfil":[
Usuario.esteUsuario.imagenUrl1["Imagen"],
Usuario.esteUsuario.imagenUrl2["Imagen"],
Usuario.esteUsuario.imagenUrl3["Imagen"],
Usuario.esteUsuario.imagenUrl4["Imagen"],
Usuario.esteUsuario.imagenUrl5["Imagen"],
Usuario.esteUsuario.imagenUrl6["Imagen"],


  ]

}).then((valor){
print(valor.data);
}).catchError((error){
  print("Est es el error: $error");
});



  
}




}