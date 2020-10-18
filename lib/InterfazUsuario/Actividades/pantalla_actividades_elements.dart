import 'dart:io';

import 'dart:ui';

import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: <Widget>[
          Flexible(
              flex: 15,
              fit: FlexFit.tight,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints box) {
                  PerfilesGenteCitas.limitesPrimeraFoto = box;
                  PerfilesGenteCitas.limitesParaCreador = box;
                  ImagenesCarrete.limitesCuadro=box;
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
                                .listaPerfiles[
                                    PerfilesGenteCitas.indicePerfil + 1]
                                .valoracion;
                            Perfiles.perfilesCitas.notifyListeners();
                          }
                          print(
                              "${PerfilesGenteCitas.indicePerfil} la lista esta aqui");
                          widget.cambiarIndice = false;
                        },
                        controller: controladorSwipe,

                        itemCount: Perfiles.perfilesCitas.listaPerfiles.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int indice) {
                          return Stack(alignment: Alignment.center, children: [
                            RepaintBoundary(
                              child: Container(
                                height: box.biggest.height,
                                width: box.biggest.width,
                                color: Colors.white,
                                child: Stack(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left:3.0,right: 3),
                                      child: ListView(
                                        children: Perfiles.perfilesCitas
                                            .listaPerfiles[indice].carrete,
                                      ),
                                    ),
                                    leGusta
                                        ? pantallaGusta(box, indice)
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                                height: box.biggest.height,
                                width: box.biggest.width,
                                child: Perfiles
                                            .perfilesCitas
                                            .listaPerfiles[indice]
                                            .linksHistorias
                                            .length >
                                        0
                                    ? Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              BotonHistoriasPerfiles(
                                                  rutaHistorias: MaterialPageRoute(
                                                      builder: (context) =>
                                                          HistoriasPerfiles(
                                                              linksHistorias: Perfiles
                                                                  .perfilesCitas
                                                                  .listaPerfiles[
                                                                      indice]
                                                                  .linksHistorias))),
                                              Text("Historias")
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container()),
                          ]);
                        },
                      ),
                    ),
                  );
                },
              )),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
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
                        child: TweenAnimationBuilder(
                            tween: Tween<double>(
                              begin: Perfiles
                                          .perfilesCitas
                                          .listaPerfiles[
                                              PerfilesGenteCitas.indicePerfil]
                                          .valoracion <
                                      5
                                  ? ScreenUtil().setSp(90)
                                  : ScreenUtil().setSp(170),
                              end: Perfiles
                                          .perfilesCitas
                                          .listaPerfiles[
                                              PerfilesGenteCitas.indicePerfil]
                                          .valoracion <
                                      5
                                  ? ScreenUtil().setSp(170)
                                  : ScreenUtil().setSp(90),
                            ),
                            duration: Duration(milliseconds: 200),
                            builder: (BuildContext context, double valor,
                                Widget child) {
                              return Icon(
                                Icons.cancel,
                                size: valor,
                                color: Colors.red,
                              );
                            }),
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
                        child: TweenAnimationBuilder(
                            tween: Tween<double>(
                              begin: Perfiles
                                          .perfilesCitas
                                          .listaPerfiles[
                                              PerfilesGenteCitas.indicePerfil]
                                          .valoracion >
                                      5
                                  ? ScreenUtil().setSp(90)
                                  : ScreenUtil().setSp(170),
                              end: Perfiles
                                          .perfilesCitas
                                          .listaPerfiles[
                                              PerfilesGenteCitas.indicePerfil]
                                          .valoracion >
                                      5
                                  ? ScreenUtil().setSp(170)
                                  : ScreenUtil().setSp(90),
                            ),
                            duration: Duration(milliseconds: 200),
                            builder: (BuildContext context, double valor,
                                Widget child) {
                              return Icon(
                                LineAwesomeIcons.heart_1,
                                size: valor,
                                color: Colors.green,
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
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
              activeTrackColor: Colors.blueAccent,
              disabledActiveTrackColor: Colors.pink,
              disabledInactiveTrackColor: Colors.red,
              disabledThumbColor: Colors.blue,
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

// ignore: must_be_immutable
class BotonHistoriasPerfiles extends StatefulWidget {
  MaterialPageRoute rutaHistorias;
  BotonHistoriasPerfiles({@required this.rutaHistorias});
  @override
  _BotonHistoriasPerfilesState createState() => _BotonHistoriasPerfilesState();
}

class _BotonHistoriasPerfilesState extends State<BotonHistoriasPerfiles>
    with SingleTickerProviderStateMixin {
  AnimationController _animacionMicrofono;
  Animation animacion;

  int duracionAudio;
  void initState() {
    _animacionMicrofono =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animacionMicrofono.repeat(reverse: true);
    animacion =
        Tween<double>(begin: 5.0, end: 40.0).animate(_animacionMicrofono)
          ..addListener(() {
            setState(() {});
          });
    super.initState();
  }

  void dispose() {
    if (_animacionMicrofono.status == AnimationStatus.forward ||
        _animacionMicrofono.status == AnimationStatus.reverse) {
      _animacionMicrofono.notifyStatusListeners(AnimationStatus.dismissed);
    }
    _animacionMicrofono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RepaintBoundary(
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue,
                        spreadRadius: ScreenUtil().setSp(animacion.value),
                        blurRadius: ScreenUtil().setSp(animacion.value))
                  ]),
              child: TweenAnimationBuilder(
                  tween: Tween<double>(
                      begin: ScreenUtil().setSp(0),
                      end: ScreenUtil().setSp(250)),
                  duration: Duration(milliseconds: 250),
                  builder: (BuildContext context, double valor, Widget child) {
                    return IconButton(
                      icon: Icon(
                        LineAwesomeIcons.film,
                      ),
                      color: Colors.white,
                      onPressed: () =>
                          Navigator.push(context, widget.rutaHistorias),
                    );
                  }),
            ),
          )
        ]);
  }
}

