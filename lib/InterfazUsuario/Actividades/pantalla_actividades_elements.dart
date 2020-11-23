import 'dart:io';

import 'dart:ui';

import 'package:citasnuevo/DatosAplicacion/ControladorLikes.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import "package:citasnuevo/Inte../../DatosAplicacion/ControladorConversacion.dart";
import 'package:citasnuevo/InterfazUsuario/Actividades/TarjetaPerfiles.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/people_screen.dart';
import 'package:citasnuevo/InterfazUsuario/Directo/live_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen_elements.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:image_picker/image_picker.dart';

import 'package:image_cropper/image_cropper.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:swipe_stack/swipe_stack.dart';

import 'Pantalla_Actividades.dart';

// ignore: must_be_immutable
class PerfilesGenteCitas extends StatefulWidget {
  List<List<Widget>> perfiles = new List();
  static int posicion;

  BoxConstraints limites;
  static double valor;
  static BoxConstraints limitesPrimeraFoto;
  static BoxConstraints limitesParaCreador;
  static int indicePerfil = 0;
  static double valorPerfilPasado = 0;
  static double valorPerfilPresente = 0;
  bool cambiarIndice = false;
  PerfilesGenteCitas({@required this.limites}) {
    if (this.limites.biggest.height != null &&
        this.limites.biggest.width != null) {
      limitesPrimeraFoto = this.limites;
    }
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PerfilesGenteCitasState();
  }
}

class ControlarLista {
  Function noTeGusta;
  Function teGusta;
  static ControlarLista controladorLista = ControlarLista();

  ControlarLista.instancia({@required this.noTeGusta, @required this.teGusta});
  ControlarLista();
}

class PerfilesGenteCitasState extends State<PerfilesGenteCitas> {
  static ItemScrollController mover = new ItemScrollController();
  static SwiperController controladorSwipe = new SwiperController();
  

  @override
  void initState(){
PerfilesGenteCitas.indicePerfil=0;
    super.initState();

  }

