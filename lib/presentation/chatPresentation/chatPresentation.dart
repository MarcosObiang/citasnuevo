import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatScreen.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTile.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTilesScreen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

import 'package:citasnuevo/domain/controller/chatController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';

import '../../domain/entities/ChatEntity.dart';

enum ChatListState { loading, ready, empty, error }

class ChatPresentation extends ChangeNotifier implements Presentation {
  ChatController chatController;
  late ChatListState chatListState = ChatListState.empty;
  String currentOpenChat = "NOT_ AVAILABLE";

  /// Via this [StreamController] we send the [Chat.chatId] wich [ChatMessagesScreen]
  ///
  /// need to be updated
  StreamController<String> updateMessageListNotification =
      new StreamController.broadcast();
  StreamController<String> chatDeletedNotification =
      new StreamController.broadcast();
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
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
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
    }, (succes) {
      initializeChatStream();
    });
  }

  /// Here we start the MESSAGE LISTENER and if it succeds we call [_initializeMessageStream] method

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

  void _initializeMessageStream() {
    chatController.getMessageStream.stream.listen((event) {
      Message message = event["message"];
      if (ChatMessagesScreen.chatMessageScreenKey.currentState != null) {
        updateMessageListNotification.add(message.chatId);
      }
      notifyListeners();
    });
  }

  void loadMoreMessages(
      {required String chatId, required String lastMessageId}) async {
    notifyListeners();

    Either<Failure, List<Message>> result = await chatController
        .loadMoreMessages(chatId: chatId, lastMessageId: lastMessageId);
    result.fold((l) {
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
    chatController.getChatStream.stream.listen((event) {
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
      }

      if (isRemoved) {
        chatDeletedNotification.add(chatListFromStream.first.chatId);

        ChatScreen.chatListState.currentState?.removeItem(
            chatController.chatRemovedIndex,
            (context, animation) => ChatCard(
                chatData: chatListFromStream.first,
                animationValue: animation,
                index: chatController.chatRemovedIndex));
      }

      if (isModified) {
        setChatListState = ChatListState.ready;
      }
    });
  }

  void closeStreams() {
    updateMessageListNotification.close();
    chatDeletedNotification.close();
  }

  void getChatRemitentProfile({required String profileId})async{
        var result = await chatController.getUserProfile(profileId: profileId);
    result.fold((failure) {}, (succes) {});

  }

  void sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId}) async {
    var result = await chatController.sendMessage(
        message: message,
        messageNotificationToken: messageNotificationToken,
        remitentId: remitentId);
    result.fold((failure) {}, (succes) {});
  }

  @override
  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {
    // TODO: implement showErrorDialog
  }

  @override
  void showLoadingDialog() {
    // TODO: implement showLoadingDialog
  }

  @override
  void showNetworkErrorDialog({required BuildContext? context}) {
    // TODO: implement showNetworkErrorDialog
  }
}
