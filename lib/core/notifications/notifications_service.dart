import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../dependencies/dependencyCreator.dart';
import '../globalData.dart';

/// Funcion de alto nivel ecargada de procesar los mensajes siempre y cuando la aplicacion pase a segundo plano o haya sido terminada
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  if (message.data["notificationType"] == "reaction") {
    SystemNotifications.instance.showReactionNotification();
  }

  if (message.data["notificationType"] == "chat") {
    SystemNotifications.instance.showNewChatNotifications();
  }

  if (message.data["notificationType"] == "message") {
    SystemNotifications.instance.showMessageNotification();
  }

  if (message.data["notificationType"] == "reward") {
    SystemNotifications.instance.showRewardNotification();
  }

  /*if(message.data["tipoNotificacion"]=="tokenRevocado"){
    ControladorInicioSesion.instancia.cerrarSesion();
  }*/
}

class NotificationService {
  static late String? notificationToken;
  static NotificationService instance = new NotificationService();

  Future<void> startBackgroundNotificationHandler() async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    final notificationSettings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
    notificationToken = await FirebaseMessaging.instance.getToken();
    iniciarEscuchadorSegudoPlano();
    SystemNotifications.instance.inicializarNotificaciones();
  }

  void iniciarEscuchadorSegudoPlano() async {
    notificationToken = await FirebaseMessaging.instance.getToken();
    await changeUserToken(notificationToken as String);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance.onTokenRefresh
        .asBroadcastStream()
        .listen((event) async {
      changeUserToken(event);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  @protected
  Future<void> changeUserToken(String token) async {
   /* try {
      notificationToken = await FirebaseMessaging.instance.getToken();
      UserModel? user = Dependencies.applicationDataSource.userDataSet;
      notificationToken =
          jsonEncode({"token": notificationToken!, "platform": "android"});

      await Dependencies.applicationDataSource.realm!.writeAsync(() {
        UserModel userModel = Dependencies.applicationDataSource.realm!
            .query<UserModel>(
                r'userId == $0', [GlobalDataContainer.userId]).first;

        userModel.notificationToken = notificationToken!;
        Dependencies.applicationDataSource.realm!
            .add<UserModel>(user!, update: true);
      });
    } catch (error) {
      throw Exception("CHANGE_NOTIFICATION_TOKEN_ERROR: $error");
    }*/
  }

  @protected
  void establishUserToken() async {
    /*try {
      notificationToken = await FirebaseMessaging.instance.getToken();
      UserModel? user = Dependencies.applicationDataSource.userDataSet;
      if (user != null && notificationToken != null) {
        user.notificationToken =
            jsonEncode({"token": notificationToken!, "platform": "android"});
      }

      await Dependencies.applicationDataSource.realm!.writeAsync(() {
        Dependencies.applicationDataSource.realm!
            .add<UserModel>(user!, update: true);
      });
    } catch (error) {
      throw Exception("ESTABLISH_NOTIFICATION_TOKEN_ERROR: $error");
    }*/
  }

  void revokeToken() async {
   /* try {
     notificationToken = await FirebaseMessaging.instance.getToken();
      UserModel? user = Dependencies.applicationDataSource.userDataSet;
      if (user != null && notificationToken != null) {
        user.notificationToken =
            jsonEncode({"token": "NOT_AVAILABLE", "platform": "NOT_AVAILABLE"});
      }

      await Dependencies.applicationDataSource.realm!.writeAsync(() {
        Dependencies.applicationDataSource.realm!
            .add<UserModel>(user!, update: true);
      });
    } catch (error) {
      throw Exception("REVOKE_NOTIFICATION_TOKEN_ERROR: $error");
    }*/
  }
}

class SystemNotifications {
  static SystemNotifications instance = new SystemNotifications();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void inicializarNotificaciones() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  @protected
  void showReactionNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, "Nueva reacción",
        "Tienes reacciones sin revelar", platformChannelSpecifics,
        payload: "valoraciones");
  }

  @protected
  void showNewChatNotifications() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        1,
        "Nueva conversacion",
        "Se ha añadido un nuevo chat a tus conversaciones",
        platformChannelSpecifics,
        payload: "conversaciones");
  }

  void mostrarNotificacionVerificacion() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      2,
      "Tu perfil ha sido verifiicado",
      "Has ganado 2500 creditos",
      platformChannelSpecifics,
    );
  }

  @protected
  void showRewardNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(3, "Recompesa lista",
        "Pulsa para reclamar tu recompensa", platformChannelSpecifics,
        payload: "recompensas");
  }

  @protected
  void showMessageNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, "Mensajes", "Tienes nuevos mensajes", platformChannelSpecifics,
        payload: "recompensas");
  }
}
