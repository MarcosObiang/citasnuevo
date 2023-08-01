import 'dart:convert';
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
enum VerificationProcessStatus {
  VERIFICATION_NOT_INITIALIZED,
  VERIFICATION_INITIALIZED,

  VERIFICATION_WAITING_MODERATION,
  VERIFICATION_NOT_SUCCESFULL,
  VERIFICATION_SUCCESFULL
}

Future<void> start(final req, final res) async {
  try {
    Client client = Client()
        .setEndpoint('https://www.hottyserver.com/v1') // Your API Endpoint
        .setProject('636bd00b90e7666f0f6f') // Your project ID
        .setKey(
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824'); // Your secret API key
    final databases = Databases(client);
    final data = jsonDecode(req.payload);
    final storage = Storage(client);
    String? userId = req.variables["APPWRITE_FUNCTION_USER_ID"].toString();
    Map<String, dynamic> userPicture1 = jsonDecode(data["userPicture1"]);
    Map<String, dynamic> userPicture2 = jsonDecode(data["userPicture2"]);
    Map<String, dynamic> userPicture3 = jsonDecode(data["userPicture3"]);
    Map<String, dynamic> userPicture4 = jsonDecode(data["userPicture4"]);
    Map<String, dynamic> userPicture5 = jsonDecode(data["userPicture5"]);
    Map<String, dynamic> userPicture6 = jsonDecode(data["userPicture6"]);
    String promotionalCode = data["promotionalCode"];
    bool promotionalCodeExists = await verifyPromotionalCode(
        promotionalCode: promotionalCode, databases: databases);
    bool promotionalCodePendingOfUse = false;
    Map<String, dynamic> userCharacteristicsMap =
        jsonDecode(data["userCharacteristics"]);
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

    await pictureVerification(images: userPicturesIds, storage: storage);
    verifyPictureId(userPicturesIds, userId);
    verifyAppSettings(jsonDecode(data["userSettings"]));
    verifyPositionData(data["positionLat"], data["positionLon"]);
    verifyUserAge(data["birthDateInMilliseconds"]);
    verifyUserCharacterisitcs(jsonDecode(data["userCharacteristics"]));

    for (int i = 0; i < userPicturesIds.length; i++) {
      if (userPicturesIds[i]["imageId"] != null &&
          userPicturesIds[i]["imageId"] != "empty") {
        await storage.updateFile(
            bucketId: "63712fd65399f32a5414",
            fileId: userPicturesIds[i]["imageId"]!,
            permissions: [
              Permission.read(Role.users("verified")),
              Permission.update(Role.user(userId))
            ]);
      }
    }
    await databases.createDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374cbd1eb8543d64263",
        documentId: userId,
        data: {
          "userPicture1": data["userPicture1"],
          "userPicture2": data["userPicture2"],
          "userPicture3": data["userPicture3"],
          "userPicture4": data["userPicture4"],
          "userPicture5": data["userPicture5"],
          "userPicture6": data["userPicture6"],
          "userBlocked": false,
          "userId": userId,
          "userBio": data["userBio"],
          "amountReports": 0,
          "reports": []
        });
    await databases.createDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "643532127e8e23305b84",
        documentId: userId,
        data: {
          "imageLink": "NOT_AVAILABLE",
          "imageExpectedHandGesture": "NOT_AVAILABLE",
          "verificationStatus":
              VerificationProcessStatus.VERIFICATION_NOT_INITIALIZED.name
        });

    await databases.createDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: userId,
        data: {
          "userPicture1": data["userPicture1"],
          "userPicture2": data["userPicture2"],
          "userPicture3": data["userPicture3"],
          "userPicture4": data["userPicture4"],
          "userPicture5": data["userPicture5"],
          "userPicture6": data["userPicture6"],
          "userId": userId,
          "birthDateInMilliseconds": data["birthDateInMilliseconds"],
          "userName": data["userName"],
          "userSex": data["userSex"],
          "userBio": data["userBio"],
          "userCoins": 0,
          "positionLon": data["positionLon"],
          "positionLat": data["positionLat"],
          "userSettings": data["userSettings"],
          "averageRating": 0,
          "waitingReward": false,
          "giveFirstReward": true,
          "email": data["email"],
          "nextRewardTimestamp": 0,
          "isUserPremium": false,
          "lastRatingTimestamp": 0,
          "ratingsRecieved": 0,
          "totalRatingPoints": 0,
          "notificationToken": "absd",
          "isUserVisible": true,
          "subscriptionStatus": "NOT_SUBCRIBED",
          "lastBlindDate": 0,
          "subscriptionId": "",
          "subscriptionExpirationTimestamp": 0,
          "subscriptionPaused": false,
          "endSubscriptionPauseTimestamp": 0,
          "userBlocked": false,
          "rewardTicketCode": createId(idLength: 6),
          "rewardTicketSuccesfulShares": 0,
          "promotionalCodeUsedByUser": promotionalCode,
          "promotionalCodePendingOfUse": promotionalCodePendingOfUse,
          "alcohol": userCharacteristicsMap["alcohol"],
          "im_looking_for": userCharacteristicsMap["im_looking_for"],
          "body_type": userCharacteristicsMap["body_type"],
          "children": userCharacteristicsMap["children"],
          "pets": userCharacteristicsMap["pets"],
          "politics": userCharacteristicsMap["politics"],
          "im_living_with": userCharacteristicsMap["im_living_with"],
          "smoke": userCharacteristicsMap["smoke"],
          "sexual_orientation": userCharacteristicsMap["sexual_orientation"],
          "zodiac_sign": userCharacteristicsMap["zodiac_sign"],
          "personality": userCharacteristicsMap["personality"],
          "penalizationState": "NOT_PENALIZED",
          "penalizationEndTimestampMs": 0,
          "verificationImageLink": "NOT_AVAILABLE",
          "imageExpectedHandGesture": "NOT_AVAILABLE",
          "verificationStatus":
              VerificationProcessStatus.VERIFICATION_NOT_INITIALIZED.name,
          "adConsentFormShown": false,
          "showPersonalizedAds": false
        },
        permissions: [
          Permission.read(Role.user(data["userId"], "verified")),
        ]);

    res.json({"status": 200, "message": "OK"});
  } catch (e) {
    if (e is AppwriteException) {
      res.json(
          {"status": 500, "message": "INTERNAL_ERROR", "details": e.message});
    } else {
      res.json({
        "status": 500,
        "message": "INTERNAL_ERROR",
        "details": e.toString()
      });

      if (e.toString().contains("EXPECTED_ERROR")) {
        Map<String, dynamic> errorData = jsonDecode(e.toString());
        res.json({
          "status": 501,
          "message": errorData["error"],
        });
      } else {
        res.json({
          "status": 500,
          "message": "INTERNAL_ERROR",
        });
      }
    }
  }
}

