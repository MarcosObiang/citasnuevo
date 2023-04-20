import 'dart:async';

import '../controllerDef.dart';


class ChatToMessagesControllerBridge implements ControllerBridge {
  @override
  StreamController<Map<String, dynamic>>?
      controllerBridgeInformationSenderStream =
      new StreamController();

  @override
  void addInformation({required Map<String, dynamic> information}) {
    if (controllerBridgeInformationSenderStream?.isClosed == false) {
      controllerBridgeInformationSenderStream?.add(information);
    }
  }

  @override
  void reinitializeStream() {
    controllerBridgeInformationSenderStream?.close();
    controllerBridgeInformationSenderStream = new StreamController();
  }
}
