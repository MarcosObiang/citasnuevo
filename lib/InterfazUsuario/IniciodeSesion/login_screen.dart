import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';

import '../RegistrodeUsuario/sign_up_screen.dart';
import '../../main.dart';
import 'login_screen_elements.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../ServidorFirebase/firebase_sign_up.dart';

class login_screen extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() {
     WidgetsFlutterBinding.ensureInitialized();
    // TODO: implement createState
    return login_screen_state();
  }
}

class login_screen_state extends State<login_screen> {
  
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }


  static String pass;
  static String email;

  String entradaClave = "Clave";

  String entradaEmail = "Email";

  static submit(BuildContext context) {
    print(pass);
    print(email);
  }

  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1440, height: 3120, allowFontScaling: true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
              child: SafeArea(
                    child: Container(
              height: ScreenUtil().setHeight(2400),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(100)),
                  color: Colors.deepPurple),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        "  Hello",
                        style: TextStyle(fontSize: ScreenUtil().setSp(150), color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new EntradaTextoAcceso(
                            Icon(
                              Icons.mail,
                              color: Colors.white,
                              size: ScreenUtil().setSp(100),
                            ),
                            entradaEmail,
                            5,
                            false,
                          ),
                          new EntradaTextoAcceso(
                            Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: ScreenUtil().setSp(100),
                            ),
                            entradaClave,
                            3,
                            true,
                          ),
                          Container(
                            height:   ScreenUtil().setHeight(20),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(20),
                          ),
                          Container(
                            height: ScreenUtil().setHeight(60),
                          ),
                          BotonAcceso()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
      
    );
  }
}

// TODO: implement build
