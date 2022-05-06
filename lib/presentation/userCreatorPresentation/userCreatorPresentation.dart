import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/controller/userCreatorController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:flutter/widgets.dart';

import '../../domain/repository/DataManager.dart';

enum UserCreatorScreenState { LOADING, READY, ERROR }

class UserCreatorPresentation extends ChangeNotifier
    implements
        ShouldUpdateData<UserCreatorInformationSender>,
        Presentation,
        ModuleCleaner {
  @override
  late StreamSubscription<UserCreatorInformationSender> updateSubscription;
  UserCreatorController userCreatorController;
  UserCreatorScreenState _userCreatorScreenState =
      UserCreatorScreenState.LOADING;

  set setUserCreatorScreenState(UserCreatorScreenState userCreatorScreenState) {
    this._userCreatorScreenState = userCreatorScreenState;
    notifyListeners();
  }

 UserCreatorScreenState get  getUserCreatorScreenState=>this._userCreatorScreenState;

  UserCreatorPresentation({required this.userCreatorController});

  @override
  void clearModuleData() {
    updateSubscription.cancel();
  }

  @override
  void initialize() {
    update();
  }

  @override
  void initializeModuleData() {
    userCreatorController.initializeModuleData();
    initialize();
  }

  void addPicture({required Uint8List imageData, required int index}) {
    userCreatorController.insertImageFile(imageData, index);
    notifyListeners();
  }

  void deletePircture(int index) {
    userCreatorController.deleteImage(index);
    notifyListeners();
  }

  @override
  void restart() {
    // TODO: implement restart
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

  void addDate({required DateTime dateTime})async{
  await  userCreatorController.userCreatorEntity.addUserDate(dateTime: dateTime);
  notifyListeners();
  }

  @override
  void update() {
    updateSubscription =
        userCreatorController.getDataStream.stream.listen((event) {
          setUserCreatorScreenState=UserCreatorScreenState.READY;
      notifyListeners();
    });
  }
}
