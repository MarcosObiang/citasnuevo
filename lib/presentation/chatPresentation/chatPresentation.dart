import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatScreen.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTile.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTilesScreen.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/emptyChatWidget.dart';

import 'package:citasnuevo/domain/controller/chatController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notify_inapp/notify_inapp.dart';
import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../domain/entities/ChatEntity.dart';

enum ChatListState { loading, ready, empty, error }

class ChatPresentation extends ChangeNotifier
    implements
        Presentation<ChatInformationSender>,
        SouldAddData<ChatInformationSender>,
        ShouldRemoveData<ChatInformationSender>,
        ShouldUpdateData<ChatInformationSender>,
        ModuleCleaner {
  ChatController chatController;
  ChatReportSendingState chatReportSendingState =
      ChatReportSendingState.notSended;
  late ChatListState chatListState = ChatListState.empty;
  String currentOpenChat = kNotAvailable;

  /// Via this [StreamController] we send the [Chat.chatId] to [ChatMessagesScreen]
  ///
  /// if the [Chat.chatId] of the [ChatMessagesScreen] match the id we have sended via this [StreamController]
  ///
  /// it will mean we need to add a new message to the conversation
  StreamController<Message> updateMessageListNotification =
      new StreamController.broadcast();

  /// Via this [StreamController] we send the [Chat.chatId] to [ChatMessagesScreen]
  ///
  /// if the chat opened in [ChatMessagesScreen] has the same [Chat.chatId]
  ///
  /// it will mean that the conversation has been deleted,
  ///
  /// so with this stream we let the user know that the chat has been deleted
  StreamController<String> chatDeletedNotification =
      new StreamController.broadcast();

  @override
  late StreamSubscription<ChatInformationSender> addDataSubscription;

  @override
  late StreamSubscription<ChatInformationSender> removeDataSubscription;

  @override
  late StreamSubscription<ChatInformationSender> updateSubscription;

  ChatPresentation({
    required this.chatController,
  }) {
    initialize();
  }

  get anyChatOpen => chatController.getAnyChatOpen;

  set setAnyChatOpen(bool value) {
    chatController.setAnyChatOpen = value;
    if (anyChatOpen == false) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        notifyListeners();
      });
    }
  }

  set setChatListState(ChatListState chatListStateData) {
    this.chatListState = chatListStateData;
    notifyListeners();
  }

  void setMessagesOnSeen({required String chatId}) async {
    await chatController.setMessagesOnSeen(chatId: chatId);
  }

  ///Initializes Chat listener to update chat tiles when needed

  void initializeChatListener() async {
    setChatListState = ChatListState.loading;
    var result = await chatController.initializeChatListener();
    result.fold((failure) {
      setChatListState = ChatListState.error;

      if (failure is NetworkFailure) {
        showNetworkErrorDialog(context: startKey.currentContext);
      }
    }, (succes) {
      addData();
      removeData();
      update();
    });
  }

  /// Here we start the MESSAGE LISTENER and if it succeds we call [_initializeMessageStream] method
  @protected
  void initializeMessageListener() async {
    var result = await chatController.initializeMessageListener();
    result.fold((failure) {}, (succes) {});
  }

  void closeStreams() {
    updateMessageListNotification.close();
    chatDeletedNotification.close();
  }

  void getChatRemitentProfile(
      {required String profileId, required String chatId}) async {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
    var result = await chatController.getUserProfile(
        profileId: profileId, chatId: chatId);
    result.fold((failure) {
      if (failure is NetworkFailure) {
        showNetworkErrorDialog(context: startKey.currentContext);
      }
      notifyListeners();
    }, (succes) {
      notifyListeners();
    });
  }

  void sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId}) async {
    var result = await chatController.sendMessage(
        message: message,
        messageNotificationToken: messageNotificationToken,
        remitentId: remitentId);
    result.fold((failure) {
      if (failure is NetworkFailure) {
        showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        showErrorDialog(
            title: "title",
            content: "content",
            context: startKey.currentContext);
      }
    }, (succes) {});
  }

  @override
  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {
    if (context != null) {
      showDialog(
          context: context,
          builder: (context) =>
              GenericErrorDialog(content: content, title: title));
    }
  }

  @override
  void showLoadingDialog() {}

  @override
  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }

  Future<void> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId}) async {
    var result = await chatController.deleteChat(
        remitent1: remitent1,
        remitent2: remitent2,
        reportDetails: reportDetails,
        chatId: chatId);

    result.fold((failure) {
      notifyListeners();

      if (failure is NetworkFailure) {
        showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        showErrorDialog(
            title: "Error",
            content: "Error al intentar eliminar la conversacion",
            context: startKey.currentContext);
      }
    }, (r) => null);
  }

  @override
  void initialize() {
    initializeModuleData();
    initializeChatListener();
    initializeMessageListener();
  }

  @override
  void restart() {
    clearModuleData();
    initializeModuleData();
    initializeChatListener();
    initializeMessageListener();
  }

  @override
  @protected
  void clearModuleData() {
    updateMessageListNotification.close();
    addDataSubscription.cancel();
    removeDataSubscription.cancel();
    updateSubscription.cancel();
    chatDeletedNotification.close();
    updateMessageListNotification = new StreamController.broadcast();
    chatDeletedNotification = new StreamController.broadcast();

    chatReportSendingState = ChatReportSendingState.notSended;
    chatListState = ChatListState.empty;
    currentOpenChat = kNotAvailable;
    chatController.clearModuleData();
  }

  @override
  void addData() {
    addDataSubscription = chatController.addDataController.stream.listen(
        (event) async {
          if (event is ChatException) {
            setChatListState = ChatListState.error;
          } else {
            bool isModified = event.isModified as bool;
            bool isRemoved = event.isDeleted as bool;
            bool isChat = event.isChat as bool;
            bool isFirstQuery=event.firstQuery;
            List<Chat> chatListFromStream = event.chatList as List<Chat>;

            if (isChat) {
              if (isRemoved == false &&
                  isModified == false &&
                  chatListFromStream.isNotEmpty) {
                    if(isFirstQuery==false){
                    showInAppNewConversation();

                    }
                setChatListState = ChatListState.ready;
                ChatScreen.chatListState.currentState?.insertItem(0);
                ChatScreen.newChatListState.currentState?.insertItem(0);
              }

              if (chatListFromStream.isEmpty) {
                setChatListState = ChatListState.empty;
              }
            }
            if (isChat == false) {
              Message message = event.messageList?.first as Message;
              if (ChatMessagesScreen.chatMessageScreenState.currentState !=
                  null) {
                if (isModified == false) {
                  updateMessageListNotification.add(message);
                }
              } else {
                notifyListeners();
                showInAppessageNotification(message);
              }
            }

            WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
              notifyListeners();
            });
          }
        },
        cancelOnError: false,
        onError: (_) {
          setChatListState = ChatListState.error;
        });
  }

  void showInAppessageNotification(Message message) {
    if (message.senderId != GlobalDataContainer.userId) {
      Notify notify = Notify();
      notify.show(
          startKey.currentContext as BuildContext,
          Padding(
            padding: EdgeInsets.all(10.h),
            child: Container(
                height: 150.h,
                width: ScreenUtil().screenWidth,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: EdgeInsets.all(10.h),
                  child: Column(
                    children: [
                      Text(
                        "Nuevo mensaje",
                        style: GoogleFonts.lato(fontSize: 60.sp),
                      ),
                      Text(
                        "Nuevo mensaje sin leer",
                        style: GoogleFonts.lato(fontSize: 40.sp),
                      ),
                    ],
                  ),
                )),
          ),
          duration: 300);
    }
  }

    void showInAppNewConversation() {
    
      Notify notify = Notify();
      notify.show(
          startKey.currentContext as BuildContext,
          Padding(
            padding: EdgeInsets.all(10.h),
            child: Container(
                height: 150.h,
                width: ScreenUtil().screenWidth,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: EdgeInsets.all(10.h),
                  child: Column(
                    children: [
                      Text(
                        "Nueva conversacion",
                        style: GoogleFonts.lato(fontSize: 60.sp),
                      ),
                      Text(
                        "Tienes una nueva conversacion",
                        style: GoogleFonts.lato(fontSize: 40.sp),
                      ),
                    ],
                  ),
                )),
          ),
          duration: 300);
    
  }

  @override
  void removeData() {
    removeDataSubscription =
        chatController.removeDataController.stream.listen((event) {
      bool isRemoved = event.isDeleted as bool;
      List<Chat> chatListFromStream = event.chatList as List<Chat>;

      if (isRemoved) {
        chatDeletedNotification.add(chatListFromStream.first.chatId);

        ChatScreen.newChatListState.currentState?.removeItem(
            chatController.chatRemovedIndex,
            (context, animation) => EmptyChatWidget(
                chat: chatListFromStream.first,
                animation: animation,
                index: chatController.chatRemovedIndex));

        ChatScreen.chatListState.currentState?.removeItem(
            chatController.chatRemovedIndex,
            (context, animation) => ChatCard(
                chatData: chatListFromStream.first,
                animationValue: animation,
                index: chatController.chatRemovedIndex));

        if (chatController.chatList.isEmpty) {
          setChatListState = ChatListState.empty;
        }
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          notifyListeners();
        });
      }
    });
  }

  @override
  void update() {
    updateSubscription =
        chatController.updateDataController.stream.listen((event) {
      notifyListeners();
    });
  }

  @override
  void initializeModuleData() {
    chatController.initializeModuleData();
  }
}
