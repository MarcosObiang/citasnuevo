import 'dart:async';
import 'dart:core';

import 'package:citasnuevo/core/common/commonUtils/getUserImage.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/iapPurchases/iapPurchases.dart';

import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';

import 'package:flutter/cupertino.dart';

import '../../../domain/repository/DataManager.dart';

abstract class SettingsDataSource
    implements DataSource, ModuleCleanerDataSource {
  /// Emits any update of the user settings
  late StreamController<Map<String, dynamic>>? onUserSettingsUpdate;

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
  StreamController<Map<String, dynamic>>? onUserSettingsUpdate =
      StreamController();

  @override
  ApplicationDataSource source;

  @override
  StreamSubscription? sourceStreamSubscription;

  SettingsDataSourceImpl({
    required this.source,
  });

  void _addErrorToStream(dynamic e) {
    if (onUserSettingsUpdate != null) {
      onUserSettingsUpdate!.addError(SettingsException(message: e.toString()));
    }
  }

  @override
  void clearModuleData() {
    try {
      latestSettings = new Map<String, dynamic>();
      onUserSettingsUpdate?.close();
      onUserSettingsUpdate = null;
      onUserSettingsUpdate = StreamController();
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
            _addErrorToStream(e);
            throw SettingsException(message: e.toString());
          }
        }

        sourceStreamSubscription = source.dataStream.stream.listen((event) {
          try {
            if (shouldSettingsUpdate(event)) {
              sendFirst();
            }
          } catch (e) {
            _addErrorToStream(e);
          }
        });
      } catch (e) {
        _addErrorToStream(e);
        throw SettingsException(message: e.toString());
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
      if (latestSettings["userName"] != dataFromSource["userName"]) {
        shoulUpdate = true;
      }

      if (latestSettings["isUserPremium"] != dataFromSource["isUserPremium"]) {
        shoulUpdate = true;
      }
      if (latestSettings["userPicture1"]["hash"] !=
          dataFromSource["userPicture1"]["hash"]) {
        shoulUpdate = true;
      }
      if (latestSettings["userPicture2"]["hash"] !=
          dataFromSource["userPicture2"]["hash"]) {
        shoulUpdate = true;
      }
      if (latestSettings["userPicture3"]["hash"] !=
          dataFromSource["userPicture3"]["hash"]) {
        shoulUpdate = true;
      }
      if (latestSettings["userPicture4"]["hash"] !=
          dataFromSource["userPicture4"]["hash"]) {
        shoulUpdate = true;
      }
      if (latestSettings["userPicture5"]["hash"] !=
          dataFromSource["userPicture5"]["hash"]) {
        shoulUpdate = true;
      }
      if (latestSettings["userPicture6"]["hash"] !=
          dataFromSource["userPicture6"]["hash"]) {
        shoulUpdate = true;
      }

      /* if (latestSettings["subscriptionId"] != dataFromSource["idSuscripcion"]) {
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
      }*/
    }

    return shoulUpdate;
  }

  void sendFirst() {
    try {
      Map<String, dynamic> dataFromSource = source.getData;
      latestSettings["name"] = dataFromSource["userName"];
      latestSettings["age"] = 30;
      latestSettings["isPremium"] = dataFromSource["isUserPremium"];
      latestSettings["userPicture1"] = dataFromSource["userPicture1"];
      latestSettings["userPicture2"] = dataFromSource["userPicture2"];
      latestSettings["userPicture3"] = dataFromSource["userPicture3"];
      latestSettings["userPicture4"] = dataFromSource["userPicture4"];
      latestSettings["userPicture5"] = dataFromSource["userPicture5"];
      latestSettings["userPicture6"] = dataFromSource["userPicture6"];

      /*  latestSettings["subscriptionId"] = dataFromSource["idSuscripcion"];
      latestSettings["paymentState"] = dataFromSource["estadoPagoSuscripcion"];
      latestSettings["subscriptionExpirationTime"] =
          dataFromSource["caducidadSuscripcion"];
      latestSettings["pausedModeExpirationTime"] =
          dataFromSource["finPausaSuscripcion"];*/

      onUserSettingsUpdate?.add(latestSettings);
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
