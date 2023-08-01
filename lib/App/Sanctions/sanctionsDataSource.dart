import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/dependencies/dependencyCreator.dart';
import '../DataManager.dart';
import '../MainDatasource/principalDataSource.dart';
import '../controllerDef.dart';
import '../../core/common/commonUtils/DateNTP.dart';
import '../../core/error/Exceptions.dart';
import '../../core/services/AuthService.dart';
import '../../core/globalData.dart';
import '../../core/params_types/params_and_types.dart';
import '../../core/platform/networkInfo.dart';

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
    Map<String, dynamic> oldSanctionsEntity = {
      "penalizationState": source.getData["penalizationState"],
      "penalizationEndTimestampMs":
          source.getData["penalizationEndTimestampMs"],
    };

    _addData(oldSanctionsEntity);
    sourceStreamSubscription = source.dataStream?.stream.listen((event) async {
      try {
        Map<String, dynamic> newSanctionsEntity = {
          "penalizationState": event["penalizationState"],
          "penalizationEndTimestampMs": event["penalizationEndTimestampMs"],
        };

        if (oldSanctionsEntity.isEmpty) {
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
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
            functionId: "unlockProfile",
            data: jsonEncode(
                {"firstReward": false, "userId": GlobalDataContainer.userId}));
        int status = jsonDecode(execution.response)["status"];
        String message = jsonDecode(execution.response)["message"];
        if (status == 200) {
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
