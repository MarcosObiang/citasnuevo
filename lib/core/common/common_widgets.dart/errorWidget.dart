import 'package:citasnuevo/main.dart';
import 'package:flutter/material.dart';

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