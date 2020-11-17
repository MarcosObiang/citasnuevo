import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/base_app.dart';
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

class _AjustesState extends State<Ajustes> {
  RangeValues valoresRangoEdad = new RangeValues(
      ControladorLocalizacion.instancia.getEdadInicial,
      ControladorLocalizacion.instancia.getEdadFinal);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: ControladorLocalizacion.instancia,
        child: Consumer<ControladorLocalizacion>(
          builder: (context, myType, child) {
            return SafeArea(
                child: WillPopScope(
                  onWillPop: (){
                   
                    return ControladorLocalizacion.instancia.guardarAjustes();

                  },
                                  child: Scaffold(
                    
                    appBar: AppBar(
                      backgroundColor: Colors.deepPurple[900],
                      
                      elevation: 0,
                      iconTheme: IconThemeData(color:Colors.white),
                      title:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Ajustes",style: GoogleFonts.lato(fontSize:90.sp,color:Colors.white,fontWeight: FontWeight.normal))
                        //  Icon(Icons.settings)

                        ],

                      )
                    ),
                      backgroundColor: Colors.deepPurple[900],
                      body: Padding(
                        padding: const EdgeInsets.only(
            top: 15, bottom: 15, left: 15, right: 15),
                        child: ListView(padding: EdgeInsets.all(10), children: [
                          Text("Ajustes descubrimiento",style: GoogleFonts.lato(color:Colors.white,fontSize:70.sp,fontWeight:FontWeight.bold),),
                          deslizadorEdad(),
                          deslizadorDistancia(),
                          botonSexo(),
                        botonVisibilidad(),
                          Text("Legal",style: GoogleFonts.lato(color:Colors.white,fontSize:70.sp,fontWeight:FontWeight.bold),),
                           botonTerminosDeServicio(),
                          botonPoliticaPrivacidad(),
                          botonLicencias(),
                          Text("Contactanos",style: GoogleFonts.lato(color:Colors.white,fontSize:70.sp,fontWeight:FontWeight.bold),),
                         botonContacto(),
                          Text("Ajustes cuenta",style: GoogleFonts.lato(color:Colors.white,fontSize:70.sp,fontWeight:FontWeight.bold),),
                          botonCerrarSesion(),
                          Icon(LineAwesomeIcons.heart,size: 150.sp,color: Colors.white,),
                          botonBorracCuenta()
                        ]),
                      )),
                ),
              );
          },
        ));
  }

  Padding botonSexo() {
    return Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 0, right: 0),
                    child: Container(
                      height: 250.h,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.deepPurple[300],
                                blurRadius: 5,
                                spreadRadius: 5)
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Mostrar",
                                style:
                                    GoogleFonts.lato(fontSize: 50.sp),
                              ),
                             
                              Container(
                        height: 70.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: Row(children: [
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 1,
                            child: GestureDetector(
                                 onTap: (){},
                                                              child: Container(
                                decoration: BoxDecoration(
                                  color: !ControladorLocalizacion.instancia.getVisualizarDistanciaEnMillas?Colors.deepPurple:Colors.white,
                                    borderRadius: BorderRadius.only(
                                      
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(30))),
                                      child:Center(child: Text("Mujeres",style:GoogleFonts.lato(fontSize:50.sp,color: !ControladorLocalizacion.instancia.getVisualizarDistanciaEnMillas?Colors.white:Colors.black,)))
                          
                              ),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 1,
                            child: GestureDetector(
                              onTap: (){},
                                                              child: Container(
                                decoration: BoxDecoration(
                                  color: ControladorLocalizacion.instancia.getVisualizarDistanciaEnMillas?Colors.deepPurple:Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30),
                                        bottomRight: Radius.circular(30))),
                                             child:Center(child: Text("Hombres",style:GoogleFonts.lato(fontSize:50.sp,color: ControladorLocalizacion.instancia.getVisualizarDistanciaEnMillas?Colors.white:Colors.black,)))
                              ),
                            ),
                          )
                        ]),
                      )
                            ]),
                      ),
                    ),
                  );
  }

  Padding botonVisibilidad() {
    return Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 40, left: 0, right: 0),
                    child: Container(
                      height: 150.h,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.deepPurple[300],
                                blurRadius: 5,
                                spreadRadius: 5)
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Perfil visible",
                                    style:
                                        GoogleFonts.lato(fontSize: 50.sp),
                                  ),
                                  Switch(value: ControladorLocalizacion.instancia.getMostrarmeEnHotty, onChanged: (value){
                                    ControladorLocalizacion.instancia.setMostrarmeEnHotty=value;
                                  })
                                ],
                              ),
                             
                  
                            ]),
                      ),
                    ),
                  );
  }

  Widget botonCerrarSesion() {
    return Padding(
      padding: const EdgeInsets.only(top:30,bottom:60,left:0,right:0),
      child: Container(
        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.deepPurple[300],
                                blurRadius: 5,
                                spreadRadius: 5)
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(20))),
        child: GestureDetector(
                          onTap: () => ControladorInicioSesion.cerrarSesion()
                              .then((value) {
                            if (value) {
                              Navigator.pop(
                                  BaseAplicacion.claveBase.currentContext);
                                  setState(() {
                                    
                                  });
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Cerrar Sesion",
                                    style: GoogleFonts.lato(
                                        fontSize: 50.sp,
                                        fontWeight: FontWeight.bold)),
                                        Icon(Icons.exit_to_app)
                              ],
                            ),
                          ),
                        ),
      ),
    );
  }

    Widget botonBorracCuenta() {
    return Padding(
      padding: const EdgeInsets.only(top:60,bottom:8,left:0,right:0),
      child: Container(
        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.deepPurple[300],
                                blurRadius: 5,
                                spreadRadius: 5)
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(20))),
        child: GestureDetector(
                          onTap: () => ControladorInicioSesion.cerrarSesion()
                              .then((value) {
                            if (value) {
                              Navigator.pop(
                                  BaseAplicacion.claveBase.currentContext);
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Borrar cuenta",
                                    style: GoogleFonts.lato(
                                        fontSize: 50.sp,
                                        fontWeight: FontWeight.bold)),
                                        Icon(Icons.delete)
                              ],
                            ),
                          ),
                        ),
      ),
    );
  }
 Widget botonTerminosDeServicio() {
    return Padding(
      padding: const EdgeInsets.only(top:30,bottom:8,left:0,right:0),
      child: Container(
        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.deepPurple[300],
                                blurRadius: 5,
                                spreadRadius: 5)
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(20))),
        child: GestureDetector(
                          onTap: () => ControladorInicioSesion.cerrarSesion()
                              .then((value) {
                            if (value) {
                              Navigator.pop(
                                  BaseAplicacion.claveBase.currentContext);
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Terminos de servicio",
                                    style: GoogleFonts.lato(
                                        fontSize: 50.sp,
                                        fontWeight: FontWeight.bold)),
                                        
                              ],
                            ),
                          ),
                        ),
      ),
    );
  }

    Widget botonPoliticaPrivacidad() {
    return Padding(
      padding: const EdgeInsets.only(top:10,bottom:8,left:0,right:0),
      child: Container(
        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.deepPurple[300],
                                blurRadius: 5,
                                spreadRadius: 5)
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(20))),
        child: GestureDetector(
                          onTap: () => ControladorInicioSesion.cerrarSesion()
                              .then((value) {
                            if (value) {
                              Navigator.pop(
                                  BaseAplicacion.claveBase.currentContext);
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Politica de privacidad",
                                    style: GoogleFonts.lato(
                                        fontSize: 50.sp,
                                        fontWeight: FontWeight.bold)),
                                     
                              ],
                            ),
                          ),
                        ),
      ),
    );
  }
     Widget botonLicencias() {
    return Padding(
      padding: const EdgeInsets.only(top:10,bottom:30,left:0,right:0),
      child: Container(
        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.deepPurple[300],
                                blurRadius: 5,
                                spreadRadius: 5)
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(20))),
        child: GestureDetector(
                          onTap: () => ControladorInicioSesion.cerrarSesion()
                              .then((value) {
                            if (value) {
                              Navigator.pop(
                                  BaseAplicacion.claveBase.currentContext);
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Licencias",
                                    style: GoogleFonts.lato(
                                        fontSize: 50.sp,
                                        fontWeight: FontWeight.bold)),
                                     
                              ],
                            ),
                          ),
                        ),
      ),
    );
  }
       Widget botonContacto() {
    return Padding(
      padding: const EdgeInsets.only(top:30,bottom:30,left:0,right:0),
      child: Container(
        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.deepPurple[300],
                                blurRadius: 5,
                                spreadRadius: 5)
                          ],
                          borderRadius:
                              BorderRadius.all(Radius.circular(20))),
        child: GestureDetector(
                          onTap: () => ControladorInicioSesion.cerrarSesion()
                              .then((value) {
                            if (value) {
                              Navigator.pop(
                                  BaseAplicacion.claveBase.currentContext);
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Asistencia",
                                    style: GoogleFonts.lato(
                                        fontSize: 50.sp,
                                        fontWeight: FontWeight.bold)),
                                        Icon(Icons.headset_mic)
                                     
                              ],
                            ),
                          ),
                        ),
      ),
    );
  }

  Padding deslizadorDistancia() {
    return Padding(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 0, right: 0),
                      child: Container(
                        height: 350.h,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.deepPurple[300],
                                  blurRadius: 5,
                                  spreadRadius: 5)
                            ],
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Distancia",
                                      style:
                                          GoogleFonts.lato(fontSize: 60.sp),
                                    ),
                                    Text(
                                    ! ControladorLocalizacion.instancia.getVisualizarDistanciaEnMillas? "${ControladorLocalizacion.instancia.getDiistanciaMaxima.toInt()} Km":"${(ControladorLocalizacion.instancia.getDiistanciaMaxima*0.62).toInt()} mi",
                                      style:
                                          GoogleFonts.lato(fontSize: 60.sp),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: ControladorLocalizacion
                                      .instancia.getDiistanciaMaxima,
                                  onChanged: (value) {
                                    ControladorLocalizacion.instancia
                                        .setDiistanciaMaxima = value;
                                  },
                                  min: 10,
                                  max: 150,
                                ),
                                Container(
                          height: 70.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: Row(children: [
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: GestureDetector(
                                      onTap: ()=>ControladorLocalizacion.instancia.setVisualizarDistanciaEnMillas=false,
                                                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !ControladorLocalizacion.instancia.getVisualizarDistanciaEnMillas?Colors.deepPurple:Colors.white,
                                      borderRadius: BorderRadius.only(
                                        
                                          topLeft: Radius.circular(30),
                                          bottomLeft: Radius.circular(30))),
                                        child:Center(child: Text("Km",style:GoogleFonts.lato(fontSize:50.sp,color: !ControladorLocalizacion.instancia.getVisualizarDistanciaEnMillas?Colors.white:Colors.black,)))
                            
                                ),
                              ),
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 1,
                              child: GestureDetector(
                                onTap: ()=>ControladorLocalizacion.instancia.setVisualizarDistanciaEnMillas=true,
                                                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ControladorLocalizacion.instancia.getVisualizarDistanciaEnMillas?Colors.deepPurple:Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(30),
                                          bottomRight: Radius.circular(30))),
                                               child:Center(child: Text("Millas",style:GoogleFonts.lato(fontSize:50.sp,color: ControladorLocalizacion.instancia.getVisualizarDistanciaEnMillas?Colors.white:Colors.black,)))
                                ),
                              ),
                            )
                          ]),
                        )
                              ]),
                        ),
                      ),
                    );
  }

  Padding deslizadorEdad() {
    return Padding(
                      padding: const EdgeInsets.only(
                          top: 40, bottom: 10, left: 0, right: 0),
                      child: Container(
                        height: 250.h,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.deepPurple[300],
                                  blurRadius: 5,
                                  spreadRadius: 5)
                            ],
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Rango de edad",
                                      style:
                                          GoogleFonts.lato(fontSize: 60.sp),
                                    ),
                                    Text(
                                      "${(ControladorLocalizacion.instancia.getEdadInicial).toInt()}-${(ControladorLocalizacion.instancia.getEdadFinal).toInt()}",
                                      style:
                                          GoogleFonts.lato(fontSize: 60.sp),
                                    ),
                                  ],
                                ),
                                FlutterSlider(
                                  values: [
                                    ControladorLocalizacion
                                        .instancia.getEdadInicial,
                                    ControladorLocalizacion
                                        .instancia.getEdadFinal
                                  ],
                                  rangeSlider: true,
                                  onDragging:
                                      (value, valorMinimo, valorMaximo) {
                                    print(value);

                                    ControladorLocalizacion.instancia
                                        .setEdadInicial = valorMinimo;
                                    ControladorLocalizacion
                                        .instancia.setEdadFinal = valorMaximo;

                                    print(
                                        "${(ControladorLocalizacion.instancia.getEdadInicial).toInt()}-${(ControladorLocalizacion.instancia.getEdadFinal).toInt()}");
                                  },
                                 
                                  min: 18,
                                  max: 71,
                                )
                              ]),
                        ),
                      ),
                    );
  }
}
