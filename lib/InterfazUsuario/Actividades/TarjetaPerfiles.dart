import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/DatosAplicacion/Usuario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ImagenesCarrete extends StatefulWidget {
  String urlImagen;
  String nombre;
  String alias;
  String edad;
  String pieFoto;
  bool nombreEnFoto;
  Image laimagen;
  bool imagenCargada = false;
  double distancia;
  static BoxConstraints limitesCuadro = new BoxConstraints();

  ImagenesCarrete(this.urlImagen,
      {@required this.distancia, this.nombre, this.alias, this.edad, this.pieFoto, this.nombreEnFoto}) {
    //cargarImagen();
  }

  @override
  _ImagenesCarreteState createState() => _ImagenesCarreteState();
}

class _ImagenesCarreteState extends State<ImagenesCarrete> {
  Uint8List bitsImagen;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () {
        print("object");
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) 
          => VisorImagenesPerfiles(imagen: widget.urlImagen)
        ));
      },
      child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 0),
          child: Container(
            child: Column(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: <Widget>[
                        widget.nombreEnFoto
                            ? Container(
                                height: ImagenesCarrete
                                    .limitesCuadro.biggest.height,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(widget.urlImagen),
                                        fit: BoxFit.cover)),
                              )
                            : CachedNetworkImage(
                                imageUrl: widget.urlImagen,
                              ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0, bottom: 0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(1.5)),
                                color: Color.fromRGBO(0, 0, 0, 80)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  widget.nombreEnFoto
                                      ? Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                              "${widget.nombre}, ${widget.edad}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      ScreenUtil().setSp(40))),
                                        )
                                      : Container(),
                                  widget.nombreEnFoto
                                      ? Padding(
                                          padding: const EdgeInsets.all(2.5),
                                          child: Text("A ${widget.distancia.toInt()} Km de ti",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      ScreenUtil().setSp(40))),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Container(
                  child:
                      widget.pieFoto == null ? Text("") : Text(widget.pieFoto),
                )
              ],
            ),
          )),
    );
  }
}

// ignore: must_be_immutable
class VisorImagenesPerfiles extends StatefulWidget {
  String imagen;
  VisorImagenesPerfiles({@required this.imagen});

  @override
  _VisorImagenesPerfilesState createState() => _VisorImagenesPerfilesState();
}

