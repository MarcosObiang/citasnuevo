import 'dart:async';

import 'package:citasnuevo/App/controllerDef.dart';

class BridgeFromPurchaseSystemToRewardSystem implements ControllerBridge{
  @override
  StreamController<Map<String, dynamic>>? controllerBridgeInformationSenderStream;

  @override
  void addInformation({required Map<String, dynamic> information}) {
    // TODO: implement addInformation
  }

  @override
  void reinitializeStream() {
    // TODO: implement reinitializeStream
  }
  
}