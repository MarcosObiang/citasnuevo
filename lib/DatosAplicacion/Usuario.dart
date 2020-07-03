import 'dart:core';

import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';

import 'Conversacion.dart';
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
import 'Valoraciones.dart';
import 'actividad.dart';

class Usuario with ChangeNotifier {
  static Usuario esteUsuario = new Usuario();
  bool tieneHistorias = false;
  Map<String, Object> DatosUsuario = new Map();
  List<File> _fotosPerfil = new List(6);
  List<File> fotosHistorias = new List(6);
  List<File> get FotosPerfil => _fotosPerfil;
  List<Map<String, String>> listaDeHistoriasRed = new List(6);

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
  Map<String, dynamic> historia1 = new Map();
  Map<String, dynamic> historia2 = new Map();
  Map<String, dynamic> historia3 = new Map();
  Map<String, dynamic> historia4 = new Map();
  Map<String, dynamic> historia5 = new Map();
  Map<String, dynamic> historia6 = new Map();
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

  ///******************************************************
  ///
  ///
  ///
  ///Filtros Eventos---especificar eventos preferidos del usuario
  ///
  ///
  ///
  ///**************+*******************************************
  bool coches = false;
  bool videoJuegos = false;
  bool cine = false;
  bool comida = false;
  bool modaYBelleza = false;
  bool animales = false;
  bool naturaleza = false;
  bool vidaSocial = false;
  bool musica = false;
  bool deporteFitness = false;
  bool fiesta = false;
  bool viajes = false;
  bool politicaSociedad = false;
  bool cienciaTecnologia = false;
  bool activismo = false;

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
    imagenesHistorias["Historia 1"] = esteUsuario.historia1;
    imagenesHistorias["Historia 2"] = esteUsuario.historia2;
    imagenesHistorias["Historia 3"] = esteUsuario.historia3;
    imagenesHistorias["Historia 4"] = esteUsuario.historia4;
    imagenesHistorias["Historia 5"] = esteUsuario.historia5;
    imagenesHistorias["Historia 6"] = esteUsuario.historia6;
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
    usuario["clave"] = esteUsuario.clave;
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
    esteUsuario.datosParaFiltrosUsuario["Formacion"] = esteUsuario.formacion;
    esteUsuario.datosParaFiltrosUsuario["Trabajo"] = esteUsuario.trabajo;
    esteUsuario.datosParaFiltrosUsuario["Mascotas"] = esteUsuario.mascotas;
    esteUsuario.datosParaFiltrosUsuario["Busco"] = esteUsuario.busco;
    esteUsuario.datosParaFiltrosUsuario["Hijos"] = esteUsuario.hijos;
    esteUsuario.datosParaFiltrosUsuario["Vegetariano"] =
        esteUsuario.vegetarianoOvegano;
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

