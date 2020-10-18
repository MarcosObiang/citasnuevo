import 'dart:ffi';

import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';
import 'package:citasnuevo/DatosAplicacion/Directo.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_methods.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../main.dart';
import '../RegistrodeUsuario/sign_up_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import '../../ServidorFirebase/firebase_manager.dart';
import 'dart:isolate';

///**************************************************************************************************************************************************************
/// EN ESTA CLASE ENCONTRAREMOS LOS ELEMENTOS QUE COMPONEN LA PANTALLA DE ACCESO DE LA APLICACION
///
///
/// *************************************************************************************************************************************************************///

///**************************************************************************************************************************************************************
///  WIDGET TEXT FIELD: Campo de texto donde el usuario introduce texto y recibe estos parametros(Icon icon,String nombre_de_campo,int numero, bool black text)
///
///  ICONO: Icono situado encima de la entrada de texto
///
///  NOMBRE DE CAMPO: Texto que aparece al lado del icono que indica el dato a introducir
///
///  NUMERO:El numero indica donde debe guardar el texto introducido para que sea procesado de la manera conveniente
///
///*************************************************************************************************************************************************************
class EntradaTextoAcceso extends StatefulWidget {
  Icon icon;
  String nombre_campo;
  int i;
  bool black_text;

  EntradaTextoAcceso(Icon icon, String nombre_campo, int i, black_text) {
    this.nombre_campo = nombre_campo;
    this.icon = icon;
    this.i = i;
    this.black_text = black_text;
  }
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EntradaTextoAccesoState(icon, nombre_campo, i, black_text);
  }
}

class EntradaTextoAccesoState extends State<EntradaTextoAcceso> {
  /// BOOL INVISIBLE: esta variable booleana es la que indica si se mostraran los caracteres del texto o si se veran los tipicos puntos de contraseña
  ///  y esta inicializada a true porque al crear este objeto TEXT_FIELD_STATE si el parametro BLACK_TEXT es verdadero no necesitamos que ese valor cambie
  ///  y queremos que la variable INVISIBLE siga siendo verdadera porque queremos ocultar el texto
  ///  En cambio si el parametro BLACK_TEXT es falso, en ese caso se igualara INVISIBLE  a falso para que muestre el texto que introduce el usuario
  bool invisible = true;
  bool aux = true;
  Icon icon;
  String nombre_campo;
  int i;
  bool black_text;

