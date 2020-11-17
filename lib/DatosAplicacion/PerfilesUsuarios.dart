import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/WrapperLikes.dart';

import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/TarjetaPerfiles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:citasnuevo/InterfazUsuario/Actividades/pantalla_Actividades_elements.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:story_view/story_view.dart';
import 'package:transparent_image/transparent_image.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'dart:io' as Io;
import 'package:path_provider/path_provider.dart';
import 'Usuario.dart';
import 'dart:isolate';

Future<DatosPerfiles> ActualizarPErfilDeterinado(
    Map<String, dynamic> lista) async {

  /// La variable [imagenesListas] vista en la seccion de carga de perfiles aqui siempre se inicia en "FALSE" ya que este es el metodo que crea los [carretes]
  /// y las imagenes aun no estan listas, la variable se hara "[true]" cuando [imagenesEnCola] y la variable [imagenesPerfilesListas] sean verdaderas
  /// mientras tanto para evitar excepciones decimos que las imagenes no estan listas
  DatosPerfiles perfilCreado;

  ///
  ///
  ///
  ///
  ///  Al llamar a este metodo se le pasa una lista de [DocumentSnapshot] la cual contiene todos los datos (de un perfil en este caso) encapsulada
  ///  entonces recorremos esa lista y cada objeto de tipo [DocumentSnapshot] es desglosado de la forma[DocumentSnapshot.data["Nombre del dato al que quiero acceder"]]
  ///  y lo guardo en una variable correspondiente a su tipo
  ///
  ///
  ///
  ///

  /// [ponerNombre], solo quiero poner en nombre del perfil en una imagen asi que la variable se hara falsa al poner el nombre en la primera imagen y asi se
  /// lo paso a[creadorImagenPerfil] para que solo lo ponga una vez
  bool ponerNombre = true;

  ///
  ///
  ///
  /// [sumarDescripcion], solo quiero la descripcion del usuario una vez, asique  sera verdadera hasta que ponga la descripcion en el [carrete]

  bool sumarDescripcion = true;

  ///
  ///
  ///
  ///
  /// [perfilTemp], como se puede observar esta variable es una lista de widgets[List<Widget>] que es justo lo que es un [carrete]
  /// asique podemos decir que es un carrete temporal el cual creamos, mas abajo muestro su uso
  List<Widget> perfilTemp = new List();

  ///
  ///
  ///
  ///
  ///
  String idUsuario = lista["Id"];
  String nombre = lista["Nombre"];
  String alias = lista["Alias"];
  String edad = (lista["Edad"]).toString();
  Map ImagenURL1 = lista["IMAGENPERFIL1"];
  Map ImagenURL2 = lista["IMAGENPERFIL2"];
  Map ImagenURL3 = lista["IMAGENPERFIL3"];
  Map ImagenURL4 = lista["IMAGENPERFIL4"];
  Map ImagenURL5 = lista["IMAGENPERFIL5"];
  Map ImagenURL6 = lista["IMAGENPERFIL5"];
  String descripcion = lista["Descripcion"];
  BloqueDescripcion1 descripcion1 = new BloqueDescripcion1(descripcion);

  /// [imagenesPerfiles] aqui almacenammos todas las imagenes de un perfil para crear cada bloque de imagen del [carrete] del perfil
  List<Map> imagenesPerfiles;
  imagenesPerfiles = [
    ImagenURL1,
    ImagenURL2,
    ImagenURL3,
    ImagenURL4,
    ImagenURL5,
    ImagenURL6
  ];

  ///
  ///
  ///
  ///
  ///
  ///
  /// en este bucle recorremos la lista de imagenes [imagenesPerfiles] y cramos las imagenes y texto del [carrete] dependiendo de si [ponerNombre] y [sumarDescripcion]
  /// son verdaderos "TRUE" o falsos "FALSE"
  for (int a = 0; a < imagenesPerfiles.length; a++) {
    if (imagenesPerfiles[a]["Imagen"] != null) {
      /// Cada Imagen que no sea nula es puesta en cola sumando una imagen a [imagenEnCola]

      ///
      ///
      ///
      ///
      ///
      /// A la lista temporal [perfilTemp]  que es un [carrete]  le añadimos los widgets necesarios
      perfilTemp.add(ImagenesCarrete(
        imagenesPerfiles[a]["Imagen"],
        nombre: nombre,
        alias: alias,
        edad: edad,
        pieFoto: imagenesPerfiles[a]["PieDeFoto"],
        nombreEnFoto: ponerNombre,
      ));
      ponerNombre = false;
      if (sumarDescripcion && descripcion != null) {
        perfilTemp.add(descripcion1);
        sumarDescripcion = false;
      }
    }
  }

  ///
  ///
  ///
  ///
  ///
  ///
  /// En [ListaPerfiles] añadimos ya el [carrete] creado [perfilTemp] y La etiqueta con sus metadatos

  List<Map<String, dynamic>> links = new List();

  perfilCreado = new DatosPerfiles.amistad(
      linksHistorias: null,
      carrete: perfilTemp,
      nombreusuaio: nombre,
      idUsuario: idUsuario);

  //print(perfilesCitas.listaPerfiles);

  print(perfilCreado);
  return perfilCreado;
}


