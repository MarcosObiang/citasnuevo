import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/InterfazUsuario/RegistrodeUsuario/sign_up_screen_elements.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import '../../DatosAplicacion/actividad.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'TarjetaEvento.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../ServidorFirebase/firebase_manager.dart';

class plan_screen extends StatefulWidget {
  bool masDeUnParticipante;
  plan_screen(this.masDeUnParticipante);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return plan_screen_state();
  }
}

class plan_screen_state extends State<plan_screen> {
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1440, height: 3120, allowFontScaling: true);
    return SafeArea(
      child: Material(
        child: Container(
          color: Colors.deepPurple.shade300,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: ScreenUtil().setHeight(500),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12)),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Hola Marcos",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextoPlan(
                    Icon(
                      Icons.featured_play_list,
                      color: Colors.black,
                    ),
                    "Nombre de Plan",
                    0,
                    false,
                    100,
                    1,
                    100),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextoPlan(
                    Icon(
                      Icons.featured_play_list,
                      color: Colors.black,
                    ),
                    "Ubicacion",
                    1,
                    false,
                    100,
                    1,
                    100),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: ScreenUtil().setHeight(200),
                  width: ScreenUtil().setWidth(1500),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(9))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        plan_date_shower(),
                        when_button("Select"),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: ScreenUtil().setHeight(200),
                  width: ScreenUtil().setWidth(1500),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(9))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        plan_hour_shower(),
                        hour_button("Select"),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextoPlan(
                        Icon(
                          Icons.featured_play_list,
                          color: Colors.black,
                        ),
                        "Comentarios",
                        2,
                        false,
                        300,
                        4,
                        250),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      cancel_button(),
                      next_button(widget.masDeUnParticipante),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///**************************************************************************************************************************************************************
///  PLAN TEXT FIELD : Entrada de texto
///
/// STRING NAME: Recibe una cadena de caracteres con la traduccion de SEXO adecuada al idioma traducido
///
/// STRING MALE_SEX_NAME: Recibe una cadena de caracteres con la traduccion adecuada de HOMBRE
///
/// STRING FEMALE_SEX_NAME: Recibe una cadena de caracteres con la traduccion adecuada de MUJER
///
/// *************************************************************************************************************************************************************
class TextoPlan extends StatefulWidget {
  Icon icon;
  int altura;
  String nombre_campo;
  int indice;
  bool texto_oscuro;
  int lineas;
  int caracteres;

  TextoPlan(this.icon, this.nombre_campo, this.indice, this.texto_oscuro,
      this.altura, this.lineas, this.caracteres);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TextoPlanState(
        icon, nombre_campo, indice, texto_oscuro, altura, lineas, caracteres);
  }
}

class TextoPlanState extends State<TextoPlan> {
  bool invisible = true;
  bool aux = true;
  Icon icon;
  String nombre_campo;
  int indice;
  bool texto_oscuro;
  int altura;
  int lineas;
  int caracteres;

  TextoPlanState(this.icon, this.nombre_campo, this.indice, this.texto_oscuro,
      this.altura, this.lineas, this.caracteres);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            color: Colors.white),
        child: text_black());
  }

  Widget text_black() {
    return TextField(
      maxLines: lineas,
      maxLength: caracteres,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.only(bottom: 0),
        counter: Offstage(),
        labelText: "$nombre_campo",
        labelStyle:
            TextStyle(color: Colors.grey, fontSize: ScreenUtil().setSp(60)),
        icon: icon,
      ),
      obscureText: false,
      onChanged: (String val) {
        setState(() {
          if (indice == 0) {
            Actividad.esteEvento.nombreEvento = val;
          }
          if (indice == 1) {
            Actividad.esteEvento.ubicacionEvento = val;
          }
          if (indice == 2) {
            Actividad.esteEvento.comentariosEvento = val;
          }
        });
      },
    );
  }
}

class when_button extends StatefulWidget {
  String birth;
  when_button(String birth) {
    this.birth = birth;
  }
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return when_button_state(birth);
  }
}

