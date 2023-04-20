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

    final data = jsonDecode(req.payload);

    bool updateToken = data["updateToken"];
    bool deleteToken = data["deleteToken"];
    String userId = data["userId"];
    var userConversationsWhereIsUser1 = await databases.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "637d10c17be1c3d1544d",
        queries: [Query.equal("user1Id", userId)]);
    var userConversationsWhereIsUser2 = await databases.listDocuments(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "637d10c17be1c3d1544d",
        queries: [Query.equal("user2Id", userId)]);
    if (updateToken) {
      String token = data["token"];
      print(data);
      await databases.updateDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: userId,
          data: {"notificationToken": token});
      for (var element in userConversationsWhereIsUser1.documents) {
        await databases.updateDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "637d10c17be1c3d1544d",
            documentId: element.$id,
            data: {"user1NotificationToken": token});
      }
      for (var element in userConversationsWhereIsUser2.documents) {
        await databases.updateDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "637d10c17be1c3d1544d",
            documentId: element.$id,
            data: {"user2NotificationToken": token});
      }
    }
    if (deleteToken) {
      await databases.updateDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: userId,
          data: {"notificationToken": ""});
      for (var element in userConversationsWhereIsUser1.documents) {
        await databases.updateDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "637d10c17be1c3d1544d",
            documentId: element.$id,
            data: {"user1NotificationToken": ""});
      }
      for (var element in userConversationsWhereIsUser2.documents) {
        await databases.updateDocument(
            databaseId: "636d59d7a2f595323a79",
            collectionId: "637d10c17be1c3d1544d",
            documentId: element.$id,
            data: {"user2NotificationToken": ""});
      }
    }

    res.json({
      'status': "correct",
    });
  } catch (e, s) {
    if (e is AppwriteException) {
      res.json({'status': "error", "mesage": e.message, "stackTrace": s});
    } else {
      res.json({'status': "error", "mesage": e.toString(), "stackTrace": s});
    }
  }
}
