import 'purchaseEntity.dart';


class PurchaseSystemMapper {
  static PurchaseEntity fromMap({required Map<String, dynamic> data}) {
    bool isUserPremium = data["isUserPremium"];
    List<Map<String, dynamic>> productsData = data["productList"];
    String subscriptionId = data["subscriptionId"];
    String subscriptionStatusData = data["subscriptionStatus"];
    int subscriptionExpirationTimestamp =
        data["subscriptionExpirationTimestamp"] ?? 0;
    SubscriptionStaus subscriptionStaus = SubscriptionStaus.NOT_SUBCRIBED;
    List<ProductInfo> subscriptionOfferingsList = [];
    ProductInfo? productInfo;
    late PurchaseEntity purchaseEntity;
    for (var offeringsData in productsData) {
      ProductInfo productInfo = ProductInfo(
        productPriceString: offeringsData["priceString"],
        productPriceNumber: offeringsData["priceNumber"],
        productId: offeringsData["id"],
        productName: offeringsData["name"],
      );

      subscriptionOfferingsList.add(productInfo);
    }
    if (isUserPremium) {
      if (subscriptionStatusData == "SUBSCRIBED") {
        subscriptionStaus = SubscriptionStaus.SUBSCRIBED;
      }
      if (subscriptionStatusData == "CANCELLED") {
        subscriptionStaus = SubscriptionStaus.CANCELLED;
      }
      if (subscriptionStatusData == "NOT_SUBSCRIBED") {
        subscriptionStaus = SubscriptionStaus.NOT_SUBCRIBED;
      }
      if (subscriptionStatusData == "PAYMENT_ISSUES") {
        subscriptionStaus = SubscriptionStaus.PAYMENT_ISSUES;
      }
      for (var productData in subscriptionOfferingsList) {
        if (productData.productId == subscriptionId) {
          productInfo = productData;
        }
      }
    }

    subscriptionOfferingsList.sort(
      (a, b) => a.productPriceNumber.compareTo(b.productPriceNumber),
    );
    purchaseEntity = PurchaseEntity(
        subscriptionStatus: subscriptionStaus,
        isUserPremium: isUserPremium,
        offeringsList: subscriptionOfferingsList,
        subscriptionExpirationTimestamp: subscriptionExpirationTimestamp,
        cheapestProfuct: subscriptionOfferingsList.first);
    purchaseEntity.activeSubscription = productInfo;
    print("stop");
    return purchaseEntity;
  }
}
