// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatPresentation.dart';

import '../Routes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static GlobalKey<AnimatedListState> chatListState = GlobalKey();

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.chatPresentation,
      child: Consumer<ChatPresentation>(builder: (BuildContext context,
          ChatPresentation chatPresentation, Widget? child) {
        return Material(
            child: SafeArea(
                child: Column(
          children: [
            Flexible(
              flex: 3,
              fit: FlexFit.loose,
              child: Container(),
            ),
            Flexible(
              flex: 10,
              fit: FlexFit.loose,
              child: Container(
                child: AnimatedList(
                    key: ChatScreen.chatListState,
                    initialItemCount:
                        chatPresentation.chatController.chatList.length,
                    itemBuilder: (BuildContext context, int index,
                        Animation<double> animation) {
                      return ChatCard(
                        chatData:
                            chatPresentation.chatController.chatList[index],
                        animationValue: animation,
                      );
                    }),
              ),
            )
          ],
        )));
      }),
    );
  }
}

class ChatCard extends StatefulWidget {
  Chat chatData;
  Animation<double> animationValue;
  ChatCard({required this.chatData, required this.animationValue});

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animationValue,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            GoToRoute(
                page: ChatMessagesScreen(chatId: widget.chatData.chatId,messageTokenNotification: widget.chatData.notificationToken,remitentId: widget.chatData.remitentId,))),
        child: Card(
            child: Container(
                height: 200.h,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      chatCardImage(),
                      chatLastMessageShower(),
                      unreadMessagesCounter(),
                    ],
                  ),
                ))),
      ),
    );
  }

  Flexible unreadMessagesCounter() {
    return Flexible(
      flex: 3,
      fit: FlexFit.tight,
      child: Container(child: Text(widget.chatData.unreadMessages.toString())),
    );
  }

  Flexible chatLastMessageShower() {
    return Flexible(
      flex: 9,
      fit: FlexFit.tight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.chatData.remitentName),
          if (widget.chatData.messagesList.last.messageType ==
              MessageType.TEXT) ...[
            Text(widget.chatData.messagesList.first.data),
          ],
          if (widget.chatData.messagesList.last.messageType !=
              MessageType.TEXT) ...[
            Text("widget.chatData.messagesList.last.data"),
          ]
        ],
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

class ChatMessagesScreen extends StatefulWidget {
  String chatId;
  String remitentId;
  String messageTokenNotification;
  ChatMessagesScreen(
      {required this.chatId,
      required this.remitentId,
      required this.messageTokenNotification});

  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  int lastListLength = 0;
  ScrollController controller = new ScrollController();
  GlobalKey<AnimatedListState> chatMessageScreenState = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.chatPresentation,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(),
          resizeToAvoidBottomInset: true,
          body: Consumer<ChatPresentation>(builder: (BuildContext context,
              ChatPresentation chatPresentation, Widget? child) {
            return LayoutBuilder(builder: (context, constraints) {
              return Container(
                height: constraints.biggest.height,
                width: constraints.biggest.width,
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  reverse: true,
                  child: Column(
                    children: [
                      Container(
                        height: constraints.biggest.height -
                            kBottomNavigationBarHeight,
                        width: constraints.biggest.width,
                        child: AnimatedList(
                            reverse: true,
                            controller: controller,
                            initialItemCount: chatPresentation.chatController
                                .chatList.first.messagesList.length,
                            itemBuilder: (context, index, animation) {
                              return TextMessage(
                                  message: chatPresentation.chatController
                                      .chatList.first.messagesList[index],
                                  animation: animation);
                            }),
                      ),
                      Container(
                        height: kBottomNavigationBarHeight * 1.75,
                        width: constraints.biggest.width,
                        child: Row(
                          children: [
                            Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.emoji_emotions)),
                            ),
                            Flexible(
                              flex: 8,
                              fit: FlexFit.tight,
                              child: TextField(),
                            ),
                            Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: IconButton(
                                  onPressed: () {
                                    Dependencies.chatPresentation.sendMessage(
                                        message: new Message(
                                            read: false,
                                            isResponse: false,
                                            data: "dataData",
                                            chatId: widget.chatId,
                                            senderId: GlobalDataContainer.userId
                                                as String,
                                            messageId: "",
                                            messageDate: 0,
                                            messageType: MessageType.TEXT),
                                        messageNotificationToken:
                                            widget.messageTokenNotification,
                                        remitentId: widget.remitentId);
                                  },
                                  icon: Icon(Icons.send)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
          }),
        ),
      ),
    );
  }
}

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
          EdgeInsets.only(top: 30.h, bottom: 30.h, left: 100.w, right: 20.w);
      messageColor = userMessagesColor;
    } else {
      paddingData =
          EdgeInsets.only(top: 30.h, bottom: 30.h, right: 100, left: 20.w);
      messageColor = remitentMessagesColor;
    }
  }

  late EdgeInsetsGeometry paddingData;
  Color userMessagesColor = Color.fromARGB(255, 4, 10, 40);
  Color remitentMessagesColor = Color.fromARGB(176, 161, 107, 242);
  late Color messageColor;

  @override
  Widget build(BuildContext context) {
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
            child: Text(
                "fjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjabra cadabra diente de cabrriidhsugfsdjg"),
          ),
        ),
      ),
    );
  }
}