class PerfilesGenteAmistad extends StatefulWidget {
  List<List<Widget>> perfiles = new List();
  static int posicion;
  static double valor;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PerfilesGenteAmistadState();
  }
}

class PerfilesGenteAmistadState extends State<PerfilesGenteAmistad> {
  ItemScrollController mover = new ItemScrollController();

  double valorSlider = 5;

  void soltarBotonLike(DatosPerfiles datos) {
    Valoraciones.Puntuaciones.escucharValoraciones();
    datos.crearDatosValoracion();
    // mover.next(animation: true);

    print("Fuera");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScrollablePositionedList.builder(
      itemCount: Perfiles.perfilesAmistad.listaPerfiles.length,
      physics: NeverScrollableScrollPhysics(),
      itemScrollController: mover,
      reverse: false,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int indice) {
        print(indice);
        void noLike(DatosPerfiles datos) {
          if (Perfiles.perfilesAmistad.listaPerfiles.length > indice + 1) {
            print(indice);

            mover.scrollTo(
                index: indice + 1,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic);
          }
        }

        return Stack(alignment: Alignment.bottomCenter, children: [
          Container(
            height: ScreenUtil().setHeight(2900),
            width: ScreenUtil().setWidth(1400),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: ListView(
              children: Perfiles.perfilesAmistad.listaPerfiles[indice].carrete,
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                  color: Colors.red,
                  child: Perfiles.perfilesAmistad.listaPerfiles[indice]
                              .linksHistorias.length >
                          0
                      ? FlatButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HistoriasPerfiles(
                                        linksHistorias: Perfiles
                                            .perfilesAmistad
                                            .listaPerfiles[indice]
                                            .linksHistorias)));
                          },
                          child: Container(
                            child: Text("data"),
                          ))
                      : Container()),
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(1300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: ScreenUtil().setHeight(250),
                  width: ScreenUtil().setWidth(200),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(255, 78, 132, 100),
                  ),
                  child: FlatButton(
                    padding: EdgeInsets.all(8),
                    onPressed: () {
                      noLike(Perfiles.perfilesAmistad.listaPerfiles[indice]);
                      Perfiles.perfilesAmistad.notifyListeners();
                    },
                    child: Icon(
                      LineAwesomeIcons.times_circle_1,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  height: ScreenUtil().setHeight(250),
                  width: ScreenUtil().setWidth(200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(255, 78, 132, 100),
                  ),
                  child: FlatButton(
                    padding: EdgeInsets.all(8),
                    onPressed: () => {},
                    child: Icon(
                      LineAwesomeIcons.star,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]);
      },
    );
  }
}

class FotoHistoria extends StatefulWidget {
  int box;
  File Imagen;
  bool imagenRed = false;
  FirebaseFirestore baseDatosRef = FirebaseFirestore.instance;

  static List<Map<String, dynamic>> linksImagenesHistorias =
      Usuario.esteUsuario.listaDeHistoriasRed;

  FotoHistoria(this.box, this.Imagen);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FotoHistoriaState(this.box, this.Imagen);
  }
}

