import 'dart:convert';
import 'dart:math';
import 'package:dart_appwrite/models.dart';
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

    Databases dataabases = Databases(client);

    String messageId = createId();
    var data = jsonDecode(req.payload);
    String recieverNotificationToken = data["recieverNotificationId"];

    await dataabases.createDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "637d18ff8b3927cce18d",
        documentId: messageId,
        data: {
          "conversationId": data["conversationId"],
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "readByReciever": false,
          "senderId": data["senderId"],
          "recieverId": data["recieverId"],
          "messageContent": data["message"],
          "messageType": data["messageType"],
          "messageId": messageId
        },
        permissions: [
          Permission.read(Role.user(data["senderId"])),
          Permission.read(Role.user(data["recieverId"]))
        ]);
    await sendPushNotification(
        dataabases: dataabases,
        recieverNotificationToken: recieverNotificationToken);

    res.json({'status': 200, "message": "correct"});
  } catch (e, s) {
    if (e is AppwriteException) {
      print({'status': "error", "message": e.message, "stackTrace": s});

      res.json({'status': 500, "message": "INTERNAL_ERROR"});
    } else {
      if (e is NotificationException) {
        print({
          'status': 200,
          "message": "NOTIFICATION_ERROR",
        });

        res.json({'status': 200, "message": "NOTIFICATION_ERROR"});
      } else {
        print({'status': "error", "message": e.toString(), "stackTrace": s});
        res.json({
          'status': 500,
          "message": "INTERNAL_ERROR",
        });
      }
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
   
    dio.Response notificationData = await dio.Dio().post(
      "https://fcm.googleapis.com/v1/projects/hotty-189c7/messages:send",
      options: dio.Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $notificationAuthToken"
      }),
      data: {
        "message": {
          "token": recieverNotificationToken,
          "data": {"notificationType": "message"}
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
