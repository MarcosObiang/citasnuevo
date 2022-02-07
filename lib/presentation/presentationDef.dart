import 'package:flutter/cupertino.dart';

abstract class Presentation{
/// Must be called when the use case returns a [Failure] type object
void showErrorDialog({required String errorLog,required String errorName,required BuildContext context});
///Must be called when the [UseCase.call()] function has not finished yet
void showLoadingDialog();}