Future<List<DatosPerfiles>> actualizarPerfilesCitas(
    List<Map<String, dynamic>> lista) async {
  List<DatosPerfiles> perfilCreado = new List();

  /// La variable [imagenesListas] vista en la seccion de carga de perfiles aqui siempre se inicia en "FALSE" ya que este es el metodo que crea los [carretes]
  /// y las imagenes aun no estan listas, la variable se hara "TRUE" cuando [imagenesEnCola] y la variable [imagenesPerfilesListas] sean verdaderas
  /// mientras tanto para evitar excepciones decimos que las imagenes no estan listas
  Perfiles.perfilesCitas.imagenesListas = false;

  ///
  ///
  ///
  ///
  ///  Al llamar a este metodo se le pasa una lista de [DocumentSnapshot] la cual contiene todos los datos (de un perfil en este caso) encapsulada
  ///  entonces recorremos esa lista y cada objeto de tipo [DocumentSnapshot] es desglosado de la forma[DocumentSnapshot.data["Nombre del dato al que quiero acceder"]]
  ///  y lo guardo en una variable correspondiente a su tipo
  ///
  ///
  ///
  ///

  for (int i = 0; i < lista.length; i++) {
    List<Map<String, dynamic>> listapreguntasPersonales = new List();
    List<Map<String, dynamic>> listaFiltrosPersonales = new List();
    bool ponerFiltros = true;

    /// [ponerNombre], solo quiero poner en nombre del perfil en una imagen asi que la variable se hara falsa al poner el nombre en la primera imagen y asi se
    /// lo paso a[creadorImagenPerfil] para que solo lo ponga una vez
    bool ponerNombre = true;

    ///
    ///
    ///
    /// [sumarDescripcion], solo quiero la descripcion del usuario una vez, asique  sera verdadera hasta que ponga la descripcion en el [carrete]

    bool sumarDescripcion = true;

    ///
    ///
    ///
    ///
    /// [perfilTemp], como se puede observar esta variable es una lista de widgets[List<Widget>] que es justo lo que es un [carrete]
    /// asique podemos decir que es un carrete temporal el cual creamos, mas abajo muestro su uso
    List<Widget> perfilTemp = new List();

    ///
    ///
    ///
    ///
    ///
    String idUsuario = lista[i]["Id"];
    String nombre = lista[i]["Nombre"];
    String alias = lista[i]["Alias"];
    String edad = (lista[i]["Edad"]).toString();
  
  double distancia=lista[i]["distancia"];
  
    Map imagenURL1 = lista[i]["IMAGENPERFIL1"];
    Map imagenURL2 = lista[i]["IMAGENPERFIL2"];
    Map imagenURL3 = lista[i]["IMAGENPERFIL3"];
    Map imagenURL4 = lista[i]["IMAGENPERFIL4"];
    Map imagenURL5 = lista[i]["IMAGENPERFIL5"];
    Map imagenURL6 = lista[i]["IMAGENPERFIL5"];
    String descripcion = lista[i]["Descripcion"];
    Map<String, dynamic> flitrosUsuario = lista[i]["Filtros usuario"];
    Map<String, dynamic> preguntasPersonales = lista[i]["Preguntas personales"];
    

    if (flitrosUsuario != null) {
      flitrosUsuario.forEach((key, value) {
        Map<String, dynamic> filtroIndividual = new Map();
        if (value != null) {
          filtroIndividual["Filtro"] = key;
          filtroIndividual["Valor"] = value;
          listaFiltrosPersonales.add(filtroIndividual);
        }
      });
    }
    if (preguntasPersonales != null) {
      preguntasPersonales.forEach((key, value) {
        Map<String, dynamic> preguntaPersonal = new Map();
        if (value != null) {
          preguntaPersonal["Pregunta"] = key;
          preguntaPersonal["Respuesta"] = value;
          listapreguntasPersonales.add(preguntaPersonal);
        }
      });
    }
    BloqueDescripcion1 descripcion1 = new BloqueDescripcion1(descripcion);

    /// [imagenesPerfiles] aqui almacenammos todas las imagenes de un perfil para crear cada bloque de imagen del [carrete] del perfil
    List<Map> imagenesPerfiles;
    imagenesPerfiles = [
      imagenURL1,
      imagenURL2,
      imagenURL3,
      imagenURL4,
      imagenURL5,
      imagenURL6
    ];

    ///
    ///
    ///
    ///
    ///
    ///
    /// en este bucle recorremos la lista de imagenes [imagenesPerfiles] y cramos las imagenes y texto del [carrete] dependiendo de si [ponerNombre] y [sumarDescripcion]
    /// son verdaderos "TRUE" o falsos "FALSE"
    for (int a = 0; a < imagenesPerfiles.length; a++) {
      if (imagenesPerfiles[a]["Imagen"] != null) {
        /// Cada Imagen que no sea nula es puesta en cola sumando una imagen a [imagenEnCola]
        Perfiles.perfilesCitas.imagenesEnCola += 1;

        ///
        ///
        ///
        ///
        ///
        /// A la lista temporal [perfilTemp]  que es un [carrete]  le añadimos los widgets necesarios

        print(PerfilesGenteCitas.limitesParaCreador);
        perfilTemp.add(ImagenesCarrete(
imagenesPerfiles[a]["Imagen"],


          distancia:distancia,
        
          nombre: nombre,
          
          alias: alias,
          edad: edad,
          pieFoto: imagenesPerfiles[a]["PieDeFoto"],
          nombreEnFoto: ponerNombre,
        ));
        ponerNombre = false;
        if (sumarDescripcion && descripcion != null) {
          perfilTemp.add(descripcion1);
          sumarDescripcion = false;
        }
      }
      if (listaFiltrosPersonales.length > 0 && ponerFiltros) {
        perfilTemp
            .add(BloqueFiltrosPersonales(filtroValor: listaFiltrosPersonales));
        ponerFiltros = false;
      }
      if (listapreguntasPersonales.length > 0) {
        perfilTemp.add(BloquePreguntasPersonales(
            preguntaRespuesta: listapreguntasPersonales[0]));
        listapreguntasPersonales.removeAt(0);
      }
    }

    ///
    ///
    ///
    ///
    ///
    ///
    /// En [ListaPerfiles] añadimos ya el [carrete] creado [perfilTemp] y La etiqueta con sus metadatos
    List<Map<String, dynamic>> links = new List();
    if (lista[i]["historias"] != null) {
      Map<String, dynamic> historias = lista[i]["historias"];

      links.add(historias);

      perfilCreado.add(DatosPerfiles.citas(
          linksHistorias: links,
          carrete: perfilTemp,
          valoracion: 5.0,
          nombreusuaio: nombre,
          idUsuario: idUsuario));
    } else {
      perfilCreado.add(DatosPerfiles.citas(
          linksHistorias: links,
          carrete: perfilTemp,
          valoracion: 5.0,
          nombreusuaio: nombre,
          idUsuario: idUsuario));
    }

    //print(perfilesCitas.listaPerfiles);
  }
  return perfilCreado;
}

