import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../DataManager.dart';
import '../../../Utils/presentationDef.dart';
import '../../../core/params_types/params_and_types.dart';
import '../../../main.dart';
import '../VerificationTicketEntity.dart';
import '../verificationController.dart';
import 'verificationScreen.dart';

enum VerificationScreenState {
  LOADING,
  REVIEW_NOT_STARTED,
  ERROR,
  REVIEW_ERROR,
  REVIEW_SUCCESFULL,
  REVIEW_IN_PROCESS
}

enum VerificationGestureLoadingState { ERROR, LOADING, LOADED, NOT_LOADED }

class VerificationPresentation extends ChangeNotifier
    implements ShouldUpdateData, ModuleCleanerPresentation {
  List<String> gesturesList = [
    "thumbs_up_gesture",
    "victory_gesture",
    "thumbs_down_gesture",
    "raised_hand_gesture",
    "pinching_hand_gesture",
    "ok_gesture",
    "raised_punch_gesture"
  ];
  @override
  StreamSubscription? updateSubscription;
  VerificationScreenState _verificationScreenState =
      VerificationScreenState.LOADING;
  VerificationGestureLoadingState _verificationGestureLoadingState =
      VerificationGestureLoadingState.LOADING;
  VerificationController verificationController;
  VerificationPresentation({
    required this.verificationController,
  });

  set setVerificationScreenState(
      VerificationScreenState verificationScreenState) {
    this._verificationScreenState = verificationScreenState;
    notifyListeners();
  }

  set setVerificationGestureLoadingState(
      VerificationGestureLoadingState verificationGestureLoadingState) {
    this._verificationGestureLoadingState = verificationGestureLoadingState;
    notifyListeners();
  }

  VerificationGestureLoadingState get getVerificationGestureLoadingState =>
      this._verificationGestureLoadingState;

  VerificationScreenState get getVerificationScreenState =>
      this._verificationScreenState;

  @override
  void clearModuleData() {
    updateSubscription?.cancel();
    updateSubscription = null;
    _verificationScreenState = VerificationScreenState.LOADING;
    setVerificationGestureLoadingState=VerificationGestureLoadingState.LOADING;

    verificationController.clearModuleData();
  }

  @override
  void initializeModuleData() {
    update();
    verificationController.initializeModuleData();
  }

  void requestNewVerificationProcess() async {
    setVerificationGestureLoadingState =
        VerificationGestureLoadingState.LOADING;

    var result = await verificationController.requestNewVerificationProcess();

    result.fold((l) {
      setVerificationGestureLoadingState =
          VerificationGestureLoadingState.ERROR;
    }, (r) => null);
  }

  void setUserVerificationPicture({required Uint8List byteData}) async {
    setVerificationGestureLoadingState =
        VerificationGestureLoadingState.LOADING;

    var result = await verificationController.submitVerificationPicture(
        byteData: byteData);

    result.fold((l) {
      setVerificationGestureLoadingState =
          VerificationGestureLoadingState.ERROR;
    }, (r) => null);
  }

  @override
  void update() {
    updateSubscription =
        verificationController.updateDataController?.stream.listen((event) {
      if (event is VerificationTicketEntity) {
        VerificationTicketEntity verificationTicketEntity = event;

        if (gesturesList.contains(verificationTicketEntity.handGesture) ==
            false) {
          setVerificationGestureLoadingState =
              VerificationGestureLoadingState.NOT_LOADED;
        }
        if (gesturesList.contains(verificationTicketEntity.handGesture) ==
            true) {
          setVerificationGestureLoadingState =
              VerificationGestureLoadingState.LOADED;
        }

        if (verificationTicketEntity.verificationProcessStatus ==
                VerificationProcessStatus.VERIFICATION_NOT_INITIALIZED ||
            verificationTicketEntity.verificationProcessStatus ==
                VerificationProcessStatus.VERIFICATION_INITIALIZED) {
          setVerificationScreenState =
              VerificationScreenState.REVIEW_NOT_STARTED;
          if (verificationScreenKey.currentContext == null) {
            /*  Navigator.pushNamed(startKey.currentContext as BuildContext,
                VerificationScreen.routeName);*/
          }
        }
        if (verificationTicketEntity.verificationProcessStatus ==
            VerificationProcessStatus.VERIFICATION_WAITING_MODERATION) {
          setVerificationScreenState =
              VerificationScreenState.REVIEW_IN_PROCESS;
        }
        if (verificationTicketEntity.verificationProcessStatus ==
            VerificationProcessStatus.VERIFICATION_NOT_SUCCESFULL) {
          setVerificationScreenState = VerificationScreenState.REVIEW_ERROR;
          if (verificationScreenKey.currentContext == null) {
            /*   Navigator.pushNamed(startKey.currentContext as BuildContext,
                VerificationScreen.routeName);*/
          }
        }
        if (verificationTicketEntity.verificationProcessStatus ==
            VerificationProcessStatus.VERIFICATION_SUCCESFULL) {
          setVerificationScreenState =
              VerificationScreenState.REVIEW_SUCCESFULL;
        }
      }
    });
  }
}
