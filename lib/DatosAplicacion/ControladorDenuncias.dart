

import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/GeneradorCodigos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

enum TipoDenuncia{
perfilFalso,menorEdad,fotosBiografiaInapropiada,hacePublicidad,otroTipo
}

//Hay dos zonas desde donde se pueden hacer denuncias
//Una de ellas es desde el visor de perfiles que es donde damos nota a los perfiles
//Y la otra es desde las conversaciones 
// Es importante esta distincion porque asi podremos distinguir y añadir o quitar denuncias dependiendo de desde donde se hagan
enum ZonaDenuncia{
  visorPerfiles,conversacion
}

class ControladorDenuncias with ChangeNotifier{

String idDenuncia;
String idDenunciado;
String idDenunciante;
String detallesDenuncia;

TipoDenuncia tipologiaDenuncia;
ZonaDenuncia zonaDenuncia;
DateTime fechaDenuncia;
bool vistoPorModerador=false;

ControladorDenuncias.visorPerfiles({@required this.idDenunciado,@required this.detallesDenuncia,@required this.zonaDenuncia,@required this.fechaDenuncia,@required this.tipologiaDenuncia}){
this.idDenuncia=GeneradorCodigos.instancia.crearCodigo();
this.idDenunciante=Usuario.esteUsuario.idUsuario;
this.zonaDenuncia=ZonaDenuncia.visorPerfiles;



}

ControladorDenuncias.conversacion({@required this.idDenunciado,@required this.detallesDenuncia,@required this.zonaDenuncia,@required this.fechaDenuncia,@required this.tipologiaDenuncia}){
this.idDenuncia=GeneradorCodigos.instancia.crearCodigo();
this.idDenunciante=Usuario.esteUsuario.idUsuario;
this.zonaDenuncia=ZonaDenuncia.conversacion;



}



static Future<bool> enviarDenuncia(ControladorDenuncias denuncia)async {
  bool denunciaEnviada=false;
  FirebaseFirestore baseDatos=FirebaseFirestore.instance;
  String tipoDenuncia;
  if(denuncia.tipologiaDenuncia==TipoDenuncia.fotosBiografiaInapropiada){
tipoDenuncia="Perfil Inapropiado";
  }
    if(denuncia.tipologiaDenuncia==TipoDenuncia.hacePublicidad){
tipoDenuncia="Hace publicidad";
  }
    if(denuncia.tipologiaDenuncia==TipoDenuncia.menorEdad){
tipoDenuncia="Menor edad";
  }
    if(denuncia.tipologiaDenuncia==TipoDenuncia.perfilFalso){
tipoDenuncia="Perfil falso";
  }

  


 await baseDatos.collection("expedientes").doc(denuncia.idDenunciado).update({
    
    "cantidadDenuncias":FieldValue.increment(1),
    "denuncias":FieldValue.arrayUnion([{
      "vistoModerador":denuncia.vistoPorModerador,
      "tipoDenuncia":tipoDenuncia,
      "idDenuncia":denuncia.idDenuncia,"detallesDenuncia":denuncia.detallesDenuncia,"horaDenuncia":denuncia.fechaDenuncia,"zonaDenuncia":denuncia.zonaDenuncia==ZonaDenuncia.visorPerfiles?"visorPerfiles":"conversacion"}])}).then((value) => denunciaEnviada=true).catchError((errr)=>denunciaEnviada=false);

return denunciaEnviada;

}





}