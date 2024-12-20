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
    String? userCollectionId = Platform.environment["USER_DATA_COLELCTION_ID"];
    String? databaseId = Platform.environment["DATABASE_ID"];
    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject(projectId as String)
        .setKey(apiKey);

    final data = context.req.bodyJson;
    Databases database = Databases(client);
    bool firstReward = data["firstReward"];
    String userId = data["userId"];
    Document userData = await database.getDocument(
        databaseId: databaseId as String,
        collectionId: userCollectionId as String,
        documentId: userId);

    if (firstReward == false) {
      int secondsUntilNextReward = userData.data["nextRewardTimestamp"];
      bool waitingReward = userData.data["waitingRewards"];
      int userCoins = userData.data["userCoins"];
      if ((waitingReward == true) &&
          (secondsUntilNextReward < DateTime.now().millisecondsSinceEpoch) &&
          userCoins < 200) {
        await database.updateDocument(
            databaseId: databaseId,
            collectionId: userCollectionId,
            documentId: userId,
            data: {
              "userCoins": 600,
              "nextRewardTimestamp": 0,
              "waitingRewards": false
            });
      }
    }
    if (firstReward == true) {
      bool giveFirstReward = userData.data["giveFirstReward"];
      int secondsUntilNextReward = userData.data["nextRewardTimestamp"];
      int userCoins = userData.data["userCoins"];

      if ((giveFirstReward == true) &&
          (secondsUntilNextReward < DateTime.now().millisecondsSinceEpoch)) {
        await database.updateDocument(
            databaseId: databaseId,
            collectionId: userCollectionId,
            documentId: userId,
            data: {
              "userCoins": 15000 + userCoins,
              "nextRewardTimestamp": 0,
              "waitingRewards": false,
              "giveFirstReward": false
            });
      }
    }

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
