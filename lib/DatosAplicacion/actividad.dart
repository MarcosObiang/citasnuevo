import 'dart:core';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/TarjetaEvento.dart';
import 'package:citasnuevo/ServidorFirebase/firebase_manager.dart';
import 'package:provider/provider.dart';

import 'Usuario.dart';

///La funcion[ActualizarEventos] que es ejecutada desde un [isolate] es la encargada de procesar los datos recibidos de la base de datos y transformarlos en el [carrete] que se ve en la pestaña planes donde se pueden ver las imagenes
///del evento y sus datos en lista vertical

Future<List<Map<String, Object>>> ActualizarEventos(
    List<Map<String, dynamic>> lista) async {
  ///En la lista [Imagenes] guardamos todos los links que son serviran para descargar las imagenes de la base de datos correspondientes en cada [carrete]
  ///
  ///
  ///
  List<String> Imagenes = new List();

  ///
  ///
  ///
  /// Al estar dentro de un [isolate] devolveremos una lista a la que llamaremos [eventosLista] que es una lista que contiene una serie objetos [eventoUnico]que son mapas[Map<String,dynamic>], entonces asumimos que
  /// guardaremos cada evento en un mapa [eventoUnico] el cual es un mapa que servira para componer la actividad correspondiente mas adelante
  ///
  ///
  ///

  List<Map<String, dynamic>> eventosLista = new List();

  ///
  ///
  ///
  ///
  ///
  ///
  ///Usamos la variable [dia] para almacenar la forma en la forma deseada y como un String la fecha de la actividad recibida de la base de datos
  final dia = new DateFormat("yMMMMEEEEd");
  final f = new DateFormat('dd-MM-yyyy HH:mm');

  ///
  ///
  ///
  ///
  ///
  ///Aqui usamos la variable y parametro de esta funcion[lista]para acceder a los datos que nos llegan de la base de datos que es una [List<DocumentSnapshot>] y la recorremos en un bucle dependiendo de su tamaño para desglosar
  ///cada[DocumentSnapshot] contenido en la lista y acceder a esos datos de la forma[lista[i].data["Nombre de dato que quiero"]] y se guarda en [eventoUnico]
  ///
  ///
  ///
  ///
  ///
  for (int i = 0; i < lista.length; i++) {
    /// [etiquetaPlan] es un valor booleano el cual usaremos para decir a [creadorImagenesEvento] cuantas veces debe poner la etiqueta sobre las imagenes del [carrete]
    ///
    ///
    ///
    ///
    bool etiquetaPlan = false;

    ///
    ///
    ///
    ///
    Map<String, Object> eventoUnico = Map();

    ///
    ///
    ///La variable [carreteEnLista] almacenara todos los objetos creados de tipo[creadorImagenEvento] al ser una lista de  [Widget] y luego se asignara a [eventoUnico]como las demas variables y se le llamara [carrete]

    List<Widget> carreteEnLista = new List();
    creadorImagenesEvento carreteCreado;
    eventoUnico["participantes"] = lista[i]["Cantidad Participantes"];
    eventoUnico["comentarios"] = lista[i]["Comentarios"];
    eventoUnico["fechaEvento"] = lista[i]["Fecha"].toDate();
    eventoUnico["lugar"] = lista[i]["Lugar"];
    eventoUnico["plazasDisponibles"] = lista[i]["Plazas Disponibles"];
    eventoUnico["creadorEvento"] = lista[i]["Creador Plan"];
    eventoUnico["codigoEvento"] = lista[i]["Codigo Plan"];
    if (lista[i]["Image1"] != null) {
      String ImagenURL1 = lista[i]["Image1"];
      Imagenes.add(ImagenURL1);
    }
    if (lista[i]["Image2"] != null) {
      String ImagenURL2 = lista[i]["Image2"];
      Imagenes.add(ImagenURL2);
    }
    if (lista[i]["Image2"] != null) {
      String ImagenURL3 = lista[i]["Image3"];
      Imagenes.add(ImagenURL3);
    }
    if (lista[i]["Image4"] != null) {
      String ImagenURL4 = lista[i]["Image4"];
      Imagenes.add(ImagenURL4);
    }
    if (lista[i]["Image5"] != null) {
      String ImagenURL5 = lista[i]["Image5"];
      Imagenes.add(ImagenURL5);
    }
    if (lista[i]["Image6"] != null) {
      String ImagenURL6 = lista[i]["Image6"];
      Imagenes.add(ImagenURL6);
    }
    for (int i = 0; i < 6; i++) {}

    for (int a = 0; a < Imagenes.length; a++) {
      if (Imagenes[a] != null) {
        if (a == 0) {
          etiquetaPlan = true;
        } else {
          etiquetaPlan = false;
        }
        carreteCreado = new creadorImagenesEvento(
          Imagenes[a],
          nombre: lista[i]["Nombre"],
          alias: lista[i]["Lugar"],
          fechaEvento: dia.format(((lista[i]["Fecha"]).toDate())),
          plazasDisponibles: lista[i]["Plazas Ocupadas"].toDouble(),
          plazasTotales: lista[i]["Cantidad Participantes"],
          edad: "30",
          nombreEnFoto: etiquetaPlan,
          datosPlanPuestos: etiquetaPlan,
          idEvento: lista[i]["Codigo Plan"],
        );

        carreteEnLista = List.from(carreteEnLista)..add(carreteCreado);
      }
    }

    eventoUnico["carrete"] = carreteEnLista;
    eventoUnico["listaImagenes"] = Imagenes;

    ///Aqui tras crear el [carrete] y añadir todos los datos a [eventoUnico] añadimos ese evento unico a la lista [eventosLista] y si el bucle llega a su fin lo que indicaria que no hay mas [carretes] que crear entonces se devuelve
    ///al isolado principal
    eventosLista = List.from(eventosLista)..add(eventoUnico);
  }

  // listaTemporal.add(cache);
  //listaTemporal["Actividad"].principal=cache;
  // listaTemporal.add(10);

  return eventosLista;
}

class Actividad with ChangeNotifier {
  /// el objeto de tipo [Actividad] [esteEvento] se usa para creaer los eventos del usuario
  ///
  ///
  ///
  static Actividad esteEvento = new Actividad();

  ///
  ///
  ///[cacheActividadesParaTi] es un objetoActividad que solo contendra las actividades a mostrar al usuario
  ///
  ///
  ///
  static Actividad cacheActividadesParaTi;

  ///
  ///
  ///[listaEventos] contiene todas las actividades, esta variabe se usa solo en[cacheActividadesParaTi]
  ///
  ///
  ///
  List<Actividad> listaEventos = new List();

  ///
  List<String> participantes = new List();

  ///
  ///
  ///[fotosEventoEditar] ayuda a ver las fotos de los eventos propios que son descargados para que el usuario pueda editarlos y tiene todas las fotos en orden del evento
  ///
  ///
  List<EditarFotoEvento> fotosEventoEditar = new List();

  ///
  ///
  ///[solicitantes] es una lista que en la pantalla de edicion de evento almacena los widgets creados a partir de los solicitantes a unirse a un evento del usuario
  List<SolicitanteEventoUsuario> solicitantes = new List();

  ///
  ///
  ///
  ///
  ///[participantesEventoUsuario] es una lista que en la pantalla de edicion de evento almacena los widgets creados a partir de los participantes en un evento del usuario
  List<ParticipanteEvento> participantesEventoUsuario = new List();

  ///
  ///
  ///
  ///[obtenerSolicitudesEventos] es un getter que pasaremos al panel de edicion de eventos para obtener las solicitudes que tiene un evento en la pantalla de edicion de eventos del usuario
  ///su omportamiento es igual a [obtenerParticipantesEventoUsuario]
  List<SolicitanteEventoUsuario> obtenerSolicitudesEventos() {
    return this.solicitantes;
  }

  List<ParticipanteEvento> obtenerParticipantesEventoUsuario() {
    return this.participantesEventoUsuario;
  }