class Perfiles extends ChangeNotifier {
  static void cargarPerfilesCitas(List<Map<String, dynamic>> listaProvisional) {
    Perfiles.perfilesCitas.cargarIsolate(listaProvisional);
  }

  static void cargarPerfilesAmistad() {}

  /// [cargarIsolate]
  ///
  /// Aqui cargamos el isolado de citas, primero, aun estando en el isolado principal hacemos una peticion de datos a firestore
  ///
  ///
  ///
  ///

  Future cargarIsolate(List<Map<String, dynamic>> listaDatoos) async {
    ///Aqui aun estando en el isolado principal le hacemos una peticion a firebase parque nos de los datos necesarios atraves del metodo [obtenerPerfilesCitas]
    ///

    List<Map<String, dynamic>> listaProvisional =
       listaDatoos;
    ReceivePort puertoRecepcion = ReceivePort();
    WidgetsFlutterBinding.ensureInitialized();

    ///
    ///
    ///
    ///Luego de recibir datos de [obtenerPerfilesCitas]
    ///creamos el nuevo[isolate] al cual pasamos el nombre del metodo que queremos ejecutar en el isolado y le mandamos el puerto de envio de el [isolate] principal
    ///ya que sera ese nuestro puerto de comunicacion
    ///
    ///
    Isolate proceso = await Isolate.spawn(
        isolateCitas, puertoRecepcion.sendPort,
        debugName: "IsolateCitas");

    /// [puertoEnvio] aqui almacenamos la respuesta que obtenemos de  [isolateCitas] de donde recibimos el puerto de envio del [isolate]
    ///
    ///
    SendPort puertoEnvio = await puertoRecepcion.first;

    ///
    ///[enviarRecibirCitas], aqui enviamos los datos obtenidos del metodo [obtenerPerfilesCitas] y tambien pasamos [puertoEnvio] del [isolate]
    ///
    Perfiles.perfilesCitas.listaPerfiles = await enviarRecibirCitas(
        Usuario.esteUsuario, puertoEnvio, listaProvisional);

    /// Aqui acabamos con el isolate despues de que el [await] nos devuelva los datos pedidos del otro [isolate]
    proceso.kill();
    Usuario.esteUsuario.notifyListeners();
  }

