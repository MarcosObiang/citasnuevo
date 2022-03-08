import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:flutter/cupertino.dart';

abstract class Presentation<T> implements DataManager {
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
  ///or when we swich users to clear the module data an restart [T]

  void restart();
}