  int contadorPrueba = 0;
  void aumentarContador() {
    contadorPrueba += 1;
    notifyListeners();
  }
  carreteComprimido carreteListo;
  String nombreEvento;
  Firestore escuchadorReferencia = Firestore.instance;
  List<Widget> carrete = new List();
  List<String> listaDeImagenes = new List();
  String creadorEvento;
  String ubicacionEvento;
  DateTime fechaEvento;
  String comentariosEvento;
  String codigoEvento;
  String _fechaEvento;
  String _horaEvento;
  String imagenUrl1;
  String imagenUrl2;
  String imagenUrl3;
  String imagenUrl4;
  String imagenUrl5;
  String imagenUrl6;
  double participantesEvento = 0.2;
  double plazasOcupadas;
  String tipoPlan;
  Actividad();
  Actividad.externa(
      {this.nombreEvento,
      this.creadorEvento,
      this.ubicacionEvento,
      this.fechaEvento,
      this.comentariosEvento,
      this.codigoEvento,
      this.imagenUrl1,
      this.imagenUrl2,
      this.imagenUrl3,
      this.imagenUrl4,
      this.imagenUrl5,
      this.imagenUrl6,
      this.participantesEvento,
      this.tipoPlan,
      this.participantesEventoUsuario}){
        this.escucharCambiosEnActividad();
      }

  List<File> _Images_List = new List(6);
  List<Actividad> _EventosUsuario = new List(10);

  List<Actividad> get EventosUsuario => _EventosUsuario;

  set EventosUsuario(List<Actividad> value) {
    _EventosUsuario = value;
    notifyListeners();
  }

  List<File> get Images_List => _Images_List;

  set Images_List(List<File> value) {
    _Images_List = value;
    notifyListeners();
  }

  Map<String, dynamic> plan = Map();
  Map<String, dynamic> CopiaPlan = Map();
  Map<String, Object> gustos = Map();

  ///
  ///
  ///
  ///
  ///Aqui se inicia la carga de eventos desde la nube hasta el dispositivo, aqui se usaran aislados[isolates] para evitar parones en la interfaz de usuario
  ///
  ///
  ///
  static void cargarEventos() async {
    cargarIsolateEventos();
  }

  static Future cargarIsolateEventos() async {
    ///
    ///Habilitamos un puerto de recepcion desde [main] para podee enviar y recibir mensajes desde [isolateEventos]
    ///
    ///
    ReceivePort puertoRecepcion = ReceivePort();

    ///
    ///
    ///[cache] almacena los datos recibidos desde el [isolateEventos] que luego se procesaran como actividad mas abajo y se almacena en [cacheActividadesParaTi]
    ///
    ///
    List<Map<String, dynamic>> cache = new List();

    WidgetsFlutterBinding.ensureInitialized();

    ///[listaProvisinal] almacena los datos obtenidos desde la red de tipo[List<DocumentSnapshot>] y se pasan a[ActualizarEventos] para que se procesen en [isolateEventos]
    ///
    ///
    List<Map<String, dynamic>> listaProvisional = await ObtenerActividad();

    ///
    ///
    /// [proceso] es el isolado donde mandaremos los datos para uque se procesen en un [isolate]
    Isolate proceso = await Isolate.spawn(
        isolateEventos, puertoRecepcion.sendPort,
        debugName: "isolateEventos");

    /// al enviar [puertoRecepcion]  al isolado [puertoEnvio] es la primera respuesta que [main] reciba desde el isolado que suele ser el puerto de envio a ese isolado
    ///
    ///
    SendPort puertoEnvio = await puertoRecepcion.first;

    ///
    ///
    ///despues de establecer comunicacion con el isolado,[cache] sera la respuesta de [enviarRecibirEventos] que es el metodo que devuelve la lista de eventos que transformaremos en objetos Actividad
    ///

    cache = await enviarRecibirEventos(puertoEnvio, listaProvisional);
    if (cache != null) {
      Firestore referenciaBaseDatos = Firestore.instance;
      cacheActividadesParaTi = new Actividad();
      for (int i = 0; i < cache.length; i++) {
        Actividad temp = new Actividad();
        temp.codigoEvento = cache[i]["codigoEvento"];
        temp.creadorEvento = cache[i]["creadorEvento"];
        temp.participantesEvento = cache[i]["participantes"];
        temp.comentariosEvento = cache[i]["comentarios"];
        temp.ubicacionEvento = cache[i]["lugar"];
        temp.fechaEvento = cache[i]["fechaEvento"];
        temp.listaDeImagenes = cache[i]["listaImagenes"];
        temp.carrete = cache[i]["carrete"] as List<Widget>;
        temp.carreteListo=new carreteComprimido();
        temp.carreteListo.carrete=temp.carrete;
        temp.escucharCambiosEnActividad();
        cacheActividadesParaTi.listaEventos.add(temp);
      }

      proceso.kill();
    }
  }

  static Future<dynamic> enviarRecibirEventos(
      SendPort envio, List<Map<String, dynamic>> lista) async {
    ///
    ///[puertoRespuestaIntermedio], este metodo aun pertenece al [main], pero es usado como intermediario, este sera el puerto por el que llegara la informacion del [isolate] y la que se usara en [cache] para que sea procesada como Actividad
    ///
    ///
    ReceivePort puertoRespuestaIntermedio = ReceivePort();

    ///
    ///aqui enviamos mediante [envio], que es el puerto de envio que hemos recibido de [cargarIsolateEventos] el cual es el puerto de envio del [isolate]
    ///
    ///
    envio.send([lista, puertoRespuestaIntermedio.sendPort]);

    ///
    ///
    ///Se envia la informacion a [cargarIsolateEventos] donde se asigna a [cache] para que se procesen las actividades
    return puertoRespuestaIntermedio.first;
  }

  static isolateEventos(SendPort puertoEnvio) async {
    ReceivePort respuesta = ReceivePort();

    List<Map<String, Object>> nuevo;

    ///Aqui se envia el puerto de envio del [isolateEventos] al metodo [cargarIsolateEventos] para establecer comunicacion entre los dos [isolates]
    puertoEnvio.send(respuesta.sendPort);
    await for (var msj in respuesta) {
      List<Map<String, dynamic>> lista = msj[0];
      SendPort sendPort = msj[1];
      // Actividad prueba=msj[3];

      nuevo = await ActualizarEventos(lista);

      ///Aqui enviamos el resultado de  [ActualizarEventos] a [enviarRecibirEventos] para que se lo devuellva a [cargarIsolateEventos] y se asigne a [cache]
      ///
      ///
      sendPort.send(nuevo);
    }
  }

  String getCodigo() {
    return codigoEvento;
  }

  ///[CrearPlan] al haber editado todas las variables para crear un plan, este metodo crea el mapa que se enviara a la base de datos
  ///
  ///
  void CrearPlan() {
    assert(gustos != null);
    if (esteEvento.tipoPlan == "Individual") {
      esteEvento.participantesEvento = 1;
    }

    plan["Nombre"] = esteEvento.nombreEvento;
    plan["Lugar"] = esteEvento.ubicacionEvento;
    plan["Fecha"] = esteEvento.fechaEvento;
    plan["Codigo Plan"] = esteEvento.codigoEvento;
    plan["Comentarios"] = esteEvento.comentariosEvento;
    plan["Image1"] = esteEvento.imagenUrl1;
    plan["Image2"] = esteEvento.imagenUrl2;
    plan["Image3"] = esteEvento.imagenUrl3;
    plan["Image4"] = esteEvento.imagenUrl4;
    plan["Image5"] = esteEvento.imagenUrl5;
    plan["Image6"] = esteEvento.imagenUrl6;
    plan["Creador Plan"] = Usuario.esteUsuario.idUsuario;
    plan["Lista Participantes"] = esteEvento.participantesEventoUsuario;
    plan["Gustos"] = esteEvento.gustos;
    plan["Cantidad Participantes"] = esteEvento.participantesEvento * 20;
    plan["Plazas Disponibles"] = esteEvento.participantesEvento * 20;
    plan["Tipo Plan"] = esteEvento.tipoPlan;
    CopiaPlan["Fecha"] = esteEvento.fechaEvento;
    CopiaPlan["Codigo Plan"] = esteEvento.codigoEvento;
    CopiaPlan["Creador Plan"] = Usuario.esteUsuario.idUsuario;

    //  print(plan);
  }

