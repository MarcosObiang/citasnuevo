import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';

import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';

import '../../../core/dependencies/error/Exceptions.dart';
import '../../../core/platform/networkInfo.dart';

abstract class ReportDataSource implements DataSource {
  Future<bool> sendReport(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails,
      required bool blockUser});

  Future<bool> sendReportWithMessages(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails,
      required String messageId,
      required bool blockUser});
}

class ReportDataSourceImpl implements ReportDataSource {
  @override
  ApplicationDataSource source;
  @override
   StreamSubscription? sourceStreamSubscription;
  ReportDataSourceImpl({
    required this.source,
  });

  @override
  Future<bool> sendReport(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails,
      required bool blockUser}) async {
    HttpsCallable reportUser =
        FirebaseFunctions.instance.httpsCallable("enviarDenuncia");
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        await reportUser.call({
          "idDenunciado": idUserReported,
          "idDenunciante": idReporter,
          "detalles": reportDetails,
          "conversacionIncluida":false,
          "idConversacion":0
        });
        return true;
      } catch (e) {
        throw ReportException(message: e.toString());
      }
    } else {
      throw NetworkException(message:kNetworkErrorMessage );
    }
  }

  @override
  Future<bool> sendReportWithMessages(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails,
      required String messageId,
      required bool blockUser}) {
    // TODO: implement sendReportWithMessages
    throw UnimplementedError();
  }

  @override
  void subscribeToMainDataSource() {
    // TODO: implement subscribeToMainDataSource
  }


}