  Future<dynamic> enviarRecibirCitas(Usuario user, SendPort puertos,
      List<Map<String, dynamic>> listaPerfiles) async {
    ///[puertoRespuestaIntermedio] es lo que devolve mos al [isolate] principal cuando el [isolate] ha terminado de resolver el problema
    ///
    ///
    ReceivePort puertoRespuestaIntermedio = ReceivePort();

    ///Aqui se envia el [puetoRespuestaIntermedio] al isolado secundario para que sepa donde responder al acabar su opeeracion
    ///
    ///
    puertos.send(
        [user.DatosUsuario, puertoRespuestaIntermedio.sendPort, listaPerfiles]);

    /// devolvemos la primera respuesta recibida por el[puertoRespuestaIntermedio] que va a ser la lista sde perfiles al [isolate] principal
    return puertoRespuestaIntermedio.first;
  }

  static isolateCitas(SendPort puertoEnvio) async {
    ///[perfilesCitas] guardará los datos recibidos de[ActualiizarEventosCitas()]
    ///
    ///
    List<DatosPerfiles> perfilesCita;

    ///[puertoRespuesta] es el puesrto de comunicacion con el isolado principal
    ///
    ///
    ReceivePort puertoRespuesta = ReceivePort();

    ///
    ///
    ///[puertoEnvio] variable recibida de el Isolado principal, a traves de él enviamos como respuesta [puertoRespuesta.sendPort] nuestro puerto de envio
    ///para que se sepa donde enviar y como comunicarse con el isolate
    ///
    puertoEnvio.send(puertoRespuesta.sendPort);

    ///
    ///al haber enviado nuestro puerto de datos aqui esperamos a que reciba algo para procesar sus datos ya en el isolate objetivo y ejecutar el metodo deseado sin
    ///interrumpir el main isolate
    await for (var msj in puertoRespuesta) {
      Map datoUsuario = msj[0];
      SendPort sendPort = msj[1];
      List<Map<String, dynamic>> lista = msj[2];

      perfilesCita = await actualizarPerfilesCitas(lista);
      sendPort.send(perfilesCita);
    }
  }

