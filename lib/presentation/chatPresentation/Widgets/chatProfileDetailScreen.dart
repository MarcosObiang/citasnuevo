// ignore_for_file: must_be_immutable

import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatPresentation.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/profileWidget.dart';
import 'package:flutter/material.dart';

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class ChatProfileDetailsScreen extends StatefulWidget {
  String remitentId;
  String chatId;

  ChatProfileDetailsScreen({
    required this.remitentId,
    required this.chatId,
  });

  @override
  _ChatProfileDetailsScreenState createState() =>
      _ChatProfileDetailsScreenState();
}

class _ChatProfileDetailsScreenState extends State<ChatProfileDetailsScreen> {
  Profile? userProfile;
  int index = -1;

  @override
  void initState() {
    super.initState();
    index = getIndex(chatId: widget.chatId);

    searchChatObject();
  }

  @override
  void didChangeDependencies() {
    index = getIndex(chatId: widget.chatId);
    super.didChangeDependencies();
  }

  void searchChatObject() {
    if (Dependencies
            .chatPresentation.chatController.chatList[index].senderProfile ==
        null) {
      Dependencies.chatPresentation.getChatRemitentProfile(
          profileId: widget.remitentId, chatId: widget.chatId);
    } else {
      userProfile = Dependencies
          .chatPresentation.chatController.chatList[index].senderProfile;
    }
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
      child: Material(
        child: Consumer<ChatPresentation>(builder: (BuildContext context,
            ChatPresentation chatPresentation, Widget? child) {
          return SafeArea(
              child: chatPresentation.chatController.chatList[index]
                          .senderProfileLoadingState ==
                      SenderProfileLoadingState.READY
                  ? Container(
                      color: Colors.amberAccent,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return ProfileWidget(
                          profile: chatPresentation.chatController
                              .chatList[index].senderProfile as Profile,
                          boxConstraints: constraints,
                          listIndex: 0,
                          needRatingWidget: false,
                          showDistance: false,
                        );
                      }),
                    )
                  : chatPresentation.chatController.chatList[index]
                              .senderProfileLoadingState ==
                          SenderProfileLoadingState.ERROR
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Center(
                                child: Text("ERROR"),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Dependencies.chatPresentation
                                    .getChatRemitentProfile(
                                        profileId: widget.remitentId,
                                        chatId: widget.chatId);
                              },
                              child: Text("Intentar de nuevo"),
                            )
                          ],
                        )
                      : chatPresentation.chatController.chatList[index]
                                  .senderProfileLoadingState ==
                              SenderProfileLoadingState.LOADING
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 200.w,
                                  width: 200.w,
                                  child: LoadingIndicator(
                                      indicatorType: Indicator.ballBeat),
                                ),
                                Container(
                                  child: Center(
                                    child: Text("Cargando"),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              color: Colors.pink,
                            ));
        }),
      ),
    );
  }
}
