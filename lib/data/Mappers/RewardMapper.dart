import 'package:citasnuevo/domain/entities/RewardsEntity.dart';

class RewardMapper{

  static RewardMapper instance= new RewardMapper();

  Rewards fromMap({required Map<String,dynamic> data}){
    
    return new Rewards(
      isPremium: data["monedasInfinitas"],
      coins: data["creditos"],
            timeUntilDailyReward: data["siguienteRecompensa"],
            waitingFirstReward: data["primeraRecompensa"],
            rewardForShareRigth: false,
            rewardForVerificationRigth: false,
            waitingReward: data["esperandoRecompensa"]);
  }
}