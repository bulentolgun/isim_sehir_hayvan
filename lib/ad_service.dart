import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._init();
  AdService._init();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1815802672526148/6431616325';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Desteklenmeyen platform');
  }

  String get mediumRectangleAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1815802672526148/4022103076';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Desteklenmeyen platform');
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1815802672526148/2648283988';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4452514319';
    }
    throw UnsupportedError('Desteklenmeyen platform');
  }

  void loadInterstitialAd() {
    if (_interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  // 🎯 6 SANİYE EMNİYET KONTROLLÜ GEÇİŞ REKLAMI
  void showEmniyetliGecisReklami({required Function onReklamBitti}) {
    if (_interstitialAd == null) {
      onReklamBitti();
      loadInterstitialAd();
      return;
    }

    bool akisTetiklendiMi = false;
    Timer? emniyetTimer;

    void tetikleVeTemizle() {
      if (!akisTetiklendiMi) {
        akisTetiklendiMi = true;
        emniyetTimer?.cancel();
        _interstitialAd?.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onReklamBitti();
      }
    }

    // 🚨 MAX 6 SANİYE EMNİYET SAYACI
    emniyetTimer = Timer(const Duration(seconds: 6), () {
      tetikleVeTemizle();
    });

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        tetikleVeTemizle();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        tetikleVeTemizle();
      },
    );

    _interstitialAd!.show();
  }

  BannerAd createBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );
  }

  BannerAd createMediumRectangleAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: mediumRectangleAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );
  }
}

// 🎯 KESİNTİSİZ, EKRAN GENİŞLİĞİNİ %100 KAPLAYAN ŞIK BANNER WIDGET'I
class BottomBannerAdWidget extends StatefulWidget {
  const BottomBannerAdWidget({super.key});

  @override
  State<BottomBannerAdWidget> createState() => _BottomBannerAdWidgetState();
}

class _BottomBannerAdWidgetState extends State<BottomBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdService.instance.createBannerAd(
      onAdLoaded: () {
        if (mounted) setState(() => _isAdLoaded = true);
      },
      onAdFailedToLoad: (error) {},
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0 || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity, // 🎯 Ekran kenarlarına sıfırlanıp bütünlük sağlar
      height: _bannerAd!.size.height.toDouble() + 6,
      decoration: BoxDecoration(
        color: Colors.black, // 🎯 Şık ve göz yormayan siyah zemin
        border: Border(
          top: BorderSide(
            color: Colors.purple.shade200.withOpacity(0.3), // İnce estetik geçiş çizgisi
            width: 1,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

class MediumRectangleAdWidget extends StatefulWidget {
  const MediumRectangleAdWidget({super.key});

  @override
  State<MediumRectangleAdWidget> createState() => _MediumRectangleAdWidgetState();
}

class _MediumRectangleAdWidgetState extends State<MediumRectangleAdWidget> {
  BannerAd? _mediumAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _mediumAd = AdService.instance.createMediumRectangleAd(
      onAdLoaded: () {
        if (mounted) setState(() => _isAdLoaded = true);
      },
      onAdFailedToLoad: (error) {},
    );
    _mediumAd?.load();
  }

  @override
  void dispose() {
    _mediumAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _mediumAd == null) {
      return Container(
        width: 300,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.purple.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.shade400, width: 1),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      width: 300,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AdWidget(ad: _mediumAd!),
      ),
    );
  }
}