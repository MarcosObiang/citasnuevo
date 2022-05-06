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

  void adsServiceInit() async {
    if (adsInitialized == false) {
      bool hasConsent = false;
      bool shoulShowConsentForm = await requestConsentInfoUpdate();

      if (shoulShowConsentForm == true) {
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
      }

      Status consentStatus = await ConsentManager.getConsentStatus();

      if (consentStatus == Status.PERSONALIZED) {
        hasConsent = true;
      }

      Appodeal.setLogLevel(Appodeal.LogLevelDebug);
      Appodeal.setTesting(true);

      if (Platform.isAndroid) {
        await Appodeal.initialize(
            androidAdsId, [Appodeal.REWARDED_VIDEO, Appodeal.INTERSTITIAL],
            boolConsent: hasConsent);
      }

      Appodeal.setUseSafeArea(true);
      Appodeal.muteVideosIfCallsMuted(true);
      Appodeal.setAutoCache(Appodeal.REWARDED_VIDEO, true);
      Appodeal.setAutoCache(Appodeal.INTERSTITIAL, true);
      adsInitialized = true;
    }
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
