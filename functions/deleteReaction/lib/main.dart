import 'dart:convert';

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

Future<void> start(final req, final res) async {
  try {
    Client client = Client()
        .setEndpoint('http://www.hottyserver.com/v1') // Your API Endpoint
        .setProject('636bd00b90e7666f0f6f') // Your project ID
        .setKey(
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824')
        .setSelfSigned(status: true);

    var data = jsonDecode(req.payload);
    Databases database = Databases(client);
    List<dynamic> reactionIds = data["reactionIds"];
    String? userId = req.variables["APPWRITE_FUNCTION_USER_ID"].toString();
    String status = "correct";
    reactionIds.forEach((element) async {
      Document reactionData = await database.getDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "6374fe10e76d07bfe639",
          documentId: element);

      if (userId == reactionData.data["recieverId"]) {
        await database.deleteDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "6374fe10e76d07bfe639",
            documentId: element);
        await database.deleteDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "6374fc078b95d03fb3c1",
            documentId: element);
      } else {
        status = "UNAUTHORIZED_OPERATIONS";
      }
    });

    res.json({
      'status': status,
    });
  } catch (e, s) {
    if (e is AppwriteException) {
      res.json({'status': "error", "mesage": e.message, "stackTrace": s});
    } else {
      res.json({'status': "error", "mesage": e.toString(), "stackTrace": s});
    }
  }
}