class when_button_state extends State<when_button> {
  String birth_text;
  DateTime date;
  static int age;
  when_button_state(String birth_text) {
    this.birth_text = birth_text;
  }
  static int GetAge() {
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setWidth(470),
          height: ScreenUtil().setHeight(120),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: RaisedButton(
              color: Colors.deepPurple,
              elevation: 0,
              onPressed: () {
                setState(() {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100))
                      .then((data) {
                    if (data != null) {
                      DateTime dato = data;
                      plan_date_shower_state.fecha_final.value = dato;
                    }

                    print(data);
                    return data;
                  });
                });
              },
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.today,
                  size: ScreenUtil().setSp(70),
                  color: Colors.white,
                ),
                Text(
                  birth_text,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(70), color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class plan_date_shower extends StatefulWidget {
  String formatted_data;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return plan_date_shower_state();
  }
}

class plan_date_shower_state extends State<plan_date_shower> {
  var f = new DateFormat('dd-MM-yyyy');
  var h = new DateFormat('yyyy-MM-dd');
  var temp;

  static ValueNotifier<DateTime> fecha_final = ValueNotifier<DateTime>(null);
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setWidth(400),
          height: ScreenUtil().setHeight(120),
          child: Material(
            color: Colors.white,
            elevation: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              child: Center(
                  child: ValueListenableBuilder(
                      valueListenable: fecha_final,
                      builder: (BuildContext context, fecha, Widget child) {
                        if (fecha == null) {
                          return Text(
                            "   -   -   - ",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(60),
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          );
                        } else {
                          temp = h.format(fecha);
                          Actividad.esteEvento.Fecha = temp;
                          return Text(
                            f.format(fecha),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(60),
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          );
                        }
                      })),
            ),
          ),
        ),
      ],
    );
  }
}

class hour_button extends StatefulWidget {
  String birth;

  hour_button(String birth) {
    this.birth = birth;
  }
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return hour_button_state(birth);
  }
}

class hour_button_state extends State<hour_button> {
  DateTime Time;
  String birth_text;
  DateTime date;
  static int age;
  hour_button_state(String birth_text) {
    this.birth_text = birth_text;
  }
  static int GetAge() {
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setWidth(470),
          height: ScreenUtil().setHeight(120),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: RaisedButton(
              color: Colors.deepPurple,
              elevation: 0,
              onPressed: () {
                DatePicker.showTimePicker(context, showSecondsColumn: false,
                    onConfirm: (time) {
                  print(time);
                  setState(() {
                    Time = time;
                    plan_hour_shower_state.fecha_final.value = Time;
                  });
                });
              },
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.access_time,
                  size: ScreenUtil().setSp(70),
                  color: Colors.white,
                ),
                Text(
                  birth_text,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(70), color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class plan_hour_shower extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return plan_hour_shower_state();
  }
}

class plan_hour_shower_state extends State<plan_hour_shower> {
  final f = new DateFormat('HH:mm');
  static DateTime Hora;
  static ValueNotifier<DateTime> fecha_final = ValueNotifier<DateTime>(Hora);
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: ScreenUtil().setWidth(400),
          height: ScreenUtil().setHeight(120),
          child: Material(
            color: Colors.white,
            elevation: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              child: Center(
                  child: ValueListenableBuilder(
                      valueListenable: fecha_final,
                      builder: (BuildContext context, fecha, Widget child) {
                        print("$fecha en casa");
                        if (fecha == null) {
                          return SizedBox(
                            width: ScreenUtil().setWidth(300),
                            child: Text(
                              "  ",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(60),
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        } else {
                          Actividad.esteEvento.Hora = f.format(fecha);

                          return Text(
                            f.format(fecha),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(60),
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold),
                          );
                        }
                      })),
            ),
          ),
        ),
      ],
    );
  }
}

class PerfilesGenteCitas extends StatefulWidget {
  List<List<Widget>> perfiles = new List();
  static int posicion;
  static double valor;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PerfilesGenteCitasState();
  }
}

class PerfilesGenteCitasState extends State<PerfilesGenteCitas> {
  ItemScrollController mover = new ItemScrollController();
  bool leGusta = false;
  double valorSlider = 5;

