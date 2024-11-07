import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../core/dependencies/dependencyCreator.dart';
import '../../core/params_types/params_and_types.dart';
import 'homeReportScreenPresentation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class ReportScreenArgs {
  String userId;
  ReportScreenArgs({
    required this.userId,
  });
}

class ReportScreen extends StatefulWidget {
  static const routeName = '/ReporScreen';

  ReportScreen();

  @override
  State<StatefulWidget> createState() {
    return _ReportScreenState();
  }
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController textEditingController =
      new TextEditingController();
  FocusNode focusNode = new FocusNode();
  String reportText = "";
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ReportScreenArgs;
    String userId = args.userId;
    return WillPopScope(
      onWillPop: () async {
        Dependencies.homeReportScreenPresentation.reportSendidnState =
            ReportSendingState.notSended;
        return true;
      },
      child: ChangeNotifierProvider.value(
        value: Dependencies.homeReportScreenPresentation,
        child: Consumer<HomeReportScreenPresentation>(builder:
            (BuildContext context,
                HomeReportScreenPresentation homeReportScreenPresentation,
                Widget? child) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                children: [
                  Flexible(
                    flex: 5,
                    fit: FlexFit.loose,
                    child: Column(children: [
                      Icon(Icons.report, color: Colors.red, size: 300.sp),
                      Text(AppLocalizations.of(context)!.help_us_keep_hotty_safe,
                          style: GoogleFonts.lato(fontSize: 55.sp)),
                    ]),
                  ),
                  Flexible(
                    flex: 6,
                    fit: FlexFit.loose,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: homeReportScreenPresentation
                                    .getReportSendingState ==
                                ReportSendingState.notSended
                            ? TextField(
                                focusNode: focusNode,
                                textAlignVertical: TextAlignVertical.top,
                                textInputAction: TextInputAction.done,
                                controller: textEditingController,
                                onChanged: (value) {
                                  reportText = textEditingController.text;
                                },
                                onEditingComplete: () => Dependencies
                                    .homeReportScreenPresentation
                                    .sendReport(
                                        idReporter: userId,
                                        idUserReported: userId,
                                        reportDetails: reportText),
                                style: GoogleFonts.lato(fontSize: 45.sp),
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    labelText: AppLocalizations.of(context)!.report,
                                    alignLabelWithHint: true,
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    )),
                                maxLength: 300,
                                expands: true,
                                maxLines: null,
                                minLines: null,
                              )
                            : homeReportScreenPresentation
                                        .getReportSendingState ==
                                    ReportSendingState.sending
                                ? Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 200.h,
                                          child: LoadingIndicator(
                                              indicatorType: Indicator.orbit,colors: [Colors.black],),
                                        ),
                                        Text(AppLocalizations.of(context)!.sending_report)
                                      ],
                                    ),
                                  )
                                : homeReportScreenPresentation
                                            .getReportSendingState ==
                                        ReportSendingState.error
                                    ? Center(
                                        child: ElevatedButton.icon(
                                            onPressed: () {
                                              homeReportScreenPresentation.setToRetry();
                                            },
                                            icon: Icon(Icons.refresh),
                                            label: Text(AppLocalizations.of(context)!.try_again)),
                                      )
                                    : Center(
                                        child: Column(
                                          children: [
                                            Icon(Icons.done,size: 120.sp,),
                                            Text(AppLocalizations.of(context)!.done)
                                          ],
                                        ),
                                      ),
                      ),
                    ),
                  ),
                  Flexible(
                      flex: 3,
                      fit: FlexFit.loose,
                      child:
                          homeReportScreenPresentation.getReportSendingState ==
                                  ReportSendingState.notSended
                              ? ElevatedButton(
                                  onPressed: () {
                                    focusNode.unfocus();
                                    Dependencies.homeReportScreenPresentation
                                        .sendReport(
                                            idReporter: userId,
                                            idUserReported: userId,
                                            reportDetails: reportText);
                                  },
                                  child: Text(AppLocalizations.of(context)!.send_report_button))
                              : homeReportScreenPresentation
                                          .getReportSendingState ==
                                      ReportSendingState.sended
                                  ? ElevatedButton(
                                      onPressed: () {
                                        focusNode.unfocus();
                                        Navigator.pop(context);
                                        homeReportScreenPresentation.setToRetry();
                                      },
                                      child: Text(AppLocalizations.of(context)!.done))
                                  : Container())
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void showSendReportDialog(BuildContext contex, userId) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.send_report),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Dependencies.homeReportScreenPresentation.sendReport(
                        idReporter: userId,
                        idUserReported: userId,
                        reportDetails: reportText);
                  },
                  child: Text(AppLocalizations.of(context)!.send_report_button)),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel))
            ],
          );
        });
  }

  void showTextfieldIsEmpty(BuildContext contex) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.report_empty_error_message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.revealing_card_understood)),
            ],
          );
        });
  }
}
