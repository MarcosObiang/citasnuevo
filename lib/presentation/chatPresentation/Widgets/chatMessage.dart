import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:intl/intl.dart';

import '../../../core/globalData.dart';

// ignore: must_be_immutable
class TextMessage extends StatefulWidget {
  Message message;
  Animation<double> animation;
  TextMessage({required this.message, required this.animation});

  @override
  _TextMessageState createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> {
  var dateformat = DateFormat.yMEd();

  @override
  void initState() {
    super.initState();

    if (widget.message.senderId == GlobalDataContainer.userId) {
      paddingData =
          EdgeInsets.only(top: 50.h, bottom: 50.h, left: 300.w, right: 20.w);
      messageColor = userMessagesColor;
    } else {
      paddingData =
          EdgeInsets.only(top: 50.h, bottom: 50.h, right: 300.w, left: 20.w);
      messageColor = remitentMessagesColor;
    }
  }

  late EdgeInsetsGeometry paddingData;
  Color userMessagesColor = Color.fromARGB(255, 107, 113, 143);
  Color remitentMessagesColor = Color.fromARGB(176, 161, 107, 242);
  late Color messageColor;

  @override
  Widget build(BuildContext context) {
    if (widget.message.senderId == GlobalDataContainer.userId) {
      paddingData =
          EdgeInsets.only(top: 30.h, bottom: 30.h, left: 300.w, right: 20.w);
      messageColor = userMessagesColor;
    } else {
      paddingData =
          EdgeInsets.only(top: 30.h, bottom: 30.h, right: 300.w, left: 20.w);
      messageColor = remitentMessagesColor;
    }
    return FadeTransition(
        opacity: widget.animation,
        child: widget.message.messageType != MessageType.DATE
            ? Padding(
                padding: paddingData,
                child: Column(
                  crossAxisAlignment:
                      widget.message.senderId == GlobalDataContainer.userId
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: messageColor,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                          padding: EdgeInsets.all(40.h),
                          child: widget.message.messageType ==
                                  MessageType.TEXT
                              ? Text(widget.message.data)
                              : Container(
                                  height: 700.w,
                                  width: 700.w,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          scale: 1,
                                          image: CachedNetworkImageProvider(
                                            widget.message.data,
                                          ))),
                                )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.h),
                      child: Container(
                        child: Text(widget.message.messageDateText),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                width: ScreenUtil().screenWidth,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60.h, bottom: 30.h),
                    child: Container(
                      child: Text(widget.message.messageDateText),
                    ),
                  ),
                ),
              ));
  }
}
