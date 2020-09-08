import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:citasnuevo/InterfazUsuario/Actividades/pantalla_actividades_elements.dart';

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
      perfilTemp.add(creadorImagenPerfilAmistad(
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

Future<List<DatosPerfiles>> actualizarPerfilesAmigos(
    List<Map<String, dynamic>> lista) async {
  /// La variable [imagenesListas] vista en la seccion de carga de perfiles aqui siempre se inicia en "FALSE" ya que este es el metodo que crea los [carretes]
  /// y las imagenes aun no estan listas, la variable se hara "[true]" cuando [imagenesEnCola] y la variable [imagenesPerfilesListas] sean verdaderas
  /// mientras tanto para evitar excepciones decimos que las imagenes no estan listas
  List<DatosPerfiles> perfilCreado = new List();

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
    Map ImagenURL1 = lista[i]["IMAGENPERFIL1"];
    Map ImagenURL2 = lista[i]["IMAGENPERFIL2"];
    Map ImagenURL3 = lista[i]["IMAGENPERFIL3"];
    Map ImagenURL4 = lista[i]["IMAGENPERFIL4"];
    Map ImagenURL5 = lista[i]["IMAGENPERFIL5"];
    Map ImagenURL6 = lista[i]["IMAGENPERFIL5"];
    String descripcion = lista[i]["Descripcion"];
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
        perfilTemp.add(creadorImagenPerfilAmistad(
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

    if (lista[i]["historias"] != null) {
      Map<String, dynamic> historias = lista[i]["historias"];

      perfilCreado.add(DatosPerfiles.amistad(
          linksHistorias: links,
          carrete: perfilTemp,
          nombreusuaio: nombre,
          idUsuario: idUsuario));
    } else {
      perfilCreado.add(DatosPerfiles.amistad(
          linksHistorias: links,
          carrete: perfilTemp,
          nombreusuaio: nombre,
          idUsuario: idUsuario));
    }

    //print(perfilesCitas.listaPerfiles);

    print(perfilCreado);
    return perfilCreado;
  }
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
  static void cargarPerfilesCitas() {
    Perfiles.perfilesCitas.cargarIsolate();
  }

  static void cargarPerfilesAmistad() {
  
  }

  /// [cargarIsolate]
  ///
  /// Aqui cargamos el isolado de citas, primero, aun estando en el isolado principal hacemos una peticion de datos a firestore
  ///
  ///
  ///
  ///

  Future cargarIsolate() async {
    ///Aqui aun estando en el isolado principal le hacemos una peticion a firebase parque nos de los datos necesarios atraves del metodo [obtenerPerfilesCitas]
    ///

    List<Map<String, dynamic>> listaProvisional =
        await obtenetPerfilesCitas(Usuario.esteUsuario.DatosUsuario);
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

  ///Aqui aparece el objeto estatico[perfilesAmistad] el cual dentro de su variable[_listaPerfiles]almacenara todos los perfiles
  ///que hayan elegido "Amistad" o "Ambos" en la creacion de su perfil sin importar el sexo de los perfiles ya que el unico requisito
  ///sera que haya elegido poder recibir solicitudes de amigos
  static Perfiles perfilesAmistad = new Perfiles();

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
          .where("Citas con", isEqualTo: "Hombre")
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
    for (int i = 0; i < perfilesTemp.length; i++) {
      await baseDatosRef
          .collection("usuarios")
          .doc(perfilesTemp[i]["Id"])
          .collection("historias")
          .doc("Historias")
          .get()
          .then((value) {
        if (value.data != null) {
          //     print(value.data);
          Map<String, dynamic> historias = value.data();

          perfilesTemp[i].putIfAbsent("historias", () => historias);
        }
      });
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
    await baseDatosRef
        .collection("usuarios")
        .doc(usuario)
        .collection("historias")
        .get()
        .then((value) {
      if (value != null) {
        perfilTemporal.putIfAbsent("Lista historias", () => value.docs);
      }
    });
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
class ImagenesCarrete extends StatefulWidget {
  String urlImagen;
  String nombre;
  String alias;
  String edad;
  String pieFoto;
  bool nombreEnFoto;
  Image laimagen;
  bool imagenCargada = false;

  ImagenesCarrete(this.urlImagen,
      {this.nombre, this.alias, this.edad, this.pieFoto, this.nombreEnFoto}) {
    //cargarImagen();
  }

  @override
  _ImagenesCarreteState createState() => _ImagenesCarreteState();
}

class _ImagenesCarreteState extends State<ImagenesCarrete> {
  Uint8List bitsImagen;
  initState() {
    super.initState();
    widget.laimagen = Image.network(widget.urlImagen);
  }

  void didChangeDependencies() {
    precacheImage(widget.laimagen.image, context)
        .catchError((error) => print(error));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        print("object");
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return VisorImagenesPerfiles(imagen: widget.urlImagen);
        }));
      },
      child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 0),
          child: Container(
            child: Column(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: <Widget>[
                        widget.nombreEnFoto
                            ? Container(
                                height: PerfilesGenteCitas
                                    .limitesParaCreador.biggest.height,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(widget.urlImagen),
                                        fit: BoxFit.cover)),
                              )
                            : CachedNetworkImage(
                                imageUrl: widget.urlImagen,
                              ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0, bottom: 0),
                          child: Container(
                                decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(1.5)),
                                            color: Color.fromRGBO(0, 0, 0, 80)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  widget.nombreEnFoto
                                      ? Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Text("${widget.nombre}, ${widget.edad}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    ScreenUtil().setSp(40))),
                                      )
                                      : Container(),
                        
                                  widget.nombreEnFoto
                                      ? Padding(
                                        padding: const EdgeInsets.all(2.5),
                                        child: Text("A 8 Km de ti",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    ScreenUtil().setSp(40))),
                                      )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Container(
                  child:
                      widget.pieFoto == null ? Text("") : Text(widget.pieFoto),
                )
              ],
            ),
          )),
    );
  }
}

