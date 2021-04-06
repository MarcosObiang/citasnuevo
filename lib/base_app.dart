

import 'package:citasnuevo/DatosAplicacion/ControladorInicioSesion.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorSanciones.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/Ajustes/PantallaAjustes.dart';
import 'package:citasnuevo/InterfazUsuario/Conversaciones/ListaConversaciones.dart';
import 'package:citasnuevo/PrimeraPantalla.dart';
import 'package:flash/flash.dart';


import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorConversacion.dart';


import 'package:citasnuevo/InterfazUsuario/Actividades/Pantalla_Actividades.dart';






import 'package:flushbar/flushbar.dart';
import 'package:citasnuevo/main.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseAplicacion extends State<start> with WidgetsBindingObserver {
  


  static AppLifecycleState notificadorEstadoAplicacion; 
  static final GlobalKey claveNavegacion = GlobalKey();
  static final GlobalKey claveBase = GlobalKey();
  static final formatoFecha=new DateFormat("dd/MM/yyyy");
  static final id = 'starter_app';
  static BaseAplicacion instancia=BaseAplicacion();
  static double alturaNavegacion = claveNavegacion.currentContext.size.height;
  static int indicePagina = 0;
  final tabs = [PantallaPrincipal(), ConversacionesLikes(),AjustesAplicacion()];
    FirebaseDatabase baseDatosConexion = FirebaseDatabase(
                        app: app,
                        databaseURL: "https://citas-46a84.firebaseio.com/");
                         FirebaseDatabase referenciaStatus = FirebaseDatabase(
                        app: app,
                        databaseURL: "https://citas-46a84.firebaseio.com/");

@override
void didChangeAppLifecycleState(AppLifecycleState estado){
  setState(() {
    notificadorEstadoAplicacion=estado;
  });
  super.didChangeAppLifecycleState(estado);
}


  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
     WidgetsBinding.instance.addObserver(this);

    super.initState();

    
  }

   @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  State<StatefulWidget> createState() {
    // ignore: todo
    // TODO: implement createState
    return BaseAplicacion();
  }

  Widget build(BuildContext context) {

    // ignore: todo
    // TODO: implement build
    return WillPopScope(
      onWillPop: (){
        return ;

      },
          child: ChangeNotifierProvider.value(
        value: Conversacion.conversaciones,
            child: Material(
             
          key: claveBase,
          
     
          child: Container(
            color: Colors.deepPurple[900],
            height: ScreenUtil.screenHeight,
            child: Stack(
              children: <Widget>[
                
               
                
                Container(
                    height: MediaQuery.of(context).size.height
                    ,
                    child: tabs[indicePagina]),
                       Align(
                         alignment: Alignment.bottomCenter,
                                                child: Consumer<Conversacion>(
                  builder: (context, myType, child) {
                 
                    return  barraBajaPrincipalNavegacion();
                  },
                ),
                       ),
              
                
         
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget barraBajaPrincipalNavegacion() {
    return BottomNavigationBar(
      key: claveNavegacion,
      iconSize: ScreenUtil().setSp(1),
      unselectedLabelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(1),
          fontStyle: FontStyle.italic,
          color: Colors.black87),
      selectedLabelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(1),
          fontWeight: FontWeight.bold,
          color: Colors.white),
      selectedIconTheme: IconThemeData(color: Colors.black, size: 25),
      selectedItemColor: Colors.black,
      currentIndex: indicePagina,
      type: BottomNavigationBarType.fixed,
      backgroundColor: indicePagina==0?Colors.transparent:Colors.white,
      elevation: 0.0,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined, size: ScreenUtil().setSp(60),color: BaseAplicacion.indicePagina==0?Colors.white:Colors.black),
          title: new Text(
            "",
            style: TextStyle(
              fontSize: ScreenUtil().setSp(0),
            ),
          ),
        ),
      
        BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.bottomLeft,
              children: [
              Icon(Icons.message_outlined, size: ScreenUtil().setSp(60),color: BaseAplicacion.indicePagina==0?Colors.white:Colors.black),
            Container(
              height: 30.w,
              width: 30.w,
              
              decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Conversacion.conversaciones.cantidadMensajesNoLeidos>0&&BaseAplicacion.indicePagina!=1?  Colors.purple:Colors.transparent,
              ),
            ),
              
              ],
           
            )
            
            ,
            title: new Text(
              "",
              style: TextStyle(
            fontSize: ScreenUtil().setSp(0),
            fontStyle: FontStyle.italic,
              ),
            ),
            backgroundColor: Colors.red),
        
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: ScreenUtil().setSp(60),color: BaseAplicacion.indicePagina==0?Colors.white:Colors.black),
            title: new Text(
              "",
              style: TextStyle(
            fontSize: ScreenUtil().setSp(0),
            fontStyle: FontStyle.italic,
              ),
            ),
            backgroundColor: Colors.deepPurple),
      ],
      onTap: (index) {
        setState(() {
        
       
          indicePagina = index;
        });
      },
             
    );
  }
  Future<dynamic>notificacionPulsada(String c){
 print(c.toString());
 
   Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>ConversacionesLikes()) );
  
  


