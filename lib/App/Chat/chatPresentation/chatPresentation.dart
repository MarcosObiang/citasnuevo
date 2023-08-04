import 'dart:async';
import 'dart:typed_data';

import '../../DataManager.dart';
import '../../PrincipalScreen.dart';
import '../../PrincipalScreenDataNotifier.dart';
import '../../../Utils/dialogs.dart';
import '../../../Utils/presentationDef.dart';
import '../../controllerDef.dart';
import '../../../core/error/Exceptions.dart';
import '../../../core/error/Failure.dart';
import '../../../core/globalData.dart';
import '../../../core/params_types/params_and_types.dart';
import '../../../main.dart';
import '../ChatEntity.dart';
import '../MessageEntity.dart';
import 'Widgets/chatMessage.dart';
import 'Widgets/chatScreen.dart';
import 'Widgets/chatTile.dart';
import 'Widgets/chatTilesScreen.dart';
import 'Widgets/emptyChatWidget.dart';

import '../chatController.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notify_inapp/notify_inapp.dart';

enum ChatListState { loading, ready, empty, error }

enum BlindDateCreationState { loading, done }

enum BlindDateRevelationState { loading, done }

class ChatPresentation extends ChangeNotifier
    implements
        Presentation,
        ShouldAddData<ChatInformationSender>,
        ShouldRemoveData<ChatInformationSender>,
        ShouldUpdateData<ChatInformationSender>,
        ModuleCleanerPresentation,
        PrincipalScreenNotifier {
  ChatController chatController;
  ChatReportSendingState chatReportSendingState =
      ChatReportSendingState.notSended;
  List<Chat> chatListCache = [];
  late ChatListState chatListState = ChatListState.empty;
  BlindDateCreationState blindDateCreationState = BlindDateCreationState.done;
  BlindDateRevelationState blindDateRevelationState =
      BlindDateRevelationState.done;
  String _currentOpenChat = kNotAvailable;
  get getCurrentOpenChat => this._currentOpenChat;
  int newChats = 0;
  int newMessages = 0;

  set setCurrentOpenChat(currentOpenChat) {
    this._currentOpenChat = currentOpenChat;
    chatController.chatOpenId = this._currentOpenChat;
  }

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
  StreamSubscription<ChatInformationSender>? addDataSubscription;

  @override
  StreamSubscription<ChatInformationSender>? removeDataSubscription;

  @override
  StreamSubscription<ChatInformationSender>? updateSubscription;

  @override
  StreamController<Map<String, dynamic>>? principalScreenNotifier =
      StreamController();

  ChatPresentation({
    required this.chatController,
  });

  get anyChatOpen => chatController.getAnyChatOpen;

  set setAnyChatOpen(bool value) {
    chatController.setAnyChatOpen = value;
    if (anyChatOpen == false) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        notifyListeners();
      });
    }
  }

  set setChatListState(ChatListState chatListStateData) {
    this.chatListState = chatListStateData;
    notifyListeners();
  }

  set setBlindDateCreationState(BlindDateCreationState blindDateCreationState) {
    this.blindDateCreationState = blindDateCreationState;
    notifyListeners();
  }

  set setBlindDateRevelationState(
      BlindDateRevelationState blindDateRevelationState) {
    this.blindDateRevelationState = blindDateRevelationState;
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
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
    var result = await chatController.getUserProfile(
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

  void sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId,
      required bool retryMessageSending,
      Uint8List? fileData}) async {
    var result = await chatController.sendMessage(
      retryMessageSending: retryMessageSending,
      message: message,
      messageNotificationToken: messageNotificationToken,
      remitentId: remitentId,
    );
    result.fold((failure) {
      if (failure is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      }
      if (failure is ChatFailure) {
        if (failure.message == "MESSAGE_QUEQUE_IS_NOT_EMPTY") {
          PresentationDialogs.instance.showErrorDialog(
              title: "Error al enviar el mensaje",
              content:
                  "Tienes mensajes pendientes de ser enviados.\nQuizás se este enviando o haya habido un error en el envio",
              context: startKey.currentContext);
        }
        if (failure.message == "INTERNAL_ERROR") {
          PresentationDialogs.instance.showErrorDialog(
              title: "Error al enviar el mensaje",
              content:
                  "Si el problema continua cierre y vuelva a abrir la aplicacion o contacte con soporte",
              context: startKey.currentContext);
        }
      }
    }, (succes) {});
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

  @override
  void restart() {
    clearModuleData();
    initializeModuleData();
    initializeChatListener();
    initializeMessageListener();
  }

  @override
  void clearModuleData() {
    try {
      updateMessageListNotification.close();
      addDataSubscription?.cancel();
      removeDataSubscription?.cancel();
      updateSubscription?.cancel();
      chatDeletedNotification.close();
      updateMessageListNotification = new StreamController.broadcast();
      chatDeletedNotification = new StreamController.broadcast();
      newChats = 0;
      newMessages = 0;
      principalScreenNotifier?.close();
      principalScreenNotifier = null;
      principalScreenNotifier = StreamController();

      chatReportSendingState = ChatReportSendingState.notSended;
      chatListState = ChatListState.empty;
      setCurrentOpenChat = kNotAvailable;
      setBlindDateCreationState = BlindDateCreationState.done;
      setBlindDateRevelationState = BlindDateRevelationState.done;
      var result = chatController.clearModuleData();
      result.fold((l) {
        setChatListState = ChatListState.error;
      }, (r) => null);
    } catch (e) {
      setChatListState = ChatListState.error;
    }
  }

  ///***************** */ COMPROBAR QUE EL MENSAJE SE AÑADE AL CHAT NECESARIO
  @override
  void addData() {
    addDataSubscription = chatController.addDataController?.stream.listen(
        (event) async {
          await Future.delayed(Duration(milliseconds: 250));

          if (event is ChatException) {
            setChatListState = ChatListState.error;
          } else {
            bool isModified = event.isModified as bool;
            bool isRemoved = event.isDeleted as bool;
            bool isChat = event.isChat as bool;
            bool isFirstQuery = event.firstQuery;
            List<Chat> chatListFromStream = event.chatList as List<Chat>;
            newChats = event.newChats as int;
            newMessages = event.newMessages as int;

            if (isChat) {
              if (isRemoved == false &&
                  isModified == false &&
                  chatListFromStream.isNotEmpty) {
                if (isFirstQuery == false) {
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
              if (ChatMessagesScreen.messageListState.currentState != null) {
                if (isModified == false &&
                    getCurrentOpenChat == message.chatId) {
                  ChatMessagesScreen.messageListState.currentState!
                      .insertItem(0, duration: Duration(milliseconds: 200));
                }
                if (message.chatId != getCurrentOpenChat) {
                  if (message.messageType != MessageType.DATE) {
                    showInAppessageNotification(message);
                    notifyPrincipalScreen();
                  }
                }
              } else {
                notifyListeners();
                if (message.messageType != MessageType.DATE) {
                  showInAppessageNotification(message);
                }
              }
            }
            notifyPrincipalScreen();

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
        chatController.removeDataController?.stream.listen((event) {
      bool isRemoved = event.isDeleted as bool;
      List<Chat> chatListFromStream = event.chatList as List<Chat>;

      newChats = event.newChats as int;
      bool isChat = event.isChat as bool;
      if (isChat) {
        if (isRemoved) {
          chatDeletedNotification.add(chatListFromStream.first.chatId);
          if (ChatMessagesScreen.messageListState.currentState == null) {
            checkOnChatListUpdates();
          }

          if (chatListFromStream.first.chatId == getCurrentOpenChat) {
            if (ChatMessagesScreen.messageListState.currentState != null) {
              Navigator.popUntil(startKey.currentContext as BuildContext,
                  (route) => route.settings.name == PrincipalScreen.routeName);
            }
          }

          if (chatController.chatList.isEmpty) {
            setChatListState = ChatListState.empty;
          }
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            notifyPrincipalScreen();

            notifyListeners();
          });
        }
      } else {
        List<Message> messageList = event.messageList as List<Message>;
        newMessages = event.newMessages as int;

        if (ChatMessagesScreen.messageListState.currentState != null) {
          if (getCurrentOpenChat == messageList.first.chatId) {
            ChatMessagesScreen.messageListState.currentState!.removeItem(
                0,
                ((context, animation) => TextMessage(
                    message: messageList.first,
                    animation: animation,
                    sendMessageAgain: () {},
                    deleteMessage: () {})));
          }
        }
      }
    });
  }

  ///
  ///
  ///
  ///Chacks if there has been an update to the chatList
  ///
  ///
  void checkOnChatListUpdates() {
    for (int i = 0; i < chatListCache.length; i++) {
      if (chatListCache[i].removePending == true) {
        Chat removedChat = chatController.removeChatsFromList(chatIndex: i);

        ChatScreen.newChatListState.currentState?.removeItem(
            i,
            (context, animation) => EmptyChatWidget(
                chat: removedChat, animation: animation, index: i));

        ChatScreen.chatListState.currentState?.removeItem(
            i,
            (context, animation) => ChatCard(
                chatData: removedChat, animationValue: animation, index: i));
      }
    }
  }

  void removeMessageFromChatList(
      {required String chatId, required String messageId}) {
    this
        .chatController
        .removeMessageFromChatList(messageId: messageId, chatId: chatId);
  }

  @override
  void update() {
    updateSubscription =
        chatController.updateDataController?.stream.listen((event) {
      newChats = event.newChats as int;
      newMessages = event.newMessages as int;
      notifyPrincipalScreen();
      notifyListeners();
    });
  }

  @override
  void initializeModuleData() {
    chatController.initializeModuleData();
    this.chatListCache = chatController.chatList;
    setCurrentOpenChat = chatController.chatOpenId;
    initializeChatListener();
    initializeMessageListener();
  }

  @override
  void notifyPrincipalScreen() {
    principalScreenNotifier?.add({
      "payload": "chatData",
      "newMessagesCount": newMessages,
      "newChatsCount": newChats
    });
  }

  Future<Uint8List?> getImage() async {
    Uint8List? data;

    var result = await chatController.getImage();

    result.fold((l) => null, (r) => data = r);

    return data;
  }

  void revealBlindDate({required String chatId}) async {
    setBlindDateRevelationState = BlindDateRevelationState.loading;
    var result = await chatController.revealBlinDate(chatId: chatId);
    result.fold((l) {
      if (l is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      } else {
        if (l.message == "LOW_MESSAGES_COUNT") {
          PresentationDialogs.instance.showErrorDialog(
              title: "Pocos mensajes",
              content:
                  "Necesitais 20 mensajes o mas para revelar vuestra identidad",
              context: startKey.currentContext);
        }
        if (l.message == "INTERNAL_ERROR") {
          PresentationDialogs.instance.showErrorDialog(
              title: "Error de servidor",
              content:
                  "No podemos realizar la operacion intentalo de nuevo mas tarde, si el problema persiste contacta con soporte",
              context: startKey.currentContext);
        }
      }
    }, (r) => null);
    setBlindDateRevelationState = BlindDateRevelationState.done;
  }

  void createBlindDate() async {
    setBlindDateCreationState = BlindDateCreationState.loading;
    var result = await chatController.createBlindDate();

    result.fold((fail) {
      if (fail is NetworkFailure) {
        PresentationDialogs.instance
            .showNetworkErrorDialog(context: startKey.currentContext);
      }
      if (fail is LocationServiceFailure) {
        if (fail.message == "LOCATION_PERMISSION_DENIED_FOREVER") {
          PresentationDialogs.instance.showErrorDialogWithOptions(
              dialogOptionsList: [
                DialogOptions(
                    function: () {
                      openLocationSettings();
                      Navigator.pop(startKey.currentContext as BuildContext);
                    },
                    text: "Dar permiso de ubicacion"),
                DialogOptions(
                    function: () =>
                        Navigator.pop(startKey.currentContext as BuildContext),
                    text: "Ahora no")
              ],
              dialogTitle: "Permiso de localizacion",
              dialogText:
                  "Es necesario saber tu ubicaciòn para encontrarte citas a ciegas cerca de ti, dirigete a 'ajuses' para darnos permiso",
              context: startKey.currentContext);
        }

        if (fail.message == "LOCATION_PERMISSION_DENIED") {
          PresentationDialogs.instance.showErrorDialogWithOptions(
              dialogOptionsList: [
                DialogOptions(
                    function: () {
                      openLocationSettings();
                      Navigator.pop(startKey.currentContext as BuildContext);
                    },
                    text: "Dar permiso de ubicacion"),
                DialogOptions(
                    function: () =>
                        Navigator.pop(startKey.currentContext as BuildContext),
                    text: "Ahora no")
              ],
              dialogTitle: "Ir a ajustes",
              dialogText:
                  "Es necesario saber tu ubicaciòn para encontrarte citas a ciegas cerca de ti, dirigete a 'ajuses' para darnos permiso",
              context: startKey.currentContext);
        }

        if (fail.message == "UNABLE_TO_DETERMINE_LOCATION_STATUS") {
          PresentationDialogs.instance.showErrorDialog(
              title: "Error",
              content:
                  "Tenemos problemas para acceder a tu ubicacion, verifica que tu ubicacion esta activada ae intentalo de nuevo ",
              context: startKey.currentContext);
        }
        if (fail.message == "LOCATION_SERVICE_DISABLED") {
          PresentationDialogs.instance.showErrorDialog(
              title: "Activar ubicacion",
              content:
                  "Parece que tu ubicacion esta desactvada, activala para que puedas hablar con algien cercano a ti ",
              context: startKey.currentContext);
        }
      }
      if (fail is ChatFailure) {
        if (fail.message == "NO_USERS_FOUND") {
          PresentationDialogs.instance.showErrorDialog(
              title: "Error",
              content:
                  "No se han encontrado usuarios disponibles en este momento",
              context: startKey.currentContext);
        } else {
          PresentationDialogs.instance.showErrorDialog(
              title: "Error",
              content: "No se puede crear una cita a ciegas en este momento",
              context: startKey.currentContext);
        }
      }
    }, (r) => null);
    setBlindDateCreationState = BlindDateCreationState.done;
  }

  void openLocationSettings() async {
    var result = await chatController.goToLocationSettings();
    result.fold((failure) {
      PresentationDialogs.instance.showErrorDialog(
          title: "No se puede acceder a los ajustes de ubicacion",
          content:
              "Debes ir manualmente a los ajustes de localizacion de tu telefono y dar permiso a Hotty",
          context: startKey.currentContext);
    }, (succes) {
      if (succes == true) {
      } else {
        PresentationDialogs.instance.showErrorDialog(
            title: "No se puede acceder a los ajustes de ubicacion",
            content:
                "Debes ir manualmente a los ajustes de localizacion de tu telefono y dar permiso a Hotty",
            context: startKey.currentContext);
      }
    });
  }
}
