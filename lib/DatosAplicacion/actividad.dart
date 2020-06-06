import 'dart:core';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
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

Future<List<Map<String, Object>>> ActualizarEventos(
    List<DocumentSnapshot> lista) async {
  TarjetaEvento tarjeta;
  Timestamp tiempo;
  DateTime tiempoTransformado;

  List<String> Imagenes = new List();

  List<Map<String, dynamic>> eventosLista = new List();
  final dia = new DateFormat("yMMMMEEEEd");
  final f = new DateFormat('dd-MM-yyyy HH:mm');
  print("${lista.length}***********************************************++++++");
  for (int i = 0; i < lista.length; i++) {
    bool etiquetaPlan = false;
    Map<String, Object> eventoUnico = Map();

    List<Widget> carreteEnLista = new List();
    creadorImagenesEvento carreteCreado;
    eventoUnico["participantes"] = lista[i].data["Cantidad Participantes"];
    eventoUnico["comentarios"] = lista[i].data["Comentarios"];
    eventoUnico["fechaEvento"] = lista[i].data["Fecha"].toDate();
    eventoUnico["lugar"] = lista[i].data["Lugar"];
    eventoUnico["plazasDisponibles"] = lista[i].data["Plazas Disponibles"];
    eventoUnico["creadorEvento"] = lista[i].data["Creador Plan"];
    eventoUnico["codigoEvento"] = lista[i].data["Codigo Plan"];
    if (lista[i].data["Image1"] != null) {
      String ImagenURL1 = lista[i].data["Image1"];
      Imagenes.add(ImagenURL1);
    }
    if (lista[i].data["Image2"] != null) {
      String ImagenURL2 = lista[i].data["Image2"];
      Imagenes.add(ImagenURL2);
    }
    if (lista[i].data["Image2"] != null) {
      String ImagenURL3 = lista[i].data["Image3"];
      Imagenes.add(ImagenURL3);
    }
    if (lista[i].data["Image4"] != null) {
      String ImagenURL4 = lista[i].data["Image4"];
      Imagenes.add(ImagenURL4);
    }
    if (lista[i].data["Image5"] != null) {
      String ImagenURL5 = lista[i].data["Image5"];
      Imagenes.add(ImagenURL5);
    }
    if (lista[i].data["Image6"] != null) {
      String ImagenURL6 = lista[i].data["Image6"];
      Imagenes.add(ImagenURL6);
    }
    for (int i = 0; i < 6; i++) {}

    for (int a = 0; a < Imagenes.length; a++) {
      if (Imagenes[a] != null) {
        // print("CarreteCreado****************************************************************************************************++++++");
        if (a == 0) {
          etiquetaPlan = true;
        } else {
          etiquetaPlan = false;
        }
        carreteCreado = new creadorImagenesEvento(
          Imagenes[a],
          nombre: lista[i].data["Nombre"],
          alias: lista[i].data["Lugar"],
          fechaEvento: dia.format(((lista[i].data["Fecha"]).toDate())),
          plazasDisponibles: lista[i].data["Plazas Disponibles"],
          plazasTotales: lista[i].data["Cantidad Participantes"],
          edad: "30",
          nombreEnFoto: etiquetaPlan,
          datosPlanPuestos: etiquetaPlan,
        );

        carreteEnLista = List.from(carreteEnLista)..add(carreteCreado);
      }
    }

    eventoUnico["carrete"] = carreteEnLista;
    eventoUnico["listaImagenes"] = Imagenes;
    eventosLista = List.from(eventosLista)..add(eventoUnico);
  }

  // listaTemporal.add(cache);
  //listaTemporal["Actividad"].principal=cache;
  // listaTemporal.add(10);

  return eventosLista;
}

class Actividad with ChangeNotifier {
  static Actividad esteEvento = new Actividad();
  static Actividad cacheActividadesParaTi;
  List<Actividad> listaEventos = new List();
  List<Map<String, dynamic>> participantes = new List();
  List<EditarFotoEvento> fotosEventoEditar = new List();

  int contadorPrueba = 0;
  void aumentarContador() {
    contadorPrueba += 1;
    notifyListeners();
  }

  String nombreEvento;
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
  String tipoPlan;
  Actividad();
  Actividad.externa({
    this.nombreEvento,
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
  });

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

  String getCodigo() {
    return codigoEvento;
  }

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

