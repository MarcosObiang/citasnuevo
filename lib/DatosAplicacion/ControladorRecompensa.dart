


import 'package:flutter/cupertino.dart';

enum TipoRecompensa{
  diaria,especial
}

class ControladorRecompensa with ChangeNotifier{

String nombreRecompensa;
TipoRecompensa tipoRecompensa;
DateTime finRecompensa;
DateTime inicioRecompensa;
bool paraHombre;
bool paraMujer;
bool usada;
String idRecompensa;
int cantidadRecompensa;
List<ControladorRecompensa>recompensas=new List();

ControladorRecompensa.recompensaDiaria({@required this.nombreRecompensa,@required this.tipoRecompensa,@required this.finRecompensa,
@required this.inicioRecompensa,@required this.paraHombre,@required this.paraMujer,@required this.cantidadRecompensa });


  
}