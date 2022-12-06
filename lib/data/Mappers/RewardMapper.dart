import 'package:citasnuevo/domain/entities/RewardsEntity.dart';

class RewardMapper{

  static RewardMapper instance= new RewardMapper();

  Rewards fromMap({required Map<String,dynamic> data}){
    
    return new Rewards(
      isPremium: data["isUserPremium"],
      coins: data["userCoins"],
            timeUntilDailyReward: data["nextRewardTimestamp"],
            waitingFirstReward: data["giveFirstReward"],
            rewardForShareRigth: false,
            rewardForVerificationRigth: false,
            waitingReward: data["waitingReward"]);
  }
}