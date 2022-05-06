import 'dart:async';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

///MANDATORY:use the [ApplicationDataSource] in any class that will act as a [DataSource]
///
///Pricipal source of data in the app
///
///Due to the database design, most of the user data is centralized
///
///Only the chats, reactions and chat messages (we are talking about the data the user from his device can read) are separated in the backend
///
///Via [ApplicationDataSource] we can access the centralized user data and listen to updates (user pictures,user id,user name, user credits... and more), this will work as a main data source to all types of
///data sources in case they need to acces to the same information
class ApplicationDataSource {
  @protected
  Map<String, dynamic> _data = Map();
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> appSubscription;
  String? userId;
  FirebaseFirestore db = FirebaseFirestore.instance;
  StreamController<Map<String, dynamic>> dataStream =
      new StreamController.broadcast();
  set setData(data) {
    this._data = data;
    dataStream.add(this._data);
  }

  Map<String, dynamic> get getData {
    return this._data;
  }

  ApplicationDataSource({required this.userId});

  Future<bool> initializeMainDataSource() async {
    if (this.userId != null) {
      if (await userDataExists() == true) {
        await getDataFromDb();
        listenDataFromDb();
        return true;
      } else {
        return false;
      }
    } else {
      throw Exception("USER_ID_CANNOT_BE_NULL");
    }
  }

  Future<void> getDataFromDb() async {
    DocumentSnapshot document =
        await db.collection("usuarios").doc(userId).get();
    setData = document.data() as Map<String, dynamic>;
  }

  Future<bool> userDataExists() async {
    var dor = await db.collection("usuarios").doc(userId).get();

    return dor.exists;
  }

  void listenDataFromDb() async {
    appSubscription = db
        .collection("usuarios")
        .where("id", isEqualTo: userId)
        .snapshots()
        .listen((event) {
      setData = event.docs.first.data();
    });
  }

  void clearAppDataSource() {
    appSubscription.cancel();
    _data.clear();
  }
}

abstract class DataSource implements ModuleCleaner {
  /// Subscribe to the source to get the data from the backend
  late ApplicationDataSource source;

  late StreamSubscription sourceStreamSubscription;

  ///Must be called before any method in the class to get the data needed
  ///
  ///From the source
  void subscribeToMainDataSource();
}
