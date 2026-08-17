import 'dart:async'; // 🟢 Timeout (Zaman Aşımı) için gerekli
import 'dart:convert'; // 🚀 EKLENDİ: Gemini'den gelen JSON cevabını çözmek için
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 🟢 Gizli Kasa Paketi
import 'package:cloud_firestore/cloud_firestore.dart'; // 🚀 Firebase Veritabanı Bağlantısı İçin

class GeminiService {
  // 🟢 Şifreyi .env gizli kasasından çekiyoruz!
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? "";

  // 🧠 YENİ: TOPLU KELİME KONTROLÜ (MALİYET VE HIZ OPTİMİZASYONU)
  // Map<int, String> girilenKelimeler -> Örnek: {1: "ahmet", 3: "comba", 5: "masa"}
  static Future<Map<int, bool>> topluKelimeKontrol(
      Map<int, String> girilenKelimeler) async {
    Map<int, bool> sonuclar = {};
    Map<int, String> geminiyeSorulacaklar = {};

    if (_apiKey.trim().isEmpty) {
      print(
          "🚨 DİKKAT: Gemini API anahtarı eksik veya .env dosyası okunamadı!");
      girilenKelimeler.forEach((key, value) => sonuclar[key] = false);
      return sonuclar;
    }

    // 1. ADIM: FİREBASE HAFIZA VE BOŞLUK KONTROLÜ (Ön Bellek)
    for (var entry in girilenKelimeler.entries) {
      int catId = entry.key;
      String kelime = entry.value.trim().toLowerCase();

      // Eğer oyuncu kutuyu boş bıraktıysa direkt false ver, hiç uğraşma
      if (kelime.isEmpty) {
        sonuclar[catId] = false;
        continue;
      }

      String docId = "${catId}_$kelime";

      try {
        final hafizaDoc = await FirebaseFirestore.instance
            .collection('kelime_hafizasi')
            .doc(docId)
            .get();

        if (hafizaDoc.exists) {
          bool onayDurumu = hafizaDoc.data()?['onaylandiMi'] ?? false;
          sonuclar[catId] = onayDurumu;
          print(onayDurumu
              ? "⚡ Hafızadan Onaylandı (Gemini'ye gidilmedi): $kelime (Kategori:$catId)"
              : "🛑 Hafızadan Reddedildi (Gemini'ye gidilmedi): $kelime (Kategori:$catId)");
        } else {
          // Firebase'de yoksa, Gemini'ye sorulacaklar sepetine ekle
          geminiyeSorulacaklar[catId] = kelime;
        }
      } catch (e) {
        print("🚨 Firebase hafıza okuma hatası ($kelime):$e");
        geminiyeSorulacaklar[catId] =
            kelime; // Hata olursa riske atma, Gemini'ye sor
      }
    }

    // Eğer tüm kelimeler hafızada bulunduysa (sepet boşsa), Gemini'ye hiç gitme!
    if (geminiyeSorulacaklar.isEmpty) {
      print(
          "🎯 Tüm kelimeler hafızadan veya boşluk kontrolünden geçti, Gemini'ye TEK KURUŞ ödenmedi!");
      return sonuclar;
    }

    // 2. ADIM: FİREBASE'DE OLMAYANLARI GEMİNİ'YE "TEK SEFERDE" SOR
    try {
      final model =
          GenerativeModel(model: 'gemini-3.5-flash-lite', apiKey: _apiKey);

      // Gemini'ye göndereceğimiz kelimeleri hazırlayalım
      String jsonSoru = "";
      geminiyeSorulacaklar.forEach((catId, kelime) {
        String kategoriAdi = _getKategoriAdi(catId);
        jsonSoru +=
            '"$catId": { "kategori": "$kategoriAdi", "kelime": "$kelime" },\n';
      });

      final prompt = '''
Aşağıdaki JSON formatında verilen kelimeleri incele:
{
$jsonSoru
}

Kurallar:
1. Her kelimenin kendi kategorisine ait GERÇEK, BİYOLOJİK veya FİZİKSEL olarak geçerli bir genel tür/isim olup olmadığını kontrol et.
2. Argo, mecaz, deyim veya mitolojik canlıları KESİNLİKLE REDDET (false).
3. Hayvanlara takılan özel isimleri (örn: çomar, karabaş) KESİNLİKLE REDDET (false).
4. Eşya kategorisinde marka isimlerini değil, nesnenin genel adını kabul et.

SADECE VE SADECE aşağıdaki gibi JSON formatında cevap ver, hiçbir açıklama veya markdown (```json) kullanma:
{
  "1": true,
  "3": false
}
''';

      final response = await model.generateContent(
          [Content.text(prompt)]).timeout(const Duration(seconds: 12));
      String cevap = response.text?.trim() ?? "{}";

      // Gemini bazen cevabın başına ve sonuna ```json tagları ekler, onları temizleyelim
      if (cevap.startsWith("```json")) {
        cevap = cevap.replaceAll("```json", "").replaceAll("```", "").trim();
      } else if (cevap.startsWith("```")) {
        cevap = cevap.replaceAll("```", "").trim();
      }

      print("🤖 Gemini Toplu Analiz Cevabı: $cevap");

      // Gelen JSON stringini Dart objesine çeviriyoruz
      Map<String, dynamic> geminiKararlari = jsonDecode(cevap);

      // 3. ADIM: SONUÇLARI BİRLEŞTİR VE FİREBASE'E KAYDET
      for (var entry in geminiyeSorulacaklar.entries) {
        int catId = entry.key;
        String kucukHarfKelime = entry.value;
        String docId = "${catId}_$kucukHarfKelime";

        // Gemini JSON'da bu ID'ye ne yanıt verdi? (Bulamazsa false say)
        bool geminiOnayi = geminiKararlari[catId.toString()] ?? false;
        sonuclar[catId] = geminiOnayi;

        print(geminiOnayi
            ? "✅ Gemini Onayladı: $kucukHarfKelime"
            : "❌ Gemini Reddetti: $kucukHarfKelime");

        // Hafızayı Güncelle
        try {
          await FirebaseFirestore.instance
              .collection('kelime_hafizasi')
              .doc(docId)
              .set({
            'kelime': kucukHarfKelime,
            'kategoriId': catId,
            'onaylandiMi': geminiOnayi,
            'eklenmeTarihi': FieldValue.serverTimestamp(),
            'kaynak': 'Gemini Toplu Analiz'
          });
          print(
              "💾 Yeni kelime Firebase hafızasına eklendi: $kucukHarfKelime -> $geminiOnayi");
        } catch (e) {
          print("🚨 Firebase hafıza kaydetme hatası: $e");
        }
      }
    } on TimeoutException catch (_) {
      print("⏳ Gemini API Yanıt Vermedi (Zaman Aşımı)");
      // Zaman aşımı olursa yeni kelimeleri reddedilmiş sayıyoruz ama Firebase'e KAYDETMİYORUZ.
      geminiyeSorulacaklar.forEach((k, v) => sonuclar[k] = false);
    } catch (e) {
      print("🚨 Gemini API Genel Hatası: $e");
      geminiyeSorulacaklar.forEach((k, v) => sonuclar[k] = false);
    }

    return sonuclar;
  }