return null;}

Future<dynamic>onDidReceiveLocalNotification(int canal,String a,String b,String c){
   Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>ConversacionesLikes()) );
 return null;
}



 static  void mostrarNotificacionConexionCorrecta(BuildContext context) {
 
    Flushbar(
      message: "Estas conectado",
      duration: Duration(seconds:3),
  
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.green,
      forwardAnimationCurve: Curves.ease,
      title: "Conexion",
      icon: Icon(LineAwesomeIcons.check_circle),
      reverseAnimationCurve: Curves.ease,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      borderRadius: 10,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(10),
    )..show(context);
  }

  
 static  void mostrarNotificacionConexionPerdida(BuildContext context) {
    Flushbar(
      message: "Estas desconectado",
      duration: Duration(seconds:3),

      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.red,
      forwardAnimationCurve: Curves.ease,
      title: "Conexion",
      icon: Icon(Icons.cancel,),
      reverseAnimationCurve: Curves.ease,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      borderRadius: 10,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
    )..show(context);
  }
   


}


class Sanciones extends StatefulWidget {
  static List<Sanciones> listaSanciones=[];
 final String sancion;

  Sanciones({@required this.sancion});
  @override
  _SancionesState createState() => _SancionesState();
}

class _SancionesState extends State<Sanciones> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
      child:Text("- ${widget.sancion}",style:GoogleFonts.lato(color: Colors.white,fontSize:50.sp))
      
    );
  }
}


class PantallaSancion extends StatefulWidget {
  static final formatoTiempoMes=DateFormat("M");
  static final formatoTiempoDia=DateFormat("d");
  static final formatoTiempoHora=DateFormat("HH");
  static final formatoTiempoMinuto=DateFormat("mm");
  static final formatoTiempoSegundo=DateFormat("ss");
  static final formatoGral= new DateFormat("M:DD:HH:mm:ss");
  static final GlobalKey clavePantallaSancion=new GlobalKey();
  final bool desdePantalla;

  PantallaSancion({@required this.desdePantalla});
 
  @override
  _PantallaSancionState createState() => _PantallaSancionState();
}

