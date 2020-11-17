import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:citasnuevo/ServidorFirebase/firebase_sign_up.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:citasnuevo/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as f;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ControladorInicioSesion {
  static ControladorInicioSesion instancia = ControladorInicioSesion();
  final archivoInicioSesionAutomatico = new FlutterSecureStorage();
  FirebaseDatabase baseDatosConexion = FirebaseDatabase(
      app: app, databaseURL: "https://citas-46a84.firebaseio.com/");
  FirebaseDatabase referenciaStatus = FirebaseDatabase(
      app: app, databaseURL: "https://citas-46a84.firebaseio.com/");
 static f.FirebaseAuth _auth = f.FirebaseAuth.instance;
  static bool primeraConexion = false;
  static GoogleSignIn googleSignIn = GoogleSignIn();
  static var facebookLogin = FacebookLogin();

  ///
  ///
  ///
  ///
  ///
  ///
  ///Inicio de Sesion en google
  ///
  

  Future<f.UserCredential> inicioSesionGoogle(BuildContext context) async {
    f.AuthCredential credencialGoogle;

    final GoogleSignInAccount usuarioGoogle = await googleSignIn.signIn();
    f.UserCredential usuario;
    if (usuarioGoogle == null) {
      usuario = null;
    } else {
      final GoogleSignInAuthentication autenticacionGoogle =
          await usuarioGoogle.authentication;
      credencialGoogle = f.GoogleAuthProvider.credential(
          accessToken: autenticacionGoogle.accessToken,
          idToken: autenticacionGoogle.idToken);

      usuario = await _auth.signInWithCredential(credencialGoogle);

      print("sesionIniciada ${usuario.user.displayName}");
    }

    return usuario;
  }

  ///
  ///
  ///
  ///
  ///Inicio de sesion en Facebook

  Future<f.UserCredential> inicioSesionFacebook(BuildContext context) async {
    FacebookLoginResult result = await facebookLogin.logIn(['email']);
    f.UserCredential usuarioFacebook;
    if (result.status == FacebookLoginStatus.cancelledByUser) {
      usuarioFacebook = null;
    }

//Problema al iniciar sesion del cual se daran detalles
    if (result.status == FacebookLoginStatus.error) {
      print(
          "Ha ocurrido un error al conectar con Facebook:${result.errorMessage}");
      usuarioFacebook = null;
    }

//El iniciio de sesion ha sido un exito
    if (result.status == FacebookLoginStatus.loggedIn) {
      final f.AuthCredential credencialFacebook =
          f.FacebookAuthProvider.credential(result.accessToken.token);

      usuarioFacebook = await _auth.signInWithCredential(credencialFacebook);
      print("sesionIniciada ${usuarioFacebook.user.displayName}");
    }

    return usuarioFacebook;
  }

  static Future<bool> cerrarSesion() async {
    bool seCerroSesion;
    await _auth.signOut().
    then((value)async {seCerroSesion=true;
    await googleSignIn.isSignedIn().then((value) {if(value){
seCerroSesion=true;
      googleSignIn.disconnect();
    }});

  await  facebookLogin.isLoggedIn.then((value) {
      if(value){
        seCerroSesion=true;
        facebookLogin.logOut();
    
      }
    });
     PantallaDeInicio.iniciarSesion=false;
    }).
    catchError((onError) => seCerroSesion = false);
print("cerrando");

    return seCerroSesion;
  }

  Future<bool> iniciarSesion(String idUsuario, BuildContext context,) async {
    bool sinError=true;
    FirebaseFirestore basedatos = FirebaseFirestore.instance;
    print("Usuario");

    Usuario.esteUsuario.idUsuario = idUsuario;

   await basedatos.collection("usuarios").doc(idUsuario).get().then((value) {
      Usuario.esteUsuario.DatosUsuario = value.data();

      if (Usuario.esteUsuario.DatosUsuario != null&&value.exists) {
        Usuario.esteUsuario.DatosUsuario = value.data();
        Usuario.esteUsuario.inicializarUsuario();
        
 ControladorLocalizacion.instancia.obtenerLocalizacion().then((value) =>
 
   ControladorLocalizacion.instancia.cargarPerfiles());
       

        Conversacion.conversaciones.obtenerConversaciones();
        Valoracion.Puntuaciones.obtenerValoraciones();

        Valoracion.Puntuaciones.obtenerMedia();
        VideoLlamada.escucharLLamadasEntrantes();

        Conversacion.conversaciones.escucharMensajes();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => start()));

        _confirmarEstadoConexion();

        print("Estaba vacio");
        CrontroladorCreditos.escucharCreditos();
       
        SolicitudConversacion.instancia.obtenerSolicitudes();
     
      }
      if(Usuario.esteUsuario.DatosUsuario == null&&!value.exists){
     //  FirebaseAuth.instance.currentUser.delete();
     // ignore: invalid_use_of_protected_member
     sinError=false;
     

      }
    }).catchError((onError)=>print("Error de inicio de sesion::=>$onError"));

return sinError;

  }

  void _confirmarEstadoConexion() {
    baseDatosConexion
        .reference()
        .child(".info/connected")
        .onValue
        .listen((event) {
      Map<String, dynamic> ultimaConexion = new Map();
      ultimaConexion["Status"] = "Conectado";
      ultimaConexion["Hora"] = DateTime.now().toString();
      ultimaConexion["idUsuario"] = Usuario.esteUsuario.idUsuario;
      Map<String, dynamic> ultimaDesconexion = new Map();
      ultimaDesconexion["Status"] = "Desconectado";
      ultimaDesconexion["Hora"] = DateTime.now().toString();
      ultimaDesconexion["idUsuario"] = Usuario.esteUsuario.idUsuario;

      referenciaStatus
          .reference()
          .child("/status/${Usuario.esteUsuario.idUsuario}")
          .set(ultimaConexion);

      referenciaStatus
          .reference()
          .child("/status/${Usuario.esteUsuario.idUsuario}")
          .onDisconnect()
          .set(ultimaDesconexion);

      if (event.snapshot.value) {
        Citas.estaConectado = true;

        primeraConexion = true;
        // BaseAplicacion.mostrarNotificacionConexionCorrecta(BaseAplicacion.claveBase.currentContext);
        Usuario.esteUsuario.notifyListeners();
      } else {
        Citas.estaConectado = false;
        if (primeraConexion) {
          //BaseAplicacion.mostrarNotificacionConexionPerdida(BaseAplicacion.claveBase.currentContext);
        }
        Usuario.esteUsuario.notifyListeners();
      }
    });
  }
}