    plan["Gustos"] = esteEvento.gustos;
    plan["Cantidad Participantes"] = esteEvento.participantesEvento * 20;
    plan["Plazas Disponibles"] = esteEvento.participantesEvento * 20;
    plan["Tipo Plan"] = esteEvento.tipoPlan;
    CopiaPlan["Fecha"] = esteEvento.fechaEvento;
    CopiaPlan["Codigo Plan"] = esteEvento.codigoEvento;
    CopiaPlan["Creador Plan"] = Usuario.esteUsuario.idUsuario;

    //  print(plan);
  }

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

  void Upload_Image() async {
    final databaseReference = Firestore.instance;
    String v = esteEvento.crearCodigo();
    final Codigo = v;
    esteEvento.codigoEvento = v;
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

    baseDatos
        .collection("usuarios")
        .document(this.creadorEvento)
        .collection("solicitudes actividad")
        .document()
        .setData(datosSolicitud);
  }

  static Future<List<DocumentSnapshot>> ObtenerActividad() async {
    final databaseReference = Firestore.instance;
    Map GustosUsuario;
    String preferencia;
    List<DocumentSnapshot> EventosUsuarioTemp = new List();
    List<DocumentSnapshot> EventosUsuario = new List();
    List<String> Gustos = new List();
    QuerySnapshot Temp;

    Temp = await databaseReference.collection("actividades").getDocuments();
    EventosUsuarioTemp.addAll(Temp.documents);
    if (EventosUsuarioTemp.length != 0) {
      print(EventosUsuarioTemp[0].data["Codigo Plan"] +
          ":     de  ${Gustos.length}");
    }

    for (int i = 0; i < EventosUsuario.length; i++) {
      print(EventosUsuario[i].data["Codigo Plan"] + "     $i");
    }
    //ActualizarEventos(EventosUsuarioTemp);
    return EventosUsuarioTemp;
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

  static void cargarEventos() async {
    cargarIsolateEventos();
  }

  static Future cargarIsolateEventos() async {
    ReceivePort puertoRecepcion = ReceivePort();
    List<Map<String, dynamic>> cache = new List();

    WidgetsFlutterBinding.ensureInitialized();
    List<DocumentSnapshot> listaProvisional = await ObtenerActividad();
    Isolate proceso = await Isolate.spawn(
        isolateEventos, puertoRecepcion.sendPort,
        debugName: "isolateEventos");
    SendPort puertoEnvio = await puertoRecepcion.first;
    cache = await enviarRecibirEventos(puertoEnvio, listaProvisional);
    if (cache == null) {
      print(
          "cache contiene algo********************************************************************************************************************************************");
    }
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
      cacheActividadesParaTi.listaEventos.add(temp);
    }

    proceso.kill();
  }

  static Future<dynamic> enviarRecibirEventos(
      SendPort envio, List<DocumentSnapshot> lista) async {
    List<DatosPerfiles> prueba = new List();
    ReceivePort puertoRespuestaIntermedio = ReceivePort();
    envio.send([lista, puertoRespuestaIntermedio.sendPort]);
    return puertoRespuestaIntermedio.first;
  }

  static isolateEventos(SendPort puertoEnvio) async {
    ReceivePort respuesta = ReceivePort();

    List<Map<String, Object>> nuevo;
    puertoEnvio.send(respuesta.sendPort);
    await for (var msj in respuesta) {
      List<DocumentSnapshot> lista = msj[0];
      SendPort sendPort = msj[1];
      // Actividad prueba=msj[3];

      nuevo = await ActualizarEventos(lista);
      sendPort.send(nuevo);
    }
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

  creadorImagenesEvento(this.urlImagen,
      {this.nombre,
      this.alias,
      this.edad,
      this.pieFoto,
      this.nombreEnFoto,
      this.datosPlanPuestos,
      this.fechaEvento,
      this.plazasDisponibles,
      this.plazasTotales}) {
    //cargarImagen();
  }

  @override
  creadorImagenesEventoState createState() => creadorImagenesEventoState();
}

