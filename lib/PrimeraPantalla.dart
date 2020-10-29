import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/InterfazUsuario/Descubrir/descubir.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'InterfazUsuario/RegistrodeUsuario/sign_up_screen.dart';

class PantallaDeInicio extends StatefulWidget {
  final accesoArchivoCredencial = new FlutterSecureStorage();
 
  bool esFacebook = false;
  bool esGoogle = false;

  @override
  _PantallaDeInicioState createState() => _PantallaDeInicioState();
}

class _PantallaDeInicioState extends State<PantallaDeInicio> {
  @override
  void initState()  {
    // TODO: implement initState
   comprobarInicioSesion();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void comprobarInicioSesion()async{
     widget.esFacebook =
        await widget.accesoArchivoCredencial.containsKey(key: "Facebook");
        widget.esGoogle=await widget.accesoArchivoCredencial.containsKey(key: "Google");
    if (widget.esFacebook) {
      String tokenFacebook =
          await widget.accesoArchivoCredencial.read(key: "Facebook");
      ControladorInicioSesion.instancia
          .inicioSesionFacebook(tokenFacebook,context);
       
    }
    if(widget.esGoogle){
      String tokenGoogle=await widget.accesoArchivoCredencial.read(key: "Google");
      ControladorInicioSesion.instancia.inicioSesionGoogle(tokenGoogle,context);
    }


  }

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
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: FlatButton(
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              ControladorInicioSesion.instancia
                                  .inicioSesionFacebook(null,context)
                                  .then((value) {
                             

                        
                                 /* Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PantallaRegistro(
                                                credencialUsuario: value,
                                              )));*/
                                
                                
                               
                                
                              });
                            },
                            child: Row(
                              children: [
                                Icon(LineAwesomeIcons.google),
                                Text("Iniciar sesion con Facebook"),
                              ],
                            ))),
                    Divider(height: 50),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: FlatButton(
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              ControladorInicioSesion.instancia
                                  .inicioSesionGoogle(null,context);
                                  
                            },
                            child: Row(
                              children: [
                                Icon(LineAwesomeIcons.google),
                                Text("Iniciar sesion con Google"),
                              ],
                            ))),
                    Divider(height: 50),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: FlatButton(
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => login_screen())),
                            child: Text("Iniciar Sesion"))),
                    Divider(height: 50),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
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
