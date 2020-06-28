import 'dart:core';
import 'PerfilesUsuarios.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ServidorFirebase/firebase_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:citasnuevo/ServidorFirebase/firebase_sign_up.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_methods.dart';
import 'dart:core';

import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen_elements.dart';

import '../main.dart';

class Usuario with ChangeNotifier {
  static Usuario esteUsuario = new Usuario();

  Map<String,Object>DatosUsuario=new Map();
  List<File> _FotosPerfil = new List(6);
  List<File> get FotosPerfil => _FotosPerfil;

  set FotosPerfil(List<File> value) {
    _FotosPerfil = value;
    notifyListeners();
  }
  String idUsuario;
 
  Map<String,dynamic> ImageURL1=new Map();
  Map<String,dynamic> ImageURL2=new Map();
  Map<String,dynamic> ImageURL3=new Map();
  Map<String,dynamic> ImageURL4=new Map();
  Map<String,dynamic> ImageURL5=new Map();
  Map<String,dynamic> ImageURL6=new Map();
  void iniciarMapas(){
ImageURL1["Imagen"]="";
ImageURL2["Imagen"]="";
ImageURL3["Imagen"]="";
ImageURL4["Imagen"]="";
ImageURL5["Imagen"]="";
ImageURL6["Imagen"]="";

}
///************************************************************************ */
///
///
///Datos Personales Basicos-----Informacion OBLIGATORIA paara crear ell perfil
///
///
///************************************************************************ */
  String nombre;
  String alias;
  String clave;
  String confirmar_clave;
  String email;
  DateTime nacimiento;
  int edad;
  String sexo;
  String citasCon;
  String sexoPareja;
  DateTime _fechaNacimiento;
  String observaciones;
  ///
  ///
  ///Filtros de busqueda------- datos que debes completar para aparecer en la busqueda mas personalizada de otros usuarios
  ///
  ///
  double altura;
  String complexion;
  Map<String,String>formacion=new Map();
  Map<String,String>trabajo=new Map();
  String alcohol;
  String tabaco;
  String idiomas;
  String mascotas;
  String busco;
  String hijos;
  String zodiaco;
  String vegetarianoOvegano;
  String politica;
  String religion;
  String vivoCon;
  ///*************************************+ */
  ///
  ///Preguntas perfil---preguntas hechas al usuario y respondidas por este para hacer un perfil mas personal
  ///
  ///
  ///********************************** */
  String queBuscasEnAlguien;
  String queOdiasEnAlguien;
  String recetaFelicidad;
  String siQuedaUnDiaDeVida;
  String queMusicaTeGusta;
  String enQueEresBueno;
  String queEsLoQueMasValoras;
  String laGenteDiceQueSoy;
  String estoyAquiPara;
  String queMeHaceReir;
  String citaPErfecta;
  String cancionFavorita;
  String comidaFavorita;
  String unaVerdadUnaMentira;
  String meHariaFamosoPor;
  String siFueraUnHeroe;
  String siFueraUnVillano;
  String comerUnPlatoElRestoDeMividaSeria;
  String nosLlevaremosBienSi;
  String borrachoSoyMuy;
  String anecdota;
  String peliculaRecomiendas;
  String habilidadSecretaa;

  ///******************************************************
  ///
  ///
  ///
  ///Filtros Eventos---especificar eventos preferidos del usuario
  ///
  ///
  ///
  ///**************+******************************************* 
  bool coches=false;
  bool videoJuegos=false;
  bool cine=false;
  bool comida=false;
  bool modaYBelleza=false;
  bool animales=false;
  bool naturaleza=false;
  bool vidaSocial=false;
  bool musica=false;
  bool deporteFitness=false;
  bool fiesta=false;
  bool viajes=false;
  bool politicaSociedad=false;
  bool cienciaTecnologia=false;
  bool activismo=false;
  

  void configurarModo(){
    if(citas){
      amigos=false;
      if(sexo=="Hombre"&&sexoPareja=="Mujer"){
        citasCon="Mujer";
      }
      if(sexo=="Mujer"&&sexoPareja=="Hombre"){
        citasCon="Hombre";
      }
      if(sexo=="Mujer"&&sexoPareja==sexo){
        citasCon="MujerGay";
      }
      if(sexo=="Hombre"&&sexoPareja==sexo){
        citasCon="HombreGay";
      }
      if(sexoPareja=="Ambos"){
        citasCon="Ambos";
      }
    }
    if(amigos){
      citas=false;
      citasCon="";
    }
    if(ambos){
      if(sexo=="Hombre"&&sexoPareja=="Mujer"){
        citasCon="Mujer";
      }
      if(sexo=="Mujer"&&sexoPareja=="Hombre"){
        citasCon="Hombre";
      }
      if(sexo=="Mujer"&&sexoPareja==sexo){
        citasCon="MujerGay";
      }
      if(sexo=="Hombre"&&sexoPareja==sexo){
        citasCon="HombreGay";
      }
      if(sexoPareja=="Ambos"){
        citasCon="Ambos";
      }
    }
  }


