import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/domain/entities/SanctionsEntity.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../../domain/controller/controllerDef.dart';
import '../principalDataSource/principalDataSource.dart';

abstract class SanctionsDataSource
    implements DataSource, AuthenticationSignOutCapacity {
  late StreamController<SanctionsEntity> sanctionsUpdate;
  Future<bool> unlockProfile();
}

class SanctionsDataSourceImpl implements SanctionsDataSource {
  @override
  ApplicationDataSource source;
  @override
  AuthService authService;
  @override
  StreamController<SanctionsEntity> sanctionsUpdate =
      StreamController.broadcast();

  @override
  StreamSubscription? sourceStreamSubscription;
  SanctionsDataSourceImpl({required this.source, required this.authService});

  @override
  void clearModuleData() {
    sanctionsUpdate.close();
    sourceStreamSubscription?.cancel();
    sourceStreamSubscription = null;
  }

  @override
  void initializeModuleData() {
    sanctionsUpdate = new StreamController.broadcast();
    subscribeToMainDataSource();
  }

  @override
  Future<bool> logOut() async {
    try {
      Map<String, dynamic> userData = await authService.logOut();
      return true;
    } catch (e, s) {
      print(s);
      throw e;
    }
  }

  @override
  void subscribeToMainDataSource() async {
    SanctionsEntity? oldSanctionsEntity;

    sourceStreamSubscription = source.dataStream.stream.listen((event) async {
      SanctionsEntity? newSanctionsEntity = SanctionsEntity(
          sanctionConfirmed: event["sancionado"]["moderado"],
          sanctionTimeStamp: event["sancionado"]["finSancion"],
          isUserSanctioned: event["sancionado"]["usuarioSancionado"]);

      if (oldSanctionsEntity == null) {
        oldSanctionsEntity = newSanctionsEntity;

        DateTime dateTime = await DateNTP.instance.getTime();
        int actualTimeInMilliseconds = dateTime.millisecondsSinceEpoch;

        newSanctionsEntity.sanctionTimerStart(
            actualTimeInMilliseconds: actualTimeInMilliseconds);
        sanctionsUpdate.add(newSanctionsEntity);
      }
      // ignore: unnecessary_null_comparison
      if (oldSanctionsEntity != null && newSanctionsEntity != null) {
        if ((oldSanctionsEntity!.isUserSanctioned !=
                newSanctionsEntity.isUserSanctioned) ||
            (oldSanctionsEntity!.sanctionConfirmed !=
                newSanctionsEntity.sanctionConfirmed) ||
            (oldSanctionsEntity!.sanctionTimeStamp !=
                newSanctionsEntity.sanctionTimeStamp)) {
          oldSanctionsEntity = newSanctionsEntity;

          DateTime dateTime = await DateNTP.instance.getTime();
          int actualTimeInMilliseconds = dateTime.millisecondsSinceEpoch;

          newSanctionsEntity.sanctionTimerStart(
              actualTimeInMilliseconds: actualTimeInMilliseconds);
          sanctionsUpdate.add(newSanctionsEntity);
        }
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
          throw ServerException(message: "SERVER_ERROR");
        }
      } catch (e) {
        throw ServerException(message: e.toString());
      }
    } else {
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }
}
