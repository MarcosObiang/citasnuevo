import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorSanciones.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorVideollamadas.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';

import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/EstadoConexion.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/liberadorMemoria.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/WidgetError.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';

import 'package:citasnuevo/base_app.dart';
import 'package:citasnuevo/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart' as f;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum FasesInicioSesion { sesionNoIniciada, iniciandoSesion, sesionIniciada }

class ControladorInicioSesion {
  static ControladorInicioSesion instancia = ControladorInicioSesion();
  FasesInicioSesion fasesInicioSesion = FasesInicioSesion.sesionNoIniciada;
  final archivoInicioSesionAutomatico = new FlutterSecureStorage();

  f.FirebaseAuth _auth = f.FirebaseAuth.instance;
  bool primeraConexion = false;
  GoogleSignIn googleSignIn = GoogleSignIn();
  var facebookLogin = FacebookLogin();

  ///
  ///
  ///
  ///
  ///
  ///
  ///Inicio de Sesion en google
  ///

  Future<f.UserCredential> inicioSesionGoogle(BuildContext context) async {
    fasesInicioSesion = FasesInicioSesion.iniciandoSesion;
    f.AuthCredential credencialGoogle;

    final GoogleSignInAccount usuarioGoogle =
        await googleSignIn.signIn().catchError((error) {
      if (error.code == "network_error") {
        ManejadorErroresAplicacion.erroresInstancia.mostrarErrorConexion(
            PantallaDeInicio.clavePrimeraPantalla.currentContext);
        fasesInicioSesion = FasesInicioSesion.sesionNoIniciada;
        Usuario.esteUsuario.notifyListeners();
      }
      if (error.code == "sign_in_failed") {
        ManejadorErroresAplicacion.erroresInstancia.mostrarErrorIniciarSesion(
            PantallaDeInicio.clavePrimeraPantalla.currentContext);
        fasesInicioSesion = FasesInicioSesion.sesionNoIniciada;
        Usuario.esteUsuario.notifyListeners();
      }
    });
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
      fasesInicioSesion = FasesInicioSesion.sesionIniciada;
      Usuario.esteUsuario.notifyListeners();
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
    Usuario.esteUsuario.notifyListeners();
    fasesInicioSesion = FasesInicioSesion.iniciandoSesion;
    FacebookLoginResult result = await facebookLogin.logIn(['email']);
    f.UserCredential usuarioFacebook;
    if (result.status == FacebookLoginStatus.cancelledByUser) {
      fasesInicioSesion = FasesInicioSesion.sesionNoIniciada;
      usuarioFacebook = null;
    }

//Problema al iniciar sesion del cual se daran detalles
    if (result.status == FacebookLoginStatus.error) {
      fasesInicioSesion = FasesInicioSesion.sesionNoIniciada;
      Usuario.esteUsuario.notifyListeners();
      print(
          "Ha ocurrido un error al conectar con Facebook:${result.errorMessage}");
      usuarioFacebook = null;
      ManejadorErroresAplicacion.erroresInstancia.mostrarErrorConexion(
          PantallaDeInicio.clavePrimeraPantalla.currentContext);
    }

//El iniciio de sesion ha sido un exito
    if (result.status == FacebookLoginStatus.loggedIn) {
      final f.AuthCredential credencialFacebook =
          f.FacebookAuthProvider.credential(result.accessToken.token);

      usuarioFacebook = await _auth.signInWithCredential(credencialFacebook);
      fasesInicioSesion = FasesInicioSesion.sesionIniciada;
      Usuario.esteUsuario.notifyListeners();
      print("sesionIniciada ${usuarioFacebook.user.displayName}");
    }

    return usuarioFacebook;
  }

  ///
  ///
  ///
  /// Cerrar sesion y liberarMemoria
  ///
  ///
  Future<bool> cerrarSesion() async {
    bool seCerroSesion;

    



    await _auth.signOut().then((value) async {
      seCerroSesion = true;

      await googleSignIn.isSignedIn().then((valor) {
        if (valor) {
          seCerroSesion = true;
          googleSignIn.disconnect().then((valorGogole) {
            EstadoConexionInternet.estadoConexion.baseDatosConexion.goOffline();

            LimpiadorMemoria.liberarMemoria();
          }).catchError((error) {
            print("Error al cerrar cuenta con google $error");
          });
        }
      });

      await facebookLogin.isLoggedIn.then((valorFacebook) {
        if (valorFacebook) {
          seCerroSesion = true;
          facebookLogin.logOut().then((val) {
                        EstadoConexionInternet.estadoConexion.baseDatosConexion.goOffline();

            LimpiadorMemoria.liberarMemoria();
          });
        }
      }).catchError((error) {
        print("Error al cerrar cuenta con facebook $error");
      });

      PantallaDeInicio.iniciarSesion = false;
    }).catchError((onError) => seCerroSesion = false);

    print("cerrando");

    return seCerroSesion;
  }

  Future<bool> iniciarSesion(
    String idUsuarioCredencial,
    BuildContext context,
  ) async {
    bool sinError = true;
    FirebaseFirestore basedatos = FirebaseFirestore.instance;

    Usuario.esteUsuario.idUsuario = idUsuarioCredencial;

    await basedatos
        .collection("usuarios")
        .doc(idUsuarioCredencial)
        .get()
        .then((value) async {
      Usuario.esteUsuario.datosUsuario = value.data();

      if (Usuario.esteUsuario.datosUsuario != null && value.exists) {
        ControladorCreditos.instancia.obtenerPrecioSolicitud();
        ControladorCreditos.instancia.obtenerPrecioValoracion();
        Usuario.esteUsuario.datosUsuario = value.data();
        Usuario.esteUsuario.inicializarUsuario();
        await SancionesUsuario.instancia.obtenerSanciones().then((valor) {
          if (Usuario.esteUsuario.usuarioBloqueado == true) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PantallaSancion(
                          desdePantalla: false,
                        )));
          }
          if (Usuario.esteUsuario.usuarioBloqueado == false) {
            ControladorAjustes.instancia.obtenerLocalizacion().then(
                 
                (value) async => ControladorAjustes.instancia.cargaPerfiles());
                Perfiles.perfilesCitas.estadoLista=EstadoListaPerfiles.cargandoLista;
            Conversacion.conversaciones.obtenerConversaciones();
            Valoracion.instanciar.obtenerValoraciones();

            Valoracion.instanciar.obtenerMedia();
            VideoLlamada.escucharLLamadasEntrantes();

            Conversacion.conversaciones.escucharMensajes();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => start()));
          }
        });

        EstadoConexionInternet.estadoConexion.confirmarEstadoConexion();

        ControladorCreditos.instancia.escucharEstadoUsuario();

        SolicitudConversacion.instancia.obtenerSolicitudes();
      }
      if (Usuario.esteUsuario.datosUsuario == null && value.exists == false) {
        sinError = false;
      }
    }).catchError((onError) => print("Error de inicio de sesion::=>$onError"));
                        EstadoConexionInternet.estadoConexion.baseDatosConexion.goOnline();

    return sinError;
  }
}
