
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'package:provider/provider.dart';


import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';


import 'pantalla_actividades_elements.dart';

class PantallaPrincipal extends StatefulWidget {
  @override
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return Pantalla_Actividades();
  }
}

class Pantalla_Actividades extends State<PantallaPrincipal>
    with SingleTickerProviderStateMixin{
  Color colorPrincipal = Color.fromRGBO(27, 189, 163, 100);
  TabController controller;
  static bool citas = true;
  static bool amigos = false;
  static bool eventos = false;
  static String tituloModo = "";
  static String descripcionModo = "";
  static GlobalKey claveListaCitas = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 1, vsync: this);

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



  @override
  Widget build(BuildContext context) {
    
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
      height: ScreenUtil.screenHeight - kBottomNavigationBarHeight,
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
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                  
                      Expanded(
                        child: LayoutBuilder(
                          builder: (BuildContext contexto,
                              BoxConstraints limites) {
                            return Container(
                              height: limites.biggest.height,
                              child: Perfiles.perfilesCitas.listaPerfiles==null?Center(
                                child: Container(
                                  height: ScreenUtil().setHeight(150),
                                  width: ScreenUtil().setWidth(150),
                                  child: CircularProgressIndicator()),
                              ):getTabBarView(limites),
                            );
                          },
                        ),
                      )
                    ],
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

  TabBarView getTabBarView(BoxConstraints limitesHeredados) {
    controller.notifyListeners();
    return TabBarView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        Citas(
          limites: limitesHeredados,
        ),
    
        
      ],
      controller: controller,
    );
  }


}

class Citas extends StatefulWidget {
  BoxConstraints limites;
  static bool estaConectado=false;
  static bool pantallaCalificacion = false;
  bool leGustaPerfil = false;
  static final verdeRojo =
      ColorTween(begin: Color.fromRGBO(27, 196, 35, 100), end: Colors.red);
  static final rojoVerde = ColorTween(
    begin: Colors.red,
    end: Color.fromRGBO(27, 196, 35, 100),
  );
  Citas({@required this.limites});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CitasState();
  }
}

class CitasState extends State<Citas> with AutomaticKeepAliveClientMixin{
  bool haTerminado = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Perfiles.perfilesCitas,
      child: Consumer<Perfiles>(
        builder: (BuildContext context, perfiles, Widget child) {
        
          return SafeArea(
                      child: Container(
                        
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                ),
              height: ScreenUtil().setHeight(2000),
              child: Stack(alignment: AlignmentDirectional.center, children: <
                  Widget>[
                   Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(child: CircularProgressIndicator()),
                            Text(
                              "Cargando",
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                     Container(
                      height: widget.limites.biggest.height,
                      width: widget.limites.biggest.width,
                      color: Colors.deepPurple,
                      child:
                       LayoutBuilder(
                        builder: (BuildContext context,
                            BoxConstraints espacioPerfiles) {
                          return PerfilesGenteCitas(
                              limites: espacioPerfiles);
                        },
                      ),
                    ),
              ]),
            ),
          );
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

 
 
}



  