  ///[CrearPlan] al haber editado todas las variables para editar un plan, este metodo crea el mapa que se enviara a la base de datos
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  void CrearPlanEditado() {
    assert(gustos != null);
    if (this.tipoPlan == "Individual") {
      this.participantesEvento = 1;
    }

    plan["Nombre"] = this.nombreEvento;
    plan["Lugar"] = this.ubicacionEvento;
    plan["Fecha"] = this.fechaEvento;
    plan["Codigo Plan"] = this.codigoEvento;
    plan["Comentarios"] = this.comentariosEvento;
    plan["Image1"] = this.imagenUrl1;
    plan["Image2"] = this.imagenUrl2;
    plan["Image3"] = this.imagenUrl3;
    plan["Image4"] = this.imagenUrl4;
    plan["Image5"] = this.imagenUrl5;
    plan["Image6"] = this.imagenUrl6;
    plan["Creador Plan"] = Usuario.esteUsuario.idUsuario;
    // plan["Lista Participantes"] = this.participantesEventoUsuario;
    plan["Gustos"] = this.gustos;
    plan["Cantidad Participantes"] = this.participantesEvento;
    plan["Plazas Disponibles"] = this.participantesEvento;
    plan["Tipo Plan"] = this.tipoPlan;
    CopiaPlan["Fecha"] = this.fechaEvento;
    CopiaPlan["Codigo Plan"] = this.codigoEvento;
    CopiaPlan["Creador Plan"] = Usuario.esteUsuario.idUsuario;

    //  print(plan);
  }

  ///[crearCodigo] creamos el identificador del plan

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

  Map GetPlan() {
    return plan;
  }

  Map GetCopiaPlan() {
    return CopiaPlan;
  }

  void ReiniciarPlan() {
    this.plan.clear();
  }

  String get Fecha => _fechaEvento;

  set Fecha(String value) {
    _fechaEvento = value;
  }
///
///
///
///:::::::::::::::::ESCUCHAR CAMBIOS EN ACTIVIDAD:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
///
///
///Con este metodo [escucharCambiosEnActividad],escucharemos todos los cambios en una actividad respecto a los participantes
///
///
  void escucharCambiosEnActividad() {
    
    this
        .escuchadorReferencia
        .collection("actividades")
        .document(this.codigoEvento)
        .collection("participantes evento")
        .snapshots()
        .listen((event) {
       //   print(event);
       // Actividad.esteEvento.notifyListeners();
      if (event.documents != null) {
           print("${this.codigoEvento}:ññññññññññññññññññññññññññññññññññññññññññ.");
        this.plazasOcupadas = event.documents.length.toDouble();
        Actividad.cacheActividadesParaTi.notifyListeners();
      }
      
    });
  }
///
///
///
///:::::::::::::::::CERRAR ESCUCHAR CAMBIOS EN ACTIVIDAD:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
///
///
///Con el metodo [cerrarEscuchadorCambiosActividad], cada vez que eliminnemos una actividad de la memoria por razones de optimizacion se cerrara el escuchador que tenia asignado esa actividad y luego se borra de la lista y se 
///libera espacio
///
///
  void cerrarEscuchadorCambiosActividad() {
    this
        .escuchadorReferencia
        .collection("actividades")
        .document(this.codigoEvento)
        .collection("participantes evento")
        .snapshots()
        .listen((event) {})
        .cancel()
        .then((value) {
      for (int i = 0;
          i < Actividad.cacheActividadesParaTi.listaEventos.length;
          i++) {
        if (Actividad.cacheActividadesParaTi.listaEventos[i].codigoEvento ==
            this.codigoEvento) {
          Actividad.cacheActividadesParaTi.listaEventos.removeAt(i);
        }
      }
    });
  }

  void subirImagenes() async {
    final databaseReference = Firestore.instance;
    if (codigoEvento == null) {
      String v = esteEvento.crearCodigo();

      final Codigo = v;
      esteEvento.codigoEvento = v;
    }

    assert(esteEvento.codigoEvento != null);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    if (Images_List[0] != null) {
      String Image1 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${esteEvento.codigoEvento}/imagenes/Image1.jpg";
      StorageReference ImagesReference = reference.child(Image1);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[0]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      imagenUrl1 = URL;
      print(URL);
    }

    if (Images_List[1] != null) {
      String Image2 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${esteEvento.codigoEvento}/imagenes/Image2.jpg";
      StorageReference ImagesReference = reference.child(Image2);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[1]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl2 = URL;
    }
    if (Images_List[2] != null) {
      String Image3 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${esteEvento.codigoEvento}/imagenes/Image3.jpg";
      StorageReference ImagesReference = reference.child(Image3);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[2]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl3 = URL;
    }
    if (Images_List[3] != null) {
      String Image4 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${esteEvento.codigoEvento}/imagenes/Image4.jpg";
      StorageReference ImagesReference = reference.child(Image4);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[3]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl4 = URL;
    }
    if (Images_List[4] != null) {
      String Image5 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${esteEvento.codigoEvento}/imagenes/Image5.jpg";
      StorageReference ImagesReference = reference.child(Image5);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[4]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl5 = URL;
    }
    if (Images_List[5] != null) {
      String Image6 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${esteEvento.codigoEvento}/imagenes/Image6.jpg";
      StorageReference ImagesReference = reference.child(Image6);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[5]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl6 = URL;
    }
    esteEvento.fechaEvento = DateTime.parse("${Fecha} ${Hora}");
    CrearPlan();

    print(fechaEvento);
    assert(plan != null);
    assert(fechaEvento != null);
    databaseReference
        .collection("actividades")
        .document(esteEvento.codigoEvento)
        .setData(esteEvento.plan)
        .whenComplete(() {
      databaseReference
          .collection("usuarios")
          .document(Usuario.esteUsuario.idUsuario)
          .collection("Planes usuario")
          .document("${esteEvento.codigoEvento}")
          .setData(esteEvento.GetCopiaPlan());
    });
  }

  void subirEventoEditado() async {
    final databaseReference = Firestore.instance;
    if (codigoEvento == null) {
      String v = this.crearCodigo();

      final Codigo = v;
      this.codigoEvento = v;
    }
    CrearPlanEditado();

    assert(this.codigoEvento != null);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    if (Images_List[0] != null) {
      String Image1 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${this.codigoEvento}/imagenes/Image1.jpg";
      StorageReference ImagesReference = reference.child(Image1);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[0]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      imagenUrl1 = URL;
      print(URL);
    }

    if (Images_List[1] != null) {
      String Image2 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${this.codigoEvento}/imagenes/Image2.jpg";
      StorageReference ImagesReference = reference.child(Image2);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[1]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl2 = URL;
    }
    if (Images_List[2] != null) {
      String Image3 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${this.codigoEvento}/imagenes/Image3.jpg";
      StorageReference ImagesReference = reference.child(Image3);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[2]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl3 = URL;
    }
    if (Images_List[3] != null) {
      String Image4 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${this.codigoEvento}/imagenes/Image4.jpg";
      StorageReference ImagesReference = reference.child(Image4);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[3]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl4 = URL;
    }
    if (Images_List[4] != null) {
      String Image5 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${this.codigoEvento}/imagenes/Image5.jpg";
      StorageReference ImagesReference = reference.child(Image5);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[4]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl5 = URL;
    }
    if (Images_List[5] != null) {
      String Image6 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${this.codigoEvento}/imagenes/Image6.jpg";
      StorageReference ImagesReference = reference.child(Image6);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[5]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl6 = URL;
    }
    //  this.fechaEvento = DateTime.parse("${Fecha} ${Hora}");
    CrearPlanEditado();

    print(fechaEvento);
    assert(plan != null);
    assert(fechaEvento != null);
    databaseReference
        .collection("actividades")
        .document(this.codigoEvento)
        .setData(this.plan)
        .whenComplete(() {
      databaseReference
          .collection("usuarios")
          .document(Usuario.esteUsuario.idUsuario)
          .collection("Planes usuario")
          .document("${esteEvento.codigoEvento}")
          .setData(this.GetCopiaPlan());
    });
  }

  String get Hora => _horaEvento;

  set Hora(String value) {
    if (esteEvento == null) {
      esteEvento = new Actividad();
      print("Sin hora");
    }
    _horaEvento = value;
  }