// ignore: must_be_immutable
class VisorImagenesPerfiles extends StatelessWidget {
  String imagen;
  VisorImagenesPerfiles({@required this.imagen});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: LayoutBuilder(builder: (
          BuildContext context,
          BoxConstraints limites,
        ) {
          return Container(
            height: limites.biggest.height,
            width: limites.biggest.width,
            color: Colors.black,
            child: Image.network(imagen),
          );
        }));
  }
}

class creadorImagenPerfilAmistad extends StatefulWidget {
  String urlImagen;
  String nombre;
  String alias;
  String edad;
  String pieFoto;
  bool nombreEnFoto;
  Image laimagen;
  bool imagenCargada = false;

  creadorImagenPerfilAmistad(this.urlImagen,
      {this.nombre, this.alias, this.edad, this.pieFoto, this.nombreEnFoto}) {
    //cargarImagen();
  }

  @override
  _creadorImagenPerfilAmistadState createState() =>
      _creadorImagenPerfilAmistadState();
}

class _creadorImagenPerfilAmistadState
    extends State<creadorImagenPerfilAmistad> {
  Uint8List bitsImagen;
  initState() {
    super.initState();
    widget.laimagen = Image.network(widget.urlImagen);
  }

  void didChangeDependencies() {
    precacheImage(widget.laimagen.image, context)
        .catchError((onError) => print(onError));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Container(
          child: Column(
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: Stack(
                    alignment: AlignmentDirectional.bottomStart,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: widget.urlImagen,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            widget.nombreEnFoto
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(1.5)),
                                        color: Color.fromRGBO(0, 0, 0, 100)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(widget.nombre,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  ScreenUtil().setSp(60))),
                                    ),
                                  )
                                : Container(),
                            widget.nombreEnFoto
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(1.5)),
                                        color: Color.fromRGBO(0, 0, 0, 100)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.5),
                                      child: Text("@${widget.alias}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  ScreenUtil().setSp(60))),
                                    ),
                                  )
                                : Container(),
                            widget.nombreEnFoto
                                ? Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(1.5)),
                                        color: Color.fromRGBO(0, 0, 0, 100)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.5),
                                      child: Text("A 8 Km de ti",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  ScreenUtil().setSp(60))),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  )),
              Container(
                child: widget.pieFoto == null ? Text("") : Text(widget.pieFoto),
              )
            ],
          ),
        ));
  }
}

class BloqueDescripcion1 extends StatelessWidget {
  String descripcionPerfil;

