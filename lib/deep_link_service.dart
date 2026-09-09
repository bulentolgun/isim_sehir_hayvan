import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();

  // =============================================================== //
  // BÖLÜM 1: LİNK DİNLEME VE BAŞLATMA SERVİSİ
  // Görevi: Uygulama açıkken veya kapalıyken gelen linkleri yakalamak
  // =============================================================== //

  static void initDeepLinks(Function(String odaKodu) onOdaKoduAlindi) {
    // DURUM 1: Uygulama tamamen KAPALIYKEN (Soğuk Başlangıç)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _odaKoduAyristir(uri, onOdaKoduAlindi);
      }
    });

    // DURUM 2: Uygulama ARKA PLANDAYKEN linke tıklandıysa
    _appLinks.uriLinkStream.listen((uri) {
      _odaKoduAyristir(uri, onOdaKoduAlindi);
    });
  }

  // ----------------------- BÖLÜM 1 SONU -------------------------- //


  // =============================================================== //
  // BÖLÜM 2: LİNK AYRIŞTIRMA VE ODA KODU ÇIKARMA
  // Görevi: Yakalanan linkin içinden oda numarasını ayıklamak
  // =============================================================== //

  static void _odaKoduAyristir(Uri uri, Function(String odaKodu) onOdaKoduAlindi) {
    debugPrint("🔗 SİSTEME GELEN LİNK: ${uri.toString()}");

    // --- A PLANI: Standart URL Parametresi Kontrolü ---
    if (uri.queryParameters.containsKey('code')) {
      String? code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        debugPrint("✅ ODA KODU PARAMETREDEN YAKALANDI: $code");
        onOdaKoduAlindi(code);
      }
    }

    // --- B PLANI: Alternatif Metin Ayrıştırma (Regex) ---
    else if (uri.toString().contains('code=')) {
      try {
        var parts = uri.toString().split('code=');
        if (parts.length > 1) {
          // Sadece rakamları filtrele ve kodu çıkar
          String code = parts[1].split('&')[0].replaceAll(RegExp(r'[^0-9]'), '');
          if (code.isNotEmpty) {
            debugPrint("✅ ODA KODU METİNDEN YAKALANDI: $code");
            onOdaKoduAlindi(code);
          }
        }
      } catch (e) {
        debugPrint("⚠️ Link ayrıştırma hatası: $e");
      }
    }
  }

// ----------------------- BÖLÜM 2 SONU -------------------------- //
}