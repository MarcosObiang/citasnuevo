import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/GeneradorCodigos.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/PantallaConversacion.dart';
import 'package:http/http.dart' as http;
import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/Mensajes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TituloChat extends StatefulWidget {
  List<Mensajes> listadeMensajes = new List();
  String idRemitente;
  String idConversacion;
  String estadoConversacion;
  bool estadoConexion;
  String imagen;
  String nombre;
  PantallaConversacion pantalla;

  int mensajesSinLeer=0;

  Map<String, dynamic> ultimoMensaje = new Map();
  String mensajeId;
  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
  Conversacion conversacion;

  TituloChat(
      {@required this.conversacion,
      @required this.estadoConexion,
      @required this.idConversacion,
      @required this.mensajesSinLeer,
      @required this.estadoConversacion,
      @required this.idRemitente,
      @required this.listadeMensajes,
      @required this.ultimoMensaje,
      @required this.nombre,
      @required this.imagen,
      this.mensajeId}) {
    if (listadeMensajes != null && listadeMensajes.length > 0) {}
  }

  Future<List<Mensajes>> obtenerMensajes(
      String identificadorMensajes, String rutaRemitente) async {
    List<Mensajes> temp = new List();
  
    



    if (!this.conversacion.grupo) {
      await baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("mensajes")
          .where("idMensaje", isEqualTo: identificadorMensajes)
          .limit(100)
          .get()
          .then((dato) async {
            if(dato!=null){

        if (dato.docs.length > 0) {
          print("${dato.docs.length} mensajes para el en firebase");
          print(rutaRemitente);
          print(identificadorMensajes);
    
          for (int a = 0; a < dato.docs.length; a++) {
 
            print(dato.docs[a].get("Tipo Mensaje"));
            if (dato.docs[a].get("Tipo Mensaje") == "Texto" ||
                dato.docs[a].get("Tipo Mensaje") == "Imagen" ||
                dato.docs[a].get("Tipo Mensaje") == "Gif") {
              Mensajes mensaje = new Mensajes(
               
                respuestaMensaje: dato.docs[a].get("mensajeRespuesta"),
                respuesta:dato.docs[a].get("respuesta") ,
                mensajeLeido: dato.docs[a].get("mensajeLeido"),
                nombreEmisor: dato.docs[a].get("Nombre emisor"),
                identificadorUnicoMensaje:
                    dato.docs[a].get("identificadorUnicoMensaje"),
                idEmisor: dato.docs[a].get("idEmisor"),
                idConversacion: dato.docs[a].get("idConversacion"),
                mensajeLeidoRemitente:
                    dato.docs[a].get("mensajeLeidoRemitente"),
                mensaje: dato.docs[a].get("Mensaje"),
                idMensaje: dato.docs[a].get("idMensaje"),
                horaMensaje: (dato.docs[a].get("Hora mensaje")).toDate(),
                tipoMensaje: dato.docs[a].get("Tipo Mensaje"),
              );
              temp = List.from(temp)..add(mensaje);
            }
            if (dato.docs[a].get("Tipo Mensaje") == "Audio") {
              Mensajes mensaje = new Mensajes.audio(
             respuesta:dato.docs[a].get("respuesta") ,
                duracionMensaje: dato.docs[a].get("duracion"),
                mensajeLeido: dato.docs[a].get("mensajeLeido"),
                respuestaMensaje: dato.docs[a].get("mensajeRespuesta"),
                idConversacion: dato.docs[a].get("idConversacion"),
                nombreEmisor: dato.docs[a].get("Nombre emisor"),
                idEmisor: dato.docs[a].get("idEmisor"),
                mensajeLeidoRemitente:
                    dato.docs[a].get("mensajeLeidoRemitente"),
                identificadorUnicoMensaje:
                    dato.docs[a].get("identificadorUnicoMensaje"),
                mensaje: dato.docs[a].get("Mensaje"),
                idMensaje: dato.docs[a].get("idMensaje"),
                horaMensaje: (dato.docs[a].get("Hora mensaje")).toDate(),
                tipoMensaje: dato.docs[a].get("Tipo Mensaje"),
              );

              temp = List.from(temp)..add(mensaje);
            }
          }
        }}
      });
    }

    if (temp.length > 0) {
      temp = insertarHoras(temp);
    }

    for(int v=0;v<temp.length;v++){
      if(temp[v].tipoMensaje!="SeparadorHora"){
 if(temp[v].respuesta){
        if(temp[v].respuestaMensaje["tipoMensaje"]=="Texto"){

          temp[v].widgetRespuesta=Container(
            color: temp[v].respuestaMensaje["idEmisorMensaje"]==Usuario.esteUsuario.idUsuario?Colors.blue:Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.start,children: [
              temp[v].respuestaMensaje["idEmisorMensaje"]==Usuario.esteUsuario.idUsuario?Text("Yo"):Text(nombre),
             
              Text(temp[v].respuestaMensaje["mensaje"])

            ],),
          );
        }
         if(temp[v].respuestaMensaje["tipoMensaje"]=="Imagen"){

          temp[v].widgetRespuesta=Container(
            color: temp[v].respuestaMensaje["idEmisorMensaje"]==Usuario.esteUsuario.idUsuario?Colors.blue:Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.start,children: [
              temp[v].respuestaMensaje["idEmisorMensaje"]==Usuario.esteUsuario.idUsuario?Text("Yo"):Text(nombre),
            
              Container(
                                      decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(temp[v].respuestaMensaje["mensaje"],
                    scale: 1,
               )),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.transparent,
                  ),
                                 height: 500.w,width: 500.w,)

            ],),
          );
        }
          if(temp[v].respuestaMensaje["tipoMensaje"]=="Gif"){

          temp[v].widgetRespuesta=Container(
            
            color: temp[v].respuestaMensaje["idEmisorMensaje"]==Usuario.esteUsuario.idUsuario?Colors.blue:Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              temp[v].respuestaMensaje["idEmisorMensaje"]==Usuario.esteUsuario.idUsuario?Text("Yo"):Text(nombre),
    
              Container(
                                      decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(temp[v].respuestaMensaje["mensaje"],
                    scale: 1,
                      headers: {'accept': 'image/*'})
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.transparent,
                  ),
                                 height: 700.w,width: 700.w,) 

            ],),
          );
        }
                  if(temp[v].respuestaMensaje["tipoMensaje"]=="Audio"){
                     Mensajes mensajeRespuestaAudio;
                         for(int z=0;z<Conversacion.conversaciones.listaDeConversaciones.length;z++ ){
        if(Conversacion.conversaciones.listaDeConversaciones[z].idMensajes==temp[v].idMensaje){
          for(int i=0;i<Conversacion.conversaciones.listaDeConversaciones[z].ventanaChat.listadeMensajes.length;i++){
            if(temp[v].respuestaMensaje["idMensaje"]==Conversacion.conversaciones.listaDeConversaciones[z].ventanaChat.listadeMensajes[i].identificadorUnicoMensaje){
              mensajeRespuestaAudio=Conversacion.conversaciones.listaDeConversaciones[z].ventanaChat.listadeMensajes[i];

            }
          }
        }
      }

          temp[v].widgetRespuesta=Container(
            color: temp[v].respuestaMensaje["idEmisorMensaje"]==Usuario.esteUsuario.idUsuario?Colors.blue:Colors.green,
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.start,
              children: [
              temp[v].respuestaMensaje["idEmisorMensaje"]==Usuario.esteUsuario.idUsuario?Text("Yo"):Text(nombre),
           
              Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(3),
                            topRight: Radius.circular(3),
                            bottomLeft: Radius.circular(3))),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 3,
                          child: Container(
                            child: Center(
                              child: FlatButton(
                                onPressed: () {
                                  mensajeRespuestaAudio.reproducirAudio();
                                },
                                child: Center(
                                    child: Icon(
                                  Icons.play_arrow,
                                  size: ScreenUtil().setSp(100),
                                )),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 11,
                          child: Container(
                            child: Stack(alignment: Alignment.center, children: <
                                Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15.0, right: 15),
                                child: LinearPercentIndicator(
                                  lineHeight: ScreenUtil().setHeight(70),
                                  percent: mensajeRespuestaAudio.posicion,
                                ),
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  thumbColor: Colors.transparent,
                                  activeTickMarkColor: Colors.transparent,
                                  activeTrackColor: Colors.transparent,
                                  disabledActiveTickMarkColor: Colors.transparent,
                                  disabledActiveTrackColor: Colors.transparent,
                                  disabledInactiveTickMarkColor:
                                      Colors.transparent,
                                  disabledInactiveTrackColor: Colors.transparent,
                                  disabledThumbColor: Colors.transparent,
                                  inactiveTickMarkColor: Colors.transparent,
                                  inactiveTrackColor: Colors.transparent,
                                  overlappingShapeStrokeColor: Colors.transparent,
                                  overlayColor: Colors.transparent,
                                  valueIndicatorColor: Colors.transparent,
                                ),
                                child: Slider(
                                  value: mensajeRespuestaAudio.posicion,
                                  max: mensajeRespuestaAudio.duracionMensaje.toDouble(),
                                  min: 0,
                                  onChanged: (val) {
                                    mensajeRespuestaAudio.posicionAudio(val);
                                  },
                                ),
                              ),
                            ]),
                          ),
                        )
                      ],
                    ),
                  ),

            ],),
          );
        }
        
        
      }
      }
     

    }

    return temp;
  }

  List<Mensajes> insertarHoras(List<Mensajes> datos) {
    List<Mensajes> lista = datos;
    if (lista != null) {
      print("ordenado");
      lista.sort((b, c) => b.horaMensaje.compareTo(c.horaMensaje));
    }

    DateTime cacheTiempo = lista[0].horaMensaje;
    int cacheDia = lista[0].horaMensaje.day;
    Mensajes horaSeparador;

    horaSeparador = Mensajes.separadorHora(
      horaMensaje: cacheTiempo,
      idEmisor: lista[0].idEmisor,
    );
    lista.insert(0, horaSeparador);
    for (int i = 0; i < lista.length; i++) {
      if (cacheDia != lista[i].horaMensaje.day) {
        horaSeparador = Mensajes.separadorHora(
          horaMensaje: lista[i].horaMensaje,
          idEmisor: lista[i].idEmisor,
        );

        cacheTiempo = lista[i].horaMensaje;
        cacheDia = lista[i].horaMensaje.day;
        lista.insert(i, horaSeparador);
      }
    }
    return lista;
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

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TituloChatState(imagen, nombre, ultimoMensaje);
  }

  void enviarMensaje(
    String mensajeTexto,
    String idMensaje,
    bool respuesta,
    Map<String,String>respuestaEnMensaje
  ) async {
    WriteBatch escrituraMensajes = baseDatosRef.batch();
    String idMensajeUnico =  GeneradorCodigos.instancia.crearCodigo();
    DocumentReference direccionMensajes = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("mensajes")
        .doc(idMensajeUnico);
    DocumentReference direccionMensajesUsuario = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .doc(idMensajeUnico);
    DocumentReference referenciaConversacionRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);
    DocumentReference referenciaConversacionUsuario = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(idConversacion);

    if (!this.conversacion.grupo) {
      if (mensajeTexto != null) {
        Map<String, dynamic> mensaje = Map();
        DateTime horaMensaje = DateTime.now();
        mensaje["Hora mensaje"] = horaMensaje;
        mensaje["Mensaje"] = mensajeTexto;
        mensaje["idMensaje"] = idMensaje;
        mensaje["mensajeLeido"] = false;
        mensaje["mensajeLeidoRemitente"] = false;
        mensaje["Nombre emisor"] = Usuario.esteUsuario.nombre;
        mensaje["idConversacion"] = idConversacion;
        mensaje["identificadorUnicoMensaje"] = idMensajeUnico;
        mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
        mensaje["Tipo Mensaje"] = "Texto";
        mensaje["mensajeRespuesta"]=respuestaEnMensaje;
        mensaje["respuesta"]=respuesta;

        escrituraMensajes.update(referenciaConversacionRemitente, {
          "cantidadMensajesSinLeer": FieldValue.increment(1),
          "ultimoMensaje": {
            "mensaje": mensaje["Mensaje"],
            "tipoMensaje": "texto",
            "duracion": 0
          }
        });
        escrituraMensajes.update(referenciaConversacionUsuario, {
          "ultimoMensaje": {
            "mensaje": mensaje["Mensaje"],
            "tipoMensaje": "texto",
            "duracion": 0
          }
        });
        escrituraMensajes.set(direccionMensajes, mensaje);
        escrituraMensajes.set(direccionMensajesUsuario, mensaje);
        await escrituraMensajes.commit();
      }
    }

  }

  void enviarMensajeAudio(
      Uint8List audio, String idMensaje, int duracion,bool respuesta,
    Map<String,String>respuestaEnMensaje) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    String idMensajeUnico =  GeneradorCodigos.instancia.crearCodigo();
    String ruta = "${idRemitente}/Perfil/NotasVoz/${crearCodigo()}.aac";
    StorageReference referenciaArchivo = reference.child(ruta);
    WriteBatch escrituraMensajes = baseDatosRef.batch();
    DocumentReference direccionMensajes = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("mensajes")
        .doc(idMensajeUnico);

    DocumentReference direccionMensajesUsuario = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .doc(idMensajeUnico);
    DocumentReference referenciaConversacionRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);
    DocumentReference referenciaConversacionUsuario = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(idConversacion);

    StorageUploadTask task = referenciaArchivo.putData(audio);
    var url = await (await task.onComplete).ref.getDownloadURL();
    if (audio != null) {
      Map<String, dynamic> mensaje = Map();
      DateTime horaMensaje = DateTime.now();
      mensaje["Hora mensaje"] = horaMensaje;
      mensaje["Mensaje"] = url;
      mensaje["idMensaje"] = idMensaje;
      mensaje["mensajeLeido"] = false;
      mensaje["mensajeLeidoRemitente"] = false;
      mensaje["idConversacion"] = idConversacion;
      mensaje["identificadorUnicoMensaje"] = idMensajeUnico;
      mensaje["Nombre emisor"] = Usuario.esteUsuario.nombre;
      mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
      mensaje["duracion"] = duracion;
      mensaje["Tipo Mensaje"] = "Audio";
      mensaje["mensajeRespuesta"]=respuestaEnMensaje;
      mensaje["respuesta"]=respuesta;
      print(idRemitente);
      if (this.conversacion.grupo) {
        await baseDatosRef
            .collection("grupos directo")
            .doc(this.conversacion.idConversacion)
            .collection("mensajes")
            .doc()
            .set(mensaje);
      }
      if (!this.conversacion.grupo) {
        escrituraMensajes.update(referenciaConversacionRemitente, {
          "cantidadMensajesSinLeer": FieldValue.increment(1),
          "ultimoMensaje": {
            "mensaje": mensaje["Mensaje"],
            "tipoMensaje": "audio",
            "duracion": duracion
          }
        });
        escrituraMensajes.update(referenciaConversacionUsuario, {
          "ultimoMensaje": {
            "mensaje": mensaje["Mensaje"],
            "tipoMensaje": "audio",
            "duracion": duracion
          }
        });
        escrituraMensajes.set(direccionMensajes, mensaje);
        escrituraMensajes.set(direccionMensajesUsuario, mensaje);
        await escrituraMensajes.commit();
      }
    }
  }

  void enviarMensajeImagen(File imagen, String idMensaje,bool respuesta,
    Map<String,String>respuestaEnMensaje) async {
    if (imagen != null) {
      FirebaseStorage storage = FirebaseStorage.instance;
      String idMensajeUnico =  GeneradorCodigos.instancia.crearCodigo();
      StorageReference reference = storage.ref();
      String ruta =
          "${idRemitente}/Perfil/ImagenesConversaciones/${crearCodigo()}.jpg";
      StorageReference referenciaArchivo = reference.child(ruta);
      WriteBatch escrituraMensajes = baseDatosRef.batch();
      DocumentReference direccionMensajes = baseDatosRef
          .collection("usuarios")
          .doc(idRemitente)
          .collection("mensajes")
          .doc(idMensajeUnico);
      DocumentReference direccionMensajesUsuario = baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("mensajes")
          .doc(idMensajeUnico);
      DocumentReference referenciaConversacionRemitente = baseDatosRef
          .collection("usuarios")
          .doc(idRemitente)
          .collection("conversaciones")
          .doc(idConversacion);
      DocumentReference referenciaConversacionUsuario = baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("conversaciones")
          .doc(idConversacion);

      StorageUploadTask task = referenciaArchivo.putFile(imagen);
      var url = await (await task.onComplete).ref.getDownloadURL();
      if (imagen != null) {
        Map<String, dynamic> mensaje = Map();
        DateTime horaMensaje = DateTime.now();
        mensaje["Hora mensaje"] = horaMensaje;
        mensaje["Mensaje"] = url;
        mensaje["idMensaje"] = idMensaje;
        mensaje["mensajeLeido"] = false;
        mensaje["mensajeLeidoRemitente"] = false;
        mensaje["idConversacion"] = idConversacion;
        mensaje["identificadorUnicoMensaje"] = idMensajeUnico;
        mensaje["Nombre emisor"] = Usuario.esteUsuario.nombre;
        mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
        mensaje["Tipo Mensaje"] = "Imagen";
          mensaje["mensajeRespuesta"]=respuestaEnMensaje;
      mensaje["respuesta"]=respuesta;
      
        
        print(idRemitente);
        if (conversacion.grupo) {
          await baseDatosRef
              .collection("grupos directo")
              .doc(idRemitente)
              .collection("mensajes")
              .doc()
              .set(mensaje)
              .then((value) {
            print("ImagenEnviada");
          });
        }
        if (!conversacion.grupo) {
          escrituraMensajes.update(referenciaConversacionRemitente, {
            "cantidadMensajesSinLeer": FieldValue.increment(1),
            "ultimoMensaje": {
              "mensaje": mensaje["Mensaje"],
              "tipoMensaje": "imagen",
              "duracion": 0
            }
          });
          escrituraMensajes.update(referenciaConversacionUsuario, {
            "ultimoMensaje": {
              "mensaje": mensaje["Mensaje"],
              "tipoMensaje": "imagen",
              "duracion": 0
            }
          });
          escrituraMensajes.set(direccionMensajes, mensaje);
          escrituraMensajes.set(direccionMensajesUsuario, mensaje);

          await escrituraMensajes.commit();
        }
      }
    }
  }

  void enviarMensajeImagenGif(String urlImagen, String idMensaje,bool respuesta,
    Map<String,String>respuestaEnMensaje) async {
    http.get(urlImagen).then((value) async {
      if (urlImagen != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        String idMensajeUnico =  GeneradorCodigos.instancia.crearCodigo();
        StorageReference reference = storage.ref();
        String ruta =
            "$idRemitente/Perfil/ImagenesConversaciones/${crearCodigo()}.gif";
        StorageReference referenciaArchivo = reference.child(ruta);
        WriteBatch escrituraMensajes = baseDatosRef.batch();
        DocumentReference direccionMensajes = baseDatosRef
            .collection("usuarios")
            .doc(idRemitente)
            .collection("mensajes")
            .doc(idMensajeUnico);
        DocumentReference direccionMensajesUsuario = baseDatosRef
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("mensajes")
            .doc(idMensajeUnico);
        DocumentReference referenciaConversacionRemitente = baseDatosRef
            .collection("usuarios")
            .doc(idRemitente)
            .collection("conversaciones")
            .doc(idConversacion);
        DocumentReference referenciaConversacionUsuario = baseDatosRef
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("conversaciones")
            .doc(idConversacion);

        if (urlImagen != null) {
          Map<String, dynamic> mensaje = Map();
          DateTime horaMensaje = DateTime.now();
          mensaje["Hora mensaje"] = horaMensaje;
          mensaje["Mensaje"] = urlImagen;
          mensaje["idMensaje"] = idMensaje;
          mensaje["mensajeLeido"] = false;
          mensaje["mensajeLeidoRemitente"] = false;
          mensaje["idConversacion"] = idConversacion;
          mensaje["identificadorUnicoMensaje"] = idMensajeUnico;
          mensaje["Nombre emisor"] = Usuario.esteUsuario.nombre;
          mensaje["idEmisor"] = Usuario.esteUsuario.idUsuario;
          mensaje["Tipo Mensaje"] = "Gif";
           mensaje["mensajeRespuesta"]=respuestaEnMensaje;
      mensaje["respuesta"]=respuesta;
          print(idRemitente);
          if (conversacion.grupo) {
            await baseDatosRef
                .collection("grupos directo")
                .doc(idRemitente)
                .collection("mensajes")
                .doc()
                .set(mensaje)
                .then((value) {
              print("ImagenEnviada");
            });
          }
          if (!conversacion.grupo) {
            escrituraMensajes.update(referenciaConversacionRemitente, {
              "cantidadMensajesSinLeer": FieldValue.increment(1),
              "ultimoMensaje": {
                "mensaje": mensaje["Mensaje"],
                "tipoMensaje": "gif",
                "duracion": 0
              }
            });
            escrituraMensajes.update(referenciaConversacionUsuario, {
              "ultimoMensaje": {
                "mensaje": mensaje["Mensaje"],
                "tipoMensaje": "gif",
                "duracion": 0
              }
            });
            escrituraMensajes.set(direccionMensajes, mensaje);
            escrituraMensajes.set(direccionMensajesUsuario, mensaje);

            await escrituraMensajes.commit();
          }
        }
      }
    });
  }

  void actualizarEstadoConversacion(bool estaEscribiendo) async {
    if (estaEscribiendo) {
      print("estaEscribiendo");
      print("Esta escribiendo para ${conversacion.idConversacion}");
      Map<String, dynamic> estadoConexionUsuario = Map();
      estadoConexionUsuario["Escribiendo"] = true;
      estadoConexionUsuario["Conectado"] = true;
      estadoConexionUsuario["IdConversacion"] = conversacion.idConversacion;
      estadoConexionUsuario["Hora Conexion"] = DateTime.now();
      await baseDatosRef
          .collection("usuarios")
          .doc(idRemitente)
          .collection("estados conversacion")
          .doc(idConversacion)
          .update(estadoConexionUsuario);
    }
    if (!estaEscribiendo) {
      print("No esta escribiensssssdo");
      Map<String, dynamic> estadoConexionUsuario = Map();
      estadoConexionUsuario["Escribiendo"] = false;
      estadoConexionUsuario["Conectado"] = true;
      estadoConexionUsuario["IdConversacion"] = conversacion.idConversacion;
      estadoConexionUsuario["Hora Conexion"] = DateTime.now();
      await baseDatosRef
          .collection("usuarios")
          .doc(idRemitente)
          .collection("estados conversacion")
          .doc(conversacion.idConversacion)
          .update(estadoConexionUsuario);
    }
  }
}

