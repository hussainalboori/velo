import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';

class RewardedAdManager {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isShowing = false;

  // Ad Unit ID pulled dynamically based on OS platform via EnvConfig
  final String adUnitId = EnvConfig.adMobRewardedId;

  void loadAd() {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('RewardedAd loaded.');
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  void showAd({
    required VoidCallback onReward,
    required VoidCallback onClosed,
  }) {
    if (_rewardedAd == null || !_isAdLoaded || _isShowing) {
      debugPrint('Warning: attempt to show rewarded ad before loaded.');
      // If ad isn't loaded, invoke onClosed instantly so the UI isn't blocked.
      onClosed();
      return;
    }

    _isShowing = true;
    
    // Set up full screen callbacks. We invoke onClosed exactly once.
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => debugPrint('Ad showed fullscreen content.'),
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Ad dismissed fullscreen content.');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        _isShowing = false;
        onClosed();
        loadAd(); // Preload next one just in case
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Ad failed to show fullscreen content: $error');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        _isShowing = false;
        onClosed();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        debugPrint('Reward earned.');
        onReward();
      },
    );
  }
}
