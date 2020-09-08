import 'dart:core';
import 'dart:ffi';


import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';

import 'Conversacion.dart';
import 'Directo.dart';
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


import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen_elements.dart';

import '../main.dart';
import 'Valoraciones.dart';


class Usuario with ChangeNotifier {
  static Usuario esteUsuario = new Usuario();
  bool tieneHistorias = false;
  Map<String, Object> DatosUsuario = new Map();
  List<File> _fotosPerfil = new List(6);
  List<File> fotosHistorias = new List(6);
  List<File> get FotosPerfil => _fotosPerfil;
  List<Map<String, dynamic>> listaDeHistoriasRed = new List(6);

  set FotosPerfil(List<File> value) {
    _fotosPerfil = value;
    notifyListeners();
  }

  String idUsuario;
  

  Map<String, dynamic> ImageURL1 = new Map();
  Map<String, dynamic> ImageURL2 = new Map();
  Map<String, dynamic> ImageURL3 = new Map();
  Map<String, dynamic> ImageURL4 = new Map();
  Map<String, dynamic> ImageURL5 = new Map();
  Map<String, dynamic> ImageURL6 = new Map();

  /// Aqui almacenamos las imagenes de las historias para que se suban
  ///
  ///
  ///
  ///
  ///
  Map<String, String> historia1 = new Map();
  Map<String, String> historia2 = new Map();
  Map<String, String> historia3 = new Map();
  Map<String, String> historia4 = new Map();
  Map<String, String> historia5 = new Map();
  Map<String, String> historia6 = new Map();
  void iniciarMapas() {
    ImageURL1["Imagen"] = "";
    ImageURL2["Imagen"] = "";
    ImageURL3["Imagen"] = "";
    ImageURL4["Imagen"] = "";
    ImageURL5["Imagen"] = "";
    ImageURL6["Imagen"] = "";
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
  bool estaConectado=false;

  ///
  ///
  ///Filtros de busqueda------- datos que debes completar para aparecer en la busqueda mas personalizada de otros usuarios
  ///
  ///
  double altura;
  String complexion;
  Map<String, String> formacion = new Map();
  Map<String, String> trabajo = new Map();
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



  void configurarModo() {
    if (citas) {
      amigos = false;
      if (sexo == "Hombre" && sexoPareja == "Mujer") {
        citasCon = "Mujer";
      }
      if (sexo == "Mujer" && sexoPareja == "Hombre") {
        citasCon = "Hombre";
      }
      if (sexo == "Mujer" && sexoPareja == sexo) {
        citasCon = "MujerGay";
      }
      if (sexo == "Hombre" && sexoPareja == sexo) {
        citasCon = "HombreGay";
      }
      if (sexoPareja == "Ambos") {
        citasCon = "Ambos";
      }
    }
    if (amigos) {
      citas = false;
      citasCon = "";
    }
    if (ambos) {
      if (sexo == "Hombre" && sexoPareja == "Mujer") {
        citasCon = "Mujer";
      }
      if (sexo == "Mujer" && sexoPareja == "Hombre") {
        citasCon = "Hombre";
      }
      if (sexo == "Mujer" && sexoPareja == sexo) {
        citasCon = "MujerGay";
      }
      if (sexo == "Hombre" && sexoPareja == sexo) {
        citasCon = "HombreGay";
      }
      if (sexoPareja == "Ambos") {
        citasCon = "Ambos";
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
  Map<String, dynamic> imagenesHistorias = Map();
  void InicializarUsuario() {
    nombre = DatosUsuario["Nombre"];
    alias = DatosUsuario["Alias"];
    citasCon = DatosUsuario["Citas con"];
    edad = DatosUsuario["Edad"];
    sexo = DatosUsuario["Sexo"];
    amigos = DatosUsuario["Solo amigos"];
    citas = DatosUsuario["Solo Citas"];
    ambos = DatosUsuario["Ambos"];

    ImageURL1 = DatosUsuario["IMAGENPERFIL1"];
    ImageURL2 = DatosUsuario["IMAGENPERFIL2"];
    ImageURL3 = DatosUsuario["IMAGENPERFIL3"];
    ImageURL4 = DatosUsuario["IMAGENPERFIL4"];
    ImageURL5 = DatosUsuario["IMAGENPERFIL5"];
    ImageURL6 = DatosUsuario["IMAGENPERFIL6"];
  }

  void establecerHistorias() {
    imagenesHistorias["Nombre usuario"] = esteUsuario.nombre;
    imagenesHistorias["Id usuario"] = esteUsuario.idUsuario;
    imagenesHistorias["Imagen Perfil"] = VideoLlamada.obtenerImagenUsuarioLocal();
    imagenesHistorias["Historia 1"] = esteUsuario.historia1;
    imagenesHistorias["Historia 2"] = esteUsuario.historia2;
    imagenesHistorias["Historia 3"] = esteUsuario.historia3;
    imagenesHistorias["Historia 4"] = esteUsuario.historia4;
    imagenesHistorias["Historia 5"] = esteUsuario.historia5;
    imagenesHistorias["Historia 6"] = esteUsuario.historia6;
    esteUsuario.historia1["Identificador"]="Historia1";
      esteUsuario.historia2["Identificador"]="Historia2";
        esteUsuario.historia3["Identificador"]="Historia3";
          esteUsuario.historia4["Identificador"]="Historia4";
            esteUsuario.historia5["Identificador"]="Historia5";
              esteUsuario.historia6["Identificador"]="Historia6";
  }

  static Map<String, dynamic> usuario = Map();
  Map<String, bool> gustosUsuario = Map();
  Map<String, dynamic> preguntasPersonales = Map();
  Map<String, dynamic> datosParaFiltrosUsuario = Map();
  void establecerUsuario() {
    ///
    ///
    ///Datos principales del usuario
    ///
    ///
    ///
    usuario["Id"] = esteUsuario.idUsuario;
    usuario["IMAGENPERFIL1"] = esteUsuario.ImageURL1;
    usuario["IMAGENPERFIL2"] = esteUsuario.ImageURL2;
    usuario["IMAGENPERFIL3"] = esteUsuario.ImageURL3;
    usuario["IMAGENPERFIL4"] = esteUsuario.ImageURL4;
    usuario["IMAGENPERFIL5"] = esteUsuario.ImageURL5;
    usuario["IMAGENPERFIL6"] = esteUsuario.ImageURL6;
    usuario["Nombre"] = esteUsuario.nombre;
    usuario["Alias"] = esteUsuario.alias;

    usuario["Email"] = esteUsuario.email;
    usuario["Edad"] = esteUsuario.edad;
    usuario["Sexo"] = esteUsuario.sexo;

    ///
    ///
    /// Datos sobre el uso de la aplicacion
    ///
    ///
    ///
    usuario["Citas con"] = esteUsuario.citasCon;
    usuario["Solo amigos"] = esteUsuario.amigos;
    usuario["Solo Citas"] = esteUsuario.citas;
    usuario["Ambos"] = esteUsuario.ambos;
    usuario["Descripcion"] = esteUsuario.observaciones;

    ///
    ///
    ///
    /// Datos necesarios y mas especificos para coonocer mas al usuario
    ///
    ///
    ///
    ///

    esteUsuario.datosParaFiltrosUsuario["Altura"] = esteUsuario.altura;
    esteUsuario.datosParaFiltrosUsuario["Complexion"] = esteUsuario.complexion;
    esteUsuario.datosParaFiltrosUsuario["Tabaco"]=esteUsuario.tabaco;
    esteUsuario.datosParaFiltrosUsuario["Alcohol"]=esteUsuario.alcohol;
 
    esteUsuario.datosParaFiltrosUsuario["Mascotas"] = esteUsuario.mascotas;
    esteUsuario.datosParaFiltrosUsuario["Busco"] = esteUsuario.busco;
    esteUsuario.datosParaFiltrosUsuario["Hijos"] = esteUsuario.hijos;
    esteUsuario.datosParaFiltrosUsuario["Vegetariano"] =esteUsuario.vegetarianoOvegano;
    esteUsuario.datosParaFiltrosUsuario["Politca"] = esteUsuario.politica;
    esteUsuario.datosParaFiltrosUsuario["Que viva con"] = esteUsuario.vivoCon;

    ///
    ///
    ///Preguntas personales que el usuario quiera responder siendo 3 el maximo numero de preguntas a responder
    ///
    ///
    ///
    esteUsuario.preguntasPersonales["Que buscas en la gente"] =
        esteUsuario.queBuscasEnAlguien;
    esteUsuario.preguntasPersonales["Que odias de la gente"] =
        esteUsuario.queOdiasEnAlguien;
    esteUsuario.preguntasPersonales["Receta Felicidad"] =
        esteUsuario.recetaFelicidad;
    esteUsuario.preguntasPersonales["Un dia de vida"] =
        esteUsuario.siQuedaUnDiaDeVida;
    esteUsuario.preguntasPersonales["Musica te gusta"] =
        esteUsuario.queMusicaTeGusta;
    esteUsuario.preguntasPersonales["En que eres bueno"] =
        esteUsuario.enQueEresBueno;
    esteUsuario.preguntasPersonales["Que mas valoras"] =
        esteUsuario.queEsLoQueMasValoras;
    esteUsuario.preguntasPersonales["La gente dice que soy"] =
        esteUsuario.laGenteDiceQueSoy;
    esteUsuario.preguntasPersonales["Me hace reir"] = esteUsuario.queMeHaceReir;
    esteUsuario.preguntasPersonales["Cita perfecta"] = esteUsuario.citaPErfecta;
    esteUsuario.preguntasPersonales["Cancion favorita"] =
        esteUsuario.cancionFavorita;
    esteUsuario.preguntasPersonales["Verdad y mentira"] =
        esteUsuario.unaVerdadUnaMentira;
    esteUsuario.preguntasPersonales["Seria famoso por"] =
        esteUsuario.meHariaFamosoPor;
    esteUsuario.preguntasPersonales["Heroe"] = esteUsuario.siFueraUnHeroe;
    esteUsuario.preguntasPersonales["Villano"] = esteUsuario.siFueraUnVillano;
    esteUsuario.preguntasPersonales["Plato resto de mi vida"] =
        esteUsuario.comerUnPlatoElRestoDeMividaSeria;
    esteUsuario.preguntasPersonales["Nos llevamos bien si"] =
        esteUsuario.nosLlevaremosBienSi;
    esteUsuario.preguntasPersonales["Como eres borracho"] =
        esteUsuario.borrachoSoyMuy;
    esteUsuario.preguntasPersonales["Anecdotas"] = esteUsuario.anecdota;
    esteUsuario.preguntasPersonales["Pelicula recomendada"] =
        esteUsuario.peliculaRecomiendas;


    
    usuario["Preguntas personales"] = esteUsuario.preguntasPersonales;
    usuario["Filtros usuario"] = esteUsuario.datosParaFiltrosUsuario;
    usuario["Historias"]=esteUsuario.imagenesHistorias;
  }

  Future<void> subirImagenPerfil(String IDUsuario) async {
    assert(imagenes != null);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    DocumentReference referenciaUsuario= databaseReference.collection("usuarios").doc(IDUsuario);
    DocumentReference referenciaHistoriasDirecto=databaseReference.collection("directo historias").doc(IDUsuario);
    
    DocumentReference referenciaValoracionesLocales= databaseReference.collection("usuarios").doc(IDUsuario).collection("valoraciones").doc("mediaPuntos");
    DocumentReference referenciaEstadoLLamadas= databaseReference.collection("usuarios").doc(IDUsuario).collection("estadoLlamada").doc("estadoLlamada");
     WriteBatch escrituraUsuario=databaseReference.batch();
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

escrituraUsuario.set(referenciaUsuario, usuario);
escrituraUsuario.set(referenciaEstadoLLamadas, {"Estado":"Desconectado"});
escrituraUsuario.set(referenciaValoracionesLocales, {"mediaTotal":0,"Valoracion":5,"cantidadValoraciones":0,"puntuacionTotal":0});
escrituraUsuario.set(referenciaHistoriasDirecto, Usuario.esteUsuario.imagenesHistorias);
await escrituraUsuario.commit().catchError((onError){
  print("Error al crear usuario");
});


    
  
  }

  ///Metodo usado para subir historias del usuario, en la primera version solo permitira subir imagenes(Hasta un tottal de 6)
  ///
  ///
  ///
  ///
  Future<void> subirHistorioasUsuario(String IDUsuario) async {
    assert(imagenes != null);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    FirebaseFirestore referenciaBaseDatos=FirebaseFirestore.instance;
    DocumentReference referenciaHistoriaLocal= referenciaBaseDatos.collection("usuarios").doc(Usuario.esteUsuario.idUsuario);
    DocumentReference referenciaHistoriasDirecto=referenciaBaseDatos.collection("directo historias").doc(Usuario.esteUsuario.idUsuario);
    
     DocumentReference referenciaValoracionesLocales= referenciaBaseDatos.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).collection("valoraciones").doc("mediaPuntos");
     DocumentReference referenciaEstadoLLamadas= referenciaBaseDatos.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).collection("estadoLlamada").doc("estadoLlamada");
    

    WriteBatch escrituraHistorias=referenciaBaseDatos.batch();
    if (esteUsuario.fotosHistorias[0] != null) {
      String image1 = "${IDUsuario}/Perfil/Historias/Image1.jpg";
      StorageReference referenciaImagenes = reference.child(image1);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[0]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia1["Imagen"] = URL;
  
    }
    if (esteUsuario.fotosHistorias[1] != null) {
      String Image2 = "${IDUsuario}/Perfil/Historias/Image2.jpg";
      StorageReference referenciaImagenes = reference.child(Image2);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[1]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia2["Imagen"] = URL;
      print(URL);
   
    }
    if (esteUsuario.fotosHistorias[2] != null) {
      String Image3 = "${IDUsuario}/Perfil/Historias/Image3.jpg";
      StorageReference referenciaImagenes = reference.child(Image3);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[2]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia3["Imagen"] = URL;
      print(URL);
    
    }
    if (esteUsuario.fotosHistorias[3] != null) {
      String Image4 = "${IDUsuario}/Perfil/Historias/Image4.jpg";
      StorageReference referenciaImagenes = reference.child(Image4);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[3]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia4["Imagen"] = URL;
      print(URL);

   
    }
    if (esteUsuario.fotosHistorias[4] != null) {
      String Image5 = "${IDUsuario}/Perfil/Historias/Image5.jpg";
      StorageReference referenciaImagenes = reference.child(Image5);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[4]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia5["Imagen"] = URL;
      print(URL);

    }
    if (esteUsuario.fotosHistorias[5] != null) {
      String Image6 = "${IDUsuario}/Perfil/Historias/Image6.jpg";
      StorageReference referenciaImagenes = reference.child(Image6);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[5]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia6["Imagen"] = URL;
      print(URL);

      
    }
escrituraHistorias.update(referenciaHistoriaLocal,imagenesHistorias );
escrituraHistorias.update(referenciaHistoriasDirecto, imagenesHistorias);

await escrituraHistorias.commit().catchError((onError)=>(print(onError)));





    
  }

  static submit(BuildContext context) async {
    assert(esteUsuario.clave == esteUsuario.confirmar_clave);
    FirebaseStorage storage = FirebaseStorage.instance;
        FirebaseFirestore referenciaBaseDatos=FirebaseFirestore.instance;
    
    
  
    StorageReference reference = storage.ref();
    DocumentSnapshot val;
    FirebaseFirestore referencia = FirebaseFirestore.instance;

    esteUsuario.idUsuario = await AuthService.signUpUser(
        esteUsuario.nombre,
        esteUsuario.alias,
        esteUsuario.clave,
        esteUsuario.email,
        esteUsuario.edad,
        esteUsuario.sexo,
        esteUsuario.citasCon);
     

    print(esteUsuario.idUsuario);

    Usuario.esteUsuario
        .subirImagenPerfil(esteUsuario.idUsuario)
        .then((value) async {
      val = await referencia
          .collection("usuarios")
          .doc(esteUsuario.idUsuario)
          .get();
      esteUsuario.DatosUsuario = val.data();
      if (Usuario.esteUsuario.DatosUsuario != null) {
        Usuario.esteUsuario.InicializarUsuario();
        Perfiles.cargarPerfilesCitas();
     
        Conversacion.conversaciones.obtenerConversaciones();
        Valoraciones.Puntuaciones.escucharValoraciones();
        Conversacion.conversaciones.escucharEstadoConversacion();
       
        Conversacion.conversaciones.escucharMensajes();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => start()));
      }
    });
    print("SiguientePantalla");

    // Perfiles.perfilesCitas.obtenetPerfilesCitas();
  }

