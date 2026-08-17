import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Web çökmesini önlemek için eklendi
import 'package:app_tracking_transparency/app_tracking_transparency.dart'; // 🔴 EKLENDİ: Apple İzin Paketi

// ==========================================
// ==========================================
// BÖLÜM 1: Temel Kurulum, Reklam Kimlikleri ve İzinler
// ==========================================
class AdService {
  static final AdService instance = AdService._init();

  AdService._init();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  // 🔴 YENİ EKLENEN METOT: Reklamları ve iOS İzinlerini Başlatma
  Future<void> initializeAds() async {
    // Sadece web değilse ve cihaz iOS ise izin sor
    if (!kIsWeb && Platform.isIOS) {
      // iOS için ATT (Takip İzni) durumunu kontrol et
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // Kullanıcıya izin penceresini göster
        // Yarım saniye beklemek Apple'ın pencereyi yutmasını/bug'a girmesini önler
        await Future.delayed(const Duration(milliseconds: 500));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }
    // İzin penceresi gösterildikten (veya zaten izin verildikten) sonra AdMob'u başlat
    await MobileAds.instance.initialize();

    // 🟢 1. DEĞİŞİKLİK BURADA: AdMob başlar başlamaz geçiş reklamını hafızaya al
    loadInterstitialAd();
  }

  // 🛡️ DÜZELTME: Desteklenmeyen platformlarda (Web, Desktop) çökmeyi önleyen güvenli ID çekimi
  String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return 'ca-app-pub-1815802672526148/6431616325';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    return '';
  }

  String get mediumRectangleAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return 'ca-app-pub-1815802672526148/4022103076';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    return '';
  }

  String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return 'ca-app-pub-1815802672526148/2648283988';

    // 🟢 2. DEĞİŞİKLİK BURADA: iOS Geçiş (Interstitial) Test ID'si düzeltildi
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    return '';
  }

// ---------------- BÖLÜM 1 SONU ----------------

// ==========================================
// BÖLÜM 2: Geçiş Reklamı (Interstitial) Yükleme ve Gösterme
// ==========================================
  void loadInterstitialAd() {
    String adId = interstitialAdUnitId;
    if (adId.isEmpty || _interstitialAd != null || _isInterstitialLoading)
      return;

    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Geçiş Reklamı Hatası: ${error.message}');
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
        loadInterstitialAd(); // Sonraki kullanım için arkadan yenisini yükle
        onReklamBitti();
      }
    }

    emniyetTimer = Timer(const Duration(seconds: 6), () {
      tetikleVeTemizle();
    });

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => tetikleVeTemizle(),
      onAdFailedToShowFullScreenContent: (ad, error) => tetikleVeTemizle(),
    );

    _interstitialAd!.show();
  }

// ---------------- BÖLÜM 2 SONU ----------------

// ==========================================
// BÖLÜM 3: Banner ve Kutu Reklam Motorları (Yükleme Öncelikli)
// ==========================================
  BannerAd? createBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    String adId = bannerAdUnitId;
    if (adId.isEmpty) return null; // Platform desteklenmiyorsa boş dön

    return BannerAd(
      adUnitId: adId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner Hatası: ${error.message}');
          ad.dispose(); // 🛡️ Bellek Sızıntısı Kalkanı
          onAdFailedToLoad(error);
        },
      ),
    )..load();
  }

  BannerAd? createMediumRectangleAd({
    required Function() onAdLoaded,
    required Function(LoadAdError) onAdFailedToLoad,
  }) {
    String adId = mediumRectangleAdUnitId;
    if (adId.isEmpty) return null;

    return BannerAd(
      adUnitId: adId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Kutu Reklam Hatası: ${error.message}');
          ad.dispose(); // 🛡️ Bellek Sızıntısı Kalkanı
          onAdFailedToLoad(error);
        },
      ),
    )..load();
  }
}
// ---------------- BÖLÜM 3 SONU ----------------

// ==========================================
// BÖLÜM 4: Kesintisiz Alt Banner Widget'ı (Kullanıcı Arayüzü)
// ==========================================
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
        if (mounted) {
          setState(() => _isAdLoaded = true);
        } else {
          // 🛡️ KRİTİK DÜZELTME: Reklam yüklendiğinde kullanıcı sayfadan çoktan çıkmışsa reklamı öldür!
          _bannerAd?.dispose();
          _bannerAd = null;
        }
      },
      onAdFailedToLoad: (error) {
        if (mounted) setState(() => _isAdLoaded = false);
        _bannerAd = null;
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ Hata Kalkanı: Widget klavye açıkken, henüz yüklenmemişken veya null ise çizilmez
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0 || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble() + 6,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: Colors.purple.shade200.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
// ---------------- BÖLÜM 4 SONU ----------------

// ==========================================
// BÖLÜM 5: Orta Boy Kutu Reklam Widget'ı (Kullanıcı Arayüzü)
// ==========================================
class MediumRectangleAdWidget extends StatefulWidget {
  const MediumRectangleAdWidget({super.key});

  @override
  State<MediumRectangleAdWidget> createState() =>
      _MediumRectangleAdWidgetState();
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
        if (mounted) {
          setState(() => _isAdLoaded = true);
        } else {
          // 🛡️ KRİTİK DÜZELTME: Bellek Sızıntısı Koruması
          _mediumAd?.dispose();
          _mediumAd = null;
        }
      },
      onAdFailedToLoad: (error) {
        if (mounted) setState(() => _isAdLoaded = false);
        _mediumAd = null;
      },
    );
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
// ---------------- BÖLÜM 5 SONU ----------------
