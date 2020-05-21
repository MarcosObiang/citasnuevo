import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'Usuario.dart';
import 'dart:math';
import 'package:citasnuevo/InterfazUsuario/Gente/people_screen_elements.dart';

class Valoraciones extends ChangeNotifier {
  init() {
    obtenerValoracion();
  }

  String imagenEmisor;
  String idEmisor;
  String aliasEmisor;
  String nombreEmisor;
  String mensaje;
  String valoracion;
  ValoracionWidget valorWidget;
  Valoraciones.crear({
    @required this.idEmisor,
    @required this.imagenEmisor,
    @required this.aliasEmisor,
    @required this.nombreEmisor,
    @required this.mensaje,
    @required this.valoracion,
    @required this.valorWidget,
  });
  Valoraciones();

  static Valoraciones Puntuaciones = new Valoraciones();
  static List<Valoraciones> puntuaciones = new List();

  void obtenerValoracion() {
   
    Firestore instanciaBaseDatos = Firestore.instance;
    print(Usuario.esteUsuario.idUsuario);
    instanciaBaseDatos
        .collection("usuarios")
        .document(Usuario.esteUsuario.idUsuario)
        .collection("valoraciones")
        .limit(1)
        .orderBy("Time", descending: true)
        .snapshots()
        .listen((dato) {
           int coincidencias=0;
      print("escuchado");
      List<DocumentSnapshot> valoraciones = dato.documents;
      print(dato.documents.length);

      print(
          "${dato.documents.last.data["Mensaje"]} y puntnnos ${dato.documents.last.data["Valoracion"]}");
      
      for(int i=0;i<puntuaciones.length;i++){
        
        if(dato.documents[0].data["id valoracion"]==puntuaciones[i].valorWidget.idValoracion){
          coincidencias+=1;

        }
        }
        if(coincidencias==0){
          print("Creando");
      crearValoracion(
          (dato.documents.last.data["Id emisor"]).toString(),
          (dato.documents.last.data["Nombre emisor"]).toString(),
          (dato.documents.last.data["Alias emisor"]).toString(),
          (dato.documents.last.data["Imagen Usuario"]).toString(),
          (dato.documents.last.data["Mensaje"]).toString(),
          double.parse((dato.documents.last.data["Valoracion"]).toString()),
          (dato.documents.last.data["id valoracion"]).toString());}
    });
  }

  void crearValoracion(
      String idEmisor,
      String nombreUsuario,
      String aliasUsuario,
      String imagenURl,
      String mensajeUsuario,
      double puntuacion,
      String valoracionId) {
    print(puntuacion);
    ValoracionWidget valoracionWidget = new ValoracionWidget(
        idValoracion: valoracionId,
        idEmisorValoracion: idEmisor,
        nombreEmisor: nombreUsuario,
        aliasEmisor: aliasUsuario,
        imagenUsuario: imagenURl,
        mensajeUsuario: mensajeUsuario,
        puntuacionUsuario: puntuacion);
   
    Valoraciones valoracion = new Valoraciones.crear(
        idEmisor: idEmisor,
        nombreEmisor: nombreUsuario,
        aliasEmisor: aliasUsuario,
        imagenEmisor: imagenURl,
        mensaje: mensajeUsuario,
        valoracion: puntuacion.toString(),
        valorWidget: valoracionWidget);
    puntuaciones = List.from(puntuaciones)..add(valoracion);
 for (int i = 0; i < puntuaciones.length; i++) {
      print("en bucle   ${puntuaciones[i].valorWidget.puntuacionUsuario}");
      print(puntuaciones.length);
    }
    puntuaciones.reversed;
    notifyListeners();
  }
}

class ValoracionWidget extends StatelessWidget {
  String idValoracion;
  String idEmisorValoracion;
  String nombreEmisor;
  String aliasEmisor;
  String imagenUsuario;
  String mensajeUsuario;
  double puntuacionUsuario;
  double porciento;
  Key clave;

  ValoracionWidget(
      {@required this.idValoracion,
      @required this.idEmisorValoracion,
      @required this.nombreEmisor,
      @required this.aliasEmisor,
      @required this.imagenUsuario,
      @required this.mensajeUsuario,
      @required this.puntuacionUsuario});

  Widget build(BuildContext context) {
    Valoraciones().notifyListeners();
    return Padding(
      key: UniqueKey(),
      padding: const EdgeInsets.all(8.0),
      child: Container(
          height: ScreenUtil().setHeight(600),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Color.fromRGBO(0, 0, 0, 100)),
          child: Row(
            children: <Widget>[
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: ClipRRect(
                  child: Container(
                    height: ScreenUtil().setHeight(550),
                    child: Image.network(
                      imagenUsuario,
                    ),
                  ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            child: Text(
                          "$nombreEmisor",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(60),
                              fontWeight: FontWeight.bold),
                        )),
                        Container(
                            child: Text(
                          "$aliasEmisor",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(40),
                          ),
                        )),
                        Container(
                            height: ScreenUtil().setHeight(200),
                            width: ScreenUtil().setWidth(1000),
                            child: mensajeUsuario == null
                                ? Text("")
                                : Text(
                                    mensajeUsuario,
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(60),
                                    ),
                                  )),
                        Container(
                          height: ScreenUtil().setHeight(100),
                          child: Center(
                            child: LinearPercentIndicator(
                              //  progressColor: Colors.deepPurple,
                              percent: puntuacionUsuario / 10,
                              animationDuration: 3,
                              lineHeight: ScreenUtil().setHeight(100),
                              linearGradient: LinearGradient(colors: [
                                Colors.pink,
                                Colors.pinkAccent[100]
                              ]),
                              center: Text(
                                "${(puntuacionUsuario).toStringAsFixed(1)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil()
                                        .setSp(70, allowFontScalingSelf: true),
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
