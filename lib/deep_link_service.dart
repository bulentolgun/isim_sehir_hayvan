import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();

  /// Uygulama açılırken veya çalışırken link tıklandığında tetiklenir
  static void initDeepLinks(Function(String odaKodu) onOdaKoduAlindi) {
    // 1. Uygulama tamamen KAPALIYKEN linke tıklanıp açıldıysa
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

  static void _odaKoduAyristir(
      Uri uri, Function(String odaKodu) onOdaKoduAlindi) {
    // Örnek Bağlantı: https://isimsehir.app/join?code=7582
    if (uri.path == '/join' && uri.queryParameters.containsKey('code')) {
      String? code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        onOdaKoduAlindi(code);
      }
    }
  }
}
