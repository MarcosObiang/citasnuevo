import 'dart:async';
import 'dart:io';

import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class AdvertisingServices {
  String androidAdsId = "b7fe6eeed91b14eb3399851c5a8b3d24eb0755e9a014fda4";
  bool showAds = true;

  void adsServiceInit() async {
    Appodeal.setLogLevel(Appodeal.LogLevelDebug);
    Appodeal.setTesting(false);
    if (Platform.isAndroid) {
      await Appodeal.initialize(androidAdsId,
          [Appodeal.REWARDED_VIDEO, Appodeal.INTERSTITIAL, Appodeal.BANNER],
          boolConsent: false);
    }

   await  requestConsentInfoUpdate();

    Appodeal.setUseSafeArea(true);
    Appodeal.muteVideosIfCallsMuted(true);
    Appodeal.setAutoCache(Appodeal.REWARDED_VIDEO, true);
    Appodeal.setAutoCache(Appodeal.INTERSTITIAL, true);
    Appodeal.setAutoCache(Appodeal.BANNER, true);
  }

  StreamController<bool> advertismentStateStream =
      new StreamController.broadcast();

  void closeStream() {
    advertismentStateStream.close();
  }

  Future<bool> showInterstitial() async {
    bool sePuedeMostrar = await Appodeal.canShow(Appodeal.INTERSTITIAL);
    bool anuncioEnCurso = false;
    if (sePuedeMostrar) {
      anuncioEnCurso = await Appodeal.show(Appodeal.INTERSTITIAL);
    } else {}

    Appodeal.setInterstitialCallbacks(onInterstitialLoaded: (isPrecache) {
      print("onInterstitialLoaded");
    }, onInterstitialFailedToLoad: () {
      print("onInterstitialFailedToLoad");
    }, onInterstitialShown: () {
      print("onInterstitialShown");
    }, onInterstitialShowFailed: () {
      print("onInterstitialShowFailed");
    }, onInterstitialClicked: () {
      print("onInterstitialClicked");
    }, onInterstitialClosed: () {
      print("onInterstitialClosed");
      advertismentStateStream.add(true);
    }, onInterstitialExpired: () {
      print("onInterstitialExpired");
    });

    return anuncioEnCurso;
  }

 Future <void> requestConsentInfoUpdate() async {
    if (Platform.isAndroid) {
      await ConsentManager.requestConsentInfoUpdate(androidAdsId);
      Status consentStatus = await ConsentManager.getConsentStatus();
      if (consentStatus == Status.UNKNOWN) {
        ShouldShow shouldShow = await ConsentManager.shouldShowConsentDialog();

        if (shouldShow == ShouldShow.TRUE) {
           ConsentManager.loadConsentForm();
          bool isLoaded = await ConsentManager.consentFormIsLoaded();
          if (isLoaded) {
         await   ConsentManager.showAsActivityConsentForm();
          }
        }
      }

      ConsentManager.setConsentInfoUpdateListener(
          (onConsentInfoUpdated, consent) {
      }, (onFailedToUpdateConsentInfo, error) => {});
    }
  }
}
