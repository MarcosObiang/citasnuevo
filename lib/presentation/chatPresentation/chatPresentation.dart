import 'dart:async';

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatScreen.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTile.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTilesScreen.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/emptyChatWidget.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/domain/controller/chatController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:flutter/material.dart';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../domain/entities/ChatEntity.dart';

enum ChatListState { loading, ready, empty, error }

class ChatPresentation extends ChangeNotifier implements Presentation {
  ChatController chatController;
  ChatReportSendingState chatReportSendingState =
      ChatReportSendingState.notSended;
  late ChatListState chatListState = ChatListState.empty;
  String currentOpenChat = "NOT_ AVAILABLE";

  @override
  bool clearModuleData() {
    chatReportSendingState = ChatReportSendingState.notSended;
    chatListState = ChatListState.empty;
    currentOpenChat = "NOT_ AVAILABLE";

    return true;
  }

  /// Via this [StreamController] we send the [Chat.chatId] wich [ChatMessagesScreen]
  ///
  /// need to be updated
  StreamController<Message> updateMessageListNotification =
      new StreamController.broadcast();
  StreamController<String> chatDeletedNotification =
      new StreamController.broadcast();

  late StreamSubscription chatStreamSubscription;
  late StreamSubscription messageStreamSubscription;

  ChatPresentation({
    required this.chatController,
  });

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
      initializeChatStream();
    });
  }

  /// Here we start the MESSAGE LISTENER and if it succeds we call [_initializeMessageStream] method
  @protected
  void initializeMessageListener() async {
    var result = await chatController.initializeMessageListener();
    result.fold((failure) {}, (succes) {
      _initializeMessageStream();
    });
  }

  /// Here we start to listen the [Message] stream from the [ChatController]
  ///
  /// wich recieves the new [Message] that has been added to a [Chat] object ´s messageList from the [ChatController.chatList]
  ///
  /// Then to update the [ChatMessagesScreen]´s [AnimatedList] we send the [Chat.chatId] via [updateMessageListNotification]
  ///
  /// Last we add to [updateMessageListNotification] an empty string due to an unexpected behaviour where even if we send the id once the [ChatMessagesScreen]
  ///
  /// will listen to it twice leading to a [RangeError]

  void _initializeMessageStream() {
    messageStreamSubscription = chatController.getMessageStream.stream.listen(
        (event) {
          Message message = event["message"];

          if (ChatMessagesScreen.chatMessageScreenState.currentState != null) {
            updateMessageListNotification.add(message);
          } else {
            notifyListeners();
          }
        },
        cancelOnError: false,
        onError: (_) {
          setChatListState = ChatListState.error;
        });
  }

  void loadMoreMessages(
      {required String chatId, required String lastMessageId}) async {
    notifyListeners();

    Either<Failure, List<Message>> result = await chatController
        .loadMoreMessages(chatId: chatId, lastMessageId: lastMessageId);
    result.fold((l) {
      if (l is NetworkFailure) {
        showNetworkErrorDialog(context: startKey.currentContext);
      }
      notifyListeners();
    }, (r) {
      notifyListeners();

      if (chatController.chatOpenId == chatId) {
        for (int i = 0; i < chatController.chatList.length; i++) {
          if (chatController.chatList[i].chatId == chatId) {
            for (int a = 0;
                a < r.length && chatController.chatOpenId == chatId;
                a++) {
              ChatMessagesScreen.chatMessageScreenState.currentState
                  ?.insertItem(0, duration: Duration(milliseconds: 200));
            }
          }
        }
      }
    });
  }

  void initializeChatStream() {
    chatStreamSubscription = chatController.getChatStream.stream.listen(
        (event) {
          if (event is ChatException) {
            chatListState = ChatListState.error;
          } else {
            bool isModified = event["modified"];
            bool isRemoved = event["removed"];
            bool firstQuery = event["firstQuery"];
            List<Chat> chatListFromStream = event["chatList"];
            if (isRemoved == false &&
                isModified == false &&
                chatListFromStream.isNotEmpty &&
                firstQuery == true) {
              setChatListState = ChatListState.ready;
            }
            if (isRemoved == false &&
                isModified == false &&
                chatListFromStream.isNotEmpty &&
                firstQuery == true) {
              setChatListState = ChatListState.ready;
              ChatScreen.chatListState.currentState?.insertItem(0);
              ChatScreen.newChatListState.currentState?.insertItem(0);
            }

            if (chatListFromStream.isEmpty) {
              setChatListState = ChatListState.empty;
            }

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
            }

            if (isModified) {
              setChatListState = ChatListState.ready;
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
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
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
    for (int i = 0; i < chatController.chatList.length; i++) {
      if (chatController.chatList[i].chatId == chatId) {
        chatController.chatList[i].isBeingDeleted = true;
        notifyListeners();

        break;
      }
    }

    var result = await chatController.deleteChat(
        remitent1: remitent1,
        remitent2: remitent2,
        reportDetails: reportDetails,
        chatId: chatId);

    result.fold((failure) {
      for (int i = 0; i < chatController.chatList.length; i++) {
        if (chatController.chatList[i].chatId == chatId) {
          chatController.chatList[i].isBeingDeleted = false;
          notifyListeners();
          break;
        }
      }
      if (failure is NetworkFailure) {
        showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        showErrorDialog(
            title: "title",
            content: "content",
            context: startKey.currentContext);
      }
    }, (r) => null);
  }

  @override
  void initialize() {
    initializeChatListener();
    initializeMessageListener();
  }

  @override
  void restart() {
    chatStreamSubscription.cancel();
    messageStreamSubscription.cancel();
    updateMessageListNotification.close();
    chatDeletedNotification.close();
    updateMessageListNotification = new StreamController.broadcast();
    chatDeletedNotification = new StreamController.broadcast();

    chatController.clearData();
    initializeChatListener();
    initializeMessageListener();
  }
}
