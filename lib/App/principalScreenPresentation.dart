import 'package:flutter/widgets.dart';

import 'PrincipalScreenDataNotifier.dart';
import 'Rewards/rewardScreenPresentation/rewardScreenPresentation.dart';




class PrincipalScreenPresentation extends ChangeNotifier {
  PrincipalScreenNotifier reactionScreenPresentation;
  PrincipalScreenNotifier chatPresentation;
  RewardScreenPresentation rewardScreenPresentation;
  int newMessages = 0;
  int newChats = 0;
  int newReactions = 0;
  int coins = 0;
  bool isPremium = false;
  int rewardTicketSuccesfulShares = 0;
  bool promotionalCodePendingOfUse = false;
  bool waitingDailyReward = false;
  bool waitingFirstReward = false;
  PrincipalScreenPresentation(
      {required this.reactionScreenPresentation,
      required this.chatPresentation,
      required this.rewardScreenPresentation}) {
    chatDataUpdate();
    reactionDataUpdate();
    rewardDataUpdate();
  }

  void chatDataUpdate() {
    chatPresentation.principalScreenNotifier?.stream.listen((event) {
      if (event["payload"] == "chatData") {
        newChats = event["newChatsCount"];
        newMessages = event["newMessagesCount"];
        notifyListeners();
      }
    });
  }

  void reactionDataUpdate() {
    reactionScreenPresentation.principalScreenNotifier?.stream.listen((event) {
      if (event["payload"] == "reactionData") {
        newReactions = event["newReactions"];
        coins = event["coins"];
        isPremium = event["isPremium"];
        notifyListeners();
      }
    });
  }

  void rewardDataUpdate() {
    rewardScreenPresentation.principalScreenNotifier?.stream.listen((event) {
      if (event["payload"] == "rewardData") {
        promotionalCodePendingOfUse = event["promotionalCodePendingOfUse"];
        waitingDailyReward = event["waitingDailyReward"];
        rewardTicketSuccesfulShares = event["rewardTicketSuccesfulShares"];
        waitingFirstReward = event["waitingFirstReward"];

        notifyListeners();
      }
    });
  }
}
