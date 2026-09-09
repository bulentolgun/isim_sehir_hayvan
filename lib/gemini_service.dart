import 'dart:async';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class GeminiService {

  // ============================================================================
  // 🚀 BÖLÜM 1: TOPLU KELİME KONTROL SİSTEMİ BAŞLANGICI
  // ============================================================================

  // 🧠 ÇOK DİLLİ TOPLU KELİME KONTROLÜ
  // Kullanıcının girdiği kelimeleri önce Firebase hafızasında arar,
  // bulamazsa Cloud Functions üzerinden Gemini'ye sorar.
  static Future<Map<int, bool>> topluKelimeKontrol(
      Map<int, String> girilenKelimeler) async {
    Map<int, bool> sonuclar = {};
    Map<int, String> geminiyeSorulacaklar = {};

    String currentLang = appLocale.value.languageCode;

    // ---------------------------------------------------------
    // 📌 ALT BAŞLIK 1.1: FİREBASE HAFIZA VE BOŞLUK KONTROLÜ
    // ---------------------------------------------------------
    for (var entry in girilenKelimeler.entries) {
      int catId = entry.key;

      // 🛡️ ZIRH 1.1: Boşlukları temizle ve '/' işaretini '-' yap (Firestore çökmesini önler)
      String kelime = entry.value.trim().toLowerCase().replaceAll('/', '-');

      if (kelime.isEmpty) {
        sonuclar[catId] = false;
        continue;
      }

      String docId = "${currentLang}_${catId}_$kelime";

      try {
        final hafizaDoc = await FirebaseFirestore.instance
            .collection('kelime_hafizasi')
            .doc(docId)
            .get();

        if (hafizaDoc.exists) {
          bool onayDurumu = hafizaDoc.data()?['onaylandiMi'] ?? false;
          sonuclar[catId] = onayDurumu;
          print(onayDurumu
              ? "⚡ Hafızadan Onaylandı [$currentLang]: $kelime (Kategori:$catId)"
              : "🛑 Hafızadan Reddedildi [$currentLang]: $kelime (Kategori:$catId)");
        } else {
          geminiyeSorulacaklar[catId] = kelime;
        }
      } catch (e) {
        // 🛡️ ZIRH 1.2: Hafıza okuma çökse bile oyunu durdurma, kelimeyi Gemini'ye gönder
        print("🚨 Firebase hafıza okuma hatası ($kelime):$e");
        geminiyeSorulacaklar[catId] = kelime;
      }
    }

    if (geminiyeSorulacaklar.isEmpty) {
      return sonuclar;
    }

    // ---------------------------------------------------------
    // 📌 ALT BAŞLIK 1.2: CLOUD FUNCTIONS (GEMİNİ) İLE KONTROL
    // ---------------------------------------------------------
    try {
      String jsonSoru = "";
      geminiyeSorulacaklar.forEach((catId, kelime) {
        String kategoriAdi = _getKategoriAdi(catId, currentLang);
        jsonSoru += '"$catId": { "kategori": "$kategoriAdi", "kelime": "$kelime" },\n';
      });

      String prompt = _getLocalizedPrompt(currentLang, jsonSoru);

      // 🚀 YENİ BAĞLANTI: Doğrudan kendi sunucumuzu çağırıyoruz!
      final callable = FirebaseFunctions.instance.httpsCallable('geminiSorgusu');
      final response = await callable.call({'prompt': prompt}).timeout(const Duration(seconds: 15));

      String cevap = response.data['cevap']?.toString().trim() ?? "{}";

      // 🛡️ ZIRH 1.3: Gemini'nin Markdown (```json) formatını temizleme
      if (cevap.startsWith("```json")) {
        cevap = cevap.replaceAll("```json", "").replaceAll("```", "").trim();
      } else if (cevap.startsWith("```")) {
        cevap = cevap.replaceAll("```", "").trim();
      }

      print("🤖 Sunucu Gemini [$currentLang] Cevabı: $cevap");

      Map<String, dynamic> geminiKararlari;
      try {
        geminiKararlari = jsonDecode(cevap);
      } catch (formatHatasi) {
        // 🛡️ ZIRH 1.4: Yapay zeka JSON formatını bozarsa tüm kelimeleri geçersiz say (Oyun çökmesin)
        print("🚨 Sunucu bozuk JSON gönderdi: $formatHatasi \n Gelen Cevap: $cevap");
        geminiyeSorulacaklar.forEach((k, v) => sonuclar[k] = false);
        return sonuclar;
      }

      // ---------------------------------------------------------
      // 📌 ALT BAŞLIK 1.3: SONUÇLARI BİRLEŞTİR VE HAFIZAYA KAYDET
      // ---------------------------------------------------------
      for (var entry in geminiyeSorulacaklar.entries) {
        int catId = entry.key;
        String kucukHarfKelime = entry.value.replaceAll('/', '-');
        String docId = "${currentLang}_${catId}_$kucukHarfKelime";

        bool geminiOnayi = geminiKararlari[catId.toString()] ?? false;
        sonuclar[catId] = geminiOnayi;

        try {
          await FirebaseFirestore.instance
              .collection('kelime_hafizasi')
              .doc(docId)
              .set({
            'kelime': kucukHarfKelime,
            'kategoriId': catId,
            'dil': currentLang,
            'onaylandiMi': geminiOnayi,
            'eklenmeTarihi': FieldValue.serverTimestamp(),
            'kaynak': 'Gemini Sunucu Analizi'
          });
        } catch (e) {
          // 🛡️ ZIRH 1.5: Kayıt başarısız olursa sadece logla, oyunu durdurma
          print("🚨 Firebase hafıza kaydetme hatası: $e");
        }
      }
    } on TimeoutException catch (_) {
      // 🛡️ ZIRH 1.6: Zaman aşımı durumunda kelimeleri reddet
      print("⏳ Sunucu API Yanıt Vermedi (Zaman Aşımı)");
      geminiyeSorulacaklar.forEach((k, v) => sonuclar[k] = false);
    } catch (e) {
      // 🛡️ ZIRH 1.7: Genel API hatalarında çökme engeli
      print("🚨 Sunucu API Genel Hatası: $e");
      geminiyeSorulacaklar.forEach((k, v) => sonuclar[k] = false);
    }

    return sonuclar;
  }

  // ============================================================================
  // 🚀 BÖLÜM 1: TOPLU KELİME KONTROL SİSTEMİ BİTİŞİ
  // ============================================================================



  // ============================================================================
  // 🚀 BÖLÜM 2: YARDIMCI METOTLAR BAŞLANGICI
  // ============================================================================

  // 🌍 YARDIMCI 2.1: Dile Göre Kategori İsimleri Getirici
  static String _getKategoriAdi(int catId, String lang) {
    if (lang == "en") {
      switch (catId) {
        case 1: return "First Name (Real human name)";
        case 2: return "City or Country";
        case 3: return "Animal";
        case 4: return "Plant, Fruit, Vegetable, or Tree";
        case 5: return "Physical Object or Thing";
        case 6: return "Country";
        default: return "Unknown Category";
      }
    } else if (lang == "de") {
      switch (catId) {
        case 1: return "Vorname (Echter menschlicher Name)";
        case 2: return "Stadt oder Land";
        case 3: return "Tier";
        case 4: return "Pflanze, Frucht, Gemüse oder Baum";
        case 5: return "Gegenstand (Physisches Objekt)";
        case 6: return "Land";
        default: return "Unbekannte Kategorie";
      }
    } else if (lang == "es") {
      switch (catId) {
        case 1: return "Nombre (Nombre humano real)";
        case 2: return "Ciudad o País";
        case 3: return "Animal";
        case 4: return "Planta, Fruta, Verdura o Árbol";
        case 5: return "Objeto o Cosa Física";
        case 6: return "País";
        default: return "Categoría Desconocida";
      }
    } else {
      switch (catId) {
        case 1: return "İnsan İsmi (Gerçek bir insan ismi)";
        case 2: return "Şehir veya Ülke İsmi";
        case 3: return "Hayvan türü";
        case 4: return "Bitki (Meyve, sebze, ağaç, çiçek vb.)";
        case 5: return "Eşya (Gerçek hayatta kullanılan bir nesne)";
        case 6: return "Ülke";
        default: return "Bilinmeyen Kategori";
      }
    }
  }

  // 🌍 YARDIMCI 2.2: Dile Göre Gemini Promtu (Komutu) Oluşturucu
  static String _getLocalizedPrompt(String lang, String jsonSoru) {
    if (lang == "en") {
      return '''
You are a strict referee for the traditional word game "Scattergories" (or "Stop!").
Analyze the following JSON words:
{
$jsonSoru
}
Rules:
1. Check if each word is a VALID, REAL, and COMMONLY ACCEPTED term in English for its specific category.
2. REJECT (false) slang, mythological creatures, or made-up words.
3. REJECT (false) specific pet names for animals (e.g., Fido, Rex).
4. For objects, accept general terms, not brand names.

REPLY STRICTLY in JSON format with boolean values (true/false) like this:
{ "1": true, "3": false }
''';
    } else if (lang == "de") {
      return '''
Du bist ein strenger Schiedsrichter für das traditionelle Spiel "Stadt, Land, Fluss".
Analysiere die folgenden Wörter im JSON-Format:
{
$jsonSoru
}
Regeln:
1. Prüfe, ob jedes Wort ein GÜLTIGER, REALER und ALLGEMEIN AKZEPTIERTER Begriff auf Deutsch für seine Kategorie ist.
2. LEHNE (false) Slang, Fabelwesen oder erfundene Wörter ab.
3. LEHNE (false) Haustiernamen (z.B. Bello) für die Kategorie Tier ab.
4. Bei Gegenständen akzeptiere allgemeine Begriffe, keine Markennamen.

ANTWORTE AUSSCHLIESSLICH im JSON-Format mit booleschen Werten (true/false) wie folgt:
{ "1": true, "3": false }
''';
    } else if (lang == "es") {
      return '''
Eres un árbitro estricto del juego tradicional "Tutti Frutti" (o "Basta!").
Analiza las siguientes palabras en formato JSON:
{
$jsonSoru
}
Reglas:
1. Verifica si cada palabra es un término VÁLIDO, REAL y COMÚNMENTE ACEPTADO en español para su categoría.
2. RECHAZA (false) jerga, criaturas mitológicas o palabras inventadas.
3. RECHAZA (false) nombres de mascotas (ej: Firulais) en animales.
4. Para objetos, acepta términos generales, no marcas.

RESPONDE ESTRICTAMENTE en formato JSON con valores booleanos (true/false) así:
{ "1": true, "3": false }
''';
    } else {
      return '''
Sen geleneksel "İsim Şehir Hayvan" oyunu için bir hakemsin.
Aşağıdaki JSON formatında verilen kelimeleri incele:
{
$jsonSoru
}
Kurallar:
1. Her kelimenin Türkçe'de kendi kategorisine ait GERÇEK, BİYOLOJİK veya FİZİKSEL olarak geçerli bir genel tür/isim olup olmadığını kontrol et.
2. Argo, mecaz, deyim veya mitolojik canlıları KESİNLİKLE REDDET (false).
3. Hayvanlara takılan özel isimleri (örn: çomar, karabaş) KESİNLİKLE REDDET (false).
4. Eşya kategorisinde marka isimlerini değil, nesnenin genel adını kabul et.

SADECE VE SADECE JSON formatında cevap ver:
{ "1": true, "3": false }
''';
    }
  }

  // ============================================================================
  // 🚀 BÖLÜM 2: YARDIMCI METOTLAR BİTİŞİ
  // ============================================================================



  // ============================================================================
  // 🚀 BÖLÜM 3: OYUNCU İSMİ GÜVENLİK FİLTRESİ BAŞLANGICI
  // ============================================================================

  // 🛡️ OYUNCU İSMİ GÜVENLİK KONTROLÜ
  // Yeni kayıt olan oyuncuların isimlerini küfür, argo ve nefret söylemine karşı tarar.
  static Future<bool> isimUygunMu(String oyuncuAdi) async {

    // 🛡️ ZIRH 3.1: Firestore '/' işaretinde çökmesin diye temizleme
    String kucukHarfIsim = oyuncuAdi.trim().toLowerCase().replaceAll('/', '-');

    // ---------------------------------------------------------
    // 📌 ALT BAŞLIK 3.1: KARA LİSTE (BLACKLIST) KONTROLÜ
    // ---------------------------------------------------------
    try {
      final karaListeDoc = await FirebaseFirestore.instance
          .collection('yasakli_isimler')
          .doc(kucukHarfIsim)
          .get();

      if (karaListeDoc.exists) return false;
    } catch (e) {
      // 🛡️ ZIRH 3.2: Okuma hatası olursa oyunu kitleme, kontrole devam et
      print("🚨 Firebase kara liste okuma hatası: $e");
    }

    // ---------------------------------------------------------
    // 📌 ALT BAŞLIK 3.2: CLOUD FUNCTIONS İLE YAPAY ZEKA FİLTRESİ
    // ---------------------------------------------------------
    try {
      final prompt = '''
      Sen uluslararası bir mobil oyun güvenlik filtresisin.
      Kontrol edilecek oyuncu adı: "$oyuncuAdi"

      Kurallar:
      1. Bu isim HANGİ DİLDE OLURSA OLSUN (Türkçe, İngilizce, Almanca, İspanyolca) küfür, hakaret, argo, cinsel içerik, nefret söylemi içeriyor mu?
      2. İsim TERTEMİZ ve UYGUNSA SADECE "True" yaz.
      3. İsim UYGUNSUZSA SADECE "False" yaz.
      ''';

      // 🚀 YENİ BAĞLANTI: Sunucuya gönderiyoruz
      final callable = FirebaseFunctions.instance.httpsCallable('geminiSorgusu');
      final response = await callable.call({'prompt': prompt}).timeout(const Duration(seconds: 10));
      final cevap = response.data['cevap']?.toString().trim().toLowerCase() ?? "true";

      if (cevap.contains("false")) {
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
        } catch (e) {
          // 🛡️ ZIRH 3.3: Kayıt hatası çökme yapmasın
          print("🚨 Firebase kara liste kaydetme hatası: $e");
        }
        return false; // İsim reddedildi
      }
      return true; // İsim onaylandı

    } catch (e) {
      // 🛡️ ZIRH 3.4: API hata verirse, iyi niyet kuralı gereği oyuncuyu içeri al
      print("🚨 İsim kontrolü hatası: $e");
      return true;
    }
  }

// ============================================================================
// 🚀 BÖLÜM 3: OYUNCU İSMİ GÜVENLİK FİLTRESİ BİTİŞİ
// ============================================================================

}