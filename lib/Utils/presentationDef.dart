// ignore_for_file: cancel_subscriptions

import 'dart:async';

abstract class Presentation {
  /// Restarts the whole module
  ///
  ///  Modules are only initialized when the user logs in, and are cleaned up only when the user logs out
  ///
  /// but there are many cases where we may need to reload the whole module (if any error occcurs while using the app)
  ///
  /// so the restart implementation should call the [clearModuleData] and the [initializeModuleData] (in this order) methods from the absract class [ModuleCleaner]

  void restart();
}

abstract class ShouldRemoveData<InformationSender> {
  late StreamSubscription<InformationSender>? removeDataSubscription;

  /// Holds the controller.remove [StreamSubscription]
  ///
  /// Use the [Stream.listen] to add the remove logic needed

  void removeData();
}

abstract class ShouldUpdateData<InformationSender> {
  /// Needs to listen to a [Controller.updateData] and implement the presentation logic for updated data
  late StreamSubscription<InformationSender>? updateSubscription;

  /// Holds the controller.update [StreamSubscription]
  ///
  /// Use the [Stream.listen] to add the update logic needed

  void update();
}

abstract class ShouldAddData<InformationSender> {
  /// Needs to listen to a [Controller.addDataController] and implement the presentation logic for new data
  late StreamSubscription<InformationSender>? addDataSubscription;

  /// Holds the controller.remove [StreamSubscription]
  ///
  /// Use the [Stream.listen] to add the add logic needed

  void addData();
}
