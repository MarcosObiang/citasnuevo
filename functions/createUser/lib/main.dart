import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';

enum PenalizationState {
  NOT_PENALIZED,
  IN_MODERATION_WAITING,
  PENALIZED,
  IN_MODERATION_DONE
}

enum VerificationProcessStatus {
  VERIFICATION_NOT_INITIALIZED,
  VERIFICATION_INITIALIZED,

  VERIFICATION_WAITING_MODERATION,
  VERIFICATION_NOT_SUCCESFULL,
  VERIFICATION_SUCCESFULL
}

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

    final databases = Databases(client);
    final data = context.req.bodyJson;
    final storage = Storage(client);
    String userId = data["userId"];
    Map<String, dynamic> userPicture1 = jsonDecode(data["userPicture1"]);
    Map<String, dynamic> userPicture2 = jsonDecode(data["userPicture2"]);
    Map<String, dynamic> userPicture3 = jsonDecode(data["userPicture3"]);
    Map<String, dynamic> userPicture4 = jsonDecode(data["userPicture4"]);
    Map<String, dynamic> userPicture5 = jsonDecode(data["userPicture5"]);
    Map<String, dynamic> userPicture6 = jsonDecode(data["userPicture6"]);
    Map<String, double> coordenadas;
    String promotionalCode = data["promotionalCodeUsedByUser"];
    bool promotionalCodeExists = await verifyPromotionalCode(
        promotionalCode: promotionalCode, databases: databases);
    bool promotionalCodePendingOfUse = false;

    List<Map<String, dynamic>> userPicturesIds = [
      userPicture1,
      userPicture2,
      userPicture3,
      userPicture4,
      userPicture5,
      userPicture6
    ];
    if (promotionalCodeExists) {
      promotionalCodePendingOfUse = true;
    } else {
      promotionalCodePendingOfUse = false;
    }

    await updatePicturesPermissions(
        userPicturesIds: userPicturesIds, userId: userId, storage: storage);

    await pictureVerification(images: userPicturesIds, storage: storage);
    verifyPictureId(userPicturesIds, userId);
    verifyAppSettings(jsonDecode(data["userSettings"]));
    verifyPositionData(data["positionLat"], data["positionLon"]);
    verifyUserAge(data["userBirthDate"]);
    verifyUserCharacterisitcs(data);

    coordenadas =
        transformarCoordenadas(data["positionLat"], data["positionLon"]);
    data["positionLat"] = coordenadas["latitud"];
    data["positionLon"] = coordenadas["longitud"];

    await databases.createDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "67334609000211639278",
        documentId: userId,
        data: {
          "userId": userId,
          "imageId": "NOT_AVAILABLE",
          "expectedHandGesture": "NOT_AVAILABLE",
          "verificationStatus":
              VerificationProcessStatus.VERIFICATION_NOT_INITIALIZED.name
        });

    await databases.createDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "usersToAvoid",
        documentId: userId,
        data: {"userId": userId, "usersToAvoid": []});
    await createReportModel(client: client, data: data);

    await createUserData(
        client: client,
        promotionalCode: promotionalCode,
        promotionalCodePendingOfUse: promotionalCodePendingOfUse,
        data: data);

    return context.res
        .json({"message": "REQUEST_SUCCESFULL", "details": "COMPLETED"}, 200);
  } catch (e, s) {
    context.log(s);

    if (e is AppwriteException) {
      return context.res
          .json({"message": "INTERNAL_ERROR", "details": e.message}, 500);
    } else {
      return context.res
          .json({"message": "INTERNAL_ERROR", "details": e.toString()}, 500);
    }
  }
}

Future<Document> createReportModel(
    {required Client client, required Map<String, dynamic> data}) async {
  Databases databases = Databases(client);
  Document document = await databases.createDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "reportModel",
      documentId: data["userId"],
      data: {
        "userPicture1": data["userPicture1"],
        "userPicture2": data["userPicture2"],
        "userPicture3": data["userPicture3"],
        "userPicture4": data["userPicture4"],
        "userPicture5": data["userPicture5"],
        "userPicture6": data["userPicture6"],
        "userBlocked": false,
        "userId": data["userId"],
        "userBio": data["userBio"],
        "amountReports": 0,
        "reports": jsonEncode([""]),
        "penalizationState": PenalizationState.NOT_PENALIZED.name,
        "sanctionTimestamp": 0,
        "penalizationEndTimestamp": 0,
        "penalizationCounter": 0,
      });

  return document;
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

