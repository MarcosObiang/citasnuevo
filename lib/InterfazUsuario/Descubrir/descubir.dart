import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:citasnuevo/DatosAplicacion/Directo.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';
import 'package:citasnuevo/InterfazUsuario/Actividades/pantalla_actividades_elements.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PantallaDirecto extends StatefulWidget {
  static bool permisoAlmacenamiento;
  static bool permisoCamara;
  static bool permisoMicrofono;
  static final clavePantallaDirecto = GlobalKey();
  @override
  _PantallaDirectoState createState() => _PantallaDirectoState();
}

class _PantallaDirectoState extends State<PantallaDirecto>
    with TickerProviderStateMixin {
  TextEditingController controladorTextoBio = new TextEditingController();
  TabController controller;
  String textoPantalla = "";
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 4, vsync: this);
    controller.addListener(() {
      if (controller.indexIsChanging) {
        acualizadorTextoPantalla(controller.index);
      }
      acualizadorTextoPantalla(controller.index);
    });
  }

  void acualizadorTextoPantalla(int index) {
    if (index == 0) {
      textoPantalla = "Chat";
      Usuario.esteUsuario.notifyListeners();
    }
    if (index == 1) {
      textoPantalla = "Historias";
      Usuario.esteUsuario.notifyListeners();
    }
    if (index == 2) {
      textoPantalla = "Video";
      Usuario.esteUsuario.notifyListeners();
    }

    if (index == 3) {
      textoPantalla = "Grupos";
      Usuario.esteUsuario.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        key: PantallaDirecto.clavePantallaDirecto,
        value: Usuario.esteUsuario,
        child: Consumer<Usuario>(
          builder: (BuildContext context, Usuario user, Widget child) {
            return Container(
              color: Colors.white,
              child: SafeArea(
                child: Material(
                  child: Container(
                    color: Colors.red,
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Container(
                            color: Colors.red,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30),
                                        child: Text(
                                          "Historias",
                                          style: TextStyle(
                                              fontSize: ScreenUtil()
                                                  .setSp(90),
                                              fontWeight:
                                                  FontWeight.bold,color: Colors.black),
                                        ),
                                      ),
                                    ),
                                   configuradorHistoria()
                                 
                                  ],
                                ),
                            
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 9,
                          fit: FlexFit.tight,
                          child: Container(child:      VentanaDirectoHistorias()),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }



  Padding configuradorHistoria() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                    child: FlatButton(
                  


                  onPressed: ()async  { 
                    await Permission.storage.status.then((statusPermisoAlmacenamiento) async{
                   if (statusPermisoAlmacenamiento.isGranted){
                     PantallaDirecto.permisoAlmacenamiento=true;
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CreadorDeHistorias()));


                   }
                 if(!statusPermisoAlmacenamiento.isGranted){
                  await Permission.storage.request();
                 }
                    });
                    
                    
                   },
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.movie_filter),
                      Text("Nueva Historia")
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }






  TabBar tabla() {
    return TabBar(
      unselectedLabelColor: Colors.black,
      indicatorColor: Colors.purple,
      tabs: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Tab(
                text: "Chat",
              ),
              Icon(Icons.chat_bubble_outline)
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Tab(
                text: "Historia",
              ),
              Icon(Icons.video_label)
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Tab(
                text: "Video",
              ),
              Icon(Icons.videocam)
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Tab(
                text: "Grupos",
              ),
              Icon(Icons.people_outline)
            ],
          ),
        ),
      ],
      controller: controller,
    );
  }

  TabBarView widgetMontado() {
    return TabBarView(
      dragStartBehavior: DragStartBehavior.start,
      children: <Widget>[
        
        VentanaDirectoHistorias(),
       
      ],
      controller: controller,
    );
  }
}



class VentanaDirectoHistorias extends StatefulWidget {
  @override
  _VentanaDirectoHistoriasState createState() =>
      _VentanaDirectoHistoriasState();
}

class _VentanaDirectoHistoriasState extends State<VentanaDirectoHistorias> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        height: ScreenUtil().setHeight(500),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView(
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio:
                    ScreenUtil.defaultWidth / ScreenUtil.defaultHeight,
                mainAxisSpacing: ScreenUtil().setHeight(30),
                crossAxisSpacing: ScreenUtil().setWidth(30)),
            children: HistoriasDirecto.ventanasHistoriasDirecto,
          ),
        ));
  }
}

class HistoriaUsuarioDirecto extends StatelessWidget {
  String idHistoria;
  String imagenPrimeraHistoria;
  String nombreUsuario;
  String imagenPerfilUsuario;
  HistoriaUsuarioDirecto(
      {@required this.idHistoria,
      @required this.imagenPerfilUsuario,
      @required this.imagenPrimeraHistoria,
      @required this.nombreUsuario});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await HistoriasDirecto.buscarPantallaHistorias(idHistoria)
            .then((value) => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => VisorEnListaHistorias(
                          indice: value,
                        ))));
      },
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black,
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imagenPrimeraHistoria),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: ScreenUtil().setHeight(150),
                        width: ScreenUtil().setWidth(150),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                          image: DecorationImage(
                              image: NetworkImage(imagenPerfilUsuario),
                              fit: BoxFit.fill),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            color: Colors.black38,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                nombreUsuario,
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}

class VisorEnListaHistorias extends StatefulWidget {
  int indice;
  int posicionEnLista;
  static BuildContext context;
  static SwiperController controlador = new SwiperController();
  VisorEnListaHistorias({@required this.indice});
  // ignore: missing_return
  static int siguienteHistoriaDirecto() {
    int index;

    if (HistoriasDirecto.pantallaHistoriaDirecto.length >=
        (controlador.index + 1)) {
      controlador.move(controlador.index + 1);
      index = 1;
    }
    if (HistoriasDirecto.pantallaHistoriaDirecto.length <
        (controlador.index + 1)) {
      index = 0;
    }
    return index;
  }

  @override
  _VisorEnListaHistoriasState createState() => _VisorEnListaHistoriasState();
}

class _VisorEnListaHistoriasState extends State<VisorEnListaHistorias> {
  @override
  Widget build(BuildContext context) {
    VisorEnListaHistorias.controlador.index = widget.indice;
    print(widget.indice);
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Material(
            color: Colors.black,
            child: LayoutBuilder(builder: (BuildContext context, limites) {
              return Swiper(
                itemCount: HistoriasDirecto.pantallaHistoriaDirecto.length,
                scrollDirection: Axis.horizontal,
                loop: false,
                curve: Curves.easeInOutSine,
                index: VisorEnListaHistorias.controlador.index,
                onIndexChanged: (valor) {},
                itemHeight: limites.maxHeight,
                itemWidth: limites.maxWidth,
                controller: VisorEnListaHistorias.controlador,
                itemBuilder: (BuildContext context, int posiciones) {
                  return Container(
                      height: limites.maxHeight,
                      width: limites.maxWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: HistoriasDirecto
                            .pantallaHistoriaDirecto[posiciones],
                      ));
                },
              );
            })),
      ),
    );
  }
}

