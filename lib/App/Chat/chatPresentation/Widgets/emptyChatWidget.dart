import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';

import '../../../../Utils/getImageFile.dart';
import '../../../../Utils/routes.dart';
import '../../ChatEntity.dart';
import 'chatScreen.dart';

class EmptyChatWidget extends StatefulWidget {
  final Chat chat;
  final Animation<double> animation;
  final int index;

  EmptyChatWidget(
      {required this.chat, required this.animation, required this.index});

  @override
  _EmptyChatWidgetState createState() => _EmptyChatWidgetState();
}

class _EmptyChatWidgetState extends State<EmptyChatWidget> {
  late Future<Uint8List> remitentImageData;
  @override
  void initState() {
    if (widget.chat.isBlindDate == false) {
      remitentImageData =
          ImageFile.getFile(fileId: widget.chat.remitentPicture);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animation,
      child: GestureDetector(
        onTap: () {
          if (widget.chat.userBlocked == false &&
              widget.chat.isBeingDeleted == false) {
            Navigator.push(
                context,
                GoToRoute(
                    page: ChatMessagesScreen(
                  chatId: widget.chat.chatId,
                  remitentId: widget.chat.remitentId,
                )));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              widget.chat.isBlindDate == false
                  ? FutureBuilder(
                      future: remitentImageData,
                      builder: (BuildContext context,
                          AsyncSnapshot<Uint8List> snapshot) {
                        return snapshot.hasData
                            ? CircleAvatar(
                                radius: 100.h,
                                foregroundImage: MemoryImage(snapshot.data!),
                              )
                            : Container(
                                height: 200.h,
                                width: 200.h,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.orbit));
                      })
                  : CircleAvatar(
                      radius: 100.h,
                      child: Icon(
                        LineAwesomeIcons.mask,
                        size: 100.sp,
                      ),
                    ),
              widget.chat.userBlocked
                  ? Container(
                      width: 400.w,
                      color: Colors.black,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                          Text(
                            "Usuario bloqueado",
                            style: GoogleFonts.lato(
                                color: Colors.white, fontSize: 50.sp),
                            textAlign: TextAlign.center,
                          ),
                          ElevatedButton(
                              onPressed: () {}, child: Text("Eliminar"))
                        ],
                      )),
                    )
                  : Container(),
              widget.chat.isBeingDeleted == true
                  ? Container(
                      width: 400.w,
                      color: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.orbit)),
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: Text(
                                "Eliminando",
                                style: GoogleFonts.lato(
                                    color: Colors.white, fontSize: 50.sp),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
