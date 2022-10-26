import 'dart:async';

abstract class StreamParser {
// ignore: close_sinks, unused_field
  late StreamController? streamParserController;
  StreamController? get getStreamParserController;
  // ignore: cancel_subscriptions
  StreamSubscription? streamParserSubscription;


  ///Inside this method occurs any Map to Object transformation needed from incoming data from [DataSource] via streams to a consumeble object to  [Controller]
  ///
  ///Use it only if the controller needs a data stream from the datasource, inside this method any transformation needed occurs
  void parseStreams();
}
