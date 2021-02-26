import 'dart:io';

import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorPermisos.dart';
import 'package:citasnuevo/InterfazUsuario/WidgetError.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:string_validator/string_validator.dart';

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
  static final GlobalKey clavePAtallaRegistro=new GlobalKey();

  PantallaRegistro({@required this.credencialUsuario});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PantallaRegistroState();
  }
}

class PantallaRegistroState extends State<PantallaRegistro> {
  void initState() {
    User user = AuthService.auth.currentUser;

    if (widget.credencialUsuario.user.email != null) {
      Usuario.esteUsuario.email = widget.credencialUsuario.user.email;
    }
    if (widget.credencialUsuario.user.displayName != null) {
      Usuario.esteUsuario.nombre = widget.credencialUsuario.user.displayName;
    } else {
      Usuario.esteUsuario.email = user.providerData[0].email;
    }

    Usuario.esteUsuario.idUsuario = widget.credencialUsuario.user.uid;
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  final introKey = GlobalKey<IntroductionScreenState>();

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
  int pos;
  bool permisoDenegado = false;

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
      key: PantallaRegistro.clavePAtallaRegistro,
      onWillPop: () {
        return ;
      },
      child: ChangeNotifierProvider.value(
          value: Usuario.esteUsuario,
          child: Consumer<Usuario>(
            builder: (context, myType, child) {
              return MaterialApp(
                
                debugShowCheckedModeBanner: false,
                home: Stack(
                  children: [
                    SafeArea(
                      child: Scaffold(
                          resizeToAvoidBottomInset: false,
                          resizeToAvoidBottomPadding: true,
                          backgroundColor: Colors.deepPurple[900],
                          body: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints limitesMayores) {
                              return Container(
                                height: limitesMayores.biggest.height,
                                width: limitesMayores.biggest.width,
                                child: IntroductionScreen(
                                  key: introKey,
                                  initialPage: 0,
                                  freeze: true,
                                  showSkipButton: false,
                                  dotsFlex: 2,
                                  onDone: () {},
                                  done: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.arrow_forward),
                                      )),
                                  pages: [
                                    PageViewModel(
                                      decoration: PageDecoration(
                                          pageColor: Colors.deepPurple),
                                      titleWidget: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 100, bottom: 50),
                                        child: Text("Hola, ¿Cómo te llamas?",
                                            style: GoogleFonts.lato(
                                                color: Colors.white,
                                                fontSize: 120.sp)),
                                      ),
                                      bodyWidget: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                              ),
                                              child: new EntradaTexto(
                                                  Icon(
                                                    Icons.person,
                                                    color: Colors.black,
                                                  ),
                                                  Usuario.esteUsuario.nombre,
                                                  0,
                                                  false,
                                                  100,
                                                  1,
                                                  60),
                                            ),
                                            Divider(
                                              height: 500.h,
                                            ),
                                            RaisedButton(
                                              color: Colors.green,
                                              onPressed: () {
                                                String nombreUsuarioSinEspacio =
                                                    Usuario
                                                        .esteUsuario.nombre
                                                        .replaceAll(
                                                            new RegExp(
                                                                r"\s\b|\b\s"),
                                                            "");
                                                if (Usuario.esteUsuario.nombre !=
                                                        null &&
                                                    Usuario.esteUsuario.nombre
                                                        .isNotEmpty &&
                                                    isAlpha(nombreUsuarioSinEspacio) ==
                                                        true) {
                                                  introKey.currentState
                                                      ?.animateScroll(1);
                                                } else {
                                                  ManejadorErroresAplicacion
                                                      .erroresInstancia
                                                      .mostrarErrorNombreVacioRegistro(
                                                          context);
                                                }
                                              },
                                              child: Text("Siguiente"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    PageViewModel(
                                      decoration: PageDecoration(
                                          pageColor: Colors.deepPurple),
                                      titleWidget: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 100, bottom: 50),
                                        child: Text("¿Cúando naciste?",
                                            style: GoogleFonts.lato(
                                                color: Colors.white,
                                                fontSize: 120.sp)),
                                      ),
                                      bodyWidget: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                    
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                              ),
                                              child: Consumer<Usuario>(
                                                builder: (BuildContext context,
                                                    usuario, Widget child) {
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Flexible(
                                                        flex: 7,
                                                        fit: FlexFit.tight,
                                                        child: BotonNacimiento(
                                                            usuario
                                                                .fechaNacimiento),
                                                      ),
                                                      Flexible(
                                                          flex: 4,
                                                          fit: FlexFit.tight,
                                                          child: MostradorEdad(
                                                              usuario.edad))
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                            Divider(height: 30.h,),
                                               Usuario.esteUsuario.edad!=null&& Usuario.esteUsuario.edad<18?    Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(10)),
                                                  color: Colors.redAccent),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Flexible(
                                                        flex: 3,
                                                        fit: FlexFit.tight,
                                                        child: Icon(Icons
                                                            .warning_amber_rounded,color: Colors.white,)),
                                                              Flexible(
                                                        flex: 9,
                                                        fit: FlexFit.tight,
                                                        child: Text("Debes tenes 18 años o mas para crearte una cuenta",style: GoogleFonts.lato(color: Colors.white),)),
                                                  ],
                                                ),
                                              ),
                                            ):Container(height: 0,width: 0,),
                                            Divider(
                                              height: 500.h,
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  RaisedButton(
                                                    color: Colors.transparent,
                                                    onPressed: () {
                                                      introKey.currentState
                                                          ?.animateScroll(0);
                                                    },
                                                    child: Text("Atras"),
                                                  ),
                                                  Usuario.esteUsuario
                                                                  .fechaNacimiento !=
                                                              null &&
                                                          Usuario.esteUsuario
                                                                  .edad !=
                                                              null &&
                                                          Usuario.esteUsuario
                                                                  .edad >=
                                                              18
                                                      ? RaisedButton(
                                                          color: Colors.green,
                                                          onPressed: () {
                                                            if (Usuario.esteUsuario
                                                                        .fechaNacimiento !=
                                                                    null &&
                                                                Usuario.esteUsuario
                                                                        .edad !=
                                                                    null &&
                                                                Usuario.esteUsuario
                                                                        .edad >=
                                                                    18) {
                                                              introKey.currentState
                                                                  ?.animateScroll(
                                                                      2);
                                                            }
                                                          },
                                                          child: Text("Siguiente"),
                                                        )
                                                      : Container(
                                                          height: 0,
                                                          width: 0,
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    PageViewModel(
                                        decoration: PageDecoration(
                                            pageColor: Colors.deepPurple),
                                        titleWidget: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 100, bottom: 50),
                                          child: Text(
                                              "Elige tu sexo y tus preferencias",
                                              style: GoogleFonts.lato(
                                                  color: Colors.white,
                                                  fontSize: 120.sp)),
                                        ),
                                        bodyWidget: Consumer<Usuario>(
                                          builder: (context, myType, child) {
                                            return Container(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(5.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                      children: <Widget>[
                                                        CampoSexo(),
                                                        CampoPreferenciaSexual(),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(
                                                    height: 300.h,
                                                  ),
                                                  Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        RaisedButton(
                                                          color: Colors.transparent,
                                                          onPressed: () {
                                                            introKey.currentState
                                                                ?.animateScroll(1);
                                                          },
                                                          child: Text("Atras"),
                                                        ),
                                                        RaisedButton(
                                                          color: Colors.green,
                                                          onPressed: () {
                                                            introKey.currentState
                                                                ?.animateScroll(3);
                                                          },
                                                          child: Text("Siguiente"),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )),
                                    PageViewModel(
                                      decoration: PageDecoration(
                                          pageColor: Colors.deepPurple),
                                      titleWidget: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text("Tus mejores fotos",
                                            style: GoogleFonts.lato(
                                                color: Colors.white,
                                                fontSize: 90.sp)),
                                      ),
                                      bodyWidget: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                              ),
                                              child: Consumer<Usuario>(
                                                builder: (BuildContext context,
                                                    usuario, Widget child) {
                                                  return DragAndDropGridView(
                                                    dragStartBehavior:
                                                        DragStartBehavior.start,
                                                    isCustomChildWhenDragging:
                                                        false,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    onReorder:
                                                        (indiceViejo, indiceNuevo) {
                                                      setState(() {
                                                        if (Usuario.esteUsuario
                                                                    .fotosPerfil[
                                                                indiceViejo] !=
                                                            null) {
                                                          File temporal = Usuario
                                                                  .esteUsuario
                                                                  .fotosPerfil[
                                                              indiceNuevo];
                                                          Usuario.esteUsuario
                                                                  .fotosPerfil[
                                                              indiceNuevo] = Usuario
                                                                  .esteUsuario
                                                                  .fotosPerfil[
                                                              indiceViejo];
                                                          Usuario.esteUsuario
                                                                      .fotosPerfil[
                                                                  indiceViejo] =
                                                              temporal;
                                                        }

                                                        pos = null;
                                                      });
                                                    },
                                                    onWillAccept:
                                                        (indiceViejo, indiceNuevo) {
                                                      setState(() {
                                                        pos = indiceNuevo;
                                                      });

                                                      if (Usuario.esteUsuario
                                                                  .fotosPerfil[
                                                              indiceNuevo] !=
                                                          null) {
                                                        return true;
                                                      } else {
                                                        return false;
                                                      }
                                                    },
                                                    controller:
                                                        PantallaEdicionPerfil
                                                            .controladorScroll,
                                                    itemCount: Usuario.esteUsuario
                                                        .fotosPerfil.length,
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisSpacing: 0,
                                                      mainAxisSpacing: 0,
                                                      crossAxisCount: 3,
                                                      childAspectRatio: 1 / 1.3,
                                                    ),
                                                    itemBuilder: (context, indice) {
                                                      return Opacity(
                                                        opacity: pos != null
                                                            ? pos == indice
                                                                ? 0.4
                                                                : 1
                                                            : 1,
                                                        child: FotosPerfilNuevas(
                                                          indice,
                                                          Usuario.esteUsuario
                                                              .fotosPerfil[indice],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                            Divider(
                                              height: 100.h,
                                            ),

                                                Usuario.esteUsuario.fotosPerfil.any((File elemento)=>elemento!=null)==false? Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(10)),
                                                  color: Colors.redAccent),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Flexible(
                                                        flex: 3,
                                                        fit: FlexFit.tight,
                                                        child: Icon(Icons
                                                            .warning_amber_rounded,color: Colors.white,)),
                                                              Flexible(
                                                        flex: 9,
                                                        fit: FlexFit.tight,
                                                        child: Text("Debes añadir almenos una imagen",style: GoogleFonts.lato(color: Colors.white),)),
                                                  ],
                                                ),
                                              ),
                                            ):Container(height: 0,width: 0,),

                                            Divider(height: 100.h,),
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(10)),
                                                  color: Colors.green[700]),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    Flexible(
                                                        flex: 3,
                                                        fit: FlexFit.tight,
                                                        child: Icon(Icons
                                                            .lightbulb_outline,color: Colors.white,)),
                                                              Flexible(
                                                        flex: 9,
                                                        fit: FlexFit.tight,
                                                        child: Text("Mantén presionada una imagen para eliminarla",style: GoogleFonts.lato(color: Colors.white),)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                               Divider(height: 100.h,),
                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  RaisedButton(
                                                    color: Colors.transparent,
                                                    onPressed: () {
                                                      introKey.currentState
                                                          ?.animateScroll(2);
                                                    },
                                                    child: Text("Atras"),
                                                  ),
                                                 Usuario.esteUsuario.fotosPerfil.any((File elemento)=>elemento!=null)==true
                                                      ? RaisedButton(
                                                          color: Colors.green,
                                                          onPressed: () {
                                                             if (Usuario.esteUsuario
                                                          .fotosPerfil.isNotEmpty)  {
                                                              introKey.currentState
                                                                  ?.animateScroll(
                                                                      4);
                                                            }
                                                          },
                                                          child: Text("Siguiente"),
                                                        )
                                                      : Container(
                                                          height: 0,
                                                          width: 0,
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    PageViewModel(
                                        decoration: PageDecoration(
                                            titlePadding: EdgeInsets.all(8),
                                            pageColor: Colors.deepPurple),
                                        titleWidget: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          child: Text("Cuenta mas sobre ti",
                                              style: GoogleFonts.lato(
                                                  color: Colors.white,
                                                  fontSize: 90.sp)),
                                        ),
                                        bodyWidget: Consumer<Usuario>(
                                          builder: (context, myType, child) {
                                            return Container(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: ScreenUtil()
                                                            .setWidth(30),
                                                        right: ScreenUtil()
                                                            .setWidth(30)),
                                                    child: Container(
                                                      height: 1200.h,
                                                      child: Consumer<Usuario>(
                                                          builder: (context,
                                                              usuario, child) {
                                                        return ListaCaracteristicasEditar();
                                                      }),
                                                    ),
                                                  ),
                                                  Divider(
                                                    height: 50.h,
                                                  ),
                                                  Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        RaisedButton(
                                                          color: Colors.transparent,
                                                          onPressed: () {
                                                            introKey.currentState
                                                                ?.animateScroll(3);
                                                          },
                                                          child: Text("Atras"),
                                                        ),
                                                        RaisedButton(
                                                          color: Colors.green,
                                                          onPressed: () {
                                                            introKey.currentState
                                                                ?.animateScroll(5);
                                                          },
                                                          child: Text("Siguiente"),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )),
                                    PageViewModel(
                                        decoration: PageDecoration(
                                            titlePadding: EdgeInsets.all(8),
                                            pageColor: Colors.deepPurple),
                                        titleWidget: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          child: Text("Sobre tí",
                                              style: GoogleFonts.lato(
                                                  color: Colors.white,
                                                  fontSize: 90.sp)),
                                        ),
                                        bodyWidget: Consumer<Usuario>(
                                          builder: (context, myType, child) {
                                            return Container(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Divider(
                                                    height: 200.h,
                                                  ),
                                                  CreadorDescripcion(),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      RaisedButton(
                                                        color: Colors.transparent,
                                                        onPressed: () {
                                                          introKey.currentState
                                                              ?.animateScroll(4);
                                                        },
                                                        child: Text("Atras"),
                                                      ),
                                                                       RaisedButton(
                                                    color: Colors.green,
                                                    onPressed: () {
                                                      introKey.currentState
                                                          ?.animateScroll(6);
                                                    },
                                                    child: Text("Siguiente"),
                                                  )
                                                    ],
                                                  ),
                                 
                                                ],
                                              ),
                                            );
                                          },
                                        )),
                                    PageViewModel(
                                        decoration: PageDecoration(
                                            titlePadding: EdgeInsets.all(8),
                                            pageColor: Colors.deepPurple),
                                        titleWidget: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 50, bottom: 10),
                                          child: Text("Permisos",
                                              style: GoogleFonts.lato(
                                                  color: Colors.white,
                                                  fontSize: 90.sp)),
                                        ),
                                        bodyWidget: Consumer<Usuario>(
                                          builder: (context, myType, child) {
                                            return Container(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  permisoDenegado
                                                      ? dialogoCuandoUsuarioNiegaUbicacion()
                                                      : Container(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Permiso de ubicacion",
                                                        style: GoogleFonts.lemon(
                                                            fontSize: 55.sp,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold),
                                                      ),
                                                      Icon(
                                                          LineAwesomeIcons
                                                              .alternate_map_marker,
                                                          size: 70.sp,
                                                          color: Colors.white),
                                                    ],
                                                  ),
                                                  Divider(
                                                    height: 100.h,
                                                  ),
                                                  Text(
                                                    "Hotty se basa en tu ubicacion para mostrarte los perfiles mas cercanos a ti, por eso la aplpicacion necesita tu permiso para acceder a los servicios de ubicacion de tu dispositivo.Tu ubicacion solo se usará mientras estés usando la aplicación",
                                                    style: GoogleFonts.lato(
                                                        fontSize: 50.sp,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  Divider(
                                                    height: 200.h,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                    
                                                      await ControladorPermisos
                                                          .instancia
                                                          .comprobarPermisoUbicacion()
                                                          .then((value) {
                                                        if (value ==
                                                            EstadosPermisos
                                                                .permisoDenegado) {
                                                          setState(() {
                                                            permisoDenegado = true;
                                                          });
                                                        }
                                                        if (value ==
                                                            EstadosPermisos
                                                                .permisoDenegadoPermanente) {
                                                          setState(() {
                                                            permisoDenegado = true;
                                                          });
                                                        }
                                                        if (value ==
                                                            EstadosPermisos
                                                                .permisoConcedido) {
                                                          setState(() {
                                                            permisoDenegado = false;
                                                            Usuario.esteUsuario.submit(context);
                                                          });
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 500.w,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      20)),
                                                          color: Colors
                                                              .greenAccent[700]),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8.0),
                                                        child: Center(
                                                            child: Text(
                                                                "Dar permiso")),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        )),
                                  ],
                                ),
                              );
                            },
                          )),
                    ),
                 
              Usuario.esteUsuario.estadoProcesoCreacionCuenta==EstadoCreacionCuenta.creando?   Material(
                color: Color.fromRGBO(20, 20, 20, 100),
                   child: SafeArea(child: Container(
                      color: Color.fromRGBO(20, 20, 20, 100),
                     height: ScreenUtil.defaultHeight.toDouble(),
                     child: Center(child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                     CircularProgressIndicator(),
                     Text("Creando cuenta",style:GoogleFonts.lato(color: Colors.white))],),),),),
                 ):Container(height: 0,width: 0,)
                  ],
                ),
              );
            },
          )),
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
                    onTap: () async {
                      print("dddd");
                      await ControladorPermisos.instancia
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
                            Usuario.esteUsuario.submit(context);
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