  void alerta() {
    notifyListeners();
  }

  void escuchadorHistorias() async {
    FirebaseFirestore dbRef = FirebaseFirestore.instance;
    // ignore: await_only_futures
    await dbRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("historias")
        .doc("Historias")
        .snapshots()
        .listen((value) {
      //4   listaDeHistoriasRed = null;
      tieneHistorias = false;
      if (value != null) {
      
        descargarHistorias();
        /* for (int i = 0; i < value.documents.length; i++) {
          if (value.documents[i].documentID == "Historia1") {
            if (value.documents[i].data["Imagen"] != null) {
              Map<String, String> historiasPaquete = new Map();
              historiasPaquete["Identificador"] = value.documents[i].documentID;
              historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
              historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

              listaDeHistoriasRed[0] = historiasPaquete;
              tieneHistorias = true;
            }
          }
          if (value.documents[i].documentID == "Historia2") {
            if (value.documents[i].data != null) {
              Map<String, String> historiasPaquete = new Map();
              historiasPaquete["Identificador"] = value.documents[i].documentID;
              historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
              historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

              listaDeHistoriasRed[1] = historiasPaquete;
              tieneHistorias = true;
            }
          }

          if (value.documents[i].documentID == "Historia3") {
            if (value.documents[i].data != null) {
              Map<String, String> historiasPaquete = new Map();
              historiasPaquete["Identificador"] = value.documents[i].documentID;
              historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
              historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

              listaDeHistoriasRed[2] = historiasPaquete;
              tieneHistorias = true;
            }
          }
          if (value.documents[i].documentID == "Historia4") {
            if (value.documents[i].data != null) {
              Map<String, String> historiasPaquete = new Map();
              historiasPaquete["Identificador"] = value.documents[i].documentID;
              historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
              historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

              listaDeHistoriasRed[3] = historiasPaquete;
              tieneHistorias = true;
            }
          }
          if (value.documents[i].documentID == "Historia5") {
            if (value.documents[i].data != null) {
              Map<String, String> historiasPaquete = new Map();
              historiasPaquete["Identificador"] = value.documents[i].documentID;
              historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
              historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

              listaDeHistoriasRed[4] = historiasPaquete;
              tieneHistorias = true;
            }
          }
          if (value.documents[i].documentID == "Historia6") {
            if (value.documents[i].data != null) {
              Map<String, String> historiasPaquete = new Map();
              historiasPaquete["Identificador"] = value.documents[i].documentID;
              historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
              historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

              listaDeHistoriasRed[5] = historiasPaquete;
              tieneHistorias = true;
            }
          }
        }*/
      }
    });
  }

