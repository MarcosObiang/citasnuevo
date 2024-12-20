import 'dart:convert';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';
import 'package:georange/georange.dart';

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
    List<String> usersFetched = [];
    double currentLon = double.parse((data["lon"] + 180 as double).toStringAsFixed(1));
    double currentLat = double.parse((data["lat"] + 90 as double).toStringAsFixed(1));
    int maxDistance = data["distance"];
    String userId = data["userId"];
    await database.updateDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        documentId: userId,
        data: {
          "userLongitude": [currentLon],
          "userLatitude": currentLat
        });

        context.log(getAllLongitudesRange(currentLon, maxDistance));

    DocumentList documentList = await database.listDocuments(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        queries: [
          Query.orderDesc("lastRatingTimestamp"),

          Query.equal(
              "userLongitude", getAllLongitudesRange(currentLon, maxDistance)),
          Query.greaterThanEqual(
              "userLatitude", getMinLatitude(currentLat, maxDistance)),
          Query.lessThanEqual(
              "userLatitude", getMaxLatitude(currentLat, maxDistance)),
        ]);

    return context.res.json({
      "message": "REQUEST_SUCCESFULL",
      "details": "COMPLETED",
      "payload": jsonEncode(processUserData(
          documentList: documentList.documents,
          currentLat: currentLat,
          currentLon: currentLon,
          userId: userId))
    }, 200);
  } catch (e) {
    if (e is AppwriteException) {
      return context.res
          .json({"message": "INTERNAL_ERROR", "details": e.message}, 500);
    } else {
      return context.res
          .json({"message": "INTERNAL_ERROR", "details": e.toString()}, 500);
    }
  }
}

List<Map<String, dynamic>> processUserData(
    {required List<Document> documentList,
    required double currentLat,
    required double currentLon,
    required String userId}) {
  List<Map<String, dynamic>> returnData = [];

  for (int i = 0; i < documentList.length; i++) {
    double userLon = documentList[i].data["userLongitude"][0];
    double userLat = documentList[i].data["userLatitude"];
    GeoRange geoRange = GeoRange();
    Point startCoordinate = Point(latitude: currentLat -90, longitude: currentLon-180);
    Point endCoordinate = Point(latitude: userLat-90, longitude: userLon-180);
    if (userId != documentList[i].$id) {
      int userDistance =
          geoRange.distance(startCoordinate, endCoordinate).toInt();

      int userBirthDateInMillisecondsSinceEpoch =
          documentList[i].data["userBirthDate"];
      int userAge = DateTime.now()
              .difference(DateTime.fromMillisecondsSinceEpoch(
                  userBirthDateInMillisecondsSinceEpoch))
              .inDays ~/
          365;

      Map<String, dynamic> dataToJson = {
        "userId": documentList[i].data["userId"],
        "userName": documentList[i].data["userName"],
        "userSex": documentList[i].data["userSex"],
        "userBio": documentList[i].data["userBio"],
        "distance": userDistance,
        "userAge": userAge,
        "userPicture1": jsonDecode(documentList[i].data["userPicture1"]),
        "userPicture2": jsonDecode(documentList[i].data["userPicture2"]),
        "userPicture3": jsonDecode(documentList[i].data["userPicture3"]),
        "userPicture4": jsonDecode(documentList[i].data["userPicture4"]),
        "userPicture5": jsonDecode(documentList[i].data["userPicture6"]),
        "userPicture6": jsonDecode(documentList[i].data["userPicture6"]),
        "userCharacteristics_alcohol":
            documentList[i].data["userCharacteristics_alcohol"],
        "userCharacteristics_what_he_looks":
            documentList[i].data["userCharacteristics_what_he_looks"],
        "userCharacteristics_bodyType":
            documentList[i].data["userCharacteristics_bodyType"],
        "userCharacteristics_children":
            documentList[i].data["userCharacteristics_children"],
        "userCharacteristics_pets":
            documentList[i].data["userCharacteristics_pets"],
        "userCharacteristics_politics":
            documentList[i].data["userCharacteristics_politics"],
        "userCharacteristics_lives_with":
            documentList[i].data["userCharacteristics_lives_with"],
        "userCharacteristics_smokes":
            documentList[i].data["userCharacteristics_smokes"],
        "userCharacteristics_sexualO":
            documentList[i].data["userCharacteristics_sexualO"],
        "userCharacteristics_zodiak":
            documentList[i].data["userCharacteristics_zodiak"],
        "userCharacteristics_personality":
            documentList[i].data["userCharacteristics_personality"],
      };
      returnData.add(dataToJson);
    }
  }

  return returnData;
}



List<double> getAllLongitudesRange(double currentLon, int distance) {
  List<double> longitudes = [];
  double firstLongitude = currentLon;
  double finalLongitude = firstLongitude - 0.1;
  longitudes.add(finalLongitude);
  longitudes.add(currentLon);

  for (int i = 0; i < 5; i++) {
    finalLongitude = finalLongitude - 0.1;

    longitudes.add(double.parse(finalLongitude.toStringAsFixed(1)));
  }

  finalLongitude = firstLongitude + 0.1;
  longitudes.add(finalLongitude);

  for (int i = 0; i < 5; i++) {
    finalLongitude = finalLongitude + 0.1;

    longitudes.add(double.parse(finalLongitude.toStringAsFixed(1)));
  }

  return longitudes;
}


double getMaxLatitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));

  for (int i = 0; i < distance; i++) {
    lon = lon + 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  return lon;
}

double getMinLatitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));

  for (int i = 0; i < distance; i++) {
    lon = lon - 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  return lon;
}