///Verifies that user pictures ids are  in the expected format

bool verifyPictureId(
  List<Map<String, dynamic>?> pircutreIds,
  String userId,
) {
  try {
    bool result = true;

    for (int i = 0; i < pircutreIds.length; i++) {
      if (pircutreIds[i]?["imageId"]!.contains(userId)) {
        String desiredStructure = "${userId}_image${i + 1}";
        if (pircutreIds[i]?["imageId"] != desiredStructure) {
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
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          queries: [Query.equal("rewardTicketCode", promotionalCode)]);
      if (ownerOfPromotionalCodeUserData.total > 0) {
        int amountOfRewardTicketSuccesfulShares = ownerOfPromotionalCodeUserData
                .documents.first.data["rewardTicketSuccesfulShares"] +
            1;
        await databases.updateDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "636d59df12dcf7a399d5",
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
    int alcohol = userCharacteristic["alcohol"];
    int lookingFor = userCharacteristic["im_looking_for"];
    int bodyType = userCharacteristic["body_type"];
    int children = userCharacteristic["children"];
    int pets = userCharacteristic["pets"];
    int politics = userCharacteristic["politics"];
    int livingWith = userCharacteristic["im_living_with"];
    int smoke = userCharacteristic["smoke"];
    int personality = userCharacteristic["personality"];
    int zodiacSign = userCharacteristic["zodiac_sign"];

    if ((alcohol >= 0 && alcohol <= 4) &&
        (lookingFor >= 0 && lookingFor <= 4) &&
        (bodyType >= 0 && bodyType <= 5) &&
        (children >= 0 && children <= 3) &&
        (pets >= 0 && pets <= 4) &&
        (politics >= 0 && politics <= 4) &&
        (livingWith >= 0 && livingWith <= 3) &&
        (smoke >= 0 && smoke <= 4) &&
        (personality >= 0 && personality <= 3) &&
        (zodiacSign >= 0 && zodiacSign <= 12)) {
    } else {
      throw Exception("error_verify_user_characteristcs");
    }
  } catch (e, s) {
    throw Exception(
      {
        "error": "EXPECTED_ERROR:ERROR_VERIFYING_USER_CHARACTERISITCS",
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
      throw Exception("verifyPositionData");
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
      if (images[i]["imageId"] != "empty") {
        await storage.getFile(
            bucketId: "63712fd65399f32a5414", fileId: images[i]["imageId"]);
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

String createId({required int idLength}) {
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

  for (int i = 0; i <= idLength; i++) {
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