  static Future<DatosPerfiles> cargarIsolatePerfilDeterminado(
      String idPerfil) async {
    DatosPerfiles perfil;

    ///Aqui aun estando en el isolado principal le hacemos una peticion a firebase parque nos de los datos necesarios atraves del metodo [obtenerPerfilesAmistad]
    ///
    Map<String, dynamic> listaProvisional =
        await obtenerPerfilUsuarioDeterminado(idPerfil);
    ReceivePort puertoRecepcion = ReceivePort();
    WidgetsFlutterBinding.ensureInitialized();

    ///
    ///
    ///
    ///Luego de recibir datos de [obtenerPerfilesAmistad]
    ///creamos el nuevo[isolate] al cual pasamos el nombre del metodo que queremos ejecutar en el isolado y le mandamos el puerto de envio de el [isolate] principal
    ///ya que sera ese nuestro puerto de comunicacion
    ///
    ///
    Isolate proceso = await Isolate.spawn(
        isolatePerfilDetermiando, puertoRecepcion.sendPort,
        debugName: "IsolatePerfilDeterminado");

    /// [puertoEnvio] aqui almacenamos la respuesta que obtenemos de  [isolatePerfilDeterminado] de donde recibimos el puerto de envio del [isolate]
    ///
    ///
    SendPort puertoEnvio = await puertoRecepcion.first;

    ///
    ///[enviarRecibirCitas], aqui enviamos los datos obtenidos del metodo [obtenerPErfilesAmistad] y tambien pasamos [puertoEnvio] del [isolate]
    ///
    perfil = await enviarRebirPerfilDeterminado(
        Usuario.esteUsuario, puertoEnvio, listaProvisional);

    /// Aqui acabamos con el isolate despues de que el [await] nos devuelva los datos pedidos del otro [isolate]
    ///
    ///
    proceso.kill();

    return perfil;
  }

  static Future<dynamic> enviarRebirPerfilDeterminado(Usuario user,
      SendPort puertos, Map<String, dynamic> listaPerfiles) async {
    ReceivePort puertoRespuestaIntermedio = ReceivePort();

    ///[puertoRespuestaIntermedio] es lo que devolve mos al [isolate] principal cuando el [isolate] ha terminado de resolver el problema
    ///
    ///
    puertos.send(
        [user.DatosUsuario, puertoRespuestaIntermedio.sendPort, listaPerfiles]);

    /// devolvemos la primera respuesta recibida por el[puertoRespuestaIntermedio] que va a ser la lista sde perfiles al [isolate] principal
    ///
    ///
    return puertoRespuestaIntermedio.first;
  }

  static isolatePerfilDetermiando(SendPort puertoEnvio) async {
    ///[perfilesCitas] guardará los datos recibidos de [ActualizarPerfilDetermado()]
    ///
    ///
    DatosPerfiles perfilesCita;

    ///[puertoRespuesta] es el puesrto de comunicacion con el isolado principal
    ///
    ///
    ReceivePort puertoRespuesta = ReceivePort();

    ///
    ///
    ///[puertoEnvio] variable recibida de el Isolado principal, a traves de él enviamos como respuesta [puertoRespuesta.sendPort] nuestro puerto de envio
    ///para que se sepa donde enviar y como comunicarse con el isolate
    ///
    puertoEnvio.send(puertoRespuesta.sendPort);

    ///
    ///al haber enviado nuestro puerto de datos aqui esperamos a que reciba algo para procesar sus datos ya en el isolate objetivo y ejecutar el metodo deseado sin
    ///interrumpir el main isolate
    await for (var msj in puertoRespuesta) {
      Map datoUsuario = msj[0];
      SendPort sendPort = msj[1];
      Map<String, dynamic> lista = msj[2];

      perfilesCita = await ActualizarPErfilDeterinado(lista);
      sendPort.send(perfilesCita);
    }
  }