  void soltarBotonLike(DatosPerfiles datos) {
    leGusta = false;
    Perfiles.perfilesCitas.notifyListeners();
    datos.crearDatosValoracion();
    print(" HAY EStos usuarios ${Perfiles.perfilesCitas.listaPerfiles.length}");
    Perfiles.perfilesCitas.listaPerfiles.length;
    //  mover.next(animation: true);
    leGusta = false;
    print("Fuera");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: ScreenUtil().setHeight(2400),
      width: ScreenUtil().setWidth(1500),
      child: ScrollablePositionedList.builder(
        itemCount: Perfiles.perfilesCitas.listaPerfiles.length,
        physics: NeverScrollableScrollPhysics(),
        itemScrollController: mover,
        reverse: false,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int indice) {
          void noLike(DatosPerfiles datos) {
            if (Perfiles.perfilesCitas.listaPerfiles.length > indice + 1) {
              print(indice);
              mover.scrollTo(
                  index: indice + 1,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic);
              print(indice);
            }
          }

          return Stack(alignment: Alignment.bottomCenter, children: [
            Container(
              height: ScreenUtil().setHeight(2400),
              width: ScreenUtil().setWidth(1400),
              child: ListView(
                children: Perfiles.perfilesCitas.listaPerfiles[indice].carrete,
              ),
            ),
            leGusta
                ? Container(
                    height: ScreenUtil().setHeight(2400),
                    width: ScreenUtil().setWidth(1400),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                      color: Color.fromRGBO(255, 78, 132, 50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text(
                            "¿Cuanto te gusta ${Perfiles.perfilesCitas.listaPerfiles[indice].nombreusuaio}?",
                            style: TextStyle(
                                fontSize: ScreenUtil()
                                    .setSp(100, allowFontScalingSelf: false),
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          Divider(
                            height: ScreenUtil().setHeight(150),
                          ),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: LinearPercentIndicator(
                                //  progressColor: Colors.deepPurple,
                                percent: Perfiles.perfilesCitas
                                        .listaPerfiles[indice].valoracion /
                                    10,
                                animationDuration: 0,

                                lineHeight: ScreenUtil().setHeight(150),
                                linearGradient: LinearGradient(colors: [
                                  Colors.pink,
                                  Colors.pinkAccent[100]
                                ]),
                                center: Text(
                                  "${Perfiles.perfilesCitas.listaPerfiles[indice].valoracion.toStringAsFixed(1)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil().setSp(100,
                                          allowFontScalingSelf: false),
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            height: ScreenUtil().setHeight(150),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.white,
                            ),
                            child: TextField(
                              maxLines: 2,
                              maxLength: 60,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(bottom: 0),
                                labelText: "¿Quieres romper el hielo?",
                                labelStyle: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: ScreenUtil().setSp(60)),
                              ),
                              onChanged: (String val) {
                                setState(() {
                                  Perfiles.perfilesCitas.listaPerfiles[indice]
                                      .mensaje = val;
                                });
                              },
                            ),
                          ),
                          Divider(
                            height: ScreenUtil().setHeight(100),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: FlatButton(
                                  onPressed: () {
                                    print(leGusta);
                                    leGusta = false;
                                    Perfiles.perfilesCitas.listaPerfiles[indice]
                                        .valoracion = 5;
                                    Perfiles.perfilesCitas.notifyListeners();
                                    print(leGusta);
                                  },
                                  color: Colors.black,
                                  child: Text(
                                    "Atras",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: FlatButton(
                                  onPressed: () {
                                    soltarBotonLike(Perfiles
                                        .perfilesCitas.listaPerfiles[indice]);
                                  },
                                  color: Colors.green,
                                  child: Text("Hecho"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ))
                : Container(),
            Container(
              width: ScreenUtil().setWidth(1300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: ScreenUtil().setHeight(250),
                    width: ScreenUtil().setWidth(200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(255, 78, 132, 100),
                    ),
                    child: FlatButton(
                      padding: EdgeInsets.all(8),
                      onPressed: () {
                        noLike(Perfiles.perfilesCitas.listaPerfiles[indice]);
                        Perfiles.perfilesCitas.notifyListeners();
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
                  Container(
                    height: ScreenUtil().setHeight(200),
                    width: ScreenUtil().setWidth(700),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromRGBO(255, 78, 132, 100),
                    ),
                    child: SliderTheme(
                      data: SliderThemeData(
                          trackHeight: ScreenUtil().setHeight(60),
                          activeTrackColor: Colors.pink,
                          disabledActiveTrackColor: Colors.pink,
                          disabledInactiveTrackColor: Colors.pink,
                          disabledThumbColor: Colors.pink,
                          valueIndicatorShape: SliderComponentShape.noThumb,
                          thumbColor: Colors.pink,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 20,
                          ),
                          overlappingShapeStrokeColor: Colors.pink,
                          overlayColor: Colors.pink),
                      child: GestureDetector(
                        onTap: () {},
                        child: Slider(
                          value: Perfiles
                              .perfilesCitas.listaPerfiles[indice].valoracion,
                          onChangeStart: (val) {
                            print(val);
                            leGusta = true;
                            print(leGusta);
                            Perfiles.perfilesCitas.notifyListeners();
                          },
                          onChanged: (valor) {
                            setState(() {
                              Perfiles.perfilesCitas.listaPerfiles[indice]
                                  .valoracion = valor;
                            });
                          },
                          min: 5,
                          max: 10,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ]);
        },
      ),
    );
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
    Valoraciones.Puntuaciones.obtenerValoracion();
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
        void noLike(DatosPerfiles datos) {
          if (Perfiles.perfilesAmistad.listaPerfiles.length > indice + 1) {
            print(indice);
            mover.scrollTo(
                index: indice + 1,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic);
            print(indice);
          }
        }

        return Stack(alignment: Alignment.bottomCenter, children: [
          Container(
            height: ScreenUtil().setHeight(2400),
            width: ScreenUtil().setWidth(1400),
            child: ListView(
              children: Perfiles.perfilesAmistad.listaPerfiles[indice].carrete,
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
                      Perfiles.perfilesCitas.notifyListeners();
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

class cancel_button extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return cancel_button_state();
  }
}

class cancel_button_state extends State<cancel_button> {
  Widget build(BuildContext build) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: ScreenUtil().setWidth(500),
                height: ScreenUtil().setHeight(120),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.red),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Icon(Icons.cancel), Text("Cancel")],
                ),
              )),
        ],
      ),
    );
  }
}

class next_button extends StatefulWidget {
  bool mostrarParticipantes;
  next_button(this.mostrarParticipantes);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return next_button_state();
  }
}

class next_button_state extends State<next_button> {
  Widget build(BuildContext build) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 100),
                        transitionsBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secAnimation,
                            Widget child) {
                          return ScaleTransition(
                              alignment: Alignment.centerRight,
                              scale: animation,
                              child: child);
                        },
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secAnimation) {
                          return confirm_plan_screen(widget.mostrarParticipantes);
                        }));
                ;
              },
              child: Container(
                width: ScreenUtil().setWidth(500),
                height: ScreenUtil().setHeight(120),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: Colors.green),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Icon(Icons.check_circle), Text("Next")],
                ),
              )),
        ],
      ),
    );
  }
}

