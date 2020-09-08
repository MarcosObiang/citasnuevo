
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../InterfazUsuario/Directo/live_screen.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import 'package:citasnuevo/InterfazUsuario/Gente/people_screen.dart';
import '../InterfazUsuario/Actividades/TarjetaEvento.dart';
import '../InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';


class FirebaseManager {
  static String UID;

  Future<String> getCurrentUserId(dynamic auth) async {
    String usercode = await auth.user.uid;

    if (usercode != null) {
      String userId = usercode;
      UID = userId;
      print(userId);
    }
  }


}