  static String _getKategoriAdi(int catId) {
    switch (catId) {
      case 1:
        return "İnsan İsmi (Sadece gerçek bir insan ismi mi?)";
      case 2:
        return "Şehir veya Ülke İsmi"; // Eklenmemişse diye ekledim
      case 3:
        return "Hayvan türü";
      case 4:
        return "Bitki (Meyve, sebze, ağaç, çiçek vb.)";
      case 5:
        return "Eşya (Gerçek hayatta kullanılan bir nesne veya araç gereç mi?)";
      default:
        return "Bilinmeyen Kategori";
    }
  }

  // 🛡️ OYUNCU İSMİ GÜVENLİK KONTROLÜ (Aynı kaldı)
  static Future<bool> isimUygunMu(String oyuncuAdi) async {
    if (_apiKey.trim().isEmpty) return true;

    String kucukHarfIsim = oyuncuAdi.trim().toLowerCase();

    try {
      final karaListeDoc = await FirebaseFirestore.instance
          .collection('yasakli_isimler')
          .doc(kucukHarfIsim)
          .get();

      if (karaListeDoc.exists) {
        print(
            "🛑 Veritabanından Hızlı Engelleme (Gemini'ye sorulmadı): $oyuncuAdi");
        return false;
      }
    } catch (e) {
      print("🚨 Firebase kara liste okuma hatası: $e");
    }

    try {
      final model =
          GenerativeModel(model: 'gemini-3.5-flash-lite', apiKey: _apiKey);

      final prompt = '''
      Sen bir mobil oyun güvenlik ve ahlak filtresisin.
      Kontrol edilecek oyuncu adı: "$oyuncuAdi"

      Kurallar:
      1. Bu isim küfür, hakaret, argo, cinsel içerik, nefret söylemi veya saldırgan bir ifade içeriyor mu?
      2. İsim TERTEMİZ ve her yaştan (çocuklar dahil) oyuncuya UYGUNSA SADECE "True" yaz.
      3. İsim UYGUNSUZ, KÜFÜRLÜ veya KÖTÜ NİYETLİYSE SADECE "False" yaz.

      Başka hiçbir açıklama veya noktalama işareti kullanma.
      ''';

      final response = await model.generateContent(
          [Content.text(prompt)]).timeout(const Duration(seconds: 5));
      final cevap = response.text?.trim().toLowerCase() ?? "true";

      if (cevap.contains("false")) {
        print("❌ Gemini İsmi Engelledi: $oyuncuAdi");

        try {
          await FirebaseFirestore.instance
              .collection('yasakli_isimler')
              .doc(kucukHarfIsim)
              .set({
            'isim': kucukHarfIsim,
            'orijinalGiris': oyuncuAdi,
            'eklenmeTarihi': FieldValue.serverTimestamp(),
            'kaynak': 'Gemini Otomatik Engel'
          });
          print(
              "💾 Yeni uygunsuz kelime Firebase kara listesine eklendi: $kucukHarfIsim");
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