Future<Document> createUserData(
    {required Client client,
    required String promotionalCode,
    required bool promotionalCodePendingOfUse,
    required Map<String, dynamic> data}) async {
  Databases databases = Databases(client);
  Document document = await databases.createDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "6729a8c50029409cd062",
      documentId: data["userId"],
      data: {
        "userPicture1": data["userPicture1"],
        "userPicture2": data["userPicture2"],
        "userPicture3": data["userPicture3"],
        "userPicture4": data["userPicture4"],
        "userPicture5": data["userPicture5"],
        "userPicture6": data["userPicture6"],
        "userId": data["userId"],
        "userBirthDate": data["userBirthDate"],
        "userName": data["userName"],
        "userSex": data["userSex"],
        "userBio": data["userBio"],
        "userCoins": 0,
        "userLongitude": [data["positionLon"]],
        "userLatitude": data["positionLat"],
        "userSettings": data["userSettings"],
        "waitingRewards": false,
        "giveFirstReward": true,
        "email": data["email"],
        "nextRewardTimestamp": 0,
        "isUserPremium": false,
        "lastRatingTimestamp": 0,
        "notificationToken": "absd",
        "isUserVisible": true,
        "subscriptionStatus": "NOT_SUBCRIBED",
        "lastBlindDate": 0,
        "subscriptionId": "",
        "subscriptionExpiryDate": 0,
        "subscriptionPaused": false,
        "endSubscriptionPauseTimeStamp": 0,
        "userBlocked": false,
        "rewardTicketCode": createId(idLength: 10),
        "rewardTicketSuccesfulShares": 0,
        "promotionalCodeUsedByUser": promotionalCode,
        "isUserPromotionalCodeUsed": promotionalCodePendingOfUse,
        "userCharacteristics_alcohol": data["userCharacteristics_alcohol"],
        "userCharacteristics_what_he_looks":
            data["userCharacteristics_what_he_looks"],
        "userCharacteristics_bodyType": data["userCharacteristics_bodyType"],
        "userCharacteristics_children": data["userCharacteristics_children"],
        "userCharacteristics_pets": data["userCharacteristics_pets"],
        "userCharacteristics_politics": data["userCharacteristics_politics"],
        "userCharacteristics_lives_with":
            data["userCharacteristics_lives_with"],
        "userCharacteristics_smokes": data["userCharacteristics_smokes"],
        "userCharacteristics_sexualO": data["userCharacteristics_sexualO"],
        "userCharacteristics_zodiak": data["userCharacteristics_zodiak"],
        "userCharacteristics_personality":
            data["userCharacteristics_personality"],
        "penalizationState": "NOT_PENALIZED",
        "penalizationEndDate": 0,
        "verificationImageLink": "NOT_AVAILABLE",
        "imageExpectedHandGesture": "NOT_AVAILABLE",
        "verificationStatus":
            VerificationProcessStatus.VERIFICATION_NOT_INITIALIZED.name,
        "adConsentFormShown": false,
        "adConsentFormShownDate": 0,
        "showPersonalizedAds": false,
        "isBlindDateActive": true,
        "reactionAveragePoints": 0,
        "reactionCount": 0,
        "totalReactionPoints": 0,
      },
      permissions: [
        Permission.read(Role.user(data["userId"], "verified")),
      ]);

  return document;
}

Future<void> updatePicturesPermissions(
    {required List<Map<String, dynamic>> userPicturesIds,
    required String userId,
    required Storage storage}) async {
  for (int i = 0; i < userPicturesIds.length; i++) {
    if (userPicturesIds[i]["imageData"] != null &&
        userPicturesIds[i]["imageData"] != "NOT_AVAILABLE") {
      await storage.updateFile(
          bucketId: "userPictures",
          fileId: userPicturesIds[i]["imageData"]!,
          permissions: [
            Permission.read(Role.users("verified")),
            Permission.update(Role.user(userId))
          ]);
    }
  }
}

