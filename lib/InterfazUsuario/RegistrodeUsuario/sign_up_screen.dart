import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import '../../ServidorFirebase/firebase_sign_up.dart';
import 'sign_up_methods.dart';
import '../../main.dart';
import 'sign_up_screen_elements.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PantallaRegistro extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PantallaRegistroState();
  }
}

class PantallaRegistroState extends State<PantallaRegistro> {
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  DateTime date;
  int age = BotonNacimientoState.GetAge();
  String sex = "Sexo";
  String i_like = "Man";
  String campoUsuario = "Nombre";
  String campoAlias = "Alias";
  String campoClave = "Clave";
  String campoConfirmarClave = "Cofirmar clave";
  String campoEmail = "Email";
  String campoSexo = "Sex";
  String campoCitasCon = "I Like";

  void showErrorDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: <Widget>[
                Icon(LineAwesomeIcons.exclamation_triangle),
                Text("Error"),
              ],
            ),
            content: Text(ErrorMessages.errores[ErrorMessages.error]),
            actions: <Widget>[],
          );
        });
  }

  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1440, height: 3120, allowFontScaling: true);
    return ChangeNotifierProvider.value(
      value: Usuario.esteUsuario,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
            backgroundColor: Color.fromRGBO(255, 78, 132, 100),
            body: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      " Sign Up",
                      style: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(120, allowFontScalingSelf: true),
                          color: Colors.white),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color.fromRGBO(69, 76, 80, 90),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            new EntradaTexto(
                                Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                                campoUsuario,
                                0,
                                false,
                                100,
                                1,
                                80),
                            Container(
                              height: ScreenUtil().setHeight(40),
                            ),
                            new EntradaTexto(
                                Icon(
                                  Icons.face,
                                  color: Colors.black,
                                ),
                                campoAlias,
                                1,
                                false,
                                100,
                                1,
                                80),
                            Container(
                              height: ScreenUtil().setHeight(40),
                            ),
                            new EntradaTexto(
                                Icon(
                                  Icons.lock,
                                  color: Colors.black,
                                ),
                                campoClave,
                                2,
                                true,
                                120,
                                1,
                                80),
                            Container(
                              height: ScreenUtil().setHeight(40),
                            ),
                            new EntradaTexto(
                                Icon(
                                  Icons.lock,
                                  color: Colors.black,
                                ),
                                campoConfirmarClave,
                                3,
                                true,
                                120,
                                1,
                                80),
                            Container(
                              height: ScreenUtil().setHeight(40),
                            ),
                            new EntradaTexto(
                                Icon(
                                  Icons.mail,
                                  color: Colors.black,
                                ),
                                campoEmail,
                                4,
                                false,
                                120,
                                1,
                                80),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: ScreenUtil().setHeight(80),
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Color.fromRGBO(69, 76, 80, 90),
                            ),
                            height: ScreenUtil().setHeight(200),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Consumer<Usuario>(
                                builder: (BuildContext context, usuario,
                                    Widget child) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      BotonNacimiento(usuario.fechaNacimiento),
                                      Divider(),
                                      MostradorEdad(usuario.edad)
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: ScreenUtil().setHeight(80),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color.fromRGBO(69, 76, 80, 90),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CampoSexo(),
                            campoPreferenciaSexual(),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: ScreenUtil().setHeight(80),
                    ),
                    Center(child: next_button()),
                    Container(
                      height: ScreenUtil().setHeight(70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class sign_up_confirm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return sign_up_confirm_state();
  }
}

class sign_up_confirm_state extends State<sign_up_confirm> {
  String coche = "Automoviles";
  String videojuegos = "VideoJuegos";
  String cine = "Cine";
  String bricolaje = "Manualidades y Bricolaje";
  String comida = "Comida";
  String moda = "Moda y Belleza";
  String animales = "Aniimales";
  String musica = "Musica";
  String naturaleza = "Naturaleza";
  String ciencia = "Ciencia y Tecnologia";
  String politica = "Politica y Sociedad";
  String viajes = "Viajes";
  String fiesta = "Fiesta";
  String vidasocial = "Vida Social";
  String fittnes = "Deporte y Fittness";
  String salud = "Salud";
  String virtudes = "Mis Virtudes";
  String defectos = "Mis Defectos";
  String nomegusta = "No me Gusta";
  String megusta = "Me Gusta";
  String megustadelagente = "¿Que te gusta en una persona?";
  String nomegustadelagente = "¿Que no te gusta en una persona?";
  String descripcion = "Descripcion";
  static String descripcion_fotos_perfil = "Add pictures to your profile";
  static String seleccionar_modo = "What do you preffer";
  static String textocitas = "Cita";
  static String textoaigos = "Amistad";
  static String texto_ambos = "Ambos (Predeterminado)";
  static final GlobalKey claveScaffold = GlobalKey();

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Usuario.esteUsuario,
      child: SafeArea(
        child: Scaffold(
          key: claveScaffold,
          backgroundColor: Color.fromRGBO(255, 78, 132, 100),
          body: Padding(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(30),
                right: ScreenUtil().setWidth(30)),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text("Add pictures for your date profile"),
                  Consumer<Usuario>(
                    builder: (BuildContext context, usuario, Widget child) {
                      if (usuario.FotosPerfil[0] != null) {
                        print(usuario);
                      }
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Color.fromRGBO(69, 76, 80, 90),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Stack(children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  height: ScreenUtil().setHeight(30),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    FotosPerfil(0, usuario.FotosPerfil[0]),
                                    FotosPerfil(1, usuario.FotosPerfil[1]),
                                    FotosPerfil(2, usuario.FotosPerfil[2]),
                                  ],
                                ),
                                Container(
                                  height: ScreenUtil().setHeight(50),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    FotosPerfil(3, usuario.FotosPerfil[3]),
                                    FotosPerfil(4, usuario.FotosPerfil[4]),
                                    FotosPerfil(5, usuario.FotosPerfil[5]),
                                  ],
                                )
                              ],
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                  Container(
                    height: ScreenUtil().setHeight(50),
                  ),
                  Container(child: ElegirModo("Hola", "Hombre ", " Mujer")),
                  Container(
                    height: ScreenUtil().setHeight(50),
                  ),
                  Text("Cuentanos un poco sobre ti"),
                  EntradaTexto(Icon(LineAwesomeIcons.comment), descripcion, 5,
                      false, 500, 4, 250),
                  Container(
                    height: ScreenUtil().setHeight(80),
                  ),

                  Container(
                    height: ScreenUtil().setHeight(800),
                    child: Center(
                      child: BotonConfirmarRegistro(context),
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
