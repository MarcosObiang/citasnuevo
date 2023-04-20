import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../core/common/common_widgets.dart/errorWidget.dart';
import '../../../core/error/Failure.dart';
import '../../../core/params_types/params_and_types.dart';
import '../../../main.dart';
import '../../Utils/dialogs.dart';
import '../../Utils/presentationDef.dart';
import 'reportController.dart';

class HomeReportScreenPresentation extends ChangeNotifier
    implements Presentation {
  ReportController reportController;
  HomeReportScreenPresentation({
    required this.reportController,
  });
  ReportSendingState _reportSendingState = ReportSendingState.notSended;

  ReportSendingState get getReportSendingState => this._reportSendingState;
  set reportSendidnState(reportSendidnState) {
    _reportSendingState = reportSendidnState;
    notifyListeners();
  }

  bool checkReport({required String userReport}) {
    bool result = true;
    if (userReport.trim().isEmpty) {
      result = false;
    }
    return result;
  }

  /// Call this method to report any user profile the user may think it violates the norms of the comunity
  ///
  void setToRetry() {
    reportSendidnState = ReportSendingState.notSended;
  }

  void sendReport(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails}) async {
    PresentationDialogs().showErrorDialogWithOptions(
        context: startKey.currentContext,
        dialogOptionsList: [
          DialogOptions(
              function: () async {
                Navigator.pop(startKey.currentContext as BuildContext);

                if (checkReport(userReport: reportDetails)) {
                  reportSendidnState = ReportSendingState.sending;
                  var result = await reportController.sendUserReport(
                      idReporter: idReporter,
                      reportDetails: reportDetails,
                      idUserReported: idUserReported);

                  result.fold((fail) {
                    reportSendidnState = ReportSendingState.notSended;
                    if (fail is NetworkFailure) {
                      PresentationDialogs.instance.showNetworkErrorDialog(
                          context: startKey.currentContext);
                    } else {
                      PresentationDialogs.instance.showErrorDialog(
                          title: "Error",
                          content: "Error enviar denuncia",
                          context: startKey.currentContext);
                    }
                  }, (succes) {
                    reportSendidnState = ReportSendingState.sended;
                  });
                } else {
                  PresentationDialogs.instance.showErrorDialog(
                      title: "Error",
                      content: "El campo 'Denuncia' no puede estar vacio",
                      context: startKey.currentContext);
                }
              },
              text: "Si"),
          DialogOptions(
              function: () =>
                  Navigator.pop(startKey.currentContext as BuildContext),
              text: "No")
        ],
        dialogTitle: "¿Enviar denuncia?",
        dialogText: "denunciar al usuario");
  }

  void showThanksForReportingDialog() {}

  @override
  void restart() {
    // TODO: implement restart
  }

  @override
  void clearModuleData() {
    // TODO: implement clearModuleData
  }

  @override
  void initializeModuleData() {
    // TODO: implement initializeModuleData
  }
}
