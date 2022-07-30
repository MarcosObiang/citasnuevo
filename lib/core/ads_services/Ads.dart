import 'dart:async';
import 'dart:io';

import 'package:citasnuevo/core/common/common_widgets.dart/errorWidget.dart';
import 'package:citasnuevo/main.dart';
import 'package:flutter/material.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class AdvertisingServices {
  String androidAdsId = "b7fe6eeed91b14eb3399851c5a8b3d24eb0755e9a014fda4";
  bool showAds = true;
  bool adsInitialized = false;
  bool hasUserConsent = false;
  bool consentFormShowed = false;

  Future<bool> shouldUserGiveCosent() async {
    return requestConsentInfoUpdate();
  }

  Future<bool> checkConsent() async {
    var consent = await ConsentManager.getConsentStatus();
    if (consent == Status.PERSONALIZED) {
      return true;
    } else {
      return false;
    }
  }

  void initializeAdsService() async {
    bool showDialog = await shouldUserGiveCosent();

    if (showDialog) {
      await showConsentForm(showDialog);
    }

    Appodeal.setLogLevel(Appodeal.LogLevelDebug);
    Appodeal.setTesting(true);

    if (Platform.isAndroid) {
      await Appodeal.initialize(
          androidAdsId, [Appodeal.REWARDED_VIDEO, Appodeal.INTERSTITIAL],
          boolConsent: await checkConsent());
    }

    Appodeal.setUseSafeArea(true);
    Appodeal.muteVideosIfCallsMuted(true);
    Appodeal.setAutoCache(Appodeal.REWARDED_VIDEO, true);
    Appodeal.setAutoCache(Appodeal.INTERSTITIAL, true);
    adsInitialized = true;
  }

  Future<void> showConsentForm(bool shouldShowConsentForm) async {
    if (shouldShowConsentForm == true) {
      try {
        await showDialog(
            context: startKey.currentContext as BuildContext,
            builder: (context) => AdsGenericErrorDialog(
                  title: "Ads",
                  content: "ads consent",
                ));
      } catch (e, s) {
        print(e);
        print(s);
      }

      consentFormShowed = true;
    }
  }

  StreamController<bool>? interstitialAdvertismentStateStream;
  StreamController<bool>? rewardedAdvertismentStateStream;

  void closeStream() {
    interstitialAdvertismentStateStream?.close();
    rewardedAdvertismentStateStream?.close();


  }

  Future<void> showInterstitial() async {
    
      interstitialAdvertismentStateStream = StreamController();
      bool sePuedeMostrar = await Appodeal.canShow(Appodeal.INTERSTITIAL);
      if (sePuedeMostrar == true) {
        await Appodeal.show(Appodeal.INTERSTITIAL);
        Appodeal.setInterstitialCallbacks(onInterstitialLoaded: (isPrecache) {
          print("onInterstitialLoaded");
        }, onInterstitialFailedToLoad: () {
          print("onInterstitialLoaded");
        }, onInterstitialShown: () {
          print("onInterstitialShown");
        }, onInterstitialShowFailed: () {
          print("onInterstitialShowFailed");
          interstitialAdvertismentStateStream?.add(true);
        }, onInterstitialClicked: () {
          print("onInterstitialClicked");
        }, onInterstitialClosed: () {
          print("onInterstitialClosed");
          interstitialAdvertismentStateStream?.add(true);
        }, onInterstitialExpired: () {
          print("onInterstitialExpired");
          interstitialAdvertismentStateStream?.add(true);
        });
      } else {
        interstitialAdvertismentStateStream?.add(true);
      }
    
  }

  Future<void> showRewarded() async {
      rewardedAdvertismentStateStream=StreamController();
    bool sePuedeMostrar = await Appodeal.canShow(Appodeal.REWARDED_VIDEO);
    if (sePuedeMostrar) {
   await Appodeal.show(Appodeal.REWARDED_VIDEO);
      Appodeal.setRewardedVideoCallbacks(
          onRewardedVideoLoaded: (isPrecache) => {},
          onRewardedVideoFailedToLoad: ()  {
              
          },
          onRewardedVideoShown: () => {},
          onRewardedVideoShowFailed: () {
            rewardedAdvertismentStateStream?.add(true);
          },
          onRewardedVideoFinished: (amount, reward) {
            rewardedAdvertismentStateStream?.add(true);
          },
          onRewardedVideoClosed: (isFinished) => {},
          onRewardedVideoExpired: () => {},
          onRewardedVideoClicked: () => {});
    } else {
      rewardedAdvertismentStateStream?.add(true);
    }
    


  }

  Future<bool> requestConsentInfoUpdate() async {
    bool shouldShowGPDRDialog = false;

    await ConsentManager.requestConsentInfoUpdate(androidAdsId);
    Status consentStatus = await ConsentManager.getConsentStatus();
    if (consentStatus == Status.UNKNOWN) {
      ShouldShow shouldShow = await ConsentManager.shouldShowConsentDialog();

      if (shouldShow == ShouldShow.TRUE) {
        await ConsentManager.loadConsentForm();

        shouldShowGPDRDialog = true;
      } else {
        shouldShowGPDRDialog = false;
      }
    } else {
      shouldShowGPDRDialog = false;
    }

    return shouldShowGPDRDialog;
  }
}