  void enviarSolicitudEvento() {
    String imagenSolicitante;
    String codigoSolicitud;
    codigoSolicitud = crearCodigo();
    int imagenIndice = 1;
    for (int i = 0; i < 5; i++) {
      String nombreImagen = "IMAGENPERFIL$imagenIndice";
      Map mapaProvisional = Usuario.esteUsuario.DatosUsuario[nombreImagen];
      if (mapaProvisional["Imagen"] != null) {
        imagenSolicitante = mapaProvisional["Imagen"];
        i = 5;
      } else {
        imagenIndice += 1;
      }
    }
    Firestore baseDatos = Firestore.instance;
    Map<String, dynamic> datosSolicitud = new Map();
    datosSolicitud["ID Solicitante"] = Usuario.esteUsuario.idUsuario;
    datosSolicitud["Nombre Solicitante"] =
        Usuario.esteUsuario.DatosUsuario["Nombre"];
    datosSolicitud["Imagen Solicitante"] = imagenSolicitante;
    datosSolicitud["Hora Solicitud"] = DateTime.now();
    datosSolicitud["Plan de Interes"] = this.codigoEvento;
    datosSolicitud["Fecha Evento"] = this.fechaEvento;
    datosSolicitud["Lugar Evento"] = this.ubicacionEvento;
    datosSolicitud["Edad Solicitante"] = Usuario.esteUsuario.edad.toString();
    datosSolicitud["Id Solicitud"] = codigoSolicitud;

    baseDatos
        .collection("usuarios")
        .document(this.creadorEvento)
        .collection("solicitudes actividad")
        .document(codigoSolicitud)
        .setData(datosSolicitud);
  }

  static Future<List<Map<String, dynamic>>> ObtenerActividad() async {
    final databaseReference = Firestore.instance;
    final referencia = Firestore.instance;
    Map GustosUsuario;
    String preferencia;
    List<DocumentSnapshot> EventosUsuarioTemp = new List();
    List<DocumentSnapshot> EventosUsuario = new List();
    List<String> Gustos = new List();
    QuerySnapshot Temp;
    List<Map<String, dynamic>> listaMapas = new List();

    Temp = await databaseReference.collection("actividades").getDocuments();
    EventosUsuarioTemp.addAll(Temp.documents);
    if (EventosUsuarioTemp.length != 0) {
      for (int i = 0; i < EventosUsuarioTemp.length; i++) {
        await referencia
            .collection("actividades")
            .document(EventosUsuarioTemp[i].data["Codigo Plan"])
            .collection("participantes evento")
            .getDocuments()
            .then((value) {
          if (value != null) {
            listaMapas.add(EventosUsuarioTemp[i].data);
            listaMapas[i]
                .putIfAbsent("Plazas Ocupadas", () => value.documents.length);

            print(
                "${listaMapas[i]["Plazas Ocupadas"]}  aver comom va   ${value.documents.length}");
            //  print(value.documents.length);
          } else {
            EventosUsuarioTemp[i].data["Plazas Ocupadas"] = 0;
          }
        });
      }
      //ActualizarEventos(EventosUsuarioTemp);
      return listaMapas;
    }
  }

  static Future<List<DocumentSnapshot>> ObtenerSolicitudes() async {
    final databaseReference = Firestore.instance;
    Map GustosUsuario;
    String preferencia;
    List<DocumentSnapshot> EventosUsuarioTemp = new List();
    List<DocumentSnapshot> EventosUsuario = new List();
    List<String> Gustos = new List();
    QuerySnapshot Temp;

    Temp = await databaseReference
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("solicitudes actividad")
        .limit(10)
        .getDocuments();
    EventosUsuarioTemp.addAll(Temp.documents);
    if (EventosUsuarioTemp.length != 0) {
      print(EventosUsuarioTemp[0].data["Codigo Plan"] +
          ":     de  ${Gustos.length}");
    }

    //ActualizarEventos(EventosUsuarioTemp);
    return EventosUsuarioTemp;
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
        if (listaTemp[iteradorTemp].data["Codigo Plan"] ==
            lista[iteradorLista].data["Codigo Plan"]) {
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
}

class creadorImagenesEvento extends StatefulWidget {
  String urlImagen;
  String nombre;
  String alias;
  String edad;
  String pieFoto;
  bool nombreEnFoto;
  Image laimagen;
  bool imagenCargada = false;
  String fechaEvento;
  bool datosPlanPuestos;
  double plazasTotales;
  double plazasDisponibles;
  String idEvento;

  creadorImagenesEvento(this.urlImagen,
      { @required this.nombre,
    @required   this.alias,
    @required   this.edad,
    @required   this.pieFoto,
    @required   this.nombreEnFoto,
    @required   this.datosPlanPuestos,
    @required   this.fechaEvento,
    @required   this.plazasDisponibles,
   @required   this.plazasTotales,
    @required  this.idEvento}) {
    
  }
  int leerParticipantesEvento(){
    int dato=0;
    for(int i=0;i<Actividad.cacheActividadesParaTi.listaEventos.length;i++){
            if(Actividad.cacheActividadesParaTi.listaEventos[i].codigoEvento==this.idEvento){
              this.plazasDisponibles=Actividad.cacheActividadesParaTi.listaEventos[i].plazasOcupadas;
              dato=this.plazasDisponibles.toInt();
               return dato;
            }
    }
   
  }

  @override
  creadorImagenesEventoState createState() => creadorImagenesEventoState();
}

class creadorImagenesEventoState extends State<creadorImagenesEvento> {
  Key clave;
  @override
  Widget build(BuildContext context) {
    
  widget.plazasDisponibles=  widget.leerParticipantesEvento().toDouble();
  print("cucaracha");
    // TODO: implement build
    return Padding(
      
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Stack(alignment: AlignmentDirectional.topStart, children: [
          Container(
            child: Column(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: <Widget>[
                        CachedNetworkImage(imageUrl: widget.urlImagen),
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
                  child:
                      widget.pieFoto == null ? Text("") : Text(widget.pieFoto),
                )
              ],
            ),
          ),
          widget.datosPlanPuestos
              ? Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      "Participantes: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ScreenUtil().setSp(40,
                                              allowFontScalingSelf: false),
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "${(widget.plazasDisponibles).toInt()}/ ${(widget.plazasTotales).toInt()} ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ScreenUtil().setSp(40,
                                              allowFontScalingSelf: false),
                                          color: Colors.white),
                                    ),
                                    Icon(
                                      Icons.people,
                                      size: ScreenUtil().setSp(40,
                                          allowFontScalingSelf: false),
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                Container(
                                  width: ScreenUtil().setWidth(600),
                                  height: ScreenUtil().setHeight(60),
                                  child: LinearPercentIndicator(
                                    percent: widget.plazasDisponibles /
                                        widget.plazasTotales,
                                    animationDuration: 0,
                                    center: Text(
                                      "${(widget.plazasDisponibles).toInt()}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ScreenUtil().setSp(40,
                                              allowFontScalingSelf: false),
                                          color: Colors.white),
                                    ),
                                    lineHeight: ScreenUtil().setHeight(40),
                                    linearGradient: LinearGradient(colors: [
                                      Colors.pink,
                                      Colors.pinkAccent[100]
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.fechaEvento,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil()
                                      .setSp(20, allowFontScalingSelf: false),
                                  color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ))
              : Container()
        ]));
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

class SolicitudEventos {
  DateTime fechaEvento;
  DateTime horaSolicitud;
  String nombreEvento;
  String imagenAnfitrionEvento;
  String descripcionEvento;
  String lugarEvento;
  String idSolicitante;
  String nombreSolicitante;
  String edadSolicitante;
  String imagenSolicitante;
  String idPlanSolicitud;
  String idSolicitud;
  List<String> participantesEvento = new List();
  Firestore referenciaBaseDatos = Firestore.instance;
  SolicitudEventos.invitacion({
    @required this.fechaEvento,
    @required this.nombreEvento,
    @required this.participantesEvento,
    @required this.descripcionEvento,
    @required this.lugarEvento,
    @required this.idPlanSolicitud,
  });

  SolicitudEventos.solicitudDeParticipacionUsuario({
    @required this.horaSolicitud,
    @required this.fechaEvento,
    @required this.edadSolicitante,
    @required this.nombreSolicitante,
    @required this.idSolicitante,
    @required this.lugarEvento,
    @required this.idPlanSolicitud,
    @required this.imagenSolicitante,
    @required this.idSolicitud,
  });

  void crearSolicitudParticipacionEventoUsuario(DocumentSnapshot dato) {
    this.horaSolicitud = (dato.data["Hora Solicitud"]).toDate();
    this.idSolicitante = dato.data["ID Solicitante"];
    this.imagenSolicitante = dato.data["Imagen Solicitante"];
    this.nombreSolicitante = dato.data["Nombre Solicitante"];
    this.idPlanSolicitud = dato.data["Plan de Interes"];
    this.fechaEvento = (dato.data["Fecha Evento"]).toDate();
    this.lugarEvento = dato.data["Lugar Evento"];
  }

