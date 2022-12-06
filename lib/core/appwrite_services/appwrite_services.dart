import 'package:appwrite/appwrite.dart';

class Server {
  Client? client;
  Account? account;
  Server() {
    initializeServer();
  }

  void initializeServer() async {
    client = Client()
        .setEndpoint('https://www.hottyserver.com/v1') // Your Appwrite Endpoint
        .setProject('636bd00b90e7666f0f6f') // Your project ID
        .setSelfSigned(status: true);
        account= Account(client!);
  }
}
