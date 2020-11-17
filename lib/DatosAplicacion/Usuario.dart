import 'dart:core';
import 'dart:ffi';
import 'dart:typed_data';

import 'dart:io' as Io;
import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/GeneradorCodigos.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/pantalla_actividades_elements.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'ControladorLikes.dart';
import 'ControladorConversacion.dart';

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

import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen_elements.dart';

import '../main.dart';

class Usuario with ChangeNotifier {
  static Usuario esteUsuario = new Usuario();
  static Usuario cacheEdicionUsuario = new Usuario();
  static int creditosUsuario = 0;
  bool tieneHistorias = false;
  Map<String, Object> DatosUsuario = new Map();
  List<File> _fotosPerfil = new List(6);
  List<File> fotosHistorias = new List(6);
  List<File> get fotosPerfil => _fotosPerfil;
  List<Map<String, dynamic>> listaDeHistoriasRed = new List(6);
  List<File> fotosUsuarioActualizar = new List();
  double latitud;
  double longitud;
  String geohash;
  Map<String, dynamic> posicion;
  int dia = 0;
  int mes = 0;
  int anio = 0;
  List<int> listaEdades = new List();
  int edadInicial = 18;
  int edadfinal;

  void establecerEdades() {
    listaEdades.add(Usuario.esteUsuario.edad);
  }

  set fotosPerfil(List<File> value) {
    _fotosPerfil = value;
    notifyListeners();
  }

  static List<String> listaDeImagenesUsuario = [
    Usuario.esteUsuario.ImageURL1["Imagen"],
    Usuario.esteUsuario.ImageURL2["Imagen"],
    Usuario.esteUsuario.ImageURL3["Imagen"],
    Usuario.esteUsuario.ImageURL4["Imagen"],
    Usuario.esteUsuario.ImageURL5["Imagen"],
    Usuario.esteUsuario.ImageURL6["Imagen"],
  ];