  void aceptarSolicitud() async {
    Map<String, String> datosUsuarioAceptado = new Map();
    Map<String, String> actividadActiva = new Map();
    datosUsuarioAceptado["Id Participante"] = this.idSolicitante;
    actividadActiva["Id Actividad"] = this.idPlanSolicitud;
    await referenciaBaseDatos
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("solicitudes actividad")
        .document(this.idSolicitud)
        .delete();
    await referenciaBaseDatos
        .collection("actividades")
        .document(this.idPlanSolicitud)
        .collection("participantes evento")
        .document()
        .setData(datosUsuarioAceptado);
    await referenciaBaseDatos
        .collection("usuarios")
        .document(this.idSolicitante)
        .collection("Tus Planes")
        .document(this.idPlanSolicitud)
        .setData(actividadActiva);
  }
}

class EventosPropios {
  static Firestore referenciaBaseDatos = Firestore.instance;
  static final dia = new DateFormat("yMMMMEEEEd");
  Actividad eventoPropio;
  TarjetaEventoPropio tarjetaEvento;

  static List<EventosPropios> listaEventosPropios = new List();
  static EventosPropios instanciaEventosPoprios = EventosPropios.instancia();

  EventosPropios.instancia();
  EventosPropios({@required this.eventoPropio}) {
    tarjetaEvento = new TarjetaEventoPropio(
      evento: eventoPropio,
      actualizadorEvento: eventoPropio.obtenerSolicitudesEventos,
      actualizadorParticipantes: eventoPropio.obtenerParticipantesEventoUsuario,
    );
  }
  void obtenerEventoosPropios() async {
    referenciaBaseDatos
        .collection("actividades")
        .where("Creador Plan", isEqualTo: Usuario.esteUsuario.idUsuario)
        .getDocuments()
        .then((datos) async {
      if (datos != null) {
        for (int i = 0; i < datos.documents.length; i++) {
          int indiceListaImagenes = 0;
          Actividad nueva = new Actividad();
          EventosPropios evento;

          String ImagenURL1 = datos.documents[i].data["Image1"];
          nueva.listaDeImagenes.add(ImagenURL1);

          String ImagenURL2 = datos.documents[i].data["Image2"];
          nueva.listaDeImagenes.add(ImagenURL2);

          String ImagenURL3 = datos.documents[i].data["Image3"];
          nueva.listaDeImagenes.add(ImagenURL3);

          String ImagenURL4 = datos.documents[i].data["Image4"];
          nueva.listaDeImagenes.add(ImagenURL4);

          String ImagenURL5 = datos.documents[i].data["Image5"];
          nueva.listaDeImagenes.add(ImagenURL5);

          String ImagenURL6 = datos.documents[i].data["Image6"];
          nueva.listaDeImagenes.add(ImagenURL6);

          nueva.imagenUrl1 = datos.documents[i].data["Image1"];
          nueva.imagenUrl2 = datos.documents[i].data["Image2"];
          nueva.imagenUrl3 = datos.documents[i].data["Image3"];
          nueva.imagenUrl4 = datos.documents[i].data["Image4"];
          nueva.imagenUrl5 = datos.documents[i].data["Image5"];
          nueva.imagenUrl6 = datos.documents[i].data["Image6"];
          nueva.nombreEvento = datos.documents[i].data["Nombre"];
          await referenciaBaseDatos
              .collection("actividades")
              .document(datos.documents[i].data["Codigo Plan"])
              .collection("participantes evento")
              .getDocuments()
              .then((value) {
            if (value != null) {
              nueva.plazasOcupadas = value.documents.length.toDouble();
            } else {
              nueva.plazasOcupadas = 0;
            }
          });
          nueva.comentariosEvento = datos.documents[i].data["Comentarios"];
          nueva._fechaEvento =
              dia.format(datos.documents[i].data["Fecha"].toDate());
          nueva.fechaEvento = datos.documents[i].data["Fecha"].toDate();
          nueva.ubicacionEvento = datos.documents[i].data["Lugar"];
          nueva.participantesEvento =
              datos.documents[i].data["Plazas Disponibles"];
          nueva.creadorEvento = datos.documents[i].data["Creador Plan"];
          nueva.codigoEvento = datos.documents[i].data["Codigo Plan"];

          for (int i = 0; i < 6; i++) {
            nueva.fotosEventoEditar.add(EditarFotoEvento(
                esteEvento: nueva,
                box: indiceListaImagenes,
                Imagen: nueva._Images_List[indiceListaImagenes]));
            indiceListaImagenes += 1;
          }

          evento = new EventosPropios(eventoPropio: nueva);

          evento.eventoPropio.solicitantes =
              await obtenerSolicitudesEventoUsuario(evento);
          nueva.participantesEventoUsuario =
              await obtenerListaPrticipantes(nueva);

          listaEventosPropios.add(evento);
        }
      }
    });
  }

  init() {
    escuchadorSolicitudesEventosPropios();
  }

  Future<List<ParticipanteEvento>> obtenerListaPrticipantes(
      Actividad actividad) async {
    List<ParticipanteEvento> listaParticipantes = new List();
    ParticipanteEvento participante;
    await referenciaBaseDatos
        .collection("actividades")
        .document(actividad.codigoEvento)
        .collection("participantes evento")
        .getDocuments()
        .then((value) {
      if (value != null) {
        for (DocumentSnapshot dato in value.documents) {
          print(dato["Id Participante"]);
          referenciaBaseDatos
              .collection("usuarios")
              .document(dato["Id Participante"])
              .get()
              .then((value) {
            if (value != null) {
              participante = new ParticipanteEvento(
                  imagenUsuario: value["IMAGENPERFIL1"]["Imagen"],
                  edadUsuario: value["Edad"].toString(),
                  nombreUsuario: value["Nombre"]);
              listaParticipantes.add(participante);
            }
          });
        }
      }
    });
    return listaParticipantes;
  }

  void escuchadorSolicitudesEventosPropios() async {
    print("Escuchando estas solicitudes");
    SolicitudEventos solicitud;
    SolicitanteEventoUsuario tarjetaSolicitud;
    referenciaBaseDatos
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("solicitudes actividad")
        .limit(1)
        .orderBy("Hora Solicitud", descending: true)
        .snapshots()
        .listen((event) {
      if (event != null) {
        for (EventosPropios dato in listaEventosPropios) {
          if (dato.eventoPropio.codigoEvento ==
              event.documents[0]["Plan de Interes"]) {
            print("${event.documents[0]["Plan de Interes"]}");
            solicitud = SolicitudEventos.solicitudDeParticipacionUsuario(
                idSolicitud: event.documents[0].data["Id Solicitud"],
                horaSolicitud: (event.documents[0]["Hora Solicitud"]).toDate(),
                fechaEvento: (event.documents[0]["Hora Solicitud"]).toDate(),
                edadSolicitante:
                    (event.documents[0]["Edad Solicitante"]).toString(),
                nombreSolicitante: event.documents[0]["Nombre Solicitante"],
                idSolicitante: event.documents[0]["ID Solicitante"],
                lugarEvento: event.documents[0]["Lugar Evento"],
                imagenSolicitante: event.documents[0]["Imagen Solicitante"],
                idPlanSolicitud: event.documents[0]["Plan de Interes"]);
            tarjetaSolicitud =
                new SolicitanteEventoUsuario(estaSolicitud: solicitud);
            dato.eventoPropio.solicitantes =
                List.from(dato.eventoPropio.solicitantes)
                  ..add(tarjetaSolicitud);

            Actividad.esteEvento.notifyListeners();
          }
        }
      }
    });
  }

