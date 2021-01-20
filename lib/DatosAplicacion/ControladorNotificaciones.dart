import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class ControladorNotificacion {
   List<String> listaDeNombresEmisoresMensajesSinLeer = new List();
   List<String> listaDeMensajesSinLeer = new List();
   List<String> listaDeMensajesNotificar = new List();
  static ControladorNotificacion instancia =
      ControladorNotificacion();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void inicializarNotificaciones() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
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
    if (mensaje.get("Tipo Mensaje") == "Audio" &&
        mensaje.get("idEmisor") != Usuario.esteUsuario.idUsuario) {
      ControladorNotificacion.instancia.listaDeMensajesSinLeer
          .add("${mensaje.get("Mensaje")}");
      ControladorNotificacion.instancia.listaDeNombresEmisoresMensajesSinLeer
          .add("${mensaje.get("Nombre emisor")}");
      ControladorNotificacion.instancia.listaDeMensajesNotificar
          .add("${mensaje.get("Nombre emisor")}  te ha enviado mensaje de voz");

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
        ControladorNotificacion.mostrarNotificacionMensajeAplicaionAbierta(
          BaseAplicacion.claveBase.currentContext,
          documetno.get("Nombre emisor"),
       
          documetno.get("Tipo Mensaje")=="Texto"?documetno.get("Mensaje"):documetno.get("Tipo Mensaje")=="Audio"?"Te ha enviado un mensaje de voz":documetno.get("Tipo Mensaje")=="Imagen"?"Te ha enviado una imagen":"Te ha enviado un Gif"
        );
      }
    } else {
      ControladorNotificacion.mostrarNotificacionMensajeAplicaionAbierta(
        BaseAplicacion.claveBase.currentContext,
        documetno.get("Nombre emisor"),
          documetno.get("Tipo Mensaje")=="Texto"?documetno.get("Mensaje"):documetno.get("Tipo Mensaje")=="Audio"?"Te ha enviado un mensaje de voz":documetno.get("Tipo Mensaje")=="Imagen"?"Te ha enviado una imagen":"Te ha enviado un Gif"
      );
    }
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
   /* Flushbar(
      message: mensaje,
      duration: Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.purple[900],
      forwardAnimationCurve: Curves.linear,
      title: emisorMensaje,
      icon: Icon(
        Icons.chat,
      ),
      reverseAnimationCurve: Curves.linear,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      borderRadius: 10,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
    )..show(context);*/
  }
}
