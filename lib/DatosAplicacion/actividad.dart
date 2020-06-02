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
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/TarjetaEvento.dart';
import 'package:citasnuevo/ServidorFirebase/firebase_manager.dart';

import 'Usuario.dart';

Future<List<Map<String, Object>>> ActualizarEventos(
    List<DocumentSnapshot> lista) async {
  TarjetaEvento tarjeta;
  Timestamp tiempo;
  DateTime tiempoTransformado;
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
    String ImagenURL1 = lista[i].data["Image1"];
    String ImagenURL2 = lista[i].data["Image2"];
    String ImagenURL3 = lista[i].data["Image3"];
    String ImagenURL4 = lista[i].data["Image4"];
    String ImagenURL5 = lista[i].data["Image5"];
    String ImagenURL6 = lista[i].data["Image6"];
    List<String> Imagenes;
    Imagenes = [
      ImagenURL1,
      ImagenURL2,
      ImagenURL3,
      ImagenURL4,
      ImagenURL5,
      ImagenURL6
    ];

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
    eventosLista = List.from(eventosLista)..add(eventoUnico);
  }

  // listaTemporal.add(cache);
  //listaTemporal["Actividad"].principal=cache;
  // listaTemporal.add(10);

  return eventosLista;
}

class Actividad with ChangeNotifier {
  static Actividad esteEvento;
  static Actividad cacheActividadesParaTi;
  List<Actividad> listaEventos = new List();

  int contadorPrueba = 0;
  void aumentarContador() {
    contadorPrueba += 1;
    notifyListeners();
  }

  String nombreEvento;
  List<Widget> carrete = new List();
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
  String ImageURL5;
  String ImageURL6;
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
    this.ImageURL5,
    this.ImageURL6,
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
    plan["Image5"] = esteEvento.ImageURL5;
    plan["Image6"] = esteEvento.ImageURL6;
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
      ImageURL5 = URL;
    }
    if (Images_List[5] != null) {
      String Image6 =
          "${Usuario.esteUsuario.idUsuario}/Planes/${esteEvento.codigoEvento}/imagenes/Image6.jpg";
      StorageReference ImagesReference = reference.child(Image6);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[5]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      ImageURL6 = URL;
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

class TarjetaSolicitudEvento extends StatefulWidget {
  String imagen;
  String nombreSolicitante;
  DateTime fechaEvento;
  String lugarEvento;
  @override
  _TarjetaSolicitudEventoState createState() => _TarjetaSolicitudEventoState();
}

class _TarjetaSolicitudEventoState extends State<TarjetaSolicitudEvento> {
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
