import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/EstadoConexion.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/GeneradorCodigos.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/ListaConversaciones.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/PantallaConversacion.dart';
import 'package:citasnuevo/InterfazUsuario/WidgetError.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
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

enum EstadoCargaMesajesAdicionales { cargando, cargados, error, noCargados,noQuedanMensajes }

List<Mensajes> insertarHoras(List<Mensajes> datos) {
  List<Mensajes> lista = datos;
  if (lista != null) {
    lista.sort(
        (b, c) => b.horaMensajeFormatoDate.compareTo(c.horaMensajeFormatoDate));
  }

  DateTime cacheTiempo = lista[0].horaMensajeFormatoDate;
  int cacheDia = lista[0].horaMensajeFormatoDate.day;
  Mensajes horaSeparador;

  horaSeparador = Mensajes.separadorHora(
    horaMensaje: lista[0].horaMensaje,
    horaMensajeFormatoDate: cacheTiempo,
    idEmisor: lista[0].idEmisor,
  );
  lista.insert(0, horaSeparador);
  for (int i = 0; i < lista.length; i++) {
    if (cacheDia != lista[i].horaMensajeFormatoDate.day) {
      horaSeparador = Mensajes.separadorHora(
        horaMensajeFormatoDate: lista[i].horaMensajeFormatoDate,
        horaMensaje: lista[i].horaMensaje,
        idEmisor: lista[i].idEmisor,
      );

      cacheTiempo = lista[i].horaMensajeFormatoDate;
      cacheDia = lista[i].horaMensajeFormatoDate.day;
      lista.insert(i, horaSeparador);
    }
    //  lista[i].horaMensajeFormatoDate=null;
  }

  return lista;
}

List<Mensajes> procesarMensajes(Map<String, dynamic> datos) {
  List<Map<dynamic, dynamic>> dato = datos["Mensajes"];
  String nombre = datos["nombre"];
  String idUsuario=datos["idUsuario"];
  double dimension=datos["ancho"];

  List<Mensajes> temp = [];
  dato = dato.reversed.toList();
  if (dato != null) {
    if (dato.length > 0) {
      for (int a = 0; a < dato.length; a++) {
        if (dato[a][("idMensaje")] != null &&
            dato[a]["Tipo Mensaje"] != null &&
            dato[a]["respuesta"] != null &&
            dato[a]["mensajeRespuesta"] != null &&
            dato[a]["mensajeLeidoRemitente"] != null &&
            dato[a]["Nombre emisor"] != null &&
            dato[a]["idConversacion"] != null &&
            dato[a]["mensajeLeido"] != null &&
            dato[a]["identificadorUnicoMensaje"] != null &&
            dato[a]["idEmisor"] != null &&
            dato[a]["Hora mensaje"] != null &&
            dato[a]["Mensaje"] != null) {
          if (dato[a]["Tipo Mensaje"] == "Texto" ||
              dato[a]["Tipo Mensaje"] == "Imagen" ||
              dato[a]["Tipo Mensaje"] == "Gif") {
            Mensajes mensaje = new Mensajes(
              respuestaMensaje: dato[a]["mensajeRespuesta"],
              respuesta: dato[a]["respuesta"],
              mensajeLeido: dato[a]["mensajeLeido"],
              nombreEmisor: dato[a]["Nombre emisor"],
              identificadorUnicoMensaje: dato[a]["identificadorUnicoMensaje"],
              idEmisor: dato[a]["idEmisor"],
              idConversacion: dato[a]["idConversacion"],
              mensajeLeidoRemitente: dato[a]["mensajeLeidoRemitente"],
              mensaje: dato[a]["Mensaje"],
              idMensaje: dato[a]["idMensaje"],
              horaMensajeFormatoDate: DateTime.fromMillisecondsSinceEpoch(
                  (dato[a]["Hora mensaje"])),
              horaMensaje:
                  ("${DateTime.fromMillisecondsSinceEpoch((dato[a]["Hora mensaje"])).hour}:${DateTime.fromMillisecondsSinceEpoch((dato[a]["Hora mensaje"])).minute}"),
              tipoMensaje: dato[a]["Tipo Mensaje"],
            );
            temp.insert(0, mensaje);
          }
        }
      }
      if (temp.length > 0) {
        temp = insertarHoras(temp);
        temp = temp.reversed.toList();
      }

      for (int v = 0; v < temp.length; v++) {
        if (temp[v].tipoMensaje != "SeparadorHora") {
          if (temp[v].respuesta) {
            if (temp[v].respuestaMensaje["tipoMensaje"] == "Texto") {
              temp[v].widgetRespuesta = Container(
                color: temp[v].respuestaMensaje["idEmisorMensaje"] ==
                       idUsuario
                    ? Colors.blue
                    : Colors.green,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    temp[v].respuestaMensaje["idEmisorMensaje"] ==
                           idUsuario
                        ? Text("Yo")
                        : Text(nombre),
                    Text(temp[v].respuestaMensaje["mensaje"])
                  ],
                ),
              );
            }
            if (temp[v].respuestaMensaje["tipoMensaje"] == "Imagen") {
              temp[v].widgetRespuesta = Container(
                color: temp[v].respuestaMensaje["idEmisorMensaje"] ==
                   idUsuario
                    ? Colors.blue
                    : Colors.green,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    temp[v].respuestaMensaje["idEmisorMensaje"] ==
                           idUsuario
                        ? Text("Yo")
                        : Text(nombre),
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              temp[v].respuestaMensaje["mensaje"],
                              scale: 1,
                            )),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.transparent,
                      ),
                      height: dimension,
                      width: dimension,
                    )
                  ],
                ),
              );
            }
            if (temp[v].respuestaMensaje["tipoMensaje"] == "Gif") {
              temp[v].widgetRespuesta = Container(
                color: temp[v].respuestaMensaje["idEmisorMensaje"] ==
                        idUsuario
                    ? Colors.blue
                    : Colors.green,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    temp[v].respuestaMensaje["idEmisorMensaje"] ==
                        idUsuario
                        ? Text("Yo")
                        : Text(nombre),
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                temp[v].respuestaMensaje["mensaje"],
                                scale: 1,
                                headers: {'accept': 'image/*'})),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.transparent,
                      ),
                      height: dimension,
                      width: dimension,
                    )
                  ],
                ),
              );
            }
          }
        }
      }
    }
  }
  return temp;
}

