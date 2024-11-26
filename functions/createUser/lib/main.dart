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

enum PenalizationState {
  NOT_PENALIZED,
  IN_MODERATION_WAITING,
  PENALIZED,
  IN_MODERATION_DONE
}

Future<dynamic> main(final context) async {
  try {
    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject('6723890e00073730d5e5').setKey("standard_8499cc7de8cfc0f2981a3e64b3b5cbf889b96c988cdfcd8972c8e345f9d91f1154bb8e329b00ab54c318eb944da90c526d32e4413e839b1d97705773da4ca6b460a278051053e77b13957f2d5ae5d30e7484130f4fc49d12b0f11c92538d4a17c97f9c2e5e5307b386d0e9df69200f34fd06888c1d3c0693cb95b14d772cbc1a"); // Your project ID




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
    String promotionalCode = data["promotionalCodeUsedByUser"];
    bool promotionalCodeExists = await verifyPromotionalCode(
        promotionalCode: promotionalCode, databases: databases);
    bool promotionalCodePendingOfUse = false;
    Map<String, dynamic> userCharacteristicsMap = {
      "alcohol": data["userCharacteristics_alcohol"],
      "im_looking_for": data["userCharacteristics_what_he_looks_for"],
      "body_type": data["userCharacteristics_bodyType"],
      "children": data["userCharacteristics_children"],
      "pets": data["userCharacteristics_pets"],
      "politics": data["userCharacteristics_politics"],
      "im_living_with": data["userCharacteristics_lives_with"],
      "smoke": data["userCharacteristics_smokes"],
      "sexual_orientation": data["userCharacteristics_sexual_orientation"],
      "zodiac_sign": data["userCharacteristics_zodiak"],
      "personality": data["userCharacteristics_personality"]
    };
     
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
    verifyUserAge(data["userBirthDate"]);
    verifyUserCharacterisitcs(userCharacteristicsMap);

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
    await databases.createDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "reportModel",
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
          "reports": jsonEncode([""]),
          "penalizationState": PenalizationState.NOT_PENALIZED.name,
          "sanctionTimestamp": 0,
          "penalizationEndTimestamp": 0,
          "penalizationCounter": 0,
        });
    await databases.createDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "67334609000211639278",
        documentId: userId,
        data: {
          "userId":userId,
          "imageId": "NOT_AVAILABLE",
          "expectedHandGesture": "NOT_AVAILABLE",
          "verificationStatus":
              VerificationProcessStatus.VERIFICATION_NOT_INITIALIZED.name
        });

        await databases.createDocument(databaseId: "6729a8be001c8e5fa57a", collectionId: "usersToAvoid", documentId: userId, data: {
          "userId":userId,
          "usersToAvoid":[]
        });

        Map<String,double> coordenadas=transformarCoordenadas( data["positionLat"], data["positionLon"]);
        data["positionLat"]=coordenadas["latitud"];
        data["positionLon"]=coordenadas["longitud"];

    await databases.createDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        documentId: userId,
        data: {
          "userPicture1": data["userPicture1"],
          "userPicture2": data["userPicture2"],
          "userPicture3": data["userPicture3"],
          "userPicture4": data["userPicture4"],
          "userPicture5": data["userPicture5"],
          "userPicture6": data["userPicture6"],
          "userId": userId,
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
          "rewardTicketCode": createId(idLength: 6),
          "rewardTicketSuccesfulShares": 0,
          "promotionalCodeUsedByUser": promotionalCode,
          "isUserPromotionalCodeUsed": promotionalCodePendingOfUse,
          "userCharacteristics_alcohol": userCharacteristicsMap["alcohol"],
          "userCharacteristics_what_he_looks": userCharacteristicsMap["im_looking_for"],
          "userCharacteristics_bodyType": userCharacteristicsMap["body_type"],
          "userCharacteristics_children": userCharacteristicsMap["children"],
          "userCharacteristics_pets": userCharacteristicsMap["pets"],
          "userCharacteristics_politics": userCharacteristicsMap["politics"],
          "userCharacteristics_lives_with": userCharacteristicsMap["im_living_with"],
          "userCharacteristics_smokes": userCharacteristicsMap["smoke"],
          "userCharacteristics_sexualO": userCharacteristicsMap["sexual_orientation"],
          "userCharacteristics_zodiak": userCharacteristicsMap["zodiac_sign"],
          "userCharacteristics_personality": userCharacteristicsMap["personality"],
          "penalizationState": "NOT_PENALIZED",
          "penalizationEndDate": 0,
          "verificationImageLink": "NOT_AVAILABLE",
          "imageExpectedHandGesture": "NOT_AVAILABLE",
          "verificationStatus":VerificationProcessStatus.VERIFICATION_NOT_INITIALIZED.name,
          "adConsentFormShown": false,
          "adConsentFormShownDate":0,
          "showPersonalizedAds": false,
          "isBlindDateActive": true,
          "reactionAveragePoints": 0,
          "reactionCount": 0,
          "totalReactionPoints": 0,
        },
        permissions: [
          Permission.read(Role.user(data["userId"], "verified")),
        ]);

  } catch ( e,s) {

    context.log(s);

    
          
                      // Raw request body, contains request data

    if (e is AppwriteException) {
      
      

    return  context.res.json(
          {"status": 500, "message": "INTERNAL_ERROR", "details": e.message});
    } else {
     return context.res.json({
        "status": 500,
        "message": "INTERNAL_ERROR",
        "details": e.toString()
      });

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
