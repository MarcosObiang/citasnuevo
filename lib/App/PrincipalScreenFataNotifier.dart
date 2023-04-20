import 'dart:async';

abstract class PrincipalScreenNotifier{
  late StreamController<Map<String,dynamic>>? principalScreenNotifier;
  void notifyPrincipalScreen();
}