  ///************************************************************
  ///Aqui se crean objetos estaticos de tipo [Perfiles] dentro de los cuales cada uno en su [_listaPerfiles] almacenara
  ///un tipo de perfil, por ejemplo dentro de [perfilesCitas]almacenaremos y se procesaran todos los perfiles que encajen
  ///con lo seleccionado por el usuario

  static Perfiles perfilesCitas = new Perfiles();

 
  ///************************************************************
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  /// **********Instancia a firestore*************
  /// El objeto [baseDatosRef]nos da la posibilidad de crear un objeto que luego nos serviria para acceder a Firestore
  static FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;

  ///
  ///
  ///
  ///
  ///
  ///
  /// **********Carga de imagenes en Perfiles********
  /// Al crear los objetos perfiels las imagenes son muy importantes, es inadmisible crear la lista de  [Widget] que mostraria las imagenes
  /// sin asegurarse de que estan todas cargadas ya que daria una excepcion
  ///Por eso tenemos la variable [imagenesEnCola] que son las imagenes confirmadas descargadas de la base de datos pero que aun no han sido procesadas
  ///Luego tenemos la variable[imagenesPerfilesListas] la cual indica las imagenes de perfiles que ya estan listas para ser mostradas
  ///Por ultimo tenemos la variable [imagenesListas] que devolveria "TRUE" si la cantidad de imagenes listas [imagenesPerfilesListas]es igual a la cantidad de
  ///imagenes descargadas y en espera a ser procesadas [imagenesEnCola]
  int imagenesPerfilesListas = 0;
  int imagenesEnCola = 0;
  bool imagenesListas = false;
  void mostrarImagenes() {
    imagenesListas = true;
    notifyListeners();
  }

  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  /// ***************Almacenamiento de perfiles listos***************************+
  /// Aqui tenemos la variable [listaPerfiles] que es una variable de tipo [DatosPerfiles], Este tipo de dato almacena la lista de Widgets[carrete] que consiste en
  /// imagenes y contenedores de texto y una "ETIQUETA" asociada a cada [carrete] que contiene datos que serian necesarios para "CALIFICAR" los perfiles que le gusten
  /// al usuario como el nombre del perfil ue califica, la puntuacion que le asigna[EN CASO DE CITAS]

  List<DatosPerfiles> _listaPerfiles;

  List<DatosPerfiles> get listaPerfiles => _listaPerfiles;

