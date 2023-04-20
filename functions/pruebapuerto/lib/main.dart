import 'dart:convert';
import 'dart:io';

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
    Databases databases = Databases(client);

    int port = 8080;
    RawDatagramSocket socket =
        await RawDatagramSocket.bind(InternetAddress("172.17.0.2"), port);
    var document = await databases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "63eba9bfd3923130eb3d",
        documentId: "63ebaa165a793004bb38");
    String notificationAuthToken = document.data["fcmNotifications"];
    socket.send(
        Utf8Codec().encode(jsonEncode({
          "notificationType": "reaction",
          "serverToken": notificationAuthToken,
          "recieverToken":
              "eCupJoRBSs6s31E6njLInJ:APA91bH9EvFEojf9oiEGGZqZy9wiqV3bIFdqqpfnL0iC_Gg9SHPGhGHTeygdhwLPJ_-Ki4nWSdgM_2BqRv3aciDRaLP8j7MvkfHQDI2-MmqrNew7mDLQRL8Md89fM7NAH8DZaf7_OVlx"
        })),
        InternetAddress("172.17.0.2"),
        port);

    res.json({
      'areDevelopersAwesome': true,
    });
  } catch (e) {
    if (e is AppwriteException) {
      res.json({
        'status': 500,
        "mesage": "INTERNAL_ERROR",
      });
    } else {
      res.json({'status': 500, "mesage": e.toString()});
    }
  }
}
