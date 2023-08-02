import 'dart:convert';
import 'package:dio/dio.dart' as dio;

import 'package:dart_appwrite/dart_appwrite.dart';

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
        .setEndpoint('https://www.hottyserver.com/v1') // Your API Endpoint
        .setProject('636bd00b90e7666f0f6f') // Your project ID
        .setKey(
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824')
        .setSelfSigned(status: true);
    final database = Databases(client);
    var data = jsonDecode(req.payload);
    String chatId = data["chatId"];

    var chatData = await database.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "637d10c17be1c3d1544d",
        documentId: chatId);
    Map chatDataMap = chatData.data;

    var messages = await database.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "637d18ff8b3927cce18d",
        queries: [Query.equal("conversationId", chatId)]);

    int messagesAmount = messages.total;

    if (messagesAmount >= 20) {
      var user1Data = await database.getDocument(
        databaseId: "636d59d7a2f595323a79",
        documentId: chatDataMap["user1Id"],
        collectionId: "636d59df12dcf7a399d5",
      );
      var user2Data = await database.getDocument(
        databaseId: "636d59d7a2f595323a79",
        documentId: chatDataMap["user2Id"],
        collectionId: "636d59df12dcf7a399d5",
      );

      chatDataMap["user1Picture"] = user1Data.data["user1Picture"];
      chatDataMap["user2Picture"] = user2Data.data["user2Picture"];
      chatDataMap["isBlindDate"] = false;
      await database.updateDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "637d10c17be1c3d1544d",
        documentId: chatId,
        data: chatDataMap,
      );

      res.json({
        'status': 200,
        "message": "correct",
      });
    } else {
      res.json({
        'status': 201,
        "message": "LOW_MESSAGES_COUNT",
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
    var document = await dataabases.getDocument(
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
          "data": {"notificationType": "blind_chat"}
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
