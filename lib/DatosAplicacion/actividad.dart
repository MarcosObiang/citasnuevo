import 'dart:core';
import 'dart:math';
import 'dart:typed_data';
import 'package:citasnuevo/InterfazUsuario/Actividades/TarjetaEvento.dart';
import 'package:citasnuevo/ServidorFirebase/firebase_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:intl/intl.dart';
import 'Usuario.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class Actividad with ChangeNotifier {
  static Actividad esteEvento = new Actividad();
  static Actividad cacheActividadesParaTi = new Actividad();
  List<Actividad> listaEventos = new List();

  int contadorPrueba = 0;
  void aumentarContador() {
    contadorPrueba += 1;
    notifyListeners();
  }

  String nombreEvento;
  List<Widget> carrete = new List();
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
  bool _coches = false;
  bool _juegos = false;
  bool _cine = false;
  bool _manualidades = false;
  bool _comida = false;
  bool _moda = false;
  bool _animales = false;
  bool _musica = false;
  bool _naturaleza = false;
  bool _ciencia = false;
  bool _politica = false;
  bool _viajes = false;
  bool _fiesta = false;
  bool _salud = false;
  bool _vida_social = false;
  bool _deportes = false;
  final databaseReference = Firestore.instance;
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
  void EstablecerGustos() {
    assert(gustos != null);
    gustos["Automoviles"] = esteEvento.coches;
    gustos["Videojuegos"] = esteEvento.juegos;
    gustos["Cine"] = esteEvento.cine;
    gustos["Manualidades y Bricolaje"] = esteEvento.manualidades;
    gustos["Comida"] = esteEvento.comida;
    gustos["Moda y Belleza"] = esteEvento.moda;
    gustos["Animales"] = esteEvento.animales;
    gustos["Musica"] = esteEvento.musica;
    gustos["Naturaleza"] = esteEvento.naturaleza;
    gustos["Ciencia y Tecnologias"] = esteEvento.ciencia;
    gustos["Politica y Sociedad"] = esteEvento.politica;
    gustos["Viajes y Turismo"] = esteEvento.viajes;
    gustos["Fiesta"] = esteEvento.fiesta;
    gustos["Salud"] = esteEvento.salud;
    gustos["Vida Social"] = esteEvento.vida_social;
    gustos["Fitness y Deporte"] = esteEvento.deportes;
  }

  String getCodigo() {
    return codigoEvento;
  }

  void CrearPlan() {
    assert(gustos != null);
    if (esteEvento.tipoPlan == "Individual") {
      esteEvento.participantesEvento = 1;
    }
    EstablecerGustos();
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
    CopiaPlan["Creador Plan"] = FirebaseManager.UID;

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
    String v = esteEvento.crearCodigo();
    final Codigo = v;
    esteEvento.codigoEvento = v;
    assert(esteEvento.codigoEvento != null);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    if (Images_List[0] != null) {
      String Image1 =
          "${FirebaseManager.UID}/Planes/${Codigo}/imagenes/Image1.jpg";
      StorageReference ImagesReference = reference.child(Image1);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[0]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      imagenUrl1 = URL;
      print(URL);
    }

    if (Images_List[1] != null) {
      String Image2 =
          "${FirebaseManager.UID}/Planes/${esteEvento.codigoEvento}/imagenes/Image2.jpg";
      StorageReference ImagesReference = reference.child(Image2);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[1]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl2 = URL;
    }
    if (Images_List[2] != null) {
      String Image3 =
          "${FirebaseManager.UID}/Planes/${esteEvento.codigoEvento}/imagenes/Image3.jpg";
      StorageReference ImagesReference = reference.child(Image3);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[2]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl3 = URL;
    }
    if (Images_List[3] != null) {
      String Image4 =
          "${FirebaseManager.UID}/Planes/${esteEvento.codigoEvento}/imagenes/Image4.jpg";
      StorageReference ImagesReference = reference.child(Image4);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[3]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      imagenUrl4 = URL;
    }
    if (Images_List[4] != null) {
      String Image5 =
          "${FirebaseManager.UID}/Planes/${esteEvento.codigoEvento}/imagenes/Image5.jpg";
      StorageReference ImagesReference = reference.child(Image5);
      StorageUploadTask uploadTask = ImagesReference.putFile(Images_List[4]);
      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(URL);
      ImageURL5 = URL;
    }
    if (Images_List[5] != null) {
      String Image6 =
          "${FirebaseManager.UID}/Planes/${esteEvento.codigoEvento}/imagenes/Image6.jpg";
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
          .document(FirebaseManager.UID)
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

  bool get juegos => _juegos;

  set juegos(bool value) {
    _juegos = value;
    notifyListeners();
  }

  bool get coches => _coches;

  set coches(bool value) {
    _coches = value;
    notifyListeners();
  }

  bool get cine => _cine;

  set cine(bool value) {
    _cine = value;
    notifyListeners();
  }

  bool get manualidades => _manualidades;

  set manualidades(bool value) {
    _manualidades = value;
    notifyListeners();
  }

  bool get comida => _comida;

  set comida(bool value) {
    _comida = value;
    notifyListeners();
  }

  bool get moda => _moda;

  set moda(bool value) {
    _moda = value;
    notifyListeners();
  }

  bool get animales => _animales;

  set animales(bool value) {
    _animales = value;
    notifyListeners();
  }

  bool get musica => _musica;

  set musica(bool value) {
    _musica = value;
    notifyListeners();
  }

  bool get naturaleza => _naturaleza;

  set naturaleza(bool value) {
    _naturaleza = value;
    notifyListeners();
  }

  bool get ciencia => _ciencia;

  set ciencia(bool value) {
    _ciencia = value;
    notifyListeners();
  }

  bool get politica => _politica;

  set politica(bool value) {
    _politica = value;
    notifyListeners();
  }

  bool get viajes => _viajes;

  set viajes(bool value) {
    _viajes = value;
    notifyListeners();
  }

  bool get fiesta => _fiesta;

  set fiesta(bool value) {
    _fiesta = value;
    notifyListeners();
  }

  bool get salud => _salud;

  set salud(bool value) {
    _salud = value;
    notifyListeners();
  }

  bool get vida_social => _vida_social;

  set vida_social(bool value) {
    _vida_social = value;
    notifyListeners();
  }

  bool get deportes => _deportes;

  set deportes(bool value) {
    _deportes = value;
    notifyListeners();
  }

  Future<List<DocumentSnapshot>> ObtenerActividad() async {
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
    ActualizarEventos(EventosUsuarioTemp);
    return EventosUsuario;
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

  void ActualizarEventos(List<DocumentSnapshot> lista) {
    print("CarreteCreado****************************************************************************************************++++++");
    TarjetaEvento tarjeta;
    Timestamp tiempo;
    DateTime tiempoTransformado;
   
    
    final f = new DateFormat('dd-MM-yyyy HH:mm');
  print(
            "${lista.length}***********************************************++++++");
    for (int i = 0; i < lista.length; i++) {
      Actividad nueva=new Actividad();
      List<Widget> carreteEnLista=new List();
       creadorImagenesEvento carreteCreado;
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
       print(
            "${Imagenes.length}***********************************************++++++");
      for (int a = 0; a < Imagenes.length; a++) {
       
        if (Imagenes[a] != null) {
          // print("CarreteCreado****************************************************************************************************++++++");
          carreteCreado = new creadorImagenesEvento(
            Imagenes[a],
            nombre: lista[i].data["Nombre"],
            alias: lista[i].data["Lugar"],
            edad: "30",
            nombreEnFoto: true,
          );
          carreteEnLista=List.from(carreteEnLista)..add(carreteCreado);
        }
      }

      nueva.carrete = carreteEnLista;

      listaEventos = List.from(listaEventos)..add(nueva);
    }

    if (listaEventos.length != 0) {
      notifyListeners();
      print(listaEventos.length);
    }
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

  creadorImagenesEvento(this.urlImagen,
      {this.nombre, this.alias, this.edad, this.pieFoto, this.nombreEnFoto}) {
    //cargarImagen();
  }

  @override
  creadorImagenesEventoState createState() => creadorImagenesEventoState();
}

class creadorImagenesEventoState extends State<creadorImagenesEvento> {
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
                      widget.laimagen,
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
