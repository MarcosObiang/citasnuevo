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
    String? chatCollectionId =
        Platform.environment["CONVERSATION_COLLECTION_ID"];
    String? reportedChatCollectionId =
        Platform.environment["REPORTED_CHAT_COLLECTION_ID"];

    String? reactionsCollectionId =
        Platform.environment["REACTIONS_COLLECTION_ID"];
    String? privateReactionsCollectionId =
        Platform.environment["PRIVATE_REACTIONS_COLLECTION_ID"];

    String? reportsCollectionId = Platform.environment["REPORTS_COLLECTION_ID"];

    String? messagesCollectionId =
        Platform.environment["MESSAGES_COLLECTION_ID"];
    String? usersToAvoidCollectionId =
        Platform.environment["USERS_TO_AVOID_COLLECTION_ID"];

    String? reportdMessagesCollectionId =
        Platform.environment["REPORTED_MESSAGES_COLLECTION_ID"];

    String? verificationCollectionId =
        Platform.environment["VERIFICATION_COLLECTION_ID"];

    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject(projectId as String)
        .setKey(apiKey);
    Databases database = Databases(client);
    Users users = Users(client);
    Storage storage = Storage(client);
    final data = context.req.bodyJson;

    String userId = data["userId"];

    var userData = await database.getDocument(
        databaseId: databaseId as String,
        collectionId: userCollectionId as String,
        documentId: userId);
    int rewardTicketSuccesfulShares =
        userData.data["rewardTicketSuccesfulShares"] * 5000;
    int userCredits = userData.data["userCoins"] + rewardTicketSuccesfulShares;

    if (rewardTicketSuccesfulShares > 0) {
      await database.updateDocument(
          databaseId: databaseId as String,
          collectionId: userCollectionId as String,
          documentId: userId,
          data: {"rewardTicketSuccesfulShares": 0, "userCoins": userCredits});
    } else {
      throw Exception(
        {
          "error": "EXPECTED_ERROR:ERROR_USING_SUCCESFUL_SHARES",
          "errorMessage": "THIS_USER_HAS_NO_SUCCESFUL_SHARES_LEFT",
        },
      );
    }
    return context.res
        .json({"message": "REQUEST_SUCCESFULL", "details": "COMPLETED"}, 200);
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({'status': "error", "message": e.message, "stackTrace": s});

      return context.res.json(
          {"message": "INTERNAL_ERROR", "details": "SOMETHING_WENT_WRONG"},
          500);
    } else {
      if (e.toString().contains("EXPECTED_ERROR")) {
        Map<String, dynamic> errorData = jsonDecode(e.toString());
        String message = errorData["errorMessage"];
        context
            .log({'status': "error", "message": e.toString(), "stackTrace": s});

        return context.res.json({
          "message": "INTERNAL_ERROR",
          "details": message,
        }, 500);
      } else {
        context
            .log({'status': "error", "message": e.toString(), "stackTrace": s});

        return context.res.json(
            {"message": "INTERNAL_ERROR", "details": "SOMETHING_WENT_WRONG"},
            500);
      }
    }
  }
}