///Verifies that user pictures ids are  in the expected format

Map<String, double> transformarCoordenadas(double latitud, double longitud) {
  // Validar que las coordenadas están dentro del rango esperado
  if (latitud < -90 || latitud > 90) {
    throw ArgumentError('La latitud debe estar entre -90 y 90 grados.');
  }
  if (longitud < -180 || longitud > 180) {
    throw ArgumentError('La longitud debe estar entre -180 y 180 grados.');
  }

  // Transformar las coordenadas
  double nuevaLatitud = latitud + 90;
  double nuevaLongitud = longitud + 180;

  // Retornar un mapa con los resultados
  return {
    'latitud': nuevaLatitud,
    'longitud': nuevaLongitud,
  };
}

bool verifyPictureId(
  List<Map<String, dynamic>?> pircutreIds,
  String userId,
) {
  try {
    bool result = true;

    for (int i = 0; i < pircutreIds.length; i++) {
      if (pircutreIds[i]?["imageData"]!.contains(userId)) {
        String desiredStructure = "${userId}-image${i + 1}";
        if (pircutreIds[i]?["imageData"] != desiredStructure) {
          result = false;
        }
      }
    }
    return result;
  } catch (e, s) {
    throw Exception(
      {
        "error": "EXPECTED_ERROR:ERROR_PICTURE_ID_VERIFICATION",
        "errorMessage": e.toString(),
        "stackTrace": s
      },
    );
  }
}

Future<bool> verifyPromotionalCode(
    {required String promotionalCode, required Databases databases}) async {
  bool verified = false;
  try {
    if (promotionalCode.isNotEmpty) {
      var ownerOfPromotionalCodeUserData = await databases.listDocuments(
          databaseId: "6729a8be001c8e5fa57a",
          collectionId: "6729a8c50029409cd062",
          queries: [Query.equal("rewardTicketCode", promotionalCode)]);
      if (ownerOfPromotionalCodeUserData.total > 0) {
        int amountOfRewardTicketSuccesfulShares = ownerOfPromotionalCodeUserData
                .documents.first.data["rewardTicketSuccesfulShares"] +
            1;
        await databases.updateDocument(
            databaseId: "6729a8be001c8e5fa57a",
            collectionId: "6729a8c50029409cd062",
            documentId: ownerOfPromotionalCodeUserData.documents.first.$id,
            data: {
              "rewardTicketSuccesfulShares": amountOfRewardTicketSuccesfulShares
            });

        verified = true;
      }
    }
    return verified;
  } catch (e, s) {
    if (e is AppwriteException) {
      throw Exception(
        {
          "error": "EXPECTED_ERROR:ERROR_SUBMITTING_PROMOTIONAL_CODE",
          "errorMessage": e.message,
          "stackTrace": s
        },
      );
    } else {
      throw Exception(
        {
          "error": "EXPECTED_ERROR:ERROR_SUBMITTING_PROMOTIONAL_CODE",
          "errorMessage": e.toString(),
          "stackTrace": s
        },
      );
    }
  }
}

void verifyUserCharacterisitcs(Map<String, dynamic> userCharacteristic) {
  try {
    int alcohol = userCharacteristic["userCharacteristics_alcohol"];
    int lookingFor =
        userCharacteristic["userCharacteristics_what_he_looks"];
    int bodyType = userCharacteristic["userCharacteristics_bodyType"];
    int children = userCharacteristic["userCharacteristics_children"];
    int pets = userCharacteristic["userCharacteristics_pets"];
    int politics = userCharacteristic["userCharacteristics_politics"];
    int livingWith = userCharacteristic["userCharacteristics_lives_with"];
    int smoke = userCharacteristic["userCharacteristics_smokes"];
    int personality = userCharacteristic["userCharacteristics_personality"];
    int zodiacSign = userCharacteristic["userCharacteristics_zodiak"];
    int sexuality=userCharacteristic["userCharacteristics_sexualO"];


    if ((alcohol >= 0 && alcohol <= 4) &&
        (lookingFor >= 0 && lookingFor <= 4) &&
        (bodyType >= 0 && bodyType <= 5) &&
        (children >= 0 && children <= 3) &&
        (pets >= 0 && pets <= 4) &&
        (politics >= 0 && politics <= 4) &&
        (livingWith >= 0 && livingWith <= 3) &&
        (smoke >= 0 && smoke <= 4) &&
        (personality >= 0 && personality <= 3) &&
        (zodiacSign >= 0 && zodiacSign <= 12&&sexuality>=0&&sexuality<=8)) {
    } else {
      throw Exception("error_verify_user_characteristcs");
    }
  } catch (e, s) {
    throw Exception(
      {
        "error": "ERROR:ERROR_VERIFYING_USER_CHARACTERISITCS",
        "errorMessage": e.toString(),
        "stackTrace": s
      },
    );
  }
}

