import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../../core/error/Exceptions.dart';
import '../../../../core/platform/networkInfo.dart';
import '../MainDatasource/principalDataSource.dart';

abstract class ReportDataSource implements DataSource {
  Future<bool> sendReport(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails,
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
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);
        Execution execution = await functions.createExecution(
            functionId: "reportUser",
            data: jsonEncode({
              "userReported": idUserReported,
              
              "userId": idReporter,
              "reportDetails": reportDetails,
              "includeMessages": false,
              "chatId": ""
            }));

        int status = jsonDecode(execution.response)["status"];
        if (status == 200) {
          return true;
        } else {
          throw ReportException(message: execution.response);
        }
      } catch (e) {
        throw ReportException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void subscribeToMainDataSource() {
    // TODO: implement subscribeToMainDataSource
  }
}
