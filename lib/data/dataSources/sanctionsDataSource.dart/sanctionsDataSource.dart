import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/domain/entities/SanctionsEntity.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/controller/controllerDef.dart';
import '../../../domain/repository/DataManager.dart';
import '../principalDataSource/principalDataSource.dart';

abstract class SanctionsDataSource
    implements
        DataSource,
        AuthenticationSignOutCapacity,
        ModuleCleanerDataSource {
  // ignore: close_sinks
  late StreamController<Map<String, dynamic>>? sanctionsUpdate;
  Future<bool> unlockProfile();
}

class SanctionsDataSourceImpl implements SanctionsDataSource {
  @override
  ApplicationDataSource source;
  @override
  AuthService authService;
  @override
  StreamController<Map<String, dynamic>>? sanctionsUpdate =
      StreamController.broadcast();

  @override
  StreamSubscription? sourceStreamSubscription;
  SanctionsDataSourceImpl({required this.source, required this.authService});

  @override
  void clearModuleData() {
    try {
      sanctionsUpdate?.close();
      sourceStreamSubscription?.cancel();
      sourceStreamSubscription = null;
      sanctionsUpdate = new StreamController.broadcast();
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  void initializeModuleData() {
    try {
      subscribeToMainDataSource();
    } catch (e) {
      throw ModuleInitializeException(message: e.toString());
    }
  }

  @override
  Future<bool> logOut() async {
    try {
      await authService.logOut();
      return true;
    } catch (e, s) {
      print(s);
      throw e;
    }
  }



  void _addData(Map<String, dynamic> data) {
    if (sanctionsUpdate != null) {
      sanctionsUpdate?.add(data);
    } else {
      throw Exception(kStreamParserNullError);
    }
  }

  void _addError(dynamic e) {
    if (sanctionsUpdate != null) {
      sanctionsUpdate?.addError(e);
    } else {
      throw Exception(kStreamParserNullError);
    }
  }

  @override
  void subscribeToMainDataSource() async {
    Map<String, dynamic>? oldSanctionsEntity = {
      "sanctionConfirmed": source.getData["sancionado"]["moderado"],
      "sanctionTimeStamp": source.getData["sancionado"]["finSancion"],
      "isUserSanctioned": source.getData["sancionado"]["usuarioSancionado"]
    };

    _addData(oldSanctionsEntity);
    sourceStreamSubscription = source.dataStream.stream.listen((event) async {
      try {
        Map<String, dynamic> newSanctionsEntity = {
          "sanctionConfirmed": source.getData["sancionado"]["moderado"],
          "sanctionTimeStamp": source.getData["sancionado"]["finSancion"],
          "isUserSanctioned": source.getData["sancionado"]["usuarioSancionado"]
        };

        if (oldSanctionsEntity == null) {
          oldSanctionsEntity = newSanctionsEntity;

          _addData(newSanctionsEntity);
        }
        // ignore: unnecessary_null_comparison
        if (oldSanctionsEntity != null && newSanctionsEntity != null) {
          if (!mapEquals(oldSanctionsEntity, newSanctionsEntity)) {
            oldSanctionsEntity = newSanctionsEntity;

            _addData(newSanctionsEntity);
          }
        }
      } catch (e) {
        _addError(e);
      }
    });
  }

  @override
  Future<bool> unlockProfile() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable unlockProfileFunction =
            FirebaseFunctions.instance.httpsCallable("desbloquearPerfil");

        HttpsCallableResult httpsCallableResult = await unlockProfileFunction
            .call({"userId": GlobalDataContainer.userId});
        if (httpsCallableResult.data["estado"] == "correcto") {
          return true;
        } else {
          throw SanctionException(message: "SERVER_ERROR");
        }
      } catch (e) {
        throw SanctionException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }
}
