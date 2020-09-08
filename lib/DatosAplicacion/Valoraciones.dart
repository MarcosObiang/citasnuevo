import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import 'package:citasnuevo/InterfazUsuario/Directo/live_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'Usuario.dart';
import 'dart:math';
import 'package:citasnuevo/InterfazUsuario/Gente/people_screen_elements.dart';

class Valoraciones extends ChangeNotifier {
  static Valoraciones instanciar = Valoraciones.instancia();
  String imagenEmisor;
  String idEmisor;
  String aliasEmisor;
  String nombreEmisor;
  DateTime fechaValoracion;
  String mensaje;
  double valoracion;
  String idValoracion;
  
  static double mediaUsuario;
  static List<Valoraciones>listaDeValoraciones=new List();
  static int visitasTotales;
  static String idUsuarioDestino = Usuario.esteUsuario.idUsuario;
  
  Valoraciones.crear({
    @required this.idValoracion,
    @required this.fechaValoracion,
    @required this.idEmisor,
    @required this.imagenEmisor,
    @required this.aliasEmisor,
    @required this.nombreEmisor,
    @required this.mensaje,
    @required this.valoracion,
  

  });
  Valoraciones();
  Valoraciones.instancia();

  static Valoraciones Puntuaciones = new Valoraciones();
  static List<ValoracionWidget> puntuaciones = new List();

  void obtenerValoraciones() {
    FirebaseFirestore instanciaBaseDatos = FirebaseFirestore.instance;

    print(Usuario.esteUsuario.idUsuario);
    instanciaBaseDatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("valoraciones")
        .where("Valoracion", isGreaterThanOrEqualTo: 5)
        .get()
        .then((dato) {
      if (dato.docs.length > 0) {
        print("escuchado a ${dato.docs.length} valoraciones");

        print(dato.docs.length);
        for (int i = 0; i < dato.docs.length; i++) {
          print("Creando");
          if (dato.docs[i].id != "mediaPuntos") {
            crearValoracion(
                (dato.docs[i].get("Id emisor").toString()),
                (dato.docs[i].get("Nombre emisor").toString()).toString(),
                (dato.docs[i].get("Alias Emisor").toString()).toString(),
                (dato.docs[i].get("Imagen Usuario").toString()).toString(),
                (dato.docs[i].get("Mensaje").toString()).toString(),
                double.parse((dato.docs[i].get("Valoracion").toString()).toString()),
                (dato.docs[i].get("Time")).toDate(),
                (dato.docs[i].get("id valoracion").toString()).toString());
          }
          if (dato.docs[i].id == "mediaPuntos") {
            mediaUsuario = dato.docs[i].get("mediaTotal");
            visitasTotales = dato.docs[i].get("cantidadValoraciones");
          }
        }

        instanciar.notifyListeners();
      }
    }).then((val) => escucharValoraciones());
  }

  void escucharValoraciones() {
    FirebaseFirestore instanciaBaseDatos = FirebaseFirestore.instance;
    bool coincidencias;

    print(Usuario.esteUsuario.idUsuario);
    instanciaBaseDatos
        .collection("usuarios")
        .doc(Usuario.esteUsuario.idUsuario)
        .collection("valoraciones")
        .where("Valoracion", isGreaterThanOrEqualTo: 5)
        .snapshots()
        .listen((dato) {
      if (dato.docs.length > 0) {
       
       

      
        for (int a = 0; a < dato.docs.length; a++) {
         if (dato.docs[a].id == "mediaPuntos") {
            mediaUsuario = dato.docs[a].get("mediaTotal").toDouble();
            visitasTotales = dato.docs[a].get("cantidadValoraciones");
          }
        }












        for (int b = 0; b < dato.docs.length; b++) {
            coincidencias =false;
          for (int i = 0; i < listaDeValoraciones.length; i++) {
            if(dato.docs[b].id!="mediaPuntos"){


            if (dato.docs[b].get("id valoracion") ==
                listaDeValoraciones[i].idValoracion) {
              coincidencias=true;
            }
          }
        }
               if (!coincidencias) {
         
            print("Creando");
            if (dato.docs[b].id != "mediaPuntos") {
                sumarValoracion(
                (dato.docs[b].get("Id emisor").toString()),
                (dato.docs[b].get("Nombre emisor").toString()).toString(),
                (dato.docs[b].get("Alias Emisor").toString()).toString(),
                (dato.docs[b].get("Imagen Usuario").toString()).toString(),
                (dato.docs[b].get("Mensaje").toString()).toString(),
                double.parse((dato.docs[b].get("Valoracion").toString()).toString()),
                (dato.docs[b].get("Time")).toDate(),
                (dato.docs[b].get("id valoracion").toString()).toString());
            }
          
        }
  
        
        
        
        }

       
      }
      instanciar.notifyListeners();
    }).onError((e) => print(e));
  }

  void crearValoracion(
      String idEmisor,
      String nombreUsuario,
      String aliasUsuario,
      String imagenURl,
      String mensajeUsuario,
      double puntuacion,
      DateTime fechaValoraciones,
      String valoracionId) {
    print(puntuacion);
    Valoraciones valoracion = new Valoraciones.crear(
        idValoracion: valoracionId,
        idEmisor: idEmisor,
        nombreEmisor: nombreUsuario,
        aliasEmisor: aliasUsuario,
        imagenEmisor: imagenURl,
        
        fechaValoracion: fechaValoraciones,
        mensaje: mensajeUsuario,
        valoracion: puntuacion);
        int i=listaDeValoraciones.length>0?listaDeValoraciones.length:0;
        listaDeValoraciones.insert(i, valoracion);
         listaDeValoraciones.sort((a, b) => b.fechaValoracion.compareTo(a.fechaValoracion));
    // list_live.llaveListaValoraciones.currentState.(i);

    //listaDeValoraciones = List.from(listaDeValoraciones)..add(valoracion);
    
   

    instanciar.notifyListeners();
  }
  void sumarValoracion(
      String idEmisor,
      String nombreUsuario,
      String aliasUsuario,
      String imagenURl,
      String mensajeUsuario,
      double puntuacion,
      DateTime fechaValoraciones,
      String valoracionId) {
    print(puntuacion);
    Valoraciones valoracion = new Valoraciones.crear(
        idValoracion: valoracionId,
        idEmisor: idEmisor,
        nombreEmisor: nombreUsuario,
        aliasEmisor: aliasUsuario,
        imagenEmisor: imagenURl,
        
        fechaValoracion: fechaValoraciones,
        mensaje: mensajeUsuario,
        valoracion: puntuacion);
        int i=listaDeValoraciones.length>0?listaDeValoraciones.length:0;
        listaDeValoraciones.insert(0, valoracion);
         listaDeValoraciones.sort((a, b) => b.fechaValoracion.compareTo(a.fechaValoracion));
    list_live.llaveListaValoraciones.currentState.insertItem(0);

    //listaDeValoraciones = List.from(listaDeValoraciones)..add(valoracion);
    
   

    //instanciar.notifyListeners();
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
  DateTime fechaValoracion;
  Animation animation; 


  ValoracionWidget(
      {@required this.idValoracion,
      @required this.fechaValoracion,
      @required this.idEmisorValoracion,
      @required this.nombreEmisor,
      @required this.aliasEmisor,
      @required this.imagenUsuario,
      @required this.mensajeUsuario,
      @required this.puntuacionUsuario});

  Widget build(BuildContext context) {
   
  }


}
