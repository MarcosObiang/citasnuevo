import 'package:citasnuevo/InterfazUsuario/Descubrir/descubir.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';

import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/Gente/people_screen.dart';


import 'package:citasnuevo/InterfazUsuario/Social/social_screen.dart';

import 'package:citasnuevo/InterfazUsuario/Directo/live_screen.dart';
import 'package:citasnuevo/InterfazUsuario/Social/social_screen.dart';
import 'package:flushbar/flushbar.dart';
import 'package:citasnuevo/main.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class starter_app extends State<start> {
  static final GlobalKey claveNavegacion = GlobalKey();
  static final GlobalKey claveBase = GlobalKey();
  static final id = 'starter_app';
  static double alturaNavegacion = claveNavegacion.currentContext.size.height;
    FirebaseDatabase baseDatosConexion = FirebaseDatabase(
                        app: app,
                        databaseURL: "https://citas-46a84.firebaseio.com/");
                         FirebaseDatabase referenciaStatus = FirebaseDatabase(
                        app: app,
                        databaseURL: "https://citas-46a84.firebaseio.com/");


  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
  }

  int page_index = 0;
  final tabs = [pantalla(), people(), PantallaDirecto(), social_screen()];

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return starter_app();
  }

  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      key: claveBase,
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          highlightColor: Colors.purple,
          tabBarTheme: TabBarTheme(
              unselectedLabelStyle: TextStyle(fontSize: ScreenUtil().setSp(50)),
              labelColor: Colors.green,
              unselectedLabelColor: Colors.black87,
              labelStyle: TextStyle(fontSize: ScreenUtil().setSp(50))),
          primaryColor: Colors.white,
          accentColor: Colors.purple),
      home: Container(
        color: Colors.white,
        height: ScreenUtil.screenHeight,
        child: Column(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height -
                    kBottomNavigationBarHeight,
                child: tabs[page_index]),
            Container(
              height: kBottomNavigationBarHeight,
              child: BottomNavigationBar(
                key: claveNavegacion,
                iconSize: ScreenUtil().setSp(1),
                unselectedLabelStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(1),
                    fontStyle: FontStyle.italic,
                    color: Colors.black87),
                selectedLabelStyle: TextStyle(
                    fontSize: ScreenUtil().setSp(1),
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                selectedIconTheme: IconThemeData(color: Colors.black, size: 25),
                selectedItemColor: Colors.black,
                currentIndex: page_index,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                elevation: 0.0,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: ScreenUtil().setSp(60)),
                    title: new Text(
                      "",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(0),
                      ),
                    ),
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.people, size: ScreenUtil().setSp(60)),
                      title: new Text(
                        "",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(0),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      backgroundColor: Colors.red),
                  BottomNavigationBarItem(
                      icon: Icon(
                        LineAwesomeIcons.globe,
                        size: ScreenUtil().setSp(60),
                      ),
                      title: new Text(
                        "",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(0),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      backgroundColor: Colors.white),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings, size: ScreenUtil().setSp(60)),
                      title: new Text(
                        "",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(0),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      backgroundColor: Colors.deepPurple),
                ],
                onTap: (index) {
                  setState(() {
                  
                 
                    page_index = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

 static  void mostrarNotificacionConexionCorrecta(BuildContext context) {
    Flushbar(
      message: "Estas conectado",
      duration: Duration(seconds:3),
  
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.green,
      forwardAnimationCurve: Curves.ease,
      title: "Conexion",
      icon: Icon(LineAwesomeIcons.check_circle),
      reverseAnimationCurve: Curves.ease,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      borderRadius: 10,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(20),
    )..show(context);
  }

  
 static  void mostrarNotificacionConexionPerdida(BuildContext context) {
    Flushbar(
      message: "Estas desconectado",
      duration: Duration(seconds:3),

      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.red,
      forwardAnimationCurve: Curves.ease,
      title: "Conexion",
      icon: Icon(Icons.cancel,),
      reverseAnimationCurve: Curves.ease,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      borderRadius: 10,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(20),
    )..show(context);
  }
}
