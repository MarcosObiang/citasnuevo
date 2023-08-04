import 'dart:typed_data';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../Utils/getImageFile.dart';
import '../../../../Utils/routes.dart';
import '../../ChatEntity.dart';
import '../../MessageEntity.dart';
import 'chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ChatCard extends StatefulWidget {
  ChatCard(
      {required this.chatData,
      required this.animationValue,
      required this.index});

  Animation<double> animationValue;
  Chat chatData;
  int index;

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  bool? wasBlindChat;

  Color defaultColor = Colors.white;
  Color defaultTextColor = Colors.black;
  late Future<Uint8List> remitentImageData;
  Color unreadMessagesColor = Colors.deepPurpleAccent;
  Color unreadMessagesTextColor = Colors.white;

  @override
  void initState() {
    wasBlindChat = widget.chatData.isBlindDate;

    if (widget.chatData.isBlindDate == false) {
      remitentImageData =
          ImageFile.getFile(fileId: widget.chatData.remitentPicture);
    }

    super.initState();
  }

  void checkIfBlindCChatHadBeenRevealed(Chat chatData) {
    if (chatData.isBlindDate == false && wasBlindChat == true) {
      remitentImageData = ImageFile.getFile(fileId: chatData.remitentPicture);
      wasBlindChat = false;
    }
  }

  Widget build(BuildContext context) {
    checkIfBlindCChatHadBeenRevealed(widget.chatData);
    return FadeTransition(
      opacity: widget.animationValue,
      child: GestureDetector(
        onTap: () {
          if (widget.chatData.isBeingDeleted == false &&
              widget.chatData.userBlocked == false) {
            Navigator.push(
                context,
                GoToRoute(
                    page: ChatMessagesScreen(
                  chatId: widget.chatData.chatId,
                  remitentId: widget.chatData.remitentId,
                )));
          }
        },
        child: Card(
          color: widget.chatData.unreadMessages > 0
              ? unreadMessagesColor
              : defaultColor,
          child: Stack(
            children: [
              Container(
                  height: 200.h,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          chatCardImage(),
                          chatLastMessageShower(),
                          unreadMessagesCounter(),
                        ],
                      ))),
              widget.chatData.userBlocked == true
                  ? Container(
                      height: 200.h,
                      color: Colors.black,
                      child: Row(
                        children: [
                          Text(
                            "Usuario bloqueado",
                            style: GoogleFonts.lato(color: Colors.white),
                          ),
                          ElevatedButton(
                              onPressed: () {}, child: Text("Eliminar"))
                        ],
                      ),
                    )
                  : Container(),
              widget.chatData.isBeingDeleted == true
                  ? Container(
                      height: 200.h,
                      color: Colors.black,
                      child: Row(
                        children: [
                          Text(
                            "Eliminando conversacion",
                            style: GoogleFonts.lato(color: Colors.white),
                          ),
                          LoadingIndicator(indicatorType: Indicator.ballBeat)
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Flexible unreadMessagesCounter() {
    return Flexible(
      flex: 3,
      fit: FlexFit.tight,
      child: Container(
          child: Text(
        widget.chatData.unreadMessages.toString(),
        style: GoogleFonts.lato(
            color: widget.chatData.unreadMessages > 0
                ? unreadMessagesTextColor
                : defaultTextColor),
      )),
    );
  }

  Flexible chatLastMessageShower() {
    return Flexible(
      flex: 9,
      fit: FlexFit.tight,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints boxConstraints) {
        return Container(
          width: boxConstraints.maxWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              widget.chatData.isBlindDate == false
                  ? Text(widget.chatData.remitentName)
                  : Text("Secreto"),
              if (widget.chatData.messagesList.first.messageType ==
                  MessageType.TEXT) ...[
                Container(
                  width: boxConstraints.maxWidth,
                  child: Text(widget.chatData.messagesList.first.data,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                          color: widget.chatData.unreadMessages > 0
                              ? unreadMessagesTextColor
                              : defaultTextColor)),
                ),
              ],
              if (widget.chatData.messagesList.first.messageType !=
                  MessageType.TEXT) ...[
                Text("GIF",
                    style: GoogleFonts.lato(
                        color: widget.chatData.unreadMessages > 0
                            ? unreadMessagesTextColor
                            : defaultTextColor)),
              ]
            ],
          ),
        );
      }),
    );
  }

  Flexible chatCardImage() {
    return Flexible(
      flex: 3,
      fit: FlexFit.tight,
      child: widget.chatData.isBlindDate == false
          ? FutureBuilder(
              future: remitentImageData,
              builder:
                  (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                return Container(
                    child: snapshot.hasData
                        ? Image.memory(
                            snapshot.data!,
                          )
                        : Center(
                            child: Container(
                                height: 200.h,
                                width: 200.h,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.orbit)),
                          ));
              })
          : Icon(
              LineAwesomeIcons.mask,
              size: 100.sp,
            ),
    );
  }
}