  Future<List<SolicitanteEventoUsuario>> obtenerSolicitudesEventoUsuario(
      EventosPropios evento) async {
    List<SolicitanteEventoUsuario> solicitudes = new List();
    SolicitudEventos solicitud;
    SolicitanteEventoUsuario tarjetaSolicitud;
    await referenciaBaseDatos
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("solicitudes actividad")
        .where("Plan de Interes", isEqualTo: evento.eventoPropio.codigoEvento)
        .getDocuments()
        .then((datos) {
      if (datos != null) {
        for (DocumentSnapshot dato in datos.documents) {
          print(dato.data["Id Solicitud"]);
          solicitud = SolicitudEventos.solicitudDeParticipacionUsuario(
              idSolicitud: dato.data["Id Solicitud"],
              horaSolicitud: (dato["Hora Solicitud"]).toDate(),
              fechaEvento: (dato["Hora Solicitud"]).toDate(),
              edadSolicitante: (dato["Edad Solicitante"]).toString(),
              nombreSolicitante: dato["Nombre Solicitante"],
              idSolicitante: dato["ID Solicitante"],
              lugarEvento: dato["Lugar Evento"],
              imagenSolicitante: dato["Imagen Solicitante"],
              idPlanSolicitud: dato["Plan de Interes"]);

          tarjetaSolicitud =
              new SolicitanteEventoUsuario(estaSolicitud: solicitud);
          solicitudes = List.from(solicitudes)..add(tarjetaSolicitud);
        }
      }
    });
    return solicitudes;
  }
}

class TarjetaInvitacionEvento extends StatefulWidget {
  String imagen;
  String nombreSolicitante;
  DateTime fechaEvento;
  String lugarEvento;
  @override
  _TarjetaInvitacionEventoState createState() =>
      _TarjetaInvitacionEventoState();
}

class _TarjetaInvitacionEventoState extends State<TarjetaInvitacionEvento> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(1000),
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 15,
              fit: FlexFit.tight,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 5,
                      fit: FlexFit.tight,
                      child: Container(
                        child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                color: Colors.grey,
                              ),
                              Image.network(
                                  "https://firebasestorage.googleapis.com/v0/b/citas-46a84.appspot.com/o/mSg0tkowGkOVLmHfrQmVj401lMP2%2FPerfil%2Fimagenes%2FImage1.jpg?alt=media&token=4ed72e5e-b9a2-45b5-8b3c-bc2730a0c5ae"),
                            ]),
                      ),
                    ),
                    Flexible(
                      flex: 10,
                      fit: FlexFit.tight,
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Flexible(
                              flex: 4,
                              fit: FlexFit.tight,
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                    "Discoteca Wakanda entradas 5 euros Discoteca Wakanda entradas 5 eurosDiscoteca Wakanda entradas 5 eurosDiscoteca Wakanda entradas 5 euros",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(65)),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: Container(
                                height: ScreenUtil().setHeight(100),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.tight,
                                          child: Icon(Icons.location_on)),
                                      Flexible(
                                        flex: 10,
                                        fit: FlexFit.tight,
                                        child: Container(
                                          child: Text(
                                            "Calle de guadalajara 8 Mostoles madrides España",
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(55)),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 10,
                              fit: FlexFit.tight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.tight,
                                          child: Icon(Icons.chat)),
                                      Flexible(
                                        flex: 10,
                                        fit: FlexFit.tight,
                                        child: Container(
                                          child: Text(
                                            "Calle de guadalajara 8 Mostoles madrides EspañaCalle de guadalajara 8 Mostoles madrides EspañaCalle de guadalajara 8 Mostoles madrides EspañaCalle de guadalajara 8 Mostoles madrides EspañaCalle de guadalajara 8 Mostoles madrides España",
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(55)),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Container(
                  child: Row(
                children: <Widget>[
                  Flexible(
                      flex: 5,
                      fit: FlexFit.tight,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Icon(Icons.people),
                            ),
                            Container(
                              child: Text("20/60",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(70),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )),
                  Flexible(
                      flex: 10,
                      fit: FlexFit.tight,
                      child: Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Icon(LineAwesomeIcons.calendar),
                          ),
                          Container(
                            child: Text("Lunes 20 Mayo 2020",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(70),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ))),
                ],
              )),
            )
          ],
        ),
      ),
    );
  }
}

class TarjetaEventoPropio extends StatefulWidget {
  String imagen;
  String nombreEvento;
  String fechaEvento;
  String lugarEvento;
  String comentariosEvento;
  Actividad evento;
  Function actualizadorEvento;
  Function actualizadorParticipantes;

  bool dejarDeBuscarImagen = true;

  TarjetaEventoPropio(
      {@required this.evento,
      @required this.actualizadorEvento,
      @required this.actualizadorParticipantes}) {
    for (int i = 0;
        i < evento.listaDeImagenes.length && dejarDeBuscarImagen;
        i++) {
      if (evento.listaDeImagenes[i] != null) {
        imagen = evento.listaDeImagenes[i];
        dejarDeBuscarImagen = false;
      }
    }

    nombreEvento = evento.nombreEvento;
    fechaEvento = evento._fechaEvento;
    lugarEvento = evento.ubicacionEvento;
    comentariosEvento = evento.comentariosEvento;
  }
  @override
  _TarjetaEventoPropioState createState() => _TarjetaEventoPropioState();
}