class creadorImagenesEventoState extends State<creadorImagenesEvento> {
  @override
  Widget build(BuildContext context) {
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
                                      "Plazas Disponibles: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: ScreenUtil().setSp(40,
                                              allowFontScalingSelf: false),
                                          color: Colors.white),
                                    ),
                                    Text(
                                      " ${(widget.plazasDisponibles).toInt()} ",
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
                                          fontSize: ScreenUtil().setSp(30,
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
                                      .setSp(50, allowFontScalingSelf: false),
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
  String imagenSolicitante;
  String idPlanSolicitud;
  List<String> participantesEvento = new List();

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
    @required this.nombreEvento,
    @required this.nombreSolicitante,
    @required this.idSolicitante,
    @required this.lugarEvento,
    @required this.idPlanSolicitud,
  });

  void crearSolicitudEventoUsuario(DocumentSnapshot dato) {
    this.horaSolicitud = (dato.data["Hora Solicitud"]).toDate();
    this.idSolicitante = dato.data["ID Solicitante"];
    this.imagenSolicitante = dato.data["Imagen Solicitante"];
    this.nombreSolicitante = dato.data["Nombre Solicitante"];
    this.idPlanSolicitud = dato.data["Plan de Interes"];
    this.fechaEvento = (dato.data["Fecha Evento"]).toDate;
    this.lugarEvento = dato.data["Lugar Evento"];
  }
}

class EventosPropios {
  static Firestore referenciaBaseDatos = Firestore.instance;
  static final dia = new DateFormat("yMMMMEEEEd");
  Actividad eventoPropio;
  TarjetaEventoPropio tarjetaEvento;
  static List<EventosPropios> listaEventosPropios = new List();

  EventosPropios({@required this.eventoPropio}) {
    tarjetaEvento = new TarjetaEventoPropio(
      evento: eventoPropio,
    );
  }
  static void obtenerEventoosPropios() async {
    referenciaBaseDatos
        .collection("actividades")
        .where("Creador Plan", isEqualTo: Usuario.esteUsuario.idUsuario)
        .getDocuments()
        .then((datos) {
      if (datos != null) {
        for (int i = 0; i < datos.documents.length; i++) {
          int indiceListaImagenes = 0;
          Actividad nueva = new Actividad();
          EventosPropios evento;
          if (datos.documents[i].data["Image1"] != null) {
            String ImagenURL1 = datos.documents[i].data["Image1"];
            nueva.listaDeImagenes.add(ImagenURL1);
          }
          if (datos.documents[i].data["Image2"] != null) {
            String ImagenURL2 = datos.documents[i].data["Image2"];
            nueva.listaDeImagenes.add(ImagenURL2);
          }
          if (datos.documents[i].data["Image2"] != null) {
            String ImagenURL3 = datos.documents[i].data["Image3"];
            nueva.listaDeImagenes.add(ImagenURL3);
          }
          if (datos.documents[i].data["Image4"] != null) {
            String ImagenURL4 = datos.documents[i].data["Image4"];
            nueva.listaDeImagenes.add(ImagenURL4);
          }
          if (datos.documents[i].data["Image5"] != null) {
            String ImagenURL5 = datos.documents[i].data["Image5"];
            nueva.listaDeImagenes.add(ImagenURL5);
          }
          if (datos.documents[i].data["Image6"] != null) {
            String ImagenURL6 = datos.documents[i].data["Image6"];
            nueva.listaDeImagenes.add(ImagenURL6);
          }
          nueva.imagenUrl1 = datos.documents[i].data["Image1"];
          nueva.imagenUrl2 = datos.documents[i].data["Image2"];
          nueva.imagenUrl3 = datos.documents[i].data["Image3"];
          nueva.imagenUrl4 = datos.documents[i].data["Image4"];
          nueva.imagenUrl5 = datos.documents[i].data["Image5"];
          nueva.imagenUrl6 = datos.documents[i].data["Image6"];
          nueva.nombreEvento = datos.documents[i].data["Nombre"];
          nueva.participantesEvento =
              datos.documents[i].data["Cantidad Participantes"];
          nueva.comentariosEvento = datos.documents[i].data["Comentarios"];
          nueva._fechaEvento =
              dia.format(datos.documents[i].data["Fecha"].toDate());
          nueva.fechaEvento = datos.documents[i].data["Fecha"].toDate();
          nueva.ubicacionEvento = datos.documents[i].data["Lugar"];
          nueva.participantesEvento =
              datos.documents[i].data["Plazas Disponibles"];
          nueva.creadorEvento = datos.documents[i].data["Creador Plan"];
          nueva.codigoEvento = datos.documents[i].data["Codigo Plan"];
          /*      if (nueva.imagenUrl1 != null) {
            nueva.listaDeImagenes.add(nueva.imagenUrl1);
            nueva.fotosEventoEditar.add(EditarFotoEvento(
                esteEvento: nueva, box: 0, Imagen: nueva._Images_List[0]));
          }
          if (nueva.imagenUrl2 != null) {
            nueva.listaDeImagenes.add(nueva.imagenUrl2);
            nueva.fotosEventoEditar.add(EditarFotoEvento(
                esteEvento: nueva, box: 1, Imagen: nueva._Images_List[1]));
          }
          if (nueva.imagenUrl3 != null) {
            nueva.listaDeImagenes.add(nueva.imagenUrl3);
            nueva.fotosEventoEditar.add(EditarFotoEvento(
                esteEvento: nueva, box: 2, Imagen: nueva._Images_List[2]));
          }
          if (nueva.imagenUrl4 != null) {
            nueva.listaDeImagenes.add(nueva.imagenUrl4);
            nueva.fotosEventoEditar.add(EditarFotoEvento(
                esteEvento: nueva, box: 3, Imagen: nueva._Images_List[3]));
          }
          if (nueva.imagenUrl5 != null) {
            nueva.listaDeImagenes.add(nueva.imagenUrl5);
            nueva.fotosEventoEditar.add(EditarFotoEvento(
                esteEvento: nueva, box: 4, Imagen: nueva._Images_List[4]));
          }
          if (nueva.imagenUrl6 != null) {
            nueva.listaDeImagenes.add(nueva.imagenUrl6);
            nueva.fotosEventoEditar.add(EditarFotoEvento(
                esteEvento: nueva, box: 5, Imagen: nueva._Images_List[5]));
          }*/

          for (int i = 0; i < 6; i++) {
            nueva.fotosEventoEditar.add(EditarFotoEvento(
                esteEvento: nueva,
                box: indiceListaImagenes,
                Imagen: nueva._Images_List[indiceListaImagenes]));
            indiceListaImagenes += 1;
          }

          evento = new EventosPropios(eventoPropio: nueva);
          listaEventosPropios.add(evento);
        }
      }
    });
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
  bool dejarDeBuscarImagen = true;
  TarjetaEventoPropio({@required this.evento}) {
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
                builder: (context) =>
                    PantallaDetallesEventoPropio(evento: widget.evento))),
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
  TextEditingController controladorNombreEvento;
  TextEditingController controladorLugarEvento;
  TextEditingController controladorComentariosEvento;

