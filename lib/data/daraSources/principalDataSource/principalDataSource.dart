
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
class ApplicationDataSource {
  @protected
  Map<String, dynamic> _data = Map();
  String userId;
  StreamController<Map<String, dynamic>> dataStream =
      new StreamController.broadcast();
  ApplicationDataSource({required this.userId}){
    getDataFromDb();
    listenDataFromDb();
  }
  FirebaseFirestore db = FirebaseFirestore.instance;
  set setData(data) {
    this._data = data;
    dataStream.add(this._data);
  }
  get getData {
    return this._data;
  }
  void getDataFromDb() async {
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
  }}
abstract class DataSource {
  late ApplicationDataSource source;}