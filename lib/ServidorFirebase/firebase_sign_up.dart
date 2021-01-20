import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';






class AuthService {

  static final auth = FirebaseAuth.instance;
  static final firestore = Firestore.instance;
  static String userId;

  static Future<String> signUpUser(
       String nombre, String alias,String password, String email,int edad,String sexo,String interes_sexual) async {
    try {
      dynamic authResult = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      // ignore: missing_return
      ).then((respuesta){
       userId=respuesta.user.uid;
      /* if(UserId!=null){
         Usuario.esteUsuario.InicializarUsuario();
         Perfiles.perfilesCitas.obtenetPerfilesCitas();
         Perfiles.perfilesAmistad.obtenerPerfilesAmistad();
       }*/
        return null;
      });
      FirebaseUser signedInUser = authResult.user;


    } catch (e) {
      print(e);
    }
    return userId;
  }
}
