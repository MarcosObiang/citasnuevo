import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/IniciodeSesion/login_screen.dart';
import '../../ServidorFirebase/firebase_sign_up.dart';
import 'sign_up_methods.dart';
import '../../main.dart';
import 'sign_up_screen_elements.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen_elements.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PantallaRegistro extends StatefulWidget {
  UserCredential credencialUsuario;

  PantallaRegistro({@required this.credencialUsuario}) {
    Usuario.esteUsuario.email = credencialUsuario.user.email;
    Usuario.esteUsuario.idUsuario = credencialUsuario.user.uid;
  }
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

  Future<bool> eliminarCacheApp() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
    return true;
  }

  Future<bool> eliinarDatosApp() async {
    final appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
    return true;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return ControladorInicioSesion.cerrarSesion();
      },
      child: ChangeNotifierProvider.value(
        value: Usuario.esteUsuario,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              resizeToAvoidBottomPadding: true,
              backgroundColor: Colors.deepPurple[900],
              body: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          height: ScreenUtil().setHeight(200),
                        ),
                        Text(
                          "Informacion Basica",
                          style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(60, allowFontScalingSelf: true),
                              color: Colors.white),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                                    widget.credencialUsuario.user.displayName,
                                    0,
                                    false,
                                    100,
                                    1,
                                    60),
                                Container(
                                  height: ScreenUtil().setHeight(40),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(10),
                        ),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Consumer<Usuario>(
                                  builder: (BuildContext context, usuario,
                                      Widget child) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          flex: 7,
                                          fit: FlexFit.tight,
                                          child: BotonNacimiento(
                                              usuario.fechaNacimiento),
                                        ),
                                        Flexible(
                                            flex: 4,
                                            fit: FlexFit.tight,
                                            child: MostradorEdad(usuario.edad))
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(30),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CampoSexo(),
                              campoPreferenciaSexual(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FlatButton(
                            color: Colors.blue,
                            child: Row(children: [
                              Text("Atras"),
                              Icon(Icons.arrow_back),
                            ]),
                            onPressed: () {
                              ControladorInicioSesion.cerrarSesion()
                                  .then((value) => Navigator.pop(context));
                            }),
                        FlatButton(
                            color: Colors.blue,
                            child: Row(children: [
                              Text("Siguiente"),
                              Icon(Icons.arrow_forward),
                            ]),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PantallaEdicionPerfil(),
                                ))),
                        Container(
                          height: ScreenUtil().setHeight(30),
                        ),
                      ],
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
              child: Container(
                height: ScreenUtil().setHeight(5000),
                child: Column(
                  children: <Widget>[
                    Text("Add pictures for your date profile"),
                    Consumer<Usuario>(
                      builder: (BuildContext context, usuario, Widget child) {
                        if (usuario.fotosPerfil[0] != null) {
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[],
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
                        false, 800, 9, 500),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.red),
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Atras"))),
                        Container(
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        pantallaRegistroTres()),
                              ),
                              child: Text("Siguiente"),
                            )),
                      ],
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

// TODO: implement build

class pantallaRegistroTres extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return pantallaRegistroTresState();
  }
}

class pantallaRegistroTresState extends State<pantallaRegistroTres> {
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
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.red),
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Atras"))),
                        Container(
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        pantallaRegistroCuatro()),
                              ),
                              child: Text("Siguiente"),
                            )),
                      ],
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

class pantallaRegistroCuatro extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return pantallaRegistroCuatroState();
  }
}

class pantallaRegistroCuatroState extends State<pantallaRegistroCuatro> {
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
              child: Container(
                height: ScreenUtil().setHeight(4000),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: ScreenUtil().setHeight(200),
                      child: Center(
                        child: Text(
                          "Cuentanos mas sobre ti",
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(120),
                          ),
                        ),
                      ),
                    ),
                    Consumer<Usuario>(builder: (context, usuario, child) {
                      return ListaCaracteristicasEditar();
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.red),
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Atras"))),
                        Container(
                            height: ScreenUtil().setHeight(150),
                            child: FlatButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        pantallaRegistroCinco()),
                              ),
                              child: Text("Siguiente"),
                            )),
                      ],
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

class pantallaRegistroCinco extends StatefulWidget {
  static int preguntasRestantes = 3;
  @override
  _pantallaRegistroCincoState createState() => _pantallaRegistroCincoState();
}