///**************************************************************************************************************************************************************
///                                   PANTALLA DE CONFIRMACION
///
/// STRING NAME: Recibe una cadena de caracteres con la traduccion de SEXO adecuada al idioma traducido
///
/// STRING MALE_SEX_NAME: Recibe una cadena de caracteres con la traduccion adecuada de HOMBRE
///
/// STRING FEMALE_SEX_NAME: Recibe una cadena de caracteres con la traduccion adecuada de MUJER
///
/// *************************************************************************************************************************************************************

class confirm_plan_screen extends StatefulWidget {
  bool masDeUnParticipane = true;
  confirm_plan_screen(this.masDeUnParticipane);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return confirm_plan_screen_state();
  }
}

// ignore: camel_case_types
class confirm_plan_screen_state extends State<confirm_plan_screen> {
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
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1440, height: 3120, allowFontScaling: true);
    return ChangeNotifierProvider.value(
      value: Actividad.esteEvento,
      child: SafeArea(
        child: Container(
          color: Colors.deepPurple.shade300,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        height: ScreenUtil().setHeight(150),
                        child: Text(
                          "Add a Picture",
                          style: TextStyle(fontSize: ScreenUtil().setSp(90)),
                        ),
                      ),
                    ),
                    Container(
                        height: ScreenUtil().setHeight(1200),
                        color: Colors.deepPurple.shade200,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Consumer<Actividad>(
                            builder: (context, actividad, child) {
                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      FotoEvento(0, actividad.Images_List[0]),
                                      FotoEvento(1, actividad.Images_List[1]),
                                      FotoEvento(2, actividad.Images_List[2]),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      FotoEvento(3, actividad.Images_List[3]),
                                      FotoEvento(4, actividad.Images_List[4]),
                                      FotoEvento(5, actividad.Images_List[5]),
                                    ],
                                  )
                                ],
                              );
                            },
                          ),
                        )),
                  ],
                ),
                Container(
                  height: ScreenUtil().setHeight(200),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      height: ScreenUtil().setHeight(1300),
                      color: Colors.white,
                      child: Consumer<Actividad>(builder:
                          (BuildContext context, actividad, Widget child) {
                        // print(usuario.cine);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.count(
                              childAspectRatio: (ScreenUtil().setWidth(550) /
                                  ScreenUtil().setHeight(350)),
                              mainAxisSpacing: ScreenUtil().setHeight(50),
                              crossAxisSpacing: ScreenUtil().setWidth(30),
                              addRepaintBoundaries: false,
                              crossAxisCount: 3,
                              children: [
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.car),
                                    BotonGustosState.setCoche,
                                    coche,
                                    actividad.coches),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.gamepad),
                                    BotonGustosState.setJuegos,
                                    videojuegos,
                                    actividad.juegos),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.film),
                                    BotonGustosState.setCine,
                                    cine,
                                    actividad.cine),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.screwdriver),
                                    BotonGustosState.setManualidades,
                                    bricolaje,
                                    actividad.manualidades),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.hamburger),
                                    BotonGustosState.setComida,
                                    comida,
                                    actividad.comida),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.t_shirt),
                                    BotonGustosState.setModa,
                                    moda,
                                    actividad.moda),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.otter),
                                    BotonGustosState.setAnimales,
                                    animales,
                                    actividad.animales),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.music),
                                    BotonGustosState.setMusica,
                                    musica,
                                    actividad.musica),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.mountain),
                                    BotonGustosState.setNaturaleza,
                                    naturaleza,
                                    actividad.naturaleza),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.brain),
                                    BotonGustosState.setCiencia,
                                    ciencia,
                                    actividad.ciencia),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.vote_yea),
                                    BotonGustosState.setPolitica,
                                    politica,
                                    actividad.politica),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.suitcase),
                                    BotonGustosState.setViajes,
                                    viajes,
                                    actividad.viajes),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.glass_cheers),
                                    BotonGustosState.setFiesta,
                                    fiesta,
                                    actividad.fiesta),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.users),
                                    BotonGustosState.setVidaSocial,
                                    vidasocial,
                                    actividad.vida_social),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.dumbbell),
                                    BotonGustosState.setDeporte,
                                    fittnes,
                                    actividad.deportes),
                                BotonGustos(
                                    context,
                                    Icon(LineAwesomeIcons.heartbeat),
                                    BotonGustosState.setSalud,
                                    salud,
                                    actividad.salud),
                              ]),
                        );
                      }),
                    ),
                    widget.masDeUnParticipane
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: ScreenUtil().setHeight(500),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Participantes:",
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(90)),
                                      ),
                                      Container(
                                        child: Text(
                                            "${(Actividad.esteEvento.participantesEvento * 10).toInt()}",
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(90))),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    height: ScreenUtil().setHeight(100),
                                  ),
                                  Material(
                                    child: Container(
                                      child: Slider(
                                          label:
                                              "${Actividad.esteEvento.participantesEvento}",
                                          value: Actividad.esteEvento
                                                  .participantesEvento /
                                              10,
                                          min: 0,
                                          max: 1,
                                          onChanged: (valor) {
                                            setState(() {});
                                            Actividad.esteEvento
                                                    .participantesEvento =
                                                valor * 10;

                                            print(Actividad.esteEvento
                                                .participantesEvento);
                                          }),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    Container(
                      height: ScreenUtil().setHeight(600),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          cancel_button(),
                          submit_plan_button()
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FotoEvento extends StatefulWidget {
  int box;
  File Imagen;

  FotoEvento(this.box, this.Imagen);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FotoEventoState(this.box, this.Imagen);
  }
}

class FotoEventoState extends State<FotoEvento> {
  @override
  File Image_picture;
  File imagen;
  File imagenFinal;

  static List<File> pictures = List(6);
  int box;
  FotoEventoState(this.box, this.imagen) {}
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

  abrirGaleria(BuildContext context) async {
    var archivoImagen =
        await ImagePicker.pickImage(source: ImageSource.gallery);
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

    this.setState(() {
      imagenFinal = imagenRecortada;
      pictures[box] = imagenFinal;
      Actividad.esteEvento.Images_List = pictures;
      print("${archivoImagen.lengthSync()} Tamaño original");
      print("${imagenRecortada.lengthSync()} Tamaño Recortado");
      print(box);
      Actividad.esteEvento.notifyListeners();
    });
  }

  abrirCamara(BuildContext context) async {
    var archivoImagen = await ImagePicker.pickImage(source: ImageSource.camera);
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

    this.setState(() {
      imagenFinal = imagenRecortada;
      pictures[box] = imagenFinal;
      Actividad.esteEvento.Images_List = pictures;
      print("${archivoImagen.lengthSync()} Tamaño original");
      print("${imagenRecortada.lengthSync()} Tamaño Recortado");
      print(box);
      Actividad.esteEvento.notifyListeners();
    });
  }

  eliminarImagen(BuildContext context) {
    this.setState(() {
      Actividad.esteEvento.Images_List[box] = null;
      imagenFinal = null;
      print("object");
      if (Actividad.esteEvento.Images_List[box] == null) {
        print("vacio en $box");
        Actividad.esteEvento.notifyListeners();
      }
    });
  }

  Widget build(BuildContext context) {
    imagen = widget.Imagen;
    // TODO: implement build
    return Container(
      height: ScreenUtil().setHeight(420),
      width: ScreenUtil().setWidth(420),
      decoration: BoxDecoration(
        border:
            Border.all(color: Colors.white, width: ScreenUtil().setWidth(6)),
        borderRadius: BorderRadius.all(Radius.circular(3)),
        color: Colors.white30,
      ),
      child: FlatButton(
        onPressed: () => opcionesImagenPerfil(),
        onLongPress: () => eliminarImagen(context),
        child: imagenFinal == null
            ? Center(
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                ),
              )
            : Stack(alignment: AlignmentDirectional.center, children: [
                Image.file(
                  imagenFinal,
                  fit: BoxFit.fill,
                ),
                Container(
                  height: ScreenUtil().setHeight(500),
                  width: ScreenUtil().setWidth(500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: ScreenUtil().setSp(150),
                    ),
                  ),
                ),
              ]),
      ),
    );
  }
}

