import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../../../../core/globalData.dart';
import '../../MessageEntity.dart';

// ignore: must_be_immutable
class TextMessage extends StatefulWidget {
  Message message;
  Animation<double> animation;
  VoidCallback sendMessageAgain;
  VoidCallback deleteMessage;

  TextMessage(
      {required this.message,
      required this.animation,
      required this.sendMessageAgain,
      required this.deleteMessage});

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
                    widget.message.messageSendingState ==
                            MessageSendingState.SENT
                        ? Padding(
                            padding: EdgeInsets.all(10.h),
                            child: widget.message.read &&
                                    widget.message.senderId ==
                                        GlobalDataContainer.userId
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(LineAwesomeIcons.check),
                                      Container(
                                        child: Text(
                                            widget.message.messageDateText),
                                      ),
                                    ],
                                  )
                                : Container(
                                    child: Text(widget.message.messageDateText),
                                  ))
                        : widget.message.messageSendingState ==
                                MessageSendingState.ERROR
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("No se pudo enviar"),
                                      TextButton.icon(
                                          onPressed: () {
                                            widget.sendMessageAgain.call();
                                          },
                                          icon: Icon(Icons.refresh),
                                          label: Text("Intentar de nuevo")),
                                      TextButton.icon(
                                          onPressed: () {
                                            widget.deleteMessage.call();
                                          },
                                          icon: Icon(Icons.delete),
                                          label: Text("Borrar mensaje"))
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                width: 100.w,
                                height: 100.w,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.ballRotate),
                              )
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
