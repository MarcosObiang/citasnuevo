import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class ReportChatScreen extends StatefulWidget {
  final String chatId;
  final String remitent;

  ReportChatScreen({required this.chatId, required this.remitent});

  @override
  State<StatefulWidget> createState() {
    return _ReportChatScreenState();
  }
}

class _ReportChatScreenState extends State<ReportChatScreen> {
  final TextEditingController textEditingController =
      new TextEditingController();
  FocusNode focusNode = new FocusNode();
  String reportText = "";
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.chatPresentation,
      child: Consumer<ChatPresentation>(builder: (BuildContext context,
          ChatPresentation chatPresentation, Widget? child) {
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
                  if (chatPresentation.chatReportSendingState ==
                      ChatReportSendingState.sending) ...[
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
                        if (textEditingController.text.trim().isNotEmpty) {
                          showSendReportDialog(context);
                        } else {
                          showTextfieldIsEmpty(context);
                        }
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
            content:
                Text("Se enviará tu denuncia y la conversacion será eliminada"),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                     Dependencies.chatPresentation.deleteChat(
                        remitent1: GlobalDataContainer.userId as String,
                        remitent2: widget.remitent,
                        reportDetails: textEditingController.text,
                        chatId: widget.chatId);
                    Navigator.pop(context);
                    Navigator.pop(context);
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

  void showTextfieldIsEmpty(BuildContext contex) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("No Puede enviar una denuncia vacia"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Entendido")),
            ],
          );
        });
  }
}
