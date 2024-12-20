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
    String? userCollectionId = Platform.environment["USER_DATA_COLELCTION_ID"];
    String? databaseId = Platform.environment["DATABASE_ID"];
    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject(projectId as String)
        .setKey(apiKey);

    final data = context.req.bodyJson;
    Databases database = Databases(client);
    String userId = data["userId"];

    Map<String, dynamic> userData = {};
    userData = {
      "maxDistance": data["maxDistance"],
      "maxAge": data["maxAge"],
      "minAge": data["minAge"],
      "showCentimeters": data["showCentimeters"],
      "showKilometers": data["showKilometers"],
      "showBothSexes": data["showBothSexes"],
      "showWoman": data["showWoman"],
      "showProfile": data["showProfile"],
    };
    await database.updateDocument(
        databaseId: databaseId as String,
        collectionId: userCollectionId as String,
        documentId: userId,
        data: {
          "isUserVisible": data["showProfile"],
          "userSettings": jsonEncode(userData)
        });

    return context.res.json({
      'message': "REQUEST_SUCCESFULL",
      'details': "COMPLETED",
    }, 200);
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({'status': "error", "mesage": e.message, "stackTrace": s});

      return context.res.json(
          {"message": "INTERNAL_ERROR", "detaiils": "SOMETHING_WENT_WRONG"},
          500);
    } else {
      context.log({'status': "error", "mesage": e.toString(), "stackTrace": s});

      return context.res.json(
          {"message": "INTERNAL_ERROR", "detaiils": "SOMETHING_WENT_WRONG"},
          500);
    }
  }
}
