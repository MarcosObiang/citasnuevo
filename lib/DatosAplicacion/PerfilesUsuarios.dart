import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/DatosAplicacion/actividad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;
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

Future<List<DatosPerfiles>> ActualizarEventosAmigos(
    List<DocumentSnapshot> lista) async {
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
    String idUsuario = lista[i].data["Id"];
    String nombre = lista[i].data["Nombre"];
    String alias = lista[i].data["Alias"];
    String edad = (lista[i].data["Edad"]).toString();
    Map ImagenURL1 = lista[i].data["IMAGENPERFIL1"];
    Map ImagenURL2 = lista[i].data["IMAGENPERFIL2"];
    Map ImagenURL3 = lista[i].data["IMAGENPERFIL3"];
    Map ImagenURL4 = lista[i].data["IMAGENPERFIL4"];
    Map ImagenURL5 = lista[i].data["IMAGENPERFIL5"];
    Map ImagenURL6 = lista[i].data["IMAGENPERFIL5"];
    String descripcion = lista[i].data["Descripcion"];
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

    perfilCreado = List.from(perfilCreado)
      ..add(DatosPerfiles.amistad(
          carrete: perfilTemp, nombreusuaio: nombre, idUsuario: idUsuario));

    print(perfilCreado);
    return perfilCreado;
  }
}

