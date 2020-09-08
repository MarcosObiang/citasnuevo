import 'dart:ui';

import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Valoraciones.dart';
import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import 'live_screen_elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';

class live extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return live_screen().build(context);
  }
}

class live_screen extends State<start> with SingleTickerProviderStateMixin {
  TabController controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
        value: Valoraciones.Puntuaciones, child: live_screen_widget());
  }

  Widget live_screen_widget() {
    return DefaultTabController(
        length: 2,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: new ThemeData(
              highlightColor: Colors.deepPurple,
              tabBarTheme: TabBarTheme(
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.black87,
                  labelStyle: TextStyle(
                      fontSize:
                          ScreenUtil().setSp(60, allowFontScalingSelf: true),
                      fontWeight: FontWeight.bold)),
              primaryColor: Colors.white,
              accentColor: Colors.deepPurple),
          home: Scaffold(
              backgroundColor: Colors.white,
              body: Consumer<Valoraciones>(
                builder: (BuildContext context, valoraciones, Widget child) {
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(child: list_live()),
                      ],
                    ),
                  );
                },
              )),
        ));
  }

  TabBar getTabBar() {
    return TabBar(
      isScrollable: false,
      tabs: <Widget>[
        Tab(
          text: "Le Gustas",
        ),
        Tab(
          text: "Invitacion",
        ),
      ],
      controller: controller,
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
      children: <Widget>[
        list_live(),
        InvitacionesEventos(),
      ],
      controller: controller,
    );
  }
}

class list_live extends StatefulWidget {
  static final GlobalKey<AnimatedListState> llaveListaValoraciones=GlobalKey();
  @override
  _list_liveState createState() => _list_liveState();
}

