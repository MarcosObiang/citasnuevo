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
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject(projectId as String)
        .setKey(apiKey);

    final data = context.req.bodyJson;
    String userId = data["userId"];
    int reactionValue = data["reactionValue"];
    bool reactionTypeIsValid = false;
    String reactionId = createId(idLength: 10);
    String recieverId = data["recieverId"];
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int expirationTimestamp =
        (DateTime.now().add(Duration(days: 1))).millisecondsSinceEpoch;

    Databases databases = Databases(client);
    Document recieverUserData = await databases.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        documentId: recieverId);
    Document senderUserData = await databases.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        documentId: userId);

    int reactionAverage = recieverUserData.data["reactionAveragePoints"];
    int totalReactionPoints = recieverUserData.data["totalReactionPoints"];
    int reactionCount = recieverUserData.data["reactionCount"];
    int newReactionPoints = data["reactionValue"];
    String notificationToken = recieverUserData.data["notificationToken"];

    if (reactionValue > 0 && reactionValue <= 100) {
      reactionTypeIsValid = true;
    }

    if (reactionTypeIsValid == true) {
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
          databaseId: "6729a8be001c8e5fa57a",
          collectionId: "6729a8c50029409cd062",
          documentId: recieverId,
          data: {
            "reactionCount": reactionCount,
            "reactionAveragePoints": reactionAverage,
            "totalReactionPoints": totalReactionPoints,
            "lastRatingTimestamp": DateTime.now().millisecondsSinceEpoch,
          });

      await databases.createDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "reactionsPrivate",
        documentId: reactionId,
        data: {
          "timestamp": timestamp,
          "userIsBlocked": false,
          "expirationTimestamp": expirationTimestamp,
          "reactionId": reactionId,
          "recieverId": recieverId,
          "senderId": userId,
          "reactionRevealed": false,
          "senderName": data["senderName"],
          "reactionValue": reactionValue,
          "userPicture":
              jsonDecode(senderUserData.data["userPicture1"])["imageData"],
        },
      );
      await databases.createDocument(
          databaseId: "6729a8be001c8e5fa57a",
          collectionId: "reactions",
          documentId: reactionId,
          data: {
            "timestamp": timestamp,
            "userBlocked": false,
            "expirationTimestamp": expirationTimestamp,
            "reactionId": reactionId,
            "recieverId": recieverId,
            "senderId": "NOT_AVAILABLE",
            "reactionRevealed": false,
            "senderName": "NOT_AVAILABLE",
            "reactionValue": 0,
            "userPicture": "NOT_AVAILABLE",
          },
          permissions: [
            Permission.read(Role.user(recieverId))
          ]);

      await updateUsersToAvoid(databases, userId, recieverId);

      /* await sendPushNotification(
          dataabases: databases, recieverNotificationToken: notificationToken);*/

      return context.res.json({
        "message": "REQUEST_SUCCESFULL",
        "details": "COMPLETED",
      }, 200);
    } else {
      return context.res.json({
        "message": "INVALID_REACTION_TYPE",
        "details": "THE PROVIDED REACTION TYPE IS INVALID"
      }, 501);
    }
  } catch (e) {
    if (e is AppwriteException) {
      context.log(e.message);
      return context.res.json({
        "message": "INTERNAL_ERROR",
        "details": "SOMETHING WENT WRONG",
      }, 500);
    }
    if (e is NotificationException) {
      return context.res.json({
        "message": "NOTIFICATION_ERROR",
        "details": "REACTION NOTIFICATION FAILED",
      }, 200);
    } else {
      context.log(e.toString());

      return context.res.json({
        "message": "INTERNAL_ERROR",
        "details": "SOMETHING WENT WRONG",
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

Future<void> updateUsersToAvoid(
    Databases databases, String userId, String recieverId) async {
  Document usersToAvoidOfSender = await databases.getDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "usersToAvoid",
      documentId: userId);

  Document usersToAvoidOfReciever = await databases.getDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "usersToAvoid",
      documentId: recieverId);

  List<dynamic> usersToAvoidOfSenderList =
      usersToAvoidOfSender.data["usersToAvoid"];
  List<dynamic> usersToAvoidOfRecieverList =
      usersToAvoidOfReciever.data["usersToAvoid"];
  usersToAvoidOfRecieverList.remove(userId);
  usersToAvoidOfSenderList.remove(recieverId);
  usersToAvoidOfSenderList.add(recieverId);
  usersToAvoidOfRecieverList.add(userId);
  await databases.updateDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "usersToAvoid",
      documentId: userId,
      data: {"usersToAvoid": usersToAvoidOfSenderList});

  await databases.updateDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "usersToAvoid",
      documentId: recieverId,
      data: {"usersToAvoid": usersToAvoidOfRecieverList});
}

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
