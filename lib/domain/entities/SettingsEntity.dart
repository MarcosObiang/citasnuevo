class SettingsEntity {
  String userName;
  String userPicture;
  String userPictureHash;
  int userAge;
  bool isPremium;
  List<ProductInfo> productInfoList;
  ProductInfo weekSubscription;
  ProductInfo? activeSubscription;

  SettingsEntity(
      {required this.userName,
      required this.userPicture,
      required this.userPictureHash,
      required this.userAge,
      required this.isPremium,
      required this.productInfoList,
      required this.weekSubscription});
}

enum SubscriptionState { ACTIVE, PAUSED, NOT_SUBSCRIBED, CANCELED, ISSUES }

class ProductInfo {
  String productName;
  String offerId;
  String productId;
  String productPrice;
  String productCurrency;
  int subscriptionExpireTime;
  bool productIsActive;
  int pausedStateExpirationTime;
  SubscriptionState subscriptionState;
  ProductInfo(
      {required this.offerId,
      required this.pausedStateExpirationTime,
      required this.productId,
      required this.productName,
      required this.productPrice,
      required this.productCurrency,
      required this.productIsActive,
      required this.subscriptionState,
      required this.subscriptionExpireTime});
}