  BloqueDescripcion1(this.descripcionPerfil) {
    if (descripcionPerfil == null) {
      descripcionPerfil = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sobre mi:",
              style: TextStyle(color: Colors.black),
            ),
            Divider(
              height: ScreenUtil().setHeight(100),
              color: Colors.transparent,
            ),
            Text(
              descripcionPerfil,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class BloquePreguntasPersonales extends StatelessWidget {
  Map<String, dynamic> preguntaRespuesta;

  BloquePreguntasPersonales({@required this.preguntaRespuesta}) {}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              this.preguntaRespuesta["Pregunta"].toString(),
              style: TextStyle(color: Colors.black),
            ),
            Divider(
              height: ScreenUtil().setHeight(100),
              color: Colors.transparent,
            ),
            Text(
              this.preguntaRespuesta["Respuesta"].toString(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: ScreenUtil().setSp(60),
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

class BloqueFiltrosPersonales extends StatelessWidget {
  List<Map<String, dynamic>> filtroValor;
  List<Widget> filtrosCreados = new List();
  bool altura = false;
  bool busco = false;
  bool complexion = false;
  bool hijos = false;
  bool mascotas = false;
  bool politica = false;
  bool queVivaCon = false;
  String valorAltura;
  String valorBusco;
  String valorComplexion;
  String valorHijos;
  String valorMascotas;
  String valorPolitica;
  String valorQueVivaCon;

  BloqueFiltrosPersonales({@required this.filtroValor}) {
    for (Map filtros in filtroValor) {
      Icon simbolo = Icon(Icons.home);
      if (filtros["Filtro"] == "Altura") {
        simbolo = Icon(
          LineAwesomeIcons.ruler_vertical,
          size: 50,
        );
        altura=true;
        valorAltura=filtros["Valor"].toString();
      }
      if (filtros["Filtro"] == "Busco") {
        simbolo = Icon(LineAwesomeIcons.ring);
        valorBusco=filtros["Valor"];
        busco=true;
      }
      if (filtros["Filtro"] == "Complexion") {
        simbolo = Icon(LineAwesomeIcons.snowboarding);
         valorComplexion=filtros["Valor"];
         complexion=true;
      }
      if (filtros["Filtro"] == "Hijos") {
        simbolo = Icon(LineAwesomeIcons.baby);
         valorHijos=filtros["Valor"];
         hijos=true;
      }
      if (filtros["Filtro"] == "Mascotas") {
        simbolo = Icon(LineAwesomeIcons.dog);
         valorMascotas=filtros["Valor"];
         mascotas=true;
         
      }
      if (filtros["Filtro"] == "Politca") {
        simbolo = Icon(LineAwesomeIcons.landmark);
         valorPolitica=filtros["Valor"];
         politica=true;
      }
      if (filtros["Filtro"] == "Que viva con") {
        simbolo = Icon(LineAwesomeIcons.home);
        valorQueVivaCon=filtros["Valor"];
        queVivaCon=true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: ScreenUtil().setHeight(600),
      width: PerfilesGenteCitas.limitesParaCreador.biggest.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: ScreenUtil().setWidth(10),
              mainAxisSpacing: ScreenUtil().setHeight(10),
              childAspectRatio: 5 / 1.5,
              crossAxisCount: 3,
              children: [
               altura? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Icon(LineAwesomeIcons.ruler_vertical,size: ScreenUtil().setSp(40),),
                        Text(
                          valorAltura,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    ),
                  ),
                ):Container(
                  color:Colors.red
                ),
               busco? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Icon(LineAwesomeIcons.ring,size: ScreenUtil().setSp(40),),
                        Text(
                          valorBusco,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    ),
                  ),
                ):Container(
                  color:Colors.red
                ),
                 complexion? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Icon(LineAwesomeIcons.dumbbell,size: ScreenUtil().setSp(40),),
                        Text(
                          valorComplexion,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    ),
                  ),
                ):Container(
                  color:Colors.red
                ),
                 hijos? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Icon(LineAwesomeIcons.ring,size: ScreenUtil().setSp(40),),
                        Text(
                          valorHijos,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    ),
                  ),
                ):Container(
                  color:Colors.red
                ),
                 mascotas? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Icon(LineAwesomeIcons.dog,size: ScreenUtil().setSp(40),),
                        Text(
                          valorMascotas,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    ),
                  ),
                ):Container(
                  color:Colors.red
                ),
                 politica? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Icon(LineAwesomeIcons.landmark,size: ScreenUtil().setSp(40),),
                        Text(
                          valorPolitica,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    ),
                  ),
                ):Container(
                  color:Colors.red
                ),
                queVivaCon? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Icon(LineAwesomeIcons.home,size: ScreenUtil().setSp(40),),
                        Text(
                          valorQueVivaCon,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    ),
                  ),
                ):Container(
                  color:Colors.red
                ),
                

              ]),
              
        ),
      ),
    );
  }
}

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

