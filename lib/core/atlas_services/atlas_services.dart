import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class Server {
  late Client client;
  late Account account;
  late Functions functions;


  Server() {
    initializeServer();
  }
  void initializeServer() async {
    client = Client();
    client.setEndpoint('https://cloud.appwrite.io/v1')..setProject('6723890e00073730d5e5');
    account = Account(client);
    functions = Functions(client);
  }
}
