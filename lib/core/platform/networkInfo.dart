import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

abstract class NetworkInfoContract {
  Future<bool> get isConnected;
  Future<bool> checkConnection();
}

class NetworkInfoImpl implements NetworkInfoContract {
  static NetworkInfoImpl networkInstance = new NetworkInfoImpl();
  late Future<bool> connected;
  @override
  Future<bool> get isConnected => checkConnection();
  NetworkInfoImpl();
  @override
  Future<bool> checkConnection() async {
    bool internet = await SimpleConnectionChecker.isConnectedToInternet(
        lookUpAddress: "www.google.com");

    return internet;
  }
}

abstract class NetwrokServices {
  late NetworkInfoContract networkInfoContract;
}

abstract class UsesServerFunctions {
  late Functions functinos;
}

abstract class UsesServerDatabase {
  late Databases databases;
}

abstract class Mapper<T> {
  T fromMap(Map<String, dynamic> data);
  Map<String, dynamic> toMap(T data);
}

abstract class UsesMapper<T> {
  late Mapper<T> mapper;
}
