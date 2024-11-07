import 'package:citasnuevo/Utils/adConsentDialog.dart';
import 'package:citasnuevo/Utils/routes.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/main.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';


class PresentationDialogs {
  static PresentationDialogs instance = PresentationDialogs();

  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {
    if (context != null) {
      showDialog(
          context: context,
          builder: (context) =>
              GenericErrorDialog(title: title, content: content));
    }
  }

  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }

  void showAdConsentDialog() {
    Navigator.push(startKey.currentContext as BuildContext,
        GoToRoute(page: AdConsentform()));
  }

  void showErrorDialogWithOptions(
      {required BuildContext? context,
      required List<DialogOptions> dialogOptionsList,
      required String dialogTitle,
      required String dialogText}) {
    List<Widget> buttons = [];

    dialogOptionsList.forEach((element) {
      buttons.add(TextButton(
        child: Text(element.text),
        onPressed: () => element.function.call(),
      ));
    });

    if (context != null) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(dialogTitle),
                content: Text(dialogText),
                actions: buttons,
              ));
    }
  }
}

class DialogOptions {
  /// The functions that will be called after pressing the button
  VoidCallback function;

  /// The visible name of the button
  String text;
  DialogOptions({
    required this.function,
    required this.text,
  });
}

class NetwortErrorWidget extends StatelessWidget {
  const NetwortErrorWidget();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text("No se ha detectado una conexion a internet"),
      title: Text("No hay conexion"),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Entendido"))
      ],
    );
  }
}

class GenericErrorDialog extends StatelessWidget {
  final String content;
  final String title;

  const GenericErrorDialog({required this.content, required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(content),
      title: Text(title),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Entendido"))
      ],
    );
  }
}

class GenericDialog extends StatelessWidget {
  final String content;
  final String title;

  const GenericDialog({required this.content, required this.title});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(content),
      title: Text(title),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Entendido"))
      ],
    );
  }
}