  Future<void> descarGarImagenesUsuario(List<String> listaDeImagenes) async {
    Directory directorio = await getApplicationDocumentsDirectory();
    String directorioImagenes = directorio.path;

    for (int i = 0; i < listaDeImagenesUsuario.length; i++) {
      if (listaDeImagenesUsuario[i] != null) {
        Uint8List archivo = await networkImageToByte(listaDeImagenes[i]);
        String referenciaCompleta =
            "$directorioImagenes/${ GeneradorCodigos.instancia.crearCodigo()}";
        Io.File puntero = new Io.File(referenciaCompleta);
        puntero.writeAsBytes(archivo);
        File imagenGuardada = File(referenciaCompleta);

        Usuario.esteUsuario.fotosUsuarioActualizar.add(imagenGuardada);
      } else {
        File archivoVacio;
        Usuario.esteUsuario.fotosUsuarioActualizar.add(archivoVacio);
      }
    }
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
  int edad = 0;
  String sexo;
  String citasCon;
  String sexoPareja;
  DateTime fechaNacimiento;
  String observaciones;
  bool estaConectado = false;

  ///
  ///
  ///Filtros de busqueda------- datos que debes completar para aparecer en la busqueda mas personalizada de otros usuarios
  ///
  ///

  Map<String, String> formacion = new Map();
  Map<String, String> trabajo = new Map();
  double altura;
  int complexion = 0;
  int alcohol = 0;
  int tabaco = 0;
  int idiomas = 0;
  int mascotas = 0;
  int busco = 0;
  int hijos = 0;
  int zodiaco = 0;
  int vegetarianoOvegano = 0;
  int politica = 0;
  int religion = 0;
  int vivoCon = 0;

  ///*************************************+ */
  ///
  ///Preguntas perfil---preguntas hechas al usuario y respondidas por este para hacer un perfil mas personal
  ///
  ///
  ///********************************** */
  int preguntasContestadas = 3;
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

  List<String> listaRespuestasPreguntasPersonales = new List(21);
  static List<String> listaPreguntasPersonales = [
    "Me hace reir..",
    "Valoro mucho..",
    "Mi musica favorita es..",
    "Mi receta de la felicidad es..",
    "Soy bueno en..",
    "Me describen como..",
    "Mi cita perfecta seria..",
    "¿Cancion favorita?",
    "Una verdad y una mentira",
    "Te harias famoso por..",
    "si fueras un heroe seria..",
    "Si fuera un villano seria..",
    "Un plato el resto de mi vida",
    "Nos llevaremos bien si..",
    "Borracho/a soy...",
    "Anecdota",
    "¿Que pelicula recomiendas?",
    "En alguien busco..",
    "Odio a la gente que..",
    "Si me quedara un dia de vida"
  ];

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

  void cargarPreguntasPersonales() {
    esteUsuario.queBuscasEnAlguien =
        esteUsuario.preguntasPersonales["Que buscas en la gente"];
    esteUsuario.queOdiasEnAlguien =
        esteUsuario.preguntasPersonales["Que odias de la gente"];
    esteUsuario.recetaFelicidad =
        esteUsuario.preguntasPersonales["Receta Felicidad"];
    esteUsuario.siQuedaUnDiaDeVida =
        esteUsuario.preguntasPersonales["Un dia de vida"];
    esteUsuario.queMusicaTeGusta =
        esteUsuario.preguntasPersonales["Musica te gusta"];
    esteUsuario.enQueEresBueno =
        esteUsuario.preguntasPersonales["En que eres bueno"];
    esteUsuario.queEsLoQueMasValoras =
        esteUsuario.preguntasPersonales["Que mas valoras"];
    esteUsuario.laGenteDiceQueSoy =
        esteUsuario.preguntasPersonales["La gente dice que soy"];
    esteUsuario.queMeHaceReir = esteUsuario.preguntasPersonales["Me hace reir"];
    esteUsuario.citaPErfecta = esteUsuario.preguntasPersonales["Cita perfecta"];
    esteUsuario.cancionFavorita =
        esteUsuario.preguntasPersonales["Cancion favorita"];
    esteUsuario.unaVerdadUnaMentira =
        esteUsuario.preguntasPersonales["Verdad y mentira"];
    esteUsuario.meHariaFamosoPor =
        esteUsuario.preguntasPersonales["Seria famoso por"];
    esteUsuario.siFueraUnHeroe = esteUsuario.preguntasPersonales["Heroe"];
    esteUsuario.siFueraUnVillano = esteUsuario.preguntasPersonales["Villano"];
    esteUsuario.comerUnPlatoElRestoDeMividaSeria =
        esteUsuario.preguntasPersonales["Plato resto de mi vida"];
    esteUsuario.nosLlevaremosBienSi =
        esteUsuario.preguntasPersonales["Nos llevamos bien si"];
    esteUsuario.borrachoSoyMuy =
        esteUsuario.preguntasPersonales["Como eres borracho"];
    esteUsuario.anecdota = esteUsuario.preguntasPersonales["Anecdotas"];
    esteUsuario.peliculaRecomiendas =
        esteUsuario.preguntasPersonales["Peliculas recomendada"];
    esteUsuario.listaRespuestasPreguntasPersonales = [
      esteUsuario.queMeHaceReir,
      esteUsuario.queEsLoQueMasValoras,
      esteUsuario.queMusicaTeGusta,
      esteUsuario.recetaFelicidad,
      esteUsuario.enQueEresBueno,
      esteUsuario.laGenteDiceQueSoy,
      esteUsuario.estoyAquiPara,
      esteUsuario.citaPErfecta,
      esteUsuario.cancionFavorita,
      esteUsuario.comidaFavorita,
      esteUsuario.unaVerdadUnaMentira,
      esteUsuario.meHariaFamosoPor,
      esteUsuario.siFueraUnHeroe,
      esteUsuario.siFueraUnVillano,
      esteUsuario.comerUnPlatoElRestoDeMividaSeria,
      esteUsuario.nosLlevaremosBienSi,
      esteUsuario.borrachoSoyMuy,
      esteUsuario.anecdota,
      esteUsuario.peliculaRecomiendas,
      esteUsuario.habilidadSecretaa,
      esteUsuario.queBuscasEnAlguien,
      esteUsuario.queOdiasEnAlguien,
      esteUsuario.siQuedaUnDiaDeVida
    ];
    for (int i = 0;
        i < esteUsuario.listaRespuestasPreguntasPersonales.length;
        i++) {
      if (esteUsuario.listaRespuestasPreguntasPersonales[i] != null) {
        esteUsuario.preguntasContestadas -= 1;
      }
    }
  }

  void cargarFiltrosPersonales() {
    esteUsuario.altura =
        esteUsuario.datosParaFiltrosUsuario["Altura"].toDouble();
    esteUsuario.complexion = esteUsuario.datosParaFiltrosUsuario["Complexion"];
    esteUsuario.tabaco = esteUsuario.datosParaFiltrosUsuario["Tabaco"];
    esteUsuario.alcohol = esteUsuario.datosParaFiltrosUsuario["Alcohol"];
    esteUsuario.mascotas = esteUsuario.datosParaFiltrosUsuario["Mascotas"];
    esteUsuario.busco = esteUsuario.datosParaFiltrosUsuario["Busco"];
    esteUsuario.hijos = esteUsuario.datosParaFiltrosUsuario["Hijos"];
    esteUsuario.politica = esteUsuario.datosParaFiltrosUsuario["Politca"];
    esteUsuario.vivoCon = esteUsuario.datosParaFiltrosUsuario["Que viva con"];
  }

  bool citas = false;
  bool amigos = false;
  bool ambos = true;

  final databaseReference = FirebaseFirestore.instance;
  static final dbRef = FirebaseFirestore.instance;

  static Map<String, dynamic> imagenes = Map();
  Map<String, dynamic> imagenesHistorias = Map();
  void inicializarUsuario() {
    Timestamp temporalParaFecha;
    nombre = DatosUsuario["Nombre"];
    alias = DatosUsuario["Alias"];
    citasCon = DatosUsuario["Citas con"];
    posicion = DatosUsuario["posicion"];
    edad = DatosUsuario["Edad"];
    sexo = DatosUsuario["Sexo"];
    amigos = DatosUsuario["Solo amigos"];
    citas = DatosUsuario["Solo Citas"];
    ambos = DatosUsuario["Ambos"];
    creditosUsuario = DatosUsuario["creditos"];
    temporalParaFecha = DatosUsuario["fechaNacimiento"];
    fechaNacimiento = temporalParaFecha.toDate();
    observaciones = DatosUsuario["Descripcion"];
    datosParaFiltrosUsuario = DatosUsuario["Filtros usuario"];
    preguntasPersonales = DatosUsuario["Preguntas personales"];
    cargarFiltrosPersonales();
    cargarPreguntasPersonales();
    GeoPoint punto = posicion["geopoint"];
    geohash = posicion["geohash"];

    latitud = punto.latitude;
    longitud = punto.longitude;

    ImageURL1 = DatosUsuario["IMAGENPERFIL1"];
    ImageURL2 = DatosUsuario["IMAGENPERFIL2"];
    ImageURL3 = DatosUsuario["IMAGENPERFIL3"];
    ImageURL4 = DatosUsuario["IMAGENPERFIL4"];
    ImageURL5 = DatosUsuario["IMAGENPERFIL5"];
    ImageURL6 = DatosUsuario["IMAGENPERFIL6"];

    ///Obtenemos los ajustes de la cuenta de usuario
    ///
    Map<String, dynamic> ajustes = DatosUsuario["Ajustes"];
    ControladorLocalizacion.instancia.setMostrarmeEnHotty =
        ajustes["mostrarPerfil"];
    ControladorLocalizacion.instancia.setDiistanciaMaxima =
        ajustes["distanciaMaxima"].toDouble();
    ControladorLocalizacion.instancia.setEdadFinal =
        ajustes["edadFinal"].toDouble();
    ControladorLocalizacion.instancia.setEdadInicial =
        ajustes["edadInicial"].toDouble();
    ControladorLocalizacion.instancia.setVisualizarDistanciaEnMillas =
        ajustes["enMillas"];
    ControladorLocalizacion.instancia.mostrarMujeres =
        ajustes["mostrarMujeres"];
    ControladorLocalizacion.activadorEdadesDeseadas =
        new List<int>.from(ajustes["rangoEdades"]);
    Usuario.esteUsuario
        .descarGarImagenesUsuario(Usuario.listaDeImagenesUsuario)
        .then((value) {});
  }

  static Map<String, dynamic> usuario = Map();
  Map<String, dynamic> ajustesUSuario = new Map();
  Map<String, bool> gustosUsuario = Map();
  Map<String, dynamic> preguntasPersonales = Map();
  Map<String, dynamic> datosParaFiltrosUsuario = Map();
  Future<void> establecerUsuario() async {
    establecerEdades();

    var geoposicion =
        await ControladorLocalizacion.obtenerLocalizacionPorPrimeraVez()
            .catchError((onError) =>
                print("Hubo un error con la localizacion: $onError"));

    ///
    ///
    ///Datos principales del usuario
    ///
    ///
    ajustesUSuario["mostrarPerfil"] =
        ControladorLocalizacion.instancia.mostrarmeEnHotty;
    ajustesUSuario["distanciaMaxima"] =
        ControladorLocalizacion.instancia.distanciaMaxima;
    ajustesUSuario["edadFinal"] =
        ControladorLocalizacion.instancia.getEdadFinal;
    ajustesUSuario["edadInicial"] =
        ControladorLocalizacion.instancia.getEdadInicial;
    ajustesUSuario["enMillas"] =
        ControladorLocalizacion.instancia.getVisualizarDistanciaEnMillas;
    ajustesUSuario["mostrarMujeres"] =
        ControladorLocalizacion.instancia.mostrarMujeres;
    ajustesUSuario["rangoEdades"] = [22, 23, 24];

    usuario["Id"] = esteUsuario.idUsuario;
    usuario["IMAGENPERFIL1"] = esteUsuario.ImageURL1;
    usuario["IMAGENPERFIL2"] = esteUsuario.ImageURL2;
    usuario["IMAGENPERFIL3"] = esteUsuario.ImageURL3;
    usuario["IMAGENPERFIL4"] = esteUsuario.ImageURL4;
    usuario["IMAGENPERFIL5"] = esteUsuario.ImageURL5;
    usuario["IMAGENPERFIL6"] = esteUsuario.ImageURL6;
    usuario["Nombre"] = esteUsuario.nombre;
    usuario["Alias"] = esteUsuario.alias;
    usuario["creditos"] = creditosUsuario;
    usuario["posicion"] = geoposicion.data;
    usuario["Email"] = esteUsuario.email;
    usuario["Edad"] = esteUsuario.edad;
    usuario["Sexo"] = esteUsuario.sexo;
    usuario["Edades"] = listaEdades;
    usuario["Ajustes"] = ajustesUSuario;

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
    usuario["fechaNacimiento"] = esteUsuario.fechaNacimiento;

    ///
    ///
    ///
    /// Datos necesarios y mas especificos para coonocer mas al usuario
    ///
    ///
    ///
    ///

    esteUsuario.datosParaFiltrosUsuario["Altura"] = esteUsuario.altura ?? 0;
    esteUsuario.datosParaFiltrosUsuario["Complexion"] =
        esteUsuario.complexion ?? 0;
    esteUsuario.datosParaFiltrosUsuario["Tabaco"] = esteUsuario.tabaco ?? 0;
    esteUsuario.datosParaFiltrosUsuario["Alcohol"] = esteUsuario.alcohol ?? 0;

    esteUsuario.datosParaFiltrosUsuario["Mascotas"] = esteUsuario.mascotas ?? 0;
    esteUsuario.datosParaFiltrosUsuario["Busco"] = esteUsuario.busco ?? 0;
    esteUsuario.datosParaFiltrosUsuario["Hijos"] = esteUsuario.hijos ?? 0;
    esteUsuario.datosParaFiltrosUsuario["Vegetariano"] =
        esteUsuario.vegetarianoOvegano ?? 0;
    esteUsuario.datosParaFiltrosUsuario["Politca"] = esteUsuario.politica ?? 0;
    esteUsuario.datosParaFiltrosUsuario["Que viva con"] =
        esteUsuario.vivoCon ?? 0;

    ///
    ///
    ///Preguntas personales que el usuario quiera responder siendo 3 el maximo numero de preguntas a responder
    ///
    ///
    ///

    esteUsuario.preguntasPersonales["Que buscas en la gente"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[17] ?? null;
    esteUsuario.preguntasPersonales["Que odias de la gente"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[18];
    esteUsuario.preguntasPersonales["Receta Felicidad"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[3];
    esteUsuario.preguntasPersonales["Un dia de vida"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[19];
    esteUsuario.preguntasPersonales["Musica te gusta"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[2];
    esteUsuario.preguntasPersonales["En que eres bueno"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[4];
    esteUsuario.preguntasPersonales["Que mas valoras"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[1];
    esteUsuario.preguntasPersonales["La gente dice que soy"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[5];
    esteUsuario.preguntasPersonales["Me hace reir"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[0];
    esteUsuario.preguntasPersonales["Cita perfecta"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[6];
    esteUsuario.preguntasPersonales["Cancion favorita"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[7];
    esteUsuario.preguntasPersonales["Verdad y mentira"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[8];
    esteUsuario.preguntasPersonales["Seria famoso por"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[9];
    esteUsuario.preguntasPersonales["Heroe"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[10];
    esteUsuario.preguntasPersonales["Villano"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[11];
    esteUsuario.preguntasPersonales["Plato resto de mi vida"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[12];
    esteUsuario.preguntasPersonales["Nos llevamos bien si"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[13];
    esteUsuario.preguntasPersonales["Como eres borracho"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[14];
    esteUsuario.preguntasPersonales["Anecdotas"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[15];
    esteUsuario.preguntasPersonales["Pelicula recomendada"] =
        Usuario.esteUsuario.listaRespuestasPreguntasPersonales[16];

    usuario["Preguntas personales"] = esteUsuario.preguntasPersonales;
    usuario["Filtros usuario"] = esteUsuario.datosParaFiltrosUsuario;
    usuario["Historias"] = esteUsuario.imagenesHistorias;
  }

  Future<void> subirImagenPerfil(String IDUsuario) async {
    assert(imagenes != null);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    DocumentReference referenciaUsuario =
        databaseReference.collection("usuarios").doc(IDUsuario);
    DocumentReference referenciaHistoriasDirecto =
        databaseReference.collection("directo historias").doc(IDUsuario);

    DocumentReference referenciaValoracionesLocales = databaseReference
        .collection("usuarios")
        .doc(IDUsuario)
        .collection("valoraciones")
        .doc("mediaPuntos");
    DocumentReference referenciaEstadoLLamadas = databaseReference
        .collection("usuarios")
        .doc(IDUsuario)
        .collection("estadoLlamada")
        .doc("estadoLlamada");
    WriteBatch escrituraUsuario = databaseReference.batch();
    if (esteUsuario.fotosPerfil[0] != null) {
      String image1 = "${IDUsuario}/Perfil/imagenes/Image1.jpg";
      StorageReference ImagesReference = reference.child(image1);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[0]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL1["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.fotosPerfil[1] != null) {
      String Image2 = "${IDUsuario}/Perfil/imagenes/Image2.jpg";
      StorageReference ImagesReference = reference.child(Image2);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[1]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL2["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.fotosPerfil[2] != null) {
      String Image3 = "${IDUsuario}/Perfil/imagenes/Image3.jpg";
      StorageReference ImagesReference = reference.child(Image3);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[2]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL3["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.fotosPerfil[3] != null) {
      String Image4 = "${IDUsuario}/Perfil/imagenes/Image4.jpg";
      StorageReference ImagesReference = reference.child(Image4);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[3]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL4["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.fotosPerfil[4] != null) {
      String Image5 = "${IDUsuario}/Perfil/imagenes/Image5.jpg";
      StorageReference ImagesReference = reference.child(Image5);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[4]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL5["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.fotosPerfil[5] != null) {
      String Image6 = "${IDUsuario}/Perfil/imagenes/Image6.jpg";
      StorageReference ImagesReference = reference.child(Image6);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[5]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL6["Imagen"] = URL;
      print(URL);
    }
    await establecerUsuario().then((value) async {
      escrituraUsuario.set(referenciaUsuario, usuario);
      escrituraUsuario
          .set(referenciaEstadoLLamadas, {"Estado": "Desconectado"});
      escrituraUsuario.set(referenciaValoracionesLocales, {
        "mediaTotal": 0,
        "Valoracion": 5,
        "cantidadValoraciones": 0,
        "puntuacionTotal": 0
      });

      await escrituraUsuario.commit().catchError((onError) {
        print("Error al crear usuario: $onError");
      });
    });
  }

  Future<void> editarPerfilUsuario(String IDUsuario) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Usuario.esteUsuario.fotosPerfil =
        Usuario.esteUsuario.fotosUsuarioActualizar;
    StorageReference reference = storage.ref();
    DocumentReference referenciaUsuario =
        databaseReference.collection("usuarios").doc(IDUsuario);

    WriteBatch escrituraUsuario = databaseReference.batch();
    if (esteUsuario.fotosPerfil[0] != null) {
      String image1 = "${IDUsuario}/Perfil/imagenes/Image1.jpg";
      StorageReference ImagesReference = reference.child(image1);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[0]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL1["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.fotosPerfil[1] != null) {
      String Image2 = "${IDUsuario}/Perfil/imagenes/Image2.jpg";
      StorageReference ImagesReference = reference.child(Image2);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[1]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL2["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.fotosPerfil[2] != null) {
      String Image3 = "${IDUsuario}/Perfil/imagenes/Image3.jpg";
      StorageReference ImagesReference = reference.child(Image3);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[2]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL3["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.fotosPerfil[3] != null) {
      String Image4 = "${IDUsuario}/Perfil/imagenes/Image4.jpg";
      StorageReference ImagesReference = reference.child(Image4);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[3]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL4["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.fotosPerfil[4] != null) {
      String Image5 = "${IDUsuario}/Perfil/imagenes/Image5.jpg";
      StorageReference ImagesReference = reference.child(Image5);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[4]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL5["Imagen"] = URL;
      print(URL);
    }
    if (esteUsuario.fotosPerfil[5] != null) {
      String Image6 = "${IDUsuario}/Perfil/imagenes/Image6.jpg";
      StorageReference ImagesReference = reference.child(Image6);
      StorageUploadTask uploadTask =
          ImagesReference.putFile(esteUsuario.fotosPerfil[5]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      esteUsuario.ImageURL6["Imagen"] = URL;
      print(URL);
    }
    await establecerUsuario();

    escrituraUsuario.update(referenciaUsuario, usuario);

    await escrituraUsuario.commit().catchError((onError) {
      print("Error al actualizar  usuario: ${onError}");
    });
  }

  ///Metodo usado para subir historias del usuario, en la primera version solo permitira subir imagenes(Hasta un tottal de 6)
  ///
  ///
  ///
  ///

  static submit(BuildContext context) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    FirebaseFirestore referenciaBaseDatos = FirebaseFirestore.instance;

    StorageReference reference = storage.ref();
    DocumentSnapshot val;
    FirebaseFirestore referencia = FirebaseFirestore.instance;

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
        ControladorInicioSesion.instancia
            .iniciarSesion(esteUsuario.idUsuario, context);
      }
    });
    print("SiguientePantalla");

    // Perfiles.perfilesCitas.obtenetPerfilesCitas();
  }

  void alerta() {
    notifyListeners();
  }

  int validadorFecha() {
    DateTime fechaTemporal;

    fechaTemporal = new DateTime(anio ?? 0, mes ?? 0, dia ?? 0, 10, 10);

    print("Construyendo fechas:::::::::.   $fechaTemporal");

    int dur = DateTime.now().difference(fechaTemporal).inDays;
    int data = dur ~/ 365;
    edad = data;
    Usuario.esteUsuario.fechaNacimiento = fechaTemporal;
    print(data);
    notifyListeners();

    return 0;
  }
}
