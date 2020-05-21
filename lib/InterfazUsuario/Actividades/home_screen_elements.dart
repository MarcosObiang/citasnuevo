import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class home_screen_elements extends StatelessWidget {

  String Imagen_tarjeta;
  String Nombre_Plan;
  String Ubicacion;
  String Tiempo_restante;
  String Contactos_en_Plan;
  @override
  Widget build(BuildContext context) {


    // TODO: implement build
    return Container(
      child: SizedBox(
        width: ScreenUtil().setWidth(400),
        height:ScreenUtil().setHeight(718),
        child: Card(
          color: Colors.white,
          elevation: 8.0,
          borderOnForeground: true,
          child: Row(
            //*******************************************************************************************************************************+Primera mitad de la tarjeta

            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                width: ScreenUtil().setWidth(550),
                height:ScreenUtil().setHeight(715),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      width: ScreenUtil().setWidth(550),
                      height:ScreenUtil().setHeight(530),
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.all(Radius.circular(6.0)),
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  'https://files.rcnradio.com/public/styles/image_834x569/public/2019-11/Rosal%C3%ADa.jpg?itok=0qv61R6w'))),

                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(550),
                      height:ScreenUtil().setHeight(150),
                      child:

                      Container(
                        width: ScreenUtil().setWidth(550),
                        height:ScreenUtil().setHeight(150),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius:
                            BorderRadius.all(Radius.circular(6.0))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: ScreenUtil().setSp(70,allowFontScalingSelf:true),
                              color: Colors.white,
                            ),
                            Text(
                              "Me Apunto",
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(70,allowFontScalingSelf:true), color: Colors.white),
                            ),
                          ],

                        ),
                      ),



                    ), ],
                ),
                //Aqui acaba la primera mitad de la tarjeta**************************************************************************
              ),

              Container(
                  width: ScreenUtil().setWidth(850),
                  height:ScreenUtil().setHeight(700),
                  //color: Colors.red,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ScreenUtil().setWidth(850),
                          height:ScreenUtil().setHeight(200),
                          child: Text(
                            "Atleti vs Madrid En Botanica (Cubo a 6 euros) y Shisha",
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(57,allowFontScalingSelf: true),
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(840),
                          height:ScreenUtil().setHeight(120),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: ScreenUtil().setSp(57,allowFontScalingSelf: true),
                              ),
                              Flexible(
                                child:
                                Text(
                                  "Calle Guadalajara, 8, 4D, Mostoles, Madrid España"
                                  ,style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40,allowFontScalingSelf: true),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),maxLines: 3,),),

                            ],
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(840),
                          height:ScreenUtil().setHeight(120),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: ScreenUtil().setSp(57,allowFontScalingSelf: true),
                              ),
                              Flexible(
                                child:
                                Text(
                                  "23/01/2020 a las 22:30h (quedan 2 dias) y 7 horas"
                                  ,style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40,allowFontScalingSelf: true),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),maxLines: 3,),),

                            ],
                          ),
                        ),


                        SizedBox(
                          width: ScreenUtil().setWidth(840),
                          height:ScreenUtil().setHeight(130),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.people,
                                size: ScreenUtil().setSp(57,allowFontScalingSelf: true),
                              ),
                              Flexible(
                                child:
                                Text(
                                  "Carlos Sanchez, Manuel Guerrra, Alvaro Varo y 30 personas mas se apuntan",style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40,allowFontScalingSelf: true),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),maxLines: 3,),),

                            ],
                          ),
                        ),SizedBox(
                          width: ScreenUtil().setWidth(840),
                          height:ScreenUtil().setHeight(80),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.chat,
                                size: ScreenUtil().setSp(57,allowFontScalingSelf: true),
                              ),
                              Flexible(
                                child:
                                Text(
                                  " 6 Comentarios",style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40,allowFontScalingSelf: true),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),maxLines: 3,),),

                            ],
                          ),
                        ),

                      ])),

            ],
          ),
        ),
      ),
    );
  }}
