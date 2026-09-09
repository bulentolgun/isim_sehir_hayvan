import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:js' as js; // 🚀 EKLENEN YENİ JS KÜTÜPHANESİ

bool _isRegistered = false;

class AdSenseWidget extends StatelessWidget {
  const AdSenseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const String viewId = 'adsense-ad-300x250';

    if (!_isRegistered) {
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
        final ins = html.Element.tag('ins')
          ..className = 'adsbygoogle'
          ..style.display = 'inline-block'
          ..style.width = '300px'
          ..style.height = '250px'
          ..dataset['adClient'] = 'ca-pub-1815802672526148'
          ..dataset['adSlot'] = '1517304178';

        // 🚀 DÜZELTİLEN KISIM: JS kodu artık dart:js üzerinden tetikleniyor
        Future.microtask(() {
          try {
            js.context.callMethod('eval', ['(adsbygoogle = window.adsbygoogle || []).push({});']);
          } catch (e) {
            debugPrint("AdSense Yükleme Hatası: $e");
          }
        });

        return html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..append(ins);
      });
      _isRegistered = true;
    }

    return Container(
      width: 300,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black, // Reklam gelene kadar şık siyah arkaplan
        borderRadius: BorderRadius.circular(16),
      ),
      child: const HtmlElementView(viewType: viewId),
    );
  }
}