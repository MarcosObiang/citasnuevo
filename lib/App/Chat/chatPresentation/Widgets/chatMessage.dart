import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/Utils/routes.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:citasnuevo/Utils/getImageFile.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';

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
      if (widget.message.fileData == null) {
        messageColor = remitentMessagesColor;
      }
    }
    widget.message.initMessage();
  }

  late EdgeInsetsGeometry paddingData;
  Color userMessagesColor = Color.fromARGB(255, 141, 141, 141);
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
                              : widget.message.messageType == MessageType.IMAGE
                                  ? imageMessage()
                                  : gifMessage()),
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
                                  indicatorType: Indicator.ballSpinFadeLoader,
                                  colors: [Colors.black],
                                ),
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

  Widget gifMessage() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            GoToRoute(
                page: PictureViewer(
              fileData: Uint8List.fromList([]),
              gifUrl: widget.message.data,
            )));
      },
      child: Container(
        height: 700.w,
        width: 700.w,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                scale: 1,
                image: CachedNetworkImageProvider(
                  widget.message.data,
                ))),
      ),
    );
  }

  FutureBuilder<Uint8List?> imageMessage() {
    return FutureBuilder(
        future: widget.message.remitentFile,
        initialData: widget.message.fileData,
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.data != null) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    GoToRoute(
                        page: PictureViewer(
                      fileData: snapshot.data!,
                      gifUrl: kNotAvailable,
                    )));
              },
              child: Container(
                  height: 700.w,
                  width: 700.w,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          scale: 1,
                          image: MemoryImage(
                            snapshot.data!,
                          )))),
            );
          } else {
            return Container(
              height: 700.w,
              width: 700.w,
              child: RepaintBoundary(
                child: Center(
                  child: LoadingIndicator(
                      indicatorType: Indicator.ballSpinFadeLoader),
                ),
              ),
            );
          }
        });
  }
}

class PictureViewer extends StatelessWidget {
  Uint8List fileData;
  String gifUrl;
  PictureViewer({
    required this.fileData,
    required this.gifUrl,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Column(
        children: [
          AppBar(
            title: Text("Ver Imagen"),
          ),
          Expanded(
            child: Container(
              child: fileData.isEmpty
                  ? InteractiveViewer(
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                scale: 1,
                                image: CachedNetworkImageProvider(
                                  gifUrl,
                                ))),
                      ),
                    )
                  : InteractiveViewer(
                      child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.contain,
                                  scale: 1,
                                  image: MemoryImage(
                                    fileData,
                                  )))),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