enum EstadosListaMensajes { listaVacia, cargandoLista, listaCargada }

class PuenteVentanaChat extends InheritedWidget {
  final List<Mensajes> listaMensajes;
  final Widget child;
  final Key key;
  final String estadoConversacion;
  final bool estadoConexion;
  final EstadoCargaMesajesAdicionales estadoCargaMensajesAdicionales;
  final bool todosLosMensajesCargados;

  PuenteVentanaChat(
      {@required this.key,
      @required this.todosLosMensajesCargados,
      @required this.estadoCargaMensajesAdicionales,
      @required this.listaMensajes,
      @required this.child,
      @required this.estadoConexion,
      @required this.estadoConversacion})
      : super(key: key, child: child);

  static PuenteVentanaChat of(BuildContext context) {
    final PuenteVentanaChat result =
        context.dependOnInheritedWidgetOfExactType<PuenteVentanaChat>();
    return result;
  }

  @override
  bool updateShouldNotify(PuenteVentanaChat oldWidget) =>
      (oldWidget.listaMensajes?.length != this.listaMensajes?.length ||
          oldWidget.estadoConexion != this.estadoConexion ||
          oldWidget.estadoConversacion != this.estadoConversacion ||
          oldWidget.estadoCargaMensajesAdicionales !=
              this.estadoCargaMensajesAdicionales);
}

// ignore: must_be_immutable
class TituloChat extends StatefulWidget with ChangeNotifier {
  List<Mensajes> listadeMensajes = [];
  String idRemitente;
  String idConversacion;
  String estadoConversacion;
  bool estadoConexion;
  String imagen;
  String nombre;
  PantallaConversacion pantalla;
  bool todosLosMensajesCargados=false;
  EstadoCargaMesajesAdicionales cargaMensajesAdicionales =
      EstadoCargaMesajesAdicionales.noCargados;

  bool pulsado = false;
  EstadosListaMensajes estado = EstadosListaMensajes.listaVacia;

  int mensajesSinLeer = 0;

  Map<String, dynamic> ultimoMensaje = new Map();
  String mensajeId;
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
    this.estado = EstadosListaMensajes.cargandoLista;
    Conversacion.conversaciones.notifyListeners();

