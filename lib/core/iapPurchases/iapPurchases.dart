import 'dart:async';
import 'dart:io';

import 'package:citasnuevo/core/globalData.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesServices {
  static PurchasesServices purchasesServices = new PurchasesServices();
  late Offerings product;
  Future<void> initService() async {
    if (Platform.isAndroid) {
      await Purchases.setDebugLogsEnabled(true);
       Purchases.addPurchaserInfoUpdateListener((purchaserInfo) {

        print(purchaserInfo);
       });
      await Purchases.setup("goog_gUQRNUmExxIGLyeAlZIQYwLfvSa",
          appUserId: GlobalDataContainer.userId, observerMode: false);
      await getProducts();
    }
  }

  Future<void> getProducts() async {
    try {
      product = await Purchases.getOfferings();
      if (product.all.isNotEmpty) {
        // Display current offering with offerings.current
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<bool> makePurchase({required String offerId}) async {
    try {
      Offering? offering =
          PurchasesServices.purchasesServices.product.all[offerId];
      await Purchases.invalidatePurchaserInfoCache();
      var purchaserData = await Purchases.getPurchaserInfo();

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