import 'dart:convert';

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

Future<void> start(final req, final res) async {
  try {
    Client client = Client()
        .setEndpoint('https://www.hottyserver.com/v1') // Your API Endpoint
        .setProject('636bd00b90e7666f0f6f') // Your project ID
        .setKey(
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824')
        .setSelfSigned(status: true);

    final database = Databases(client);
    var data = jsonDecode(req.payload);
    List<String> usersFetched = [];
    double currentLon = data["lon"];
    double currentLat = data["lat"];
    int maxDistance = data["distance"];
    String userId = data["userId"];
    await database.updateDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "64510456c91ba8281a51",
        documentId: userId,
        data: {"positionLon": currentLon, "positionLat": currentLat});
    DocumentList documentList = await database.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "64510456c91ba8281a51",
        queries: [
          Query.greaterThanEqual(
              "positionLon", getMinLongitude(currentLon, maxDistance)),
          Query.lessThanEqual(
              "positionLon", getMaxLongitude(currentLon, maxDistance)),
          Query.greaterThanEqual(
              "positionLat", getMinLatitude(currentLat, maxDistance)),
          Query.lessThanEqual(
              "positionLat", getMaxLatitude(currentLat, maxDistance)),
        ]);

    res.json({
      "status": 200,
      "message": "correct",
      'payload': jsonEncode(processUserData(
          documentList: documentList.documents,
          currentLat: currentLat,
          currentLon: currentLon,
          userId: userId)),
    });
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
    double userLon = documentList[i].data["positionLon"];
    double userLat = documentList[i].data["positionLat"];
    GeoRange geoRange = GeoRange();
    Point startCoordinate = Point(latitude: currentLat, longitude: currentLon);
    Point endCoordinate = Point(latitude: userLat, longitude: userLon);
    if (userId != documentList[i].$id) {
      int userDistance =
          geoRange.distance(startCoordinate, endCoordinate).toInt();

      int userBirthDateInMillisecondsSinceEpoch =
          documentList[i].data["profileBirthDate"];
      int userAge = DateTime.now()
              .difference(DateTime.fromMillisecondsSinceEpoch(
                  userBirthDateInMillisecondsSinceEpoch))
              .inDays ~/
          365;

      Map<String, dynamic> dataToJson = {
        "profileId": documentList[i].data["profileId"],
        "profileSex": documentList[i].data["profileSex"],
        "distance": userDistance,
        "userAge": userAge,
      };
      returnData.add(dataToJson);
    }
  }

  return returnData;
}

double getMaxLongitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));
  lon = lon + 360;

  for (int i = 0; i < distance; i++) {
    lon = lon + 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  double result = lon - 360;
  return result;
}

double getMinLongitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));
  lon = lon + 360;

  for (int i = 0; i < distance; i++) {
    lon = lon - 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  double result = lon - 360;
  return result;
}

double getMaxLatitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));
  lon = lon + 90;

  for (int i = 0; i < distance; i++) {
    lon = lon + 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  double result = lon - 90;
  return result;
}

double getMinLatitude(double currentLon, int distance) {
  double lon = double.parse(currentLon.toStringAsFixed(1));
  lon = lon + 90;

  for (int i = 0; i < distance; i++) {
    lon = lon - 0.1;
    lon = double.parse(lon.toStringAsFixed(1));
  }
  double result = lon - 98;
  return result;
}
