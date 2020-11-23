import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/GeneradorCodigos.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart' as xd;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import 'Usuario.dart';

class Solicitudes with ChangeNotifier {
  static Solicitudes instancia = Solicitudes();
  List<SolicitudConversacion> listaSolicitudesConversacion = new List();
  

  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;

  Solicitudes();

  


}

class SolicitudConversacion with ChangeNotifier {
  String nombreEmisor;
  String idEmisor;
  String idDestino;
  String imagenEmisor;
  double calificacion;
  String idSolicitudConversacion;
  DateTime fechaSolicitud;
  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;
  bool solicitudRevelada = true;
  WidgetSolicitudConversacion widgetSolicitud;
  static SolicitudConversacion instancia = SolicitudConversacion();
  SolicitudConversacion();
  SolicitudConversacion.crear(
      {@required this.nombreEmisor,
      @required this.fechaSolicitud,
      @required this.idDestino,
      @required this.imagenEmisor,
      @required this.solicitudRevelada,
      @required this.calificacion,
      @required this.idSolicitudConversacion,
      @required this.idEmisor});

  void obtenerSolicitudes() async {
    int indice = 0;
    baseDatosRef
        .collection("solicitudes conversaciones")
        .where("idDestino", isEqualTo: Usuario.esteUsuario.idUsuario)
        .get()
        .then((value) {
      if (value != null) {
        for (QueryDocumentSnapshot documento in value.docs) {
          SolicitudConversacion solicitud = new SolicitudConversacion.crear(
            fechaSolicitud: documento.get("tiemmpo").toDate(),
              idEmisor: documento.get("idEmisor"),
              nombreEmisor: documento.get("nombreEmisor"),
              idDestino: documento.get("idDestino"),
              imagenEmisor: documento.get("imagenEmisor"),
              solicitudRevelada: documento.get("solicitudRevelada"),
              calificacion: documento.get("calificacion"),
              idSolicitudConversacion:
                  documento.get("idSolicitudConversacion"));
          // Solicitudes.instancia.listaSolicitudesConversacion.add(solicitud);
          Solicitudes.instancia.listaSolicitudesConversacion
              .insert(indice, solicitud);
        }
      }
    }).then((value) => escucharSolicitudesConversacion());
  }

  void escucharSolicitudesConversacion() async {
    baseDatosRef
        .collection("solicitudes conversaciones")
        .where("idDestino", isEqualTo: Usuario.esteUsuario.idUsuario)
        .snapshots()
        .listen((event) {
      bool coincidencias;
      if (event.docs.length > 0) {
        for (int a = 0; a < event.docs.length; a++) {
          coincidencias = false;
          int indice = 0;

          for (int b = 0;
              b < Solicitudes.instancia.listaSolicitudesConversacion.length;
              b++) {
            if (event.docs[a].id ==
                Solicitudes.instancia.listaSolicitudesConversacion[b]
                    .idSolicitudConversacion) {
              coincidencias = true;
              indice = b;
            }
          }

          if (coincidencias) {
            if (event.docs[a].get("nombreEmisor") !=
                Solicitudes.instancia.listaSolicitudesConversacion[indice]
                    .nombreEmisor) {
              Solicitudes.instancia.listaSolicitudesConversacion[indice]
                  .nombreEmisor = event.docs[a].get("nombreEmisor");
            }
            if (event.docs[a].get("imagenEmisor") !=
                Solicitudes.instancia.listaSolicitudesConversacion[indice]
                    .imagenEmisor) {
              Solicitudes.instancia.listaSolicitudesConversacion[indice]
                  .imagenEmisor = event.docs[a].get("imagenEmisor");
            }
            if (event.docs[a].get("solicitudRevelada") !=
                Solicitudes.instancia.listaSolicitudesConversacion[indice]
                    .solicitudRevelada) {
              Solicitudes.instancia.listaSolicitudesConversacion[indice]
                  .solicitudRevelada = event.docs[a].get("solicitudRevelada");
            }
            Solicitudes.instancia.notifyListeners();
          }

          if (!coincidencias) {
            SolicitudConversacion solicitud = new SolicitudConversacion.crear(
              fechaSolicitud: event.docs[a].get("tiemmpo").toDate(),
                idEmisor: event.docs[a].get("idEmisor"),
                nombreEmisor: event.docs[a].get("nombreEmisor"),
                idDestino: event.docs[a].get("idDestino"),
                imagenEmisor: event.docs[a].get("imagenEmisor"),
                solicitudRevelada: event.docs[a].get("solicitudRevelada"),
                calificacion: event.docs[a].get("calificacion"),
                idSolicitudConversacion:
                    event.docs[a].get("idSolicitudConversacion"));
            // Solicitudes.instancia.listaSolicitudesConversacion.add(solicitud);
            Solicitudes.instancia.listaSolicitudesConversacion
                .insert(0, solicitud);
            if (WidgetSolicitudConversacion
                    .llaveListaSolicitudes.currentState !=
                null) {
              WidgetSolicitudConversacion.llaveListaSolicitudes.currentState
                  .insertItem(0);
            }
            Solicitudes.instancia.notifyListeners();
          }
        }
      }
    });
  }

