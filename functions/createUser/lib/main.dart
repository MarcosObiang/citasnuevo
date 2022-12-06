import 'dart:convert';
import 'package:blurhash_dart/blurhash_dart.dart';

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

    if (verifyPictureId(userPicturesIds, userId) &&
        verifyAppSettings(jsonDecode(data["userSettings"])) &&
        verifyPositionData(data["positionLat"], data["positionLon"]) &&
        verifyImageBlurHashes(userPicturesIds) &&
        verifyUserAge(data["birthDateInMilliseconds"]) &&
        verifyUserCharacterisitcs(jsonDecode(data["userCharacteristics"]))) {
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
            "userId": userId,
            "userBio": data["userBio"],
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
            "positionLon": data["positionLon"],
            "positionLat": data["positionLat"],
            "userCharacteristics": data["userCharacteristics"],
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
            "alcohol_attribute": userCharacteristicsMap["alcohol"],
            "imLookingfor_attribute": userCharacteristicsMap["Im_looking_for"],
            "bodyType_attribute": userCharacteristicsMap["body_type"],
            "children_attribute": userCharacteristicsMap["children"],
            "pets_attribute": userCharacteristicsMap["pets"],
            "politics_attribute": userCharacteristicsMap["politics"],
            "imLivingWith_attribute": userCharacteristicsMap["im_living_with"],
            "smoke_attribute": userCharacteristicsMap["smoke"],
            "sexualOrientation_attribute": userCharacteristicsMap["sexual_orientation"],
            "zodiacSign_attribute": userCharacteristicsMap["zodiac_sign"],
            "personality_attribute": userCharacteristicsMap["personality"],
          },
          permissions: [
            Permission.read(Role.user(data["userId"], "verified")),
          ]);

      res.json({
        'status': "correct",
      });
    } else {
      res.json({
        'status': "error",
      });
    }
  } catch (e, s) {
    if (e is AppwriteException) {
      res.json({'payload': e.message, "stackTrace": s.toString()});
    } else {
      res.json({'payload': e.toString(), "stackTrace": s.toString()});
    }
  }
}

///Verifies that user pictures ids are  in the expected format

bool verifyPictureId(
  List<Map<String, dynamic>?> pircutreIds,
  String userId,
) {
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
}

bool verifyUserCharacterisitcs(Map<String, dynamic> userCharacteristic) {
  try {
    int alcohol = userCharacteristic["alcohol"];
    int lookingFor = userCharacteristic["im_looking_for"];
    int bodyType = userCharacteristic["body_type"];
    int children = userCharacteristic["children"];
    int pets = userCharacteristic["pets"];
    int politics = userCharacteristic["politics"];
    int livingWith = userCharacteristic["im_living_with"];
    int smoke = userCharacteristic["smoke"];
    if ((alcohol >= 0 && alcohol <= 4) &&
        (lookingFor >= 0 && lookingFor <= 4) &&
        (bodyType >= 0 && bodyType <= 5) &&
        (children >= 0 && children <= 3) &&
        (pets >= 0 && pets <= 4) &&
        (politics >= 0 && politics <= 4) &&
        (livingWith >= 0 && livingWith <= 3) &&
        (smoke >= 0 && smoke <= 4)) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception("error_verification_user_characterisitcs: ${e.toString()}");
  }
}

bool verifyAppSettings(Map<String, dynamic> settingsData) {
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
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception("error_verification_user_settings: ${e.toString()}");
  }
}

bool verifyImageBlurHashes(List<Map<String, dynamic>> blurhashesList) {
  try {
    for (int i = 0; i < blurhashesList.length; i++) {
      if (blurhashesList[i]["imageId"] != "empty") {
        BlurHash.decode(blurhashesList[i]["hash"]);
      }
    }
    return true;
  } catch (e) {
    throw Exception(" image_hash_verification_error: ${e.toString()}");
  }
}

bool verifyPositionData(double lat, double lon) {
  try {
    if ((lat <= 90 && lat >= -90) && (lon <= 180 && lon >= -180)) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception("error_verification_position_coordinates: ${e.toString()}");
  }
}

bool verifyUserAge(int birthDateInMilliseconds) {
  try {
    DateTime dateTime = DateTime.now();

    if (dateTime.millisecondsSinceEpoch - birthDateInMilliseconds >=
        (567648000 * 1000)) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    throw Exception("error_verification_age: ${e.toString()}");
  }
}
