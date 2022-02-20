import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:flutter/cupertino.dart';

import 'package:citasnuevo/domain/controller/chatController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';

class ChatPresentation extends ChangeNotifier implements Presentation {
  ChatController chatController;
  ChatPresentation({
    required this.chatController,
  });

  void initializeChatListener() async {
    var result = await chatController.initializeChatListener();
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