void verifyAppSettings(Map<String, dynamic> settingsData) {
  try {
    int maxAge = settingsData["maxAge"];
    int minAge = settingsData["minAge"];
    bool? inCentimeters = settingsData["showCentimeters"];
    bool? showKilometers = settingsData["showKilometers"];
    bool? showWomen = settingsData["showWoman"];
    bool? showProfile = settingsData["showProfile"];
    bool? showBothSexes = settingsData["showBothSexes"];
    int maxDistance = settingsData["maxDistance"];

    if ((maxAge >= 18 && maxAge <= 71) &&
        (minAge >= 18 && minAge <= 71) &&
        (maxDistance >= 10 && maxDistance <= 150) &&
        showWomen != null &&
        inCentimeters != null &&
        showProfile != null &&
        showKilometers != null &&
        showBothSexes != null) {
    } else {
      throw Exception("verifyAppSettings");
    }
  } catch (e, s) {
    throw Exception(
      {
        "error": "EXPECTED_ERROR:ERROR_APP_SETTINGS_VERIFICATION",
        "errorMessage": e.toString(),
        "stackTrace": s
      },
    );
  }
}

void verifyPositionData(double lat, double lon) {
  try {
    if ((lat <= 90 && lat >= -90) && (lon <= 180 && lon >= -180)) {
    } else {
      throw Exception(
          "THE POSITION DATA DOES NOT HAVE THE EXPECTED FORMAT OR BOUNDS");
    }
  } catch (e, s) {
    throw Exception(
      {
        "error": "EXPECTED_ERROR:ERROR_VERIFICATION_POSITION_DATA",
        "errorMessage": e.toString(),
        "stackTrace": s
      },
    );
  }
}

void nameVerification({required String name}) {
  try {
    if (name.trim().isEmpty) {}
    if (name.length > 25) {
      throw Exception("nameVerification");
    }
  } catch (e, s) {
    throw Exception(
      {
        "error": "EXPECTED_ERROR:ERROR_VERIFICATION_USER_NAME",
        "errorMessage": e.toString(),
        "stackTrace": s
      },
    );
  }
}

Future<void> pictureVerification(
    {required List<Map<String, dynamic>> images,
    required Storage storage}) async {
  try {
    bool result = false;

    for (int i = 0; i < images.length; i++) {
      if (images[i]["imageData"] != "NOT_AVAILABLE") {
        await storage.getFile(
            bucketId: "userPictures", fileId: images[i]["imageData"]);
        result = true;
      }
    }
  } catch (e, s) {
    throw Exception(
      {
        "error": "EXPECTED_ERROR:ERROR_VERIFICATION_PICTURE_DATA",
        "errorMessage": e.toString(),
        "stackTrace": s
      },
    );
  }
}

void verifyUserAge(int birthDateInMilliseconds) {
  try {
    DateTime dateTime = DateTime.now();

    if (dateTime.millisecondsSinceEpoch - birthDateInMilliseconds >=
        (567648000 * 1000)) {
    } else {
      throw Exception("USER_IS_UNDER_AGE");
    }
  } catch (e, s) {
    throw Exception(
      {
        "error": "EXPECTED_ERROR:ERROR_VERIFICATION_AGE_DATA",
        "errorMessage": e.toString(),
        "stackTrace": s
      },
    );
  }
}