class FotoHistoriaState extends State<FotoHistoria> {
  @override
  File Image_picture;
  File imagen;
  File imagenFinal;
  static Map<String, Map> datosActualizados = new Map();
  static Map<String, dynamic> mapaHistorias = new Map();
  FirebaseStorage storage = FirebaseStorage.instance;
  static List<File> pictures = List(6);
  int box;
  FotoHistoriaState(this.box, this.imagen) {}

  int calculadoraIndice() {
    return this.box + 12;
  }

  void opcionesImagenPerfil() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Añadir Imagen"),
            content: Text("¿Seleccione la fuente de la imagen?"),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        abrirGaleria(context);
                      },
                      child: Row(
                        children: <Widget>[Text("Galeria"), Icon(Icons.image)],
                      )),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        abrirCamara(context);
                      },
                      child: Row(
                        children: <Widget>[
                          Text("Camara"),
                          Icon(Icons.camera_enhance)
                        ],
                      )),
                ],
              )
            ],
          );
        });
  }

  void pieFoto(BuildContext context, File imagen, int indice) {
    showGeneralDialog(
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 200),
        context: CreadorDeHistorias.clave.currentContext,
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondanimation) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: ScreenUtil().setHeight(1800),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color.fromRGBO(20, 20, 20, 50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: ScreenUtil().setHeight(800),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: Image.file(imagen),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          child: Text("Comentarios Foto",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(60))),
                        ),
                      ),
                      Divider(
                        height: ScreenUtil().setHeight(50),
                      ),
                      Material(
                          color: Color.fromRGBO(0, 0, 0, 100),
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white,
                                    width: ScreenUtil().setWidth(6)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                                color: Colors.white30,
                              ),
                              child: EntradaTexto(
                                  Icon(LineAwesomeIcons.comment),
                                  "Pie de Foto",
                                  indice,
                                  false,
                                  200,
                                  2,
                                  200))),
                      Divider(
                        height: ScreenUtil().setHeight(50),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.green),
                        child: FlatButton(
                          child: Text("Hecho"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  abrirGaleria(BuildContext context) async {
    var archivoImagen =
        await ImagePicker().getImage(source: ImageSource.gallery);
    File imagenRecortada = await ImageCropper.cropImage(
        sourcePath: archivoImagen.path,
        maxHeight: 1280,
        maxWidth: 720,
        aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 3),
        compressQuality: 90,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (imagenRecortada != null) {
      this.setState(() {
        imagenFinal = imagenRecortada;
        pictures[box] = imagenFinal;
        Usuario.esteUsuario.fotosHistorias = pictures;
    
        print("${imagenRecortada.lengthSync()} Tamaño Recortado");
        print(box);
        Usuario.esteUsuario.notifyListeners();
        pieFoto(context, imagenFinal, calculadoraIndice());
      });
    }
  }

  abrirCamara(BuildContext context) async {
    var archivoImagen =
        await ImagePicker().getImage(source: ImageSource.camera);
    File imagenRecortada = await ImageCropper.cropImage(
        sourcePath: archivoImagen.path,

        // aspectRatio: CropAspectRatio(ratioX: 9,ratioY: 16),
        maxHeight: 1000,
        maxWidth: 720,
        compressQuality: 90,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    if (imagenRecortada != null) {
      this.setState(() {
        imagenFinal = imagenRecortada;
        pictures[box] = imagenFinal;
        Usuario.esteUsuario.fotosHistorias = pictures;

        Usuario.esteUsuario.notifyListeners();
        pieFoto(context, imagenFinal, calculadoraIndice());
      });
    }
  }

  eliminarImagen(BuildContext context) {
    this.setState(() {
      Usuario.esteUsuario.fotosHistorias[box] = null;
      imagenFinal = null;
      widget.imagenRed = false;

      // ignore: unnecessary_statements
      FotoHistoria.linksImagenesHistorias[box] = null;

      if (box == 0) {
        print("object");
        if (FotoHistoria.linksImagenesHistorias[box] == null) {
          datosActualizados = FotoHistoria.linksImagenesHistorias[box];

          Usuario.esteUsuario.notifyListeners();
          widget.baseDatosRef
              .collection("usuarios")
              .document(Usuario.esteUsuario.idUsuario)
              .collection("historias")
              .document("Historia1")
              .delete();

          StorageReference reference = storage.ref();

          String Image1 =
              "${Usuario.esteUsuario.idUsuario}/Perfil//Historias/Image${box + 1}.jpg";
          StorageReference imagesReference = reference.child(Image1);
          //  widget.esteEvento.fotosEventoEditar.removeAt(box);
          imagesReference.delete().catchError((error) {
            print(error);
          });
        }
      }
      if (box == 1) {
        if (FotoHistoria.linksImagenesHistorias[box] == null) {
          datosActualizados = null;

          Usuario.esteUsuario.notifyListeners();
          widget.baseDatosRef
              .collection("usuarios")
              .document(Usuario.esteUsuario.idUsuario)
              .collection("historias")
              .document("Historia2")
              .delete();

          StorageReference reference = storage.ref();

          String Image1 =
              "${Usuario.esteUsuario.idUsuario}/Perfil//Historias/Image${box + 1}.jpg";
          StorageReference imagesReference = reference.child(Image1);
          //  widget.esteEvento.fotosEventoEditar.removeAt(box);
          imagesReference.delete().catchError((error) {
            print(error);
          });
        }
      }
      if (box == 2) {
        if (FotoHistoria.linksImagenesHistorias[box] == null) {
          datosActualizados = FotoHistoria.linksImagenesHistorias[box];

          Usuario.esteUsuario.notifyListeners();
          widget.baseDatosRef
              .collection("usuarios")
              .document(Usuario.esteUsuario.idUsuario)
              .collection("historias")
              .document("Historia3")
              .delete();

          StorageReference reference = storage.ref();

          String Image1 =
              "${Usuario.esteUsuario.idUsuario}/Perfil//Historias/Image${box + 1}.jpg";
          StorageReference imagesReference = reference.child(Image1);
          //  widget.esteEvento.fotosEventoEditar.removeAt(box);
          imagesReference.delete().catchError((error) {
            print(error);
          });
        }
      }
      if (box == 3) {
        if (FotoHistoria.linksImagenesHistorias[box] == null) {
          datosActualizados = FotoHistoria.linksImagenesHistorias[box];

          Usuario.esteUsuario.notifyListeners();
          widget.baseDatosRef
              .collection("usuarios")
              .document(Usuario.esteUsuario.idUsuario)
              .collection("historias")
              .document("Historia4")
              .delete();

          StorageReference reference = storage.ref();

          String Image1 =
              "${Usuario.esteUsuario.idUsuario}/Perfil//Historias/Image${box + 1}.jpg";
          StorageReference imagesReference = reference.child(Image1);
          //  widget.esteEvento.fotosEventoEditar.removeAt(box);
          imagesReference.delete().catchError((error) {
            print(error);
          });
        }
      }
      if (box == 4) {
        if (FotoHistoria.linksImagenesHistorias[box] == null) {
          datosActualizados = FotoHistoria.linksImagenesHistorias[box];

          Usuario.esteUsuario.notifyListeners();
          widget.baseDatosRef
              .collection("usuarios")
              .document(Usuario.esteUsuario.idUsuario)
              .collection("historias")
              .document("Historia5")
              .delete();

          StorageReference reference = storage.ref();

          String Image1 =
              "${Usuario.esteUsuario.idUsuario}/Perfil//Historias/Image${box + 1}.jpg";
          StorageReference imagesReference = reference.child(Image1);
          //  widget.esteEvento.fotosEventoEditar.removeAt(box);
          imagesReference.delete().catchError((error) {
            print(error);
          });
        }
      }
      if (box == 5) {
        if (FotoHistoria.linksImagenesHistorias[box] == null) {
          datosActualizados = FotoHistoria.linksImagenesHistorias[box];

          Usuario.esteUsuario.notifyListeners();
          widget.baseDatosRef
              .collection("usuarios")
              .document(Usuario.esteUsuario.idUsuario)
              .collection("historias")
              .document("Historia6")
              .delete();

          StorageReference reference = storage.ref();

          String Image1 =
              "${Usuario.esteUsuario.idUsuario}/Perfil//Historias/Image${box + 1}.jpg";
          StorageReference imagesReference = reference.child(Image1);
          //  widget.esteEvento.fotosEventoEditar.removeAt(box);
          imagesReference.delete().catchError((error) {
            print(error);
          });
        }
      }
    });
  }

  Future<void> subirHistorioasUsuario(String IDUsuario) async {
    //  assert(imagenes != null);
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference reference = storage.ref();
    if (Usuario.esteUsuario.fotosHistorias[0] != null) {
      String image1 = "${IDUsuario}/Perfil/Historias/Image1.jpg";
      StorageReference referenciaImagenes = reference.child(image1);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(Usuario.esteUsuario.fotosHistorias[0]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      Usuario.esteUsuario.historia1["Imagen"] = URL;
      print(URL);
    }
    if (Usuario.esteUsuario.fotosHistorias[1] != null) {
      String Image2 = "${IDUsuario}/Perfil/Historias/Image2.jpg";
      StorageReference referenciaImagenes = reference.child(Image2);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(Usuario.esteUsuario.fotosHistorias[1]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      Usuario.esteUsuario.historia2["Imagen"] = URL;
      print(URL);
    }
    if (Usuario.esteUsuario.fotosHistorias[2] != null) {
      String Image3 = "${IDUsuario}/Perfil/Historias/Image3.jpg";
      StorageReference referenciaImagenes = reference.child(Image3);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(Usuario.esteUsuario.fotosHistorias[2]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      Usuario.esteUsuario.historia3["Imagen"] = URL;
      print(URL);
    }
    if (Usuario.esteUsuario.fotosHistorias[3] != null) {
      String Image4 = "${IDUsuario}/Perfil/Historias/Image4.jpg";
      StorageReference referenciaImagenes = reference.child(Image4);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(Usuario.esteUsuario.fotosHistorias[3]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      Usuario.esteUsuario.historia4["Imagen"] = URL;
      print(URL);
    }
    if (Usuario.esteUsuario.fotosHistorias[4] != null) {
      String Image5 = "${IDUsuario}/Perfil/Historias/Image5.jpg";
      StorageReference referenciaImagenes = reference.child(Image5);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(Usuario.esteUsuario.fotosHistorias[4]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      Usuario.esteUsuario.historia5["Imagen"] = URL;
      print(URL);
    }
    if (Usuario.esteUsuario.fotosHistorias[5] != null) {
      String Image6 = "${IDUsuario}/Perfil/Historias/Image6.jpg";
      StorageReference referenciaImagenes = reference.child(Image6);
      StorageUploadTask uploadTask =
          referenciaImagenes.putFile(Usuario.esteUsuario.fotosHistorias[5]);

      var URL = await (await uploadTask.onComplete).ref.getDownloadURL();
      Usuario.esteUsuario.historia6["Imagen"] = URL;
      print(URL);
    }
    Usuario.esteUsuario.establecerHistorias();

    Usuario.esteUsuario.databaseReference
        .collection("usuarios")
        .doc(IDUsuario)
        .collection("historias")
        .doc("DocumentoHistorias")
        .set(Usuario.esteUsuario.imagenesHistorias);
  }

  Widget build(BuildContext context) {
    
    if (FotoHistoria.linksImagenesHistorias[box] == null) {
      widget.imagenRed = false;
    } else {
      widget.imagenRed = true;
    }

    // TODO: implement build
    return widget.imagenRed==true?historiaImagenRed():Usuario.esteUsuario.fotosHistorias[box]!=null?historiaImagenLocaal():historiaVacia();
  }

  Container historiaImagenRed() {
    return Container(
       height: 700.h,
        width: 350.w,
      child: Stack(
    fit: StackFit.expand,

children: [
   Container(
        height: 700.h,
        width: 350.w,

        decoration: BoxDecoration(
         color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(3)
          
          ),
          
          image: DecorationImage(image: NetworkImage(FotoHistoria.linksImagenesHistorias[box]["Imagen"]))
          )
          


  ),
  Align(
      alignment:Alignment.topLeft,
      child:IconButton(iconSize:90.sp,   color: Colors.red,icon: Icon(Icons.delete),onPressed: (){
        eliminarImagen(context);

      },)
  )

],

           
      ),
    );
  }
  Widget historiaImagenLocaal() {
    return Container(
       height: 700.h,
        width: 350.w,
      child: Stack(
    fit: StackFit.expand,

children: [
   Container(
        height: 700.h,
        width: 350.w,

        decoration: BoxDecoration(
         color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(3)
          
          ),
          
          image: DecorationImage(image: FileImage(Usuario.esteUsuario.fotosHistorias[box]))
          )
          


  ),
  Align(
      alignment:Alignment.topLeft,
      child:IconButton(iconSize:90.sp,   color: Colors.red,icon: Icon(Icons.delete),onPressed: (){
        eliminarImagen(context);

      },)
  )

],

           
      ),
    );
  }

  GestureDetector historiaVacia() {
    return GestureDetector(
      onTap: (){
     
      },
  
          child: Container(
      height: 700.h,
      width: 350.w,

      decoration: BoxDecoration(
       color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(3)
        
        ),
        
       
        ),
        child: Center(
child:Icon(LineAwesomeIcons.camera,color: Colors.white,)
        ),
        


  ),
    );
  }
}


