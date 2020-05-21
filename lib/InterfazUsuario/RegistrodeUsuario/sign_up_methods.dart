
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class nacimiento_usuario {
  int year;
  int month;
  int day;

  DateTime fecha(BuildContext context) {

    DateTime dato;

    showDatePicker(
            context: context,
            initialDate: DateTime(2010),
            firstDate: DateTime(1900),
            lastDate: DateTime.now())
        .then((data) {
      dato = data;
   //   print(dato);
      return dato;
    });

  }

  int edad(DateTime fecha) {
    int data;
    if(fecha!=null){
    int dur = DateTime.now().difference(fecha).inDays;
    data = dur ~/365;
    print(dur);}

    return data;
  }
}
