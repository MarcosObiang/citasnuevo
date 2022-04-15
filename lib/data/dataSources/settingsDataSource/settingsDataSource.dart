import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/getUserImage.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:flutter/cupertino.dart';

abstract class SettingsDataSource implements DataSource {


  /// Emits any update of the user settings
  late StreamController<SettingsEntity> onUserSettingsUpdate;

  ///The [userDataSubscription] will listen to any changes the [ApplicationDataSource] emits, even if it does not concern to settings variables
  ///
  ///that is why we need to first save the settings in thes map and then if [userDataSubscription] emits a new change
  ///
  ///it is going to be compared with [latestSettings]
  late Map<String, dynamic> latestSettings;
}

class SettingsDataSourceImpl implements SettingsDataSource {
  @override
  late Map<String, dynamic> latestSettings = new Map<String, dynamic>();

  @override
  late StreamController<SettingsEntity> onUserSettingsUpdate =
      StreamController.broadcast();

  @override
  ApplicationDataSource source;


    @override
  late StreamSubscription sourceStreamSubscription;

  SettingsDataSourceImpl({
    required this.source,
  });

  @override
  void clearModuleData() {
    latestSettings = new Map<String, dynamic>();
    onUserSettingsUpdate = StreamController.broadcast();
    sourceStreamSubscription.cancel();
  }

  @override
  void subscribeToMainDataSource() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        if (shouldSettingsUpdate(source.getData)) {
          try {
            sendFirst();
          } catch (e) {
            onUserSettingsUpdate
                .addError(SettingsException(message: e.toString()));
          }
        }
        sourceStreamSubscription = source.dataStream.stream.listen((event) {
          try {
            if (shouldSettingsUpdate(event)) {
              sendFirst();
            }
          } catch (e) {
            onUserSettingsUpdate
                .addError(SettingsException(message: e.toString()));
          }
        }, onError: (error) {
          onUserSettingsUpdate.addError(error);
        });
      } catch (e) {
        onUserSettingsUpdate.addError(e);

        throw SettingsException(message: e.toString());
      }
    } else {
      onUserSettingsUpdate.addError(NetworkException());

      throw NetworkException();
    }
  }

  @protected
  bool shouldSettingsUpdate(Map<String, dynamic> dataFromSource) {
    bool shoulUpdate = false;

    if (latestSettings.isEmpty) {
      shoulUpdate = true;
    } else {
      if (latestSettings["name"] != dataFromSource["Nombre"]) {
        shoulUpdate = true;
      }
      if (latestSettings["age"] != dataFromSource["Edad"]) {
        shoulUpdate = true;
      }

      if (latestSettings["isPremium"] != dataFromSource["monedasInfinitas"]) {
        shoulUpdate = true;
      }
      if (latestSettings["userPicture"] !=
          GetProfileImage.getProfileImage
              .getProfileImageMap(dataFromSource)["image"]) {
        shoulUpdate = true;
      }
      if (latestSettings["hash"] !=
          GetProfileImage.getProfileImage
              .getProfileImageMap(dataFromSource)["hash"]) {
        shoulUpdate = true;
      }
    }

    return shoulUpdate;
  }

  void sendFirst() {
    Map<String, dynamic> dataFromSource = source.getData;
    latestSettings["name"] = dataFromSource["Nombre"];
    latestSettings["age"] = dataFromSource["Edad"];
    latestSettings["isPremium"] = dataFromSource["monedasInfinitas"];
    latestSettings["userPicture"] = GetProfileImage.getProfileImage
        .getProfileImageMap(dataFromSource)["image"];
    latestSettings["hash"] = GetProfileImage.getProfileImage
        .getProfileImageMap(dataFromSource)["hash"];

    SettingsEntity settingsEntity = SettingsEntity(
        userName: latestSettings["name"],
        userPicture: latestSettings["userPicture"],
        userPictureHash: latestSettings["hash"],
        userAge: latestSettings["age"],
        isPremium: latestSettings["isPremium"]);

    onUserSettingsUpdate.add(settingsEntity);
  }

  @override
  void initializeModuleData() {
    subscribeToMainDataSource();
  }


}
