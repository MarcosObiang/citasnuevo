import 'dart:convert';

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

enum PenalizationState {
  NOT_PENALIZED,
  IN_MODERATION_WAITING,
  PENALIZED,
  IN_MODERATION_DONE
}

Future<void> start(final req, final res) async {
  try {
    Client client = Client()
        .setEndpoint('https://www.hottyserver.com/v1')
        .setProject('636bd00b90e7666f0f6f')
        .setKey(
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824');
    var data = jsonDecode(req.payload);
    Databases database = Databases(client);

    String conversationId = data["conversationId"];
    bool userReported = data["userReported"];
    String userId = data["userId"];
    String reportDetails = data["reportDetails"];
    String userReportedId = data["userReportedId"];

    if (userReported) {
      var conversationData =
          await getConversationData(database, conversationId);
      DocumentList messagesList =
          await getConversationMessages(database, conversationId);
      var reportProfile = await getUserReportProfile(database, userReportedId);
      int amountReports = reportProfile.data["amountReports"];
      amountReports = amountReports + 1;

      List<dynamic> reportsList = reportProfile.data["reports"];
      reportsList.add(jsonEncode({
        "date": DateTime.now().millisecondsSinceEpoch,
        "details": reportDetails,
        "reportedBy": userId,
        "includeChat": userReported,
        "chatId": conversationData.$id,
      }));

      await updateUserReportProfile(
          database, userReportedId, reportsList, amountReports);
      await createReportConversationData(database, conversationData);
      for (var messageData in messagesList.documents) {
        await createReportMessageData(database, messageData);
      }
      await deleteConversationData(database, conversationId);

      for (int i = 0; i < messagesList.documents.length; i++) {
        await deleteMessageData(database, messagesList, i);
      }
    } else {
      await deleteConversationData(database, conversationId);

      DocumentList messagesList = await database.listDocuments(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "637d18ff8b3927cce18d",
          queries: [Query.equal("conversationId", conversationId)]);

      for (int i = 0; i < messagesList.documents.length; i++) {
        await deleteMessageData(database, messagesList, i);
      }
    }

    res.json({'status': 200, "message": "correct"});
  } catch (e, s) {
    if (e is AppwriteException) {
      print({'status': "error", "mesage": e.message, "stackTrace": s});

      res.json({
        'status': 500,
        "mesage": "INTERNAL_ERROR",
      });
    } else {
      print({'status': "error", "mesage": e.toString(), "stackTrace": s});
      res.json({
        'status': 500,
        "mesage": "INTERNAL_ERROR",
      });
    }
  }
}

Future<dynamic> deleteMessageData(
    Databases database, DocumentList messagesList, int i) {
  return database.deleteDocument(
      databaseId: "636d59d7a2f595323a79",
      collectionId: "637d18ff8b3927cce18d",
      documentId: messagesList.documents[i].$id);
}

Future<dynamic> deleteConversationData(
    Databases database, String conversationId) {
  return database.deleteDocument(
      databaseId: "636d59d7a2f595323a79",
      collectionId: "637d10c17be1c3d1544d",
      documentId: conversationId);
}

Future<Document> createReportMessageData(
    Databases database, Document messageData) {
  return database.createDocument(
      databaseId: "636d59d7a2f595323a79",
      collectionId: "6419c3fd20b84b6563b3",
      documentId: messageData.$id,
      data: {
        "conversationId": messageData.data["conversationId"],
        "timestamp": messageData.data["timestamp"],
        "readByReciever": messageData.data["readByReciever"],
        "senderId": messageData.data["senderId"],
        "recieverId": messageData.data["recieverId"],
        "messageContent": messageData.data["messageContent"],
        "messageType": messageData.data["messageType"],
        "messageId": messageData.$id
      });
}

Future<Document> createReportConversationData(
    Databases database, Document conversationData) {
  return database.createDocument(
    databaseId: "636d59d7a2f595323a79",
    collectionId: "641bf97f352c33a6b14a",
    documentId: conversationData.$id,
    data: {
      "converstationCreationTimestamp":
          conversationData.data["converstationCreationTimestamp"],
      "conversationId": conversationData.$id,
      "user1Picture": conversationData.data["user1Picture"],
      "user2Picture": conversationData.data["user2Picture"],
      "user1Name": conversationData.data["user1Name"],
      "user2Name": conversationData.data["user2Name"],
      "user1Id": conversationData.data["user1Id"],
      "user2Id": conversationData.data["user2Id"],
    },
  );
}

Future<Document> updateUserReportProfile(Databases database,
    String userReportedId, List<dynamic> reportsList, int amountReports) async {
  if (amountReports >= 3) {
    await database.updateDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374cbd1eb8543d64263",
        documentId: userReportedId,
        data: {
          "reports": reportsList,
          "amountReports": amountReports,
          "penalizedState": PenalizationState.IN_MODERATION_WAITING.name
        });
    return database.updateDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: userReportedId,
        data: {"penalizedState": PenalizationState.IN_MODERATION_WAITING.name});
  } else {
    return database.updateDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374cbd1eb8543d64263",
        documentId: userReportedId,
        data: {"reports": reportsList, "amountReports": amountReports});
  }
}

Future<Document> getUserReportProfile(
    Databases database, String userReportedId) {
  return database.getDocument(
      databaseId: "636d59d7a2f595323a79",
      collectionId: "6374cbd1eb8543d64263",
      documentId: userReportedId);
}

Future<DocumentList> getConversationMessages(
    Databases database, String conversationId) {
  return database.listDocuments(
      databaseId: "636d59d7a2f595323a79",
      collectionId: "637d18ff8b3927cce18d",
      queries: [Query.equal("conversationId", conversationId)]);
}

Future<Document> getConversationData(
    Databases database, String conversationId) {
  return database.getDocument(
      databaseId: "636d59d7a2f595323a79",
      collectionId: "637d10c17be1c3d1544d",
      documentId: conversationId);
}
