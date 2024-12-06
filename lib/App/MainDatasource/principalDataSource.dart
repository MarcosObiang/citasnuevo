import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';

import '../../core/dependencies/dependencyCreator.dart';
import '../../core/globalData.dart';
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
  StreamController<Map<String, dynamic>>? dataStream =
      new StreamController.broadcast();

  ApplicationDataSource();

  set setData(data) {
    this._data = data;
  }

  Map<String, dynamic> get getData {
    return this._data;
  }

  void setUserId(String userId) {
    this.userId = userId;
  }

  void addDataToStream({required Map<String, dynamic> data}) {
    dataStream?.add(data);
  }

  void clearAppDataSource() {
    appSubscription?.cancel();
    appSubscription = null;
    this.userId = null;
    dataStream?.close();
    dataStream = StreamController.broadcast();
  }

  ///

  Future<void> initializeMainDataSource() async {
    this.userId = GlobalDataContainer.userId;
    if (this.userId != null) {
      await getDataFromDb();
      listenDataFromDb();
    } else {
      throw Exception("USER_ID_CANNOT_BE_NULL");
    }
  }

  Map<String,dynamic> transformDataFromSource(Map<String,dynamic> userData){
    // Assuming you want to convert from a custom coordinate system to WGS84 (latitude, longitude)
    // Replace this with your actual coordinate transformation logic
    // This is just a placeholder, adjust as needed
    // Example:  If your system is simply offset by 10 degrees latitude and 5 degrees longitude
    userData['userLatitude'] = userData['userLatitude'] -90;
    userData['userLongitude'] = (userData['userLongitude'] as List<dynamic>)[0] -180;
    userData["userPicture1"]=jsonDecode(userData["userPicture1"]);
    userData["userPicture2"]=jsonDecode(userData["userPicture2"]);
    userData["userPicture3"]=jsonDecode(userData["userPicture3"]);
    userData["userPicture4"]=jsonDecode(userData["userPicture4"]);
    userData["userPicture5"]=jsonDecode(userData["userPicture5"]);
    userData["userPicture6"]=jsonDecode(userData["userPicture6"]);
    userData["userSettings"]=jsonDecode(userData["userSettings"]);


    return userData;
  }


  Future<void> getDataFromDb() async {
    try {
      Databases databases = new Databases(Dependencies.serverAPi.client);
      Document document = await databases.getDocument(
          databaseId: kDatabaseId,
          collectionId: kUserCollecitonId,
          documentId: GlobalDataContainer.userId);
      this._data = transformDataFromSource(document.data as Map<String, dynamic>);
      


    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Checks if there is user data from the signed in user.
  ///  Returns true if the user has data in the database, returns false if not
  Future<bool> checkIfUserModelExists() async {
    try {
      Databases databases = Databases(Dependencies.serverAPi.client);
      DocumentList documentList = await databases.listDocuments(
          databaseId: kDatabaseId,
          collectionId: kUserCollecitonId,
          queries: [Query.equal("userId", GlobalDataContainer.userId)]);
      if (documentList.total > 0) {
        return true;
      }
    } catch (e) {
      throw Exception(e.toString());
    }

    return false;
  }

  void listenDataFromDb() async {
    Realtime realtime = Realtime(Dependencies.serverAPi.client);

    appSubscription = realtime
        .subscribe([
          'databases.${kDatabaseId}.collections.${kUserCollecitonId}.documents.${userId}'
        ])
        .stream
        .listen((message) {
          if (message.events
              .contains('databases.${kDatabaseId}.collections.${kUserCollecitonId}.documents.${userId}.update')) {
            Map<String, dynamic> updatedData = message.payload;

            _data = transformDataFromSource(updatedData);

            dataStream?.add(_data);
          }
        });
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
