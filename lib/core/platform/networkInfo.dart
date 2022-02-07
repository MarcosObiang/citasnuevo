import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class NetworkInfoContract {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfoContract {
  static NetworkInfoImpl networkInstance = new NetworkInfoImpl();
  FirebaseDatabase instance = FirebaseDatabase.instance;
  late Future<bool> connected;
  StreamSubscription<DatabaseEvent>? databaseConnectedStreamEvent;
  @override
  Future<bool> get isConnected => checkConnection();
  NetworkInfoImpl();

  Future<bool> checkConnection() async {
    bool internet = await SimpleConnectionChecker.isConnectedToInternet(
        lookUpAddress: "firestore.googleapis.com");

    return internet;
  }

  void startNetworkStatusListener() async {
    connected = SimpleConnectionChecker.isConnectedToInternet(
        lookUpAddress: "firestore.googleapis.com");

    instance.ref().child(".info/connected").onValue.listen((event) async {
      if (event.snapshot.value == true) {
        connected = SimpleConnectionChecker.isConnectedToInternet();
      } else {
        connected = SimpleConnectionChecker.isConnectedToInternet();
      }
    }).onError((_) {
      print("object");
    });

    instance
        .ref()
        .child("/status/VFXR80UHWMX2Qc1ZIelXZbVjlrD3")
        .onDisconnect()
        .update({
      "idDispositivo": " InformacionDispositivo.instancia.getIdDispositivo",
      "nombreDispositivo":
          "InformacionDispositivo.instancia.getNombreDispositivo",
      "Status": "Desconectado",
      "Hora": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "idUsuario": "VFXR80UHWMX2Qc1ZIelXZbVjlrD3",
      "sesionCerrada": false
    });
  }

  void cancelDatabaseStreamSubscription() async {
    databaseConnectedStreamEvent?.cancel();
    databaseConnectedStreamEvent = null;
  }
}
