import 'dart:async';

import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/presentation/MessagesScreenPresentation/chatScreen.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:flutter/cupertino.dart';

import 'package:citasnuevo/domain/controller/messagesController.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';

import '../../core/dependencies/error/Failure.dart';
import '../../core/params_types/params_and_types.dart';
import '../../main.dart';
import '../dialogs.dart';

enum MessagesScreenState { READY, LOADING, ERROR, CHAT_DELETED }

class MessagesPresentation extends ChangeNotifier
    implements ModuleCleanerPresentation, ShouldUpdateData, ShouldAddData {
  MessagesController messagesController;
  @override
  StreamSubscription? addDataSubscription;

  @override
  StreamSubscription? updateSubscription;

  MessagesScreenState _messagesScreenState = MessagesScreenState.LOADING;

  String openChatId = kNotAvailable;

  MessagesPresentation({
    required this.messagesController,
  });

  set setMessageScreenState(MessagesScreenState messagesScreenState) {
    this._messagesScreenState = messagesScreenState;
    notifyListeners();
  }

  MessagesScreenState get getMessageScreenState => this._messagesScreenState;

  @override
  void clearModuleData() {
    try {
      _messagesScreenState = MessagesScreenState.LOADING;
      updateSubscription?.cancel();
      addDataSubscription?.cancel();
      updateSubscription = null;
      addDataSubscription = null;
      openChatId = kNotAvailable;
      var result = messagesController.clearModuleData();
      result.fold(
          (l) => _messagesScreenState = MessagesScreenState.ERROR, (r) => null);
    } catch (e) {
      _messagesScreenState = MessagesScreenState.ERROR;
    }
  }

  @override
  void initializeModuleData() {
    try {
      addData();
      update();
      var result = this.messagesController.initializeModuleData();
      result.fold(
          (l) => _messagesScreenState = MessagesScreenState.ERROR, (r) => null);
    } catch (e) {
      _messagesScreenState = MessagesScreenState.ERROR;
    }
  }

  @override
  void addData() {
    addDataSubscription =
        messagesController.addDataController?.stream.listen((event) {
      String eventType = event["eventType"];

      if (eventType == "addNewMessageData") {
        String messageChatId = event["data"];

        if (messageChatId == openChatId) {
          ChatMessagesScreen.messageListState.currentState
              ?.insertItem(0, duration: Duration(milliseconds: 300));
        }
      }
    
    }, onError: (error) {
      setMessageScreenState = MessagesScreenState.ERROR;
    });
  }

  @override
  void update() {
    updateSubscription =
        messagesController.updateDataController?.stream.listen((event) {
      String eventType = event["eventType"];

      if (eventType == "chatGroupDeleted") {
        String deletedChatId = event["data"];
        if (deletedChatId == openChatId) {
          setMessageScreenState = MessagesScreenState.CHAT_DELETED;
        }
      }
         if (eventType == "modifyMessageGroup") {
       notifyListeners();
      }


    }, onError: (error) {
      setMessageScreenState = MessagesScreenState.ERROR;
    });
  }

  void setMessagesOnSeen({required String chatId}) async {
    await messagesController.setMessagesOnSeen(chatId: chatId);
  }

  void getChatRemitentProfile(
      {required String profileId, required String chatId}) async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
    var result = await messagesController.getUserProfile(
        profileId: profileId, chatId: chatId);
    result.fold((failure) {
      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      }
      notifyListeners();
    }, (succes) {
      notifyListeners();
    });
  }

  Future<void> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId}) async {
    var result = await messagesController.deleteChat(
        remitent1: remitent1,
        remitent2: remitent2,
        reportDetails: reportDetails,
        chatId: chatId);

    result.fold((failure) {
      notifyListeners();

      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        PresentationDialogs.instance.showErrorDialog(
            title: "Error",
            content: "Error al intentar eliminar la conversacion",
            context: startKey.currentContext);
      }
    }, (r) => null);
  }

  void sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId}) async {
    var result = await messagesController.sendMessage(
        message: message,
        messageNotificationToken: messageNotificationToken,
        remitentId: remitentId);
    result.fold((failure) {
      if (failure is NetworkFailure) {
        var startKey;
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        PresentationDialogs.instance.showErrorDialog(
            title: "title",
            content: "content",
            context: startKey.currentContext);
      }
    }, (succes) {});
  }
}