  void revelarSolicitud() {
    FirebaseFirestore referenciaValoraciones = FirebaseFirestore.instance;
    referenciaValoraciones
        .collection("solicitudes conversaciones")
        .doc(this.idSolicitudConversacion)
        .update({"solicitudRevelada": true});
  }

  void eliminarSolicitudConversacion(String idSolicitud) {
    FirebaseFirestore firebaseRef = FirebaseFirestore.instance;
    firebaseRef
        .collection("solicitudes conversaciones")
        .doc(idSolicitud)
        .delete();
  }


void rechazarSolicitudConversacion(
    String id,
  ) async {
    await baseDatosRef
        .collection("solicitudes conversaciones")
        .doc(id)
        .delete();
  }

  void aceptarSolicitud(String nombreRemitente, String imagenRemitente,
      String idRemitente, String idVal) async {



    String idMensaje = GeneradorCodigos.instancia.crearCodigo();
    String idConversacion = GeneradorCodigos.instancia.crearCodigo();
    Map<String, dynamic> mensajeInicial = Map();

    mensajeInicial["Hora mensaje"] = DateTime.now();

    mensajeInicial["idMensaje"] = idMensaje;
    mensajeInicial["idEmisor"] = idRemitente;
    mensajeInicial["Nombre emisor"] = Usuario.esteUsuario.idUsuario;
    mensajeInicial["Tipo Mensaje"] = "Texto";


    Map<String, dynamic> estadoConexionUsuario = Map();
    estadoConexionUsuario["Escribiendo"] = false;
    estadoConexionUsuario["Conectado"] = false;
    estadoConexionUsuario["IdConversacion"] = idConversacion;
    estadoConexionUsuario["Hora Conexion"] = DateTime.now();

    Map<String, dynamic> solicitudParaRemitente = Map();
    solicitudParaRemitente["Hora"] = DateTime.now();
    solicitudParaRemitente["IdConversacion"] = idConversacion;
    solicitudParaRemitente["idUsuario"] = Usuario.esteUsuario.idUsuario;
    solicitudParaRemitente["IdMensajes"] = idMensaje;
    solicitudParaRemitente["cantidadMensajesSinLeer"] = 0;
    solicitudParaRemitente["cantidadMensajesSinLeerPropios"] = 0;
    solicitudParaRemitente["IdRemitente"] = idRemitente;
    solicitudParaRemitente["ultimoMensaje"] = {
      "mensaje": " ",
      "tipoMensaje": "texto",
      "duracionMensaje": 0
    };
    solicitudParaRemitente["nombreRemitente"] = nombreRemitente;
    solicitudParaRemitente["imagenRemitente"] = imagenRemitente;
    solicitudParaRemitente["Grupo"] = false;
    Map<String, dynamic> solicitudLocal = Map();
    solicitudLocal["Hora"] = DateTime.now();
    solicitudLocal["IdConversacion"] = idConversacion;
    solicitudLocal["idUsuario"] = idRemitente;
    solicitudLocal["IdMensajes"] = idMensaje;
    solicitudLocal["IdRemitente"] = Usuario.esteUsuario.idUsuario;
    solicitudLocal["nombreRemitente"] = Usuario.esteUsuario.nombre;
    solicitudLocal["cantidadMensajesSinLeer"] = 0;
    solicitudLocal["cantidadMensajesSinLeerPropios"] = 0;
    solicitudLocal["imagenRemitente"] = Usuario.esteUsuario.imagenUrl1["Imagen"];
    solicitudLocal["ultimoMensaje"] = {
      "mensaje": "null",
      "tipoMensaje": "texto",
      "duracionMensaje": 0
    };
    solicitudLocal["Grupo"] = false;
    WriteBatch batch = baseDatosRef.batch();

    DocumentReference valoracionEliminar =
        baseDatosRef.collection("solicitudes conversaciones").doc(idVal);
    DocumentReference conversacionesRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("conversaciones")
        .doc(idConversacion);

    DocumentReference conversacionesLocal = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("conversaciones")
        .doc(idConversacion);

    DocumentReference estadoConversacionesRemitente = baseDatosRef
        .collection("usuarios")
        .doc(idRemitente)
        .collection("estados conversacion")
        .doc(idConversacion);

    DocumentReference estadoConversacionesLocal = baseDatosRef
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("estados conversacion")
        .doc(idConversacion);

    batch.set(conversacionesRemitente, solicitudLocal);
    batch.set(conversacionesLocal, solicitudParaRemitente);
    batch.set(estadoConversacionesRemitente, estadoConexionUsuario);
    batch.set(estadoConversacionesLocal, estadoConexionUsuario);
    batch.delete(valoracionEliminar);
    await batch.commit().then((value) {
      print("value");
    }).catchError((onError) => print(onError));
  }
}

