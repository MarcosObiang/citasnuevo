import 'package:citasnuevo/DatosAplicacion/ControladorCreditos.dart';

import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Directo/live_screen_elements.dart';
import 'social_screen_elements.dart';

class AjustesAplicacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Usuario.esteUsuario,
          child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 10, right: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                 
                      Flexible(
                        
                          flex: 3,
                  fit: FlexFit.tight,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: BotonEditarPerfil(),
                        )),
                        Flexible(
                        
                          flex: 2,
                  fit: FlexFit.tight,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: BotonFiltros(),
                        )),
                    
                      Flexible(
                          flex: 15,
                  fit: FlexFit.tight,
                        child: BotonesTiendaAplicacion()),
                   
                   
                        
                        
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
