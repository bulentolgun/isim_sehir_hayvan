import 'dart:async'; // 🟢 Timeout (Zaman Aşımı) için gerekli
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 🟢 Gizli Kasa Paketi
import 'package:cloud_firestore/cloud_firestore.dart'; // 🚀 EKLENDİ: Firebase Veritabanı Bağlantısı İçin

class GeminiService {
  // 🟢 YENİ ZIRH: Şifreyi direkt koda yazmak yerine .env gizli kasasından çekiyoruz!
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? "";

  // 🧠 OYUN KELİMESİ KONTROLÜ VE FİREBASE HAFIZASI
  static Future<bool> kelimeyiGeminiyeSor(int catId, String kelime) async {
    if (_apiKey.trim().isEmpty) {
      print("🚨 DİKKAT: Gemini API anahtarı eksik veya .env dosyası okunamadı!");
      return false;
    }

    String kucukHarfKelime = kelime.trim().toLowerCase();
    // Kategoriye özel ID oluşturuyoruz (Örn: 4_elma) ki diğer kategorilerle karışmasın!
    String docId = "${catId}_$kucukHarfKelime";

    // 1. ADIM: FİREBASE HAFIZA KONTROLÜ (Ön Bellek)
    try {
      final hafizaDoc = await FirebaseFirestore.instance
          .collection('kelime_hafizasi')
          .doc(docId)
          .get();

      if (hafizaDoc.exists) {
        bool onayDurumu = hafizaDoc.data()?['onaylandiMi'] ?? false;
        print(onayDurumu
            ? "⚡ Hafızadan Onaylandı (Gemini'ye gidilmedi): $kucukHarfKelime (Kategori: $catId)"
            : "🛑 Hafızadan Reddedildi (Gemini'ye gidilmedi): $kucukHarfKelime (Kategori: $catId)");
        return onayDurumu;
      }
    } catch (e) {
      print("🚨 Firebase hafıza okuma hatası: $e");
    }

    // 2. ADIM: FİREBASE'DE YOKSA GEMİNİ'YE SOR
    try {
      final model = GenerativeModel(model: 'gemini-3.5-flash-lite', apiKey: _apiKey);
      String kategoriAdi = _getKategoriAdi(catId);

      final prompt = '''
Kategori: $kategoriAdi
Kelime: $kelime

Kurallar:
1. Bu kelime bu kategoriye ait GERÇEK, BİYOLOJİK veya FİZİKSEL olarak geçerli bir genel tür/isim mi?
2. Argo, mecaz, deyim (örn: şam şeytanı) veya mitolojik canlıları KESİNLİKLE REDDET (False).
3. Hayvanlara takılan özel isimleri (örn: çomar, karabaş, minnoş) KESİNLİKLE REDDET (False). Genel türleri (köpek, kedi vb.) kabul et.
4. Eşya kategorisinde marka isimlerini değil, nesnenin genel adını kabul et.

Sonuç geçerli mi? SADECE "True" veya "False" yaz. Başka hiçbir kelime veya noktalama işareti kullanma.
''';

      final response = await model.generateContent([Content.text(prompt)]).timeout(const Duration(seconds: 8));
      final cevap = response.text?.trim().toLowerCase() ?? "false";

      bool geminiOnayi = cevap == "true";

      if (geminiOnayi) {
        print("✅ Gemini Onayladı: $kelime ($kategoriAdi)");
      } else {
        print("❌ Gemini Reddetti: $kelime ($kategoriAdi) | Modelin Cevabı: $cevap");
      }

      // 3. ADIM: GEMİNİ'NİN CEVABINI FİREBASE'E KAYDET
      try {
        await FirebaseFirestore.instance.collection('kelime_hafizasi').doc(docId).set({
          'kelime': kucukHarfKelime,
          'kategoriId': catId,
          'onaylandiMi': geminiOnayi,
          'eklenmeTarihi': FieldValue.serverTimestamp(),
          'kaynak': 'Gemini Analizi'
        });
        print("💾 Kelime Firebase hafızasına eklendi: $kucukHarfKelime -> $geminiOnayi");
      } catch (e) {
        print("🚨 Firebase hafıza kaydetme hatası: $e");
      }

      return geminiOnayi;

    } on TimeoutException catch (_) {
      // Zaman aşımı olursa Firebase'e kaydetmiyoruz ki yanlışlıkla "Reddedildi" kalmasın
      print("⏳ Gemini API Yanıt Vermedi (Zaman Aşımı): $kelime");
      return false;
    } catch (e) {
      print("🚨 Gemini API Genel Hatası: $e");
      return false;
    }
  }

  static String _getKategoriAdi(int catId) {
    switch (catId) {
      case 1: return "İnsan İsmi (Sadece gerçek bir insan ismi mi?)";
      case 3: return "Hayvan türü";
      case 4: return "Bitki (Meyve, sebze, ağaç, çiçek vb.)";
      case 5: return "Eşya (Gerçek hayatta kullanılan bir nesne veya araç gereç mi?)";
      default: return "Bilinmeyen Kategori";
    }
  }

  // 🛡️ OYUNCU İSMİ GÜVENLİK KONTROLÜ VE FİREBASE KARA LİSTE
  static Future<bool> isimUygunMu(String oyuncuAdi) async {
    if (_apiKey.trim().isEmpty) return true;

    String kucukHarfIsim = oyuncuAdi.trim().toLowerCase();

    try {
      final karaListeDoc = await FirebaseFirestore.instance
          .collection('yasakli_isimler')
          .doc(kucukHarfIsim)
          .get();

      if (karaListeDoc.exists) {
        print("🛑 Veritabanından Hızlı Engelleme (Gemini'ye sorulmadı): $oyuncuAdi");
        return false;
      }
    } catch (e) {
      print("🚨 Firebase kara liste okuma hatası: $e");
    }

    try {
      final model = GenerativeModel(model: 'gemini-3.5-flash-lite', apiKey: _apiKey);

      final prompt = '''
      Sen bir mobil oyun güvenlik ve ahlak filtresisin.
      Kontrol edilecek oyuncu adı: "$oyuncuAdi"

      Kurallar:
      1. Bu isim küfür, hakaret, argo, cinsel içerik, nefret söylemi veya saldırgan bir ifade içeriyor mu?
      2. İsim TERTEMİZ ve her yaştan (çocuklar dahil) oyuncuya UYGUNSA SADECE "True" yaz.
      3. İsim UYGUNSUZ, KÜFÜRLÜ veya KÖTÜ NİYETLİYSE SADECE "False" yaz.

      Başka hiçbir açıklama veya noktalama işareti kullanma.
      ''';

      final response = await model.generateContent([Content.text(prompt)]).timeout(const Duration(seconds: 5));
      final cevap = response.text?.trim().toLowerCase() ?? "true";

      if (cevap.contains("false")) {
        print("❌ Gemini İsmi Engelledi: $oyuncuAdi");

        try {
          await FirebaseFirestore.instance.collection('yasakli_isimler').doc(kucukHarfIsim).set({
            'isim': kucukHarfIsim,
            'orijinalGiris': oyuncuAdi,
            'eklenmeTarihi': FieldValue.serverTimestamp(),
            'kaynak': 'Gemini Otomatik Engel'
          });
          print("💾 Yeni uygunsuz kelime Firebase kara listesine eklendi: $kucukHarfIsim");
        } catch (e) {
          print("🚨 Firebase kara liste kaydetme hatası: $e");
        }
        return false;
      }
      return true;

    } catch (e) {
      print("🚨 İsim kontrolü hatası: $e");
      return true;
    }
  }
}