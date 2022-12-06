import 'dart:async';
import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/globalData.dart';
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
  StreamSubscription<RealtimeMessage>? appSubscription;
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
    var dataToUse;
    Databases database = Databases(Dependencies.serverAPi.client!);
    var userData = await database.getDocument(
        databaseId: "636d59d7a2f595323a79",
        collectionId: "636d59df12dcf7a399d5",
        documentId: GlobalDataContainer.userId!);

    dataToUse = userData.data;
    dataToUse["userPicture1"] = jsonDecode(dataToUse["userPicture1"]);
    dataToUse["userPicture2"] = jsonDecode(dataToUse["userPicture2"]);
    dataToUse["userPicture3"] = jsonDecode(dataToUse["userPicture3"]);
    dataToUse["userPicture4"] = jsonDecode(dataToUse["userPicture4"]);
    dataToUse["userPicture5"] = jsonDecode(dataToUse["userPicture5"]);
    dataToUse["userPicture6"] = jsonDecode(dataToUse["userPicture6"]);


    dataToUse["userSettings"] = jsonDecode(dataToUse["userSettings"]);

    setData = dataToUse;
  }

  Future<bool> userDataExists() async {
    try {
      Databases database = Databases(Dependencies.serverAPi.client!);
      await database.getDocument(
          databaseId: "636d59d7a2f595323a79",
          collectionId: "636d59df12dcf7a399d5",
          documentId: GlobalDataContainer.userId!);
      return true;
    } catch (e) {
      if (e is AppwriteException) {
        print(e.message);
      }
      return false;
    }
  }

  void listenDataFromDb() async {
    Realtime realtime = Realtime(Dependencies.serverAPi.client!);
    String userDataReference =
        "databases.636d59d7a2f595323a79.collections.636d59df12dcf7a399d5.documents.${GlobalDataContainer.userId}";
    appSubscription =
        realtime.subscribe([userDataReference]).stream.listen((event) {
              var dataToUse;

              dataToUse = event.payload;
              dataToUse["userPicture1"] = jsonDecode(dataToUse["userPicture1"]);
              dataToUse["userPicture2"] = jsonDecode(dataToUse["userPicture2"]);
              dataToUse["userPicture3"] = jsonDecode(dataToUse["userPicture3"]);
              dataToUse["userPicture4"] = jsonDecode(dataToUse["userPicture4"]);
              dataToUse["userPicture5"] = jsonDecode(dataToUse["userPicture5"]);
              dataToUse["userPicture6"] = jsonDecode(dataToUse["userPicture6"]);
           

              dataToUse["userSettings"] = jsonDecode(dataToUse["userSettings"]);
              setData = dataToUse;
            });
  }

  void clearAppDataSource() {
    if (appSubscription != null) {
      appSubscription!.cancel();
      appSubscription = null;
    }
  }
}

abstract class DataSource {
  /// Subscribe to the source to get the data from the backend
  late ApplicationDataSource source;

  // ignore: cancel_subscriptions
  StreamSubscription? sourceStreamSubscription;

  ///Must be called before any method in the class to get the data needed
  ///
  ///From the source
  void subscribeToMainDataSource();
}