class WidgetSolicitudConversacion extends StatefulWidget {
  static final GlobalKey<AnimatedListState> llaveListaSolicitudes =
      GlobalKey<AnimatedListState>();

  @override
  _WidgetSolicitudConversacionState createState() =>
      _WidgetSolicitudConversacionState();
}

class _WidgetSolicitudConversacionState
    extends State<WidgetSolicitudConversacion> {
  @override
  Widget       build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
        value: Solicitudes.instancia,
        child: Consumer<Solicitudes>(
          builder: (context, myType, child) {
            return Container(
              child: AnimatedList(
                key: WidgetSolicitudConversacion.llaveListaSolicitudes,
                initialItemCount:
                    Solicitudes.instancia.listaSolicitudesConversacion.length,
                itemBuilder: (BuildContext context, int indice, animation) {
                  return buildSlideTransition(
                      context,
                      animation,
                      indice,
                      Solicitudes
                          .instancia.listaSolicitudesConversacion[indice]);
                },
              ),
            );
          },
        ));
  }

  SizeTransition buildSlideTransition(BuildContext context, Animation animation,
      int indice, SolicitudConversacion solicitud) {
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: ScreenUtil().setHeight(400),
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10)],
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: Colors.white),
            child: Container(
              child: Stack(
                children: [
                  Row(
                    children: [
                      fotoSolicitud(solicitud),
                      cuadroOpcionesSolicitud(solicitud, indice),
                    ],
                  ),
                  !solicitud.solicitudRevelada
                      ? Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          height: 400.h,
                          child: Center(
                              child: GestureDetector(
                            onTap: () {
                              ControladorCreditos.instancia.restarCreditosSolicitud(
                                100, solicitud.idSolicitudConversacion);
                            },
                            child: Container(
                              height: 400.h,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[900],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(1)),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Flexible(
                                        flex:4,
                                        fit:FlexFit.tight,
                                                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Revelar",
                                                style: GoogleFonts.lato(fontSize: 60.sp,color: Colors.white),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "100",
                                                    style:GoogleFonts.lato(fontSize: 60.sp,color: Colors.white),
                                                  ),
                                                  Icon(xd.LineAwesomeIcons.coins,color: Colors.white,),
                                                ],
                                              )
                                            ]),
                                      ),
                                      Flexible(
                                        flex:2,
                                        fit: FlexFit.tight,
                                        child: Row(children: [

                                          CuentaAtrasSolicitud(tiempo: solicitud.fechaSolicitud),
                                          Icon(LineAwesomeIcons.clock_o,color: Colors.white,)
                                        ],)
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )))
                      : Container()
                ],
              ),
            )),
      ),
    );
  }

  Flexible cuadroOpcionesSolicitud(
      SolicitudConversacion valoracion, int indice) {
    return Flexible(
      flex: 5,
      fit: FlexFit.tight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cuadroSuperiorValoracion(valoracion),
          cuadroOpcionesValoracion(indice, valoracion),
        ],
      ),
    );
  }

  Flexible cuadroOpcionesValoracion(
      int indice, SolicitudConversacion valoracion) {
    return Flexible(
        flex: 4,
        fit: FlexFit.tight,
        child: LayoutBuilder(
          builder: (BuildContext contex, BoxConstraints limites) {
            return Container(
              decoration: BoxDecoration(),
              height: limites.maxHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Container(
                      height: limites.maxHeight,
                      decoration: BoxDecoration(color: Colors.green),
                      child: FlatButton(
                          onPressed: () {
                            aceptarSolicitud(indice, valoracion);
                          },
                          child: Icon(
                            LineAwesomeIcons.heart_o,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.red),
                      height: limites.maxHeight,
                      child: FlatButton(
                          onPressed: () {
                            eliimnarSolicitud(
                                indice,
                                Solicitudes
                                    .instancia
                                    .listaSolicitudesConversacion[indice]
                                    .idSolicitudConversacion,valoracion);
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          )),
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }

  Flexible cuadroSuperiorValoracion(SolicitudConversacion valoracion) {
    return Flexible(
      flex: 14,
      fit: FlexFit.tight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                      child: valoracion.nombreEmisor != null
                          ? Text(
                              "${valoracion.nombreEmisor}",
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(40),
                                  fontWeight: FontWeight.bold),
                            )
                          : Text(" ")),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 5,
                  child: Container(child: Text("Le calificaste con")),
                ),
                Container(
                  height: ScreenUtil().setHeight(50),
                  child: Center(
                    child: LinearPercentIndicator(
                      linearStrokeCap: LinearStrokeCap.butt,
                      //  progressColor: Colors.deepPurple,
                      percent: valoracion.calificacion / 10,
                      animationDuration: 300,
                      lineHeight: ScreenUtil().setHeight(60),
                      linearGradient: LinearGradient(
                          colors: [Colors.pink, Colors.pinkAccent[100]]),
                      center: Text(
                        "${(valoracion.calificacion).toStringAsFixed(1)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil()
                                .setSp(40, allowFontScalingSelf: true),
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Flexible fotoSolicitud(SolicitudConversacion valoracion) {
    return Flexible(
      flex: 4,
      fit: FlexFit.tight,
      child: Container(
        decoration: BoxDecoration(
        
            image: DecorationImage(
                image: NetworkImage(valoracion.imagenEmisor),
                fit: BoxFit.cover)),
      ),
    );
  }

  void eliimnarSolicitud(int indice, String id,SolicitudConversacion solicitud) {
    SolicitudConversacion valoracionQuitada =
        Solicitudes.instancia.listaSolicitudesConversacion.removeAt(indice);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return buildSlideTransition(
          context, animation, indice, valoracionQuitada);
    };
    WidgetSolicitudConversacion.llaveListaSolicitudes.currentState
        .removeItem(indice, builder);

    solicitud.rechazarSolicitudConversacion(id);
  }

  void aceptarSolicitud(int indice, SolicitudConversacion solicitud) {
    SolicitudConversacion valoracionAceptada =
        Solicitudes.instancia.listaSolicitudesConversacion.removeAt(indice);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return buildSlideTransition(
          context, animation, indice, valoracionAceptada);
    };
    WidgetSolicitudConversacion.llaveListaSolicitudes.currentState
        .removeItem(indice, builder);

    solicitud.aceptarSolicitud(
      solicitud.nombreEmisor,
      solicitud.imagenEmisor,
      solicitud.idEmisor,
      solicitud.idSolicitudConversacion,
    );
  }
}

// ignore: must_be_immutable
class CuentaAtrasSolicitud extends StatefulWidget {
  final DateTime tiempo;
   int duracionSegundos;
  
  
  CuentaAtrasSolicitud({@required this.tiempo});
  @override
  _CuentaAtrasSolicitudState createState() => _CuentaAtrasSolicitudState();
}

class _CuentaAtrasSolicitudState extends State<CuentaAtrasSolicitud> {
  Timer cuentaAtras;
  int segundos;
  int minutos;
  int horas;
  String tiempoPasado="";
   bool estaContanto=false;
   CountdownController controladorCuentaAtras=new CountdownController();
 
  var formatoTiempo=new DateFormat("HH:mm:ss");

@override
  void initState() {
    // TODO: implement initState
    
   
      widget.duracionSegundos=widget.tiempo.difference(Valoracion.tiempoReferencia).inSeconds;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
   
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
 
    return Container(

      child: Countdown(
     interval: Duration(seconds: 1),
        seconds: widget.duracionSegundos,
     
        build: (BuildContext context,double time){
          int tiempo=time.toInt();
          DateTime horas=DateTime(0,0,0,0,0,tiempo);
          
          return Text(formatoTiempo.format(horas), style:
                                                    GoogleFonts.lato(fontSize: 60.sp,color: Colors.white));
        },
      )
      
    );
  }
}