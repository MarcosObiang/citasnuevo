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
import 'package:story_view/story_view.dart';

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
  static bool citas = true;
  static bool amigos = false;
  static bool eventos = false;
  static String tituloModo = "";
  static String descripcionModo = "";
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
    void seleccionarModo() {
      if (citas) {
        controller.index = 0;
      }
      if (amigos) {
        controller.index = 1;
      }
      if (eventos) {
        controller.index = 2;
      }
      Usuario.esteUsuario.notifyListeners();
    }

    void opcionesModoAplicacion() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return ChangeNotifierProvider.value(
              value: Usuario.esteUsuario,
              child: Consumer<Usuario>(
                builder: (BuildContext context, Usuario user, Widget child) {
                  if (citas) {
                    tituloModo = "Citas";
                    descripcionModo =
                        "Encuentra a tu media naranja,hazle saber cuanto te gusta";
                  }
                  if (amigos) {
                    tituloModo = "Amigos";
                    descripcionModo =
                        "¿No quieres citas? encuentra un buen colega y hacer eventos";
                  }
                  if (eventos) {
                    tituloModo = "Eventos";
                    descripcionModo =
                        "¿Te aburres? encuantra un plan y apuntate";
                  }
                  return Container(
                    height: ScreenUtil.defaultHeight / 2,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              child: Text(
                            tituloModo,
                            style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                          )),
                          Divider(height: ScreenUtil().setHeight(200)),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              child: Text(
                                descripcionModo,
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(60)),
                              ),
                            ),
                          ),
                          Divider(height: ScreenUtil().setHeight(200)),
                          CheckboxListTile(
                            value: citas,
                            secondary: Icon(LineAwesomeIcons.heart),
                            title: Text("Citas"),
                            onChanged: (bool value) {
                              citas = value;
                              amigos = false;
                              eventos = false;
                              Usuario.esteUsuario.notifyListeners();
                            },
                          ),
                          CheckboxListTile(
                            value: amigos,
                            secondary: Icon(LineAwesomeIcons.people_carry),
                            title: Text("Amigos"),
                            onChanged: (bool value) {
                              print("Amigos");
                              amigos = value;
                              citas = false;
                              eventos = false;
                              Usuario.esteUsuario.notifyListeners();
                            },
                          ),
                          CheckboxListTile(
                            value: eventos,
                            secondary: Icon(Icons.map),
                            title: Text("Eventos"),
                            onChanged: (bool value) {
                              eventos = value;
                              citas = false;
                              amigos = false;
                              Usuario.esteUsuario.notifyListeners();
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: Colors.red),
                                    child: FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Atras"))),
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: Colors.green),
                                    child: FlatButton(
                                        onPressed: () {
                                          seleccionarModo();
                                          Navigator.pop(context);
                                        },
                                        child: Text("Aceptar"))),
                              ],
                            ),
                          )
                        ]),
                  );
                },
              ),
            );
          });
    }

    // TODO: implement build
    return Container(
      child: DefaultTabController(
        length: 3,
        child: ChangeNotifierProvider.value(
            value: Usuario.esteUsuario,
            child: Consumer<Usuario>(
              builder: (BuildContext context, Usuario usuario, Widget child) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  resizeToAvoidBottomPadding: false,
                  backgroundColor: Colors.white,
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        LineAwesomeIcons.coins,
                                        color: Colors.black,
                                        size: ScreenUtil().setSp(80),
                                      ),
                                      Text(
                                        "10000",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: ScreenUtil().setSp(40)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.people,
                                        color: Colors.black,
                                        size: ScreenUtil().setSp(80),
                                      ),
                                      Text(
                                        "Crear Plan",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: ScreenUtil().setSp(30)),
                                      ),
                                    ],
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3)),
                                      ),
                                      child: FlatButton(
                                          onPressed: () {
                                            opcionesModoAplicacion();
                                          },
                                          child: Text(tituloModo))),
                                  Container(
                                    child: GestureDetector(
                                      onTap: () => !Usuario.esteUsuario
                                                  .tieneHistorias
                                              
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CreadorDeHistorias()))
                                          : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HistoriasUsuario())),
                                      child: Column(
                                        children: <Widget>[
                                          Icon(
                                            LineAwesomeIcons.plus_circle,
                                            color: Colors.black,
                                            size: ScreenUtil().setSp(95),
                                          ),
                                          Text(
                                            " Tu historia",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize:
                                                    ScreenUtil().setSp(30)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        LineAwesomeIcons.globe,
                                        color: Colors.black,
                                        size: ScreenUtil().setSp(80),
                                      ),
                                      Text(
                                        "En directo",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: ScreenUtil().setSp(30)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 16,
                            fit: FlexFit.tight,
                            child: Container(
                                //  height: ScreenUtil().setHeight(2660),
                                child: getTabBarView()),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
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
      physics: NeverScrollableScrollPhysics(),
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

class CitasState extends State<Citas> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Perfiles.perfilesCitas,
      child: Consumer<Perfiles>(
        builder: (BuildContext context, perfiles, Widget child) {
          print("actividadconstruida");
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            height: ScreenUtil().setHeight(3200),
            child: Stack(
                alignment: AlignmentDirectional.center,
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
                          height: ScreenUtil().setHeight(3000),
                          width: ScreenUtil().setWidth(1500),
                          child: PerfilesGenteCitas()),
                ]),
          );
        },
      ),
    );
  }
}

