import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class crush_box extends StatelessWidget {
  Widget build(BuildContext context) {
    return (Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.deepPurple.shade100),
        height: ScreenUtil().setHeight(300),
        child: Row(
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(300),
              height: ScreenUtil().setHeight(300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'https://www.hotcelibrity.com/wp-content/uploads/2019/04/Karol-G-2019-Billboard-Latin-Music-Awards-6-360x640.jpg')),
                shape: BoxShape.rectangle,
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(300),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    SizedBox(
                      width: ScreenUtil().setWidth(1000),
                      height: ScreenUtil().setHeight(150),
                      child: Text(
                        "Nombre de contacto",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: ScreenUtil()
                                .setSp(50, allowFontScalingSelf: true),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(140),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.people,
                                size: ScreenUtil().setSp(67),
                              ),
                              Text(
                                "67",
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(60)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(140),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.chat,
                                size: ScreenUtil().setSp(67),
                              ),
                              Text(
                                "67",
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(60)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(140),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.videocam,
                                size: ScreenUtil().setSp(67),
                              ),
                              Text(
                                "67",
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(60)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(200),
                          height: ScreenUtil().setHeight(140),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.local_bar,
                                size: ScreenUtil().setSp(67),
                              ),
                              Text(
                                "67",
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(60)),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}

class album_box extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: ScreenUtil().setHeight(200),
          child: Row(
            children: <Widget>[
              Container(
                height: ScreenUtil().setHeight(200),
                width: ScreenUtil().setWidth(200),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(
                            'https://www.hotcelibrity.com/wp-content/uploads/2019/04/Karol-G-2019-Billboard-Latin-Music-Awards-6-360x640.jpg'))),
              ),
              Container(
                height: ScreenUtil().setHeight(180),
                width: ScreenUtil().setWidth(1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      "Carolina Giraldo",
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(60),
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          size: ScreenUtil().setSp(40),
                        ),
                        Text(
                          "Medellin, Colombia",
                          style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.deepPurple.shade200,
              image: DecorationImage(
                  image: NetworkImage(
                      'https://fitnessvolt.com/wp-content/uploads/2019/07/jeremy-buendia-and-hilda-laura-amaral-750x374.jpg'))),
          height: ScreenUtil().setHeight(1500),
        ),
        Container(
          height: ScreenUtil().setHeight(200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("230 Likes       "),
              Icon(
                Icons.chat_bubble,
                color: Colors.deepPurple,
              ),
              Text("   98")
            ],
          ),
        ),
      ],
    );
  }
}

class chat_box extends StatelessWidget {
  Widget build(BuildContext context) {
    return (Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.deepPurple.shade100),
        height: ScreenUtil().setHeight(300),
        child: Row(
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(300),
              height: ScreenUtil().setHeight(300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'https://www.hotcelibrity.com/wp-content/uploads/2019/04/Karol-G-2019-Billboard-Latin-Music-Awards-6-360x640.jpg')),
                shape: BoxShape.rectangle,
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(300),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    SizedBox(
                      width: ScreenUtil().setWidth(900),
                      height: ScreenUtil().setHeight(150),
                      child: Text(
                        "Carolina Esteban",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: ScreenUtil()
                                .setSp(70, allowFontScalingSelf: true),
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                        SizedBox(
                          width: ScreenUtil().setWidth(850),
                          height: ScreenUtil().setHeight(140),
                          child: Text(

                            "que tal te has levantado?? yo muy bien jaja te he preparado bbbbbbbb",
                            style: TextStyle(fontSize: ScreenUtil().setSp(60)),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("11:30"),
                Container(
                    width: ScreenUtil().setWidth(100),
                    height: ScreenUtil().setHeight(100),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),color: Colors.deepPurple),
                  child:
                      Center(
                        child:
                  Text(
                    "3",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                  ),),
                )
              ],
            )
          ],
        ),
      ),
    ));
  }
}
