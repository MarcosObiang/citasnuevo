import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/liberadorMemoria.dart';

import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'InterfazUsuario/RegistrodeUsuario/sign_up_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

class PantallaDeInicio extends StatefulWidget {
  final accesoArchivoCredencial = new FlutterSecureStorage();
  static bool iniciarSesion = false;
  static GlobalKey clavePrimeraPantalla = GlobalKey();

  @override
  PantallaDeInicioState createState() => PantallaDeInicioState();
}

class PantallaDeInicioState extends State<PantallaDeInicio> {
  @override
  void initState() {
    // TODO: implement initState
    comprobarInicioSesion();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void comprobarInicioSesion() async {
    if (FirebaseAuth.instance.currentUser != null) {
      PantallaDeInicio.iniciarSesion = true;
 

      ControladorInicioSesion.instancia
          .iniciarSesion(
        FirebaseAuth.instance.currentUser.uid,
        context,
      )
          .then((value) {
        if (value == false) {
          setState(() {
            PantallaDeInicio.iniciarSesion = false;
          });
        }
      });
    } else {
      PantallaDeInicio.iniciarSesion = false;
      print("Ha ocurrido un error");
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1080, height: 1920, allowFontScaling: true);
    return SafeArea(
      key: PantallaDeInicio.clavePrimeraPantalla,
      child: Material(
        child: Container(
            color: Colors.deepPurple[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Hotty",
                      style: GoogleFonts.lemon(
                        fontSize: 200.sp,
                        color: Colors.white,
                      )),
                  !PantallaDeInicio.iniciarSesion
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                child: FacebookSignInButton(
                                  text: "Entra con Facebook",
                                  onPressed: () {
                                     Usuario.esteUsuario = new Usuario();
                                    ControladorInicioSesion.instancia
                                        .inicioSesionFacebook(context)
                                        .then((value) {
                                      if (value != null &&
                                          value.additionalUserInfo.isNewUser) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PantallaRegistro(
                                                      credencialUsuario: value,
                                                    )));
                                      }

                                      if (value != null &&
                                          !value.additionalUserInfo.isNewUser) {
                                                   Usuario.esteUsuario = new Usuario();
                                        ControladorInicioSesion.instancia
                                            .iniciarSesion(
                                                value.user.uid, context)
                                            .then((valor) {
                                          if (valor == false) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PantallaRegistro(
                                                          credencialUsuario:
                                                              value,
                                                        )));
                                          }
                                        });
                                      }
                                    });
                                  },
                                ),
                              ),
                              Divider(height: 50),
                              GoogleSignInButton(
                                text: "Entra con Google",
                                onPressed: () {
                                         Usuario.esteUsuario = new Usuario();
                                  ControladorInicioSesion.instancia
                                      .inicioSesionGoogle(context)
                                      .then((value) {
                                    if (value != null &&
                                        value.additionalUserInfo.isNewUser) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PantallaRegistro(
                                                    credencialUsuario: value,
                                                  )));
                                    }

                                    if (value != null &&
                                        !value.additionalUserInfo.isNewUser) {
                                                 Usuario.esteUsuario = new Usuario();
                                      ControladorInicioSesion.instancia
                                          .iniciarSesion(
                                              value.user.uid, context)
                                          .then((valor) {
                                        if (valor == false) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PantallaRegistro(
                                                        credencialUsuario:
                                                            value,
                                                      )));
                                        }
                                      });
                                    }
                                  });
                                },
                              ),
                              Divider(height: 50),
                            ])
                      : Container(),
                ],
              ),
            )),
      ),
    );
  }
}