  get fechaNacimiento => _fechaNacimiento;

  set fechaNacimiento(value) {
    _fechaNacimiento = value;
    notifyListeners();
  }

  bool citas = false;
  bool amigos = false;
  bool ambos = true;


  final databaseReference = Firestore.instance;
  static final dbRef = Firestore.instance;

  static Map<String, dynamic> imagenes = Map();
  void InicializarUsuario(){
  nombre=DatosUsuario["Nombre"];
  alias=DatosUsuario["Alias"];
  citasCon=DatosUsuario["Citas con"];
  edad=DatosUsuario["Edad"];
  sexo=DatosUsuario["Sexo"];
  amigos=DatosUsuario["Solo amigos"];
  citas=DatosUsuario["Solo Citas"];
  ambos=DatosUsuario["Ambos"];

  
  ImageURL1= DatosUsuario["IMAGENPERFIL1"];
   ImageURL2= DatosUsuario["IMAGENPERFIL2"];
   ImageURL3= DatosUsuario["IMAGENPERFIL3"];
   ImageURL4= DatosUsuario["IMAGENPERFIL4"];
   ImageURL5= DatosUsuario["IMAGENPERFIL5"];
   ImageURL6= DatosUsuario["IMAGENPERFIL6"];

  }


  static Map<String, dynamic> usuario = Map();
  void establecerUsuario() {
    usuario["Id"]=esteUsuario.idUsuario;
    usuario["IMAGENPERFIL1"] = esteUsuario.ImageURL1;
    usuario["IMAGENPERFIL2"] = esteUsuario.ImageURL2;
    usuario["IMAGENPERFIL3"] = esteUsuario.ImageURL3;
    usuario["IMAGENPERFIL4"] = esteUsuario.ImageURL4;
    usuario["IMAGENPERFIL5"] = esteUsuario.ImageURL5;
    usuario["IMAGENPERFIL6"] = esteUsuario.ImageURL6;
    usuario["Nombre"] = esteUsuario.nombre;
    usuario["Alias"] = esteUsuario.alias;
    usuario["clave"] = esteUsuario.clave;
    usuario["Email"] = esteUsuario.email;
    usuario["Edad"] = esteUsuario.edad;
    usuario["Sexo"] = esteUsuario.sexo;
    usuario["Citas con"] = esteUsuario.citasCon;
    usuario["Solo amigos"] = esteUsuario.amigos;
    usuario["Solo Citas"] = esteUsuario.citas;
    usuario["Ambos"] = esteUsuario.ambos;
    usuario["Descripcion"] = esteUsuario.observaciones;


  }





  void subirImagenPerfil(String IDUsuario) async {
   
    assert(imagenes != null);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    if (esteUsuario.FotosPerfil[0] != null) {
      String image1 = "${IDUsuario}/Perfil/imagenes/Image1.jpg";
      StorageReference ImagesReference = reference.child(image1);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.FotosPerfil[0]);
         

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL1["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.FotosPerfil[1] != null) {
      String Image2 = "${IDUsuario}/Perfil/imagenes/Image2.jpg";
      StorageReference ImagesReference = reference.child(Image2);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.FotosPerfil[1]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL2["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.FotosPerfil[2] != null) {
      String Image3 = "${IDUsuario}/Perfil/imagenes/Image3.jpg";
      StorageReference ImagesReference = reference.child(Image3);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.FotosPerfil[2]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL3["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.FotosPerfil[3] != null) {
      String Image4 = "${IDUsuario}/Perfil/imagenes/Image4.jpg";
      StorageReference ImagesReference = reference.child(Image4);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.FotosPerfil[3]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL4["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.FotosPerfil[4] != null) {
      String Image5 = "${IDUsuario}/Perfil/imagenes/Image5.jpg";
      StorageReference ImagesReference = reference.child(Image5);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.FotosPerfil[4]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL5["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.FotosPerfil[5] != null) {
      String Image6 = "${IDUsuario}/Perfil/imagenes/Image6.jpg";
      StorageReference ImagesReference = reference.child(Image6);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.FotosPerfil[5]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL6["Imagen"] = URL;
      print(URL);
    }
    establecerUsuario();
    assert(usuario != null);
    databaseReference
        .collection("usuarios")
        .document(IDUsuario)
        .setData(usuario);
  }

  static submit(BuildContext context) async {
    assert(esteUsuario.clave == esteUsuario.confirmar_clave);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();

    esteUsuario.idUsuario=await AuthService.signUpUser(
        esteUsuario.nombre,
        esteUsuario.alias,
        esteUsuario.clave,
        esteUsuario.email,
        esteUsuario.edad,
        esteUsuario.sexo,
        esteUsuario.citasCon);

  print(esteUsuario.idUsuario);

    Usuario.esteUsuario.subirImagenPerfil(esteUsuario.idUsuario);
    print("SiguientePantalla");
     Navigator.push(context, MaterialPageRoute(builder: (context) => start()));
   // Perfiles.perfilesCitas.obtenetPerfilesCitas();
  }

    void alerta() {
    notifyListeners();
  }


}
