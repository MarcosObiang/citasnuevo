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

enum PenalizationState {
  NOT_PENALIZED,
  IN_MODERATION_WAITING,
  PENALIZED,
  IN_MODERATION_DONE
}

Future<dynamic> main(final context) async {
  try {
    String apiKey = Platform.environment["APPWRITE_FUNCTIONS_APIKEY"]!;
    String? projectId = Platform.environment["PROJECT_ID"];
    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject(projectId as String)
        .setKey(apiKey);
    final data = context.req.bodyJson;

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

      List<dynamic> reportsList = jsonDecode(reportProfile.data["reports"]);
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
          databaseId: "6729a8be001c8e5fa57a",
          collectionId: "messages",
          queries: [Query.equal("conversationId", conversationId)]);

      for (int i = 0; i < messagesList.documents.length; i++) {
        await deleteMessageData(database, messagesList, i);
      }
    }

    return context.res.json({
      "message": "REQUEST_SUCCESFULL",
      "details": "CHAT_DELETED_SUCCESSFULLY"
    }, 200);
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({'status': "error", "message": e.message, "stackTrace": s});

      return context.res.json(
          {"message": "INTERNAL_ERROR", "details": "SOMETHING_WENT_WRONG"}, 500);
    } else {
      context.log({'status': "error", "message": e.toString(), "stackTrace": s});
      return context.res.json(
          {"message": "INTERNAL_ERROR", "details": "SOMETHING_WENT_WRONG"}, 500);
    }
  }
}

Future<dynamic> deleteMessageData(
    Databases database, DocumentList messagesList, int i) {
  return database.deleteDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "messages",
      documentId: messagesList.documents[i].$id);
}

Future<dynamic> deleteConversationData(
    Databases database, String conversationId) {
  return database.deleteDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "conversations",
      documentId: conversationId);
}

Future<Document> createReportMessageData(
    Databases database, Document messageData) {
  return database.createDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "reportedMessages",
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
    databaseId: "6729a8be001c8e5fa57a",
    collectionId: "reportedConversations",
    documentId: conversationData.$id,
    data: {
      "converstationCreationtimestamp":
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
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "reportModel",
        documentId: userReportedId,
        data: {
          "reports": jsonEncode(reportsList),
          "amountReports": amountReports,
          "penalizedState": PenalizationState.IN_MODERATION_WAITING.name
        });
    return database.updateDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "6729a8c50029409cd062",
        documentId: userReportedId,
        data: {"penalizedState": PenalizationState.IN_MODERATION_WAITING.name});
  } else {
    return database.updateDocument(
        databaseId: "6729a8be001c8e5fa57a",
        collectionId: "reportModel",
        documentId: userReportedId,
        data: {"reports": jsonEncode(reportsList), "amountReports": amountReports});
  }
}

Future<Document> getUserReportProfile(
    Databases database, String userReportedId) {
  return database.getDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "reportModel",
      documentId: userReportedId);
}

Future<DocumentList> getConversationMessages(
    Databases database, String conversationId) {
  return database.listDocuments(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "messages",
      queries: [Query.equal("conversationId", conversationId)]);
}

Future<Document> getConversationData(
    Databases database, String conversationId) {
  return database.getDocument(
      databaseId: "6729a8be001c8e5fa57a",
      collectionId: "conversations",
      documentId: conversationId);
}