class TituloChatState extends State<TituloChat> {
  String imagen;
  String nombre;
  Map<String, dynamic> ultimoMensaje = Map();

  int cantidadMensajesSinLeer = 0;
  TituloChatState(
      String imagen, String nombre, Map<String, dynamic> ultimoMensaje) {
    this.imagen = imagen;
    this.nombre = nombre;
    this.ultimoMensaje = ultimoMensaje;
  }
  List<Mensajes> mensajes() {
    return widget.listadeMensajes;
  }

  String estadoEscribiendo() {
    return widget.estadoConversacion;
  }

  bool estadoConexionUsuario() {
    return widget.estadoConexion;
  }



  void dejarMensajeLeidoRemitente() async {
    FirebaseFirestore referenciaBaseDatos = FirebaseFirestore.instance;
    DocumentReference referenciaConversacion = referenciaBaseDatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(widget.idConversacion);
    WriteBatch escrituraLeidoMensajes = referenciaBaseDatos.batch();
    DocumentReference referenciaMensaje;
    if (widget.listadeMensajes != null) {
      for (int i = 0; i < widget.listadeMensajes.length; i++) {
        if (widget.listadeMensajes[i].mensajeLeidoRemitente == false &&
            widget.listadeMensajes[i].idEmisor !=
                Usuario.esteUsuario.idUsuario &&
            widget.listadeMensajes[i].mensaje != null) {
          widget.listadeMensajes[i].mensajeLeidoRemitente = true;
          referenciaMensaje = referenciaBaseDatos
              .collection("usuarios")
              .doc(widget.idRemitente)
              .collection("mensajes")
              .doc(widget.listadeMensajes[i].identificadorUnicoMensaje);
          escrituraLeidoMensajes
              .update(referenciaConversacion, {"cantidadMensajesSinLeer": 0});
          escrituraLeidoMensajes
              .update(referenciaMensaje, {"mensajeLeidoRemitente": true});
        }
      }
      await escrituraLeidoMensajes.commit().catchError((onError) {
        print(onError);
      });
    }
  }

  