class submit_plan_button extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return submit_plan_button_state();
  }
}

class submit_plan_button_state extends State<submit_plan_button> {
  Widget build(BuildContext build) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          FlatButton(
              onPressed: () {
                Actividad.esteEvento.Upload_Image();
              },
              child: Container(
                width: ScreenUtil().setWidth(500),
                height: ScreenUtil().setHeight(120),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    color: Colors.green),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.check_circle),
                    Text("Create Plan")
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class BotonGustos extends StatefulWidget {
  BuildContext context;
  Icon icono;
  Function funcion;
  String text;
  bool seleccionado;
  BotonGustos(context, icono, funcion, text, seleccionado) {
    this.context = context;
    this.icono = icono;
    this.funcion = funcion;
    this.text = text;
    this.seleccionado = seleccionado;
    // print(seleccionado);
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BotonGustosState();
  }
}

class BotonGustosState extends State<BotonGustos> {
  static bool setCoche() {
    if (Actividad.esteEvento.coches == false) {
      Actividad.esteEvento.coches = true;
      return null;
    } else {
      Actividad.esteEvento.coches = false;
      return null;
    }
  }

  static bool setCine() {
    if (Actividad.esteEvento.cine == false ||
        Actividad.esteEvento.cine == null) {
      // print("Activo");
      Actividad.esteEvento.cine = true;

      //  print(Usuario.esteUsuario.cine);
      return null;
    } else {
      Actividad.esteEvento.cine = false;
      //   print(Usuario.esteUsuario.cine);
      return null;
    }
  }

