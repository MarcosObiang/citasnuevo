import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:citasnuevo/DatosAplicacion/Directo.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';

import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import 'DatosAplicacion/Valoraciones.dart';
import 'base_app.dart';

FirebaseApp app;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
     
      options: FirebaseOptions(
        projectId: "citas-46a84",
          appId: "1:912262965304:android:d56900e27f33762bf81ecd",
          apiKey: "AIzaSyBdm1Z9JMh_MSErVg6MgvrmuPtPbxC_Eqc",
          databaseURL: "https://citas-46a84.firebaseio.com/",
          messagingSenderId: "912262965304"));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(MaterialApp(
            home: MultiProvider(providers: [
              ChangeNotifierProvider(create: (_) => Usuario()),
              ChangeNotifierProvider(create: (_) => Perfiles()),
              ChangeNotifierProvider(create: (_) => Valoraciones.instanciar),
              ChangeNotifierProvider(create: (_) => Conversacion.instancia(),
              ),
            ], child: PantallaDeInicio()),
          )));
}

class start extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return starter_app();
  }
}
