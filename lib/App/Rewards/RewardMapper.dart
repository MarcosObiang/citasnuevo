import 'RewardsEntity.dart';

class RewardMapper{

  static RewardMapper instance= new RewardMapper();

  Rewards fromMap({required Map<String,dynamic> data}){
    
    return new Rewards(
      dynamicLink: data["rewardTicketCode"],
      isPremium: data["isUserPremium"],
      coins: data["userCoins"],
      promotionalCodeUsedByUser:data["promotionalCodeUsedByUser"] ,
      rewardTicketSuccesfulShares:data["rewardTicketSuccesfulShares"] ,
            timeUntilDailyReward: data["nextRewardTimestamp"],
            waitingFirstReward: data["giveFirstReward"],
            promotionalCodePendingOfUse:  data["isUserPromotionalCodeUsed"],
            rewardForVerificationRigth: false,
            waitingReward: data["waitingRewards"]);
  }
}