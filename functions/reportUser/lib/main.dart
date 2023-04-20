// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';

enum PenalizationState {
  NOT_PENALIZED,
  IN_MODERATION_WAITING,
  PENALIZED,
  IN_MODERATION_DONE
}

Future<void> start(final req, final res) async {
  try {
    Client client = Client()
        .setEndpoint('https://www.hottyserver.com/v1') // Your API Endpoint
        .setProject('636bd00b90e7666f0f6f') // Your project ID
        .setKey(
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824')
        .setSelfSigned(status: true);
    Databases databases = Databases(client);

    var data = jsonDecode(req.payload);
    String userReported = data["userReported"];
    String userId = data["userId"];
    String reportDetails = data["reportDetails"];
    bool includeMessages = data["includeMessages"];
    String chatId = data["chatId"];
    var reportProfile = await databases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374cbd1eb8543d64263",
        documentId: userReported);
    var userReportedProfile = await databases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: userReported);
    int amountReports = reportProfile.data["amountReports"];
    amountReports = amountReports + 1;
    print(reportProfile.data);

    List<dynamic> reportsList = reportProfile.data["reports"];
    reportsList.add(jsonEncode({
      "date": DateTime.now().millisecondsSinceEpoch,
      "details": reportDetails,
      "reportedBy": userId,
      "includeChat": includeMessages,
      "chatId": "",
    }));
    if (reportProfile.data["penalizedState"] ==
        PenalizationState.NOT_PENALIZED.name) {
      if (amountReports >= 3) {
        await databases.updateDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "6374cbd1eb8543d64263",
            documentId: userReported,
            data: {
              "reports": reportsList,
              "amountReports": amountReports,
              "penalizedState": PenalizationState.IN_MODERATION_WAITING.name
            });
        await databases.updateDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "636d59df12dcf7a399d5",
            documentId: userReported,
            data: {"penalizedState": PenalizationState.IN_MODERATION_WAITING.name});
      } else {
        await databases.updateDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "6374cbd1eb8543d64263",
            documentId: userReported,
            data: {
              "reports": reportsList,
              "amountReports": amountReports,
              "penalizedState": PenalizationState.NOT_PENALIZED.name
            });
      }
    }

    res.json({
      'status': 200,
    });
  } catch (e, s) {
    if (e is AppwriteException) {
      res.json({'status': 500, "mesage": "INTERNAL_ERROR", "stackTrace": s});
    } else {
      res.json({'status': 500, "mesage": "INTERNAL_ERROR", "stackTrace": s});
    }
  }
}
