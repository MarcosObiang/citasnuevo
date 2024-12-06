import 'dart:convert';
import 'dart:io';

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
    String userId = data["userId"];

    List<dynamic> reactionIds = data["reactionIds"];

    for (int i = 0; i < reactionIds.length; i++) {
      Document reactionData = await database.getDocument(
          databaseId: "6729a8be001c8e5fa57a",
          collectionId: "reactionsPrivate",
          documentId: reactionIds[i]);

      if (userId == reactionData.data["recieverId"]) {
        await database.deleteDocument(
            databaseId: "6729a8be001c8e5fa57a",
            collectionId: "reactions",
            documentId: reactionIds[i]);
        await database.deleteDocument(
            databaseId: "6729a8be001c8e5fa57a",
            collectionId: "reactionsPrivate",
            documentId: reactionIds[i]);
      }
    }
    return context.res.json(
        {"message": "REQUEST_SUCESSFULL", "details": "REACTIONS DELETED"}, 200);
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({"message": e.message, "stackTrace": s});

      return context.res.json({"message": "INTERNAL_ERROR"}, 500);
    } else {
      context.log({"message": e.toString(), "stackTrace": s});

      return context.res.json({"message": "INTERNAL_ERROR"}, 500);
    }
  }
}
