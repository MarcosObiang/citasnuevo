import 'dart:convert';
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

Future<void> start(final req, final res) async {
  try {
    Client client = Client()
        .setEndpoint('https://www.hottyserver.com/v1') // Your API Endpoint
        .setProject('636bd00b90e7666f0f6f') // Your project ID
        .setKey(
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824')
        .setSelfSigned(status: true);
    Databases database = Databases(client);
    var jsonData = req.payload;
    Map<String, dynamic> data = jsonDecode(jsonData) as Map<String, dynamic>;
    Map<int, dynamic> parsedData = {};

    int i = 0;
    for (var element in data.keys) {
      parsedData.addAll({i: data[element]});
      i++;
    }
    var eventData = parsedData[1];
    var finalData = jsonDecode(eventData);
    String store = finalData["event"]["store"];

    String? eventType = finalData["event"]["type"];
    String activeSubscriptionStatus = "SUBSCRIBED";
    String cancelledSubscriptionStatus = "CANCELLED";
    String paymentIssuesSubscriptionStatus = "PAYMENT_ISSUES";
    String notSubscribedSubscriptionStatus = "NOT_SUBSCRIBED";
    bool isUserPremium = false;

    if (eventType == "INITIAL_PURCHASE") {
      String? userId = finalData["event"]["app_user_id"];
      String? productId = finalData["event"]["product_id"];
      int subscriptionExpirationTimeInMs =
          finalData["event"]["expiration_at_ms"];
      if (subscriptionExpirationTimeInMs >
          DateTime.now().millisecondsSinceEpoch) {
        isUserPremium = true;
      }
      await database.updateDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: userId!,
          data: {
            "isUserPremium": isUserPremium,
            "subscriptionStatus": activeSubscriptionStatus,
            "subscriptionId": productId ?? "NONE",
            "subscriptionExpirationTimestamp": subscriptionExpirationTimeInMs,
            "subscriptionPaused": false,
            "endSubscriptionPauseTimestamp": 0
          });
    }
    if (eventType == "RENEWAL") {
      String? userId = finalData["event"]["app_user_id"];
      String? productId = finalData["event"]["product_id"];
      int subscriptionExpirationTimeInMs =
          finalData["event"]["expiration_at_ms"];
      if (subscriptionExpirationTimeInMs >
          DateTime.now().millisecondsSinceEpoch) {
        isUserPremium = true;
      }
      await database.updateDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: userId!,
          data: {
            "isUserPremium": isUserPremium,
            "subscriptionStatus": activeSubscriptionStatus,
            "subscriptionId": productId ?? "NONE",
            "subscriptionExpirationTimestamp": subscriptionExpirationTimeInMs,
            "subscriptionPaused": false,
            "endSubscriptionPauseTimestamp": 0
          });
    }
    if (eventType == "CANCELLATION") {
      String? userId = finalData["event"]["app_user_id"];
      String? productId = finalData["event"]["product_id"];
      int subscriptionExpirationTimeInMs =
          finalData["event"]["expiration_at_ms"];
      if (subscriptionExpirationTimeInMs >
          DateTime.now().millisecondsSinceEpoch) {
        isUserPremium = true;
      }
      await database.updateDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: userId!,
          data: {
            "isUserPremium": isUserPremium,
            "subscriptionStatus": cancelledSubscriptionStatus,
            "subscriptionId": productId ?? "NONE",
            "subscriptionExpirationTimestamp": subscriptionExpirationTimeInMs,
            "subscriptionPaused": false,
            "endSubscriptionPauseTimestamp": 0
          });
    }
    if (eventType == "UNCANCELLATION") {
      String? userId = finalData["event"]["app_user_id"];
      String? productId = finalData["event"]["product_id"];
      int subscriptionExpirationTimeInMs =
          finalData["event"]["expiration_at_ms"];
      if (subscriptionExpirationTimeInMs >
          DateTime.now().millisecondsSinceEpoch) {
        isUserPremium = true;
      }
      await database.updateDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: userId!,
          data: {
            "isUserPremium": isUserPremium,
            "subscriptionStatus": activeSubscriptionStatus,
            "subscriptionId": productId ?? "NONE",
            "subscriptionExpirationTimestamp": subscriptionExpirationTimeInMs,
            "subscriptionPaused": false,
            "endSubscriptionPauseTimestamp": 0
          });
    }
    if (eventType == "EXPIRATION") {
      String? userId = finalData["event"]["app_user_id"];
      String? productId = finalData["event"]["product_id"];
      int subscriptionExpirationTimeInMs =
          finalData["event"]["expiration_at_ms"];
      if (subscriptionExpirationTimeInMs >
          DateTime.now().millisecondsSinceEpoch) {
        isUserPremium = true;
      }
      await database.updateDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: userId!,
          data: {
            "isUserPremium": isUserPremium,
            "subscriptionStatus": notSubscribedSubscriptionStatus,
            "subscriptionId": productId ?? "NONE",
            "subscriptionExpirationTimestamp": subscriptionExpirationTimeInMs,
            "subscriptionPaused": false,
            "endSubscriptionPauseTimestamp": 0
          });
    }
    if (eventType == "TRANSFER") {
      late String apiKey;

      if (store == "PLAY_STORE") {
        apiKey = "goog_gUQRNUmExxIGLyeAlZIQYwLfvSa";
      }

      List<dynamic> transferredTo = finalData["event"]["transferred_to"];
      List<dynamic> transferredFrom = finalData["event"]["transferred_from"];

      for (var data in transferredFrom) {
        await database.updateDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "636d59df12dcf7a399d5",
            documentId: data,
            data: {
              "isUserPremium": false,
              "subscriptionStatus": notSubscribedSubscriptionStatus,
              "subscriptionId": "NONE",
              "subscriptionExpirationTimestamp": 0,
              "subscriptionPaused": false,
              "endSubscriptionPauseTimestamp": 0
            });
      }
      for (var data in transferredTo) {
        dio.Response notificationData = await dio.Dio().get(
          "https://api.revenuecat.com/v1/subscribers/$data",
          options: dio.Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiKey",
          }),
        );
        var response = notificationData.data;
        int subscriptionExpirationTimestamp = DateTime.parse(
                response["subscriber"]["entitlements"]["Hotty Plus"]
                    ["expires_date"])
            .millisecondsSinceEpoch;
        String productIdentifier = response["subscriber"]["entitlements"]
            ["Hotty Plus"]["product_identifier"];
        if (subscriptionExpirationTimestamp >
            DateTime.now().millisecondsSinceEpoch) {
          isUserPremium = true;
        } else {
          isUserPremium = false;
        }
        await database.updateDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "636d59df12dcf7a399d5",
            documentId: data,
            data: {
              "isUserPremium": isUserPremium,
              "subscriptionStatus": isUserPremium == false
                  ? notSubscribedSubscriptionStatus
                  : activeSubscriptionStatus,
              "subscriptionId": productIdentifier,
              "subscriptionExpirationTimestamp":
                  subscriptionExpirationTimestamp,
              "subscriptionPaused": false,
              "endSubscriptionPauseTimestamp": 0
            });
      }
    }

    res.send("Ok", status: 200);
  } catch (e, s) {
    if (e is AppwriteException) {
      res.json({'status': "error", "mesage": e.message, "stackTrace": s});
    } else {
      res.json({'status': "error", "mesage": e.toString(), "stackTrace": s});
    }
  }
}
