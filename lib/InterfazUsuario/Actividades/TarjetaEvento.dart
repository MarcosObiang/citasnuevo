import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class TarjetaEvento extends StatefulWidget {

  String Nombre_Plan;
  String Ubicacion;
  String FechaEvento;
  String Contactos_en_Plan;
  String ImagenURL1;
  String ImagenURL2;
  String ImagenURL3;
  String ImagenURL4;
  String ImagenURL5;
  String ImagenURL6;
  List<String> Imagenes;





  TarjetaEvento(

      this.Nombre_Plan, this.Ubicacion, this.FechaEvento, this.Imagenes);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TarjetaEventoState();
  }
}

class TarjetaEventoState extends State<TarjetaEvento> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: SizedBox(
        width: ScreenUtil().setWidth(400),
        height: ScreenUtil().setHeight(718),
        child: Card(
          color: Colors.white,
          elevation: 8.0,
          borderOnForeground: true,
          child: Row(
            //*******************************************************************************************************************************+Primera mitad de la tarjeta

            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[
              Flexible(
                fit: FlexFit.tight,
                flex: 100,
                child: SizedBox(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3.0)),
                    ),
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return  Image.network(
                          widget.Imagenes[index]??"https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: widget.Imagenes.length,
                      pagination: SwiperPagination(
                      ),

                    ),
                  ),

                  //Aqui acaba la primera mitad de la tarjeta**************************************************************************
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 3,
                child: Container(),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 85,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                         widget.Nombre_Plan,
                          style: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(50, allowFontScalingSelf: false),
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setHeight(25),
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: ScreenUtil()
                                  .setSp(57, allowFontScalingSelf: false),
                            ),
                            Flexible(
                              child: Text(
                               widget.Ubicacion,
                                style: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(40, allowFontScalingSelf: false),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                                maxLines: 3,
                              ),
                            ),
                          ]),
                      Container(
                        height: ScreenUtil().setHeight(25),
                      ),
                      SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: ScreenUtil()
                                  .setSp(57, allowFontScalingSelf: true),
                            ),
                            Flexible(
                              child: Text(
                                widget.FechaEvento,
                                style: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(40, allowFontScalingSelf: true),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: ScreenUtil().setHeight(25),
                      ),
                      SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.people,
                              size: ScreenUtil()
                                  .setSp(57, allowFontScalingSelf: true),
                            ),
                            Flexible(
                              child: Text(
                                "Carlos Sanchez, Alvaro Varo y 30 personas mas se apuntan",
                                style: TextStyle(
                                    fontSize: ScreenUtil()
                                        .setSp(40, allowFontScalingSelf: true),
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(25),
                        child: Center(
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
