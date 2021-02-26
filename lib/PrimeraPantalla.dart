import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorNotificaciones.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/liberadorMemoria.dart';

import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:citasnuevo/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntp/ntp.dart';
import 'package:provider/provider.dart';
import 'InterfazUsuario/RegistrodeUsuario/sign_up_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
enum EstadoConexionInternet{
  noConectado,conectando,conectado,noDefinido
}

class PantallaDeInicio extends StatefulWidget {
  final accesoArchivoCredencial = new FlutterSecureStorage();
  static DateTime fechaActual;

  static bool iniciarSesion = false;
  static EstadoConexionInternet estaConectadoInternet=EstadoConexionInternet.noDefinido;
  static GlobalKey clavePrimeraPantalla = GlobalKey();

  @override
  PantallaDeInicioState createState() => PantallaDeInicioState();
}

class PantallaDeInicioState extends State<PantallaDeInicio> with RouteAware {
  @override
  void initState() {
    // TODO: implement initState
    DataConnectionChecker().hasConnection.then((value){
     if(value){
       PantallaDeInicio.estaConectadoInternet=EstadoConexionInternet.conectado;
         comprobarInicioSesion();

     }
     else{
       PantallaDeInicio.estaConectadoInternet=EstadoConexionInternet.noConectado;
       if(PantallaDeInicio.clavePrimeraPantalla.currentContext!=null){
 ControladorNotificacion.notificacionErrorConexion(PantallaDeInicio.clavePrimeraPantalla.currentContext);
       }
      
     }
    });
  

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
      // TODO: implement didChangeDependencies
      super.didChangeDependencies();
    }

      // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    debugPrint("didPopNext ${runtimeType}");

    setState(() {
          
        });
  }

  // Called when the current route has been pushed.
  void didPush() {
    debugPrint("didPush ${runtimeType}");
  }

  // Called when the current route has been popped off.
  void didPop() {
    debugPrint("didPop ${runtimeType}");
  }

  // Called when a new route has been pushed, and the current route is no longer visible.
  void didPushNext() {
    debugPrint("didPushNext ${runtimeType}");
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

    PantallaDeInicio.fechaActual=await NTP.now();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1080, height: 1920, allowFontScaling: true);



      
 return ChangeNotifierProvider.value(
   value: Usuario.esteUsuario,
   child: Consumer<Usuario>(
     builder: (context, myType, child) {
       return 
    SafeArea(
        key: PantallaDeInicio.clavePrimeraPantalla,
        child: Material(
          child: Container(
              color: Colors.deepPurple[900],
              child: Stack(
                children: [
                  Center(
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
                  ),
               
         ControladorInicioSesion.instancia.fasesInicioSesion==FasesInicioSesion.iniciandoSesion?      Center(child: Container(
                 height: 300.h,
                 width: ScreenUtil.screenWidth,
                 decoration:BoxDecoration(
              color:  Color.fromRGBO(20, 20, 20, 100),
                 borderRadius: BorderRadius.all(Radius.circular(10))),
                 child:Center(
                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceAround,
                       children: [
                         Text("Iniciando sesión",style:GoogleFonts.lato(color: Colors.white,fontSize:50.sp)),
                         CircularProgressIndicator()
                       ],
                     ),
                   ),
                 )
                 
                 ),):Container(height: 0,width: 0,)
                ],
              )),
        ),
      );
     },
   )
   
   
   
 );
    
   
  }
}
