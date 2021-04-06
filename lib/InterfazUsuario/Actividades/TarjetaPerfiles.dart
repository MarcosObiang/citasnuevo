import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bitmap/bitmap.dart';
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/DatosAplicacion/ControladorLocalizacion.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:citasnuevo/InterfazUsuario/Ajustes/PantallaAjustes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ImagenesCarrete extends StatefulWidget {
  String urlImagen;
  String nombre;
  String alias;
  String edad;
  String pieFoto;
  bool nombreEnFoto;
  ImageProvider laimagen;
  bool imagenCargada = false;
  double distancia;
  int altura;
  int ancho;
  String hash;
  ui.Image imagen;
  bool verificado;
  static BoxConstraints limitesCuadro = new BoxConstraints();

  ImagenesCarrete(this.urlImagen,
      {
        @required this.hash,
        @required this.altura,@required this.ancho,
        @required this.verificado,
        
        @required this.distancia, this.nombre, this.alias, this.edad, this.pieFoto, this.nombreEnFoto}) {
 // cargarHash();
  }

  

  @override
  _ImagenesCarreteState createState() => _ImagenesCarreteState();
}

class _ImagenesCarreteState extends State<ImagenesCarrete> {

@override
void initState() {
    // TODO: implement initState
   
   widget.laimagen=NetworkImage(widget.urlImagen);
    super.initState();
    
  }





  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
precacheImage(widget.laimagen, context);

  }



  Uint8List bitsImagen;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 0),
        child: Container(
          color: Colors.black,
          child: Container(
              height: ImagenesCarrete
                  .limitesCuadro.biggest.height,
                  child:OctoImage(
                    fit:BoxFit.cover,
                 
                    image: CachedNetworkImageProvider(
                    widget.urlImagen
                  ),
                  placeholderBuilder: OctoPlaceholder.blurHash(widget.hash,fit:BoxFit.cover),
                  )
        
        )));
  }
}

// ignore: must_be_immutable


// ignore: must_be_immutable
class BloqueDescripcion1 extends StatelessWidget {
  String descripcionPerfil;