  static bool setJuegos() {
    if (Actividad.esteEvento.juegos == false) {
      Actividad.esteEvento.juegos = true;
      return null;
    } else {
      Actividad.esteEvento.juegos = false;
      return null;
    }
  }

  static bool setManualidades() {
    if (Actividad.esteEvento.manualidades == false) {
      Actividad.esteEvento.manualidades = true;
      // ignore: unnecessary_statements
      return null;
    } else {
      Actividad.esteEvento.manualidades = false;
      return null;
    }
  }

  static bool setComida() {
    if (Actividad.esteEvento.comida == false) {
      Actividad.esteEvento.comida = true;
      return null;
    } else {
      Actividad.esteEvento.comida = false;
      return null;
    }
  }

  static bool setModa() {
    if (Actividad.esteEvento.moda == false) {
      Actividad.esteEvento.moda = true;
      return null;
    } else {
      Actividad.esteEvento.moda = false;
      return null;
    }
  }

  static bool setAnimales() {
    if (Actividad.esteEvento.animales == false) {
      Actividad.esteEvento.animales = true;
      return null;
    } else {
      Actividad.esteEvento.animales = false;
      return null;
    }
  }

  static bool setMusica() {
    if (Actividad.esteEvento.musica == false) {
      Actividad.esteEvento.musica = true;
      return null;
    } else {
      Actividad.esteEvento.musica = false;
      return null;
    }
  }

