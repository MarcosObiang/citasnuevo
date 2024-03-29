import 'dart:async';
import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../globalData.dart';

class PurchasesServices {
  static PurchasesServices purchasesServices = new PurchasesServices();
  Offerings? product;
  Future<void> initService() async {
    try {
      if (Platform.isAndroid) {
        await Purchases.setDebugLogsEnabled(true);
        Purchases.addCustomerInfoUpdateListener((purchaserInfo) {
          print(purchaserInfo);
        });
        await Purchases.setup("goog_gUQRNUmExxIGLyeAlZIQYwLfvSa",
            appUserId: GlobalDataContainer.userId, observerMode: false);
        await getProducts();
      }
    } catch (e) {
     throw e;
    }
  }

  Future<void> getProducts() async {
    try {
      product = await Purchases.getOfferings();
      if (product != null) {
        if (product!.all.isNotEmpty) {
          // Display current offering with offerings.current
        }
      }
    } catch (e) {
      throw e;
    }
  }

  Future<bool> makePurchase({required String offerId}) async {
    try {
      Offering? offering =
          PurchasesServices.purchasesServices.product?.all[offerId];
      await Purchases.invalidateCustomerInfoCache();
      var purchaserData = await Purchases.getCustomerInfo();

      if (offering != null) {
        if (purchaserData.activeSubscriptions.isEmpty) {
          await Purchases.purchasePackage(
            offering.availablePackages.first,
          );
        } else {
          await Purchases.purchasePackage(offering.availablePackages.first,
              upgradeInfo:
                  UpgradeInfo(purchaserData.activeSubscriptions.first));
        }

        return true;
      } else {
        throw Exception(["NO_OFFERINGS_FOUND"]);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
