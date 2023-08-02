// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../Utils/getImageFile.dart';
import '../../../../Utils/routes.dart';
import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../../core/globalData.dart';
import '../../MessageEntity.dart';
import '../chatPresentation.dart';
import 'chatMessage.dart';
import 'chatProfileDetailScreen.dart';
import 'chatReportScreen.dart';

// ignore: must_be_immutable
class ChatMessagesScreen extends StatefulWidget {
  String chatId;
  String remitentId;
  static GlobalKey messageScreenKey = GlobalKey();
  static GlobalKey<AnimatedListState> messageListState = GlobalKey();

  ChatMessagesScreen({
    required this.chatId,
    required this.remitentId,
  });

  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int chatLitIndex = 0;
  int lastListLength = 0;
  bool chatdeleted = false;
  bool showForceScrollDownButton = false;
  late String lastMessageId;
  late Future<Uint8List> remitentImageData;
  AppLifecycleState appState = AppLifecycleState.resumed;
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
    Dependencies.chatPresentation.setAnyChatOpen = true;

    lastMessageId = kNotAvailable;
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

        if (controller.position.pixels ==
            controller.position.maxScrollExtent) {}
      }
    });
    chatLitIndex = getIndex(chatId: widget.chatId);
    remitentImageData = ImageFile.getFile(
        fileId:
            Dependencies.chatController.chatList[chatLitIndex].remitentPicture);

    Dependencies.chatPresentation.setMessagesOnSeen(chatId: widget.chatId);
    Dependencies.chatPresentation.setCurrentOpenChat = widget.chatId;
  }

  @override
  void didUpdateWidget(covariant ChatMessagesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    lastMessageId = kNotAvailable;

    Dependencies.chatPresentation.setAnyChatOpen = false;
    Dependencies.chatPresentation.setCurrentOpenChat = kNotAvailable;

    super.dispose();
  }

  void forceScrollDown() {
    controller.animateTo(0,
        duration: Duration(milliseconds: 400), curve: Curves.easeInSine);
  }

  /// Searches for the rigth chat to open in the chatList
  ///
  /// When the user opens a chat, before anything is painted,
  /// we need to know the index of the chat we want to access

  int getIndex({required String chatId}) {
    int index = -1;

    for (int i = 0;
        i < Dependencies.chatPresentation.chatListCache.length;
        i++) {
      if (Dependencies.chatPresentation.chatListCache[i].chatId ==
          widget.chatId) {
        index = i;
      }
    }

    return index;
  }

  void showChatOptions(
      BuildContext context, ChatPresentation chatPresentation) {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        context: context,
        builder: (context) {
          return Center(
            child: ListView(
              children: [
                chatPresentation.chatController.chatList[chatLitIndex]
                            .isBlindDate ==
                        false
                    ? ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              GoToRoute(
                                  page: ChatProfileDetailsScreen(
                                      chatId: widget.chatId,
                                      remitentId: widget.remitentId)));
                        },
                        leading: Icon(Icons.person),
                        title: Text("Ver perfil"),
                        subtitle: Text("Pulsa para ver el perfil"),
                      )
                    : Container(),
                ListTile(
                    leading: Icon(Icons.delete),
                    title: Text("Eliminar conversacion"),
                    subtitle: Text("Pulsa para eliminar la conversacion"),
                    onTap: () {
                      Navigator.pop(context);
                      showDeleteChatDialog();
                    }),
                chatPresentation.chatController.chatList[chatLitIndex]
                            .isBlindDate ==
                        false
                    ? ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              GoToRoute(
                                  page: ReportChatScreen(
                                chatId: widget.chatId,
                                remitent: widget.remitentId,
                              )));
                        },
                        leading: Icon(Icons.report),
                        title: Text(
                            "Eliminar y denuciar a ${chatPresentation.chatListCache[chatLitIndex].remitentName}"),
                        subtitle: Text(
                            "Pulsa para denunciar a ${chatPresentation.chatListCache[chatLitIndex].remitentName}"),
                      )
                    : ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              GoToRoute(
                                  page: ReportChatScreen(
                                chatId: widget.chatId,
                                remitent: widget.remitentId,
                              )));
                        },
                        leading: Icon(Icons.report),
                        title: Text("Eliminar y denuciar perfil"),
                        subtitle: Text(
                            "Pulsa para denunciar a este perfil y eliminar la conversacion"),
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
        key: ChatMessagesScreen.messageScreenKey,
        child: Consumer<ChatPresentation>(builder: (BuildContext context,
            ChatPresentation chatPresentation, Widget? child) {
          return Stack(
            children: [
              Scaffold(
                  appBar: chatScreenAppBar(chatPresentation),
                  resizeToAvoidBottomInset: true,
                  body: SafeArea(
                    child: LayoutBuilder(builder: (context, constraints) {
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
                                      (kBottomNavigationBarHeight * 1.75),
                                  width: constraints.biggest.width,
                                  child: Stack(
                                    children: [
                                      messageList(
                                          chatPresentation: chatPresentation),
                                      RepaintBoundary(
                                        child: showForceScrollDownButton
                                            ? forceScrollDownButton()
                                            : Container(),
                                      )
                                    ],
                                  )),
                              chatPresentation.chatController
                                          .chatList[chatLitIndex].isBlindDate ==
                                      true
                                  ? revealRemitentButtonContainer(
                                      constraints, chatPresentation)
                                  : Container(),
                              messageSenderBar(constraints, chatPresentation)
                            ],
                          ),
                        ),
                      );
                    }),
                  )),
              chatPresentation
                          .chatController.chatList[chatLitIndex].userBlocked ==
                      true
                  ? userBlockedDialog(context)
                  : Container(),
              chatPresentation.chatListCache[chatLitIndex].isBeingDeleted ==
                      true
                  ? chatDeletedDialog(context)
                  : Container()
            ],
          );
        }));
  }

  Material chatDeletedDialog(BuildContext context) {
    return Material(
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
                style: GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
              ),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context), child: Text("Atras"))
            ],
          ),
        ),
      ),
    ));
  }

  Material userBlockedDialog(BuildContext context) {
    return Material(
        child: Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "El usuario ha sido bloqueado por infringir las normas de la comunidad",
                style: GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
              ),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Atras")),
              ElevatedButton(
                  onPressed: () {
                    showDeleteChatDialog();
                  },
                  child: Text("Eliminar conversacion"))
            ],
          ),
        ),
      ),
    ));
  }

  Padding forceScrollDownButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Align(
        alignment: Alignment.bottomRight,
        child: GestureDetector(
          onTap: () => forceScrollDown(),
          child: Container(
              child: Center(
                child: Icon(Icons.arrow_downward),
              ),
              height: 150.w,
              width: 150.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(97, 233, 30, 98))),
        ),
      ),
    );
  }

  Widget messageList({required ChatPresentation chatPresentation}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scrollbar(
        thumbVisibility: true,
        controller: controller,
        child: AnimatedList(
            physics: BouncingScrollPhysics(),
            key: ChatMessagesScreen.messageListState,
            reverse: true,
            controller: controller,
            initialItemCount: chatPresentation
                .chatController.chatList[chatLitIndex].messagesList.length,
            itemBuilder: (context, index, animation) {
              return TextMessage(
                  deleteMessage: () =>
                      chatPresentation.removeMessageFromChatList(
                          chatId: chatPresentation
                              .chatController.chatList[chatLitIndex].chatId,
                          messageId: chatPresentation
                              .chatController
                              .chatList[chatLitIndex]
                              .messagesList[index]
                              .messageId),
                  sendMessageAgain: () => chatPresentation.sendMessage(
                      message: chatPresentation.chatController
                          .chatList[chatLitIndex].messagesList[index],
                      messageNotificationToken: chatPresentation.chatController
                          .chatList[chatLitIndex].notificationToken,
                      remitentId: chatPresentation
                          .chatController.chatList[chatLitIndex].remitentId,
                      retryMessageSending: true),
                  message: chatPresentation.chatController
                      .chatList[chatLitIndex].messagesList[index],
                  animation: animation);
            }),
      ),
    );
  }

  AppBar chatScreenAppBar(ChatPresentation chatPresentation) {
    return AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  GoToRoute(
                      page: ChatProfileDetailsScreen(
                          chatId: widget.chatId,
                          remitentId: widget.remitentId))),
              child: Container(
                height: 100.w,
                width: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: chatPresentation.chatController.chatList[chatLitIndex]
                            .isBlindDate ==
                        false
                    ? FutureBuilder(
                        future: remitentImageData,
                        builder: (BuildContext context,
                            AsyncSnapshot<Uint8List> snapshot) {
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
                    : Icon(LineAwesomeIcons.mask),
              ),
            ),
            Container(
                width: 400.w,
                child: chatPresentation.chatController.chatList[chatLitIndex]
                            .isBlindDate ==
                        false
                    ? Text(
                        chatPresentation
                            .chatController.chatList[chatLitIndex].remitentName,
                      )
                    : Row(
                        children: [
                          Text(
                            "Secreto",
                          ),
                          Icon(LineAwesomeIcons.lock)
                        ],
                      )),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                showChatOptions(context, chatPresentation);
              },
              icon: Icon(Icons.menu))
        ]);
  }

  Widget revealRemitentButtonContainer(
      BoxConstraints constraints, ChatPresentation presentation) {
    return Container(
      height: kBottomNavigationBarHeight * 1,
      child: ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(LineAwesomeIcons.unlock),
          label: Text("Revelar perfil")),
    );
  }

  Container messageSenderBar(
      BoxConstraints constraints, ChatPresentation presentation) {
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
                            text: gif.images?.original?.url,
                            messageType: MessageType.GIPHY,
                            chatPresentation: presentation);
                      }
                    }
                  }
                },
                icon: Icon(Icons.emoji_emotions)),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: IconButton(
                onPressed: () async {
                  var data = await presentation.getImage();
                  if (data != null) {
                    sendMessage(
                        text: kNotAvailable,
                        messageType: MessageType.IMAGE,
                        chatPresentation: presentation,
                        fileData: data);
                  }
                },
                icon: Icon(LineAwesomeIcons.image)),
          ),
          Flexible(
            flex: 8,
            fit: FlexFit.tight,
            child: TextFormField(
              maxLength: 600,
              maxLines: null,
              controller: textEditingController,
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              onEditingComplete: () {
                sendMessage(
                    text: textEditingController.text,
                    messageType: MessageType.TEXT,
                    chatPresentation: presentation);
              },
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: IconButton(
                onPressed: () {
                  sendMessage(
                      text: textEditingController.text,
                      messageType: MessageType.TEXT,
                      chatPresentation: presentation);
                },
                icon: Icon(Icons.send)),
          ),
        ],
      ),
    );
  }

  void sendMessage(
      {required String? text,
      required MessageType messageType,
      required ChatPresentation chatPresentation,
      Uint8List? fileData}) {
    if (text != null) {
      if (text.length > 0) {
        chatPresentation.sendMessage(
            retryMessageSending: false,
            message: new Message(
              fileData: fileData,
              messageDateText: kNotAvailable,
              read: false,
              isResponse: false,
              data: text,
              chatId: widget.chatId,
              senderId: GlobalDataContainer.userId,
              messageId: "",
              messageDate: DateTime.now().millisecondsSinceEpoch,
              messageType: messageType,
            ),
            messageNotificationToken: chatPresentation
                .chatController.chatList[chatLitIndex].notificationToken,
            remitentId: widget.remitentId);

        textEditingController.text = "";
      }
    }
  }

  showDeleteChatDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Eliminar conversacion"),
            actions: [
              TextButton(
                  onPressed: () {
                    Dependencies.chatPresentation.deleteChat(
                        remitent1: GlobalDataContainer.userId as String,
                        remitent2: widget.remitentId,
                        reportDetails: "NOT_AVAILABLE",
                        chatId: widget.chatId);

                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("Si")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No"))
            ],
          );
        });
  }
}
