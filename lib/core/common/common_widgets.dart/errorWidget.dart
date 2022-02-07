import 'package:citasnuevo/main.dart';
import 'package:flutter/material.dart';



class NetwortErrorWidget extends StatelessWidget {


  const NetwortErrorWidget(
      );

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
