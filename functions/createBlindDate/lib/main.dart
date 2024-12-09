import 'dart:convert';
import 'dart:io';
import 'dart:math';

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

    final database = Databases(client);
    final data = context.req.bodyJson;
    double currentLon = data["lon"] + 180;
    double currentLat = data["lat"] + 90;
    bool isShowAdOfferUsed = data["isShowAdOfferUsed"];
    int maxDistance = data["distance"];
    String userId = data["userId"];

    String chatId = createId(idLength: 15);
    var documentList = await database.listDocuments(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        queries: [
          Query.limit(1),
          Query.orderDesc("lastRatingTimestamp"),
          Query.equal("isBlindDateActive", true),
          Query.equal("isUserVisible", true),
          Query.equal("userBlocked", false),
          Query.equal(
              "userLongitude", getAllLongitudesRange(currentLon, maxDistance)),
          Query.greaterThanEqual(
              "userLatitude", getMinLatitude(currentLat, maxDistance)),
          Query.lessThanEqual(
              "userLatitude", getMaxLatitude(currentLat, maxDistance)),
        ]);
    if (documentList.documents.isNotEmpty) {
      var user1Data = await database.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        documentId: userId,
        collectionId: "6729a8c50029409cd062",
      );

      int userCredits = user1Data.data["userCoins"];
      bool isUserPremium = user1Data.data["isUserPremium"];
      int price = isShowAdOfferUsed ? 200 : 400;

      if (userCredits >= price || isUserPremium == true) {
        int coinsLeft = userCredits - price;
        if (isUserPremium == false) {
          if (coinsLeft < 200) {
            await database.updateDocument(
                databaseId: "6729a8be001c8e5fa57a",
                collectionId: "6729a8c50029409cd062",
                documentId: user1Data.$id,
                data: {
                  "userCoins": coinsLeft,
                  "nextRewardTimestamp":
                      (DateTime.now().add(Duration(minutes: 3)))
                          .millisecondsSinceEpoch,
                  "waitingReward": true
                });
          } else {
            await database.updateDocument(
                databaseId: "6729a8be001c8e5fa57a",
                collectionId: "6729a8c50029409cd062",
                documentId: user1Data.$id,
                data: {
                  "userCoins": coinsLeft,
                });
          }

          await database.createDocument(
              databaseId: "6729a8be001c8e5fa57a",
              collectionId: "conversations",
              documentId: chatId,
              data: {
                "converstationCreationTimestamp":
                    DateTime.now().millisecondsSinceEpoch,
                "conversationId": chatId,
                "user1Picture": "NOT_AVAILABLE",
                "user2Picture": "NOT_AVAILABLE",
                "user1Name": user1Data.data["userName"],
                "user2Name": documentList.documents.first.data["userName"],
                "user1Id": userId,
                "user2Id": documentList.documents.first.$id,
                "user1Blocked": false,
                "user2Blocked": false,
                "user1NotificationToken": user1Data.data["notificationToken"],
                "user2NotificationToken":
                    documentList.documents.first.data["notificationToken"],
                "isBlindDate": true
              },
              permissions: [
                Permission.read(Role.user(userId)),
                Permission.read(Role.user(documentList.documents.first.$id))
              ]);
          /*  await sendPushNotification(
              dataabases: database,
              recieverNotificationToken:
                  documentList.documents.first.data["notificationToken"]);*/
        }
        if (isUserPremium == true) {
          await database.createDocument(
              databaseId: "6729a8be001c8e5fa57a",
              collectionId: "conversations",
              documentId: chatId,
              data: {
                "converstationCreationTimestamp":
                    DateTime.now().millisecondsSinceEpoch,
                "conversationId": chatId,
                "user1Picture": "NOT_AVAILABLE",
                "user2Picture": "NOT_AVAILABLE",
                "user1Name": user1Data.data["userName"],
                "user2Name": documentList.documents.first.data["userName"],
                "user1Id": userId,
                "user2Id": documentList.documents.first.$id,
                "user1Blocked": false,
                "user2Blocked": false,
                "user1NotificationToken": user1Data.data["notificationToken"],
                "user2NotificationToken":
                    documentList.documents.first.data["notificationToken"],
                "isBlindDate": true
              },
              permissions: [
                Permission.read(Role.user(userId)),
                Permission.read(Role.user(documentList.documents.first.$id))
              ]);
          /* await sendPushNotification(
              dataabases: database,
              recieverNotificationToken:
                  documentList.documents.first.data["notificationToken"]);*/
        }

        return context.res.json({
          "message": "REQUEST_SUCCESFULL",
          "details": "COMPLETED",
        }, 200);
      }
      if (userCredits < price) {
        return context.res.json({
          "message": "LOW_CREDITS",
          "details": "COMPLETED",
        }, 201);
      }
    }
    if (documentList.documents.isEmpty) {
      return context.res.json({
        "message": "NO_USERS_FOUND",
        "details": "COMPLETED",
      }, 202);
    }
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({'status': "error", "mesage": e.message, "stackTrace": s});
      return context.res.json({
        "message": "INTERNAL_ERROR",
        "details": "SOMETHING_WENT_WRONG",
      }, 500);
    }
    if (e is NotificationException) {
      context.log({'status': "error", "mesage": e.message, "stackTrace": s});
      return context.res.json({
        "message": "INTERNAL_ERROR",
        "details": "SOMETHING_WENT_WRONG",
      }, 500);
    } else {
      context.log({'status': "error", "mesage": e.toString(), "stackTrace": s});
      return context.res.json({
        "message": "INTERNAL_ERROR",
        "details": "SOMETHING_WENT_WRONG",
      }, 500);
    }
  }
}

/*Future<void> sendPushNotification(
    {required Databases dataabases,
    required String recieverNotificationToken}) async {
  try {
    var document = await dataabases.getDocument(
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
          "data": {"notificationType": "blind_chat"}
        },
      },
    );
  } catch (e) {
    throw NotificationException(message: e.toString());
  }
}*/

List<double> getAllLongitudesRange(double currentLon, int distance) {
  List<double> longitudes = [];
  double firstLongitude = currentLon;
  double finalLongitude = firstLongitude - 0.1;
  longitudes.add(finalLongitude);
  longitudes.add(currentLon);

  for (int i = 0; i < 5; i++) {
    finalLongitude = finalLongitude - 0.1;

    longitudes.add(double.parse(finalLongitude.toStringAsFixed(1)));
  }

  finalLongitude = firstLongitude + 0.1;
  longitudes.add(finalLongitude);

  for (int i = 0; i < 5; i++) {
    finalLongitude = finalLongitude + 0.1;

    longitudes.add(double.parse(finalLongitude.toStringAsFixed(1)));
  }

  return longitudes;
}

class NotificationException implements Exception {
  String message;
  NotificationException({
    required this.message,
  });
}


double getMaxLatitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));

  for (int i = 0; i < distance; i++) {
    lon = lon + 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  return lon;
}

double getMinLatitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));

  for (int i = 0; i < distance; i++) {
    lon = lon - 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  return lon;
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
