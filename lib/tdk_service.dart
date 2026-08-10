import 'dart:convert';
import 'package:http/http.dart' as http;

class TdkService {
  // 🎯 TDK'NIN BOT ENGELİNİ AŞMAK İÇİN TARAYICI KİMLİĞİ (HEADERS)
  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
  };

  static String trToLowerCase(String text) {
    return text
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .replaceAll('Ğ', 'ğ')
        .replaceAll('Ü', 'ü')
        .replaceAll('Ş', 'ş')
        .replaceAll('Ö', 'ö')
        .replaceAll('Ç', 'ç')
        .toLowerCase();
  }

  static Future<bool> kelimeyiTdkdanDogrula(int kategoriId, String kelime) async {
    String temizKelime = trToLowerCase(kelime.trim());
    if (temizKelime.isEmpty || temizKelime.length < 2) return false;

    try {
      // 🎯 1. KATEGORİ: İSİM (Kişi Adları Sözlüğü)
      if (kategoriId == 1) {
        final url = Uri.parse('https://sozluk.gov.tr/adlar?ara=$temizKelime');
        final response = await http.get(url, headers: _headers).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data is List && data.isNotEmpty) {
            return true;
          }
        }
      }

      // 🎯 TÜM KATEGORİLER İÇİN GENEL GTS SORGUSU
      final url = Uri.parse('https://sozluk.gov.tr/gts?ara=$temizKelime');
      final response = await http.get(url, headers: _headers).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty && data[0]['error'] == null) {

          // 🎯 SADECE ŞEHİR VE ÜLKE İÇİN SÖZLÜKTE OLMASI YETERLİ
          if (kategoriId == 2 || kategoriId == 6) {
            return true;
          }

          bool IsimMi = false;
          bool YasalOlmayanTurVarMi = false;
          String tumAnlamlar = "";

          // TDK verisini baştan sona tara
          for (var madde in data) {
            if (madde['anlamlarListe'] != null) {
              for (var anlamObj in madde['anlamlarListe']) {
                tumAnlamlar += " ${trToLowerCase(anlamObj['anlam'] ?? "")}";

                if (anlamObj['ozelliklerListe'] != null) {
                  for (var ozellik in anlamObj['ozelliklerListe']) {
                    String turAdi = trToLowerCase(ozellik['tam_adi'] ?? "");

                    // ❌ SIFAT, FİİL, ZARF, ZAMİR, EDAT, BAĞLAÇ ENGELİ
                    if (turAdi.contains("sıfat") ||
                        turAdi.contains("fiil") ||
                        turAdi.contains("zarf") ||
                        turAdi.contains("zamir") ||
                        turAdi.contains("edat") ||
                        turAdi.contains("bağlaç")) {
                      YasalOlmayanTurVarMi = true;
                    }

                    // ✅ SADECE İSİM ŞARTI
                    if (turAdi.contains("isim")) {
                      IsimMi = true;
                    }
                  }
                }
              }
            }
          }

          // 🎯 5. KATEGORİ: EŞYA KONTROLÜ (SOMUT EŞYA/NESNE ONAYI)
          if (kategoriId == 5) {
            // Eğer kelime sıfat/fiil/zarf ise veya TDK "isim" olarak tanımlamadıysa REDDET!
            if (YasalOlmayanTurVarMi || !IsimMi) {
              return false;
            }

            // ❌ SOYUT İSİM VE DUYGU ENGELİ
            List<String> soyutKavramlar = [
              "soyut", "duygu", "düşünce", "kavram", "his", "tasarım",
              "inanç", "durum", "nitelik", "özellik", "hayal", "sevecenlik", "sevgi", "ilgi"
            ];

            for (var soyutWord in soyutKavramlar) {
              if (tumAnlamlar.contains(soyutWord)) {
                return false;
              }
            }

            // ✅ SOMUT EŞYA / NESNE BELİRTEÇLERİ (Bunlardan biri geçiyorsa veya somut isimse kabul et)
            List<String> esyaAnahtarlari = [
              "eşya", "alet", "araç", "gereç", "nesne", "taşıt", "cihaz", "kumaş",
              "kap", "mobilya", "dokuma", "giysi", "giyecek", "takım", "örgü", "bıçak",
              "silah", "makine", "örnek", "bölüm", "muhafaza", "örtü"
            ];

            for (var esyaKey in esyaAnahtarlari) {
              if (tumAnlamlar.contains(esyaKey)) {
                return true; // Somut eşya olduğunu doğruladı!
              }
            }

            // TDK tanımında eşya anahtar sözcüğü geçmiyorsa soyut sayıp reddet!
            return false;
          }

          // 🎯 3. KATEGORİ: HAYVAN
          if (kategoriId == 3) {
            List<String> hayvanAnahtarlari = [
              "hayvan", "kuş", "memeli", "balık", "sürüngen", "böcek", "omurgasız", "kemirgen", "türüdür", "türü", "familyası"
            ];
            for (var key in hayvanAnahtarlari) {
              if (tumAnlamlar.contains(key)) return true;
            }
          }
          // 🎯 4. KATEGORİ: BİTKİ
          else if (kategoriId == 4) {
            List<String> bitkiAnahtarlari = [
              "bitki", "çiçek", "ağaç", "ot", "meyve", "sebze", "familyasından", "fidan", "çalı"
            ];
            for (var key in bitkiAnahtarlari) {
              if (tumAnlamlar.contains(key)) return true;
            }
          }
        }
      }
    } catch (e) {
      print("TDK Doğrulama Hatası veya Zaman Aşımı: $e");
    }

    return false;
  }
}