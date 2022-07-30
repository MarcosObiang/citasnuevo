// ignore_for_file: cancel_subscriptions

import 'dart:async';

import 'package:flutter/cupertino.dart';

abstract class Presentation<T>  {
  /// Must be called when the use case returns a [Failure] type object
  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context});

  ///Must be called when the  function has not finished yet
  void showLoadingDialog();

  void showNetworkErrorDialog({required BuildContext? context});

  ///
  ///
  ///This function is only meant to be called at the start of the app to initialize the [T] module
  void initialize();

  ///This function is only meant to be called when we need to reload an entire module after an error
  ///
  ///or when we swich users to clear the module data and restart [T]

  void restart();


}

abstract class ShouldRemoveData <InformationSender> {
  late StreamSubscription<InformationSender>?  removeDataSubscription;

  /// Holds the controller.remove [StreamSubscription]
  ///
  /// Use the [Stream.listen] to add the remove logic needed

  void removeData();
}

abstract class ShouldUpdateData<InformationSender>  {
  /// Needs to listen to a [Controller.updateData] and implement the presentation logic for updated data
  late StreamSubscription<InformationSender>?  updateSubscription;

  /// Holds the controller.update [StreamSubscription]
  ///
  /// Use the [Stream.listen] to add the update logic needed

  void update();
}

abstract class SouldAddData<InformationSender> {
  /// Needs to listen to a [Controller.addDataController] and implement the presentation logic for new data
  late StreamSubscription<InformationSender>? addDataSubscription;

  /// Holds the controller.remove [StreamSubscription]
  ///
  /// Use the [Stream.listen] to add the add logic needed

  void addData();
}
