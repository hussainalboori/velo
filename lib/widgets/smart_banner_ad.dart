import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';

class SmartBannerAd extends StatefulWidget {
  const SmartBannerAd({super.key});

  @override
  State<SmartBannerAd> createState() => _SmartBannerAdState();
}

class _SmartBannerAdState extends State<SmartBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // Ad Unit ID pulled dynamically based on OS platform via EnvConfig
  final String adUnitId = EnvConfig.adMobBannerId;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!AppConstants.showAds) return;
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Ad loaded: $ad');
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConstants.showAds) {
      return const SizedBox.shrink();
    }

    if (_isLoaded && _bannerAd != null) {
      return Container(
        padding: const EdgeInsets.only(top: 8),
        color: const Color(0xFF0A0A0A), // Matches Velo Midnight Carbon theme
        child: SafeArea(
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
