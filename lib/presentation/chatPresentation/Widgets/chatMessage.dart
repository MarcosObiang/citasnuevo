

import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/globalData.dart';

class TextMessage extends StatefulWidget {
  Message message;
  Animation<double> animation;
  TextMessage({required this.message, required this.animation});

  @override
  _TextMessageState createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> {
  @override
  void initState() {
    super.initState();

    if (widget.message.senderId == GlobalDataContainer.userId) {
      paddingData =
          EdgeInsets.only(top: 50.h, bottom: 50.h, left: 100.w, right: 20.w);
      messageColor = userMessagesColor;
    } else {
      paddingData =
          EdgeInsets.only(top: 50.h, bottom: 50.h, right: 100, left: 20.w);
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
          EdgeInsets.only(top: 30.h, bottom: 30.h, left: 100.w, right: 20.w);
      messageColor = userMessagesColor;
    } else {
      paddingData =
          EdgeInsets.only(top: 30.h, bottom: 30.h, right: 100, left: 20.w);
      messageColor = remitentMessagesColor;
    }
    return FadeTransition(
      opacity: widget.animation,
      child: Padding(
        padding: paddingData,
        child: Container(
          decoration: BoxDecoration(
              color: messageColor,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: widget.message.messageType == MessageType.TEXT
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
        ),
      ),
    );
  }
}
