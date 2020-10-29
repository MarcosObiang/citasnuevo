import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:citasnuevo/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as usuarioFirebase;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ControladorInicioSesion {
  static ControladorInicioSesion instancia = ControladorInicioSesion();
  final archivoInicioSesionAutomatico=new FlutterSecureStorage();
  FirebaseDatabase baseDatosConexion = FirebaseDatabase(
      app: app, databaseURL: "https://citas-46a84.firebaseio.com/");
  FirebaseDatabase referenciaStatus = FirebaseDatabase(
      app: app, databaseURL: "https://citas-46a84.firebaseio.com/");
  usuarioFirebase.FirebaseAuth _auth = usuarioFirebase.FirebaseAuth.instance;
  static bool primeraConexion = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final facebookLogin = FacebookLogin();

  Future<usuarioFirebase.UserCredential> inicioSesionGoogle(String tokenAcceso,BuildContext context) async {
 usuarioFirebase.AuthCredential credencialGoogle;



    final GoogleSignInAccount usuarioGoogle = await _googleSignIn.signIn();
    if (usuarioGoogle == null) {
      return null;
    }

    if(tokenAcceso==null){
final GoogleSignInAuthentication autenticacionGoogle =
        await usuarioGoogle.authentication;
    credencialGoogle =
        usuarioFirebase.GoogleAuthProvider.credential(
            accessToken: autenticacionGoogle.accessToken,
            idToken: autenticacionGoogle.idToken);
              archivoInicioSesionAutomatico.write(key: "Google", value: "${autenticacionGoogle.accessToken}::::${autenticacionGoogle.idToken}");
              

              

    }
  
    else{
    List<String> separadorToken=  tokenAcceso.split("::::");
      credencialGoogle=usuarioFirebase.GoogleAuthProvider.credential(accessToken:separadorToken[0],idToken: separadorToken[1]);

    }
    

    final usuarioFirebase.UserCredential usuario =
        await _auth.signInWithCredential(credencialGoogle);
    print("sesionIniciada ${usuario.user.displayName}");
    iniciarSesion(usuario.user.uid, context);
    return usuario;
  }

  Future<usuarioFirebase.UserCredential> inicioSesionFacebook(String tokenAcceso,BuildContext context) async {
  FacebookLoginResult result;
  bool primeraVez=false;
    if(tokenAcceso==null){
      primeraVez=true;
   result = await facebookLogin.logIn(['email']);
   primeraVez=true;
   
    if (result.status == FacebookLoginStatus.error) {
      return null;
    }
    if(result.status==FacebookLoginStatus.loggedIn){
      tokenAcceso=result.accessToken.token;
      archivoInicioSesionAutomatico.write(key: "Facebook", value: tokenAcceso);
     
      

    }
    }
 
    final usuarioFirebase.AuthCredential credencialFacebook =
        usuarioFirebase.FacebookAuthProvider.credential(tokenAcceso);

    final usuarioFirebase.UserCredential usuarioFacebook =
        await _auth.signInWithCredential(credencialFacebook);
    print("sesionIniciada ${usuarioFacebook.user.displayName}");
   if(!primeraVez){
     iniciarSesionPrimeraVez(usuarioFacebook.user.uid,context);}
     if(primeraVez){
       iniciarSesion(usuarioFacebook.user.uid, context);
     }
    return usuarioFacebook;
  }

  Future<bool> cerrarSesion()async{
    bool seCerroSesion;
    await _auth.signOut().catchError((onError)=> seCerroSesion=false);
 
    if(seCerroSesion==null){
      seCerroSesion=true;
    await  archivoInicioSesionAutomatico.delete(key: "Facebook");
    await archivoInicioSesionAutomatico.delete(key: "Google");
    }
    return seCerroSesion;
  }

  void iniciarSesion(String idUsuario,BuildContext context) async {
    FirebaseFirestore basedatos = FirebaseFirestore.instance;
    print("Usuario");

    Usuario.esteUsuario.idUsuario = idUsuario;

    basedatos.collection("usuarios").doc(idUsuario).get().then((value) {
      Usuario.esteUsuario.DatosUsuario = value.data();

      if (Usuario.esteUsuario.DatosUsuario != null) {
        Usuario.esteUsuario.DatosUsuario = value.data();
        Usuario.esteUsuario.inicializarUsuario();
        Perfiles.cargarPerfilesCitas();

        Conversacion.conversaciones.obtenerConversaciones();
        Valoraciones.Puntuaciones.obtenerValoraciones();

        Valoraciones.Puntuaciones.obtenerMedia();
        VideoLlamada.escucharLLamadasEntrantes();

        Conversacion.conversaciones.escucharMensajes();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => start()));

        _confirmarEstadoConexion();

        print("Estaba vacio");
         CrontroladorCreditos.escucharCreditos();
      }
    });
  }
    void iniciarSesionPrimeraVez(String idUsuario,BuildContext context) async {
    FirebaseFirestore basedatos = FirebaseFirestore.instance;
    print("Usuario");

    Usuario.esteUsuario.idUsuario = idUsuario;

    basedatos.collection("usuarios").doc(idUsuario).get().then((value) {
      Usuario.esteUsuario.DatosUsuario = value.data();

      if (Usuario.esteUsuario.DatosUsuario != null) {
        Usuario.esteUsuario.DatosUsuario = value.data();
        Usuario.esteUsuario.inicializarUsuario();
        Perfiles.cargarPerfilesCitas();

        Conversacion.conversaciones.obtenerConversaciones();
        Valoraciones.Puntuaciones.obtenerValoraciones();

        Valoraciones.Puntuaciones.obtenerMedia();
        VideoLlamada.escucharLLamadasEntrantes();

        Conversacion.conversaciones.escucharMensajes();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => start()));

        _confirmarEstadoConexion();

        print("Estaba vacio");
        CrontroladorCreditos.escucharCreditos();
      }
    });
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
