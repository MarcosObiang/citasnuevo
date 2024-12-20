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
    String? userCollectionId = Platform.environment["USER_DATA_COLELCTION_ID"];
    String? databaseId = Platform.environment["DATABASE_ID"];
    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject(projectId as String)
        .setKey(apiKey);

    final data = context.req.bodyJson;
    String userId = data["userId"];
    Map<String, dynamic> userPicture1 = jsonDecode(data["userPicture1"]);
    Map<String, dynamic> userPicture2 = jsonDecode(data["userPicture2"]);
    Map<String, dynamic> userPicture3 = jsonDecode(data["userPicture3"]);
    Map<String, dynamic> userPicture4 = jsonDecode(data["userPicture4"]);
    Map<String, dynamic> userPicture5 = jsonDecode(data["userPicture5"]);
    Map<String, dynamic> userPicture6 = jsonDecode(data["userPicture6"]);
    List<Map<String, dynamic>> userPicturesIds = [
      userPicture1,
      userPicture2,
      userPicture3,
      userPicture4,
      userPicture5,
      userPicture6
    ];
    Storage storage = Storage(client);
    Databases database = Databases(client);
    await uploadPictures(
        userPicturesIds: userPicturesIds,
        userId: userId,
        storage: storage,
        context: context);

    data["userPicture1"] = jsonEncode(userPicturesIds[0]);
    data["userPicture2"] = jsonEncode(userPicturesIds[1]);
    data["userPicture3"] = jsonEncode(userPicturesIds[2]);
    data["userPicture4"] = jsonEncode(userPicturesIds[3]);
    data["userPicture5"] = jsonEncode(userPicturesIds[4]);
    data["userPicture6"] = jsonEncode(userPicturesIds[5]);
    Map newData = {
      "userPicture1": data["userPicture1"],
      "userPicture2": data["userPicture2"],
      "userPicture3": data["userPicture3"],
      "userPicture4": data["userPicture4"],
      "userPicture5": data["userPicture5"],
      "userPicture6": data["userPicture6"],
      "userCharacteristics_alcohol": data["userCharacteristics_alcohol"],
      "userCharacteristics_what_he_looks":
          data["userCharacteristics_what_he_looks"],
      "userCharacteristics_bodyType": data["userCharacteristics_bodyType"],
      "userCharacteristics_children": data["userCharacteristics_children"],
      "userCharacteristics_pets": data["userCharacteristics_pets"],
      "userCharacteristics_politics": data["userCharacteristics_politics"],
      "userCharacteristics_lives_with": data["userCharacteristics_lives_with"],
      "userCharacteristics_smokes": data["userCharacteristics_smokes"],
      "userCharacteristics_sexualO": data["userCharacteristics_sexualO"],
      "userCharacteristics_zodiak": data["userCharacteristics_zodiak"],
      "userCharacteristics_personality":
          data["userCharacteristics_personality"],
      "userBio": data["userBio"]
    };

    await database.updateDocument(
        databaseId: databaseId as String,
        collectionId: userCollectionId as String,
        documentId: userId,
        data: newData);

    return context.res.json({
      'message': "REQUEST_SUCCESFULL",
      'details': "COMPLETED",
    }, 200);
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({'status': "error", "mesage": e.message, "stackTrace": s});
      return context.res.json(
          {"message": "INTERNAL_ERROR", "detaiils": "SOMETHING_WENT_WRONG"},
          500);
    } else {
      context.log({'status': "error", "mesage": e.toString(), "stackTrace": s});
      return context.res.json(
          {"message": "INTERNAL_ERROR", "detaiils": "SOMETHING_WENT_WRONG"},
          500);
    }
  }
}

Future<List<Map<String, dynamic>>> uploadPictures(
    {required List<Map<String, dynamic>> userPicturesIds,
    required String userId,
    required Storage storage,
    required dynamic context}) async {
  List<Map<String, dynamic>> listafotos = List.empty(growable: true);
  for (int i = 0; i < userPicturesIds.length; i++) {
    bool fileExists =
        await checkIfFileExists("${userId}-image${i + 1}", storage, context);
    if (userPicturesIds[i]["imageData"] != null &&
        userPicturesIds[i]["imageData"] != "NOT_AVAILABLE") {
      if (fileExists) {
        await storage.deleteFile(
          bucketId: "userPictures",
          fileId: "${userId}-image${i + 1}",
        );
      }

      File file = await storage.createFile(
          bucketId: "userPictures",
          fileId: "${userId}-image${i + 1}",
          file: InputFile.fromBytes(
              bytes: base64Decode(userPicturesIds[i]["imageData"])!,
              filename: "${userId}-image${i + 1}"),
          permissions: [
            Permission.read(Role.users("verified")),
          ]);

      listafotos.add(userPicturesIds[i]);
      listafotos[i]["imageData"] = file.$id;
    } else {
      listafotos.add(userPicturesIds[i]);
      listafotos[i]["imageData"] = "NOT_AVAILABLE";
    }
  }

  return listafotos;
}

Future<bool> checkIfFileExists(
    String fileId, Storage storage, dynamic context) async {
  try {
    File preFile =
        await storage.getFile(bucketId: "userPictures", fileId: fileId);

    return true;
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log(e.message);

      if (e.message == "The requested file could not be found.") {
        return false;
      } else {
        throw Exception(e.message);
      }
    } else {
      context.log(e.toString());
      throw Exception(e);
    }
  }
}
