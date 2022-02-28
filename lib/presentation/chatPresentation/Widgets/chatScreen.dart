import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatMessage.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatPresentation.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatProfileDetailScreen.dart';
import 'package:citasnuevo/presentation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../core/globalData.dart';
import '../../../domain/entities/ChatEntity.dart';
import '../../../domain/entities/MessageEntity.dart';

class ChatMessagesScreen extends StatefulWidget {
  String chatId;
  String remitentId;
  String messageTokenNotification;
  String imageUrl;
  String imageHash;
  String remitentName;
  static GlobalKey chatMessageScreenKey = GlobalKey();
  static GlobalKey<AnimatedListState> chatMessageScreenState = GlobalKey();

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

class _ChatMessagesScreenState extends State<ChatMessagesScreen>
    with SingleTickerProviderStateMixin {
  int chatLitIndex = 0;
  int lastListLength = 0;
  bool chatdeleted = false;
  bool showForceScrollDownButton = false;
  late Animation<double> loadMoreMessagesDialogAnimation;
  late AnimationController loadMoreMessagesDialogAnimationController;

  ScrollController controller = new ScrollController();
  FocusNode focusNode = new FocusNode();
  TextEditingController textEditingController = new TextEditingController();

  set setShowForceScrollDownButton(bool newValue) {
    if (newValue != showForceScrollDownButton) {
      showForceScrollDownButton = newValue;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.positions.isNotEmpty) {
        if (controller.position.pixels >
                controller.position.maxScrollExtent * 0.10 &&
            showForceScrollDownButton == false) {
          setShowForceScrollDownButton = true;
        }
        if (controller.position.pixels <
                controller.position.maxScrollExtent * 0.10 &&
            showForceScrollDownButton == true) {
          setShowForceScrollDownButton = false;
        }

        if (controller.position.pixels == controller.position.maxScrollExtent) {
          Dependencies.chatPresentation.loadMoreMessages(
              chatId: widget.chatId,
              lastMessageId: Dependencies.chatPresentation.chatController
                  .chatList[chatLitIndex].messagesList.last.messageId);
        }
      }
    });
    chatLitIndex = getIndex(chatId: widget.chatId);
    Dependencies.chatPresentation.setMessagesOnSeen(chatId: widget.chatId);
    Dependencies.chatPresentation.chatController.chatOpenId = widget.chatId;
    loadMoreMessagesDialogAnimationController = new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        debugLabel: "loadMoreMessagesDialog");

    loadMoreMessagesDialogAnimation = Tween<double>(begin: 0, end: 100.h)
        .animate(loadMoreMessagesDialogAnimationController);
  }

  @override
  void didUpdateWidget(covariant ChatMessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    Dependencies.chatPresentation.setAnyChatOpen = false;
    Dependencies.chatPresentation.chatController.chatOpenId = "";
    loadMoreMessagesDialogAnimationController.dispose();
    super.dispose();
  }

  void forceScrollDown() {
    controller.animateTo(0,
        duration: Duration(milliseconds: 400), curve: Curves.easeInSine);
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

  void showLoadMessageDialog(
      {required AdditionalMessagesLoadState
          additionalMessagesLoadState}) async {
    print(loadMoreMessagesDialogAnimationController.status);

    if (additionalMessagesLoadState == AdditionalMessagesLoadState.LOADING &&
        loadMoreMessagesDialogAnimationController.status ==
            AnimationStatus.dismissed) {
      loadMoreMessagesDialogAnimationController.forward();
    }
    if (additionalMessagesLoadState == AdditionalMessagesLoadState.READY &&
        loadMoreMessagesDialogAnimationController.status ==
            AnimationStatus.completed) {
      await Future.delayed(Duration(milliseconds: 300));
      loadMoreMessagesDialogAnimationController.reverse();
    }
    if (additionalMessagesLoadState == AdditionalMessagesLoadState.ERROR &&
        loadMoreMessagesDialogAnimationController.status ==
            AnimationStatus.completed) {
      await Future.delayed(Duration(milliseconds: 300));
      loadMoreMessagesDialogAnimationController.reverse();
    }
    if (additionalMessagesLoadState ==
            AdditionalMessagesLoadState.NO_MORE_MESSAGES &&
        loadMoreMessagesDialogAnimationController.status ==
            AnimationStatus.completed) {
      await Future.delayed(Duration(milliseconds: 300));
      loadMoreMessagesDialogAnimationController.reverse();
    }
  }

  void showChatOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Center(
            child: ListView(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        GoToRoute(
                            page: ChatProfileDetailsScreen(
                                remitentId: widget.remitentId)));
                  },
                  leading: Icon(Icons.person),
                  title: Text("Ver perfil de ${widget.remitentName}"),
                  subtitle: Text("Pulsa para ver el perfil"),
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Eliminar conversacion"),
                  subtitle: Text("Pulsa para eliminar la conversacion"),
                ),
                ListTile(
                  leading: Icon(Icons.block),
                  title: Text("Eliminar y bloquear"),
                  subtitle: Text(
                      "Elimina la conversacion y bloquea a ${widget.remitentName}"),
                ),
                ListTile(
                  leading: Icon(Icons.report),
                  title: Text("Denuciar a ${widget.remitentName}"),
                  subtitle:
                      Text("Pulsa para denunciar a ${widget.remitentName}"),
                )
              ],
            ),
          );
        });
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
                        appBar: chatScreenAppBAr(),
                        resizeToAvoidBottomInset: true,
                        body: StreamBuilder(
                            initialData: "",
                            stream: Dependencies.chatPresentation
                                .updateMessageListNotification.stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<String> data) {
                              if (data.data == widget.chatId) {
                                ChatMessagesScreen
                                    .chatMessageScreenState.currentState
                                    ?.insertItem(0);
                              }
                              return Consumer<ChatPresentation>(builder:
                                  (BuildContext context,
                                      ChatPresentation chatPresentation,
                                      Widget? child) {
                                showLoadMessageDialog(
                                    additionalMessagesLoadState:
                                        chatPresentation
                                            .chatController
                                            .chatList[chatLitIndex]
                                            .additionalMessagesLoadState);
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
                                                (kBottomNavigationBarHeight *
                                                    1.75),
                                            width: constraints.biggest.width,
                                            child:
                                                chatPresentation
                                                            .chatController
                                                            .chatList[
                                                                chatLitIndex]
                                                            .messagesList
                                                            .length >
                                                        0
                                                    ? Stack(
                                                        children: [
                                                          AnimatedList(
                                                              key: ChatMessagesScreen
                                                                  .chatMessageScreenState,
                                                              reverse: true,
                                                              controller:
                                                                  controller,
                                                              initialItemCount:
                                                                  chatPresentation
                                                                      .chatController
                                                                      .chatList[
                                                                          chatLitIndex]
                                                                      .messagesList
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index,
                                                                      animation) {
                                                                return TextMessage(
                                                                    message: chatPresentation
                                                                        .chatController
                                                                        .chatList[
                                                                            chatLitIndex]
                                                                        .messagesList[index],
                                                                    animation: animation);
                                                              }),
                                                          Align(
                                                            alignment: Alignment
                                                                .topCenter,
                                                            child: NotificationListener<
                                                                ScrollUpdateNotification>(
                                                              onNotification:
                                                                  (value) {
                                                                print("object");
                                                                return true;
                                                              },
                                                              child:
                                                                  AnimatedBuilder(
                                                                      animation:
                                                                          loadMoreMessagesDialogAnimation,
                                                                      builder:
                                                                          (context,
                                                                              child) {
                                                                        return Container(
                                                                          width: constraints
                                                                              .biggest
                                                                              .width,
                                                                          height:
                                                                              loadMoreMessagesDialogAnimation.value,
                                                                          color: Color.fromARGB(
                                                                              115,
                                                                              244,
                                                                              67,
                                                                              54),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(chatPresentation.chatController.chatList[chatLitIndex].additionalMessagesLoadState.name),
                                                                          ),
                                                                        );
                                                                      }),
                                                            ),
                                                          ),
                                                          showForceScrollDownButton
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          30),
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomRight,
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap: () =>
                                                                          forceScrollDown(),
                                                                      child: Container(
                                                                          child: Center(
                                                                            child:
                                                                                Icon(Icons.arrow_downward),
                                                                          ),
                                                                          height: 150.w,
                                                                          width: 150.w,
                                                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(97, 233, 30, 98))),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container()
                                                        ],
                                                      )
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
                                ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Atras"))
                              ],
                            ),
                          ),
                        ),
                      )));
          }),
    );
  }

  AppBar chatScreenAppBAr() {
    return AppBar(
        title: Row(
          children: [
            Container(
                height: 100.w,
                width: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: OctoImage(
                  fadeInDuration: Duration(milliseconds: 50),
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(widget.imageUrl),
                  placeholderBuilder: OctoPlaceholder.blurHash(widget.imageHash,
                      fit: BoxFit.cover),
                )),
            Container(
                width: 400.w,
                child: Text(
                  widget.remitentName,
                )),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                showChatOptions(context);
              },
              icon: Icon(Icons.menu))
        ]);
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