class DatosPerfiles {
  static String nombreUsuarioLocal = Usuario.esteUsuario.nombre;
  static String aliasUsuarioLocal = Usuario.esteUsuario.alias;
  static String idUsuarioLocal = Usuario.esteUsuario.idUsuario;

  String nombreusuaio;
  String mensaje;
  String idUsuario;
  bool imagenAdquirida;
  String imagen;
  double valoracion;
  List<Widget> carrete = new List();

  List<Map<String, dynamic>> linksHistorias = new List();
  Firestore baseDatosRef;
  Map<String, dynamic> datosValoracion = new Map();
  String crearCodigo() {
    List<String> letras = [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    ];
    List<String> numero = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
    var random = Random();
    int primeraLetra = random.nextInt(26);
    String codigo_final = letras[primeraLetra];

    for (int i = 0; i <= 20; i++) {
      int selector_aleatorio_num_letra = random.nextInt(20);
      int aleatorio_letra = random.nextInt(27);
      int aleatorio_numero = random.nextInt(9);
      if (selector_aleatorio_num_letra <= 2) {
        selector_aleatorio_num_letra = 2;
      }
      if (selector_aleatorio_num_letra % 2 == 0) {
        codigo_final = "${codigo_final}${(numero[aleatorio_numero])}";
      }
      if (aleatorio_letra % 3 == 0) {
        int mayuscula = random.nextInt(9);
        if (selector_aleatorio_num_letra <= 2) {
          int suerte = random.nextInt(2);
          suerte == 0
              ? selector_aleatorio_num_letra = 3
              : selector_aleatorio_num_letra = 2;
        }
        if (mayuscula % 2 == 0) {
          codigo_final =
              "${codigo_final}${(letras[aleatorio_letra]).toUpperCase()}";
        }
        if (mayuscula % 3 == 0) {
          codigo_final =
              "${codigo_final}${(letras[aleatorio_letra]).toLowerCase()}";
        }
      }
    }
    return codigo_final;
  }

  void crearDatosValoracion() {
    imagenAdquirida = false;
    if (Usuario.esteUsuario.ImageURL1["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL1["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL2["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL2["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL3["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL3["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL4["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL4["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL5["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL5["Imagen"];
      imagenAdquirida = true;
    }
    if (Usuario.esteUsuario.ImageURL6["Imagen"] != null &&
        imagenAdquirida == false) {
      imagen = Usuario.esteUsuario.ImageURL6["Imagen"];
      imagenAdquirida = true;
    }
    datosValoracion["Imagen Usuario"] = imagen;
    datosValoracion["Nombre emisor"] = nombreUsuarioLocal;
    datosValoracion["Alias Emisor"] = aliasUsuarioLocal;
    datosValoracion["Id emisor"] = idUsuarioLocal;
    datosValoracion["Valoracion"] = valoracion;
    datosValoracion["Mensaje"] = this.mensaje;
    datosValoracion["Time"] = DateTime.now();
    datosValoracion["idDestino"]=idUsuario;
    datosValoracion["id valoracion"] = crearCodigo();
    _enviarValoracion();
  }

  DatosPerfiles();
  DatosPerfiles.citas(
      {@required this.carrete,
      @required this.linksHistorias,
      @required this.valoracion,
      @required this.nombreusuaio,
      @required this.idUsuario}) {}
  DatosPerfiles.amistad(
      {@required this.carrete,
      @required this.nombreusuaio,
      @required this.linksHistorias,
      @required this.idUsuario});
  void _enviarValoracion() {
    baseDatosRef = Firestore.instance;
    baseDatosRef
        .collection("usuarios")
        .document(idUsuario)
        .collection("valoraciones")
        .document()
        .setData(datosValoracion);
  }
}
