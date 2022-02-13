import 'dart:async';
import 'package:citasnuevo/data/Mappers/ConverterDefinition.dart';
import 'package:citasnuevo/data/Mappers/ReactionsMappers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ApplicationDataSource {
  @protected
  Map<String, dynamic> _data = Map();
  String userId;
  StreamController<Map<String, dynamic>> dataStream =
      new StreamController.broadcast();
  ApplicationDataSource({required this.userId});

  Future<void> initializeMainDataSource() async {
    await getDataFromDb();
    listenDataFromDb();
  }

  FirebaseFirestore db = FirebaseFirestore.instance;
  set setData(data) {
    this._data = data;
    dataStream.add(this._data);
  }

  Map<String, dynamic> get getData {
    return this._data;
  }

  Future<void> getDataFromDb() async {
    DocumentSnapshot document =
        await db.collection("usuarios").doc(userId).get();
    setData = document.data() as Map<String, dynamic>;
  }

  void listenDataFromDb() async {
    db
        .collection("usuarios")
        .where("id", isEqualTo: userId)
        .snapshots()
        .listen((event) {
      setData = event.docs.first.data();
      dataStream.add(_data);
    });
  }
}

abstract class DataSource<T> {
  /// Subscribe to the source to get the data from the backend
  late ApplicationDataSource source;

  ///Must be called before any method in the class so get the data needed
  ///
  ///from the source
  void subscribeToMainDataSource();

  late DataSourceConverter<T> dataConverter;
}