  EntradaTextoAccesoState(
      Icon icon, String nombre_campo, int i, bool black_text) {
    this.nombre_campo = nombre_campo;
    this.icon = icon;
    this.i = i;
    this.black_text = black_text;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            icon,
            Text(
              nombre_campo,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40), color: Colors.white),
            ),
          ],
        ),
        Container(
            height: ScreenUtil().setHeight(70),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: text_black(black_text)),
      ],
    );
  }

  Widget text_black(bool text) {
    if (text) {
      aux = true;
      return Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: 10,
            child: Container(
              child: TextField(
                style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                obscureText: invisible,
                onChanged: (String val) {
                  setState(() {
                    print(val);

                    if (i == 3) {
                      login_screen_state.pass = val;
                    }

                    if (i == 5) {
                      login_screen_state.email = val;
                    }
                  });
                },
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 2,
            child: Container(
              child: RaisedButton(
                onPressed: (() {
                  setState(() {
                    if (invisible == true && aux) {
                      invisible = false;
                      aux = false;
                      print("Visible");
                    }

                    if (invisible == false && aux) {
                      invisible = true;
                      print("innVisible");
                    }
                  });
                }),
                child: Icon(
                  Icons.remove_red_eye,
                  size: ScreenUtil().setSp(60),
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Container(
        child: TextField(
          style: TextStyle(fontSize: ScreenUtil().setSp(40)),
          obscureText: false,
          onChanged: (String val) {
            setState(() {
              if (i == 3) {
                login_screen_state.pass = val;
              }

              if (i == 5) {
                login_screen_state.email = val;
                print(login_screen_state.email);
              }
            });
          },
        ),
      );
    }
  }
}

class BotonAcceso extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BotonAccesoState();
  }
}

class BotonAccesoState extends State<BotonAcceso> {
  var basedatos = Firestore.instance;
  static bool primeraConexion = false;
  FirebaseDatabase baseDatosConexion = FirebaseDatabase(
      app: app, databaseURL: "https://citas-46a84.firebaseio.com/");
  FirebaseDatabase referenciaStatus = FirebaseDatabase(
      app: app, databaseURL: "https://citas-46a84.firebaseio.com/");

  Future<void> sign_in_user() async {
    DocumentSnapshot val;

    String IdUsuario;

    try {
      dynamic user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: login_screen_state.email.trim(),
          password: login_screen_state.pass);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => start()));

//print(user);

      print("Usuario");
      IdUsuario = await user.user.uid;
      Usuario.esteUsuario.idUsuario = IdUsuario;
      if (Usuario.esteUsuario.DatosUsuario != null) {
        Usuario.esteUsuario.DatosUsuario = null;
      }

      val = await basedatos.collection("usuarios").doc(IdUsuario).get();
      Usuario.esteUsuario.DatosUsuario = null;
      if (Usuario.esteUsuario.DatosUsuario != null) {
        Usuario.esteUsuario.DatosUsuario = null;
        Usuario.esteUsuario.DatosUsuario = val.data();
        print("Estaba lleno");
      }
      if (Usuario.esteUsuario.DatosUsuario == null) {
        Usuario.esteUsuario.DatosUsuario = val.data();
        Usuario.esteUsuario.inicializarUsuario();
        Perfiles.cargarPerfilesCitas();
       
        
        Conversacion.conversaciones.obtenerConversaciones();
        Valoraciones.Puntuaciones.obtenerValoraciones();
      

     
       
        Valoraciones.Puntuaciones.obtenerMedia();
   VideoLlamada.escucharLLamadasEntrantes();
   
      

        Conversacion.conversaciones.escucharMensajes();
     
        confirmarEstadoConexion();

        print("Estaba vacio");
      }
    } catch (e) {
      print(e);
    }
  }

  void confirmarEstadoConexion() {
    baseDatosConexion
        .reference()
        .child(".info/connected")
        .onValue
        .listen((event) {
      Map<String, dynamic> ultimaConexion = new Map();
      ultimaConexion["Status"] = "Conectado";
      ultimaConexion["Hora"] = DateTime.now().toString();
      ultimaConexion["idUsuario"] = Usuario.esteUsuario.idUsuario;
      Map<String, dynamic> ultimaDesconexion = new Map();
      ultimaDesconexion["Status"] = "Desconectado";
      ultimaDesconexion["Hora"] = DateTime.now().toString();
      ultimaDesconexion["idUsuario"] = Usuario.esteUsuario.idUsuario;

      referenciaStatus
          .reference()
          .child("/status/${Usuario.esteUsuario.idUsuario}")
          .set(ultimaConexion);

      referenciaStatus
          .reference()
          .child("/status/${Usuario.esteUsuario.idUsuario}")
          .onDisconnect()
          .set(ultimaDesconexion);

      if (event.snapshot.value) {
        Citas.estaConectado=true;
        
        primeraConexion=true;
        BaseAplicacion.mostrarNotificacionConexionCorrecta(
            BaseAplicacion.claveBase.currentContext);
             Usuario.esteUsuario.notifyListeners();
      } else {
        Citas.estaConectado=false;
        if (primeraConexion) {
          BaseAplicacion.mostrarNotificacionConexionPerdida(
              BaseAplicacion.claveBase.currentContext);
        }
        Usuario.esteUsuario.notifyListeners();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
        width: ScreenUtil().setWidth(600),
        height: ScreenUtil().setHeight(100),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.green),
          child: FlatButton(
            onPressed: () {
              setState(() {
                sign_in_user();
              });
            },
            child: Text(
              "Sign Up",
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40, allowFontScalingSelf: true)),
            ),
          ),
        ));
  }
}