class _pantallaRegistroCincoState extends State<pantallaRegistroCinco> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
            color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: Consumer<Usuario>(
                    builder:
                        (BuildContext context, Usuario user, Widget child) {
                      return Column(
                        children: <Widget>[
                          Container(
                              height: ScreenUtil().setHeight(200),
                              child: Center(
                                  child: Text(
                                pantallaRegistroCinco.preguntasRestantes != 0
                                    ? "Elige ${pantallaRegistroCinco.preguntasRestantes} Preguntas Personales"
                                    : "Has respondido el maximo",
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(90)),
                              ))),
                          Container(
                            height: ScreenUtil().setHeight(1400),
                            child: ListView(
                              children: <Widget>[
                                PreguntaQueBuscasEnLaGente(),
                                PreguntaQueOdiasDeLaGente(),
                                PreguntaTuRecetaDeFelicidad(),
                                PreguntaSiQuedaraUnDiaDeVida(),
                                PreguntaQueTipoDeMusicaTeGusta(),
                                PreguntaEnQueCreesQueEresBueno(),
                                PreguntaQueEsLoQueMasValoras(),
                                PreguntaLaGenteDiceQueEres(),
                                PreguntaQueTeHaceReir(),
                                PreguntaCitaPErfecta(),
                                PReguntaCancionFavorita(),
                                PreguntaUnaVerdadYUnaMentira(),
                                PreguntaPorQueTeHariasFamoso(),
                                PreguntaSiFueraUnVillanooSeria(),
                                PreguntaSiFuerasUnHeroeSerias(),
                                PreguntaComidaRestoDeMiVida(),
                                PReguntaNosLLEvamosBienSi(),
                                PregutnaAnecdota(),
                                PReguntaBorrachoSoy(),
                                PreguntaPeliculaRecomendada(),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.red),
                        height: ScreenUtil().setHeight(150),
                        child: FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Atras"))),
                    Container(
                        color: Colors.green,
                        height: ScreenUtil().setHeight(150),
                        child: FlatButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PantalaPeticionPermisoUbicacion())),
                          child: Text("Siguiente"),
                        )),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}

class PantalaPeticionPermisoUbicacion extends StatefulWidget {
  bool permisoDenegado = false;
  @override
  _PantalaPeticionPermisoUbicacionState createState() =>
      _PantalaPeticionPermisoUbicacionState();
}

class _PantalaPeticionPermisoUbicacionState
    extends State<PantalaPeticionPermisoUbicacion> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.deepPurple[900],
      child: SafeArea(
        child: Container(
          color: Colors.deepPurple[900],
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              widget.permisoDenegado
                  ? dialogoCuandoUsuarioNiegaUbicacion()
                  : Container(),
              Divider(
                height: 100.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Permiso de ubicación",
                    style: GoogleFonts.lemon(
                        fontSize: 60.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Icon(
                    Icons.location_on,
                    size: 90.sp,
                    color: Colors.white,
                  ),
                ],
              ),
              Divider(
                height: 50.h,
              ),
              Text(
                "Es necesario que nos dejes acceder a tu ubicación para poder mostrarte gente cercana a ti, solo usaremos tu ubicación cuando estes utilizando la aplicación.",
                style: GoogleFonts.lato(color: Colors.white, fontSize: 55.sp),
                textAlign: TextAlign.start,
              ),
              Divider(
                height: 100.h,
              ),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.greenAccent[400],
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  child: FlatButton(
                      onPressed: () async {
                        await Permission.locationWhenInUse
                            .request()
                            .then((value) {
                          if (value.isGranted) {
                            Usuario.submit(context);
                          }
                          if (value.isDenied) {
                            setState(() {});
                            widget.permisoDenegado = true;
                          }
                          if (value.isPermanentlyDenied) {
                            setState(() {});
                            widget.permisoDenegado = true;
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 40, right: 40),
                        child: Text("Permitir",
                            style: TextStyle(
                                color: Colors.black, fontSize: 60.sp)),
                      )))
            ]),
          ),
        ),
      ),
    );
  }

  Container dialogoCuandoUsuarioNiegaUbicacion() {
    return Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Icon(
                            Icons.warning,
                            color: Colors.white,
                          ),
                        ),
                        Flexible(
                          flex: 8,
                          fit: FlexFit.tight,
                          child: Text(
                            "Es necesario tener permiso de ubicacion para poder continuar",
                            style: GoogleFonts.lato(
                                color: Colors.white, fontSize: 55.sp),
                            textAlign: TextAlign.start,
                          ),
                        )
                      ]),
                    ),
                  );
  }
}

class PantalaPeticionPermisoMicrofono extends StatefulWidget {
  @override
  _PantalaPeticionPermisoMicrofonoState createState() =>
      _PantalaPeticionPermisoMicrofonoState();
}

class _PantalaPeticionPermisoMicrofonoState
    extends State<PantalaPeticionPermisoMicrofono> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.deepPurple[900],
      child: SafeArea(
        child: Container(
          color: Colors.deepPurple[900],
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Permiso de acceso al Microfono",
                    style: GoogleFonts.lemon(
                        fontSize: 60.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Icon(
                    Icons.location_on,
                    size: 90.sp,
                    color: Colors.white,
                  ),
                ],
              ),
              Divider(
                height: 50.h,
              ),
              RichText(
                  text: TextSpan(
                      style: GoogleFonts.lato(
                          color: Colors.white, fontSize: 55.sp),
                      children: [
                    TextSpan(
                        text:
                            "Con este permiso permites a la aplicacion poder usar el microfono de tu dispositivo, se usa el microfono para las "),
                    TextSpan(
                        text: "VideoLlamadas",
                        style: GoogleFonts.lato(
                            fontSize: 55.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    TextSpan(text: " y para enviar"),
                    TextSpan(
                        text: "Mensajes de voz",
                        style: GoogleFonts.lato(
                            fontSize: 55.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ])),
              Divider(
                height: 100.h,
              ),
              Container(
                  decoration: BoxDecoration(
                      color: Colors.greenAccent[400],
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  child: FlatButton(
                      onPressed: () async {
                        await Permission.locationWhenInUse
                            .request()
                            .then((value) {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 40, right: 40),
                        child: Text("Permitir",
                            style: TextStyle(
                                color: Colors.black, fontSize: 60.sp)),
                      )))
            ]),
          ),
        ),
      ),
    );
  }
}