  PantallaDetallesEventoPropio({@required this.evento}) {}
  @override
  _PantallaDetallesEventoPropioState createState() =>
      _PantallaDetallesEventoPropioState();
}

class _PantallaDetallesEventoPropioState
    extends State<PantallaDetallesEventoPropio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int indice) {
                      return Container(
                          padding: const EdgeInsets.all(10),
                          child: widget.evento.fotosEventoEditar[indice]);
                    }),
              ),
              Container(
                child: FlatButton(
                    onPressed: () {},
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
                    onPressed: () {},
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
                        child: TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: widget.evento.nombreEvento),
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
                      Container(
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
                              child: TextField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: widget.evento.nombreEvento),
                              ),
                            ),
                          ],
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
                                  lastDate: DateTime(2100)).then((value) =>widget.evento.fechaEvento),
                              child: Container(
                                height: ScreenUtil().setHeight(180),
                                width: ScreenUtil().setWidth(500),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3))),
                                child: Center(
                                  child: Text(widget.evento._fechaEvento),
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
                                onPressed: () {},
                                child: Text("Cancelar"),
                              )),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                                color: Colors.green),
                            child: FlatButton(
                                onPressed: () {}, child: Text("Guardar")),
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
    );
  }
}

class EditarFotoEvento extends StatefulWidget {
  int box;
  File Imagen;
  bool imagenDesdeRed = true;
  Actividad esteEvento;

