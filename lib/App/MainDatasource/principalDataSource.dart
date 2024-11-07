import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';

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

  Future<void> getDataFromDb() async {
   /* if (realm == null) {
      await initializeRealm();
    }
    var realmData = realm!.query<UserModel>('id = oid($userId)').first;

    userDataSet = realmData;

    setData = mapUserModelModelToMap(userDataSet!);

    addDataToStream(data: getData);*/
  }

  Map<String, dynamic> mapUserModelModelToMap(Map<String,dynamic> userDataSet) {
  /*  return {
      "id": userDataSet.id.toString(),
      "userId": userDataSet.userId,
      "userName": userDataSet.userName,
      "userBrithDate": userDataSet.userBrithDate,
      "userBiography": userDataSet.userBiography,
      "userSex": userDataSet.userSex,
      "userCoins": userDataSet.userCoins,
      "userPosition": {
        "lat": userDataSet.userPosition?.lat ?? 0,
        "lon": userDataSet.userPosition?.lon ?? 0
      },
      "userSettings": jsonDecode(userDataSet.userSettings),
      "waitingRewards": userDataSet.waitingRewards,
      "giveFirstReward": userDataSet.giveFirstReward,
      "email": userDataSet.email,
      "nextRewardDate": userDataSet.nextRewardDate,
      "isUserPremium": userDataSet.isUserPremium,
      "lastRatingTimeStamp": userDataSet.lastRatingTimeStamp,
      "notificationToken": userDataSet.notificationToken,
      "isUserVisible": userDataSet.isUserVisible,
      "subscriptionStatus": userDataSet.subscriptionStatus,
      "lastBlindDate": userDataSet.lastBlindDate,
      "subscriptionId": userDataSet.subscriptionId,
      "subscriptionExpiryDate": userDataSet.subscriptionExpiryDate,
      "subscriptionPaused": userDataSet.subscriptionPaused,
      "endSubscriptionDate": userDataSet.endSubscriptionDate,
      "userBlocked": userDataSet.userBlocked,
      "rewardTicketCode": userDataSet.rewardTicketCode,
      "rewardTicketSuccesfulShares": userDataSet.rewardTicketSuccesfulShares,
      "promotionalCodeUsedByUser": userDataSet.promotionalCodeUsedByUser,
      "isUserPromotionalCodeUsed": userDataSet.isUserPromotionalCodeUsed,
      "alcohol": userDataSet.userCharacteristics_alcohol,
      "im_looking_for": userDataSet.userCharacteristics_what_he_looks_for,
      "body_type": userDataSet.userCharacteristics_bodyType,
      "children": userDataSet.userCharacteristics_children,
      "pets": userDataSet.userCharacteristics_pets,
      "politics": userDataSet.userCharacteristics_politics,
      "im_living_with": userDataSet.userCharacteristics_lives_with,
      "smoke": userDataSet.userCharacteristics_smokes,
      "sexual_orientation": userDataSet.userCharacteristics_sexualOrientation,
      "zodiac_sign": userDataSet.userCharacteristics_zodiak,
      "personality": userDataSet.userCharacteristics_personality,
      "penalizationState": userDataSet.penalizationState,
      "penalizationEndDate": userDataSet.penalizationEndDate,
      "adConsentFormSown": userDataSet.adConsentFormSown,
      "adConsentFormSownDate": userDataSet.adConsentFormSownDate,
      "showPersonalizedAds": userDataSet.showPersonalizedAds,
      "isBlindDateActive": userDataSet.isBlindDateActive,
      "reactionAveracePoints": userDataSet.reactionAveracePoints,
      "reactionCount": userDataSet.reactionCount,
      "totalReactionPoints": userDataSet.totalReactionPoints,
      "verificationImageLink": userDataSet.verificationImageLink,
      "imageExpectedHandGesture": userDataSet.imageExpectedHandGesture,
      "verificationStatus": userDataSet.verificationStatus,
      "userPicture1": jsonDecode(userDataSet.userPicture1),
      "userPicture2": jsonDecode(userDataSet.userPicture2),
      "userPicture3": jsonDecode(userDataSet.userPicture3),
      "userPicture4": jsonDecode(userDataSet.userPicture4),
      "userPicture5": jsonDecode(userDataSet.userPicture5),
      "userPicture6": jsonDecode(userDataSet.userPicture6),
    };*/

    return {};
  }



  /// Checks if there is user data from the signed in user.
  ///  Returns true if the user has data in the database, returns false if not
  Future<bool> checkIfUserModelExists() async {
   /* try {
      if (realm == null) {
        await initializeRealm();
      }
      var realmData = realm!.query<UserModel>('id = oid($userId)').first;

      return true;
    } catch (e) {
      if (e is StateError) {
        return false;
      } else {
        throw Exception(e.toString());
      }
    }*/

   return true;
  }

  void listenDataFromDb() async {
   /* realm
        ?.query<UserModel>("id = oid($userId)")
        .changes
        .listen((RealmResultsChanges<UserModel> event) {
      if (event.modified.isNotEmpty) {
        setData = mapUserModelModelToMap(event.results.first);

        addDataToStream(data: getData);
      }

      if (event.newModified.isNotEmpty) {
        setData = mapUserModelModelToMap(event.results.first);
        addDataToStream(data: getData);
      }
    });*/

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
