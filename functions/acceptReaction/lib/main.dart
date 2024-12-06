import 'dart:convert';
import 'dart:io';
//import 'package:dio/dio.dart' as dio;

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';

/*
  'req' variable has:
    'headers' - object with request headers
    'payload' - request body data as a string
    'variables' - object with function variables

  'res' variable has:
    'send(text, status: status)' - function to return text response. Status code defaults to 200
    'json(obj, status: status)' - function to return JSON response. Status code defaults to 200
  
  If an error is thrown, a response with code 500 will be returned.
*/

Future<dynamic> main(final context) async {
  try {
    String apiKey = Platform.environment["APPWRITE_FUNCTIONS_APIKEY"]!;
    String? projectId = Platform.environment["PROJECT_ID"];

    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject(projectId as String)
        .setKey(apiKey);
    final data = context.req.bodyJson;
    Databases database = Databases(client);
    String reactionId = data["reactionId"];
    String user1Id;
    String user2Id;
    bool isAnyUserBlocked = false;
    bool sameUser = false;

    Document reactionData = await database.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "reactions",
        documentId: reactionId);
    user1Id = reactionData.data["senderId"];
    user2Id = reactionData.data["recieverId"];

    Document user1Data = await database.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        documentId: user1Id);
    Document user2Data = await database.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        documentId: user2Id);
    if (user1Id == user2Id) {
      sameUser = true;
    }
    if (user1Data.data["userBlocked"] == true ||
        user2Data.data["userBlocked"] == true) {
      isAnyUserBlocked = true;
    }

    if (isAnyUserBlocked == false && sameUser == false) {
      await database.deleteDocument(
          databaseId: "6729a8be001c8e5fa57a",
          collectionId: "reactions",
          documentId: reactionId);
      await database.deleteDocument(
          databaseId: "6729a8be001c8e5fa57a",
          collectionId: "reactionsPrivate",
          documentId: reactionId);
      await database.createDocument(
          databaseId: "6729a8be001c8e5fa57a",
          collectionId: "conversations",
          documentId: reactionData.$id,
          data: {
            "converstationCreationTimestamp":
                DateTime.now().millisecondsSinceEpoch,
            "conversationId": reactionData.$id,
            "user1Picture":
                jsonDecode(user1Data.data["userPicture1"])["imageData"],
            "user2Picture":
                jsonDecode(user2Data.data["userPicture1"])["imageData"],
            "user1Name": user1Data.data["userName"],
            "user2Name": user2Data.data["userName"],
            "user1Id": user1Data.$id,
            "user2Id": user2Data.$id,
            "user1Blocked": false,
            "user2Blocked": false,
            "user1NotificationToken": user1Data.data["notificationToken"],
            "user2NotificationToken": user2Data.data["notificationToken"],
            "isBlindDate": false
          },
          permissions: [
            Permission.read(Role.user(user1Id)),
            Permission.read(Role.user(user2Id))
          ]);
      /*   await sendPushNotification(
          dataabases: database,
          recieverNotificationToken: user1Data.data["notificationToken"]);
      await sendPushNotification(
          dataabases: database,
          recieverNotificationToken: user2Data.data["notificationToken"]);*/

      return context.res.json({
        "message": "REQUEST_SUCCESFULL",
        "details": "REACTION DELETED_AND_CONVERSATION_CREATED",
      }, 200);
    } else {
      return context.res.json({
        "message": "REQUEST_FAILED",
        "details": "SOME USER IS BLOCKED OR THE SAME USER",
      }, 500);
    }
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({'status': "error", "mesage": e.message, "stackTrace": s});
      return context.res.json({
        "message": "INTERNAL_ERROR",
      }, 500);
    }
    /*if (e is NotificationException) {
      print({'status': "error", "mesage": e.message, "stackTrace": s});
      res.json({
        'status': 200,
        "message": "NOTIFICATION_ERROR",
      });
    }*/

    else {
      context.log({'status': "error", "mesage": e.toString(), "stackTrace": s});
      return context.res.json({
        "message": "INTERNAL_ERROR",
      }, 500);
    }
  }
}

/*Future<void> sendPushNotification(
    {required Databases dataabases,
    required String recieverNotificationToken}) async {
  try {
    Document document = await dataabases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "63eba9bfd3923130eb3d",
        documentId: "63ebaa165a793004bb38");
    String notificationAuthToken = document.data["fcmNotifications"];
    dio.Response notificationData = await dio.Dio().post(
      "https://fcm.googleapis.com/v1/projects/hotty-189c7/messages:send",
      options: dio.Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $notificationAuthToken"
      }),
      data: {
        "message": {
          "token": recieverNotificationToken,
          "data": {"notificationType": "chat"}
        },
      },
    );
  } catch (e) {
    throw NotificationException(message: e.toString());
  }
}

class NotificationException implements Exception {
  String message;
  NotificationException({
    required this.message,
  });
}*/
