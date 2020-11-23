import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorPermisos.dart';
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
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Divider(
                          height: ScreenUtil().setHeight(50),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Informacion Basica",
                            style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(60, allowFontScalingSelf: true),
                                color: Colors.white),
                          ),
                        ),
                        Consumer<Usuario>(
                          builder: (context, myType, child) {
                            return cuadroInformacionBasica();
                          },
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
                                      builder: (context) =>
                                          PantallaEdicionPerfil(),
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
        ),
      ),
    );
  }

  Container cuadroInformacionBasica() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.deepPurple[300], blurRadius: 2, spreadRadius: 2)
          ],
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Consumer<Usuario>(
              builder: (BuildContext context, usuario, Widget child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 7,
                      fit: FlexFit.tight,
                      child: BotonNacimiento(usuario.fechaNacimiento),
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
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CampoSexo(),
                CampoPreferenciaSexual(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// TODO: implement build

class PantallaBiografiaUsuario extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PantallaBiografiaUsuarioState();
  }
}

class PantallaBiografiaUsuarioState extends State<PantallaBiografiaUsuario> {
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
                                        PantallaSolicitudUbicacion()),
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

class PantallaSolicitudUbicacion extends StatefulWidget {
  @override
  _PantallaSolicitudUbicacionState createState() =>
      _PantallaSolicitudUbicacionState();
}

class _PantallaSolicitudUbicacionState
    extends State<PantallaSolicitudUbicacion> {
  bool permisoDenegado = false;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.deepPurple[900],
      child: SafeArea(
        child: Container(
          color: Colors.deepPurple[900],
          child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  permisoDenegado
                      ? dialogoCuandoUsuarioNiegaUbicacion()
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Permiso de ubicacion",
                        style: GoogleFonts.lemon(
                            fontSize: 55.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(LineAwesomeIcons.alternate_map_marker,
                          size: 70.sp, color: Colors.white),
                    ],
                  ),
                  Divider(
                    height: 50.h,
                  ),
                  Text(
                    "Hotty se basa en tu ubicacion para mostrarte los perfiles mas cercanos a ti, por eso la aplpicacion necesita tu permiso para acceder a los servicios de ubicacion de tu dispositivo.Tu ubicacion solo se usará mientras estés usando la aplicación",
                    style: GoogleFonts.lato(
                        fontSize: 50.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.normal),
                  ),
                  GestureDetector(
                    onTap: ()async {
                      print("dddd");
                    await  ControladorPermisos.instancia
                          .comprobarPermisoUbicacion()
                          .then((value) {
                        if (value == EstadosPermisos.permisoDenegado) {
                         
                          setState(() {
 permisoDenegado = true;

                          });
                        }
                        if (value ==
                            EstadosPermisos.permisoDenegadoPermanente) {
                          setState(() {
                            permisoDenegado = true;
                          });
                          
                        }
                        if (value == EstadosPermisos.permisoConcedido) {
                          setState(() {
    permisoDenegado = false;
                          Usuario.submit(context);
                          });
                      
                        }
                      });
                    },
                    child: Container(
                      width: 500.w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.greenAccent[700]),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text("Dar permiso")),
                      ),
                    ),
                  )
                ],
              ))),
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
              style: GoogleFonts.lato(color: Colors.white, fontSize: 55.sp),
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
