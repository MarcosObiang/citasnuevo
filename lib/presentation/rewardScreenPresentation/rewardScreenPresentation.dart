import 'dart:async';

import 'package:citasnuevo/domain/controller/rewardController.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/common/common_widgets.dart/errorWidget.dart';
import '../../domain/controller/controllerDef.dart';
import '../../domain/repository/DataManager.dart';

class RewardScreenPresentation extends ChangeNotifier
    implements
        ShouldUpdateData<RewardInformationSender>,
        Presentation,
        ModuleCleaner {
  RewardController rewardController;

  RewardScreenPresentation({required this.rewardController});

  @override
  late StreamSubscription<RewardInformationSender> updateSubscription;

  late StreamController<int> dailyRewardTieRemainingStream;

  @override
  void clearModuleData() {
    updateSubscription.cancel();
    dailyRewardTieRemainingStream.close();
  }

  @override
  void initialize() {
  }

  @override
  void initializeModuleData() {
    dailyRewardTieRemainingStream = new StreamController.broadcast();
    update();
  }

  @override
  void restart() {
  }

  @override
  void showErrorDialog(
      {required String title,
      required String content,
      required BuildContext? context}) {
  }

  @override
  void showLoadingDialog() {
  }

  @override
  void showNetworkErrorDialog({required BuildContext? context}) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }

  @override
  void update() {
    updateSubscription =
        rewardController.updateDataController.stream.listen((event) {
      dailyRewardTieRemainingStream.add(event.secondsToDailyReward);
    });
  }
}
