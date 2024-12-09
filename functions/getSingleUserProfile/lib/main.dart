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
    final database = Databases(client);
    final data = context.req.bodyJson;

    var userData = await database.getDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        documentId: data["userId"]);

    int userBirthDateInMillisecondsSinceEpoch = userData.data["userBirthDate"];
    int userAge = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(
                userBirthDateInMillisecondsSinceEpoch))
            .inDays ~/
        365;
    Map<String, dynamic> dataToJson = mapProfileData(userData, userAge);

    return context.res.json({
      "message": "REQUEST_SUCCESSFUL",
      "details": "PROFILE_FETCHED",
      "payload": dataToJson
    }, 200);
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log(
          {"status": 500, "message": e.message, "stackTrace": s.toString()});
      return context.res.json(
          {'message': "INTERNAL_ERROR", "details": "SOMETHING_WENT_WRONG"},
          500);
    } else {
      context.log(
          {"status": 500, "message": e.toString(), "stackTrace": s.toString()});

      return context.res.json(
          {'message': "INTERNAL_ERROR", "details": "SOMETHING_WENT_WRONG"},
          500);
    }
  }
}

Map<String, dynamic> mapProfileData(Document userData, int userAge) {
  return {
    "userId": userData.data["userId"],
    "userName": userData.data["userName"],
    "userSex": userData.data["userSex"],
    "userBio": userData.data["userBio"],
    "distance": 0,
    "userAge": userAge,
    "userCharacteristics_alcohol": userData.data["userCharacteristics_alcohol"],
    "userCharacteristics_what_he_looks":
        userData.data["userCharacteristics_what_he_looks"],
    "userCharacteristics_bodyType":
        userData.data["userCharacteristics_bodyType"],
    "userCharacteristics_children":
        userData.data["userCharacteristics_children"],
    "userCharacteristics_pets": userData.data["userCharacteristics_pets"],
    "userCharacteristics_politics":
        userData.data["userCharacteristics_politics"],
    "userCharacteristics_lives_with":
        userData.data["userCharacteristics_lives_with"],
    "userCharacteristics_smokes": userData.data["userCharacteristics_smokes"],
    "userCharacteristics_sexualO": userData.data["userCharacteristics_sexualO"],
    "userCharacteristics_zodiak": userData.data["userCharacteristics_zodiak"],
    "userCharacteristics_personality":
        userData.data["userCharacteristics_personality"],
    "userPicture1": jsonDecode(userData.data["userPicture1"]),
    "userPicture2": jsonDecode(userData.data["userPicture2"]),
    "userPicture3": jsonDecode(userData.data["userPicture3"]),
    "userPicture4": jsonDecode(userData.data["userPicture4"]),
    "userPicture5": jsonDecode(userData.data["userPicture6"]),
    "userPicture6": jsonDecode(userData.data["userPicture6"]),
  };
}
