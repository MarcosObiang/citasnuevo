
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/liberadorMemoria.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';


import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/pantalla_actividades_elements.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'DatosAplicacion/Valoraciones.dart';
import 'base_app.dart';

FirebaseApp app;
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  
  ControladorNotificacion.instancia.inicializarNotificaciones();
  


  app = await Firebase.initializeApp(
     
      options: FirebaseOptions(

       projectId: "citas-46a84",
          appId: "1:912262965304:android:6a20f31e4ab32f9bf81ecd",
          apiKey: "AIzaSyBdm1Z9JMh_MSErVg6MgvrmuPtPbxC_Eqc",
          databaseURL: "https://citas-46a84.firebaseio.com/",
          messagingSenderId: "912262965304"));
        LimpiadorMemoria.iniciarMemoria();
          
         
         SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
         SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  statusBarColor: Colors.deepPurple
));
         

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  
  
      .then((_) => runApp(MaterialApp(
        color: Colors.black,
        

        theme: ThemeData(primaryColor: Colors.deepPurple),
        debugShowCheckedModeBanner: false,
           routes: {
             "/PantallaInicio":(_)=>PantallaDeInicio()
           },
            home: MultiProvider(providers: [
              ChangeNotifierProvider(create: (_) => Usuario()),
              ChangeNotifierProvider(create: (_) => Perfiles()),
              ChangeNotifierProvider(create: (_) => ControladorAjustes.instancia),
              ChangeNotifierProvider(create: (_) => Valoracion.instanciar),
              ChangeNotifierProvider(create: (_) => Conversacion.instancia(),
              ),
            ], child: PantallaDeInicio()),
             navigatorObservers: [routeObserver],
          )));
}

class start extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BaseAplicacion();
  }
}