class _VisorImagenesPerfilesState extends State<VisorImagenesPerfiles> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.deepPurple[900],
          child: SafeArea(
                      child: Container(
            color: Colors.deepPurple[900],
            child: LayoutBuilder(builder: (
              BuildContext context,
              BoxConstraints limites,
            ) {
              return Container(
                  height: limites.biggest.height,
                  width: limites.biggest.width,
                  color: Colors.deepPurple[900],
                  child: Column(
                      children: [
                        Flexible(
                   flex: 12,
              fit:FlexFit.tight,
              
              child: Container(child: InteractiveViewer(child: Image.network(widget.imagen)))),
                        Flexible(
              flex: 1,
              fit:FlexFit.tight,
                child: Container(
                
                color: Colors.red,
                child: FlatButton(onPressed: (){Navigator.pop(context);}, child: Text("Atras"))),
                        )
                      ],
                    ),
                );
            })),
          ),
    );
  }
}


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
        color: Colors.red,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sobre mi:",
              style: TextStyle(color: Colors.black),
            ),
            Divider(
              height: ScreenUtil().setHeight(100),
              color: Colors.transparent,
            ),
            Text(
              descripcionPerfil,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class BloquePreguntasPersonales extends StatelessWidget {
  Map<String, dynamic> preguntaRespuesta;

  BloquePreguntasPersonales({@required this.preguntaRespuesta}) {}

  @override
  Widget build(BuildContext context) {
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

  String valorAltura;

  String valorBusco;

  String valorComplexion;

  String valorHijos;

  String valorMascotas;

  String valorTabaco;

  String valorAlcohol;

  String valorPolitica;

  String valorQueVivaCon;

  bool complexionIgual=false;

  bool buscoIgual=false;

  bool hijosIgual=false;

  bool mascotasIgual=false;

  bool alcoholIgual=false;

  bool tabacoIgual=false;

  bool politicaIgual=false;

  bool queVivaConIgual=false;

bool filtrosCargados=false;
  BloqueFiltrosPersonales({@required this.filtroValor}) {
    

  }

  @override
  _BloqueFiltrosPersonalesState createState() => _BloqueFiltrosPersonalesState();
}

class _BloqueFiltrosPersonalesState extends State<BloqueFiltrosPersonales> {
  List<Widget> filtrosCreados = new List();


  
  void init(){

    super.initState();
    cincidenciaFiltros();
  }

void cincidenciaFiltros(){
  
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
      widget. alcohol = true;
        if(filtros["Valor"]==1){

          widget.valorQueVivaCon="Solo";
        }
        if(filtros["Valor"]==2){
          widget.valorQueVivaCon="Con padres";
        }
            if(filtros["Valor"]==3){
          widget.valorQueVivaCon="Con amigos";
        }
      
      if(filtros["Valor"]==Usuario.esteUsuario.alcohol){
          widget.alcoholIgual=true;
        }


        }



      }
    
    widget.filtrosCargados=true;
    
    }










}

  @override
  Widget build(BuildContext context) {
    if(!widget.filtrosCargados){
      cincidenciaFiltros();
      print("Filtrapa");
    }
    // TODO: implement build
    return Container(
      height: ScreenUtil().setHeight(400),
      width: ImagenesCarrete.limitesCuadro.biggest.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: ScreenUtil().setWidth(10),
              mainAxisSpacing: ScreenUtil().setHeight(10),
              childAspectRatio: 5 / 1.5,
              crossAxisCount: 3,
              children: [
                widget.altura
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.purple,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                LineAwesomeIcons.ruler_vertical,
                                size: ScreenUtil().setSp(40),
                                color: Colors.white,
                              ),
                              Text(
                                widget.valorAltura,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(40)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(color: Colors.transparent),
               widget. busco
                    ? Container(
                        decoration: BoxDecoration(
                          color: widget.buscoIgual?Colors.green: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                LineAwesomeIcons.ring,
                                size: ScreenUtil().setSp(40),
                              ),
                              Text(
                               widget. valorBusco,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil().setSp(40)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(color: Colors.transparent),
                widget.complexion
                    ? Container(
                        decoration: BoxDecoration(
                              color: widget.complexionIgual?Colors.green: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                LineAwesomeIcons.dumbbell,
                                size: ScreenUtil().setSp(40),
                              ),
                              Text(
                                widget.valorComplexion,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil().setSp(40)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(color: Colors.transparent),
                widget.hijos
                    ? Container(
                        decoration: BoxDecoration(
                              color: widget.hijosIgual?Colors.green: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                LineAwesomeIcons.ring,
                                size: ScreenUtil().setSp(40),
                              ),
                              Text(
                                widget.valorHijos,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil().setSp(40)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(color: Colors.transparent),
               widget. mascotas
                    ? Container(
                        decoration: BoxDecoration(
                              color: widget.mascotasIgual?Colors.green: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                LineAwesomeIcons.dog,
                                size: ScreenUtil().setSp(40),
                              ),
                              Text(
                                widget.valorMascotas,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil().setSp(40)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(color: Colors.transparent),
                widget.politica
                    ? Container(
                        decoration: BoxDecoration(
                              color: widget.politicaIgual?Colors.green: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                LineAwesomeIcons.landmark,
                                size: ScreenUtil().setSp(40),
                              ),
                              Text(
                                widget.valorPolitica,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil().setSp(40)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(color: Colors.transparent),
                widget.queVivaCon
                    ? Container(
                          
                        decoration: BoxDecoration(
                          color:widget. queVivaConIgual?Colors.green: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                LineAwesomeIcons.home,
                                size: ScreenUtil().setSp(40),
                              ),
                              Text(
                               widget. valorQueVivaCon,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil().setSp(40)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(color: Colors.transparent),
              ]),
        ),
      ),
    );
  }
}