    if (!this.conversacion.grupo) {
      await Conversacion.baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("mensajes")
          .where("idMensaje", isEqualTo: identificadorMensajes)
          .limit(5)
          .get()
          .then((dato) async {
        if (dato != null) {
          Map<String, dynamic> datosProcesar = new Map();
          List<Map<String, dynamic>> lista = [];
          for (int i = 0; i < dato.docs.length; i++) {
            lista.add(dato.docs[i].data());
            DateTime fechaTemp = (lista[i]["Hora mensaje"]).toDate();

            lista[i]["Hora mensaje"] = fechaTemp.millisecondsSinceEpoch;
            print(lista[i]["Hora mensaje"] = fechaTemp.millisecondsSinceEpoch);
          }

          datosProcesar["Mensajes"] = lista;
          datosProcesar["nombre"] = nombre;
          Conversacion.conversaciones.cargarConversacion = false;

          temp = await compute(procesarMensajes, datosProcesar)
              .catchError((error) {
            print(error.toString());
            this.estado = EstadosListaMensajes.listaVacia;
            Conversacion.conversaciones.cargarConversacion = true;

            Conversacion.conversaciones.notifyListeners();
            ManejadorErroresAplicacion.erroresInstancia
                .mostrarNoSePuedeAbrirConversacion(ConversacionesLikes
                    .claveListaConversaciones.currentContext);
            //  throw ExcepcionesConversaciones("Error en isolate");
          });
        }
      }).catchError((onError) {
        print(onError);
        this.estado = EstadosListaMensajes.listaVacia;
        Conversacion.conversaciones.notifyListeners();
        Conversacion.conversaciones.cargarConversacion = true;

        ManejadorErroresAplicacion.erroresInstancia
            .mostrarNoSePuedeAbrirConversacion(
                ConversacionesLikes.claveListaConversaciones.currentContext);
      });
    }

    this.estado = EstadosListaMensajes.listaCargada;
    Conversacion.conversaciones.cargarConversacion = true;

