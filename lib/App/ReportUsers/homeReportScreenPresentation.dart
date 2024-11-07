import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/error/Failure.dart';
import '../../../core/params_types/params_and_types.dart';
import '../../../main.dart';
import '../../Utils/dialogs.dart';
import '../../Utils/presentationDef.dart';
import 'reportController.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

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
                          title: AppLocalizations.of(startKey.currentContext!)!
                              .error,
                          content:
                              AppLocalizations.of(startKey.currentContext!)!
                                  .report_sending_error,
                          context: startKey.currentContext);
                    }
                  }, (succes) {
                    reportSendidnState = ReportSendingState.sended;
                  });
                } else {
                  PresentationDialogs.instance.showErrorDialog(
                      title:
                          AppLocalizations.of(startKey.currentContext!)!.error,
                      content: AppLocalizations.of(startKey.currentContext!)!
                          .the_report_field_cannot_be_empty,
                      context: startKey.currentContext);
                }
              },
              text: AppLocalizations.of(startKey.currentContext!)!.yes),
          DialogOptions(
              function: () =>
                  Navigator.pop(startKey.currentContext as BuildContext),
              text: AppLocalizations.of(startKey.currentContext!)!.no)
        ],
        dialogTitle: AppLocalizations.of(startKey.currentContext!)!.send_report,
        dialogText:
            AppLocalizations.of(startKey.currentContext!)!.report_the_user);
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