  EditarFotoEvento(
      {@required this.box, @required this.Imagen, @required this.esteEvento}) {
    if (esteEvento.listaDeImagenes.length > box) {
      print("Comparando");
      for (int i = 0; i < esteEvento.listaDeImagenes.length; i++) {
        if (esteEvento.listaDeImagenes[box] == null) {
          imagenDesdeRed = false;
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

class EditarFotoEventoState extends State<EditarFotoEvento> {
  @override
  File Image_picture;
  File imagen;
  File imagenFinal;
  Firestore baseDatosRef = Firestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  Map<String, dynamic> imagenEvento = Map();

  static List<File> pictures = List(6);
  int box;
  EditarFotoEventoState(this.box, this.imagen) {}
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
    if (widget.box >= widget.esteEvento.listaDeImagenes.length) {
      widget.imagenDesdeRed = false;
    }
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
                widget.imagenDesdeRed
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

class when_button extends StatefulWidget {
  String birth;
  when_button(String birth) {
    this.birth = birth;
  }
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return when_button_state(birth);
  }
}

class when_button_state extends State<when_button> {
  String birth_text;
  DateTime date;
  static int age;
  when_button_state(String birth_text) {
    this.birth_text = birth_text;
  }
  static int GetAge() {
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setWidth(470),
          height: ScreenUtil().setHeight(120),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: RaisedButton(
              color: Colors.deepPurple,
              elevation: 0,
              onPressed: () {
                setState(() {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100))
                      .then((data) {
                    if (data != null) {
                      DateTime dato = data;
                      plan_date_shower_state.fecha_final.value = dato;
                    }

                    print(data);
                    return data;
                  });
                });
              },
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.today,
                  size: ScreenUtil().setSp(70),
                  color: Colors.white,
                ),
                Text(
                  birth_text,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(70), color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class plan_date_shower extends StatefulWidget {
  String formatted_data;
  Actividad esteEvento;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return plan_date_shower_state();
  }
}

class plan_date_shower_state extends State<plan_date_shower> {
  var f = new DateFormat('dd-MM-yyyy');
  var h = new DateFormat('yyyy-MM-dd');
  var temp;

  static ValueNotifier<DateTime> fecha_final = ValueNotifier<DateTime>(null);
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setWidth(400),
          height: ScreenUtil().setHeight(120),
          child: Material(
            color: Colors.white,
            elevation: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              child: Center(
                  child: ValueListenableBuilder(
                      valueListenable: fecha_final,
                      builder: (BuildContext context, fecha, Widget child) {
                        if (fecha == null) {
                          return Text(
                            "   -   -   - ",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(60),
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          );
                        } else {
                          temp = h.format(fecha);
                          widget.esteEvento.Fecha = temp;
                          return Text(
                            f.format(fecha),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(60),
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          );
                        }
                      })),
            ),
          ),
        ),
      ],
    );
  }
}

class hour_button extends StatefulWidget {
  String birth;

  hour_button(String birth) {
    this.birth = birth;
  }
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return hour_button_state(birth);
  }
}

class hour_button_state extends State<hour_button> {
  DateTime Time;
  String birth_text;
  DateTime date;
  static int age;
  hour_button_state(String birth_text) {
    this.birth_text = birth_text;
  }
  static int GetAge() {
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setWidth(470),
          height: ScreenUtil().setHeight(120),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: RaisedButton(
              color: Colors.deepPurple,
              elevation: 0,
              onPressed: () {
                DatePicker.showTimePicker(context, showSecondsColumn: false,
                    onConfirm: (time) {
                  print(time);
                  setState(() {
                    Time = time;
                    plan_hour_shower_state.fecha_final.value = Time;
                  });
                });
              },
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.access_time,
                  size: ScreenUtil().setSp(70),
                  color: Colors.white,
                ),
                Text(
                  birth_text,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(70), color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class plan_hour_shower extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return plan_hour_shower_state();
  }
}

class plan_hour_shower_state extends State<plan_hour_shower> {
  final f = new DateFormat('HH:mm');
  static DateTime Hora;
  static ValueNotifier<DateTime> fecha_final = ValueNotifier<DateTime>(Hora);
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setWidth(400),
          height: ScreenUtil().setHeight(120),
          child: Material(
            color: Colors.white,
            elevation: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              child: Center(
                  child: ValueListenableBuilder(
                      valueListenable: fecha_final,
                      builder: (BuildContext context, fecha, Widget child) {
                        print("$fecha en casa");
                        if (fecha == null) {
                          return SizedBox(
                            width: ScreenUtil().setWidth(300),
                            child: Text(
                              "  ",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(60),
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        } else {
                          Actividad.esteEvento.Hora = f.format(fecha);

                          return Text(
                            f.format(fecha),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(60),
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold),
                          );
                        }
                      })),
            ),
          ),
        ),
      ],
    );
  }
}
