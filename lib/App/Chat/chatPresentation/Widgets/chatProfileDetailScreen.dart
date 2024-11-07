// ignore_for_file: must_be_immutable

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../ProfileViewer/ProfileEntity.dart';
import '../../../ProfileViewer/homeScreenPresentation/Widgets/profileWidget.dart';
import '../../ChatEntity.dart';
import '../chatPresentation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                    AppLocalizations.of(context)!.chat_profile_details_title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.apply(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                Expanded(
                    child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: chatPresentation
                                        .chatController
                                        .chatList[index]
                                        .senderProfileLoadingState ==
                                    SenderProfileLoadingState.READY
                                ? LayoutBuilder(
                                    builder: (context, constraints) {
                                    return ProfileWidget(
                                      profile: chatPresentation
                                          .chatController
                                          .chatList[index]
                                          .senderProfile as Profile,
                                      boxConstraints: constraints,
                                      listIndex: 0,
                                      needRatingWidget: false,
                                      showDistance: false,
                                    );
                                  })
                                : chatPresentation
                                            .chatController
                                            .chatList[index]
                                            .senderProfileLoadingState ==
                                        SenderProfileLoadingState.ERROR
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.error,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(AppLocalizations.of(context)!.error,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineMedium
                                                            ?.apply(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onSurface,
                                                                fontWeightDelta:
                                                                    2)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.transparent,
                                            height: 50.h,
                                          ),
                                          Text(AppLocalizations.of(context)!.chat_error_loading_profile,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.apply(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface)),
                                          Divider(
                                            color: Colors.transparent,
                                            height: 50.h,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Dependencies.chatPresentation
                                                  .getChatRemitentProfile(
                                                      profileId:
                                                          widget.remitentId,
                                                      chatId: widget.chatId);
                                            },
                                            child: Text(AppLocalizations.of(context)!.try_again),
                                          )
                                        ],
                                      )
                                    : chatPresentation
                                                .chatController
                                                .chatList[index]
                                                .senderProfileLoadingState ==
                                            SenderProfileLoadingState.LOADING
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 200.w,
                                                width: 200.w,
                                                child: LoadingIndicator(
                                                  indicatorType: Indicator
                                                      .circleStrokeSpin,
                                                  colors: [
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Center(
                                                  child: Text(AppLocalizations.of(context)!.loading,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.apply(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurface)),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container()),
                      ),
                      Flexible(
                        flex: 2,
                        fit: FlexFit.loose,
                        child: Container(
                            child: Center(
                          child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back),
                              label: Text(AppLocalizations.of(context)!.back)),
                        )),
                      )
                    ],
                  ),
                )),
              ],
            ),
          ));
        }),
      ),
    );
  }
}
