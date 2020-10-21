import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import '../InterfazUsuario/Directo/live_screen.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/people_screen.dart';
import '../InterfazUsuario/Actividades/TarjetaEvento.dart';
import '../InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../DatosAplicacion/Usuario.dart';





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
