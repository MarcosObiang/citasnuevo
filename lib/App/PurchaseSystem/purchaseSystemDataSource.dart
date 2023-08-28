import 'dart:async';
import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/dependencies/dependencyCreator.dart';
import '../MainDatasource/principalDataSource.dart';
import '../../../core/globalData.dart';
import '../DataManager.dart';
import '../../core/error/Exceptions.dart';
import '../../core/platform/networkInfo.dart';

abstract class PurchaseSystemDataSource
    implements DataSource, ModuleCleanerDataSource {
  late Offerings product;
  late bool userIsAlreadyPremium;
  // ignore: close_sinks
  StreamController<Map<String, dynamic>>? purchaseSystemStream;

  Future<bool> makePurchase({required String offerId});
  Future<void> openSubscriptionMenu();
  Future<bool> restorePurchases();
}

class PurchaseSystemDataSourceImplementation extends PurchaseSystemDataSource {
  @override
  ApplicationDataSource source;
  @override
  StreamSubscription? sourceStreamSubscription;
  @override
  bool userIsAlreadyPremium = false;
  StreamController<Map<String, dynamic>>? purchaseSystemStream =
      StreamController();
  String androidApiKey = "goog_gUQRNUmExxIGLyeAlZIQYwLfvSa";
  PurchaseSystemDataSourceImplementation({
    required this.source,
  });

  @override
  void clearModuleData() {
    try {
      purchaseSystemStream?.close();
      purchaseSystemStream = null;
      purchaseSystemStream = StreamController();
      sourceStreamSubscription?.cancel();
      sourceStreamSubscription = null;
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  void initializeModuleData() async {
    try {
      await initService();

      subscribeToMainDataSource();
    } catch (e) {
      throw ModuleInitializeException(message: e.toString());
    }
  }

  Future<void> initService() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        PurchasesConfiguration purchasesConfiguration =
            PurchasesConfiguration(androidApiKey);
        purchasesConfiguration.appUserID = GlobalDataContainer.userId;
        if (Platform.isAndroid) {
          await Purchases.setLogLevel(LogLevel.debug);
          Purchases.addCustomerInfoUpdateListener((purchaserInfo) {
            print(purchaserInfo);
          });
          await Purchases.configure(purchasesConfiguration);
          await getProducts();
          sendData();
        }
      } catch (e) {
        throw PurchaseSystemException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  Future<void> getProducts() async {
    try {
      product = await Purchases.getOfferings();
      if (product.all.isNotEmpty) {
        // Display current offering with offerings.current
      }
    } catch (e) {
      throw PurchaseSystemException(message: e.toString());
    }
  }

  @override
  Future<bool> makePurchase({required String offerId}) async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        List<Package>? packageList = product.current?.availablePackages;
        Package? packageData;
        if (packageList != null) {
          for (var data in packageList) {
            if (data.storeProduct.identifier == offerId) {
              packageData = data;
            }
          }
          if (packageData != null) {
            await Purchases.invalidateCustomerInfoCache();
            var purchaserData = await Purchases.getCustomerInfo();
            if (purchaserData.activeSubscriptions.isEmpty) {
              await Purchases.purchasePackage(
                packageData,
              );
            } else {
              await Purchases.purchasePackage(packageData,
                  upgradeInfo:
                      UpgradeInfo(purchaserData.activeSubscriptions.first));
            }
          }

          return true;
        } else {
          throw PurchaseSystemException(message: "NO_OFFERINGS_FOUND");
        }
      } catch (e) {
        throw PurchaseSystemException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  List<Map<String, dynamic>> processOfferings({required Offerings offerings}) {
    List<Map<String, dynamic>> result = [];
    // log(offerings.toJson().toString());

    offerings.current?.availablePackages.forEach((package) {
      result.add({
        "id": package.storeProduct.identifier,
        "name": package.packageType.name,
        "priceString": package.storeProduct.priceString,
        "priceNumber": package.storeProduct.price,
        "introductoryPriceString":
            package.storeProduct.introductoryPrice?.priceString,
        "introductoryPrice": package.storeProduct.introductoryPrice?.price,
        "identifier": package.storeProduct.identifier
      });
    });

    return result;
  }

  void sendData() {
    if (product != null) {
      purchaseSystemStream?.add({
        "payloadType": "purchaseSystemEvent",
        "isUserPremium": userIsAlreadyPremium,
        "subscriptionStatus": source.getData["subscriptionStatus"],
        "subscriptionId": source.getData["subscriptionId"],
        "subscriptionExpirationTimestamp":
            source.getData["subscriptionExpirationTimestamp"],
        "productList": processOfferings(offerings: product)
      });
    } else {
      purchaseSystemStream?.addError("No_products_found");
    }
  }

  @override
  void subscribeToMainDataSource() {
    sourceStreamSubscription = source.dataStream?.stream.listen((event) {
      userIsAlreadyPremium = event["isUserPremium"];
      if (product != null) {
        purchaseSystemStream?.add({
          "payloadType": "purchaseSystemEvent",
          "subscriptionStatus": event["subscriptionStatus"],
          "subscriptionId": event["subscriptionId"],
          "isUserPremium": userIsAlreadyPremium,
          "subscriptionExpirationTimestamp":
              event["subscriptionExpirationTimestamp"],
          "productList": processOfferings(offerings: product)
        });
      } else {
        purchaseSystemStream?.addError("No_products_found");
      }
    }, onError: (e) {
      purchaseSystemStream?.addError(e);
    });
  }

  @override
  Future<void> openSubscriptionMenu() async {
    if (Platform.isAndroid) {
      launchUrl(
          Uri.parse(
              'https://play.google.com/store/account/subscriptions?&package=com.hotty.citas'),
          mode: LaunchMode.externalApplication);
    }
    if (Platform.isIOS) {
      launchUrl(Uri.parse("https://apps.apple.com/account/subscriptions"));
    }
  }

  @override
  Future<bool> restorePurchases() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        CustomerInfo customerInfo = await Purchases.restorePurchases();
        print(customerInfo);

        return true;
      } catch (e) {
        throw PurchaseSystemException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }
}
