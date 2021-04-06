import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/UtilidadesAplicacion/EstadoConexion.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flash/flash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';


class ControladorNotificacion {
  bool notificacionSinconexionMostrada=false;
   List<String> listaDeNombresEmisoresMensajesSinLeer = new List();
   List<String> listaDeMensajesSinLeer = new List();
   List<String> listaDeMensajesNotificar = new List();
  static ControladorNotificacion instancia =
      ControladorNotificacion();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();


/// Iniciamos el plugin que nos ayudará a mostrar notificaciones nativas en Android o IOS
  void inicializarNotificaciones() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification:
                BaseAplicacion.instancia.onDidReceiveLocalNotification);
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: BaseAplicacion.instancia.notificacionPulsada);
  }

  void notificacionesMensajesGrupales() async {
    const String groupKey = 'com.android.example.WORK_EMAIL';
    const String groupChannelId = 'grouped channel id';
    const String groupChannelName = 'grouped channel name';
    const String groupChannelDescription = 'grouped channel description';
// example based on https://developer.android.com/training/notify-user/group.html

    InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
        listaDeMensajesNotificar,
        contentTitle: '${Conversacion.conversaciones.cantidadMensajesNoLeidos} Mensajes',
        summaryText:
            '${Conversacion.conversaciones.cantidadMensajesNoLeidos} mensajes nuevos');
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          

            groupChannelId, groupChannelName, groupChannelDescription,
            styleInformation: inboxStyleInformation,
            groupKey: groupKey,
            setAsGroupSummary: true,
            importance:Importance.high,);
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        3,
        'Tienes mensajes nuevos',
        '${Conversacion.conversaciones.cantidadMensajesNoLeidos} mensajes sin leer',
        platformChannelSpecifics);
  }

  void mostrarNotificacionMensajes(String nombre, String mensaje,
      String idConversacion, String tipoMensaje) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, nombre, mensaje, platformChannelSpecifics,
        payload: idConversacion);
  }

  Future<dynamic> onDidReceiveLocalNotification(
      int canal, String a, String b, String c) {
    return null;
  }

  void sumarMensajeNuevoEnNotificacion(DocumentSnapshot mensaje) {
    if (mensaje.get("Tipo Mensaje") == "Texto" &&
        mensaje.get("idEmisor") != Usuario.esteUsuario.idUsuario) {
      ControladorNotificacion.instancia.listaDeMensajesSinLeer
          .add("${mensaje.get("Mensaje")}");
      ControladorNotificacion.instancia.listaDeNombresEmisoresMensajesSinLeer
          .add("${mensaje.get("Nombre emisor")}");
      ControladorNotificacion.instancia.listaDeMensajesNotificar
          .add("${mensaje.get("Nombre emisor")}  ${mensaje.get("Mensaje")}");

      controladorMensajesLeidoNotificaciones(mensaje);
    }
    if (mensaje.get("Tipo Mensaje") == "Imagen" &&
        mensaje.get("idEmisor") != Usuario.esteUsuario.idUsuario) {
      ControladorNotificacion.instancia.listaDeMensajesSinLeer
          .add("${mensaje.get("Mensaje")}");
      ControladorNotificacion.instancia.listaDeNombresEmisoresMensajesSinLeer
          .add("${mensaje.get("Nombre emisor")}");
      ControladorNotificacion.instancia.listaDeMensajesNotificar
          .add("${mensaje.get("Nombre emisor")}  te ha enviado una imagen");

      controladorMensajesLeidoNotificaciones(mensaje);
    }
    if (mensaje.get("Tipo Mensaje") == "Gif" &&
        mensaje.get("idEmisor") != Usuario.esteUsuario.idUsuario) {
      ControladorNotificacion.instancia.listaDeMensajesSinLeer
          .add("${mensaje.get("Mensaje")}");
      ControladorNotificacion.instancia.listaDeNombresEmisoresMensajesSinLeer
          .add("${mensaje.get("Nombre emisor")}");
      ControladorNotificacion.instancia.listaDeMensajesNotificar
          .add("${mensaje.get("Nombre emisor")}  te ha enviado un Gif");

      controladorMensajesLeidoNotificaciones(mensaje);
    }
    
  }

  void controladorMensajesLeidoNotificaciones(DocumentSnapshot documetno) {
    for (int i = 0;
        i < ControladorNotificacion.instancia.listaDeMensajesSinLeer.length;
        i++) {
      for (int a = 0;
          a < Conversacion.conversaciones.listaDeConversaciones.length;
          a++) {
        Conversacion conversacionTemp =
            Conversacion.conversaciones.listaDeConversaciones[a];
        if (conversacionTemp.ventanaChat.listadeMensajes != null) {
          for (int c = 0;
              c < conversacionTemp.ventanaChat.listadeMensajes.length;
              c++) {

             
            if (conversacionTemp.ventanaChat.listadeMensajes[c].mensaje ==
                    ControladorNotificacion.instancia.listaDeMensajesSinLeer[i] &&
                conversacionTemp
                    .ventanaChat.listadeMensajes[c].mensajeLeidoRemitente &&
                conversacionTemp.ventanaChat.listadeMensajes[c].idEmisor !=
                    Usuario.esteUsuario.idUsuario) {
              ControladorNotificacion.instancia.listaDeMensajesSinLeer.removeAt(i);
              ControladorNotificacion.instancia.listaDeNombresEmisoresMensajesSinLeer
                  .removeAt(i);
              ControladorNotificacion.instancia.listaDeMensajesNotificar.removeAt(i);
            }
          }
        }
      }
    }
    Conversacion.conversaciones.cantidadMensajesNoLeidos =
        ControladorNotificacion.instancia.listaDeMensajesNotificar.length;
    if (BaseAplicacion.notificadorEstadoAplicacion != null) {
      if (BaseAplicacion.notificadorEstadoAplicacion.index == 2) {
        ControladorNotificacion.instancia
            .notificacionesMensajesGrupales();
      } else {
        if(Conversacion.conversaciones.conversacionAbierta!= documetno.get("idConversacion")){
              ControladorNotificacion.mostrarNotificacionMensajeAplicaionAbierta(
          BaseAplicacion.claveBase.currentContext,
          documetno.get("Nombre emisor"),
       
          documetno.get("Tipo Mensaje")=="Texto"?documetno.get("Mensaje"):documetno.get("Tipo Mensaje")=="Audio"?"Te ha enviado un mensaje de voz":documetno.get("Tipo Mensaje")=="Imagen"?"Te ha enviado una imagen":"Te ha enviado un Gif"
        );

        }
    
      }
    } else {

      if(Conversacion.conversaciones.conversacionAbierta!= documetno.get("idConversacion")){
 ControladorNotificacion.mostrarNotificacionMensajeAplicaionAbierta(
        BaseAplicacion.claveBase.currentContext,
        documetno.get("Nombre emisor"),
          documetno.get("Tipo Mensaje")=="Texto"?documetno.get("Mensaje"):documetno.get("Tipo Mensaje")=="Audio"?"Te ha enviado un mensaje de voz":documetno.get("Tipo Mensaje")=="Imagen"?"Te ha enviado una imagen":"Te ha enviado un Gif"
      );
      }
     
    }
  }





  void mostrarNotificacionNuevaConversacion(String nombre) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, "Nueva conversacion creada", "Ya puedes chatear con $nombre", platformChannelSpecifics,
       );
  }

    void mostrarNotificacionNuevaSolicitud() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, "Solicitud de chat", "Tienes una solicitud de chat nueva", platformChannelSpecifics,
       );
  }

