import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();

  /// Uygulama açılırken veya çalışırken link tıklandığında tetiklenir
  static void initDeepLinks(Function(String odaKodu) onOdaKoduAlindi) {
    // 1. Uygulama tamamen KAPALIYKEN (Soğuk Başlangıç) linke tıklanıp açıldıysa
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _odaKoduAyristir(uri, onOdaKoduAlindi);
      }
    });

    // 2. Uygulama ARKA PLANDAYKEN linke tıklandıysa
    _appLinks.uriLinkStream.listen((uri) {
      _odaKoduAyristir(uri, onOdaKoduAlindi);
    });
  }

  static void _odaKoduAyristir(Uri uri, Function(String odaKodu) onOdaKoduAlindi) {
    debugPrint("🔗 SİSTEME GELEN LİNK: ${uri.toString()}");

    // A PLANI: Doğrudan URL parametreleri içinde 'code' var mı?
    // Yolun (path) ne olduğuna bakmadan doğrudan numarayı arıyoruz.
    if (uri.queryParameters.containsKey('code')) {
      String? code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        debugPrint("✅ ODA KODU PARAMETREDEN YAKALANDI: $code");
        onOdaKoduAlindi(code);
      }
    }
    // B PLANI: Link bozulmuş veya parametre olarak gelmemişse düz metin olarak içinden söküp al.
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
}