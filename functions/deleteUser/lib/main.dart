import 'dart:convert';
import 'dart:io';

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

Future<dynamic> main(final context) async {
  try {
    String apiKey = Platform.environment["APPWRITE_FUNCTIONS_APIKEY"]!;
    String? projectId = Platform.environment["PROJECT_ID"];
    String? userCollectionId = Platform.environment["USER_DATA_COLELCTION_ID"];
    String? databaseId = Platform.environment["DATABASE_ID"];
    String? chatCollectionId =
        Platform.environment["CONVERSATION_COLLECTION_ID"];
    String? reportedChatCollectionId =
        Platform.environment["REPORTED_CHAT_COLLECTION_ID"];

    String? reactionsCollectionId =
        Platform.environment["REACTIONS_COLLECTION_ID"];
    String? privateReactionsCollectionId =
        Platform.environment["PRIVATE_REACTIONS_COLLECTION_ID"];

    String? reportsCollectionId = Platform.environment["REPORTS_COLLECTION_ID"];

    String? messagesCollectionId =
        Platform.environment["MESSAGES_COLLECTION_ID"];
    String? usersToAvoidCollectionId =
        Platform.environment["USERS_TO_AVOID_COLLECTION_ID"];

    String? reportdMessagesCollectionId =
        Platform.environment["REPORTED_MESSAGES_COLLECTION_ID"];

    String? verificationCollectionId =
        Platform.environment["VERIFICATION_COLLECTION_ID"];

    Client client = Client()
        .setEndpoint('https://cloud.appwrite.io/v1') // Your API Endpoint
        .setProject(projectId as String)
        .setKey(apiKey);
    Databases databases = Databases(client);
    Users users = Users(client);
    Storage storage = Storage(client);

    final data = context.req.bodyJson;
    String userId = data["userId"];
    List<String> chatIds = [];
// Delete reactions private
    var privateReactions = await databases.listDocuments(
        databaseId: databaseId as String,
        collectionId: privateReactionsCollectionId as String,
        queries: [Query.equal("senderId", userId)]);
// Delete reactions
    var reactions = await databases.listDocuments(
        databaseId: databaseId as String,
        collectionId: reactionsCollectionId as String,
        queries: [Query.equal("senderId", userId)]);

// Chats
    var chats1 = await databases.listDocuments(
        databaseId: databaseId as String,
        collectionId: chatCollectionId as String,
        queries: [Query.equal("user1Id", userId)]);
    var chats2 = await databases.listDocuments(
        databaseId: databaseId as String,
        collectionId: chatCollectionId as String,
        queries: [Query.equal("user2Id", userId)]);
// User report profiles

    var userReportProfile = await databases.listDocuments(
        databaseId: databaseId as String,
        collectionId: reportsCollectionId as String,
        queries: [Query.equal("userId", userId)]);

    for (var element in privateReactions.documents) {
      await databases.deleteDocument(
          databaseId: databaseId as String,
          collectionId: privateReactionsCollectionId as String,
          documentId: element.$id);
    }
    for (var element in reactions.documents) {
      await databases.deleteDocument(
          databaseId: databaseId as String,
          collectionId: reactionsCollectionId,
          documentId: element.$id);
    }

    for (var element in chats1.documents) {
      chatIds.add(element.$id);
      await databases.deleteDocument(
          databaseId: databaseId as String,
          collectionId: chatCollectionId as String,
          documentId: element.$id);
    }
    for (var element in chats2.documents) {
      chatIds.add(element.$id);

      await databases.deleteDocument(
          databaseId: databaseId as String,
          collectionId: chatCollectionId as String,
          documentId: element.$id);
    }
    for (var element in userReportProfile.documents) {
      await databases.deleteDocument(
          databaseId: databaseId as String,
          collectionId: reportsCollectionId,
          documentId: element.$id);
    }

    for (String element in chatIds) {
      var messagesList = await databases.listDocuments(
          databaseId: databaseId as String,
          collectionId: messagesCollectionId as String,
          queries: [Query.equal("conversationId", element)]);
      for (var messages in messagesList.documents) {
        await databases.deleteDocument(
            databaseId: databaseId as String,
            collectionId: messagesCollectionId as String,
            documentId: messages.$id);
      }
    }
    var userDocument = await databases.getDocument(
        databaseId: databaseId as String,
        collectionId: userCollectionId as String,
        documentId: userId);

    Map<String, dynamic> userImage1 =
        jsonDecode(userDocument.data["userPicture1"]);
    Map<String, dynamic> userImage2 =
        jsonDecode(userDocument.data["userPicture2"]);
    Map<String, dynamic> userImage3 =
        jsonDecode(userDocument.data["userPicture3"]);
    Map<String, dynamic> userImage4 =
        jsonDecode(userDocument.data["userPicture4"]);
    Map<String, dynamic> userImage5 =
        jsonDecode(userDocument.data["userPicture5"]);
    Map<String, dynamic> userImage6 =
        jsonDecode(userDocument.data["userPicture6"]);
    if (userImage1["imageData"] != "NOT_AVAILABLE") {
      await storage.deleteFile(
          bucketId: "userPictures", fileId: userImage1["imageData"]);
    }
    if (userImage2["imageData"] != "NOT_AVAILABLE") {
      await storage.deleteFile(
          bucketId: "userPictures", fileId: userImage2["imageData"]);
    }
    if (userImage3["imageData"] != "NOT_AVAILABLE") {
      await storage.deleteFile(
          bucketId: "userPictures", fileId: userImage3["imageData"]);
    }
    if (userImage4["imageData"] != "NOT_AVAILABLE") {
      await storage.deleteFile(
          bucketId: "userPictures", fileId: userImage4["imageData"]);
    }
    if (userImage5["imageData"] != "NOT_AVAILABLE") {
      await storage.deleteFile(
          bucketId: "userPictures", fileId: userImage5["imageData"]);
    }
    if (userImage6["imageData"] != "NOT_AVAILABLE") {
      await storage.deleteFile(
          bucketId: "userPictures", fileId: userImage6["imageData"]);
    }
    await databases.deleteDocument(
        databaseId: databaseId as String,
        collectionId: usersToAvoidCollectionId as String,
        documentId: userId);

    await databases.deleteDocument(
        databaseId: databaseId as String,
        collectionId: userCollectionId as String,
        documentId: userId);

    await databases.deleteDocument(
        databaseId: databaseId as String,
        collectionId: verificationCollectionId as String,
        documentId: userId);

    await users.delete(userId: userId);

    return context.res
        .json({"message": "REQUEST_SUCCESFULL", "details": "COMPLETED"}, 200);
  } catch (e, s) {
    if (e is AppwriteException) {
      context.log({'status': "error", "mesage": e.message, "stackTrace": s});

      return context.res
          .json({"message": "INTERNAL_ERROR", "details": "COMPLETED"}, 500);
    } else {
      context.log({'status': "error", "mesage": e.toString(), "stackTrace": s});

      return context.res
          .json({"message": "INTERNAL_ERROR", "details": "COMPLETED"}, 500);
    }
  }
}
