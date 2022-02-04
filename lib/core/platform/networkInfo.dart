import 'dart:async';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:firebase_database/firebase_database.dart';
abstract class NetworkInfoContract {
  Future<bool> get isConnected;}
class NetworkInfoImpl implements NetworkInfoContract {
//  final DataConnectionChecker connectionChecker;
  static  NetworkInfoImpl networkInstance= new NetworkInfoImpl();
  FirebaseDatabase instance = FirebaseDatabase.instance;
  late Future<bool> connected;
  @override
  Future<bool> get isConnected => connected;
  NetworkInfoImpl() {
    startNetworkStatusListener();
  }
  void startNetworkStatusListener() async {
    connected = SimpleConnectionChecker.isConnectedToInternet();
    instance.ref().child(".info/connected").onValue.listen((event) async {
      if (event.snapshot.value == true) {
        connected = SimpleConnectionChecker.isConnectedToInternet();
      } else {
        connected = SimpleConnectionChecker.isConnectedToInternet();
      }
    });
  }}