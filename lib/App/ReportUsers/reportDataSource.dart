import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../../core/error/Exceptions.dart';
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
  /*  if (await Dependencies.networkInfoContract.isConnected) {
      try {
        final response = await Dependencies
            .serverAPi.app!.currentUser!.functions
            .call("reportUsers", [
          jsonEncode({
            "userReported": idUserReported,
            "userId": idReporter,
            "reportDetails": reportDetails,
            "includeMessages": false,
            "chatId": ""
          })
        ]);

        var responseParsed=jsonDecode(response);

        int status = responseParsed["executionCode"];
        String message = responseParsed["message"];
        if (status == 200) {
          return true;
        } else {
          throw ReportException(message: message);
        }
      } catch (e) {
        throw ReportException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }*/ return true;
  }

  @override
  void subscribeToMainDataSource() {
    // TODO: implement subscribeToMainDataSource
  }
}
