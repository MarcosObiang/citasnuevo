import 'dart:typed_data';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../Utils/getImageFile.dart';
import '../../../../Utils/routes.dart';
import '../../ChatEntity.dart';
import '../../MessageEntity.dart';
import 'chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

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
        child: Container(
          height: 200.h,
          child: Card(
            semanticContainer: true,
            elevation: widget.chatData.unreadMessages > 0 ? 2 : 0,
            color: widget.chatData.unreadMessages > 0
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            child: Stack(
              children: [
                Container(
                    height: 250.h,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            chatCardImage(),
                            chatLastMessageShower(),
                            unreadMessagesCounter(),
                          ],
                        ))),
                widget.chatData.userBlocked == true
                    ? Container(
                        height: 250.h,
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lock,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.chat_screen_blocked_user_title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onErrorContainer),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    if (widget.chatData.isBeingDeleted ==
                                            false &&
                                        widget.chatData.userBlocked == true) {
                                      Navigator.push(
                                          context,
                                          GoToRoute(
                                              page: ChatMessagesScreen(
                                            chatId: widget.chatData.chatId,
                                            remitentId:
                                                widget.chatData.remitentId,
                                          )));
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)!.details))
                            ],
                          ),
                        ),
                      )
                    : Container(),
                widget.chatData.isBeingDeleted == true
                    ? Container(
                        height: 200.h,
                        color: Theme.of(context).colorScheme.tertiary,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.chat_delete_chat_button,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary),
                                  ),
                                ],
                              ),
                              Container(
                                height: 100.h,
                                width: 100.h,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.circleStrokeSpin,
                                    colors: [
                                      Theme.of(context).colorScheme.onTertiary
                                    ]),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Flexible unreadMessagesCounter() {
    return Flexible(
      flex: 2,
      fit: FlexFit.tight,
      child: Center(
        child: Container(
            child: widget.chatData.unreadMessages > 0
                ? Row(
                    children: [
                      Text(
                        widget.chatData.unreadMessages.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.apply(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeightDelta: 1),
                      ),
                      Icon(
                        Icons.message,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 50.sp,
                      )
                    ],
                  )
                : Container()),
      ),
    );
  }

  Flexible chatLastMessageShower() {
    return Flexible(
      flex: 9,
      fit: FlexFit.loose,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints boxConstraints) {
        return Container(
          width: boxConstraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              widget.chatData.isBlindDate == false
                  ? Container(
                      child: Text(
                        widget.chatData.remitentName,
                        overflow: TextOverflow.ellipsis,
                        style: widget.chatData.unreadMessages > 0
                            ? Theme.of(context).textTheme.titleMedium?.apply(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeightDelta: 1)
                            : Theme.of(context).textTheme.titleMedium?.apply(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontWeightDelta: 1),
                        textAlign: TextAlign.left,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.chat_anonymous_chat,
                      style: widget.chatData.unreadMessages > 0
                          ? Theme.of(context).textTheme.titleMedium?.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeightDelta: 1)
                          : Theme.of(context).textTheme.titleMedium?.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeightDelta: 1),
                      textAlign: TextAlign.left,
                    ),
              widget.chatData.messagesList.isNotEmpty == true
                  ? widget.chatData.messagesList.first.messageType ==
                          MessageType.TEXT
                      ? Container(
                          width: boxConstraints.maxWidth,
                          child: Text(
                            widget.chatData.messagesList.first.data,
                            overflow: TextOverflow.ellipsis,
                            style: widget.chatData.unreadMessages > 0
                                ? Theme.of(context).textTheme.bodyMedium?.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    )
                                : Theme.of(context).textTheme.bodyMedium?.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                            textAlign: TextAlign.left,
                          ))
                      : Text(
                          AppLocalizations.of(context)!.chat_GIF,
                          style: widget.chatData.unreadMessages > 0
                              ? Theme.of(context).textTheme.bodyMedium?.apply(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )
                              : Theme.of(context).textTheme.bodyMedium?.apply(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        )
                  : Text(
                      AppLocalizations.of(context)!.chat_starter_message,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.apply(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
            ],
          ),
        );
      }),
    );
  }

  Flexible chatCardImage() {
    return Flexible(
      flex: 5,
      fit: FlexFit.loose,
      child: widget.chatData.isBlindDate == false
          ? FutureBuilder(
              future: remitentImageData,
              builder:
                  (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                return LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints boxConstraints) {
                  return Container(
                    height: boxConstraints.maxHeight,
                    width: boxConstraints.maxHeight,
                    child: ClipOval(
                      child: Container(
                          child: snapshot.hasData
                              ? Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Container(
                                      height: 200.h,
                                      width: 200.h,
                                      child: LoadingIndicator(
                                          indicatorType: Indicator.orbit)),
                                )),
                    ),
                  );
                });
              })
          : Icon(
              LineAwesomeIcons.mask,
              size: 100.sp,
            ),
    );
  }
}
