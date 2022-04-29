import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/presentation/Routes.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';

class ChatCard extends StatefulWidget {
  Chat chatData;
  Animation<double> animationValue;
  int index;
  ChatCard(
      {required this.chatData,
      required this.animationValue,
      required this.index});

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  Color defaultColor = Colors.white;
  Color unreadMessagesColor = Colors.deepPurpleAccent;
  Color defaultTextColor = Colors.black;
  Color unreadMessagesTextColor = Colors.white;

  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animationValue,
      child: GestureDetector(
        onTap: () {
          if (widget.chatData.isBeingDeleted == false) {
            Navigator.push(
                context,
                GoToRoute(
                    page: ChatMessagesScreen(
                  chatId: widget.chatData.chatId,
                  imageHash: widget.chatData.remitentPictureHash,
                  imageUrl: widget.chatData.remitenrPicture,
                  remitentName: widget.chatData.remitentName,
                  messageTokenNotification: widget.chatData.notificationToken,
                  remitentId: widget.chatData.remitentId,
                )));
          }
        },
        child: Card(
            color: widget.chatData.unreadMessages > 0
                ? unreadMessagesColor
                : defaultColor,
            child: widget.chatData.isBeingDeleted == false
                ? Container(
                    height: 200.h,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            chatCardImage(),
                            chatLastMessageShower(),
                            unreadMessagesCounter(),
                          ],
                        )))
                : Container(
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
                  )),
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
        builder: (BuildContext context,BoxConstraints boxConstraints) {
          return Container(
            width: boxConstraints.maxWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(widget.chatData.remitentName),
                if (widget.chatData.messagesList.length > 0) ...[
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
              ],
            ),
          );
        }
      ),
    );
  }

  Flexible chatCardImage() {
    return Flexible(
      flex: 3,
      fit: FlexFit.tight,
      child: Container(
        child: OctoImage(
          fadeInDuration: Duration(milliseconds: 50),
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(widget.chatData.remitenrPicture),
          placeholderBuilder: OctoPlaceholder.blurHash(
              widget.chatData.remitentPictureHash,
              fit: BoxFit.cover),
        ),
      ),
    );
  }
}