class _TarjetaEventoPropioState extends State<TarjetaEventoPropio> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(1000),
      color: Colors.red,
      child: FlatButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PantallaDetallesEventoPropio(
                      evento: widget.evento,
                      actualizadorSolicitudes: widget.actualizadorEvento,
                    ))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 15,
                fit: FlexFit.tight,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        flex: 5,
                        fit: FlexFit.tight,
                        child: Container(
                          child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  color: Colors.grey,
                                ),
                                Image.network(widget.imagen),
                              ]),
                        ),
                      ),
                      Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Flexible(
                                flex: 4,
                                fit: FlexFit.tight,
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text(
                                      widget.nombreEvento ?? "Sin Comentarios",
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(65,
                                              allowFontScalingSelf: true)),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                fit: FlexFit.tight,
                                child: Container(
                                  height: ScreenUtil().setHeight(100),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Icon(Icons.location_on)),
                                        Flexible(
                                          flex: 10,
                                          fit: FlexFit.tight,
                                          child: Container(
                                            child: Text(
                                              widget.lugarEvento ??
                                                  "Sin Comentarios",
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(55)),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 10,
                                fit: FlexFit.tight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Icon(Icons.chat)),
                                        Flexible(
                                          flex: 10,
                                          fit: FlexFit.tight,
                                          child: Container(
                                            child: Text(
                                              widget.comentariosEvento ??
                                                  "Sin Comentarios",
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(55)),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Container(
                    child: Row(
                  children: <Widget>[
                    Flexible(
                        flex: 5,
                        fit: FlexFit.tight,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Icon(Icons.people),
                              ),
                              Container(
                                child: Text(
                                    "${(widget.evento.plazasOcupadas).toInt()}/${(widget.evento.participantesEvento).toInt()}",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(70),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        )),
                    Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Icon(LineAwesomeIcons.calendar),
                            ),
                            Container(
                              child: Text(widget.fechaEvento,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(70),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ))),
                  ],
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PantallaDetallesEventoPropio extends StatefulWidget {
  Actividad evento;
  Function actualizadorSolicitudes;
  EventosPropios eventos;
  TextEditingController controladorNombreEvento;
  TextEditingController controladorLugarEvento;
  TextEditingController controladorComentariosEvento;
  DateTime desdehoras;
  DateTime desdeanios;
  int dias;
  int mes;
  int anio;
  int hora;
  int minuto;
  int segundo;
  final dia = new DateFormat("yMMMMEEEEd");
  final f = new DateFormat('HH:mm');

  PantallaDetallesEventoPropio(
      {@required this.evento, @required this.actualizadorSolicitudes});
  @override
  _PantallaDetallesEventoPropioState createState() =>
      _PantallaDetallesEventoPropioState();
}

class _PantallaDetallesEventoPropioState
    extends State<PantallaDetallesEventoPropio> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Actividad.esteEvento,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.evento.nombreEvento,
            style: TextStyle(fontSize: ScreenUtil().setSp(70)),
          ),
        ),
        body: Consumer<Actividad>(
            builder: (BuildContext context, Actividad actividad, Widget child) {
          return SingleChildScrollView(
            child: Container(
                child: Column(
              children: <Widget>[
                Container(
                  height: ScreenUtil().setHeight(600),
                  child: ListView.builder(
                      itemCount: 6,
                      addAutomaticKeepAlives: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int indice) {
                        return Container(
                            padding: const EdgeInsets.all(10),
                            child: widget.evento.fotosEventoEditar[indice]);
                      }),
                ),
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListaDeSolicitudesEvento(
                                      evento: widget.evento,
                                      actualizarSolicitudes: widget
                                          .evento.obtenerSolicitudesEventos,
                                    )));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Solicitudes"),
                          Icon(Icons.people)
                        ],
                      )),
                ),
                Container(
                  child: FlatButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListaDeParticipanteEvento(
                                      evento: widget.evento,
                                      actualizarParticipantes: widget.evento
                                          .obtenerParticipantesEventoUsuario,
                                    )));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Participantes 10/30"),
                          Icon(Icons.people)
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.contacts),
                            Text("Nombre Evento")
                          ],
                        ),
                        TextFormField(
                          initialValue: widget.evento.nombreEvento,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          controller: widget.controladorNombreEvento,
                          onChanged: (valor) {
                            widget.evento.nombreEvento = valor;
                            print(widget.evento.nombreEvento);
                          },
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.map),
                            Text("Lugar Evento")
                          ],
                        ),
                        Container(
                          child: TextFormField(
                            initialValue: widget.evento.ubicacionEvento,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (valor) =>
                                widget.evento.ubicacionEvento = valor,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            DatePicker.showTimePicker(context).then((value) {
                              if (value != null) {
                                widget.hora = value.hour;
                                widget.minuto = value.minute;
                                widget.segundo = value.second;
                                widget.desdehoras = new DateTime(0, 0, 0,
                                    value.hour, value.minute, value.second);
                                Actividad.esteEvento.notifyListeners();
                                print(widget.evento.fechaEvento);
                              }
                            });
                          },
                          child: Container(
                            width: ScreenUtil().setWidth(600),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(Icons.timer),
                                    Text("Hora Evento")
                                  ],
                                ),
                                Container(
                                  height: ScreenUtil().setHeight(180),
                                  width: ScreenUtil().setWidth(500),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(3))),
                                  child: Center(
                                    child: Text(
                                        widget.desdehoras != null
                                            ? widget.f.format(widget.desdehoras)
                                            : widget.f.format(
                                                widget.evento.fechaEvento),
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(90),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(600),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(Icons.calendar_today),
                                  Text("Fecha Evento")
                                ],
                              ),
                              FlatButton(
                                onPressed: () => showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100))
                                    .then((value) {
                                  if (value != null) {
                                    widget.dias = value.day;
                                    widget.mes = value.month;
                                    widget.anio = value.year;
                                    widget.desdeanios = new DateTime(value.year,
                                        value.month, value.day, 0, 0, 0);

                                    Actividad.esteEvento.notifyListeners();
                                  }
                                }),
                                child: Container(
                                  height: ScreenUtil().setHeight(180),
                                  width: ScreenUtil().setWidth(500),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(3))),
                                  child: Center(
                                    child: Text(widget.desdeanios != null
                                        ? widget.dia.format(widget.desdeanios)
                                        : widget.dia
                                            .format(widget.evento.fechaEvento)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.label_important),
                            Text("Comentarios Evento")
                          ],
                        ),
                        Container(
                          child: TextFormField(
                            initialValue: widget.evento.comentariosEvento,
                            maxLines: 10,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (valor) =>
                                widget.evento.comentariosEvento = valor,
                            textInputAction: TextInputAction.done,
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(100),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3)),
                                    color: Colors.red),
                                child: FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancelar"),
                                )),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3)),
                                  color: Colors.green),
                              child: FlatButton(
                                  onPressed: () {
                                    widget.evento.fechaEvento = new DateTime(
                                        widget.anio ??
                                            widget.evento.fechaEvento.year,
                                        widget.mes ??
                                            widget.evento.fechaEvento.month,
                                        widget.dias ??
                                            widget.evento.fechaEvento.day,
                                        widget.hora ??
                                            widget.evento.fechaEvento.hour,
                                        widget.minuto ??
                                            widget.evento.fechaEvento.minute,
                                        widget.segundo ??
                                            widget.evento.fechaEvento.second);
                                    widget.evento.subirEventoEditado();
                                  },
                                  child: Text("Guardar")),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            )),
          );
        }),
      ),
    );
  }
}

class EditarFotoEvento extends StatefulWidget {
  int box;
  File Imagen;
  bool imagenDesdeRed;
  Actividad esteEvento;

  EditarFotoEvento(
      {@required this.box, @required this.Imagen, @required this.esteEvento}) {
    if (esteEvento.listaDeImagenes.length > box) {
      print("Comparando");
      for (int i = 0; i < esteEvento.listaDeImagenes.length; i++) {
        if (esteEvento.listaDeImagenes[box] == null) {
          imagenDesdeRed = false;
        } else {
          imagenDesdeRed = true;
        }
      }
    }
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EditarFotoEventoState(this.box, this.Imagen);
  }
}

class EditarFotoEventoState extends State<EditarFotoEvento>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  @override
  File Image_picture;
  File imagen;
  File imagenFinal;
  Firestore baseDatosRef = Firestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  Map<String, dynamic> imagenEvento = Map();

  static List<File> pictures = List(6);
  int box;
  EditarFotoEventoState(this.box, this.imagen);
  void opcionesImagenPerfil() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Cambiar Imagen"),
            content: Text("¿Seleccione la fuente de la imagen?"),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        abrirGaleria(context);
                      },
                      child: Row(
                        children: <Widget>[Text("Galeria"), Icon(Icons.image)],
                      )),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        abrirCamara(context);
                      },
                      child: Row(
                        children: <Widget>[
                          Text("Camara"),
                          Icon(Icons.camera_enhance)
                        ],
                      )),
                ],
              )
            ],
          );
        });
  }

  abrirGaleria(BuildContext context) async {
    var archivoImagen =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    File imagenRecortada = await ImageCropper.cropImage(
        sourcePath: archivoImagen.path,
        maxHeight: 1280,
        maxWidth: 720,
        aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 3),
        compressQuality: 90,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (imagenRecortada != null) {
      this.setState(() {
        imagenFinal = imagenRecortada;
        pictures[box] = imagenFinal;
        widget.esteEvento.Images_List = pictures;
        print("${archivoImagen.lengthSync()} Tamaño original");
        print("${imagenRecortada.lengthSync()} Tamaño Recortado");
        print(box);
        widget.imagenDesdeRed = false;
        Actividad.esteEvento.notifyListeners();
      });
    }
  }

  abrirCamara(BuildContext context) async {
    var archivoImagen = await ImagePicker.pickImage(source: ImageSource.camera);
    File imagenRecortada = await ImageCropper.cropImage(
        sourcePath: archivoImagen.path,

        // aspectRatio: CropAspectRatio(ratioX: 9,ratioY: 16),
        maxHeight: 1000,
        maxWidth: 720,
        compressQuality: 90,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (imagenRecortada != null) {
      this.setState(() {
        imagenFinal = imagenRecortada;
        pictures[box] = imagenFinal;
        widget.esteEvento.Images_List = pictures;
        print("${archivoImagen.lengthSync()} Tamaño original");
        print("${imagenRecortada.lengthSync()} Tamaño Recortado");
        print(box);
        Actividad.esteEvento.notifyListeners();
        widget.imagenDesdeRed = false;
      });
    }
  }

  eliminarImagen(BuildContext context) async {
    this.setState(() {
      widget.esteEvento.Images_List[box] = null;
      imagenFinal = null;
      print("object");
      if (Actividad.esteEvento.Images_List[box] == null) {
        print("vacio en $box");
        Actividad.esteEvento.notifyListeners();
        widget.imagenDesdeRed = false;
        if (box == 0) {
          widget.esteEvento.imagenUrl1 = null;
        }
        if (box == 1) {
          widget.esteEvento.imagenUrl2 = null;
        }
        if (box == 2) {
          widget.esteEvento.imagenUrl3 = null;
        }
        if (box == 3) {
          widget.esteEvento.imagenUrl4 = null;
        }
        if (box == 4) {
          widget.esteEvento.imagenUrl5 = null;
        }
        if (box == 5) {
          widget.esteEvento.imagenUrl6 = null;
        }
        imagenEvento["Image${box + 1}"] = null;
        CrearPlan();
        baseDatosRef
            .collection("actividades")
            .document(widget.esteEvento.codigoEvento)
            .updateData(imagenEvento);

        StorageReference reference = storage.ref();

        String Image1 =
            "${Usuario.esteUsuario.idUsuario}/Planes/${widget.esteEvento.codigoEvento}/imagenes/Image${box + 1}.jpg";
        StorageReference imagesReference = reference.child(Image1);
        //  widget.esteEvento.fotosEventoEditar.removeAt(box);
        imagesReference.delete().catchError((error) {
          print(error);
        });
        Actividad.esteEvento.notifyListeners();
      }
    });
  }

  void CrearPlan() {
    imagenEvento["Nombre"] = widget.esteEvento.nombreEvento;
    imagenEvento["Lugar"] = widget.esteEvento.ubicacionEvento;
    imagenEvento["Fecha"] = widget.esteEvento.fechaEvento;
    imagenEvento["Codigo Plan"] = widget.esteEvento.codigoEvento;
    imagenEvento["Comentarios"] = widget.esteEvento.comentariosEvento;
    imagenEvento["Image1"] = widget.esteEvento.imagenUrl1;
    imagenEvento["Image2"] = widget.esteEvento.imagenUrl2;
    imagenEvento["Image3"] = widget.esteEvento.imagenUrl3;
    imagenEvento["Image4"] = widget.esteEvento.imagenUrl4;
    imagenEvento["Image5"] = widget.esteEvento.imagenUrl5;
    imagenEvento["Image6"] = widget.esteEvento.imagenUrl6;
    imagenEvento["Creador Plan"] = Usuario.esteUsuario.idUsuario;
    imagenEvento["Gustos"] = widget.esteEvento.gustos;
    imagenEvento["Cantidad Participantes"] =
        widget.esteEvento.participantesEvento * 20;
    imagenEvento["Plazas Disponibles"] =
        widget.esteEvento.participantesEvento * 20;
    imagenEvento["Tipo Plan"] = widget.esteEvento.tipoPlan;
    imagenEvento["Fecha"] = widget.esteEvento.fechaEvento;
    imagenEvento["Codigo Plan"] = widget.esteEvento.codigoEvento;
    imagenEvento["Creador Plan"] = Usuario.esteUsuario.idUsuario;

    //  print(plan);
  }

  Widget build(BuildContext context) {
    imagen = widget.Imagen;


    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: Colors.white, width: ScreenUtil().setWidth(6)),
        borderRadius: BorderRadius.all(Radius.circular(3)),
        color: Colors.white30,
      ),
      child: FlatButton(
        onPressed: () => opcionesImagenPerfil(),
        onLongPress: () => eliminarImagen(context),
        child: imagenFinal == null && widget.imagenDesdeRed == false
            ? Container(
                height: ScreenUtil().setHeight(500),
                width:
                    widget.imagenDesdeRed ? ScreenUtil().setWidth(800) : null,
                child: Center(
                  child: Icon(
                    Icons.add_a_photo,
                    color: Colors.black,
                  ),
                ),
              )
            : Stack(alignment: AlignmentDirectional.center, children: [
                widget.imagenDesdeRed && imagenFinal == null
                    ? Container(
                        height: ScreenUtil().setHeight(500),
                        child: Image.network(
                            widget.esteEvento.listaDeImagenes[box]))
                    : Container(
                        height: ScreenUtil().setHeight(500),
                        child: Image.file(
                          imagenFinal,
                          fit: BoxFit.fill,
                        ),
                      ),
                Container(
                  height: ScreenUtil().setHeight(500),
                  width:
                      widget.imagenDesdeRed ? ScreenUtil().setWidth(800) : null,
                  child: Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: ScreenUtil().setSp(150),
                    ),
                  ),
                ),
              ]),
      ),
    );
  }
}

