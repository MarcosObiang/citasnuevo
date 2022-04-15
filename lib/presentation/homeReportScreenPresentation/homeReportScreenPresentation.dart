import 'dart:async';

import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:citasnuevo/domain/controller/reportController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../core/dependencies/error/Failure.dart';

class HomeReportScreenPresentation extends ChangeNotifier implements Presentation {

ReportController reportController;
  HomeReportScreenPresentation({
    required this.reportController,
  });
    ReportSendingState _reportSendingState = ReportSendingState.notSended;

  get reportSendidnState => this._reportSendingState;
  set reportSendidnState(reportSendidnState) {
    _reportSendingState = reportSendidnState;
    notifyListeners();
  }




  /// Call this method to report any user profile the user may think it violates the norms of the comunity
  ///

  void sendReport(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails}) async {
    reportSendidnState = ReportSendingState.sending;
    var result = await reportController.sendUserReport(
        idReporter: idReporter,
        reportDetails: reportDetails,
        idUserReported: idUserReported);

    result.fold((fail) {
      reportSendidnState = ReportSendingState.error;
      if (fail is NetworkFailure) {
        var startKey;
        showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        var startKey;
        showErrorDialog(
            title: "Error",
            content: "Error enviar denuncia",
            context: startKey.currentContext);
      }
    }, (succes) {
      reportSendidnState = ReportSendingState.sended;
    });
  }
















  @override
  void showErrorDialog({required String title, required String content, required BuildContext? context}) {
    // TODO: implement showErrorDialog
  }

  @override
  void showLoadingDialog() {
    // TODO: implement showLoadingDialog
  }

  @override
  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }  }

  @override
  void initialize() {
    // TODO: implement initialize
  }

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