void mostrarNotificacionVerificacion() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, "Tu perfil ha sido verifiicado", "Has ganado 2500 creditos", platformChannelSpecifics,
       ).then((val){

         Usuario.esteUsuario.databaseReference.collection("usuarios").doc(Usuario.esteUsuario.idUsuario).update({"verificado.verificacionNotificada":true});
       });
  }



    void controladorNotificacionVerificacion() {
  
  
  }

  static void mostrarNotificacionMensajeAplicaionAbierta(
      BuildContext context, String emisorMensaje, String mensaje) {
      showFlash(
    duration: Duration(seconds: 2),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
   alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(5)),
      borderColor: Colors.white,

      backgroundColor: Colors.deepPurple,
      margin: EdgeInsets.only(bottom:150.h),

      child: Container(
        width: 1000.w,
        height: 150.h,
        
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                Flexible(
               flex: 2,
               fit:FlexFit.tight,
               child: Icon(Icons.chat_bubble_outline,color:Colors.white)),
              Flexible(
                fit: FlexFit.tight,
                flex:10,
                child: Container(
                   width: 300.w,
                        height: 100.h,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$emisorMensaje",style: GoogleFonts.lato(color:Colors.white,fontWeight: FontWeight.bold) ,overflow: TextOverflow.ellipsis,),
                      Text("$mensaje",style: GoogleFonts.lato(color:Colors.white),overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                      
                      softWrap: false,
                      ),
                    ],
                  ),
                )),
           
            ],
          ),
        ),
      ),);
  });
  }
  static void mostrarNotificacionEsperandoRespuestaRecompensa(BuildContext context){
  

  showFlash(
    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
      alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(10)),
      backgroundColor: Colors.deepPurple,

      child: Container(
        width: ScreenUtil().setWidth(500),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Espere...",style: GoogleFonts.lato(fontSize: 55.sp,color:Colors.white),),
              CircularProgressIndicator()
            ],
          ),
        ),
      ),);
  });

}

 void mostrarNotificacionCargaConversacionDebeEsperar(BuildContext context){
  

  showFlash(
    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
      alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(10)),
      backgroundColor: Colors.deepPurple,

      child: Container(
        width: ScreenUtil().setWidth(500),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Solo puede cargar una conversacion al mismo tiempo",style: GoogleFonts.lato(fontSize: 55.sp,color:Colors.white),),
              CircularProgressIndicator()
            ],
          ),
        ),
      ),);
  });

}


 void mostrarProcesoConexion(BuildContext context){
   
  

  showFlash(
    duration:EstadoConexionInternet.estadoConexion.conexion==EstadoConexion.conectado? Duration(seconds: 3):null,
    context: context,builder: (context,controller){
      notificacionSinconexionMostrada=true;
    return StatefulBuilder(builder: (BuildContext context,StateSetter setState){
      return     
    ChangeNotifierProvider.value(
      value: Usuario.esteUsuario,

   child:   Consumer<Usuario>(
        builder: (context, myType, child) {
          return    Flash.dialog(
        
        controller: controller,
        alignment: Alignment.topCenter,
   
        borderRadius:  BorderRadius.all(Radius.circular(1)),
        backgroundColor: Colors.deepPurple,

        child: Container(
          width: ScreenUtil.screenWidth,
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(1))),


          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: EstadoConexionInternet.estadoConexion.conexion!=EstadoConexion.conectado?  Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Conectando con el servidor...",style: GoogleFonts.lato(fontSize: 55.sp,color:Colors.white),),
                CircularProgressIndicator()
              ],
            ):Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Conectado correctamente",style: GoogleFonts.lato(fontSize: 40.sp,color:Colors.white),),
               ElevatedButton(
                 style: ButtonStyle(backgroundColor:  MaterialStateProperty.all(Colors.deepPurple[900])),
                 onPressed: (){
                   notificacionSinconexionMostrada=false;
                   controller.dismiss();}, child: Text("Entendido"))
              ],
            )
          ),
        ),)      ;
        },
      )
  
    );
    });
    
    
    
    
    
    

  });

}








  static void mostrarNotificacionRespuestaRecompensaObtenida(BuildContext context){
  

  showFlash(
    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
      alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(10)),
      backgroundColor: Colors.deepPurple,
      margin: EdgeInsets.only(top:10),

      child: Container(
        width: ScreenUtil().setWidth(900),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Has ganado 500 Creditos",style: GoogleFonts.lato(fontSize: 55.sp,color:Colors.white),),
             Icon(Icons.check_circle,color:Colors.green)
            ],
          ),
        ),
      ),);
  });

}
  static void notificacionCuentaCreada(BuildContext context) {
      showFlash(
    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
      alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(10)),
      borderColor: Colors.white,

      backgroundColor: Colors.green[700],
      margin: EdgeInsets.only(bottom:150.h),

      child: Container(
        width: ScreenUtil().setWidth(900),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Cuenta creada",style: GoogleFonts.lato(fontSize: 55.sp,color:Colors.white),),
             Icon(Icons.check_circle_outline,color:Colors.white)
            ],
          ),
        ),
      ),);
  });
  }


  static void notificacionErrorCrearCuenta(BuildContext context) {
      showFlash(
    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
      alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(10)),
      borderColor: Colors.white,

      backgroundColor: Colors.red,
      margin: EdgeInsets.only(bottom:150.h),

      child: Container(
        width: ScreenUtil().setWidth(900),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Error al crear la cuenta",style: GoogleFonts.lato(fontSize: 55.sp,color:Colors.white),),
             Icon(Icons.error,color:Colors.white)
            ],
          ),
        ),
      ),);
  });
  }


  static void notificacionErrorConexion(BuildContext context) {
      showFlash(
    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
      alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(10)),
      borderColor: Colors.white,

      backgroundColor: Colors.red,
      margin: EdgeInsets.only(bottom:150.h),

      child: Container(
        width: ScreenUtil().setWidth(900),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("No estás conectado a internet",style: GoogleFonts.lato(fontSize: 55.sp,color:Colors.white),),
             Icon(Icons.error,color:Colors.white)
            ],
          ),
        ),
      ),);
  });
  }


  static void notificacionPermisosNecesariosVideoLLamada(BuildContext context) {
      showFlash(
    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
      alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(10)),
      borderColor: Colors.white,

      backgroundColor: Colors.red,
      margin: EdgeInsets.only(bottom:150.h),

      child: Container(
        width: ScreenUtil().setWidth(900),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Hotty necesita usar tu camara y tu microfono para que iniciar la videollamada",style: GoogleFonts.lato(fontSize: 55.sp,color:Colors.white),),
             Icon(Icons.error,color:Colors.white)
            ],
          ),
        ),
      ),);
  });
  }



  static void notificacionCargandoMensajesAdicionales(BuildContext context) {
      showFlash(

    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return StatefulBuilder(builder: (BuildContext context, setState){
      return      Flash.bar(
      controller: controller,
      position: FlashPosition.top,
      margin: EdgeInsets.only(top:kToolbarHeight*1.2 ),
      borderRadius:  BorderRadius.all(Radius.circular(30)),
      borderColor: Colors.white,
 

      backgroundColor: Colors.deepPurple,
     

      child: Container(
        width: ScreenUtil().setWidth(600),
        height: 100.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Cargando mensajes" ,style: GoogleFonts.lato(color:Colors.white),),
              LoadingIndicator(indicatorType: Indicator.ballScaleMultiple, color: Colors.white,),])
          
            ,
          
        ),
      ),);
    });
    
    

  });
  }










     void notificacionConversacionCreada(BuildContext context,String nombre) {
      showFlash(
    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
   alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(10)),
      borderColor: Colors.white,

      backgroundColor: Colors.deepPurple,
      margin: EdgeInsets.only(bottom:150.h),

      child: Container(
        width: ScreenUtil.screenWidth,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                Flexible(
               flex: 2,
               fit:FlexFit.tight,
               child: Icon(LineAwesomeIcons.user_plus,color:Colors.white)),
              Flexible(
                fit: FlexFit.tight,
                flex:10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nueva conversacion",style: GoogleFonts.lato(color:Colors.white,fontWeight: FontWeight.bold),),
                    Text("Ya puedes chatear con $nombre",style: GoogleFonts.lato(color:Colors.white),),
                  ],
                )),
           
            ],
          ),
        ),
      ),);
  });
  }


       void notificacionMensa(BuildContext context,String nombre) {
      showFlash(
    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
   alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(10)),
      borderColor: Colors.white,

      backgroundColor: Colors.deepPurple,
      margin: EdgeInsets.only(bottom:150.h),

      child: Container(
        width: ScreenUtil.screenWidth,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                Flexible(
               flex: 2,
               fit:FlexFit.tight,
               child: Icon(LineAwesomeIcons.user_plus,color:Colors.white)),
              Flexible(
                fit: FlexFit.tight,
                flex:10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nueva conversacion",style: GoogleFonts.lato(color:Colors.white,fontWeight: FontWeight.bold),),
                    Text("Ya puedes chatear con $nombre",style: GoogleFonts.lato(color:Colors.white),),
                  ],
                )),
           
            ],
          ),
        ),
      ),);
  });
  }

  
     void notificacionSolicitudAplicacionAbierta(BuildContext context,) {
      showFlash(
    duration: Duration(seconds: 3),
    context: context,builder: (context,controller){
    return Flash.dialog(
      controller: controller,
   alignment: Alignment.topCenter,
      borderRadius:  BorderRadius.all(Radius.circular(10)),
      borderColor: Colors.white,

      backgroundColor: Colors.deepPurple,
      margin: EdgeInsets.only(bottom:150.h),

      child: Container(
        width: ScreenUtil.screenWidth,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10))),


        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                Flexible(
               flex: 2,
               fit:FlexFit.tight,
               child: Icon(LineAwesomeIcons.user_plus,color:Colors.white)),
              Flexible(
                fit: FlexFit.tight,
                flex:10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nueva solicitud",style: GoogleFonts.lato(color:Colors.white,fontWeight: FontWeight.bold),),
                    Text("Tienes una nueva solicitud de chat",style: GoogleFonts.lato(color:Colors.white),),
                  ],
                )),
           
            ],
          ),
        ),
      ),);
  });
  }













}



