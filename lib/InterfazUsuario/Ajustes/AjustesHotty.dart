import 'dart:async';

import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/PerfilesUsuarios.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/DatosAplicacion/WrapperLikes.dart';
import 'package:citasnuevo/InterfazUsuario/WidgetError.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:citasnuevo/base_app.dart';
import 'package:citasnuevo/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class Ajustes extends StatefulWidget {
  @override
  _AjustesState createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    debugPrint("didPopNext ${runtimeType}");

    setState(() {});
  }

  // Called when the current route has been pushed.
  void didPush() {
    debugPrint("didPush ${runtimeType}");
  }

  // Called when the current route has been popped off.
  void didPop() {
    ControladorAjustes.instancia.guardarAjustes();
    ControladorAjustes.instancia.listaPerfilesNube.clear();
   // ControladorLocalizacion.instancia = new ControladorLocalizacion();
    QueryPerfiles.cerrarConvexionesQuery();
    QueryPerfiles.listaStreamsCerrados = null;
    QueryPerfiles.listaStreamsCerrados = new List();
    Perfiles.perfilesCitas.estadoLista=EstadoListaPerfiles.cargandoLista;
       Usuario.esteUsuario.notifyListeners();
      
    ControladorAjustes.instancia.obtenerLocalizacion().then((value) async {
  
      ControladorAjustes.instancia.cargaPerfiles();
    });

    debugPrint("didPop ${runtimeType}");
  }

  // Called when a new route has been pushed, and the current route is no longer visible.
  void didPushNext() {
    debugPrint("didPushNext ${runtimeType}");
  }

  @override
  RangeValues valoresRangoEdad = new RangeValues(
      ControladorAjustes.instancia.getEdadInicial,
      ControladorAjustes.instancia.getEdadFinal);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: ControladorAjustes.instancia,
        child: Consumer<ControladorAjustes>(
          builder: (context, myType, child) {
            return SafeArea(
              child: Scaffold(
                  appBar: AppBar(
                      backgroundColor: Colors.deepPurple[900],
                      elevation: 0,
                      iconTheme: IconThemeData(color: Colors.white),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Ajustes",
                              style: GoogleFonts.lato(
                                  fontSize: 90.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal))
                          //  Icon(Icons.settings)
                        ],
                      )),
                  backgroundColor: Colors.deepPurple[900],
                  body: Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 15, right: 15),
                    child: ListView(padding: EdgeInsets.all(10), children: [
                      Text(
                        "Filtros",
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 70.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      deslizadorEdad(),
                      deslizadorDistancia(),
                      botonSexo(),
                      unidadesAltura(),
                      botonVisibilidad(),
                      Text(
                        "Legal",
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 70.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      botonTerminosDeServicio(),
                      botonPoliticaPrivacidad(),
                      botonLicencias(),
                      Text(
                        "Contactanos",
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 70.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      botonContacto(),
                      Text(
                        "Ajustes cuenta",
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 70.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      botonCerrarSesion(),
                      Icon(
                        LineAwesomeIcons.heart,
                        size: 150.sp,
                        color: Colors.white,
                      ),
                      botonBorracCuenta()
                    ]),
                  )),
            );
          },
        ));
  }

  Padding botonSexo() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Mostrar",
                style: GoogleFonts.lato(fontSize: 50.sp, color: Colors.white),
              ),
              Container(
                height: 70.h,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Row(children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        if (!ControladorAjustes
                            .instancia.getMostrarMujeres) {
                          ControladorAjustes.instancia.setMostrarMujeres =
                              true;
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: ControladorAjustes
                                      .instancia.getMostrarMujeres
                                  ? Colors.deepPurple
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  bottomLeft: Radius.circular(30))),
                          child: Center(
                              child: Text("Mujeres",
                                  style: GoogleFonts.lato(
                                    fontSize: 40.sp,
                                    color: ControladorAjustes
                                            .instancia.getMostrarMujeres
                                        ? Colors.white
                                        : Colors.black,
                                  )))),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        if (ControladorAjustes
                            .instancia.getMostrarMujeres) {
                          ControladorAjustes.instancia.setMostrarMujeres =
                              false;
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: !ControladorAjustes
                                      .instancia.getMostrarMujeres
                                  ? Colors.deepPurple
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomRight: Radius.circular(30))),
                          child: Center(
                              child: Text("Hombres",
                                  style: GoogleFonts.lato(
                                    fontSize: 40.sp,
                                    color: !ControladorAjustes
                                            .instancia.getMostrarMujeres
                                        ? Colors.white
                                        : Colors.black,
                                  )))),
                    ),
                  )
                ]),
              )
            ]),
      ),
    );
  }

  Padding botonVisibilidad() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 40, left: 0, right: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Perfil visible",
                    style:
                        GoogleFonts.lato(fontSize: 40.sp, color: Colors.white),
                  ),
                  Switch(
                      value:
                          ControladorAjustes.instancia.getMostrarmeEnHotty,
                      onChanged: (value) {
                        ControladorAjustes.instancia.setMostrarmeEnHotty =
                            value;
                      })
                ],
              ),
            ]),
      ),
    );
  }

  Widget botonCerrarSesion() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 60, left: 0, right: 0),
      child: GestureDetector(
        onTap: () =>
            ControladorInicioSesion.instancia.cerrarSesion().then((value) {
          if (value) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }),
        child: Container(
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Cerrar Sesion",
                    style: GoogleFonts.lato(
                        fontSize: 50.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget botonBorracCuenta() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 8, left: 0, right: 0),
      child: GestureDetector(
        onTap: () => ManejadorErroresAplicacion.erroresInstancia
            .mostrarAdvertenciaBorrarCuenta(context),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Borrar cuenta",
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 50.sp,
                      fontWeight: FontWeight.bold)),
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget botonTerminosDeServicio() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 8, left: 0, right: 0),
      child: GestureDetector(
        onTap: () => ManejadorErroresAplicacion.erroresInstancia
            .mostrarAdvertenciaBorrarCuenta(context),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Terminos de servicio",
                  style: GoogleFonts.lato(
                      fontSize: 50.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget botonPoliticaPrivacidad() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8, left: 0, right: 0),
      child: GestureDetector(
        onTap: () => ManejadorErroresAplicacion.erroresInstancia
            .mostrarAdvertenciaBorrarCuenta(context),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Politica de privacidad",
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 50.sp,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget botonLicencias() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 30, left: 0, right: 0),
      child: GestureDetector(
        onTap: () {
          showAboutDialog(
              context: context,
              applicationLegalese:
                  "En este apartado veras con detalles todas las licencias que usa la aplicacion para mas informacion dirigete a Hotty.com",
              applicationName: "Hotty",
              applicationVersion: "0.0.1");
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Licencias",
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 50.sp,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget botonContacto() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 30, left: 0, right: 0),
      child: GestureDetector(
        onTap: () =>
            ControladorInicioSesion.instancia.cerrarSesion().then((value) {
          if (value) {
            Navigator.pop(BaseAplicacion.claveBase.currentContext);
          }
        }),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Asistencia",
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 50.sp,
                      fontWeight: FontWeight.bold)),
              Icon(
                Icons.headset_mic,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget unidadesAltura(){
    return    Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text("Mostrar altura en...",
                  style: GoogleFonts.lato(
                      fontSize: 50.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
        Container(
                    height: 70.h,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Row(children: [
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => ControladorAjustes
                              .instancia.setMostrarCm = true,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: ControladorAjustes.instancia
                                                .mostrarCm
                                      ? Colors.deepPurple
                                      : Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      bottomLeft: Radius.circular(30))),
                              child: Center(
                                  child: Text("Cm",
                                      style: GoogleFonts.lato(
                                        fontSize: 50.sp,
                                        color: ControladorAjustes.instancia
                                                .mostrarCm
                                            ? Colors.white
                                            : Colors.black,
                                      )))),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => ControladorAjustes
                              .instancia.setMostrarCm = false,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: !ControladorAjustes.instancia
                                                .mostrarCm
                                      ? Colors.deepPurple
                                      : Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(30),
                                      bottomRight: Radius.circular(30))),
                              child: Center(
                                  child: Text("Pies",
                                      style: GoogleFonts.lato(
                                        fontSize: 50.sp,
                                        color: !ControladorAjustes.instancia
                                                .mostrarCm
                                            ? Colors.white
                                            : Colors.black,
                                      )))),
                        ),
                      )
                    ]),
                  ),
      ],
    );
  }







  Padding deslizadorDistancia() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Distancia",
                    style: GoogleFonts.lato(
                      fontSize: 60.sp,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    !ControladorAjustes
                            .instancia.getVisualizarDistanciaEnMillas
                        ? "${ControladorAjustes.instancia.getDiistanciaMaxima.toInt()} Km"
                        : "${(ControladorAjustes.instancia.getDiistanciaMaxima * 0.62).toInt()} mi",
                    style: GoogleFonts.lato(
                      fontSize: 60.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Slider(
                value: ControladorAjustes.instancia.getDiistanciaMaxima,
                onChanged: (value) {
                  ControladorAjustes.instancia.setDiistanciaMaxima = value;
                },
                min: 10,
                max: 150,
              ),
              Container(
                height: 70.h,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Row(children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => ControladorAjustes
                          .instancia.setVisualizarDistanciaEnMillas = false,
                      child: Container(
                          decoration: BoxDecoration(
                              color: !ControladorAjustes
                                      .instancia.getVisualizarDistanciaEnMillas
                                  ? Colors.deepPurple
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  bottomLeft: Radius.circular(30))),
                          child: Center(
                              child: Text("Km",
                                  style: GoogleFonts.lato(
                                    fontSize: 50.sp,
                                    color: !ControladorAjustes.instancia
                                            .getVisualizarDistanciaEnMillas
                                        ? Colors.white
                                        : Colors.black,
                                  )))),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => ControladorAjustes
                          .instancia.setVisualizarDistanciaEnMillas = true,
                      child: Container(
                          decoration: BoxDecoration(
                              color: ControladorAjustes
                                      .instancia.getVisualizarDistanciaEnMillas
                                  ? Colors.deepPurple
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomRight: Radius.circular(30))),
                          child: Center(
                              child: Text("Millas",
                                  style: GoogleFonts.lato(
                                    fontSize: 50.sp,
                                    color: ControladorAjustes.instancia
                                            .getVisualizarDistanciaEnMillas
                                        ? Colors.white
                                        : Colors.black,
                                  )))),
                    ),
                  )
                ]),
              )
            ]),
      ),
    );
  }

  Padding deslizadorEdad() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 10, left: 0, right: 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rango de edad",
                    style: GoogleFonts.lato(
                      fontSize: 60.sp,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "${(ControladorAjustes.instancia.getEdadInicial).toInt()}-${(ControladorAjustes.instancia.getEdadFinal).toInt()}",
                    style: GoogleFonts.lato(
                      fontSize: 60.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              FlutterSlider(
                values: [
                  ControladorAjustes.instancia.getEdadInicial,
                  ControladorAjustes.instancia.getEdadFinal
                ],
                rangeSlider: true,
                onDragging: (value, valorMinimo, valorMaximo) {
                  ControladorAjustes.instancia.setEdadInicial =
                      valorMinimo;
                  ControladorAjustes.instancia.setEdadFinal = valorMaximo;
                },
                min: 18,
                max: 71,
              )
            ]),
      ),
    );
  }
}
