import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:citasnuevo/Utils/dialogs.dart';
import 'package:citasnuevo/Utils/presentationDef.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../globalData.dart';

class AdvertisingServices {
  String androidAdsId = "b7fe6eeed91b14eb3399851c5a8b3d24eb0755e9a014fda4";
  bool showAds = true;
  bool adsInitialized = false;
  bool hasUserConsent = false;
  bool consentFormShowed = false;
  late StreamController<Map<String, dynamic>>
      interstitialAdvertismentStateStream;
  late StreamController<Map<String, dynamic>> rewardedAdvertismentStateStream;

  void consentFormShowedToUser() {
    consentFormShowed =
        Dependencies.applicationDataSource.getData["adConsentFormShown"];
  }

  void userConsentValue() {
    hasUserConsent =
        Dependencies.applicationDataSource.getData["showPersonalizedAds"];
  }

  void initializeAdsService() async {
    consentFormShowedToUser();
    userConsentValue();
    if (consentFormShowed == true) {
      Appodeal.setUseSafeArea(true);
      Appodeal.muteVideosIfCallsMuted(true);
      Appodeal.setAutoCache(Appodeal.REWARDED_VIDEO, true);
      Appodeal.setAutoCache(Appodeal.MREC, true);

      Appodeal.setAutoCache(Appodeal.INTERSTITIAL, true);
      Appodeal.setChildDirectedTreatment(false);
      Appodeal.disableNetwork("admob");

      Appodeal.setLogLevel(Appodeal.LogLevelDebug);
      Appodeal.setTesting(true);
      if (hasUserConsent == true) {
        Appodeal.updateGDPRUserConsent(GDPRUserConsent.Personalized);
        Appodeal.updateCCPAUserConsent(CCPAUserConsent.OptIn);
      } else {
        Appodeal.updateGDPRUserConsent(GDPRUserConsent.NonPersonalized);
        Appodeal.updateCCPAUserConsent(CCPAUserConsent.OptOut);
      }

      if (Platform.isAndroid) {
        await Appodeal.initialize(
          appKey: androidAdsId,
          adTypes: [
            Appodeal.REWARDED_VIDEO,
            Appodeal.INTERSTITIAL,
          ],
        );
      }
    } else {
      PresentationDialogs.instance.showAdConsentDialog();
    }

    adsInitialized = true;
  }

  void closeStream() {
    interstitialAdvertismentStateStream.close();
    rewardedAdvertismentStateStream.close();
  }

  Future<bool> showInterstitial() async {
    Appodeal.setInterstitialCallbacks(onInterstitialLoaded: (isPrecache) {
      print("onInterstitialLoaded");
    }, onInterstitialFailedToLoad: () {
      print("onInterstitialLoaded");
    }, onInterstitialShown: () {
      if (interstitialAdvertismentStateStream.isClosed == false) {
        interstitialAdvertismentStateStream.add({"status": "SHOWING"});
      }

      print("onInterstitialShown");
    }, onInterstitialShowFailed: () {
      print("onInterstitialShowFailed");
      if (interstitialAdvertismentStateStream.isClosed == false) {
        interstitialAdvertismentStateStream.add({"status": "FAILED"});
      }
    }, onInterstitialClicked: () {
      print("onInterstitialClicked");
    }, onInterstitialClosed: () {
      print("onInterstitialClosed");
      if (interstitialAdvertismentStateStream.isClosed == false) {
        interstitialAdvertismentStateStream.add({"status": "CLOSED"});
      }
    }, onInterstitialExpired: () {
      print("onInterstitialExpired");
      if (interstitialAdvertismentStateStream.isClosed == false) {
        interstitialAdvertismentStateStream.add({"status": "EXPIRED"});
      }
    });
    interstitialAdvertismentStateStream = StreamController();
    bool sePuedeMostrar = await Appodeal.canShow(Appodeal.INTERSTITIAL);
    if (sePuedeMostrar == true) {
      await Appodeal.show(Appodeal.INTERSTITIAL);
    } else {
      if (interstitialAdvertismentStateStream.isClosed == false) {
        interstitialAdvertismentStateStream.add({"status": "NOT_READY"});
      }
    }
    return true;
  }

  Future<bool> showRewarded() async {
    Appodeal.setRewardedVideoCallbacks(onRewardedVideoLoaded: (isPrecache) {
      print("onRewardedVideoLoaded");
    }, onRewardedVideoFailedToLoad: () {
      print("onRewardedVideoFailedToLoad");
    }, onRewardedVideoShown: () {
      print("onRewardedVideoShown");
    }, onRewardedVideoShowFailed: () {
      print("onRewardedVideoShowFailed");

      rewardedAdvertismentStateStream.add({"status": "FAILED"});
    }, onRewardedVideoFinished: (amount, reward) {
      print("onRewardedVideoFinished");
    }, onRewardedVideoClosed: (isFinished) {
      if (isFinished == true) {
        rewardedAdvertismentStateStream.add({"status": "CLOSED"});
      } else {
        rewardedAdvertismentStateStream.add({"status": "INCOMPLETE"});
      }
      print("onRewardedVideoClosed");
    }, onRewardedVideoExpired: () {
      rewardedAdvertismentStateStream.add({"status": "FAILED"});

      print("onRewardedVideoExpired");
    }, onRewardedVideoClicked: () {
      print("onRewardedVideoClicked");
    });
    rewardedAdvertismentStateStream = StreamController();
    bool sePuedeMostrar = await Appodeal.canShow(Appodeal.REWARDED_VIDEO);
    if (sePuedeMostrar) {
      await Appodeal.show(Appodeal.REWARDED_VIDEO);
    } else {
      rewardedAdvertismentStateStream.add({"status": "FAILED"});
    }

    return true;
  }

  Future<bool> setConsentStatus({required bool consentPersonalizedAds}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Functions functions = Functions(Dependencies.serverAPi.client!);

        Execution execution = await functions.createExecution(
            functionId: "setAdConsentStatus",
            data: jsonEncode({
              "userHasGivenConsent": consentPersonalizedAds,
              "userId": GlobalDataContainer.userId
            }));

        int status = jsonDecode(execution.response)["status"];
        if (status != 200) {
          return false;
        } else {
          await Future.delayed(Duration(seconds: 4));

          return true;
        }
      } catch (e) {
        throw Exception(
          e.toString(),
        );
      }
    } else {
      return false;
    }
  }
}
