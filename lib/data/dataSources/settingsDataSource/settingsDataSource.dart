import 'dart:async';
import 'dart:io';
import 'dart:core';

import 'package:citasnuevo/core/common/commonUtils/getUserImage.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/iapPurchases/iapPurchases.dart';

import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/SettingsMapper.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';

import 'package:flutter/cupertino.dart';

import '../../../domain/repository/DataManager.dart';

abstract class SettingsDataSource
    implements DataSource, ModuleCleanerDataSource {
  /// Emits any update of the user settings
  late StreamController<SettingsEntity> onUserSettingsUpdate;

  Future<bool> purchaseSubscription(String offerId);

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
  static const idProductos = <String>{
    "hottypremium1_mes",
    "premiumsemanal",
    "hotty3meses",
  };

  @override
  StreamController<SettingsEntity> onUserSettingsUpdate =
      StreamController.broadcast();

  @override
  ApplicationDataSource source;

  @override
  StreamSubscription? sourceStreamSubscription;

  SettingsDataSourceImpl({
    required this.source,
  });

  @override
  void clearModuleData() {
    try {
      latestSettings = new Map<String, dynamic>();
      onUserSettingsUpdate = StreamController.broadcast();
      sourceStreamSubscription?.cancel();
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
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
            throw SettingsException(message: e.toString());
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
        });
      } catch (e) {
        onUserSettingsUpdate.addError(e);
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
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

      if (latestSettings["subscriptionId"] != dataFromSource["idSuscripcion"]) {
        shoulUpdate = true;
      }
      if (latestSettings["paymentState"] !=
          dataFromSource["estadoPagoSuscripcion"]) {
        shoulUpdate = true;
      }
      if (latestSettings["subscriptionExpirationTime"] !=
          dataFromSource["caducidadSuscripcion"]) {
        shoulUpdate = true;
      }
      if (latestSettings["pausedModeExpirationTime"] !=
          dataFromSource["finPausaSuscripcion"]) {
        shoulUpdate = true;
      }
    }

    return shoulUpdate;
  }

  void sendFirst() {
    try {
      Map<String, dynamic> dataFromSource = source.getData;
      latestSettings["name"] = dataFromSource["Nombre"];
      latestSettings["age"] = dataFromSource["Edad"];
      latestSettings["isPremium"] = dataFromSource["monedasInfinitas"];
      latestSettings["userPicture"] = GetProfileImage.getProfileImage
          .getProfileImageMap(dataFromSource)["image"];
      latestSettings["hash"] = GetProfileImage.getProfileImage
          .getProfileImageMap(dataFromSource)["hash"];
      latestSettings["subscriptionId"] = dataFromSource["idSuscripcion"];
      latestSettings["paymentState"] = dataFromSource["estadoPagoSuscripcion"];
      latestSettings["subscriptionExpirationTime"] =
          dataFromSource["caducidadSuscripcion"];
      latestSettings["pausedModeExpirationTime"] =
          dataFromSource["finPausaSuscripcion"];

      onUserSettingsUpdate.add(SettingsMapper.fromMap(latestSettings));
    } catch (e) {
      print(e);
      throw e;
    }
  }

  @override
  void initializeModuleData() async {
    try {
      subscribeToMainDataSource();
    } catch (e) {
      throw ModuleInitializeException(message: e.toString());
    }
  }

  @override
  Future<bool> purchaseSubscription(String offerId) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        bool result = await PurchasesServices.purchasesServices
            .makePurchase(offerId: offerId);
        return result;
      } catch (e) {
        throw SettingsException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }
}
