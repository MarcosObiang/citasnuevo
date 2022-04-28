import 'package:citasnuevo/core/globalData.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
/// Funcion de alto nivel ecargada de procesar los mensajes siempre y cuando la aplicacion pase a segundo plano o haya sido terminada
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBm3rwlrV7qshSIgASobNLoeb5RgdwwSMI",
          appId: "1:151798284057:android:2f9b0eec10be91eb5e8f88",
          messagingSenderId: "",
          projectId: "hotty-189c7"));
  if (message.data["tipoNotificacion"] == "valoracion") {
 SystemNotifications.instance
        .showReactionNotification();
  }


  if (message.data["tipoNotificacion"] == "conversacion") {
     SystemNotifications.instance
        .showNewChatNotifications();
  }

 /* if (message.data["tipoNotificacion"] == "mensaje") {

    ControladorNotificacionesPrincipales.instancia.mostrarNotificacionMensajes(
        "identificadorConversacion", "emisorMensaje", "tipoMensaje", "idUsuario");
  }*/

  if (message.data["tipoNotificacion"] == "recompensa") {
     SystemNotifications.instance
        .showRewardNotification();

        

        
  }

  /*if(message.data["tipoNotificacion"]=="tokenRevocado"){
    ControladorInicioSesion.instancia.cerrarSesion();
  }*/

}
class NotificationService {
  static late String? notificationToken;
  static NotificationService instance = new NotificationService();

  NotificationService() {
    startBackgroundNotificationHandler();
  }
  HttpsCallable _changeToken =
      FirebaseFunctions.instance.httpsCallable("cambioToken");
  HttpsCallable _establishToken =
      FirebaseFunctions.instance.httpsCallable("establecerToken");
  HttpsCallable _revokeToken =
      FirebaseFunctions.instance.httpsCallable("eliminarToken");

  void startBackgroundNotificationHandler() async {
    notificationToken = await FirebaseMessaging.instance.getToken();
        iniciarEscuchadorSegudoPlano();

  }
   void iniciarEscuchadorSegudoPlano() async {
    notificationToken = await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance.onTokenRefresh
        .asBroadcastStream()
        .listen((event) async {
          
          
      changeUserToken(event);
    });
  }

  @protected
  void changeUserToken(String token) async {
    await _establishToken.call({
      "idUsuario":
          GlobalDataContainer.userId ?? FirebaseAuth.instance.currentUser!.uid,
      "token": token
    }).catchError((onError) {});
  }

  @protected
  void establishUserToken() async {
    try {
      notificationToken = await FirebaseMessaging.instance.getToken();
      if (notificationToken != null) {
        await _establishToken.call({
          "idUsuario": GlobalDataContainer.userId ??
              FirebaseAuth.instance.currentUser!.uid,
          "token": notificationToken
        }).catchError((onError) {});
      }
    } catch (e) {
      throw Exception([e.toString()]);
    }
  }

  void revokeToken() async {
    _revokeToken.call({
      "idUsuario":
          GlobalDataContainer.userId ?? FirebaseAuth.instance.currentUser!.uid,
    });
    FirebaseMessaging.instance.deleteToken();
  }
}


class SystemNotifications{
  static SystemNotifications instance= new SystemNotifications();
   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @protected
  void showReactionNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      3,
      "Nueva valoración",
           "Tienes valoraciones sin revelar",
      platformChannelSpecifics,payload:"valoraciones"
    );
  }

    @protected
  void showNewChatNotifications() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      1,
      "Nueva conversacion",
      "Se ha añadido un nuevo chat a tus conversaciones",
      platformChannelSpecifics,payload: "conversaciones"
    );
  }
    void mostrarNotificacionVerificacion() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(
      0,
      "Tu perfil ha sido verifiicado",
      "Has ganado 2500 creditos",
      platformChannelSpecifics,
    );
      
  }

    @protected
  void showRewardNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      4,
      "Recompesa lista",
      "Pulsa para reclamar tu recompensa",
      platformChannelSpecifics,payload: "recompensas"
    );
  }


}