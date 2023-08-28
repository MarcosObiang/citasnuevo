// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool? wasBlindChat;

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
    widget.wasBlindChat =
        Dependencies.chatController.chatList[chatLitIndex].isBlindDate;
    remitentImageData = ImageFile.getFile(
        fileId:
            Dependencies.chatController.chatList[chatLitIndex].remitentPicture);

    Dependencies.chatPresentation.setMessagesOnSeen(chatId: widget.chatId);
    Dependencies.chatPresentation.setCurrentOpenChat = widget.chatId;
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

  void checkIfBlindCChatHadBeenRevealed(ChatPresentation chatPresentation) {
    if (chatPresentation.chatController.chatList[chatLitIndex].isBlindDate ==
            false &&
        widget.wasBlindChat == true) {
      remitentImageData = ImageFile.getFile(
          fileId: chatPresentation
              .chatController.chatList[chatLitIndex].remitentPicture);
      widget.wasBlindChat = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: Dependencies.chatPresentation,
        key: ChatMessagesScreen.messageScreenKey,
        child: Consumer<ChatPresentation>(builder: (BuildContext context,
            ChatPresentation chatPresentation, Widget? child) {
          checkIfBlindCChatHadBeenRevealed(chatPresentation);
          return Stack(
            children: [
              Scaffold(
                  appBar: chatScreenAppBar(chatPresentation),
                  resizeToAvoidBottomInset: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
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
                                      (kBottomNavigationBarHeight),
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
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete),
              Text(
                "Conversacion eliminada",
                style: Theme.of(context).textTheme.titleMedium?.apply(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              Divider(
                color: Colors.transparent,
                height: 50.h,
              ),
              Text(
                "Lo sentimos,el remitente ha borrado la conversacion",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.apply(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              Divider(
                color: Colors.transparent,
                height: 50.h,
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
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Divider(
                color: Colors.transparent,
                height: 50.h,
              ),
              Icon(
                Icons.lock,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              Divider(
                color: Colors.transparent,
                height: 50.h,
              ),
              Text(
                "Usuario bloqueado",
                style: Theme.of(context).textTheme.headlineLarge?.apply(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              Text(
                "Lo sentimos, este usuario ha sido bloqueado por infringir las normas de la comunidad",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.apply(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              Divider(
                color: Colors.transparent,
                height: 50.h,
              ),
              ElevatedButton(
                  onPressed: () {
                    showDeleteChatDialog();
                  },
                  child: Text("Eliminar conversacion")),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Atras")),
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
                child: Icon(Icons.arrow_downward,
                    color: Theme.of(context).colorScheme.onSecondary),
              ),
              height: 150.w,
              width: 150.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondary,
              )),
        ),
      ),
    );
  }

  Widget messageList({required ChatPresentation chatPresentation}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
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
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Flexible(
              flex: 4,
              fit: FlexFit.loose,
              child: GestureDetector(
                onTap: () {
                  if (chatPresentation
                          .chatController.chatList[chatLitIndex].isBlindDate ==
                      false) {
                    Navigator.push(
                        context,
                        GoToRoute(
                            page: ChatProfileDetailsScreen(
                                chatId: widget.chatId,
                                remitentId: widget.remitentId)));
                  }
                },
                child: Container(
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
                            return Padding(
                              padding: EdgeInsets.all(2.h),
                              child: Container(
                                  height: 100.h,
                                  width: 100.h,
                                  decoration:
                                      BoxDecoration(shape: BoxShape.circle),
                                  child: snapshot.hasData == true
                                      ? ClipOval(
                                          child: Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Center(
                                          child: Container(
                                              height: 50.h,
                                              width: 50.h,
                                              child: LoadingIndicator(
                                                  indicatorType: Indicator
                                                      .circleStrokeSpin)),
                                        )),
                            );
                          })
                      : Icon(LineAwesomeIcons.mask),
                ),
              ),
            ),
            Flexible(flex: 1, fit: FlexFit.tight, child: Container()),
            Flexible(
              flex: 7,
              fit: FlexFit.loose,
              child: Container(
                  child: chatPresentation.chatController.chatList[chatLitIndex]
                              .isBlindDate ==
                          false
                      ? Text(
                          chatPresentation.chatController.chatList[chatLitIndex]
                              .remitentName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      : Row(
                          children: [
                            Text(
                              "Secreto",
                            ),
                            Icon(LineAwesomeIcons.lock)
                          ],
                        )),
            ),
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
          onPressed: () {
            presentation.revealBlindDate(
                chatId:
                    presentation.chatController.chatList[chatLitIndex].chatId);
          },
          icon: Icon(LineAwesomeIcons.unlock),
          label: Text("Revelar perfil")),
    );
  }

  Container messageSenderBar(
      BoxConstraints constraints, ChatPresentation presentation) {
    return Container(
      height: kBottomNavigationBarHeight * 1,
      width: constraints.biggest.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.loose,
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
            fit: FlexFit.loose,
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
            flex: 6,
            fit: FlexFit.loose,
            child: CupertinoTextField(
              maxLines: 5,
              minLines: 1,
              showCursor: true,
              controller: textEditingController,
              focusNode: focusNode,
              inputFormatters: [LengthLimitingTextInputFormatter(600)],
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.apply(color: Theme.of(context).colorScheme.onSurface),
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
            flex: 3,
            fit: FlexFit.loose,
            child: IconButton.filled(
                onPressed: () {
                  sendMessage(
                      text: textEditingController.text,
                      messageType: MessageType.TEXT,
                      chatPresentation: presentation);
                },
                icon: Icon(
                  Icons.send,
                )),
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
