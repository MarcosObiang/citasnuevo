import 'dart:async';

import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:flutter/cupertino.dart';

import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';

import '../entities/ChatEntity.dart';
//ignore_for_file: close_sinks

abstract class Controller implements ModuleCleaner {}

class InformationSender {}

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

class HomeScreenInformationSender {
  HomeScreenInformationSender();
}

class SettingsInformationSender extends InformationSender {
  SettingsEntity settingsEntity;
  SettingsInformationSender({
    required this.settingsEntity,
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
  bool showProfilePoints;
  bool showProfile;
  ApplicationSettingsInformationSender({
    required this.distance,
    required this.maxAge,
    required this.minAge,
    required this.inCm,
    required this.inKm,
    required this.showBothSexes,
    required this.showWoman,
    required this.showProfilePoints,
    required this.showProfile,
  });
}

class UserSettingsInformationSender extends InformationSender {
  List<UserPicture> userPicruresList;
  String userBio;
  List<UserCharacteristic>userCharacteristic;
  UserSettingsInformationSender(
      {required this.userBio, required this.userPicruresList, required this.userCharacteristic});
}

class UserCreatorInformationSender extends InformationSender {
  List<UserPicture> userPicruresList;
  String userBio;
  DateTime minBirthDayInMilliseconds;
  List<UserCharacteristic>userCharacteristic;
  UserCreatorInformationSender(
      {required this.userBio, required this.userPicruresList, required this.userCharacteristic,required this.minBirthDayInMilliseconds});
}
abstract class ShouldControllerRemoveData<InformationSender> {
  late StreamController<InformationSender> removeDataController;
}

abstract class ShouldControllerUpdateData<InformationSender> {
  /// Needs to listen to a [Controller.updateData] and implement the presentation logic for updated data
  late StreamController<InformationSender> updateDataController;
}

abstract class ShouldControllerAddData<InformationSender> {
  /// Needs to listen to a [Controller.addDataController] and implement the presentation logic for new data
  late StreamController<InformationSender> addDataController;
}