class Amistad extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AmistadState();
  }
}

class AmistadState extends State<Amistad> {
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
            height: ScreenUtil().setHeight(2900),
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
                          height: ScreenUtil().setHeight(2900),
                          width: ScreenUtil().setWidth(1500),
                          child: PerfilesGenteAmistad()),
                ]),
          );
        },
      ),
    );
  }
}

class CreadorDeHistorias extends StatefulWidget {
  static final GlobalKey clave = GlobalKey();
  @override
  _CreadorDeHistoriasState createState() => _CreadorDeHistoriasState();
}

class _CreadorDeHistoriasState extends State<CreadorDeHistorias> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: CreadorDeHistorias.clave,
      appBar: AppBar(
        title: Text("Subir Historias"),
      ),
      body: Container(
          color: Colors.grey,
          child: Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(children: [
                    FotoHistoria(0, Usuario.esteUsuario.fotosHistorias[0]),
                    FotoHistoria(1, Usuario.esteUsuario.fotosHistorias[1]),
                    FotoHistoria(2, Usuario.esteUsuario.fotosHistorias[2]),
                  ]),
                  Row(children: [
                    FotoHistoria(3, Usuario.esteUsuario.fotosHistorias[3]),
                    FotoHistoria(4, Usuario.esteUsuario.fotosHistorias[4]),
                    FotoHistoria(5, Usuario.esteUsuario.fotosHistorias[5]),
                  ]),
                  Container(
                      color: Colors.green,
                      child: FlatButton(
                          onPressed: () => Usuario.esteUsuario
                              .subirHistorioasUsuario(
                                  Usuario.esteUsuario.idUsuario),
                          child: Text("Subir historias")))
                ]),
          )),
    );
  }
}

class HistoriasUsuario extends StatefulWidget {
 static final controlador = StoryController();
  static List<StoryItem> historias = new List();

   static void cargarHistorias(){
       for (int i = 0; i < Usuario.esteUsuario.listaDeHistoriasRed.length; i++) {
      if (Usuario.esteUsuario.listaDeHistoriasRed[i] != null) {
              if(Usuario.esteUsuario.listaDeHistoriasRed[i]["Imagen"] != null){
     
        StoryItem historia = StoryItem.pageImage(
            url: Usuario.esteUsuario.listaDeHistoriasRed[i]["Imagen"],
            controller: HistoriasUsuario.controlador);
        HistoriasUsuario.historias.add(historia);
           print("${Usuario.esteUsuario.listaDeHistoriasRed[i]["Imagen"]}jajjjjjjjjjjjjjjjjjjjjjjajjjjjjjjjjjjjjjjjjjjjj");}
      }
    }
  }
  @override
  _HistoriasUsuarioState createState() => _HistoriasUsuarioState();
}

class _HistoriasUsuarioState extends State<HistoriasUsuario> {

  @override
  Widget build(BuildContext context) {
    
   
 
    HistoriasUsuario.controlador.play();

    return Material(
      child: SafeArea(
        child: Container(
          child: Stack(
            children: <Widget>[
              StoryView(
                storyItems: HistoriasUsuario.historias,
                controller: HistoriasUsuario.controlador,
                repeat: false,
                onComplete: () {
                  // Navigator.pop(context);
                },
              ),
              Positioned(
                top: ScreenUtil().setHeight(100),
                
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 
                    children: <Widget>[
                      Container(
                        child: FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back,
                              size: ScreenUtil().setSp(100),
                              color: Colors.white,
                            )),
                      ),
                      Text(
                        "Tu historia",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(60)),
                      ),
                    
                    ],
                  ),
                  
                ),
              ),
                Positioned(
                        top:ScreenUtil().setHeight(100),
                        left: ScreenUtil.screenWidth/4,
                        child: Container(
                        child: GestureDetector(
                          onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreadorDeHistorias()));
                                     HistoriasUsuario.controlador.pause();
                                      },
                            
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: ScreenUtil().setSp(95),
                              ),
                              Text(
                                " Editar",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(30)),
                              ),
                            ],
                          ),
                        ),
                      ),)
            ],
          ),
        ),
      ),
    );
  }
}

class Populares extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PopularesState();
  }
}

class PopularesState extends State<Populares> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Actividad.cacheActividadesParaTi,
      child: Consumer<Actividad>(
        builder: (BuildContext context, actividad, Widget child) {
          return Container(child: EventosCerca());
        },
      ),
    );
  }
}

class Historial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
//    return ListView(children: Actividad().listaEventos);
  }
}
