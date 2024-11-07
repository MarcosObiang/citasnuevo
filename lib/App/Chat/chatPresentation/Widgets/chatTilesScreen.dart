import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'chatTile.dart';
import 'emptyChatWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../../main.dart';
import '../chatPresentation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = "/ChatScreen";
  const ChatScreen({Key? key}) : super(key: key);
  static GlobalKey<AnimatedListState> chatListState = GlobalKey();
  static GlobalKey<AnimatedListState> newChatListState = GlobalKey();

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
    Dependencies.chatPresentation.checkOnChatListUpdates();
  }

  @override
  void didPushNext() {
    print("Did Push Next");
    //   Dependencies.chatPresentation.setAnyChatOpen = true;

    super.didPushNext();
  }

  int countNewChats() {
    int reslult = 0;

    for (int i = 0;
        i < Dependencies.chatPresentation.chatListCache.length;
        i++) {
      if (Dependencies.chatPresentation.chatListCache[i].messagesList.isEmpty) {
        reslult += 1;
      }
    }
    return reslult;
  }

  int countChats() {
    return Dependencies.chatPresentation.chatListCache.length;
  }

  ScrollController controller = new ScrollController();
  ScrollController newChatListController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.chatPresentation,
      child: Consumer<ChatPresentation>(builder: (BuildContext context,
          ChatPresentation chatPresentation, Widget? child) {
        return SafeArea(
            child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: chatPresentation.chatListState ==
                              ChatListState.ready ||
                          chatPresentation.chatListState == ChatListState.empty
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)!
                                            .chat_tile_screen_counter(
                                                countChats().toString()),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.apply(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container()),
              if (chatPresentation.chatListState == ChatListState.ready) ...[
                Flexible(
                  flex: 10,
                  fit: FlexFit.tight,
                  child: Container(
                    child: Column(
                      children: [
                        Flexible(
                          flex: 10,
                          fit: FlexFit.tight,
                          child: Padding(
                            padding: EdgeInsets.all(20.w),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              child: AnimatedList(
                                  physics: BouncingScrollPhysics(),
                                  controller: controller,
                                  key: ChatScreen.chatListState,
                                  initialItemCount:
                                      chatPresentation.chatListCache.length,
                                  itemBuilder: (BuildContext context, int index,
                                      Animation<double> animation) {
                                    return ChatCard(
                                      index: index,
                                      chatData:
                                          chatPresentation.chatListCache[index],
                                      animationValue: animation,
                                    );
                                  }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: chatPresentation.blindDateCreationState ==
                            BlindDateCreationState.done
                        ? Center(
                            child: ElevatedButton.icon(
                                onPressed: () {
                                  chatPresentation.createBlindDate();
                                },
                                icon: Container(
                                    height: 100.h,
                                    width: 100.h,
                                    child:
                                        Icon(LineAwesomeIcons.theater_masks)),
                                label: Text(AppLocalizations.of(context)!.chat_blinddate_button)),
                          )
                        : Center(
                            child: TextButton.icon(
                                onPressed: () {},
                                icon: Container(
                                  height: 100.h,
                                  width: 100.h,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: LoadingIndicator(
                                        indicatorType:
                                            Indicator.lineSpinFadeLoader),
                                  ),
                                ),
                                label: Text(AppLocalizations.of(context)!.chat_blind_date_progress_message)),
                          ))
              ],
              if (chatPresentation.chatListState == ChatListState.empty) ...[
                Flexible(
                  flex: 10,
                  fit: FlexFit.loose,
                  child: Container(
                      child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.chat_tile_screen_no_chats_message,
                      style: GoogleFonts.lato(
                        color: Colors.black,
                      ),
                    ),
                  )),
                ),
                Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: chatPresentation.blindDateCreationState ==
                            BlindDateCreationState.done
                        ? Center(
                            child: ElevatedButton.icon(
                                onPressed: () {
                                  chatPresentation.createBlindDate();
                                },
                                icon: Container(
                                    height: 100.h,
                                    width: 100.h,
                                    child:
                                        Icon(LineAwesomeIcons.theater_masks)),
                                label: Text(AppLocalizations.of(context)!.chat_blinddate_button)),
                          )
                        : Center(
                            child: TextButton.icon(
                                onPressed: () {},
                                icon: Container(
                                  height: 100.h,
                                  width: 100.h,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: LoadingIndicator(
                                        indicatorType:
                                            Indicator.lineSpinFadeLoader),
                                  ),
                                ),
                                label: Text(AppLocalizations.of(context)!.chat_blind_date_progress_message)),
                          ))
              ],
              if (chatPresentation.chatListState == ChatListState.error) ...[
                Flexible(
                  flex: 10,
                  fit: FlexFit.loose,
                  child: Container(
                      child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.chat_tile_screen_error_loading_chats,
                          style: GoogleFonts.lato(
                            color: Colors.black,
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              chatPresentation.restart();
                            },
                            child: Text(AppLocalizations.of(context)!.try_again))
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: 300.h,
                            width: 300.h,
                            child: LoadingIndicator(
                                indicatorType: Indicator.ballScale)),
                        Text(
                          AppLocalizations.of(context)!.loading,
                          style: GoogleFonts.lato(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  )),
                )
              ],
            ],
          ),
        ));
      }),
    );
  }
}