class SolicitanteEventoUsuario extends StatelessWidget {
  SolicitudEventos estaSolicitud;
  SolicitanteEventoUsuario({@required this.estaSolicitud});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Container(
                      height: ScreenUtil().setHeight(300),
                      child: Image.network(estaSolicitud.imagenSolicitante)),
                ),
                Flexible(
                  flex: 6,
                  fit: FlexFit.tight,
                  child: Container(
                    child: Text(estaSolicitud.nombreSolicitante),
                  ),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Container(
                    child: Text(
                      estaSolicitud.edadSolicitante,
                      style: TextStyle(fontSize: ScreenUtil().setSp(80)),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.blue,
                        ),
                        child: FlatButton(
                          onPressed: () {
                            estaSolicitud.aceptarSolicitud();
                          },
                          child: Text(
                            "Aceptar",
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: FlatButton(
                          onPressed: () {},
                          child: Text(
                            "Eliminar",
                            style: TextStyle(color: Colors.red),
                          ),
                        ))
                  ]),
            )
          ],
        ),
      ),
    );
  }
}

class ListaDeSolicitudesEvento extends StatefulWidget {
  Actividad evento;
  Function actualizarSolicitudes;
  ListaDeSolicitudesEvento(
      {@required this.evento, @required this.actualizarSolicitudes});
  @override
  _ListaDeSolicitudesEventoState createState() =>
      _ListaDeSolicitudesEventoState();
}

class _ListaDeSolicitudesEventoState extends State<ListaDeSolicitudesEvento> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Actividad>(
      builder: (BuildContext context, Actividad actividad, Widget child) {
        widget.evento.solicitantes = widget.actualizarSolicitudes();
        return Scaffold(
            appBar: AppBar(
              title: Text("Solicitudes"),
            ),
            body: widget.evento.solicitantes.length == 0
                ? Center(
                    child: Text("No hay Solicitudes"),
                  )
                : ListView.builder(
                    itemCount: widget.evento.solicitantes == null
                        ? 0
                        : widget.evento.solicitantes.length,
                    itemBuilder: (BuildContext context, int indice) {
                      return widget.evento.solicitantes[indice];
                    }));
      },
    );
  }
}

class ParticipanteEvento extends StatelessWidget {
  String imagenUsuario;
  String edadUsuario;
  String nombreUsuario;
  ParticipanteEvento(
      {@required this.imagenUsuario,
      @required this.edadUsuario,
      @required this.nombreUsuario});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: Container(
                      height: ScreenUtil().setHeight(300),
                      child: Image.network(imagenUsuario),
                    )),
                Flexible(
                  flex: 6,
                  fit: FlexFit.tight,
                  child: Container(
                    child: Text(nombreUsuario),
                  ),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Container(
                    child: Text(
                      edadUsuario,
                      style: TextStyle(fontSize: ScreenUtil().setSp(80)),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.blue,
                        ),
                        child: FlatButton(
                          onPressed: () {},
                          child: Text(
                            "Aceptar",
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: FlatButton(
                          onPressed: () {},
                          child: Text(
                            "Eliminar",
                            style: TextStyle(color: Colors.red),
                          ),
                        ))
                  ]),
            )
          ],
        ),
      ),
    );
  }
}

class ListaDeParticipanteEvento extends StatefulWidget {
  Actividad evento;
  Function actualizarParticipantes;
  ListaDeParticipanteEvento(
      {@required this.evento, @required this.actualizarParticipantes});
  @override
  _ListaDeParticipanteEventoState createState() =>
      _ListaDeParticipanteEventoState();
}

class _ListaDeParticipanteEventoState extends State<ListaDeParticipanteEvento> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Actividad>(
      builder: (BuildContext context, Actividad actividad, Widget child) {
        widget.evento.participantesEventoUsuario =
            widget.actualizarParticipantes();
        return Scaffold(
            appBar: AppBar(
              title: Text("Participantes"),
            ),
            body: widget.evento.participantesEventoUsuario.length == 0
                ? Center(
                    child: Text("No hay Participantes"),
                  )
                : ListView.builder(
                    itemCount: widget.evento.participantesEventoUsuario == null
                        ? 0
                        : widget.evento.participantesEventoUsuario.length,
                    itemBuilder: (BuildContext context, int indice) {
                      return widget.evento.participantesEventoUsuario[indice];
                    }));
      },
    );
  }
}

class carreteComprimido extends StatefulWidget {
  List<Widget>carrete=new List();
  @override
  _carreteComprimidoState createState() => _carreteComprimidoState();
}

class _carreteComprimidoState extends State<carreteComprimido> {
  @override
  Widget build(BuildContext context) {
    print("carreteListo");
    return Container(
      height: ScreenUtil().setHeight(3100),
     width: ScreenUtil().setWidth(1400),
     child: ListView(
       
       children: widget.carrete,
     ),
      
    );
  }
}