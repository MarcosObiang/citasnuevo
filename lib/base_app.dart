import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/people_screen.dart';
import 'package:citasnuevo/InterfazUsuario/Descubrir/descubir.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';

import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/people_screen.dart';


import 'package:citasnuevo/InterfazUsuario/Social/social_screen.dart';



import 'package:flushbar/flushbar.dart';
import 'package:citasnuevo/main.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseAplicacion extends State<start> with WidgetsBindingObserver {
  static AppLifecycleState notificadorEstadoAplicacion; 
  static final GlobalKey claveNavegacion = GlobalKey();
  static final GlobalKey claveBase = GlobalKey();
  static final id = 'starter_app';
  static BaseAplicacion instancia=BaseAplicacion();
  static double alturaNavegacion = claveNavegacion.currentContext.size.height;
  static int indicePagina = 0;
  final tabs = [PantallaPrincipal(), ConversacionesLikes(),AjustesAplicacion()];
    FirebaseDatabase baseDatosConexion = FirebaseDatabase(
                        app: app,
                        databaseURL: "https://citas-46a84.firebaseio.com/");
                         FirebaseDatabase referenciaStatus = FirebaseDatabase(
                        app: app,
                        databaseURL: "https://citas-46a84.firebaseio.com/");

@override
void didChangeAppLifecycleState(AppLifecycleState estado){
  setState(() {
    notificadorEstadoAplicacion=estado;
  });
}


  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();
     WidgetsBinding.instance.addObserver(this);
  }

   @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  State<StatefulWidget> createState() {
    // ignore: todo
    // TODO: implement createState
    return BaseAplicacion();
  }

  Widget build(BuildContext context) {
    // ignore: todo
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Conversacion.conversaciones,
          child: MaterialApp(
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
                  child: tabs[indicePagina]),
              Consumer<Conversacion>(
                builder: (context, myType, child) {
                  print("construir");
                  return  barraBajaPrincipalNavegacion();
                },
              )
              
             
            ],
          ),
        ),
      ),
    );
  }

  Container barraBajaPrincipalNavegacion() {
    return Container(
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
                  currentIndex: indicePagina,
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
                        icon: Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
              Icon(Icons.people, size: ScreenUtil().setSp(60)),
            Container(
              height: 30.w,
              width: 30.w,
              
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Conversacion.cantidadMensajesNoLeidos>0&&BaseAplicacion.indicePagina!=1?  Colors.purple:Colors.transparent,
              ),
            ),
                          
                          ],
                       
                        )
                        
                        ,
                        title: new Text(
                          "",
                          style: TextStyle(
            fontSize: ScreenUtil().setSp(0),
            fontStyle: FontStyle.italic,
                          ),
                        ),
                        backgroundColor: Colors.red),
        
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
                    
                   
                      indicePagina = index;
                    });
                  },
             
                )
                
                
                
              );
  }
  Future<dynamic>notificacionPulsada(String c){
 print(c.toString());
 
   Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>ConversacionesLikes()) );
  
  


return null;}

Future<dynamic>onDidReceiveLocalNotification(int canal,String a,String b,String c){
   Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>ConversacionesLikes()) );
 return null;
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
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(10),
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
      margin: EdgeInsets.all(10),
    )..show(context);
  }
   


}
