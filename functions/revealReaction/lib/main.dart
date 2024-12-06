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

    String reactionId = data["reactionId"];
    String userId = data["userId"];
    bool showAd = data["showAd"];
    int priceToRevealReaction=showAd?200:400;


    Databases database = Databases(client);

    Document reactionData = await database.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "reactionsPrivate",
        documentId: reactionId);

    Document userData = await database.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        documentId: userId);

    int userCoins = userData.data["userCoins"];
    bool isUserPremium = userData.data["isUserPremium"];

    if (isUserPremium) {
      await database.updateDocument(
          databaseId: "6729a8be001c8e5fa57a",
          collectionId: "reactionsPrivate",
          documentId: reactionId,
          data: {
            "senderName": reactionData.data["senderName"],
            "senderId": reactionData.data["senderId"],
            "userPicture": reactionData.data["userPicture"],
            "reactionValue": reactionData.data["reactionValue"],
            "reactionRevealed": true,
          });
      return context.res.json({
        "message": "REQUEST_SUCCESFULL",
        "details": "USER IS PREMIUM, JUST REVEAL AND NOT COUNT COINS"
      }, 200);
    } else {
      if (userCoins >= priceToRevealReaction) {
        int remainingCoins = userCoins - priceToRevealReaction;

        if (remainingCoins < 200) {
          await database.updateDocument(
              databaseId: "6729a8be001c8e5fa57a",
              collectionId: "6729a8c50029409cd062",
              documentId: userData.$id,
              data: {
                "userCoins": remainingCoins,
                "nextRewardTimestamp":
                    (DateTime.now().add(Duration(minutes: 3)))
                        .millisecondsSinceEpoch,
                "waitingRewards": true
              });
        } else {
          await database.updateDocument(
              databaseId: "6729a8be001c8e5fa57a",
              collectionId: "6729a8c50029409cd062",
              documentId: userData.$id,
              data: {
                "userCoins": remainingCoins,
              });
        }

        await database.updateDocument(
            databaseId: "6729a8be001c8e5fa57a",
            collectionId: "reactions",
            documentId: reactionId,
            data: {
              "senderName": reactionData.data["senderName"],
              "senderId": reactionData.data["senderId"],
              "userPicture": reactionData.data["userPicture"],
              "reactionValue": reactionData.data["reactionValue"],
              "reactionRevealed": true,
            });
        return context.res.json({
          "message": "REQUEST_SUCESSFULL",
          "details": "REACTION REVEALED",
        }, 200);
      } else {
        return context.res.json({
          "message": "CREDITS_LOW",
          "details": "USER DOES NOT HAVE ENOUGH CREDITS"
        }, 200);
      }
    }
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log("Error: ${e.message} stackTrace: $s");
      return context.res.json({ "message": "INTERNAL_ERROR"},500);
    } else {
      context.log("Error: ${e.toString()} stackTrace: $s");

      return context.res.json({ "message": "INTERNAL_ERROR"},500);
    }
  }
}