    return temp;
  }

  Future<EstadoCargaMesajesAdicionales> obtenerMasMensajes(
      String identificadorMensajes, String rutaRemitente) async {
        EstadoCargaMesajesAdicionales estadoOperacion;
    List<Mensajes> temp = [];
    Conversacion.conversaciones.notifyListeners();
    String idUltimoMensaje = listadeMensajes
        .lastWhere((element) => element.identificadorUnicoMensaje != null)
        .identificadorUnicoMensaje;


        
     await Conversacion.baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .doc(idUltimoMensaje)
        .get().then((value) async {
              if (this.cargaMensajesAdicionales != EstadoCargaMesajesAdicionales.error&&value.data()!=null) {
      await Conversacion.baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("mensajes")
          .orderBy("Hora mensaje", descending: true)
          .where("idMensaje", isEqualTo: identificadorMensajes)
          .startAfterDocument(value)
          .limit(15)
          .get()
          .then((dato) async {
        if (dato != null) {
          Map<String, dynamic> datosProcesar = new Map();
          List<Map<String, dynamic>> lista = [];
          for (int i = 0; i < dato.docs.length; i++) {
            lista.add(dato.docs[i].data());
            DateTime fechaTemp = (lista[i]["Hora mensaje"]).toDate();

            lista[i]["Hora mensaje"] = fechaTemp.millisecondsSinceEpoch;
          }
          datosProcesar["idUsuario"]=Usuario.esteUsuario.idUsuario;
          datosProcesar["Mensajes"] = lista;
          datosProcesar["nombre"] = nombre;
          datosProcesar["ancho"]=500.w;
        
          if (lista.length > 0) {
            temp = await compute(procesarMensajes, datosProcesar)
                .catchError((error) {
              print(error.toString());
              this.estado = EstadosListaMensajes.listaVacia;
              Conversacion.conversaciones.cargarConversacion = true;

              Conversacion.conversaciones.notifyListeners();
            
            });
          
         

          this.listadeMensajes.addAll(temp);
          this.cargaMensajesAdicionales =
              EstadoCargaMesajesAdicionales.cargados;
             estadoOperacion=  EstadoCargaMesajesAdicionales.cargados;
          Conversacion.conversaciones.notifyListeners();}

           else{
            estadoOperacion=EstadoCargaMesajesAdicionales.noQuedanMensajes;
          }
        }
      }).catchError((onError) {
        this.estado = EstadosListaMensajes.listaVacia;
        Conversacion.conversaciones.notifyListeners();
        Conversacion.conversaciones.cargarConversacion = true;

      });
    } else {
          estadoOperacion= EstadoCargaMesajesAdicionales.error;
    }



          
        })
        .onError((error,stackTrace) {

      this.cargaMensajesAdicionales = EstadoCargaMesajesAdicionales.error;
      estadoOperacion= EstadoCargaMesajesAdicionales.error;
    });


   
print("casa");
    return estadoOperacion;
  }



  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TituloChatState(imagen, nombre, ultimoMensaje);
  }
   void todosLosmensajesCargados(bool cargados){
this.todosLosMensajesCargados=cargados;
   }
  void enviarMensaje(String mensajeTexto, String idMensaje, bool respuesta,
      Map<String, String> respuestaEnMensaje) async {
    WriteBatch escrituraMensajes = Conversacion.baseDatosRef.batch();
    String idMensajeUnico = GeneradorCodigos.instancia.crearCodigo();
    DocumentReference direccionMensajes = Conversacion.baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("mensajes")
        .doc(idMensajeUnico);
    DocumentReference direccionMensajesUsuario = Conversacion.baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .doc(idMensajeUnico);
    DocumentReference referenciaConversacionRemitente = Conversacion
        .baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);
    DocumentReference referenciaConversacionUsuario = Conversacion.baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(idConversacion);

    if (EstadoConexionInternet.estadoConexion.conexion ==
        EstadoConexion.conectado) {
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
        mensaje["mensajeRespuesta"] = respuestaEnMensaje;
        mensaje["respuesta"] = respuesta;

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

    if (EstadoConexionInternet.estadoConexion.conexion !=
        EstadoConexion.conectado) {
      if (PantallaConversacion.llavePantallaConversacion.currentContext !=
          null) {
        ManejadorErroresAplicacion.erroresInstancia.mostrarErrorEnvioMensaje(
            PantallaConversacion.llavePantallaConversacion.currentContext);
      }
    }
  }

  void enviarMensajeAudio(Uint8List audio, String idMensaje, int duracion,
      bool respuesta, Map<String, String> respuestaEnMensaje) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    String idMensajeUnico = GeneradorCodigos.instancia.crearCodigo();
    String ruta = "${idRemitente}/Perfil/NotasVoz/${GeneradorCodigos.instancia.crearCodigo()}.aac";
    StorageReference referenciaArchivo = reference.child(ruta);
    WriteBatch escrituraMensajes = Conversacion.baseDatosRef.batch();
    DocumentReference direccionMensajes = Conversacion.baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("mensajes")
        .doc(idMensajeUnico);

    DocumentReference direccionMensajesUsuario = Conversacion.baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("mensajes")
        .doc(idMensajeUnico);
    DocumentReference referenciaConversacionRemitente = Conversacion
        .baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);
    DocumentReference referenciaConversacionUsuario = Conversacion.baseDatosRef
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
      mensaje["mensajeRespuesta"] = respuestaEnMensaje;
      mensaje["respuesta"] = respuesta;
      print(idRemitente);
      if (this.conversacion.grupo) {
        await Conversacion.baseDatosRef
            .collection("grupos directo")
            .doc(this.conversacion.idConversacion)
            .collection("mensajes")
            .doc()
            .set(mensaje);
      }

      if (EstadoConexionInternet.estadoConexion.conexion ==
          EstadoConexion.conectado) {
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
      if (EstadoConexionInternet.estadoConexion.conexion !=
          EstadoConexion.conectado) {
        if (PantallaConversacion.llavePantallaConversacion.currentContext !=
            null) {
          ManejadorErroresAplicacion.erroresInstancia.mostrarErrorEnvioMensaje(
              PantallaConversacion.llavePantallaConversacion.currentContext);
        }
      }
    }
  }

  void enviarMensajeImagen(File imagen, String idMensaje, bool respuesta,
      Map<String, String> respuestaEnMensaje) async {
    if (imagen != null) {
      FirebaseStorage storage = FirebaseStorage.instance;
      String idMensajeUnico = GeneradorCodigos.instancia.crearCodigo();
      StorageReference reference = storage.ref();
      String ruta =
          "${idRemitente}/Perfil/ImagenesConversaciones/${GeneradorCodigos.instancia.crearCodigo()}.jpg";
      StorageReference referenciaArchivo = reference.child(ruta);
      WriteBatch escrituraMensajes = Conversacion.baseDatosRef.batch();
      DocumentReference direccionMensajes = Conversacion.baseDatosRef
          .collection("usuarios")
          .doc(idRemitente)
          .collection("mensajes")
          .doc(idMensajeUnico);
      DocumentReference direccionMensajesUsuario = Conversacion.baseDatosRef
          .collection("usuarios")
          .doc(Usuario.esteUsuario.idUsuario)
          .collection("mensajes")
          .doc(idMensajeUnico);
      DocumentReference referenciaConversacionRemitente = Conversacion
          .baseDatosRef
          .collection("usuarios")
          .doc(idRemitente)
          .collection("conversaciones")
          .doc(idConversacion);
      DocumentReference referenciaConversacionUsuario = Conversacion
          .baseDatosRef
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
        mensaje["mensajeRespuesta"] = respuestaEnMensaje;
        mensaje["respuesta"] = respuesta;

        await Conversacion.baseDatosRef
            .collection("grupos directo")
            .doc(idRemitente)
            .collection("mensajes")
            .doc()
            .set(mensaje)
            .then((value) {
          print("ImagenEnviada");
        });

        if (EstadoConexionInternet.estadoConexion.conexion ==
            EstadoConexion.conectado) {
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

        if (EstadoConexionInternet.estadoConexion.conexion !=
            EstadoConexion.conectado) {
          if (PantallaConversacion.llavePantallaConversacion.currentContext !=
              null) {
            ManejadorErroresAplicacion.erroresInstancia
                .mostrarErrorEnvioMensaje(PantallaConversacion
                    .llavePantallaConversacion.currentContext);
          }
        }
      }
    }
  }

  void enviarMensajeImagenGif(String urlImagen, String idMensaje,
      bool respuesta, Map<String, String> respuestaEnMensaje) async {
    http.get(urlImagen).then((value) async {
      if (urlImagen != null) {
        FirebaseStorage storage = FirebaseStorage.instance;
        String idMensajeUnico = GeneradorCodigos.instancia.crearCodigo();
        StorageReference reference = storage.ref();
        String ruta =
            "$idRemitente/Perfil/ImagenesConversaciones/${GeneradorCodigos.instancia.crearCodigo()}.gif";
        StorageReference referenciaArchivo = reference.child(ruta);
        WriteBatch escrituraMensajes = Conversacion.baseDatosRef.batch();
        DocumentReference direccionMensajes = Conversacion.baseDatosRef
            .collection("usuarios")
            .doc(idRemitente)
            .collection("mensajes")
            .doc(idMensajeUnico);
        DocumentReference direccionMensajesUsuario = Conversacion.baseDatosRef
            .collection("usuarios")
            .doc(Usuario.esteUsuario.idUsuario)
            .collection("mensajes")
            .doc(idMensajeUnico);
        DocumentReference referenciaConversacionRemitente = Conversacion
            .baseDatosRef
            .collection("usuarios")
            .doc(idRemitente)
            .collection("conversaciones")
            .doc(idConversacion);
        DocumentReference referenciaConversacionUsuario = Conversacion
            .baseDatosRef
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
          mensaje["mensajeRespuesta"] = respuestaEnMensaje;
          mensaje["respuesta"] = respuesta;
          print(idRemitente);

          await Conversacion.baseDatosRef
              .collection("grupos directo")
              .doc(idRemitente)
              .collection("mensajes")
              .doc()
              .set(mensaje)
              .then((value) {
            print("ImagenEnviada");
          });

          if (EstadoConexionInternet.estadoConexion.conexion ==
              EstadoConexion.conectado) {
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

          if (EstadoConexionInternet.estadoConexion.conexion !=
              EstadoConexion.conectado) {
            if (PantallaConversacion.llavePantallaConversacion.currentContext !=
                null) {
              ManejadorErroresAplicacion.erroresInstancia
                  .mostrarErrorEnvioMensaje(PantallaConversacion
                      .llavePantallaConversacion.currentContext);
            }
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
      await Conversacion.baseDatosRef
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
      await Conversacion.baseDatosRef
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
  Key llave;
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
        key: llave,
        value: Conversacion.conversaciones,
        child: Consumer<Conversacion>(
          builder: (BuildContext context, conversacion, Widget child) {
            cantidadMensajesSinLeer = widget.mensajesSinLeer;
            widget.pantalla = PantallaConversacion(
              todosLosMensajesCargados: widget.todosLosmensajesCargados,
              obtenerMasMensajesConversacion: widget.obtenerMasMensajes,
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
                  if (widget.listadeMensajes == null &&
                      EstadoConexionInternet.estadoConexion.conexion ==
                          EstadoConexion.conectado &&
                      Conversaciones.enPantallaConversacion == true) {
                    widget.listadeMensajes = await widget.obtenerMensajes(
                        widget.mensajeId, widget.idRemitente);
                    setState(() {});
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (contexto) => PuenteVentanaChat(
                           todosLosMensajesCargados:   widget.todosLosMensajesCargados,
                            estadoCargaMensajesAdicionales:  widget.cargaMensajesAdicionales,
                                  estadoConexion: widget.estadoConexion,
                                  estadoConversacion: widget.estadoConversacion,
                                  key: llave,
                                  child: widget.pantalla,
                                  listaMensajes: widget.listadeMensajes,
                                )));
                  }

                  if (widget.listadeMensajes != null &&
                      Conversaciones.enPantallaConversacion == true) {
                    if (Conversacion.conversaciones.cargarConversacion ==
                        true) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (contexto) => PuenteVentanaChat(
                                                           todosLosMensajesCargados:   widget.todosLosMensajesCargados,

                                   estadoCargaMensajesAdicionales:  widget.cargaMensajesAdicionales,
                                    estadoConexion: widget.estadoConexion,
                                    estadoConversacion:
                                        widget.estadoConversacion,
                                    key: llave,
                                    child: widget.pantalla,
                                    listaMensajes: widget.listadeMensajes,
                                  )));
                    } else {
                      if (BaseAplicacion.claveBase?.currentContext != null) {
                        ControladorNotificacion.instancia
                            .mostrarNotificacionCargaConversacionDebeEsperar(
                                BaseAplicacion.claveBase.currentContext);
                      }
                    }
                  }

                  if (widget.listadeMensajes == null &&
                      EstadoConexionInternet.estadoConexion.conexion !=
                          EstadoConexion.conectado) {
                    print(EstadoConexionInternet.estadoConexion.conexion);
                    ManejadorErroresAplicacion.erroresInstancia
                        .mostrarNoSePuedeAbrirConversacion(ConversacionesLikes
                            .claveListaConversaciones.currentContext);
                  }
                },
                child: Container(
                    height: ScreenUtil().setHeight(220),
                    width: ScreenUtil().setWidth(1000),
                    decoration: BoxDecoration(
                      color: widget.mensajesSinLeer > 0
                          ? Colors.purple[100]
                          : Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Row(
                            children: <Widget>[
                              Container(
                                height: 200.h,
                                width: 200.h,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: widget.estadoConexion
                                          ? Colors.greenAccent[400]
                                          : Colors.transparent,
                                      width: 10.h),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Flexible(
                                          flex: 5,
                                          fit: FlexFit.tight,
                                          child: Container(
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
                                        ),
                                        Flexible(
                                          flex: 5,
                                          fit: FlexFit.tight,
                                          child: SizedBox(
                                              child: widget
                                                          .estadoConversacion ==
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
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal),
                                                    )
                                                  : widget.ultimoMensaje == null
                                                      ? Container()
                                                      : widget.ultimoMensaje[
                                                                  "tipoMensaje"] ==
                                                              "texto"
                                                          ? Text(
                                                              widget.ultimoMensaje[
                                                                              "mensaje"] ==
                                                                          null ||
                                                                      widget.ultimoMensaje[
                                                                              "mensaje"] ==
                                                                          "null"
                                                                  ? ""
                                                                  : widget.ultimoMensaje[
                                                                      "mensaje"],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            )
                                                          : widget.ultimoMensaje[
                                                                      "tipoMensaje"] ==
                                                                  "audio"
                                                              ? Row(children: [
                                                                  Icon(
                                                                      Icons.mic,
                                                                      color: Colors
                                                                          .black),
                                                                  Text(mostrarDuracion(
                                                                      widget.ultimoMensaje[
                                                                          "duracion"]))
                                                                ])
                                                              : widget.ultimoMensaje[
                                                                          "tipoMensaje"] ==
                                                                      "imagen"
                                                                  ? Row(
                                                                      children: [
                                                                        Icon(Icons
                                                                            .image),
                                                                        Text(
                                                                            "Imagen")
                                                                      ],
                                                                    )
                                                                  : widget.ultimoMensaje[
                                                                              "tipoMensaje"] ==
                                                                          "gif"
                                                                      ? Row(
                                                                          children: [
                                                                            Icon(Icons.image),
                                                                            Text("Gif")
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
                          widget.estado == EstadosListaMensajes.cargandoLista
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  height: 250.h,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text("Cargando conversación...",
                                          style: GoogleFonts.lato(
                                              color: Colors.white)),
                                      Container(
                                        height: 120.h,
                                        width: 120.h,
                                        child: CircularProgressIndicator(),
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  height: 0,
                                  width: 0,
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
