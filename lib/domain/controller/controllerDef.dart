import 'dart:async';

import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:flutter/cupertino.dart';

import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';

import '../entities/ChatEntity.dart';
import '../entities/RewardsEntity.dart';
//ignore_for_file: close_sinks

abstract class Controller implements ModuleCleaner {}

class InformationSender {}

abstract class AuthenticationCapacity {
  late AuthService authService;
}

enum SignInProviders { GOOGLE, FACEABOOK }

abstract class AuthenticationLogInCapacity implements AuthenticationCapacity {
  ///provider can be 2 values:
  ///
  ///"SignInProviders.GOOGLE": to sign iN with google auth
  ///
  ///"SignInProviders.FACEBOOK": to sign in with facebook

  Future<bool> logIn({required SignInProviders signInProviders});
}

abstract class AuthenticationUserAlreadySignedInCapacity
    implements AuthenticationCapacity {
  /// Call to check if the user has already signed in
  ///
  /// if the user is already signed in, the app shoould let the user to the next screen

  Future<bool> checkIfUserIsAlreadySignedIn();
}

abstract class AuthenticationSignOutCapacity implements AuthenticationCapacity {
  /// Call to end the sesion in the device and within the app

  Future<bool> logOut();
}

class ReactionInformationSender extends InformationSender {
  Reaction? reaction;
  double? reactionAverage;
  bool? isModified;
  bool? isDeleted;
  int? coins;
  int? index;
  bool sync;
  bool isPremium;
  bool notify;
  ReactionInformationSender(
      {required this.reaction,
      required this.reactionAverage,
      required this.notify,
      required this.isModified,
      required this.isDeleted,
      required this.coins,
      required this.index,
      required this.isPremium,
      required this.sync});
}

class ChatInformationSender extends InformationSender {
  List<Message>? messageList;
  List<Chat>? chatList;
  bool? isChat;
  bool? isModified;
  bool? isDeleted;
  bool firstQuery;
  int? index;

  ChatInformationSender(
      {required this.chatList,
      required this.messageList,
      required this.firstQuery,
      required this.isModified,
      required this.index,
      required this.isDeleted,
      required this.isChat,
      x});
}

class HomeScreenInformationSender extends InformationSender {
  Map<String, dynamic> information;
  HomeScreenInformationSender({required this.information});
}

class SettingsInformationSender extends InformationSender {
  SettingsEntity settingsEntity;
  SettingsInformationSender({
    required this.settingsEntity,
  });
}
class RewardInformationSender extends InformationSender {
  Rewards? rewards;
  int? secondsToDailyReward;
  String? premiumPrice;
  
  RewardInformationSender({
    required this.rewards,
    required this.secondsToDailyReward,
    required this.premiumPrice
  });
}
class ApplicationSettingsInformationSender extends InformationSender {
  int distance;
  int maxAge;
  int minAge;
  bool inCm;
  bool inKm;
  bool showBothSexes;
  bool showWoman;
  bool showProfile;
  ApplicationSettingsInformationSender({
    required this.distance,
    required this.maxAge,
    required this.minAge,
    required this.inCm,
    required this.inKm,
    required this.showBothSexes,
    required this.showWoman,
    required this.showProfile,
  });
}

class UserSettingsInformationSender extends InformationSender {
  List<UserPicture> userPicruresList;
  String userBio;
  List<UserCharacteristic> userCharacteristic;
  UserSettingsInformationSender(
      {required this.userBio,
      required this.userPicruresList,
      required this.userCharacteristic});
}

class UserCreatorInformationSender extends InformationSender {
  List<UserPicture> userPicruresList;
  String userBio;
  DateTime minBirthDayInMilliseconds;
  List<UserCharacteristic> userCharacteristic;
  UserCreatorInformationSender(
      {required this.userBio,
      required this.userPicruresList,
      required this.userCharacteristic,
      required this.minBirthDayInMilliseconds});
}

abstract class ShouldControllerRemoveData<InformationSender> {
  late StreamController<InformationSender>? removeDataController;
}

abstract class ShouldControllerUpdateData<InformationSender> {
  /// Needs to listen to a [Controller.updateData] and implement the presentation logic for updated data
   StreamController<InformationSender>? updateDataController;
}

abstract class ShouldControllerAddData<InformationSender> {
  /// Needs to listen to a [Controller.addDataController] and implement the presentation logic for new data
   StreamController<InformationSender>? addDataController;
}

///USE ONLY TO CREATE A CONTROLLER BRIDGE CLASS,
///DO NOT IMPLEMENT IT DIRECTLY ON ANY CONTROLLER
///
///EXPAMPLE:
/// ```dart
///class HomeScreenControllerBridge<HomeScreenController>
///    implements
///         ControllerBridgeInformationReciever<HomeScreenController>,
///         ControllerBridgeInformationSender<HomeScreenController> {
///   @override
///   late StreamController<Map<String, dynamic>>
///            controllerBridgeInformationSenderStream=new StreamController.broadcast();
///
///   @override
///  void addInformation({required Map<String, dynamic> information}) {
///     // TODO: implement addInformation
///   }
/// }
/// ```
/// Brigdes are not bi-directional, this means that bridges are only one way
/// between two controllers
/// 
/// To create the sender side implement in the controller the abstrac class "ExternalControllerDataSender"<T>
/// 
/// to create the recieve side implement in the controller the abstrac class "ExternalControllerDataReciever"<T>
///
///
///
abstract class ControllerBridgeInformationSender<T> {
  void addInformation({required Map<String, dynamic> information});
}

///USE ONLY TO CREATE A CONTROLLER BRIDGE CLASS,
///DO NOT IMPLEMENT IT DIRECTLY ON ANY CONTROLLER
///
///EXPAMPLE:
/// ```dart
///class HomeScreenControllerBridge<HomeScreenController>
///    implements
///         ControllerBridgeInformationReciever<HomeScreenController>,
///         ControllerBridgeInformationSender<HomeScreenController> {
///   @override
///         controllerBridgeInformationSenderStream=new StreamController.broadcast();
///
///   @override
///  void addInformation({required Map<String, dynamic> information}) {
///     // TODO: implement addInformation
///   }
/// }
/// ```
/// Brigdes are not bi-directional, this means that bridges are only one way
/// between two controllers
/// 
/// To create the sender side implement in the controller the abstrac class "ExternalControllerDataSender"<T>
/// 
/// to create the recieve side implement in the controller the abstrac class "ExternalControllerDataReciever"<T>

abstract class ControllerBridgeInformationReciever<T> {
  late StreamController<Map<String, dynamic>>
      controllerBridgeInformationSenderStream;

      void initializeStream();
      void closeStream();
}

abstract class ExternalControllerDataSender<T> {
  late ControllerBridgeInformationSender<T>? controllerBridgeInformationSender;

}

abstract class ExteralControllerDataReciever<T> {
  late ControllerBridgeInformationReciever<T>
      controllerBridgeInformationReciever;
}


