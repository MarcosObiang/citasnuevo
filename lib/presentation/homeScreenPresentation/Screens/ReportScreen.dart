import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String userId;

  ReportScreen(this.userId);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final TextEditingController textEditingController =
      new TextEditingController();
  FocusNode focusNode = new FocusNode();
  String reportText = "";
  @override
  Widget build(BuildContext context) {
    var data = ref.watch(Dependencies.homeScreenProvider);

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
              if (data.reportSendidnState == ReportSendingState.sending) ...[
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
                    onEditingComplete: () => showSendReportDialog(),
                    style: GoogleFonts.lato(fontSize: 45.sp),
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                    showSendReportDialog();
                  },
                  child: Text("Enviar denuncia"))
            ],
          ),
        ),
      ),
    );
  }

  void showSendReportDialog() {
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
                    ref.read(Dependencies.homeScreenProvider).sendReport(
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