  BloqueDescripcion1(this.descripcionPerfil) {
    if (descripcionPerfil == null) {
      descripcionPerfil = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: ScreenUtil().setHeight(500),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sobre mi:",
              style: TextStyle(color: Colors.white),
            ),
            Divider(
              height: ScreenUtil().setHeight(50),
              color: Colors.white,
            ),
            Text(
              descripcionPerfil,
              style:
                  GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}


class BloquePreguntasPersonales extends StatelessWidget {
final  Map<String, dynamic> preguntaRespuesta;

  BloquePreguntasPersonales({@required this.preguntaRespuesta});

  @override
  Widget build(BuildContext context) {
    // ignore: todo
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              this.preguntaRespuesta["Pregunta"].toString(),
              style: TextStyle(color: Colors.black),
            ),
            Divider(
              height: ScreenUtil().setHeight(100),
              color: Colors.transparent,
            ),
            Text(
              this.preguntaRespuesta["Respuesta"].toString(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: ScreenUtil().setSp(90),
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class BloqueFiltrosPersonales extends StatefulWidget {
  List<Map<String, dynamic>> filtroValor;
    bool altura = false;

  bool busco = false;

  bool complexion = false;

  bool hijos = false;

  bool mascotas = false;

  bool alcohol=false;

  bool tabaco=false;

  bool politica = false;

  bool queVivaCon = false;

  bool sexualidad=false;

  

  String valorSexualidad;

  String valorAltura;

  String valorBusco;

  String valorComplexion;

  String valorHijos;

  String valorMascotas;

  String valorTabaco;

  String valorAlcohol;

  String valorPolitica;

  String valorQueVivaCon;
  bool sexualidadIgual=false;

  bool complexionIgual=false;

  bool buscoIgual=false;

  bool hijosIgual=false;

  bool mascotasIgual=false;

  bool alcoholIgual=false;

  bool tabacoIgual=false;

  bool politicaIgual=false;

  bool queVivaConIgual=false;

bool filtrosCargados=false;
  BloqueFiltrosPersonales({@required this.filtroValor});

  @override
  _BloqueFiltrosPersonalesState createState() => _BloqueFiltrosPersonalesState();
}

class _BloqueFiltrosPersonalesState extends State<BloqueFiltrosPersonales> {
 int alturaCm;
  

  List<Widget> filtrosCreados = new List();


  @override
  void initState(){
  
    
    coincidenciaFiltros();
    alturaCm= (double.parse(widget.valorAltura)*100).toInt() ;
    super.initState();
  }

void coincidenciaFiltros(){
  
     for (Map filtros in widget.filtroValor) {
      Icon simbolo = Icon(Icons.home);
      if (filtros["Filtro"] == "Altura") {
        simbolo = Icon(
          LineAwesomeIcons.ruler_vertical,
          size: 50,
        );
        widget.altura = true;
        widget.valorAltura = filtros["Valor"].toString();
      }
      if (filtros["Filtro"] == "Busco") {
        simbolo = Icon(LineAwesomeIcons.ring);
       

        if(filtros["Valor"]!=0){
        widget.busco = true;
        if(filtros["Valor"]==1){

          widget.valorBusco="Relacion seria";
        }
        if(filtros["Valor"]==2){
          widget.valorBusco="Lo que surja";
        }
            if(filtros["Valor"]==3){
          widget.valorBusco="Algo casual";
        }
            if(filtros["Valor"]==4){
          widget.valorBusco="No lo se";
        }

   
        
        
        }
      }
      if (filtros["Filtro"] == "Complexion") {
        simbolo = Icon(LineAwesomeIcons.snowboarding);
  
           if(filtros["Valor"]!=0){
        widget.complexion = true;
        if(filtros["Valor"]==1){

          widget.valorComplexion="Normal";
        }
        if(filtros["Valor"]==2){
          widget.valorComplexion="Atletica";
        }
            if(filtros["Valor"]==3){
          widget.valorComplexion="Musculosa";
        }
            if(filtros["Valor"]==4){
          widget.valorComplexion="Talla grande";
        }
           if(filtros["Valor"]==5){
          widget.valorComplexion="Delgado";
        }
          if(filtros["Valor"]==Usuario.esteUsuario.complexion){
          widget.complexionIgual=true;
        }
        



      }


  
    }
    
       
      if (filtros["Filtro"] == "Hijos") {
        simbolo = Icon(LineAwesomeIcons.baby);
        
      

        if(filtros["Valor"]!=0){
        widget.hijos = true;
        if(filtros["Valor"]==1){

          widget.valorHijos="Algun dia";
        }
        if(filtros["Valor"]==2){
          widget.valorHijos="Nunca";
        }
            if(filtros["Valor"]==3){
          widget.valorHijos="Tengo hijos";
        }
    
  if(filtros["Valor"]==Usuario.esteUsuario.hijos){
          widget.hijos=true;
        }

        }
      }
      if (filtros["Filtro"] == "Mascotas") {
        simbolo = Icon(LineAwesomeIcons.dog);
       
        
           if(filtros["Valor"]!=0){
        widget.mascotas = true;
        if(filtros["Valor"]==1){

          widget.valorMascotas="Perro";
        }
        if(filtros["Valor"]==2){
          widget.valorMascotas="Gato";
        }
            if(filtros["Valor"]==3){
          widget.valorMascotas="No tengo";
        }
                if(filtros["Valor"]==3){
          widget.valorMascotas="Me gustaria";
        }
    
  if(filtros["Valor"]==Usuario.esteUsuario.mascotas){
          widget.mascotas=true;
        }

        }
      }
      if (filtros["Filtro"] == "Politca") {
        simbolo = Icon(LineAwesomeIcons.landmark);
        
      
           
           if(filtros["Valor"]!=0){
       widget.politica = true;
        if(filtros["Valor"]==1){

          widget.valorPolitica="Derechas";
        }
        if(filtros["Valor"]==2){
          widget.valorPolitica="Izquierdas";
        }
            if(filtros["Valor"]==3){
          widget.valorPolitica="Centro";
        }
                if(filtros["Valor"]==4){
          widget.valorPolitica="Apolitico";
        }
    

  if(filtros["Valor"]==Usuario.esteUsuario.politica){
          widget.politicaIgual=true;
        }
        }
      }
      if (filtros["Filtro"] == "Que viva con") {
        simbolo = Icon(LineAwesomeIcons.home);
        
        
    if(filtros["Valor"]!=0){
       widget.queVivaCon = true;
        if(filtros["Valor"]==1){

         widget. valorQueVivaCon="Solo";
        }
        if(filtros["Valor"]==2){
          widget.valorQueVivaCon="Con padres";
        }
            if(filtros["Valor"]==3){
          widget.valorQueVivaCon="Con amigos";
        }
      
    
  if(filtros["Valor"]==Usuario.esteUsuario.vivoCon){
          widget.queVivaConIgual=true;
        }

        }



      }

            if (filtros["Filtro"] == "Alcohol") {
        simbolo = Icon(LineAwesomeIcons.beer);
      
        
    if(filtros["Valor"]!=0){
      widget.alcohol = true;
        if(filtros["Valor"]==1){

          widget.valorAlcohol="En sociedad";
        }
        if(filtros["Valor"]==2){
          widget.valorAlcohol="No bebo";
        }
            if(filtros["Valor"]==3){
          widget.valorAlcohol="Bebo";
        }
            if(filtros["Valor"]==4){
          widget.valorAlcohol="Odio el alcohol";
        }
      
      if(filtros["Valor"]==Usuario.esteUsuario.alcohol){
          widget.alcoholIgual=true;
        }


        }



      }
      
            if (filtros["Filtro"] == "Tabaco") {
        simbolo = Icon(LineAwesomeIcons.smoking);
      
        
    if(filtros["Valor"]!=0){
      widget.tabaco = true;
        if(filtros["Valor"]==1){

          widget.valorTabaco="Fumo";
        }
        if(filtros["Valor"]==2){
          widget.valorTabaco="No fumo";
        }
            if(filtros["Valor"]==3){
          widget.valorTabaco="A veces";
        }
            if(filtros["Valor"]==4){
          widget.valorTabaco="Odio el tabaco";
        }
      
      if(filtros["Valor"]==Usuario.esteUsuario.tabaco){
          widget.tabacoIgual=true;
        }


        }



      }

               if (filtros["Filtro"] == "orientacionSexual") {
        simbolo = Icon(LineAwesomeIcons.venus_mars);
      
        
    if(filtros["Valor"]!=0){
      widget.sexualidad = true;
        if(filtros["Valor"]==1){

          widget.valorSexualidad="Heterosexual";
        }
        if(filtros["Valor"]==2){
    widget.valorSexualidad="Gay";
        }
            if(filtros["Valor"]==3){
          widget.valorSexualidad="Lesbiana";
        }
            if(filtros["Valor"]==4){
          widget.valorSexualidad="Bisexual";
        }
              if(filtros["Valor"]==5){
          widget.valorSexualidad="Asexual";
        }
              if(filtros["Valor"]==6){
          widget.valorSexualidad="Demisexual";
        }
              if(filtros["Valor"]==7){
          widget.valorSexualidad="Queer";
        }
              if(filtros["Valor"]==8){
          widget.valorSexualidad="Pansexual";
        }
              if(filtros["Valor"]==9){
          widget.valorSexualidad="Preguntame";
        }
      
      if(filtros["Valor"]==Usuario.esteUsuario.getOrientacionSexual){
          widget.sexualidadIgual=true;
        }


        }



      }
    
    widget.filtrosCargados=true;
    
    }










}

  @override
  Widget build(BuildContext context) {
   
    if(!widget.filtrosCargados){
      coincidenciaFiltros();
      
    }
    // TODO: implement build
    return Container(
      height: ScreenUtil().setHeight(550),
      width: ImagenesCarrete.limitesCuadro.biggest.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 30,bottom:30,left: 10,right: 10),
          child: Wrap(
            runSpacing: 20.w,
            spacing: 20.w,
          
            runAlignment: WrapAlignment.spaceEvenly,

              children: [
                widget.altura
                    ? Container(
                        width: 250.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.grey[400],
                         
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                LineAwesomeIcons.ruler_vertical,
                                size: ScreenUtil().setSp(50),
                                color: Colors.black,
                              ),
                              Text(
                          ControladorAjustes.instancia.mostrarCm?  "$alturaCm cm":"${(alturaCm*0.032808399).toStringAsFixed(2)} ft",
                                style: GoogleFonts.lato(

                                 fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                 ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(color: Colors.transparent),
               widget. busco
                    ?widgetValor(widget.buscoIgual,Icon(LineAwesomeIcons.ring,size: 50.sp,color: widget.buscoIgual?Colors.white: Colors.black,),widget.valorBusco)
                    : Container(color: Colors.transparent),
                widget.complexion
                    ? widgetValor(widget.complexionIgual,Icon(LineAwesomeIcons.dumbbell,size: 50.sp,color: widget.complexionIgual?Colors.white: Colors.black,),widget.valorComplexion)
                    : Container(color: Colors.transparent),
                widget.hijos
                    ? widgetValor(widget.hijosIgual,Icon(LineAwesomeIcons.baby,size: 50.sp,color: widget.hijosIgual?Colors.white: Colors.black,),widget.valorHijos)
                    : Container(color: Colors.transparent),
               widget. mascotas
                    ? widgetValor(widget.mascotasIgual,Icon(LineAwesomeIcons.dog,size: 50.sp,color: widget.mascotasIgual?Colors.white: Colors.black,),widget.valorMascotas)
                    : Container(color: Colors.transparent),
                widget.politica
                    ? widgetValor(widget.politicaIgual,Icon(LineAwesomeIcons.place_of_worship,size: 50.sp,color: widget.politicaIgual?Colors.white: Colors.black,),widget.valorPolitica)
                    : Container(color: Colors.transparent),
                widget.queVivaCon
                    ? widgetValor(widget.queVivaConIgual,Icon(LineAwesomeIcons.home,size: 50.sp,color: widget.queVivaConIgual?Colors.white: Colors.black,),widget.valorQueVivaCon)
                    : Container(color: Colors.transparent),
                          widget.alcohol
                    ? widgetValor(widget.alcoholIgual,Icon(LineAwesomeIcons.beer,size: 50.sp,color: widget.alcoholIgual?Colors.white: Colors.black,),widget.valorAlcohol)
                    : Container(color: Colors.transparent)
                    ,
                          widget.tabaco
                    ? widgetValor(widget.tabacoIgual,Icon(LineAwesomeIcons.smoking,size: 50.sp,color: widget.tabacoIgual?Colors.white: Colors.black,),widget.valorTabaco)
                    : Container(color: Colors.transparent)
                    ,
                          widget.sexualidad
                    ? widgetValor(widget.sexualidadIgual,Icon(LineAwesomeIcons.venus_mars,size: 50.sp,color: widget.sexualidadIgual?Colors.white: Colors.black,),widget.valorSexualidad)
                    : Container(color: Colors.transparent)
              ]),
        ),
      ),
    );
  }

  Container widgetValor(bool esIgual,Icon icono,String valor) {
    return Container(
      width: 400.w,
    
                      decoration: BoxDecoration(
                            color: esIgual?Colors.deepPurple: Colors.grey[400],
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                     
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                           icono,
                            Padding(

                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                valor,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  
                         
                                    color: esIgual?Colors.white: Colors.black,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
  }
}

class BloqueFotosInstagram extends StatefulWidget {
  @override
  _BloqueFotosInstagramState createState() => _BloqueFotosInstagramState();
}

class _BloqueFotosInstagramState extends State<BloqueFotosInstagram> {
  @override
  Widget build(BuildContext context) {
    return Container(
           height: ScreenUtil().setHeight(800),
      width: ImagenesCarrete.limitesCuadro.biggest.width,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text("Instagram",style: GoogleFonts.lato(fontSize:60.sp),)),
          Flexible(
               flex: 7,
            fit: FlexFit.tight,
                      child: GridView.count(
              childAspectRatio: 1/0.8,
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              
     children:   [
             Container(color: Colors.red,),
             Container(color: Colors.red,),
             Container(color: Colors.red,),
             Container(color: Colors.red,),
             Container(color: Colors.red,),
            Container(color: Colors.red,),
     



            ]),
          ),
        ],
      ),
      
    );
  }
}