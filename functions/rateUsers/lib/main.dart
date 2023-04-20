import 'dart:convert';
import 'dart:math';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';
import 'package:dio/dio.dart' as dio;

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

    var data = jsonDecode(req.payload);
    String userId = data["userId"];
    String reactionId = createId();
    String recieverId = data["recieverId"];
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int expirationTimestamp =
        (DateTime.now().add(Duration(days: 1))).millisecondsSinceEpoch;

    Databases databases = Databases(client);
    Document recieverUserData = await databases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: recieverId);
    Document senderUserData = await databases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: userId);

    num totalRatingPoints = recieverUserData.data["totalRatingPoints"];
    String notificationToken = recieverUserData.data["notificationToken"];

    int ratingsRecieved = recieverUserData.data["ratingsRecieved"];
    int newRatingsRecieved;
    double newTotalRatingPoints;
    double newReactionAverage;
    if (ratingsRecieved >= 60) {
      newRatingsRecieved = 1;
      newReactionAverage = data["reactionValue"];
      newTotalRatingPoints = data["reactionValue"];
    } else {
      newRatingsRecieved = ratingsRecieved + 1;
      newTotalRatingPoints =
          (totalRatingPoints + data["reactionValue"]).toDouble();
      newReactionAverage = newTotalRatingPoints / newRatingsRecieved;
    }

    await databases.updateDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: recieverId,
        data: {
          "ratingsRecieved": newRatingsRecieved,
          "averageRating": newReactionAverage,
          "totalRatingPoints": newTotalRatingPoints,
          "lastRatingTimestamp": DateTime.now().millisecondsSinceEpoch,
        });

    await databases.createDocument(
      databaseId: "636d59d7a2f595323a79",
      collectionId: "6374fc078b95d03fb3c1",
      documentId: reactionId,
      data: {
        "timestamp": timestamp,
        "userBlocked": false,
        "expirationTimestamp": expirationTimestamp,
        "reactionId": reactionId,
        "recieverId": recieverId,
        "senderId": userId,
        "reactionRevealed": false,
        "senderName": data["senderName"],
        "reactionValue": data["reactionValue"],
        "userPicture": senderUserData.data["userPicture1"]
      },
    );
    await databases.createDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374fe10e76d07bfe639",
        documentId: reactionId,
        data: {
          "timestamp": timestamp,
          "userBlocked": false,
          "expirationTimestamp": expirationTimestamp,
          "reactionId": reactionId,
          "recieverId": recieverId,
          "reactionRevealed": false,
        },
        permissions: [
          Permission.read(Role.user(recieverId))
        ]);
    await sendPushNotification(
        dataabases: databases, recieverNotificationToken: notificationToken);

    res.json({
      'status': 200,
    });
  } catch (e) {
    if (e is AppwriteException) {
      res.json({
        'status': 500,
        "mesage": "INTERNAL_ERROR",
      });
    }
    if (e is NotificationException) {
      res.json({
        'status': 200,
        "mesage": "NOTIFICATION_COULD_NOT_BE_SENT",
      });
    } else {
      res.json({'status': 500, "mesage": e.toString()});
    }
  }
}

Future<void> sendPushNotification(
    {required Databases dataabases,
    required String recieverNotificationToken}) async {
  try {
    Document document = await dataabases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "63eba9bfd3923130eb3d",
        documentId: "63ebaa165a793004bb38");
    String notificationAuthToken = document.data["fcmNotifications"];
    await dio.Dio().post(
      "https://fcm.googleapis.com/v1/projects/hotty-189c7/messages:send",
      options: dio.Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $notificationAuthToken"
      }),
      data: {
        "message": {
          "token": recieverNotificationToken,
          "data": {"notificationType": "reaction"}
        },
      },
    );
  } catch (e) {
    throw NotificationException(message: e.toString());
  }
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

class NotificationException implements Exception {
  String message;
  NotificationException({
    required this.message,
  });
}
