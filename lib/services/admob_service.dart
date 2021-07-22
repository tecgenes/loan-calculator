import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  InterstitialAd? interstitialAd;
  int numOfAttemptLoad = 0;

  static initialize() {
    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();
    }
  }

  static BannerAd createBannerAd() {
    BannerAd ad = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: BannerAd.testAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('ad is loaded'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('Ad is opened'),
        onAdClosed: (Ad ad) => print('Ad is closed'),
      ),
      request: AdRequest(),
    );
    return ad;
  }

  void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: InterstitialAd.testAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
          numOfAttemptLoad = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          numOfAttemptLoad + 1;
          interstitialAd = null;
          if (numOfAttemptLoad <= 2) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
      print('ad on Ad Show Full Screen');
    }, onAdDismissedFullScreenContent: (InterstitialAd ad) {
      print('ad disposed');
      ad.dispose();
    }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      print('$ad On Failed $error');
      ad.dispose();
      createInterstitialAd();
    });
    interstitialAd!.show();
    interstitialAd = null;
  }
}