  String mostrarDuracion(int duracion) {
    Duration duracionMensajeVoz = new Duration(milliseconds: duracion);
    String dosDigitos(int n) => n.toString().padLeft(2, "0");
    String dosDigitosMinutos =
        dosDigitos(duracionMensajeVoz.inMinutes.remainder(60));
    String dosDigitosSegundos =
        dosDigitos(duracionMensajeVoz.inSeconds.remainder(60));
    return "$dosDigitosMinutos:$dosDigitosSegundos";
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: Conversacion.conversaciones,
        child: Consumer<Conversacion>(
          builder: (BuildContext context, conversacion, Widget child) {
            
         cantidadMensajesSinLeer=   widget.mensajesSinLeer  ;
            widget.pantalla = PantallaConversacion(
              estadoConexion: estadoConexionUsuario,
              enviarMensajeImagenGif: widget.enviarMensajeImagenGif,
              idConversacion: widget.idConversacion,
              imagenId: widget.imagen,
              marcarMensajeLeidoRemitente: dejarMensajeLeidoRemitente,
              esGrupo: widget.conversacion.grupo,
              idRemitente: widget.idRemitente,
              recibirEstadoConversacionActualizado: estadoEscribiendo,
              estadoEscribiendoRemitente: widget.estadoConversacion,
              estadoConversacion: widget.actualizarEstadoConversacion,
              mensajesImagen: widget.enviarMensajeImagen,
              mensajesTexto: mensajes,
              nombre: nombre,
              mensajesEnviar: widget.enviarMensaje,
              mensajesAudio: widget.enviarMensajeAudio,
              mensajeId: widget.mensajeId,
            );

            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: FlatButton(
                onPressed: () async {
                  if (widget.listadeMensajes == null) {
                    widget.listadeMensajes = await widget.obtenerMensajes(
                        widget.mensajeId, widget.idRemitente);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => widget.pantalla));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => widget.pantalla));
                  }
                },
                child: Container(
                    height: ScreenUtil().setHeight(200),
                    decoration: BoxDecoration(
                      color: widget.mensajesSinLeer>0?Colors.purple[100]:Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 200.h,
                            width: 200.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                    widget.imagen,
                                  ),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Flexible(
                            flex: 6,
                            fit: FlexFit.tight,
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 5,
                                      fit: FlexFit.tight,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              height:
                                                  ScreenUtil().setHeight(100),
                                              child: nombre == null
                                                  ? Text("")
                                                  : Text(
                                                      widget.nombre,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(40),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                          widget.estadoConexion
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Container(
                                                    height: 50.w,
                                                    width: ScreenUtil()
                                                        .setWidth(50),
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.green,
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: ScreenUtil()
                                                                .setWidth(5))),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 5,
                                      fit: FlexFit.tight,
                                      child: Container(
                                          child: widget.estadoConversacion ==
                                                  "Escribiendo"
                                              ? Text(
                                                  "Escribiendo.....",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(40),
                                                      fontWeight:
                                                          cantidadMensajesSinLeer >
                                                                  0
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal),
                                                )
                                              : widget.ultimoMensaje == null
                                                  ? Container()
                                                  : widget.ultimoMensaje[
                                                              "tipoMensaje"] ==
                                                          "texto"
                                                      ? Text(widget.ultimoMensaje[
                                                                      "mensaje"] ==
                                                                  null ||
                                                              widget.ultimoMensaje[
                                                                      "mensaje"] ==
                                                                  "null"
                                                          ? ""
                                                          : widget.ultimoMensaje[
                                                              "mensaje"],overflow: TextOverflow.ellipsis,)
                                                      : widget.ultimoMensaje[
                                                                  "tipoMensaje"] ==
                                                              "audio"
                                                          ? Row(children: [
                                                              Icon(Icons.mic,
                                                                  color: Colors
                                                                      .black),
                                                              Text(mostrarDuracion(
                                                                  widget.ultimoMensaje[
                                                                      "duracion"]))
                                                            ])
                                                          : widget.ultimoMensaje["tipoMensaje"] == "imagen"
                                                              ? Row(
                                                                  children: [
                                                                    Icon(Icons
                                                                        .image),
                                                                    Text(
                                                                        "Imagen")
                                                                  ],
                                                                )
                                                              : widget.ultimoMensaje["tipoMensaje"] == "gif"
                                                                  ? Row(
                                                                      children: [
                                                                        Icon(Icons
                                                                            .image),
                                                                        Text(
                                                                            "Gif")
                                                                      ],
                                                                    )
                                                                  : Container()),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 80.w,
                                  width: 80.w,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cantidadMensajesSinLeer > 0
                                          ? Colors.purple
                                          : Colors.transparent),
                                  child: Center(
                                    child: Text(
                                      "$cantidadMensajesSinLeer",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil().setSp(30)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
              ),
            );
          },
        ));
  }
}
