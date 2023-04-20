import 'package:equatable/equatable.dart';

import '../../core/params_types/params_and_types.dart';

class Rewards extends Equatable {
  ///Every time the user reaches 0 coins, this property will be set up by the backend 24h in the future

  int timeUntilDailyReward;

  /// if the user has the welcoming reward, this is a one time reward and is given to the user after he creates a profile
  bool waitingFirstReward;

  ///When the user invites a new user via the reward link, if the new user verifies his profile this user will habe the rigth to a reward

  bool promotionalCodePendingOfUse;

  ///When the user verification process is succesful, he or she will have the ritgth to a reward

  bool rewardForVerificationRigth;

  ///Link to share with friends to earn extra coins, start value is ["NO_LINK_AVAILABLE"]
  ///
  bool waitingReward;

  bool isPremium;

  int coins;

  String dynamicLink = kNotAvailable;
  String promotionalCodeUsedByUser = kNotAvailable;
  int rewardTicketSuccesfulShares = 0;

  Rewards(
      {required this.isPremium,
      required this.waitingReward,
      required this.dynamicLink,
      required this.timeUntilDailyReward,
      required this.waitingFirstReward,
      required this.promotionalCodePendingOfUse,
      required this.rewardForVerificationRigth,
      required this.promotionalCodeUsedByUser,
      required this.rewardTicketSuccesfulShares,
      required this.coins});

  @override
  // TODO: implement props
  List<Object?> get props => [
        timeUntilDailyReward,
        waitingFirstReward,
        promotionalCodePendingOfUse,
        rewardForVerificationRigth,
        waitingFirstReward,
        isPremium,
        coins,
        dynamicLink,
        promotionalCodeUsedByUser,
        rewardTicketSuccesfulShares
      ];
}
