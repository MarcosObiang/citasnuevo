import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dart_appwrite/models.dart';
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

    Databases dataabases = Databases(client);
    Storage storage = Storage(client);

    String messageId = createId(idLength: 15);
    final data = context.req.bodyJson;
    String recieverNotificationToken = data["recieverNotificationId"];
    String messageType = data["messageType"];

    if (messageType == "IMAGE" || messageType == "AUDIO") {
      String resourceId = createId(idLength: 10);
      Uint8List fileData = base64Decode(data["message"]);
      final file = await storage.createFile(
          bucketId: "chatImages",
          fileId: resourceId,
          file: InputFile(bytes: fileData, filename: resourceId),
          permissions: [
            Permission.read(Role.user(data["senderId"])),
            Permission.read(Role.user(data["recieverId"]))
          ]);
      data["message"] = file.$id;
    }

    await dataabases.createDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "messages",
        documentId: messageId,
        data: {
          "conversationId": data["conversationId"],
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "readByReciever": false,
          "senderId": data["senderId"],
          "recieverId": data["recieverId"],
          "messageContent": data["message"],
          "messageType": data["messageType"],
          "messageId": messageId
        },
        permissions: [
          Permission.read(Role.user(data["senderId"])),
          Permission.read(Role.user(data["recieverId"]))
        ]);
    /*  await sendPushNotification(
        dataabases: dataabases,
        recieverNotificationToken: recieverNotificationToken);*/

    return context.res.json(
        {"message": "REQUEST_SUCCESSFUL", "details": "MESSAGE_SENT"}, 200);
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({'status': "error", "message": e.message, "stackTrace": s});

      return context.res.json({"message": "INTERNAL_ERROR"}, 500);
    } else {
      if (e is NotificationException) {
        context.log({'status': 200, "message": e.toString(), "stackTrace": s});

        return context.res.json({
          "message": "REQUEST_SUCCESSFUL",
          "details": "MESSAGE_SENT_WITHOUT_NOTIFICATION"
        }, 200);
      } else {
        context
            .log({'status': "error", "message": e.toString(), "stackTrace": s});
        return context.res.json({"message": "INTERNAL_ERROR"}, 500);
      }
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
          "data": {"notificationType": "message"}
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

String createId({required int idLength}) {
  const String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";
  var random = Random();
  String finalCode = characters[random.nextInt(characters.length)];

  for (var i = 0; i < idLength; i++) {
    finalCode += characters[random.nextInt(characters.length)];
  }

  return finalCode;
}
