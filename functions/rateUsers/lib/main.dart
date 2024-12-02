import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';
//import 'package:dio/dio.dart' as dio;

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

enum ReactionType { PASS, MAYBE, LIKE }
Future<dynamic> main(final context) async {
  try {
        String apiKey = Platform.environment["APPWRITE_FUNCTIONS_APIKEY"]!;
    String? projectId = Platform.environment["PROJECT_ID"];
    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject(projectId as String)
        .setKey(apiKey);

    final data = context.req.bodyJson;
    String userId = data["userId"];
    String reactionType = data["reactionType"];
    bool reactionTypeIsValid = false;
    String reactionId = createId(idLength: 10);
    String recieverId = data["recieverId"];
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int expirationTimestamp =
        (DateTime.now().add(Duration(days: 1))).millisecondsSinceEpoch;

    Databases databases = Databases(client);
    Document recieverUserData = await databases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: recieverId);
    Document senderUserData = await databases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: userId);

    int reactionAverage = recieverUserData.data["reactionAverage"];
    int totalReactionPoints = recieverUserData.data["totalReactionPoints"];
    int reactionCount = recieverUserData.data["reactionCount"];
    int newReactionPoints = 0;
    String notificationToken = recieverUserData.data["notificationToken"];

    for (int i = 0; i < ReactionType.values.length; i++) {
      if (reactionType == ReactionType.values[i].name) {
        reactionTypeIsValid = true;
      }
    }

    if (reactionTypeIsValid == true) {
      if (reactionType == "PASS") {
        newReactionPoints = 33;
      }
      if (reactionType == "MAYBE") {
        newReactionPoints = 66;
      }
      if (reactionType == "LIKE") {
        newReactionPoints = 99;
      }

      if (reactionCount >= 50) {
        reactionAverage = newReactionPoints;
        reactionCount = 1;
        totalReactionPoints = newReactionPoints;
      } else {
        totalReactionPoints = totalReactionPoints + newReactionPoints;
        reactionCount = reactionCount + 1;
        reactionAverage = totalReactionPoints ~/ reactionCount;
      }

      await databases.updateDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: recieverId,
          data: {
            "reactionCount": reactionCount,
            "reactionAverage": reactionAverage,
            "totalReactionPoints": totalReactionPoints,
            "lastRatingTimestamp": DateTime.now().millisecondsSinceEpoch,
          });

      await databases.createDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374fc078b95d03fb3c1",
        documentId: reactionId,
        data: {
          "timestamp": timestamp,
          "userBlocked": false,
          "expirationTimestamp": expirationTimestamp,
          "reactionId": reactionId,
          "recieverId": recieverId,
          "senderId": userId,
          "reactionRevealed": false,
          "senderName": data["senderName"],
          "reactionType": reactionType,
          "userPicture": senderUserData.data["userPicture1"],
        },
      );
      await databases.createDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "6374fe10e76d07bfe639",
          documentId: reactionId,
          data: {
            "timestamp": timestamp,
            "userBlocked": false,
            "expirationTimestamp": expirationTimestamp,
            "reactionId": reactionId,
            "recieverId": recieverId,
            "reactionRevealed": false,
          },
          permissions: [
            Permission.read(Role.user(recieverId))
          ]);
     /* await sendPushNotification(
          dataabases: databases, recieverNotificationToken: notificationToken);*/

      res.json({
        'status': 200,
      });
    } else {
      res.json({
        'status': 501,
        "mesage": "INVALID_REACTION_TYPE",
      });
    }
  } catch (e) {
    if (e is AppwriteException) {
      res.json({
        'status': 500,
        "mesage": "INTERNAL_ERROR",
      });
    }
    if (e is NotificationException) {
      res.json({
        'status': 200,
        "mesage": "NOTIFICATION_COULD_NOT_BE_SENT",
      });
    } else {
      res.json({'status': 500, "mesage": e.toString()});
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
    await dio.Dio().post(
      "https://fcm.googleapis.com/v1/projects/hotty-189c7/messages:send",
      options: dio.Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $notificationAuthToken"
      }),
      data: {
        "message": {
          "token": recieverNotificationToken,
          "data": {"notificationType": "reaction"}
        },
      },
    );
  } catch (e) {
    throw NotificationException(message: e.toString());
  }
}*/

String createId({required int idLength}) {
  const String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";
  var random = Random();
  String finalCode = characters[random.nextInt(characters.length)];

  for (var i = 0; i < idLength; i++) {
    finalCode += characters[random.nextInt(characters.length)];
  }

  return finalCode;
}


class NotificationException implements Exception {
  String message;
  NotificationException({
    required this.message,
  });
}
