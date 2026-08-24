import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// 🚀 EKLENDİ: Uygulamanın o anki dilini almak için main.dart'a erişim
import 'main.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? "";

  // 🧠 ÇOK DİLLİ TOPLU KELİME KONTROLÜ
  static Future<Map<int, bool>> topluKelimeKontrol(
      Map<int, String> girilenKelimeler) async {
    Map<int, bool> sonuclar = {};
    Map<int, String> geminiyeSorulacaklar = {};

    if (_apiKey.trim().isEmpty) {
      print("🚨 DİKKAT: Gemini API anahtarı eksik veya .env dosyası okunamadı!");
      girilenKelimeler.forEach((key, value) => sonuclar[key] = false);
      return sonuclar;
    }

    // Uygulamanın o anki dil kodunu alıyoruz (tr, en, de, es)
    String currentLang = appLocale.value.languageCode;

    // 1. ADIM: FİREBASE HAFIZA VE BOŞLUK KONTROLÜ
    for (var entry in girilenKelimeler.entries) {
      int catId = entry.key;
      String kelime = entry.value.trim().toLowerCase();

      if (kelime.isEmpty) {
        sonuclar[catId] = false;
        continue;
      }

      // 🌍 DİKKAT: Artık Firebase hafızasında diller karışmasın diye dil kodunu da ID'ye ekliyoruz!
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
        print("🚨 Firebase hafıza okuma hatası ($kelime):$e");
        geminiyeSorulacaklar[catId] = kelime;
      }
    }

    if (geminiyeSorulacaklar.isEmpty) {
      return sonuclar;
    }

    // 2. ADIM: FİREBASE'DE OLMAYANLARI GEMİNİ'YE SOR (ÇOK DİLLİ PROMPT)
    try {
      final model =
      GenerativeModel(model: 'gemini-3.5-flash-lite', apiKey: _apiKey);

      String jsonSoru = "";
      geminiyeSorulacaklar.forEach((catId, kelime) {
        String kategoriAdi = _getKategoriAdi(catId, currentLang); // 🌍 Dile göre kategori adını al
        jsonSoru +=
        '"$catId": { "kategori": "$kategoriAdi", "kelime": "$kelime" },\n';
      });

      // 🌍 DİLE GÖRE YERELLEŞTİRİLMİŞ (LOCALIZED) GEMINI PROMPT'U
      String prompt = _getLocalizedPrompt(currentLang, jsonSoru);

      final response = await model.generateContent(
          [Content.text(prompt)]).timeout(const Duration(seconds: 12));
      String cevap = response.text?.trim() ?? "{}";

      if (cevap.startsWith("```json")) {
        cevap = cevap.replaceAll("```json", "").replaceAll("```", "").trim();
      } else if (cevap.startsWith("```")) {
        cevap = cevap.replaceAll("```", "").trim();
      }

      print("🤖 Gemini [$currentLang] Cevabı: $cevap");

      Map<String, dynamic> geminiKararlari = jsonDecode(cevap);

      // 3. ADIM: SONUÇLARI BİRLEŞTİR VE FİREBASE'E KAYDET
      for (var entry in geminiyeSorulacaklar.entries) {
        int catId = entry.key;
        String kucukHarfKelime = entry.value;
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
            'dil': currentLang, // 🌍 Hangi dilde kaydedildiğini ekledik
            'onaylandiMi': geminiOnayi,
            'eklenmeTarihi': FieldValue.serverTimestamp(),
            'kaynak': 'Gemini Toplu Analiz'
          });
        } catch (e) {
          print("🚨 Firebase hafıza kaydetme hatası: $e");
        }
      }
    } on TimeoutException catch (_) {
      print("⏳ Gemini API Yanıt Vermedi (Zaman Aşımı)");
      geminiyeSorulacaklar.forEach((k, v) => sonuclar[k] = false);
    } catch (e) {
      print("🚨 Gemini API Genel Hatası: $e");
      geminiyeSorulacaklar.forEach((k, v) => sonuclar[k] = false);
    }

    return sonuclar;
  }

  // 🌍 1. YARDIMCI: Dile Göre Kategori İsimleri (Gemini'nin anlaması için)
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
      // Varsayılan (Türkçe)
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

  // 🌍 2. YARDIMCI: Gemini'ye verilecek kültür bazlı komutlar
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
      // Varsayılan (Türkçe)
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

  // 🛡️ OYUNCU İSMİ GÜVENLİK KONTROLÜ
  static Future<bool> isimUygunMu(String oyuncuAdi) async {
    if (_apiKey.trim().isEmpty) return true;
    String kucukHarfIsim = oyuncuAdi.trim().toLowerCase();

    try {
      final karaListeDoc = await FirebaseFirestore.instance
          .collection('yasakli_isimler')
          .doc(kucukHarfIsim)
          .get();

      if (karaListeDoc.exists) return false;
    } catch (e) {
      print("🚨 Firebase kara liste okuma hatası: $e");
    }

    try {
      final model =
      GenerativeModel(model: 'gemini-3.5-flash-lite', apiKey: _apiKey);

      final prompt = '''
      Sen uluslararası bir mobil oyun güvenlik filtresisin.
      Kontrol edilecek oyuncu adı: "$oyuncuAdi"

      Kurallar:
      1. Bu isim HANGİ DİLDE OLURSA OLSUN (Türkçe, İngilizce, Almanca, İspanyolca) küfür, hakaret, argo, cinsel içerik, nefret söylemi içeriyor mu?
      2. İsim TERTEMİZ ve UYGUNSA SADECE "True" yaz.
      3. İsim UYGUNSUZSA SADECE "False" yaz.
      ''';

      final response = await model.generateContent(
          [Content.text(prompt)]).timeout(const Duration(seconds: 5));
      final cevap = response.text?.trim().toLowerCase() ?? "true";

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