Future<List<DatosPerfiles>> ActualizarEventosCitas(
    List<DocumentSnapshot> lista) async {
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
    String idUsuario = lista[i].data["Id"];
    String nombre = lista[i].data["Nombre"];
    String alias = lista[i].data["Alias"];
    String edad = (lista[i].data["Edad"]).toString();
    Map ImagenURL1 = lista[i].data["IMAGENPERFIL1"];
    Map ImagenURL2 = lista[i].data["IMAGENPERFIL2"];
    Map ImagenURL3 = lista[i].data["IMAGENPERFIL3"];
    Map ImagenURL4 = lista[i].data["IMAGENPERFIL4"];
    Map ImagenURL5 = lista[i].data["IMAGENPERFIL5"];
    Map ImagenURL6 = lista[i].data["IMAGENPERFIL5"];
    String descripcion = lista[i].data["Descripcion"];
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
        Perfiles.perfilesCitas.imagenesEnCola += 1;

        ///
        ///
        ///
        ///
        ///
        /// A la lista temporal [perfilTemp]  que es un [carrete]  le añadimos los widgets necesarios
        perfilTemp.add(creadorImagenPerfil(
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
    perfilCreado.add(DatosPerfiles.citas(
        carrete: perfilTemp,
        valoracion: 5.0,
        nombreusuaio: nombre,
        idUsuario: idUsuario));

    //print(perfilesCitas.listaPerfiles);
  }
  return perfilCreado;
}

class Perfiles extends ChangeNotifier {
  static void cargarPerfilesCitas() {
    Perfiles.perfilesCitas.cargarIsolate();
  }

  static void cargarPerfilesAmistad() {
    Perfiles.perfilesAmistad.cargarIsolateAmistad();
  }

  Future cargarIsolate() async {
    List<DocumentSnapshot> listaProvisional =
        await obtenetPerfilesCitas(Usuario.esteUsuario.DatosUsuario);
    ReceivePort puertoRecepcion = ReceivePort();
    WidgetsFlutterBinding.ensureInitialized();
    Isolate proceso=await Isolate.spawn(isolateCitas, puertoRecepcion.sendPort,
        debugName: "IsolateCitas");
    SendPort puertoEnvio = await puertoRecepcion.first;
    Perfiles.perfilesCitas.listaPerfiles = await enviarRecibirCitas(
        Usuario.esteUsuario, puertoEnvio, listaProvisional);
        proceso.kill();
  }

  Future<dynamic> enviarRecibirCitas(Usuario user, SendPort puertos,
      List<DocumentSnapshot> listaPerfiles) async {
    ReceivePort puertoRespuestaIntermedio = ReceivePort();
    puertos.send(
        [user.DatosUsuario, puertoRespuestaIntermedio.sendPort, listaPerfiles]);
    return puertoRespuestaIntermedio.first;
  }

  static isolateCitas(SendPort puertoEnvio) async {
    List<DatosPerfiles> perfilesCita;
    ReceivePort puertoRespuesta = ReceivePort();
    puertoEnvio.send(puertoRespuesta.sendPort);
    await for (var msj in puertoRespuesta) {
      Map datoUsuario = msj[0];
      SendPort sendPort = msj[1];
      List<DocumentSnapshot> lista = msj[2];

      perfilesCita = await ActualizarEventosCitas(lista);
      sendPort.send(perfilesCita);
    }
  }

  Future cargarIsolateAmistad() async {
    List<DocumentSnapshot> listaProvisional =
        await obtenerPerfilesAmistad(Usuario.esteUsuario.DatosUsuario);
    ReceivePort puertoRecepcion = ReceivePort();
    WidgetsFlutterBinding.ensureInitialized();
   Isolate proceso= await Isolate.spawn(isolateCitas, puertoRecepcion.sendPort,
        debugName: "IsolateAmistad");
    SendPort puertoEnvio = await puertoRecepcion.first;
    Perfiles.perfilesAmistad.listaPerfiles = await enviarRecibirAmistad(
        Usuario.esteUsuario, puertoEnvio, listaProvisional);
        proceso.kill();
  }

  Future<dynamic> enviarRecibirAmistad(Usuario user, SendPort puertos,
      List<DocumentSnapshot> listaPerfiles) async {
    ReceivePort puertoRespuestaIntermedio = ReceivePort();
    puertos.send(
        [user.DatosUsuario, puertoRespuestaIntermedio.sendPort, listaPerfiles]);
    return puertoRespuestaIntermedio.first;
  }

  static isolateAmistad(SendPort puertoEnvio) async {
    List<DatosPerfiles> perfilesCita;
    ReceivePort puertoRespuesta = ReceivePort();
    puertoEnvio.send(puertoRespuesta.sendPort);
    await for (var msj in puertoRespuesta) {
      Map datoUsuario = msj[0];
      SendPort sendPort = msj[1];
      List<DocumentSnapshot> lista = msj[2];

      perfilesCita = await ActualizarEventosCitas(lista);
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
  static Firestore baseDatosRef = Firestore.instance;

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
  Future<List<DocumentSnapshot>> obtenetPerfilesCitas(Map usuario) async {
    print("dentro de isolado");
    Firestore baseDatosRef = Firestore.instance;
    print("dentro de isolado");
    String tendriaCitasCon;
    List<DocumentSnapshot> perfiles;
    DatosPerfiles perfilTemporal;
    String sexoUsuario;
    List<DocumentSnapshot> perfilesTemp = new List();
    // List<DocumentSnapshot> perfiles = new List();
    QuerySnapshot Temp;
    tendriaCitasCon = usuario["Citas con"];
    sexoUsuario = usuario["Sexo"];

    if (tendriaCitasCon == "HombreGay" || tendriaCitasCon == "MujerGay") {
      Temp = await baseDatosRef
          .collection("usuarios")
          .where("Citas con", isEqualTo: tendriaCitasCon)
          .getDocuments();
      perfilesTemp.addAll(Temp.documents);
    }

    ///***********************************************************************************//
    /// Mujer que tendria citas con hombres busca usuarios que tendrian citas con mujeres///
    ///**********************************************************************************//

    if (tendriaCitasCon == "Hombre") {
      print("Citas con mujer");
      Temp = await baseDatosRef
          .collection("usuarios")
          .where("Citas con", isEqualTo: "Mujer")
          .getDocuments();
      perfilesTemp.addAll(Temp.documents);
      print(perfilesTemp.length);
    }

    ///***********************************************************************************//
    /// Hombre que tendria citas con mujeres busca usuarios que tendrian citas con hombres///
    ///**********************************************************************************//
    if (tendriaCitasCon == "Mujer") {
      Temp = await baseDatosRef
          .collection("usuarios")
          .where("Citas con", isEqualTo: "Hombre")
          .getDocuments();
      perfilesTemp.addAll(Temp.documents);
    }
    if (tendriaCitasCon == "Ambos") {
      Temp = await baseDatosRef
          .collection("usuarios")
          .where("Citas con", isEqualTo: tendriaCitasCon)
          .getDocuments();
      perfilesTemp.addAll(Temp.documents);
    }

    return perfilesTemp;
  }

  Future<List<DocumentSnapshot>> obtenerPerfilesAmistad(Map usuario) async {
    print("dentro");
    List<DocumentSnapshot> perfilesTemp = new List();
    List<DocumentSnapshot> perfiles = new List();
    DatosPerfiles perfilTemporal;
    QuerySnapshot Temp;
    bool amigos = usuario["Solo amigos"];
    bool ambos = usuario["Ambos"];
    if ((ambos != null && ambos) || (amigos != null && amigos)) {
      Temp = await baseDatosRef
          .collection("usuarios")
          .where("Ambos", isEqualTo: true)
          .getDocuments();
      perfilesTemp.addAll(Temp.documents);
      Temp = await baseDatosRef
          .collection("usuarios")
          .where("Solo amigos", isEqualTo: true)
          .getDocuments();
      perfilesTemp.addAll(Temp.documents);
    }

    //  perfilesTemp= await _QuitarDuplicados(perfilesTemp);

    //  perfilTemporal=await ActualizarEventosAmigos(perfilesTemp);
    return perfilesTemp;
  }

  Future<List<DocumentSnapshot>> _QuitarDuplicados(
      List<DocumentSnapshot> lista) async {
    List<DocumentSnapshot> listaTemp = new List();

    int iteradorLista = 0;
    int iteradorTemp = 0;
    int coincidencia;

    if (lista.isEmpty || lista == null || lista.length == 0) {
      listaTemp.add(lista[0]);
      iteradorTemp = 1;
    } else {
      listaTemp.add(lista[0]);
    }
    for (iteradorLista; iteradorLista < lista.length; iteradorLista++) {
      coincidencia = 0;
      iteradorTemp = 0;
      for (iteradorTemp; iteradorTemp < listaTemp.length; iteradorTemp++) {
        if (listaTemp[iteradorTemp].data["Id"] ==
            lista[iteradorLista].data["Id"]) {
          coincidencia = coincidencia + 1;
          print(coincidencia);
        }
      }
      if (coincidencia == 0) {
        print(iteradorTemp);
        listaTemp.add(lista[iteradorLista]);
        coincidencia = 0;
      }
    }
    return listaTemp;
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

class creadorImagenPerfil extends StatefulWidget {
  String urlImagen;
  String nombre;
  String alias;
  String edad;
  String pieFoto;
  bool nombreEnFoto;
  Image laimagen;
  bool imagenCargada = false;

  creadorImagenPerfil(this.urlImagen,
      {this.nombre, this.alias, this.edad, this.pieFoto, this.nombreEnFoto}) {
    //cargarImagen();
  }

  @override
  _creadorImagenPerfilState createState() => _creadorImagenPerfilState();
}

class _creadorImagenPerfilState extends State<creadorImagenPerfil> {
  Uint8List bitsImagen;
  initState() {
    super.initState();
    widget.laimagen = Image.network(widget.urlImagen);
  }

  void didChangeDependencies() {
    precacheImage(widget.laimagen.image, context);
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
                      FadeInImage(
                        height: ScreenUtil().setHeight(2500),
                       
                        placeholder: MemoryImage(kTransparentImage), image: NetworkImage(widget.urlImagen),
                        fadeInCurve: Curves.easeIn,
                        fadeInDuration: Duration(milliseconds:200),
                      
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
    precacheImage(widget.laimagen.image, context);
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
                      FadeInImage(
                        height: ScreenUtil().setHeight(2500),
                        placeholder: null, image: NetworkImage(widget.urlImagen),
                        fadeInCurve: Curves.easeIn,
                        fadeInDuration: Duration(milliseconds:200),
                      
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
      height: ScreenUtil().setHeight(550),
      decoration: BoxDecoration(
        color: Color.fromRGBO(69, 76, 80, 90),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          descripcionPerfil,
          style: TextStyle(color: Colors.white),
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
  double valoracion;
  List<Widget> carrete = new List();
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
    datosValoracion["Imagen Usuario"] = Usuario.esteUsuario.ImageURL1["Imagen"];
    datosValoracion["Nombre emisor"] = nombreUsuarioLocal;
    datosValoracion["Alias Emisor"] = aliasUsuarioLocal;
    datosValoracion["Id emisor"] = idUsuarioLocal;
    datosValoracion["Valoracion"] = valoracion;
    datosValoracion["Mensaje"] = this.mensaje;
    datosValoracion["Time"] = DateTime.now();
    datosValoracion["id valoracion"] = crearCodigo();
    _enviarValoracion();
  }
DatosPerfiles();
  DatosPerfiles.citas(
      {@required this.carrete,
      @required this.valoracion,
      @required this.nombreusuaio,
      @required this.idUsuario});
  DatosPerfiles.amistad(
      {@required this.carrete,
      @required this.nombreusuaio,
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
