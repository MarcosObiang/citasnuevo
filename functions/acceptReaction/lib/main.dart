import 'dart:convert';
import 'package:dio/dio.dart' as dio;

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

Future<void> start(final req, final res) async {
  try {
    Client client = Client()
        .setEndpoint('https://www.hottyserver.com/v1')
        .setProject('636bd00b90e7666f0f6f')
        .setKey(
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824')
        .setSelfSigned(status: true);

    var data = jsonDecode(req.payload);
    Databases database = Databases(client);
    String reactionId = data["reactionId"];
    String user1Id;
    String user2Id;
    bool isAnyUserBlocked = false;
    bool sameUser = false;

    Document reactionData = await database.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374fc078b95d03fb3c1",
        documentId: reactionId);
    user1Id = reactionData.data["senderId"];
    user2Id = reactionData.data["recieverId"];

    Document user1Data = await database.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: user1Id);
    Document user2Data = await database.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
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
          databaseId: "636d59d7a2f595323a79",
          collectionId: "6374fe10e76d07bfe639",
          documentId: reactionId);
      await database.deleteDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "6374fc078b95d03fb3c1",
          documentId: reactionId);
      await database.createDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "637d10c17be1c3d1544d",
          documentId: reactionData.$id,
          data: {
            "converstationCreationTimestamp":
                DateTime.now().millisecondsSinceEpoch,
            "conversationId": reactionData.$id,
            "user1Picture": user1Data.data["userPicture1"],
            "user2Picture": user2Data.data["userPicture1"],
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
      await sendPushNotification(
          dataabases: database,
          recieverNotificationToken: user1Data.data["notificationToken"]);
      await sendPushNotification(
          dataabases: database,
          recieverNotificationToken: user2Data.data["notificationToken"]);

      res.json({
        'status': 200,
        "message": "correct",
      });
    } else {
      res.json({
        'status': 500,
        "message": "SOME_USER_MAY_BE_BLOCKED",
      });
    }
  } catch (e, s) {
    if (e is AppwriteException) {
      print({'status': "error", "mesage": e.message, "stackTrace": s});
      res.json({
        'status': 500,
        "message": "INTERNAL_ERROR",
      });
    }
    if (e is NotificationException) {
      print({'status': "error", "mesage": e.message, "stackTrace": s});
      res.json({
        'status': 200,
        "message": "NOTIFICATION_ERROR",
      });
    } else {
      print({'status': "error", "mesage": e.toString(), "stackTrace": s});
      res.json({
        'status': 500,
        "message": "INTERNAL_ERROR",
      });
    }
  }
}

Future<void> sendPushNotification(
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
}
