import 'package:citasnuevo/core/iapPurchases/iapPurchases.dart';
import 'package:citasnuevo/domain/entities/SettingsEntity.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';

class SettingsMapper {
  static SettingsEntity fromMap(Map<String, dynamic> latestSettings) {
    List<ProductInfo> productInfoList = [];
    PurchasesServices.purchasesServices.product!.all
        .forEach((String key, Offering offering) {
      String subscriptionId = "latestSettings";
      String paymentState = "latestSettings";
      SubscriptionState subscriptionState = SubscriptionState.NOT_SUBSCRIBED;
      bool activeSubscription = false;
      int subscriptionExpirationTime = 0;
      int pausedAutoRenewalTime = 0;

      if (offering.availablePackages.first.identifier ==
          subscriptionId) {
        subscriptionExpirationTime =
            0;
        activeSubscription = true;
        if (paymentState == "ACTIVA") {
          subscriptionState = SubscriptionState.ACTIVE;
        }
        if (paymentState == "CANCELADA") {
          subscriptionState = SubscriptionState.CANCELED;
        }
        if (paymentState == "PROBLEMA_PAGO") {
          subscriptionState = SubscriptionState.ISSUES;
        }
        if (paymentState == "PAUSADA") {
          subscriptionState = SubscriptionState.PAUSED;
          pausedAutoRenewalTime = latestSettings["pausedModeExpirationTime"];
        }
      }

      productInfoList.add(ProductInfo(
          pausedStateExpirationTime: pausedAutoRenewalTime,
          subscriptionExpireTime: subscriptionExpirationTime,
          subscriptionState: subscriptionState,
          productName: offering.identifier,
          productPrice: offering.availablePackages.first.storeProduct.priceString,
          productCurrency:
              offering.availablePackages.first.storeProduct.currencyCode,
          productIsActive: activeSubscription,
          offerId: key,
          productId: offering.availablePackages.first.storeProduct.identifier));
    });

    SettingsEntity settingsEntity = SettingsEntity(
        userName: latestSettings["name"],
        userPicture: latestSettings["userPicture1"]["imageId"],
        userPictureHash: latestSettings["userPicture1"]["hash"],
        userAge: latestSettings["age"],
        weekSubscription: productInfoList.first,
        productInfoList: productInfoList,
        isPremium: latestSettings["isPremium"]);


    for (int i = 0; i < productInfoList.length; i++) {
      if (productInfoList[i].productIsActive == true) {
        settingsEntity.activeSubscription = productInfoList[i];
      }
    }

    return settingsEntity;
  }
}
