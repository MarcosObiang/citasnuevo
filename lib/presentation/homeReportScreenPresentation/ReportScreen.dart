import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/presentation/homeReportScreenPresentation/homeReportScreenPresentation.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  final String userId;

  ReportScreen(this.userId);

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
    return ChangeNotifierProvider.value(
      value: Dependencies.homeReportScreenPresentation,
      child: Consumer<HomeReportScreenPresentation>(builder: (BuildContext context,
          HomeReportScreenPresentation homeReportScreenPresentation, Widget? child) {
        return SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  Icon(Icons.report, color: Colors.red, size: 400.sp),
                  Text("Ayudanos a mantener Hotty seguro",
                      style: GoogleFonts.lato(fontSize: 55.sp)),
                  Divider(
                    height: 100.h,
                  ),
                  if (homeReportScreenPresentation.reportSendidnState ==
                      ReportSendingState.sending) ...[
                    LoadingIndicator(indicatorType: Indicator.ballScale)
                  ] else ...[
                    Text("Describenos el motivo de tu denuncia",
                        style: GoogleFonts.lato(fontSize: 45.sp)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        focusNode: focusNode,
                        textInputAction: TextInputAction.done,
                        controller: textEditingController,
                        onChanged: (value) {
                          reportText = textEditingController.text;
                        },
                        onEditingComplete: () => showSendReportDialog(context),
                        style: GoogleFonts.lato(fontSize: 45.sp),
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.white),
                                gapPadding: 10)),
                        maxLines: 6,
                        maxLength: 300,
                      ),
                    ),
                  ],
                  Divider(
                    height: 50.h,
                    color: Colors.white,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        focusNode.unfocus();
                        showSendReportDialog(context);
                      },
                      child: Text("Enviar denuncia"))
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void showSendReportDialog(BuildContext contex) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("¿Enviar denuncia?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                   Dependencies.homeReportScreenPresentation.sendReport(
                        idReporter: widget.userId,
                        idUserReported: widget.userId,
                        reportDetails: reportText);
                  },
                  child: Text("Enviar")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar"))
            ],
          );
        });
  }

  void showTextfieldIsEmpty() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("¿Enviar denuncia?"),
            actions: [
              TextButton(onPressed: () {}, child: Text("Enviar")),
              TextButton(onPressed: () {}, child: Text("Cancelar"))
            ],
          );
        });
  }
}
