// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatPresentation.dart';

import '../../main.dart';
import '../Routes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static GlobalKey<AnimatedListState> chatListState = GlobalKey();

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with RouteAware {
  @override
  void initState() {
    print("Appeared");
    super.initState();
  }

  @override
  void dispose() {
    print("Disposed");
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    print("Change dependencies!!!!");
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPush() {
    // Route was pushed onto navigator and is now topmost route.
    print("Did Push!");
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    print("Did Pop Next");
    // Dependencies.chatPresentation.setAnyChatOpen = false;
  }

  @override
  void didPushNext() {
    print("Did Push Next");
    Dependencies.chatPresentation.setAnyChatOpen = true;

    super.didPushNext();
  }

  ScrollController controller = new ScrollController();
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
              flex: 2,
              fit: FlexFit.loose,
              child: Container(),
            ),
            if (chatPresentation.chatListState == ChatListState.ready) ...[
              Flexible(
                flex: 10,
                fit: FlexFit.tight,
                child: Container(
                  child: Column(
                    children: [
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Container(
                            child: Text(
                                "Conversaciones:${chatPresentation.chatController.chatList.length}")),
                      ),
                      Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Container(
                          child: AnimatedList(
                              controller: controller,
                              key: ChatScreen.chatListState,
                              initialItemCount: chatPresentation
                                  .chatController.chatList.length,
                              itemBuilder: (BuildContext context, int index,
                                  Animation<double> animation) {
                                return ChatCard(
                                  index: index,
                                  chatData: chatPresentation
                                      .chatController.chatList[index],
                                  animationValue: animation,
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
            if (chatPresentation.chatListState == ChatListState.empty) ...[
              Flexible(
                flex: 10,
                fit: FlexFit.loose,
                child: Container(
                    child: Center(
                  child: Text(
                    "No hay conversaciones",
                    style: GoogleFonts.lato(
                      color: Colors.black,
                    ),
                  ),
                )),
              )
            ],
            if (chatPresentation.chatListState == ChatListState.error) ...[
              Flexible(
                flex: 10,
                fit: FlexFit.loose,
                child: Container(
                    child: Center(
                  child: Column(
                    children: [
                      Text(
                        "Error al cargar coversaciones",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () =>
                              chatPresentation.initializeChatListener(),
                          child: Text("Cargar de nuevo"))
                    ],
                  ),
                )),
              )
            ],
            if (chatPresentation.chatListState == ChatListState.loading) ...[
              Flexible(
                flex: 10,
                fit: FlexFit.loose,
                child: Container(
                    child: Center(
                  child: Column(
                    children: [
                      Container(
                          height: 300.h,
                          width: 300.h,
                          child: LoadingIndicator(
                              indicatorType: Indicator.ballScale)),
                      Text(
                        "Cargando",
                        style: GoogleFonts.lato(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )),
              )
            ]
          ],
        )));
      }),
    );
  }
}

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
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animationValue,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            GoToRoute(
                page: ChatMessagesScreen(
              chatId: widget.chatData.chatId,
              imageHash: widget.chatData.remitentPictureHash,
              imageUrl: widget.chatData.remitenrPicture,
              remitentName: widget.chatData.remitentName,
              messageTokenNotification: widget.chatData.notificationToken,
              remitentId: widget.chatData.remitentId,
            ))),
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
          if (widget.chatData.messagesList.length > 0) ...[
            if (widget.chatData.messagesList.first.messageType ==
                MessageType.TEXT) ...[
              Text(widget.chatData.messagesList.first.data),
            ],
            if (widget.chatData.messagesList.first.messageType !=
                MessageType.TEXT) ...[
              Text("GIF"),
            ]
          ],
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
  String imageUrl;
  String imageHash;
  String remitentName;
  static GlobalKey chatMessageScreenKey = GlobalKey();

  ChatMessagesScreen(
      {required this.chatId,
      required this.remitentId,
      required this.imageUrl,
      required this.imageHash,
      required this.remitentName,
      required this.messageTokenNotification});

  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  int chatLitIndex = 0;
  int lastListLength = 0;
  bool chatdeleted = false;
  ScrollController controller = new ScrollController();
  FocusNode focusNode = new FocusNode();
  TextEditingController textEditingController = new TextEditingController();
  GlobalKey<AnimatedListState> chatMessageScreenState = GlobalKey();

  @override
  void initState() {
    super.initState();
    chatLitIndex = getIndex(chatId: widget.chatId);
    Dependencies.chatPresentation.setMessagesOnSeen(chatId: widget.chatId);
  }

  @override
  void didUpdateWidget(covariant ChatMessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    Dependencies.chatPresentation.setAnyChatOpen = false;
    super.dispose();
  }

  int getIndex({required String chatId}) {
    int index = -1;

    for (int i = 0;
        i < Dependencies.chatPresentation.chatController.chatList.length;
        i++) {
      if (Dependencies.chatPresentation.chatController.chatList[i].chatId ==
          widget.chatId) {
        index = i;
      }
    }

    return index;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.chatPresentation,
      key: ChatMessagesScreen.chatMessageScreenKey,
      child: StreamBuilder(
          stream: Dependencies.chatPresentation.chatDeletedNotification.stream,
          initialData: "",
          builder: (BuildContext context, AsyncSnapshot<String> data) {
            if (data.data == widget.chatId) {
              chatdeleted = true;
            }
            return SafeArea(
                child: chatdeleted == false
                    ? Scaffold(
                        appBar: AppBar(
                            title: Row(
                              children: [
                                Container(
                                    height: 100.w,
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: OctoImage(
                                      fadeInDuration:
                                          Duration(milliseconds: 50),
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(
                                          widget.imageUrl),
                                      placeholderBuilder:
                                          OctoPlaceholder.blurHash(
                                              widget.imageHash,
                                              fit: BoxFit.cover),
                                    )),
                                Container(
                                  width: 400.w,
                                  child: Text(widget.remitentName,)),
                              ],
                            ),
                            centerTitle: true,
                            elevation: 0,
                            actions: [
                              IconButton(
                                  onPressed: () {}, icon: Icon(Icons.menu))
                            ]),
                        resizeToAvoidBottomInset: true,
                        body: StreamBuilder(
                            initialData: "",
                            stream: Dependencies.chatPresentation
                                .updateMessageListNotification.stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<String> data) {
                              if (data.data == widget.chatId) {
                                chatMessageScreenState.currentState
                                    ?.insertItem(0);
                              }
                              return Consumer<ChatPresentation>(builder:
                                  (BuildContext context,
                                      ChatPresentation chatPresentation,
                                      Widget? child) {
                                return LayoutBuilder(
                                    builder: (context, constraints) {
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
                                            child: chatPresentation
                                                        .chatController
                                                        .chatList[chatLitIndex]
                                                        .messagesList
                                                        .length >
                                                    0
                                                ? AnimatedList(
                                                    key: chatMessageScreenState,
                                                    reverse: true,
                                                    controller: controller,
                                                    initialItemCount:
                                                        chatPresentation
                                                            .chatController
                                                            .chatList[
                                                                chatLitIndex]
                                                            .messagesList
                                                            .length,
                                                    itemBuilder: (context,
                                                        index, animation) {
                                                      return TextMessage(
                                                          message: chatPresentation
                                                              .chatController
                                                              .chatList[
                                                                  chatLitIndex]
                                                              .messagesList[index],
                                                          animation: animation);
                                                    })
                                                : Container(),
                                          ),
                                          messageSenderBar(constraints)
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              });
                            }),
                      )
                    : Material(
                        child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Lo sentimos,el remitente ha borrado la conversacion",
                                  style: GoogleFonts.lato(
                                      color: Colors.white, fontSize: 50.sp),
                                ),
                                ElevatedButton(onPressed: ()=>Navigator.pop(context), child: Text("Atras"))
                              ],
                            ),
                          ),
                        ),
                      )));
          }),
    );
  }

  Container messageSenderBar(BoxConstraints constraints) {
    return Container(
      height: kBottomNavigationBarHeight * 1.75,
      width: constraints.biggest.width,
      child: Row(
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: IconButton(
                onPressed: () async {
                  final gif = await GiphyGet.getGif(
                      tabColor: Colors.deepPurple,
                      searchText: "Busca tu GIPHY",
                      context: context,
                      apiKey: "vP5aepaZgPJxh3uVvRjYPcm2cWoFmJpd");
                  if (gif != null) {
                    if (gif.images != null) {
                      if (gif.images?.original != null) {
                        sendMessage(
                            text: gif.images?.original?.url, isGif: true);
                      }
                    }
                  }
                },
                icon: Icon(Icons.emoji_emotions)),
          ),
          Flexible(
            flex: 8,
            fit: FlexFit.tight,
            child: TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              onEditingComplete: () {
                sendMessage(text: textEditingController.text, isGif: false);
              },
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: IconButton(
                onPressed: () {
                  sendMessage(text: textEditingController.text, isGif: false);
                },
                icon: Icon(Icons.send)),
          ),
        ],
      ),
    );
  }

  void sendMessage({required String? text, required bool isGif}) {
    if (text != null) {
      if (text.length > 0) {
        Dependencies.chatPresentation.sendMessage(
            message: new Message(
                read: false,
                isResponse: false,
                data: text,
                chatId: widget.chatId,
                senderId: GlobalDataContainer.userId as String,
                messageId: "",
                messageDate: 0,
                messageType: isGif ? MessageType.GIPHY : MessageType.TEXT),
            messageNotificationToken: widget.messageTokenNotification,
            remitentId: widget.remitentId);

        textEditingController.text = "";
      }
    }
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
