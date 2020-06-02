import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'dart:math';
import 'package:citasnuevo/DatosAplicacion/actividad.dart';
import 'TarjetaEvento.dart';
import 'pantalla_actividades_elements.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class pantalla extends StatefulWidget {
  @override
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Pantalla_Actividades();
  }
}

class Pantalla_Actividades extends State<pantalla>
    with SingleTickerProviderStateMixin {
  Color colorPrincipal = Color.fromRGBO(27, 189, 163, 100);
  TabController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 3, vsync: this);

    //fill in the screen size of the device in the design

//default value : width : 1080px , height:1920px , allowFontScaling:false

//If you want to set the font size is scaled according to the system's "font size" assist optio
  }

  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void _showActivityDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Nuevo Plan"),
            content: Text("Selecciona el tipo de plan"),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                                transitionDuration: Duration(milliseconds: 100),
                                transitionsBuilder: (BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secAnimation,
                                    Widget child) {
                                  return ScaleTransition(
                                      alignment: Alignment.center,
                                      scale: animation,
                                      child: child);
                                },
                                pageBuilder: (BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secAnimation) {
                                  return plan_screen(false);
                                }));
                      },
                      child: Text("Individual")),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                       Navigator.push(
                            context,
                            PageRouteBuilder(
                                transitionDuration: Duration(milliseconds: 100),
                                transitionsBuilder: (BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secAnimation,
                                    Widget child) {
                                  return ScaleTransition(
                                      alignment: Alignment.center,
                                      scale: animation,
                                      child: child);
                                },
                                pageBuilder: (BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secAnimation) {
                                  return plan_screen(true);
                                }));
                      },
                      child: Text("Grupo")),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1440, height: 3120, allowFontScaling: false);
    // TODO: implement build
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Consumer<Actividad>(
            builder: (BuildContext context, actividad, Widget child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: true,
            backgroundColor: Color.fromRGBO(255, 78, 132, 100),
            body: Padding(
              padding:
                  const EdgeInsets.only(top: 3, bottom: 3, left: 5, right: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: ScreenUtil().setHeight(150),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                   
                        Container(
                          height: ScreenUtil().setHeight(150),
                          child: FlatButton(
                            onPressed: () {
                              _showActivityDialog();
                            },
                            child: Row(
                              children: <Widget>[
                                 Icon(
                                  Icons.people,
                                  color: Colors.white,
                                  size: ScreenUtil().setSp(130),
                                ),
                                Text(
                                  "Crear Plan",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(50)),
                                ),
                               
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                "En directo",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(50)),
                              ),
                              Icon(
                                LineAwesomeIcons.globe,
                                color: Colors.white,
                                size: ScreenUtil().setSp(130),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: ScreenUtil().setHeight(110),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    child: getTabBar(),
                  ),
                  Container(
                      height: ScreenUtil().setHeight(2300),
                      child: getTabBarView()),

                  /* FloatingActionButton(
                    onPressed: ()=>Perfiles().ObtenerPerfil(),
                  )*/
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  TabBar getTabBar() {
    return TabBar(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white,
      indicatorColor: Colors.white,
      tabs: <Widget>[
        Container(
          child: Tab(
            text: "Citas",
          ),
        ),
        Tab(
          text: "Amistad",
        ),
        Tab(
          text: "Planes",
        ),
      ],
      controller: controller,
    );
  }

  TabBarView getTabBarView() {
    controller.notifyListeners();
    return TabBarView(
      children: <Widget>[
        Citas(),
        Amistad(),
        Populares(),
      ],
      controller: controller,
    );
  }
}

class Citas extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CitasState();
  }
}

class CitasState extends State<Citas> with AutomaticKeepAliveClientMixin<Citas>{
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Perfiles.perfilesCitas,
      child: Consumer<Perfiles>(
        builder: (BuildContext context, perfiles, Widget child) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            height: ScreenUtil().setHeight(2400),
            child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  perfiles.listaPerfiles == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              Text(
                                "Cargando",
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        )
                      : Container(
                          height: ScreenUtil().setHeight(2400),
                          width: ScreenUtil().setWidth(1500),
                          child: PerfilesGenteCitas()),
                ]),
          );
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class Amistad extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AmistadState();
  }
}

class AmistadState extends State<Amistad>with AutomaticKeepAliveClientMixin<Amistad> {
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Perfiles.perfilesAmistad,
      child: Consumer<Perfiles>(
        builder: (BuildContext context, perfiles, Widget child) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            height: ScreenUtil().setHeight(2400),
            child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  perfiles.listaPerfiles == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              Text(
                                "Cargando",
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        )
                      : PerfilesGenteAmistad(),
                ]),
          );
        },
      ),
    );
  }
}
class Populares extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PopularesState();
  }
  
}



class PopularesState extends State<Populares> with AutomaticKeepAliveClientMixin<Populares> {
    bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return EventosCerca();
  }
}

class Historial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
//    return ListView(children: Actividad().listaEventos);
  }
}