  set listaPerfiles(List<DatosPerfiles> value) {
    _listaPerfiles = value;
    notifyListeners();
  }

  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///*************************************************************************************
  ///*************************************************************************************
  ///
  ///
  /// EN ESTA PARTE ES DONDE NOS CONECTAMOS A LA BASE DE DATOS PARA ADQUIRIR LOS PERFILES
  ///
  /// 1 PASO: Obtenemos los perfiles mediante los metodos [obtenerPerfilesCitas] el cual se encarga de buscar perfiles que puedan ser una potencial
  /// cita para el usuario.Y tambien el metodo [obtenerPerfilesAmistad] el cual se encarga de adquirir todos los perfiles para mostrar en la pestaña amistad
  Future<List<Map<String, dynamic>>> obtenetPerfilesCitas(Map usuario) async {
    print("dentro de isolado");
    FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
    print("dentro de isolado");
    String tendriaCitasCon;
    List<DocumentSnapshot> perfiles;
    DatosPerfiles perfilTemporal;
    String sexoUsuario;

    List<Map<String, dynamic>> perfilesTemp = new List();
    // List<DocumentSnapshot> perfiles = new List();
    QuerySnapshot Temp;
    tendriaCitasCon = usuario["Citas con"];
    sexoUsuario = usuario["Sexo"];

    if (tendriaCitasCon == "HombreGay" || tendriaCitasCon == "MujerGay") {
      Temp = await baseDatosRef
          .collection("usuarios")
          .where("Citas con", isEqualTo: tendriaCitasCon)
          .get();
      for (DocumentSnapshot elemento in Temp.docs) {
        Map<String, dynamic> usuarios = new Map();
        usuarios = elemento.data();
        perfilesTemp.add(usuarios);
      }
    }

    ///***********************************************************************************//
    /// Mujer que tendria citas con hombres busca usuarios que tendrian citas con mujeres///
    ///**********************************************************************************//

    if (tendriaCitasCon == "Hombre") {
      print("Citas con mujer");
      Temp = await baseDatosRef
          .collection("usuarios")
          .where("Citas con", isEqualTo: "Mujer")
          .get();
      for (DocumentSnapshot elemento in Temp.docs) {
        Map<String, dynamic> usuarios = new Map();
        usuarios = elemento.data();
        perfilesTemp.add(usuarios);
      }
    }

    ///***********************************************************************************//
    /// Hombre que tendria citas con mujeres busca usuarios que tendrian citas con hombres///
    ///**********************************************************************************//
    if (tendriaCitasCon == "Mujer") {
      Temp = await baseDatosRef
          .collection("usuarios")
          .where("Citas con", isGreaterThanOrEqualTo: "Hombre")
          .get();
      for (DocumentSnapshot elemento in Temp.docs) {
        Map<String, dynamic> usuarios = new Map();
        usuarios = elemento.data();
        perfilesTemp.add(usuarios);
      }
    }
    if (tendriaCitasCon == "Ambos") {
      Temp = await baseDatosRef
          .collection("usuarios")
          .where("Citas con", isEqualTo: tendriaCitasCon)
          .get();
      for (DocumentSnapshot elemento in Temp.docs) {
        Map<String, dynamic> usuarios = new Map();
        usuarios = elemento.data();
        perfilesTemp.add(usuarios);
      }
    }
 

    return perfilesTemp;
  }

  static Future<Map<String, dynamic>> obtenerPerfilUsuarioDeterminado(
      String usuario) async {
    Map<String, dynamic> perfilTemporal = new Map();
    FirebaseFirestore baseDatos = FirebaseFirestore.instance;
    await baseDatos
        .collection("usuarios")
        .doc(usuario)
        .get()
        .then((value) => perfilTemporal = value.data());

    return perfilTemporal;
  }

  ///Ambos metodos crean una lista de [DocumentSnapshot], donde cada [DocumentSnapshot] es un [Map] Mapa que contiene los campos y datos necesarios
  ///para en este caso crear perfiles y mostrarselos al usuario
  ///
  ///
  ///
  /// 2 PASO: Una vez obtenidos todos los datos de los perfiles, ya que estos aun estan "en bruto" o sin procesar, el metodo [ActualizarEventosCitas] es el encarga
  /// de desglosar cada [DocumentSnapshot], acceder a sus campos, leer los datos y construir partes de el [carrete], usando [creadorImagenPerfil] y [BloqueDescripcion1]
  ///
  ///
  ///
  ///

}

// ignore: must_be_immutable


class ManejoCache {
  String url;
  ManejoCache(this.url);
  Future<String> accederDirectorioLocal() async {
    final directorio = await getApplicationDocumentsDirectory();
    return directorio.path;
  }

  Future<Uint8List> obtenerImagenRed() async {
    Uint8List archivo = await networkImageToByte(url);
    return archivo;
  }

  Future<Io.File> guardarEnCache() async {
    final directorio = await accederDirectorioLocal();
    String referenciaCompleta =
        "$directorio/${DateTime.now().toUtc().toIso8601String()}.jpg";
    Io.File puntero = new Io.File(referenciaCompleta);
    Uint8List archivo = await obtenerImagenRed();
    puntero.writeAsBytesSync(archivo);
    return puntero;
  }

  Future<Uint8List> recuperarImagen() async {
    Io.File puntero = await guardarEnCache();
    Uint8List imagen = puntero.readAsBytesSync();
    return imagen;
  }
}

