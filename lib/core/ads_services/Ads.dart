import 'dart:async';
import 'dart:io';

import 'package:citasnuevo/core/common/common_widgets.dart/errorWidget.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class AdvertisingServices {
  String androidAdsId = "b7fe6eeed91b14eb3399851c5a8b3d24eb0755e9a014fda4";
  bool showAds = true;
  bool adsInitialized = false;
  bool hasUserConsent = false;
  bool consentFormShowed = false;

  Future<void> shouldUserGiveCosent() async {
    return requestConsentInfoUpdate();
  }

  void initializeAdsService() async {
    await shouldUserGiveCosent();

    await showConsentForm();

    Appodeal.setUseSafeArea(true);
    Appodeal.muteVideosIfCallsMuted(true);
    Appodeal.setAutoCache(Appodeal.REWARDED_VIDEO, true);
    Appodeal.setAutoCache(Appodeal.INTERSTITIAL, true);
    Appodeal.setChildDirectedTreatment(false);
    Appodeal.disableNetwork("admob");

    Appodeal.setLogLevel(Appodeal.LogLevelDebug);
    Appodeal.setTesting(true);

    if (Platform.isAndroid) {
      await Appodeal.initialize(
        appKey: androidAdsId,
        adTypes: [Appodeal.REWARDED_VIDEO, Appodeal.INTERSTITIAL],
      );
    }

    adsInitialized = true;
  }

  Future<void> showConsentForm() async {
    try {
  
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  StreamController<Map<String, dynamic>>? interstitialAdvertismentStateStream;
  StreamController<Map<String, dynamic>>? rewardedAdvertismentStateStream;

  void closeStream() {
    interstitialAdvertismentStateStream?.close();
    rewardedAdvertismentStateStream?.close();
  }

  Future<void> showInterstitial() async {
    Appodeal.setInterstitialCallbacks(onInterstitialLoaded: (isPrecache) {
      print("onInterstitialLoaded");
    }, onInterstitialFailedToLoad: () {
      print("onInterstitialLoaded");
    }, onInterstitialShown: () {
      if (interstitialAdvertismentStateStream?.isClosed == false) {
        interstitialAdvertismentStateStream?.add({"status": "SHOWING"});
      }

      print("onInterstitialShown");
    }, onInterstitialShowFailed: () {
      print("onInterstitialShowFailed");
      if (interstitialAdvertismentStateStream?.isClosed == false) {
        interstitialAdvertismentStateStream?.add({"status": "FAILED"});
      }
    }, onInterstitialClicked: () {
      print("onInterstitialClicked");
    }, onInterstitialClosed: () {
      print("onInterstitialClosed");
      if (interstitialAdvertismentStateStream?.isClosed == false) {
        interstitialAdvertismentStateStream?.add({"status": "CLOSED"});
      }
    }, onInterstitialExpired: () {
      print("onInterstitialExpired");
      if (interstitialAdvertismentStateStream?.isClosed == false) {
        interstitialAdvertismentStateStream?.add({"status": "EXPIRED"});
      }
    });
    interstitialAdvertismentStateStream = StreamController();
    bool sePuedeMostrar = await Appodeal.canShow(Appodeal.INTERSTITIAL);
    if (sePuedeMostrar == true) {
      await Appodeal.show(Appodeal.INTERSTITIAL);
    } else {
      if (interstitialAdvertismentStateStream?.isClosed == false) {
        interstitialAdvertismentStateStream?.add({"status": "NOT_READY"});
      }
    }
  }

  Future<void> showRewarded() async {
    Appodeal.setRewardedVideoCallbacks(onRewardedVideoLoaded: (isPrecache) {
      print("onRewardedVideoLoaded");
    }, onRewardedVideoFailedToLoad: () {
      print("onRewardedVideoFailedToLoad");
    }, onRewardedVideoShown: () {
      print("onRewardedVideoShown");
    }, onRewardedVideoShowFailed: () {
      print("onRewardedVideoShowFailed");

      rewardedAdvertismentStateStream?.add({"status": "FAILED"});
    }, onRewardedVideoFinished: (amount, reward) {
      print("onRewardedVideoFinished");
    }, onRewardedVideoClosed: (isFinished) {
      if (isFinished == true) {
        rewardedAdvertismentStateStream?.add({"status": "CLOSED"});
      } else {
        rewardedAdvertismentStateStream?.add({"status": "INCOMPLETE"});
      }
      print("onRewardedVideoClosed");
    }, onRewardedVideoExpired: () {
      rewardedAdvertismentStateStream?.add({"status": "FAILED"});

      print("onRewardedVideoExpired");
    }, onRewardedVideoClicked: () {
      print("onRewardedVideoClicked");
    });
    rewardedAdvertismentStateStream = StreamController();
    bool sePuedeMostrar = await Appodeal.canShow(Appodeal.REWARDED_VIDEO);
    if (sePuedeMostrar) {
      await Appodeal.show(Appodeal.REWARDED_VIDEO);
    } else {
      rewardedAdvertismentStateStream?.add({"status": "FAILED"});
    }
  }

  Future<void> requestConsentInfoUpdate() async {
    Appodeal.updateGDPRUserConsent(GDPRUserConsent.NonPersonalized);

// For users is CCPA region
    Appodeal.updateCCPAUserConsent(CCPAUserConsent.OptIn);

    Appodeal.loadConsentForm(
        appKey: androidAdsId, onLoaded: () {}, onLoadFailed: (error) {});
  }
}