class _PantallaSancionState extends State<PantallaSancion> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      key: PantallaSancion.clavePantallaSancion,
      value: Conversacion.conversaciones,
      child: Consumer<Conversacion>(
         builder: (context, myType, child) {
            print("cargado");


           return  SafeArea(
             
                    child: Material(
                      child: Container(
                       height: ScreenUtil.screenHeight,
                       width: ScreenUtil.screenWidth,
                       child: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child:SancionesUsuario.instancia.finSancion!=true? Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text("Su cuenta ha sido bloqueada hasta el ${BaseAplicacion.formatoFecha.format(Usuario.esteUsuario.bloqueadoHasta)}",style:GoogleFonts.lato(color: Colors.white,fontSize:60.sp)),
                             Divider(height: 100.h,),
                             Text("En Hotty nos tomamos muy en serio la seguridad y comodidad de nuestra comunidad,su perfil fue denunciado y moderado por las siguientes causas",style:GoogleFonts.lato(color: Colors.white,fontSize:50.sp)),
                             Container(decoration: BoxDecoration(color: Colors.blue),),
                             Divider(height: 100.h,),

                             Container(
                               
                               height: 400.h,
                               child: ListView(
                                 physics: NeverScrollableScrollPhysics(),
                                 children: Sanciones.listaSanciones,)),

                               Container(height: 200.h,child: StreamBuilder<int>(
                                 stream: SancionesUsuario.instancia.contador.stream,
                                 initialData: SancionesUsuario.instancia.segundosRestantes,

                                 builder: (BuildContext context,AsyncSnapshot<int> dato){
                                   

                                 return Column(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                      Text("Tiempo restante:",style:GoogleFonts.lato(color: Colors.white,fontSize:40.sp)),

                                 //    Text(PantallaSancion.formatoGral.format(DateTime(0,0,0,0,0,SancionesUsuario.segundosRestantes)),style:GoogleFonts.lato(color: Colors.white,fontSize:50.sp)),


                                    Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                       children: [
                                       
                                      SancionesUsuario.instancia.segundosRestantes>86400?   Column(
                                           children: [
                                             Text(PantallaSancion.formatoTiempoDia.format(DateTime(0,0,0,0,0,SancionesUsuario.instancia.segundosRestantes)),style:GoogleFonts.lato(color: Colors.white,fontSize:50.sp)),
                                               Text("Dias",style:GoogleFonts.lato(color: Colors.white,fontSize:40.sp)),

                                           ],
                                         ):Container(height: 0,width:0,),
                              SancionesUsuario.instancia.segundosRestantes>3600?                   Column(
                                           children: [
                                             Text(PantallaSancion.formatoTiempoHora.format(DateTime(0,0,0,0,0,SancionesUsuario.instancia.segundosRestantes)),style:GoogleFonts.lato(color: Colors.white,fontSize:50.sp)),
                                               Text("Horas",style:GoogleFonts.lato(color: Colors.white,fontSize:40.sp)),

                                           ],
                                         ):Container(height: 0,width:0,),
                                               Column(
                                           children: [
                                             Text(PantallaSancion.formatoTiempoMinuto.format(DateTime(0,0,0,0,0,SancionesUsuario.instancia.segundosRestantes)),style:GoogleFonts.lato(color: Colors.white,fontSize:50.sp)),
                                               Text("Minutos",style:GoogleFonts.lato(color: Colors.white,fontSize:40.sp)),

                                           ],
                                         ),
                                               Column(
                                           children: [
                                             Text(PantallaSancion.formatoTiempoSegundo.format(DateTime(0,0,0,0,0,SancionesUsuario.instancia.segundosRestantes)),style:GoogleFonts.lato(color: Colors.white,fontSize:50.sp)),
                                               Text("Segundos",style:GoogleFonts.lato(color: Colors.white,fontSize:40.sp)),

                                           ],
                                         ),
                                       ],
                                     ),
                                   ],
                                 );
                               },),),



                                 Divider(height: 100.h,),
                             
                             RaisedButton(
                               color: Colors.redAccent,
                               onPressed:(){ ControladorInicioSesion.instancia.cerrarSesion().then((val){
                                
                                     if(val){
                                Navigator.pop(context);
                                 }
                                  
                                 
                               });},
                               child: Text("Cerrar Sesion"),),
                                  RaisedButton(
                               onPressed:(){ ControladorInicioSesion.instancia.cerrarSesion().then((val){
                                 if(val){
                                   Navigator.pop(context);
                                 }
                               });},
                               child: Text("Más informacion"),),
                           ],
                         ):Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                            
                             Divider(height: 100.h,),
                             Text("Ha terminado tu periodo de sanción",style:GoogleFonts.lato(color: Colors.white,fontSize:80.sp)),
                             Divider(height: 100.h,),
                             Center(child: Text("Ya puedes volver a utilizar Hotty con normalidad",style:GoogleFonts.lato(color: Colors.white,fontSize:45.sp,),textAlign: TextAlign.center,)),
                             Container(decoration: BoxDecoration(color: Colors.blue),),
                             Divider(height: 100.h,),

                             

                               Container(height: 200.h,child: StreamBuilder<int>(
                                 stream: SancionesUsuario.instancia.contador.stream,
                                 initialData: SancionesUsuario.instancia.segundosRestantes,

                                 builder: (BuildContext context,AsyncSnapshot<int> dato){
                                   

                                 return Column(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                   

                                
                                   ],
                                 );
                               },),),



                                 Divider(height: 100.h,),
                             
                             RaisedButton(
                               color: Colors.green,
                               onPressed:(){  ControladorInicioSesion.instancia.cerrarSesion().then((val){
                                 if(val){
                                Navigator.pop(context);
                                 }
                               });},
                               child: Text("Entendido"),),
                              
                           ],
                         )

                       ), 
                       
                       
                        color:Colors.deepPurple,),
                    ),
                  )  ;
         },
       ),
    );
  }
}