import 'dart:async';

import 'package:simple_connection_checker/simple_connection_checker.dart';

abstract class NetworkInfoContract {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfoContract {
  static NetworkInfoImpl networkInstance = new NetworkInfoImpl();
  late Future<bool> connected;
  @override
  Future<bool> get isConnected => checkConnection();
  NetworkInfoImpl();

  Future<bool> checkConnection() async {
    bool internet = await SimpleConnectionChecker.isConnectedToInternet(
        lookUpAddress: "www.hottyserver.com");

    return internet;
  }
}