    ///
    ///
    ///
    ///Preferencias de eventos del usuario ppara saber que eventos le interesan
    ///
    ///
    ///
    esteUsuario.gustosUsuario["Automoviles"] = esteUsuario.coches;
    esteUsuario.gustosUsuario["VideoJuegos"] = esteUsuario.videoJuegos;
    esteUsuario.gustosUsuario["Cine"] = esteUsuario.cine;
    esteUsuario.gustosUsuario["Comida"] = esteUsuario.comida;
    esteUsuario.gustosUsuario["Moda"] = esteUsuario.modaYBelleza;
    esteUsuario.gustosUsuario["Animales"] = esteUsuario.animales;
    esteUsuario.gustosUsuario["Naturaleza"] = esteUsuario.naturaleza;
    esteUsuario.gustosUsuario["Vida social"] = esteUsuario.vidaSocial;
    esteUsuario.gustosUsuario["Musica"] = esteUsuario.musica;
    esteUsuario.gustosUsuario["Deporte"] = esteUsuario.deporteFitness;
    esteUsuario.gustosUsuario["Fiesta"] = esteUsuario.fiesta;
    esteUsuario.gustosUsuario["Viajes"] = esteUsuario.viajes;
    esteUsuario.gustosUsuario["Politica y sociedad"] =
        esteUsuario.politicaSociedad;
    esteUsuario.gustosUsuario["Ciencia y tecnologia"] =
        esteUsuario.cienciaTecnologia;
    usuario["Gustos Eventos"] = esteUsuario.gustosUsuario;
    usuario["Preguntas personales"] = esteUsuario.preguntasPersonales;
    usuario["Filtros usuario"] = esteUsuario.datosParaFiltrosUsuario;
  }

  Future<void> subirImagenPerfil(String IDUsuario) async {
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

  ///Metodo usado para subir historias del usuario, en la primera version solo permitira subir imagenes(Hasta un tottal de 6)
  ///
  ///
  ///
  ///
  Future<void> subirHistorioasUsuario(String IDUsuario) async {
    assert(imagenes != null);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    if (esteUsuario.fotosHistorias[0] != null) {
      String image1 = "${IDUsuario}/Perfil/Historias/Image1.jpg";
      StorageReference referenciaImagenes = reference.child(image1);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[0]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia1["Imagen"] = URL;
      print(URL);
      databaseReference
          .collection("usuarios")
          .document(IDUsuario)
          .collection("historias")
          .document("Historia1")
          .setData(esteUsuario.historia1);
    }
    if (esteUsuario.fotosHistorias[1] != null) {
      String Image2 = "${IDUsuario}/Perfil/Historias/Image2.jpg";
      StorageReference referenciaImagenes = reference.child(Image2);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[1]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia2["Imagen"] = URL;
      print(URL);
      databaseReference
          .collection("usuarios")
          .document(IDUsuario)
          .collection("historias")
          .document("Historia2")
          .setData(esteUsuario.historia2);
    }
    if (esteUsuario.fotosHistorias[2] != null) {
      String Image3 = "${IDUsuario}/Perfil/Historias/Image3.jpg";
      StorageReference referenciaImagenes = reference.child(Image3);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[2]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia3["Imagen"] = URL;
      print(URL);
      databaseReference
          .collection("usuarios")
          .document(IDUsuario)
          .collection("historias")
          .document("Historia3")
          .setData(esteUsuario.historia3);
    }
    if (esteUsuario.fotosHistorias[3] != null) {
      String Image4 = "${IDUsuario}/Perfil/Historias/Image4.jpg";
      StorageReference referenciaImagenes = reference.child(Image4);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[3]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia4["Imagen"] = URL;
      print(URL);

      databaseReference
          .collection("usuarios")
          .document(IDUsuario)
          .collection("historias")
          .document("Historia4")
          .setData(esteUsuario.historia4);
    }
    if (esteUsuario.fotosHistorias[4] != null) {
      String Image5 = "${IDUsuario}/Perfil/Historias/Image5.jpg";
      StorageReference referenciaImagenes = reference.child(Image5);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[4]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia5["Imagen"] = URL;
      print(URL);

      databaseReference
          .collection("usuarios")
          .document(IDUsuario)
          .collection("historias")
          .document("Historia5")
          .setData(esteUsuario.historia5);
    }
    if (esteUsuario.fotosHistorias[5] != null) {
      String Image6 = "${IDUsuario}/Perfil/Historias/Image6.jpg";
      StorageReference referenciaImagenes = reference.child(Image6);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(esteUsuario.fotosHistorias[5]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.historia6["Imagen"] = URL;
      print(URL);

      databaseReference
          .collection("usuarios")
          .document(IDUsuario)
          .collection("historias")
          .document("Historia6")
          .setData(esteUsuario.historia6);
    }
  }

  static submit(BuildContext context) async {
    assert(esteUsuario.clave == esteUsuario.confirmar_clave);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    DocumentSnapshot val;
    Firestore referencia = Firestore.instance;

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
          .document(esteUsuario.idUsuario)
          .get();
      esteUsuario.DatosUsuario = val.data;
      if (Usuario.esteUsuario.DatosUsuario != null) {
        Usuario.esteUsuario.InicializarUsuario();
        Perfiles.cargarPerfilesCitas();
        Perfiles.perfilesAmistad.cargarIsolateAmistad();
        Conversacion.obtenerConversaciones();
        Valoraciones.Puntuaciones.obtenerValoracion();
        Conversacion.conversaciones.escucharEstadoConversacion();
        EventosPropios.instanciaEventosPoprios.obtenerEventoosPropios();
        EventosPropios.instanciaEventosPoprios
            .escuchadorSolicitudesEventosPropios();

        Actividad.cargarEventos();
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

  void descargarHistorias() {
    Firestore dbRef = Firestore.instance;
    dbRef
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("historias")
        .getDocuments()
        .then((value) {
      if (value != null) {
        print(value.documents[0].documentID);
        for (int i = 0; i < value.documents.length; i++) {
          if (value.documents[i].documentID == "Historia1") {
            if (value.documents[i].data["Imagen"] != null) {
              Map<String, String> historiasPaquete = new Map();
              historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
              historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

              listaDeHistoriasRed[0] = historiasPaquete;
              tieneHistorias = true;
            }
          }
          if (value.documents[i].documentID == "Historia2") {
            if (value.documents[i].data != null) {
              Map<String, String> historiasPaquete = new Map();
              historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
              historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

              listaDeHistoriasRed[1] = historiasPaquete;
              tieneHistorias = true;
            }}

            if (value.documents[i].documentID == "Historia3") {
              if (value.documents[i].data != null) {
                Map<String, String> historiasPaquete = new Map();
                historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
                historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

                listaDeHistoriasRed[2] = historiasPaquete;
                tieneHistorias = true;
              }
            }
            if (value.documents[i].documentID == "Historia4") {
              if (value.documents[i].data != null) {
                Map<String, String> historiasPaquete = new Map();
                historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
                historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

                listaDeHistoriasRed[3] = historiasPaquete;
                tieneHistorias = true;
              }
            }
            if (value.documents[i].documentID == "Historia5") {
              if (value.documents[i].data != null) {
                Map<String, String> historiasPaquete = new Map();
                historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
                historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

                listaDeHistoriasRed[4] = historiasPaquete;
                tieneHistorias = true;
              }
            }
            if (value.documents[i].documentID == "Historia6") {
              if (value.documents[i].data != null) {
                Map<String, String> historiasPaquete = new Map();
                historiasPaquete["Imagen"] = value.documents[i].data["Imagen"];
                historiasPaquete["PieDeFoto"] = value.documents[i]["PieDeFoto"];

                listaDeHistoriasRed[5] = historiasPaquete;
                tieneHistorias = true;
              }
            }
          }
        }
      
    }).then((value) {
      if (tieneHistorias) {
        HistoriasUsuario.cargarHistorias();
      }
    });
  }
}
