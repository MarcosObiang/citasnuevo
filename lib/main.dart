import 'package:citasnuevo/InterfazUsuario/Gente/people_screen_elements.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen.dart';
import 'base_app.dart';
import 'DatosAplicacion/Conversacion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

void main(){
   WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(MaterialApp(
            home: login_screen(),
          )));
}

class start extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return starter_app();
  }
}
