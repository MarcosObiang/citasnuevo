import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';




class ControladorPagos with ChangeNotifier{

static ControladorPagos instancia = new  ControladorPagos();



/// Datos importantes para Stripe
///
///
///
String clavePublicable_test="pk_test_51IFhpdJDFaMQajCsIoKfmXrMSvJCAuGC5iWqn7IGrYp9eBRO0XTQo8V2BVOBW4sQg5EQ0keuv1tV0A3dMgQOumQS00xxwHqic6";

void enviaTokenPago(String token)async{

 await FirebaseFirestore.instance.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).collection("tokens").doc(token).set({"token":token});
}

}
