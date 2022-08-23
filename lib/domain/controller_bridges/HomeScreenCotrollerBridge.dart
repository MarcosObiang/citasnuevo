import 'dart:async';

import '../controller/controllerDef.dart';

class HomeScreenControllerBridge<HomeScreenController>
    implements
 
        ControllerBridge {
  @override
   StreamController<Map<String, dynamic>>?
      controllerBridgeInformationSenderStream;

  @override
  void addInformation({required Map<String, dynamic> information}) {
    if(controllerBridgeInformationSenderStream?.isClosed==false){
    controllerBridgeInformationSenderStream?.add(information);

    }
  }



  @override
  void closeStream() {
    controllerBridgeInformationSenderStream?.close();
  }

  @override
  void initializeStream() {
    controllerBridgeInformationSenderStream = new StreamController.broadcast();
  }
}
