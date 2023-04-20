import 'dart:convert';

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
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824');
    Databases database = Databases(client);

    String userId = req.variables["APPWRITE_FUNCTION_USER_ID"].toString();

    var userData = await database.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: userId);
    bool promotionalCodePendingOfUse =
        userData.data["promotionalCodePendingOfUse"];
    int userCredits = userData.data["userCoins"] + 5000;

    if (promotionalCodePendingOfUse) {
      await database.updateDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: userId,
          data: {
            "promotionalCodePendingOfUse": false,
            "userCoins": userCredits
          });
    } else {
      throw Exception(
        {
          "error": "EXPECTED_ERROR:ERROR_SUBMITTING_PROMOTIONAL_CODE",
          "errorMessage": "THIS_USER_HAS_NO_PROMOTION_RIGTHS_LEFT",
        },
      );
    }
    res.json({'status': 200, "message": "OK"});
  } catch (e, s) {
    if (e is AppwriteException) {
      print({'status': "error", "message": e.message, "stackTrace": s});

      res.json({'status': 500, "message": "INTERNAL_ERROR"});
    } else {
      if (e.toString().contains("EXPECTED_ERROR")) {
        Map<String, dynamic> errorData = jsonDecode(e.toString());
        String message = errorData["errorMessage"];
        print({'status': "error", "message": e.toString(), "stackTrace": s});
        res.json({
          'status': 501,
          "message": message,
        });
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
