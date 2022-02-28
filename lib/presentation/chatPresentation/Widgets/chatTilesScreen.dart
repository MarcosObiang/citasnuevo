import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../main.dart';
import '../chatPresentation.dart';

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
