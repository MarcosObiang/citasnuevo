import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/actividad.dart';
import 'package:citasnuevo/InterfazUsuario/Gente/people_screen_elements.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen.dart';
import 'package:provider/provider.dart';
import 'DatosAplicacion/Valoraciones.dart';
import 'base_app.dart';
import 'DatosAplicacion/Conversacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(MaterialApp(
            home: MultiProvider(providers: [
              ChangeNotifierProvider(create: (_) => Usuario()),
              ChangeNotifierProvider(create: (_) => Actividad()),
              ChangeNotifierProvider(create: (_) => Perfiles()),
              ChangeNotifierProvider(create: (_) => Valoraciones()),
              ChangeNotifierProvider(create: (_) => Conversacion.Instancia()),
            ], child: PantallaRegistro()),
          )));
}

class start extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    print("Construyo desde el inicio");
    // TODO: implement createState
    return starter_app();
  }
}
