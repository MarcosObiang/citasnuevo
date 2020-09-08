import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'InterfazUsuario/RegistrodeUsuario/sign_up_screen.dart';

class PantallaDeInicio extends StatefulWidget {
  @override
  _PantallaDeInicioState createState() => _PantallaDeInicioState();
}

class _PantallaDeInicioState extends State<PantallaDeInicio> {
  @override
  Widget build(BuildContext context) {
     ScreenUtil.init(context, width: 1080, height: 1920, allowFontScaling: true);
    return SafeArea(
      child: Material(
        child: Container(
            color: Colors.red,
            child: Center(
              child: Column(
                
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: FlatButton(
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      splashColor: Colors.transparent,
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => login_screen())),
                        child: Text("Iniciar Sesion"))),
                        Divider(
                          height:50
                        ),
                         Container(
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: FlatButton(
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      splashColor: Colors.transparent,
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PantallaRegistro())),
                        child: Text("Registrarse")))

              ]),
            )),
      ),
    );
  }
}