  Function soltarLikes;
  int devolverIndices = 0;
  bool leGusta = false;
  double valorSlider = 5;
  int obtenerIndice(String datos) {
    print("buscando indice");
    bool datosCoinciden = false;
    for (int i = 0; i < Perfiles.perfilesCitas.listaPerfiles.length; i++) {
      if (datos == Perfiles.perfilesCitas.listaPerfiles[i].idUsuario &&
          widget.cambiarIndice) {
        datosCoinciden = true;
        widget.cambiarIndice = false;
        return i;
      }
      if ((!datosCoinciden) &&
          (i == Perfiles.perfilesCitas.listaPerfiles.length - 1)) {
        widget.cambiarIndice = false;
        return -1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: widget.limites.biggest.height,
      width: widget.limites.biggest.width,
      decoration: BoxDecoration(),
      child: Stack(
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              PerfilesGenteCitas.limitesPrimeraFoto = box;
              PerfilesGenteCitas.limitesParaCreador = box;
              ImagenesCarrete.limitesCuadro = box;
              return Container(
                height: box.biggest.height,
                width: box.biggest.width,
                child: GestureDetector(
                  onHorizontalDragStart: (valor) {},
                  onHorizontalDragUpdate: (valor) {},
                  onHorizontalDragCancel: () {},
                  onHorizontalDragDown: (valor) {},
                  onHorizontalDragEnd: (valor) {},
                  onLongPress: () {},
                  child: Swiper(
                    loop: false,
                    physics: NeverScrollableScrollPhysics(),
                    layout: SwiperLayout.STACK,
                    itemWidth: box.biggest.width,
                    curve: Curves.easeInOut,
                    
                    onIndexChanged: (index) {
                      PerfilesGenteCitas.indicePerfil = index;
                      if (Perfiles.perfilesCitas.listaPerfiles.length >
                          PerfilesGenteCitas.indicePerfil + 1) {
                        PerfilesGenteCitas.valorPerfilPasado = Perfiles
                            .perfilesCitas
                            .listaPerfiles[PerfilesGenteCitas.indicePerfil]
                            .valoracion;
                        PerfilesGenteCitas.valorPerfilPresente = Perfiles
                            .perfilesCitas
                            .listaPerfiles[PerfilesGenteCitas.indicePerfil + 1]
                            .valoracion;
                        Perfiles.perfilesCitas.notifyListeners();
                      
                      }
                        setState(() {
                          
                        });

                      widget.cambiarIndice = false;
                    },
                    controller: controladorSwipe,
                    itemCount: Perfiles.perfilesCitas.listaPerfiles.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int indice) {
                      return RepaintBoundary(
                        child: Container(
                          height: box.biggest.height,
                          width: box.biggest.width,
                          color: Colors.white,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Stack(
                                children: [
                                  ListView(
                                    children: Perfiles.perfilesCitas
                                        .listaPerfiles[indice].carrete,
                                  ),
                                ],
                              ),
                              leGusta
                                  ? pantallaGusta(box, indice)
                                  : Container(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          
          botonesLateralesCitas(context),
          deslizadorCompuesto()
        ],
      ),
    );
  }

  Align botonesLateralesCitas(BuildContext context) {
    return Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 200.h,
                                width: 150.w,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(36, 28, 41, 100),
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                   
                              ),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListaDeValoraciones())),
                        child: Column(
                             mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              LineAwesomeIcons.heart_1,
                              color: Colors.white,
                              size: 80.sp,
                            ),
                            Container(
                                height: 80.w,
                    
                                decoration: BoxDecoration(
                                     borderRadius: BorderRadius.all(Radius.circular(10)),
                                   color: Color.fromRGBO(41, 2, 61, 100),),
                                child: Center(
                                    child: Text(
                                  "${Valoracion.listaDeValoraciones.length}",
                                  style: GoogleFonts.lato(
                                      fontSize: 35.sp, color: Colors.white,fontWeight: FontWeight.bold),
                                )),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 50.h,
                    ),
                Container(
                      height: 200.h,
                                width: 150.w,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(36, 28, 41, 100),
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                   
                              ),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PantallaSolicitudesConversaciones())),
                        child: Column(
                             mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              LineAwesomeIcons.user_friends,
                              color: Colors.white,
                              size: 80.sp,
                            ),
                            Container(
                                height: 80.w,
                    
                                decoration: BoxDecoration(
                                     borderRadius: BorderRadius.all(Radius.circular(10)),
                                    color: Color.fromRGBO(41, 2, 61, 100),),
                                child: Center(
                                    child: Text(
                                  "${Solicitudes.instancia.listaSolicitudesConversacion.length}",
                                  style: GoogleFonts.lato(
                                      fontSize: 35.sp, color: Colors.white,fontWeight: FontWeight.bold),
                                )),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        );
  }

  Widget deslizadorCompuesto() {
    return Padding(
      padding: const EdgeInsets.only(
          bottom: kBottomNavigationBarHeight, left: 20, right: 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Color.fromRGBO(36, 28, 41, 99)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                              "${Perfiles.perfilesCitas.listaPerfiles[PerfilesGenteCitas.indicePerfil].nombreusuaio}, ${Perfiles.perfilesCitas.listaPerfiles[PerfilesGenteCitas.indicePerfil].edad} ",
                              style: GoogleFonts.lato(
                                fontSize: 45.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                        ),
                        Row(
                          children: [
                            Icon(
                              LineAwesomeIcons.alternate_map_marker,
                              color: Colors.white,
                              size: 50.sp,
                            ),
                            Text(
                              "${Perfiles.perfilesCitas.listaPerfiles[PerfilesGenteCitas.indicePerfil].distancia} Km",
                              style: GoogleFonts.lato(
                                  fontSize: 45.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          ],
                        )
                      ]),
                ),
              ),
            ),
            Container(
              height: kBottomNavigationBarHeight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RepaintBoundary(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: Container(
                          width: 150.w,
                          height: 150.w,
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(36, 28, 41, 100),
                                blurRadius: 2,
                                spreadRadius: 2)
                          ], shape: BoxShape.circle, color: Colors.white),
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: 90.sp,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 10,
                        child: Container(
                          child: deslizadorPuntuacion(
                            soltarLikes,
                            PerfilesGenteCitas.indicePerfil,
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: Container(
                          width: 150.w,
                          height: 150.w,
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(36, 28, 41, 100),
                                blurRadius: 2,
                                spreadRadius: 2)
                          ], shape: BoxShape.circle, color: Colors.white),
                          child: Center(
                            child: Icon(
                              LineAwesomeIcons.heart_1,
                              size: 90.sp,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void dialogoFinPerfiles(BuildContext context) {
    bool denttroDePantalla = false;
    showGeneralDialog(
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 100),
        context: context,
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondanimation) {
          denttroDePantalla = true;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: ScreenUtil().setHeight(1000),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color.fromRGBO(20, 20, 20, 50),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Text("Upps... Parece que no queda nadie",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(70))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.transparent,
                            child: TweenAnimationBuilder(
                                tween: Tween<double>(
                                    begin: ScreenUtil().setSp(0),
                                    end: ScreenUtil().setSp(300)),
                                duration: Duration(milliseconds: 250),
                                builder: (BuildContext context, double valor,
                                    Widget child) {
                                  return Icon(
                                    LineAwesomeIcons
                                        .frowning_face_with_open_mouth_1,
                                    size: valor,
                                    color: Colors.yellow,
                                  );
                                }),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(30),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            child: Text(
                                "Invita a tus amigos a unirse y gana creditos cuando se registren por ayudarnos a crecer",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(40))),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(40),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.green),
                          child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Invitar amigos"),
                                Icon(LineAwesomeIcons.share),
                              ],
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(50),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  "Modifica tus filtros para ver mas perfiles",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(40))),
                            ),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(50),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.green),
                          child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Modificar Filtros"),
                                Icon(LineAwesomeIcons.edit)
                              ],
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Divider(
                          height: ScreenUtil().setHeight(30),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.transparent),
                          child: FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Cerrar",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(Icons.close, color: Colors.red)
                              ],
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  TweenAnimationBuilder<double> pantallaGusta(
      BoxConstraints limitesPantallaLeGusta, int indice) {
    return TweenAnimationBuilder(
        tween:
            Tween<double>(begin: 0, end: limitesPantallaLeGusta.biggest.height),
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInSine,
        builder: (BuildContext context, double valor, Widget child) {
          return AnimatedContainer(
            curve: Curves.linear,
            duration: Duration(milliseconds: 100),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color:
                    Perfiles.perfilesCitas.listaPerfiles[indice].valoracion >= 5
                        ? Color.fromRGBO(27, 196, 35, 100)
                        : Color.fromRGBO(255, 0, 42, 100)),
            height: valor,
            width: limitesPantallaLeGusta.biggest.width,
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: valor == limitesPantallaLeGusta.biggest.height
                    ? mensajePantallaCalificacion(
                        limitesPantallaLeGusta, indice)
                    : Container()),
          );
        });
  }

  Column mensajePantallaCalificacion(
      BoxConstraints limitesPantallaLeGusta, int indice) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Perfiles.perfilesCitas.listaPerfiles[indice].valoracion >= 5 &&
                Perfiles.perfilesCitas.listaPerfiles[indice].valoracion < 6.5
            ? Text(
                "No esta mal",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(70),
                    fontWeight: FontWeight.bold),
              )
            : Perfiles.perfilesCitas.listaPerfiles[indice].valoracion > 6.5 &&
                    Perfiles.perfilesCitas.listaPerfiles[indice].valoracion < 9
                ? Text(
                    "Me gustas",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(70),
                        fontWeight: FontWeight.bold),
                  )
                : Perfiles.perfilesCitas.listaPerfiles[indice].valoracion > 9
                    ? Text(
                        "Smash",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(70),
                            fontWeight: FontWeight.bold),
                      )
                    : Center(
                        child: Text(
                          "Pass",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(150),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
        Perfiles.perfilesCitas.listaPerfiles[indice].valoracion >= 0
            ? anilloPuntuacion(limitesPantallaLeGusta, indice)
            : Container(),
        Perfiles.perfilesCitas.listaPerfiles[indice].valoracion >= 5
            ? botonEscribirMensaje()
            : Container(),
      ],
    );
  }

  TweenAnimationBuilder<double> anilloPuntuacion(
      BoxConstraints limitesPantallaLeGusta, int indice) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 10, end: ScreenUtil().setSp(400)),
        curve: Curves.linearToEaseOut,
        duration: Duration(milliseconds: 300),
        builder: (BuildContext context, double valor, Widget child) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              child: CircularPercentIndicator(
                radius: valor,
                percent:
                    Perfiles.perfilesCitas.listaPerfiles[indice].valoracion /
                        10,
                animationDuration: 200,
                lineWidth: ScreenUtil().setHeight(50),
                linearGradient: LinearGradient(
                    colors: [Colors.pink, Colors.pinkAccent[100]]),
                center: Text(
                  "${Perfiles.perfilesCitas.listaPerfiles[indice].valoracion.toStringAsFixed(1)}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          ScreenUtil().setSp(90, allowFontScalingSelf: false),
                      color: Colors.white),
                ),
              ),
            ),
          );
        });
  }

  AnimatedContainer botonEscribirMensaje() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.linearToEaseOut,
      width: ScreenUtil().setWidth(400),
      height: ScreenUtil().setHeight(100),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white),
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.message,
            size: ScreenUtil().setSp(40),
          ),
          Text(
            "Enviar Mensaje",
            style: TextStyle(
                fontSize: ScreenUtil().setSp(40), fontWeight: FontWeight.bold),
          ),
        ],
      )),
    );
  }

  Padding deslizadorPuntuacion(
    Function soltarLike,
    int indice,
  ) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        child: SliderTheme(
          data: SliderThemeData(
              trackHeight: ScreenUtil().setHeight(90),
              activeTrackColor: Colors.transparent,
              disabledActiveTrackColor: Colors.pink,
              disabledInactiveTrackColor: Colors.red,
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
              disabledActiveTickMarkColor: Colors.transparent,
              disabledInactiveTickMarkColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              disabledThumbColor: Colors.transparent,
              valueIndicatorShape: SliderComponentShape.noOverlay,
              thumbColor: Colors.blueAccent,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 30,
              ),
              overlappingShapeStrokeColor: Colors.red,
              overlayColor: Colors.pink),
          child: Slider(
            value: Perfiles.perfilesCitas.listaPerfiles != null
                ? Perfiles.perfilesCitas
                    .listaPerfiles[PerfilesGenteCitas.indicePerfil].valoracion
                : 5,
            label: "Holita",
            onChangeStart: (val) {
              print(val);
              leGusta = true;
            },
            onChanged: (valor) {
              setState(() {
                Perfiles
                    .perfilesCitas
                    .listaPerfiles[PerfilesGenteCitas.indicePerfil]
                    .valoracion = valor;
              });
            },
            onChangeEnd: (valor) {
              Future.delayed(Duration(milliseconds: 250)).then((value) {
                controladorSwipe.next();
                if (Perfiles.perfilesCitas.listaPerfiles.length ==
                    PerfilesGenteCitas.indicePerfil + 1) {
                  dialogoFinPerfiles(context);
                  Perfiles.perfilesCitas.notifyListeners();
                  Perfiles.perfilesCitas
                      .listaPerfiles[PerfilesGenteCitas.indicePerfil]
                      .crearDatosValoracion();
                  print("calificao");
                }
                if (Perfiles.perfilesCitas.listaPerfiles.length >
                    PerfilesGenteCitas.indicePerfil + 1) {
                  Perfiles.perfilesCitas.notifyListeners();
                  Perfiles.perfilesCitas
                      .listaPerfiles[PerfilesGenteCitas.indicePerfil]
                      .crearDatosValoracion();
                  print("calificao");
                }

                leGusta = false;
              });
            },
            min: 0,
            max: 10,
          ),
        ),
      ),
    );
  }
}
