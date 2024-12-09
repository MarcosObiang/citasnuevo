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

Future<dynamic> main(final context) async {
  try {
    String apiKey = Platform.environment["APPWRITE_FUNCTIONS_APIKEY"]!;
    String? projectId = Platform.environment["PROJECT_ID"];
    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject(projectId as String)
        .setKey(apiKey);
    final data = context.req.bodyJson;
    List<dynamic> temporalList = data["messagesIds"];
    List<String> messagesIdList = temporalList.cast<String>();
    Databases database = Databases(client);

    for (int i = 0; i < messagesIdList.length; i++) {
      await database.updateDocument(
          databaseId: "6729a8be001c8e5fa57a",
          collectionId: "messages",
          documentId: messagesIdList[i],
          data: {"readByReciever": true});
    }

    return context.res.json({
      "details": "MESSAGES_READ_SUCCESSFULLY",
      "message": "REQUEST_SUCCESSFUL"
    }, 200);
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({'status': "error", "mesage": e.message, "stackTrace": s});

      return context.res.json(
          {"details": "SOMETHING_WENT_WRONG", "message": "INTERNAL_ERROR"},
          500);
    } else {
      context.log({'status': "error", "mesage": e.toString(), "stackTrace": s});
      return context.res.json(
          {"details": "SOMETHING_WENT_WRONG", "message": "INTERNAL_ERROR"},
          500);
    }
  }
}