  static bool setNaturaleza() {
    if (Actividad.esteEvento.naturaleza == false) {
      Actividad.esteEvento.naturaleza = true;
      return null;
    } else {
      Actividad.esteEvento.naturaleza = false;
      return null;
    }
  }

  static bool setCiencia() {
    if (Actividad.esteEvento.ciencia == false) {
      Actividad.esteEvento.ciencia = true;
      return null;
    } else {
      Actividad.esteEvento.ciencia = false;
      return null;
    }
  }

  static bool setPolitica() {
    if (Actividad.esteEvento.politica == false) {
      Actividad.esteEvento.politica = true;
      return null;
    } else {
      Actividad.esteEvento.politica = false;
      return null;
    }
  }

  static bool setViajes() {
    if (Actividad.esteEvento.viajes == false) {
      Actividad.esteEvento.viajes = true;
      return null;
    } else {
      Actividad.esteEvento.viajes = false;
      return null;
    }
  }

  static bool setFiesta() {
    if (Actividad.esteEvento.fiesta == false) {
      Actividad.esteEvento.fiesta = true;
      return null;
    } else {
      Actividad.esteEvento.fiesta = false;
      return null;
    }
  }

  static bool setVidaSocial() {
    if (Actividad.esteEvento.vida_social == false) {
      Actividad.esteEvento.vida_social = true;
      return null;
    } else {
      Actividad.esteEvento.vida_social = false;
    }
  }

  static bool setDeporte() {
    if (Actividad.esteEvento.deportes == false) {
      Actividad.esteEvento.deportes = true;
      return null;
    } else {
      Actividad.esteEvento.deportes = false;
      return null;
    }
  }

  static bool setSalud() {
    if (Actividad.esteEvento.salud == false) {
      Actividad.esteEvento.salud = true;
      return null;
    } else {
      Actividad.esteEvento.salud = false;
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
//print(widget.seleccionado);

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          color: widget.seleccionado ? Colors.green : Colors.transparent),
      child: FlatButton(
        onPressed: () {
          widget.funcion();
        },
        child: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            widget.icono,
            Text(
              widget.text,
              style: TextStyle(fontSize: ScreenUtil().setSp(40)),
            ),
          ],
        )),
      ),
    );
  }
}

class SeleccionarTipoPlan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SeleccionarTipoPlanState();
  }
}

class SeleccionarTipoPlanState extends State<SeleccionarTipoPlan> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog();
  }
}
