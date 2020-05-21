import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../Actividades/TarjetaEvento.dart';
import '../../main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class group_box extends StatelessWidget {
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
              width:ScreenUtil().setWidth(300),
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


              child:
              Align(
                alignment: Alignment.topLeft,
                child:
                Column(
                  children: [
                    SizedBox(
                      width: ScreenUtil().setWidth(1000),
                      height: ScreenUtil().setHeight(150),
                      child:

                      Text(
                        "We loooove cats and naruto boruto sharinganoopopopopopopopopo",textAlign: TextAlign.start,
                        style: TextStyle(fontSize: ScreenUtil().setSp(50,allowFontScalingSelf: true), fontWeight: FontWeight.bold),
                      ),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: ScreenUtil().setWidth(850),
                          height: ScreenUtil().setHeight(140),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.people,size: ScreenUtil().setSp(67),)
                              ,Text("67",style: TextStyle(fontSize: ScreenUtil().setSp(60)),),
                            ],
                          ),
                        )
                      ],

                    )

                  ]

                  ,),),)

          ],
        ),
      ),
    ));
  }
}
class live_video_view extends StatelessWidget {
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: Column(children: [
          Container(
            height: ScreenUtil().setHeight(900),
            width: ScreenUtil().setWidth(700),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'https://www.hotcelibrity.com/wp-content/uploads/2019/04/Karol-G-2019-Billboard-Latin-Music-Awards-6-360x640.jpg'))),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              height: ScreenUtil().setHeight(200),
              width: ScreenUtil().setWidth(700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Carolina,28",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(60,allowFontScalingSelf: true),
                        color: Colors.black87,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children:[
                      Icon(Icons.remove_red_eye,size: ScreenUtil().setSp(70,allowFontScalingSelf: true),),
                      Text(
                        " 34",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(60,allowFontScalingSelf: true),
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                      )],)
                ],
              ),
            ),
          ),
        ]));
  }
}
class chat_view extends StatelessWidget {
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: Column(children: [
          Container(
            height: ScreenUtil().setHeight(500),
            width: ScreenUtil().setWidth(400),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        'https://www.hotcelibrity.com/wp-content/uploads/2019/04/Karol-G-2019-Billboard-Latin-Music-Awards-6-360x640.jpg'))),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              height: ScreenUtil().setHeight(100),
              width: ScreenUtil().setWidth(400),
              child:
              Text(
                "Carolina,28",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(40,allowFontScalingSelf: true),
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),

            ),
          ),
        ]));
  }
}