class _list_liveState extends State<list_live> {
  Widget barraExito() {
    return ChangeNotifierProvider.value(
        value: Valoraciones.instanciar,
        child: Consumer<Valoraciones>(
          builder: (context, myType, child) {
            return Container(
              decoration: BoxDecoration(),
              height: ScreenUtil().setHeight(290),
              child: Container(
                  child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              flex: 5,
                              fit: FlexFit.tight,
                              child: Text(
                                "Esta Semana",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40),
                                    fontWeight: FontWeight.bold),
                              )),
                          Flexible(
                              fit: FlexFit.tight,
                              flex: 9,
                              child: LayoutBuilder(builder:
                                  (BuildContext context,
                                      BoxConstraints altura) {
                                return LinearPercentIndicator(
                                  lineHeight: ScreenUtil().setHeight(80),
                                  backgroundColor: Colors.grey,
                                  linearStrokeCap: LinearStrokeCap.roundAll,
                                  animation: true,
                                  animationDuration: 300,
                                  animateFromLastPercent: true,
                                  percent: Valoraciones.mediaUsuario / 10,
                                  progressColor: Colors.blue,
                                  center: Text(
                                    Valoraciones.mediaUsuario
                                        .toStringAsFixed(2),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(40),
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              })),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 2,
                            fit: FlexFit.loose,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Visitas   ",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${Valoraciones.visitasTotales}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: ScreenUtil().setSp(40),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            flex: 4,
                            child: FlatButton(
                              onPressed: () => {},
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Aumentar visitas"),
                                  Icon(LineAwesomeIcons.rocket),
                                ],
                              ),
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        barraExito(),
        Expanded(
          child: Container(
            child: AnimatedList(
              key:list_live.llaveListaValoraciones,
              initialItemCount: Valoraciones.listaDeValoraciones.length,

              itemBuilder: (BuildContext context, int indice, animation) {
                return buildSlideTransition(context, animation, indice, Valoraciones.listaDeValoraciones[indice]);
              },
            ),
          ),
        ),
      ],
    );
  }

  SizeTransition buildSlideTransition(BuildContext context,Animation animation,int indice,Valoraciones valoracion) {
    return SizeTransition(
      sizeFactor: animation,

  
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          height: ScreenUtil().setHeight(500),
          decoration: BoxDecoration(
        
            boxShadow: [BoxShadow(color: Colors.grey,blurRadius:10)],
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.white),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 13,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                    image: NetworkImage(valoracion.imagenEmisor),
                                    fit: BoxFit.cover)),
                          ),
                        ),
                        Flexible(
                          flex: 5,
                          fit: FlexFit.tight,
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Container(
                                        child: valoracion.nombreEmisor != null
                                            ? Text(
                                                "${valoracion.nombreEmisor}",
                                                style: TextStyle(
                                                    fontSize: ScreenUtil()
                                                        .setSp(40),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : Text(" ")),
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 5,
                                    child: Container(
                                        child: valoracion.mensaje == null ||
                                                valoracion.mensaje == "null"
                                            ? Text("")
                                            : Text(
                                                valoracion.mensaje,
                                                style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                ),
                                              )),
                                  ),
                                  Container(
                                    height: ScreenUtil().setHeight(50),
                                    child: Center(
                                      child: LinearPercentIndicator(
                                        linearStrokeCap: LinearStrokeCap.butt,
                                        //  progressColor: Colors.deepPurple,
                                        percent: valoracion.valoracion / 10,
                                        animationDuration: 300,
                                        lineHeight:
                                            ScreenUtil().setHeight(60),
                                        linearGradient: LinearGradient(
                                            colors: [
                                              Colors.pink,
                                              Colors.pinkAccent[100]
                                            ]),
                                        center: Text(
                                          "${(valoracion.valoracion).toStringAsFixed(1)}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenUtil().setSp(40,
                                                  allowFontScalingSelf: true),
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 4,
                  fit: FlexFit.tight,
                  child: LayoutBuilder(builder: (BuildContext contex,BoxConstraints limites){
                    return  Container(
                      decoration: BoxDecoration(

                      ),
                      height: limites.maxHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: Container(
                              height: limites.maxHeight,
                              decoration: BoxDecoration(
                                color: Colors.green
                            

                              ),
                              
                              child: FlatButton(
                                
                                  onPressed: ()  {
                                     aceptarSolicitud(indice,valoracion.mensaje, valoracion.nombreEmisor, valoracion.imagenEmisor, valoracion.idEmisor, valoracion.idValoracion);


                                   
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    
                                    children: [
                                    Text("Me gusta",  style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenUtil().setSp(50,
                                                  allowFontScalingSelf: true),
                                              color: Colors.white),),
                                    Icon(LineAwesomeIcons.heart_o,color: Colors.white,)
                                  ])),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: Container(
                               decoration: BoxDecoration(
                                 color: Colors.red
                              
                              ),
                              height: limites.maxHeight,
                               
                              child: FlatButton(
                                 
                                  onPressed: ()  {

                                    eliimnarSolicitud(indice,Valoraciones.listaDeValoraciones[indice].idValoracion);
                                  },
                                  child: Row(
                                    
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                    Text("Eliminar",style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenUtil().setSp(50,
                                                  allowFontScalingSelf: true),
                                              color: Colors.white),),
                                    Icon(Icons.close,color: Colors.white,)
                                  ])),
                            ),
                          )
                        ],
                      ),
                    );
                  },)
                                   
                  ),
                
              ],
            ),
          )),
    ),
  );


 
  }

 void eliimnarSolicitud(int indice,String id){
   Valoraciones valoracionQuitada=Valoraciones.listaDeValoraciones.removeAt(indice);
AnimatedListRemovedItemBuilder builder=(context,animation){
  return buildSlideTransition(context, animation, indice, valoracionQuitada);

};
list_live.llaveListaValoraciones.currentState.removeItem(indice, builder);

Solicitud.instancia.rechazarSolicitud(id);

 


 }
 void aceptarSolicitud(int indice,String mensaje,String nombreEmisor,String imagenEmisor,String idEmisor,String idValoracion){
   Valoraciones valoracionAceptada=Valoraciones.listaDeValoraciones.removeAt(indice);
   AnimatedListRemovedItemBuilder builder=(context,animation){
  return buildSlideTransition(context, animation, indice, valoracionAceptada);

};
list_live.llaveListaValoraciones.currentState.removeItem(indice, builder);



 Solicitud.instancia.aceptarSolicitud(mensaje, nombreEmisor,imagenEmisor,idEmisor,idValoracion);



 }



}

class InvitacionesEventos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(body: Container());
  }
}
