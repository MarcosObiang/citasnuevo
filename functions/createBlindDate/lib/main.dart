import 'dart:convert';
import 'dart:math';
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

    final database = Databases(client);
    var data = jsonDecode(req.payload);
    double currentLon = data["lon"];
    double currentLat = data["lat"];
    int maxDistance = data["distance"];
    String userId = data["userId"];

    String chatId = createId();
    var documentList = await database.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        queries: [
          Query.limit(1),
          Query.equal("isBlindDateActive", true),
          Query.equal("isUserVisible", true),
          Query.equal("userBlocked", false),
          Query.greaterThanEqual(
              "positionLon", getMinLongitude(currentLon, maxDistance)),
          Query.lessThanEqual(
              "positionLon", getMaxLongitude(currentLon, maxDistance)),
          Query.greaterThanEqual(
              "positionLat", getMinLatitude(currentLat, maxDistance)),
          Query.lessThanEqual(
              "positionLat", getMaxLatitude(currentLat, maxDistance)),
        ]);
    if (documentList.documents.isNotEmpty) {
      var user1Data = await database.getDocument(
        databaseId: "636d59d7a2f595323a79",
        documentId: userId,
        collectionId: "636d59df12dcf7a399d5",
      );

      int userCredits = user1Data.data["userCoins"];
      bool isUserPremium = user1Data.data["isUserPremium"];

      if (userCredits >= 100 || isUserPremium == true) {
        int coinsLeft = userCredits - 100;
        if (isUserPremium == false) {
          if (coinsLeft < 200) {
            await database.updateDocument(
                databaseId: "636d59d7a2f595323a79",
                collectionId: "636d59df12dcf7a399d5",
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
                databaseId: "636d59d7a2f595323a79",
                collectionId: "636d59df12dcf7a399d5",
                documentId: user1Data.$id,
                data: {
                  "userCoins": coinsLeft,
                });
          }

          await database.createDocument(
              databaseId: "636d59d7a2f595323a79",
              collectionId: "637d10c17be1c3d1544d",
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
          await sendPushNotification(
              dataabases: database,
              recieverNotificationToken:
                  documentList.documents.first.data["notificationToken"]);
        }
        if (isUserPremium == true) {
          await database.createDocument(
              databaseId: "636d59d7a2f595323a79",
              collectionId: "637d10c17be1c3d1544d",
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
          await sendPushNotification(
              dataabases: database,
              recieverNotificationToken:
                  documentList.documents.first.data["notificationToken"]);
        }

        res.json({
          'status': 200,
          "message": "correct",
        });
      }
      if (userCredits < 100) {
        res.json({
          'status': 201,
          "message": "LOW_CREDITS",
        });
      }
    }
    if (documentList.documents.isEmpty) {
      res.json({
        'status': 201,
        "message": "NO_USERS_FOUND",
      });
    }
  } catch (e, s) {
    if (e is AppwriteException) {
      print({'status': "error", "mesage": e.message, "stackTrace": s});
      res.json({
        'status': 500,
        "message": "INTERNAL_ERROR",
      });
    }
    if (e is NotificationException) {
      print({'status': "error", "mesage": e.message, "stackTrace": s});
      res.json({
        'status': 200,
        "message": "NOTIFICATION_ERROR",
      });
    } else {
      print({'status': "error", "mesage": e.toString(), "stackTrace": s});
      res.json({
        'status': 500,
        "message": "INTERNAL_ERROR",
      });
    }
  }
}

Future<void> sendPushNotification(
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
}

class NotificationException implements Exception {
  String message;
  NotificationException({
    required this.message,
  });
}

double getMaxLongitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));
  lon = lon + 360;

  for (int i = 0; i < distance; i++) {
    lon = lon + 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  double result = lon - 360;
  return result;
}

double getMinLongitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));
  lon = lon + 360;

  for (int i = 0; i < distance; i++) {
    lon = lon - 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  double result = lon - 360;
  return result;
}

double getMaxLatitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));
  lon = lon + 90;

  for (int i = 0; i < distance; i++) {
    lon = lon + 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  double result = lon - 90;
  return result;
}

double getMinLatitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));
  lon = lon + 90;

  for (int i = 0; i < distance; i++) {
    lon = lon - 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  double result = lon - 98;
  return result;
}

String createId() {
  List<String> letras = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
  ];
  List<String> numero = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
  var random = Random();
  int primeraLetra = random.nextInt(26);
  String finalCode = letras[primeraLetra];

  for (int i = 0; i <= 20; i++) {
    int characterTypeIndicator = random.nextInt(20);
    int randomWord = random.nextInt(27);
    int randomNumber = random.nextInt(9);
    if (characterTypeIndicator <= 2) {
      characterTypeIndicator = 2;
    }
    if (characterTypeIndicator % 2 == 0) {
      finalCode = "$finalCode${(numero[randomNumber])}";
    }
    if (randomWord % 3 == 0) {
      int mayuscula = random.nextInt(9);
      if (characterTypeIndicator <= 2) {
        int suerte = random.nextInt(2);
        suerte == 0 ? characterTypeIndicator = 3 : characterTypeIndicator = 2;
      }
      if (mayuscula % 2 == 0) {
        finalCode = "$finalCode${(letras[randomWord]).toUpperCase()}";
      }
      if (mayuscula % 3 == 0) {
        finalCode = "$finalCode${(letras[randomWord]).toLowerCase()}";
      }
    }
  }
  return finalCode;
}
