enum SubscriptionStaus {
  NOT_SUBCRIBED,
  SUBSCRIBED,
  PAUSED,
  CANCELLED,
  PAYMENT_ISSUES
}



class PurchaseEntity {
  bool isUserPremium;
  List<ProductInfo> offeringsList;
  ProductInfo cheapestProfuct;
  SubscriptionStaus subscriptionStatus;
  ProductInfo? activeSubscription;
  int subscriptionExpirationTimestamp;
  PurchaseEntity({
    required this.isUserPremium,
    required this.offeringsList,
    required this.cheapestProfuct,
    required this.subscriptionStatus,
    required this.subscriptionExpirationTimestamp,
  });
}

class ProductInfo {
  String productName;
  String productId;
  String productPriceString;
  double productPriceNumber;
  double? introductoryPrice;
  String? introductoryPriceString;

  ProductInfo({
      required this.productId,
      required this.productName,
      required this.productPriceString,
      required this.productPriceNumber});
}
