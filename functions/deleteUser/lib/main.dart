import 'dart:convert';

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
            'fea5a4834f59d20452556c1425ff812265a90d6a0f06ca7f6785663bdc37ce41e1e17b3bb81c73e0d2e236654136e7b4b00e41c735f07cb69c0bc8a1ffe97db7000b9f891ec582eb7359842ed1d12723b98ab6b46588076079bbf95438d767baab61dd4b8da8070ea6f0e0f914f86667361285c50a5fe4ac22be749b3dfea824')
        .setSelfSigned(status: true);

    Databases databases = Databases(client);
    Users users = Users(client);
    Storage storage = Storage(client);

    var data = jsonDecode(req.payload);
    String userId = data["userId"];
    List<String> chatIds = [];
// Delete reactions private
    var privateReactions = await databases.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374fc078b95d03fb3c1",
        queries: [Query.equal("senderId", userId)]);
// Delete reactions
    var reactions = await databases.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374fe10e76d07bfe639",
        queries: [Query.equal("senderId", userId)]);

// Chats
    var chats1 = await databases.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "637d10c17be1c3d1544d",
        queries: [Query.equal("user1Id", userId)]);
    var chats2 = await databases.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "637d10c17be1c3d1544d",
        queries: [Query.equal("user2Id", userId)]);
// User report profiles

    var userReportProfile = await databases.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "6374cbd1eb8543d64263",
        queries: [Query.equal("userId", userId)]);

    for (var element in privateReactions.documents) {
      await databases.deleteDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "6374fc078b95d03fb3c1",
          documentId: element.$id);
    }
    for (var element in reactions.documents) {
      await databases.deleteDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "6374fe10e76d07bfe639",
          documentId: element.$id);
    }
    for (var element in reactions.documents) {
      await databases.deleteDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "6374fe10e76d07bfe639",
          documentId: element.$id);
    }
    for (var element in chats1.documents) {
      chatIds.add(element.$id);
      await databases.deleteDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "637d10c17be1c3d1544d",
          documentId: element.$id);
    }
    for (var element in chats2.documents) {
      chatIds.add(element.$id);

      await databases.deleteDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "637d10c17be1c3d1544d",
          documentId: element.$id);
    }
    for (var element in userReportProfile.documents) {
      await databases.deleteDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "6374cbd1eb8543d64263",
          documentId: element.$id);
    }

    for (String element in chatIds) {
      var messagesList = await databases.listDocuments(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "637d18ff8b3927cce18d",
          queries: [Query.equal("conversationId", element)]);
      for (var messages in messagesList.documents) {
        await databases.deleteDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "637d18ff8b3927cce18d",
            documentId: messages.$id);
      }
    }
    var userDocument = await databases.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
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
    if (userImage1["imageId"] != "empty") {
      await storage.deleteFile(
          bucketId: "63712fd65399f32a5414", fileId: userImage1["imageId"]);
    }
    if (userImage2["imageId"] != "empty") {
      await storage.deleteFile(
          bucketId: "63712fd65399f32a5414", fileId: userImage2["imageId"]);
    }
    if (userImage3["imageId"] != "empty") {
      await storage.deleteFile(
          bucketId: "63712fd65399f32a5414", fileId: userImage3["imageId"]);
    }
    if (userImage4["imageId"] != "empty") {
      await storage.deleteFile(
          bucketId: "63712fd65399f32a5414", fileId: userImage4["imageId"]);
    }
    if (userImage5["imageId"] != "empty") {
      await storage.deleteFile(
          bucketId: "63712fd65399f32a5414", fileId: userImage5["imageId"]);
    }
    if (userImage6["imageId"] != "empty") {
      await storage.deleteFile(
          bucketId: "63712fd65399f32a5414", fileId: userImage6["imageId"]);
    }
    await databases.deleteDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: userId);

    await users.delete(userId: userId);

    res.json({
      'status': "correct",
    });
  } catch (e, s) {
    print(e.toString());
    if (e is AppwriteException) {
      res.json({'status': "error", "mesage": e.message, "stackTrace": s});
    } else {
      res.json({'status': "error", "mesage": e.toString(), "stackTrace": s});
    }
  }
}