  void descargarHistorias() {
    FirebaseFirestore dbRef = FirebaseFirestore.instance;
    dbRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("historias")
        .doc("Historias")
        .get()
        .then((value) {
      if (value != null) {
        

       
          if (value.get("Historia 1") != null) {
           
            if (value.get("Historia 1")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete1 = new Map();
           
                historiasPaquete1=value.get("Historia 1");
              listaDeHistoriasRed[0] = historiasPaquete1;
              tieneHistorias = true;
            }
          } 
          if (value.get("Historia 2") != null) {
            if (value.get("Historia 2")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete2 = new Map();
                  historiasPaquete2=value.get("Historia 2");

              listaDeHistoriasRed[1] = historiasPaquete2;
              tieneHistorias = true;
            }
          } 

          if (value.get("Historia 3") != null) {
            if (value.get("Historia 3")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete3 = new Map();
               historiasPaquete3=value.get("Historia 3");
              listaDeHistoriasRed[2] = historiasPaquete3;
              tieneHistorias = true;
            }
          } 
          if (value.get("Historia 4")!= null) {
            if (value.get("Historia 4")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete4 = new Map();
             historiasPaquete4=value.get("Historia 4");

              listaDeHistoriasRed[3] = historiasPaquete4;
              tieneHistorias = true;
            }
          } 
          if (value.get("Historia 5")!= null) {
            if (value.get("Historia 5")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete5 = new Map();
                historiasPaquete5=value.get("Historia 5");

              listaDeHistoriasRed[4] = historiasPaquete5;
              tieneHistorias = true;
            }
          } 
          if (value.get("Historia 6") != null) {
            if (value.get("Historia 6")["Imagen"] != null) {
              Map<String, dynamic> historiasPaquete6 = new Map();
          historiasPaquete6=value.get("Historia 6");

              listaDeHistoriasRed[5] = historiasPaquete6;
              tieneHistorias = true;
            }
          }
        
      }
    }).then((value) {
      if (tieneHistorias) {
        HistoriasUsuario.historias= new List();
        HistoriasUsuario.cargarHistorias();
        Usuario.esteUsuario.notifyListeners();
      }
    });
  }
}
