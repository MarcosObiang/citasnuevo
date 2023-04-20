// ignore_for_file: constant_identifier_names

import 'dart:convert';

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
enum PenalizationState {
  NOT_PENALIZED,
  IN_MODERATION_WAITING,
  PENALIZED,
  IN_MODERATION_DONE
}
Future<void> start(final req, final res) async {
  try {
    Client client = Client()
        .setEndpoint('https://www.hottyserver.com/v1') // Your API Endpoint
        .setProject('636bd00b90e7666f0f6f') // Your project ID
        .setKey(
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824');

    final databases = Databases(client);
    String? userId = req.variables["APPWRITE_FUNCTION_USER_ID"].toString();

    var userProfile = await databases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: userId);

    String penalizationState = userProfile.data["penalizationState"];
    int penalizationEndTimestampMs = userProfile.data["penalizationEndTimestampMs"];
    if ((penalizationState == PenalizationState.PENALIZED.name||penalizationState == PenalizationState.IN_MODERATION_DONE.name) &&
        penalizationEndTimestampMs < DateTime.now().millisecondsSinceEpoch) {
      await databases.updateDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: userId,
          data: {
            "penalizationState": "NOT_PENALIZED",
            "penalizationEndTimestampMs": 0
          });
      res.json({"status": 200, "message": "OK"});
    } else {
      res.json({"status": 201, "message": "THIS_USER_CANNOT_BE_UNLOCKED_YET"});
    }
  } catch (e) {
    if (e is AppwriteException) {
      print({"status": 500, "message": "INTERNAL_ERROR", "details": e.message});
      res.json(
          {"status": 500, "message": "INTERNAL_ERROR", "details": e.message});
    } else {
      print({
        "status": 500,
        "message": "INTERNAL_ERROR",
        "details": e.toString()
      });
      res.json({
        "status": 500,
        "message": "INTERNAL_ERROR",
        "details": e.toString()
      });
    }
  }
}
