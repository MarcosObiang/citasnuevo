import 'dart:convert';
import 'dart:io';
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

Future<dynamic> main(final context) async {
  try {
    String apiKey = Platform.environment["APPWRITE_FUNCTIONS_APIKEY"]!;
    String? projectId = Platform.environment["PROJECT_ID"];
    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject(projectId as String)
        .setKey(apiKey);
    final database = Databases(client);
    final data = context.req.bodyJson;
    String chatId = data["chatId"];

    var chatData = await database.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "conversations",
        documentId: chatId);
    Map chatDataMap = chatData.data;

    var messages = await database.listDocuments(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "messages",
        queries: [Query.equal("conversationId", chatId)]);

    int messagesAmount = messages.total;

    if (messagesAmount >= 1) {
      var user1Data = await database.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        documentId: chatDataMap["user1Id"],
        collectionId: "6729a8c50029409cd062",
      );
      var user2Data = await database.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        documentId: chatDataMap["user2Id"],
        collectionId: "6729a8c50029409cd062",
      );

      chatDataMap["user1Picture"] = user1Data.data["userPicture1"];
      chatDataMap["user2Picture"] = user2Data.data["userPicture1"];
      chatDataMap["isBlindDate"] = false;
      await database.updateDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "conversations",
        documentId: chatId,
        data: {
          "user1Picture": jsonDecode(user1Data.data["userPicture1"])["imageData"],
          "user2Picture": jsonDecode(user2Data.data["userPicture1"])["imageData"],
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
      );

      return context.res.json({
        "message": "REQUEST_SUCCESFULL",
        "details": "COMPLETED",
      }, 200);
    } else {
      return context.res.json({
        "message": "LOW_MESSAGES_COUNT",
        "details": "COMPLETED_BUT_MESSAGES_COUNT_IS_LOW",
      }, 201);
    }
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({'status': "error", "mesage": e.message, "stackTrace": s});
      return context.res.json({
        "message": "INTERNAL_ERROR",
        "details": "SOMETHING_WENT_WRONG",
      }, 500);
    }
    if (e is NotificationException) {
      context.log({'status': "error", "mesage": e.message, "stackTrace": s});
      return context.res.json({
        "message": "NOTIFICATION_ERROR",
        "details": "SOMETHING_WENT_WRONG",
      }, 200);
    } else {
      context.log({'status': "error", "mesage": e.toString(), "stackTrace": s});
      return context.res.json({
        "message": "INTERNAL_ERROR",
        "details": "SOMETHING_WENT_WRONG",
      }, 500);
    }
  }
}

/*Future<void> sendPushNotification(
    {required Databases dataabases,
    required String recieverNotificationToken}) async {
  try {
    var document = await dataabases.getDocument(
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
          "data": {"notificationType": "blind_chat"}
        },
      },
    );
  } catch (e) {
    throw NotificationException(message: e.toString());
  }
}*/

class NotificationException implements Exception {
  String message;
  NotificationException({
    required this.message,
  });
}
