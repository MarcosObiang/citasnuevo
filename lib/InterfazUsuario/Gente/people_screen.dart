import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/Conversacion.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';
import 'package:citasnuevo/DatosAplicacion/actividad.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'people_screen_elements.dart';

class people extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1440, height: 3120, allowFontScaling: true);
    // TODO: implement build
    return people_screen().build(context);
  }
}

class people_screen extends State<start> with SingleTickerProviderStateMixin {
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
    return people(context);
  }

  Widget people(BuildContext context) {
    return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: DefaultTabController(
            length: 2,
            child: Material(
            
                  
              child: Column(
                children: <Widget>[
                  Flexible(
                     flex: 2,
                    fit: FlexFit.tight,
                                      child: Container(
                     
                      child: getTabBar()),
                  ),
                  Flexible(
                    flex: 30,
                    fit: FlexFit.tight,
                                      child: Container(
                    
                      child: getTabBarView()),
                  ),
                ],
              )

                  //***************************************************************************************Barra Baja

                  
            )),
          ),
    );
  }

  TabBar getTabBar() {
    return TabBar(
      tabs: <Widget>[
        Tab(
          text: "Conversaciones",
        ),
        Tab(
          text: "Planes",
        ),

      ],
      controller: controller,
    );
  }

  TabBarView getTabBarView() {
    return TabBarView(
      children: <Widget>[list_date(), InvitacionesEventos()],
      controller: controller,
    );
  }
}

class grupo_date extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Column(
        children: <Widget>[],
      ),
    );
  }
}

class grupo_friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Column(
        children: <Widget>[],
      ),
    );
  }
}

class list_date extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChangeNotifierProvider.value(
      value: Conversacion.conversaciones,
      child:  Container(
          
          child: Consumer<Conversacion>(
          builder: (BuildContext context, conversacion, Widget child) {
            print("cambio");
            return Stack(
                        children:<Widget>[ ListView.builder(
           itemCount: conversacion.listaDeConversaciones.length,
                itemBuilder: (BuildContext context,indice){
               return conversacion.listaDeConversaciones[indice].ventanaChat;
                },

              ),]
            );
          },
        )),
      
    );
  }
}

class InvitacionesEventos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder
    
    ( itemCount:EventosPropios.listaEventosPropios.length ,

    itemBuilder: (BuildContext context,indice){
      return Padding(
        padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
        child: EventosPropios.listaEventosPropios[indice].tarjetaEvento,
      );
    },



     );
  }
}


