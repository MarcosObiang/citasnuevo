import 'package:firebase_auth/firebase_auth.dart' as usuarioFirebase;
import 'package:google_sign_in/google_sign_in.dart';

class ControladorInicioSesion {
  static ControladorInicioSesion instancia=ControladorInicioSesion();
  usuarioFirebase.FirebaseAuth _auth = usuarioFirebase.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<usuarioFirebase.UserCredential> inicioSesionGoogle() async {
    final GoogleSignInAccount usuarioGoogle = await _googleSignIn.signIn();
    if (usuarioGoogle == null) {
      return null;
    }
    final GoogleSignInAuthentication autenticacionGoogle =
        await usuarioGoogle.authentication;
    final usuarioFirebase.AuthCredential credencialGoogle =
        usuarioFirebase.GoogleAuthProvider.credential(
            accessToken: autenticacionGoogle.accessToken,
            idToken: autenticacionGoogle.idToken);

    final usuarioFirebase.UserCredential usuario =
        await _auth.signInWithCredential(credencialGoogle);
    print("sesionIniciada ${usuario.user.displayName}");
    return usuario;
  }
}
