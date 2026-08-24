// ==========================================
// BÖLÜM 1: Kütüphaneler ve Sınıf Tanımlaması (Singleton Yapısı)
// ==========================================
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gemini_service.dart';
import 'main.dart'; // 🚀 EKLENDİ: O anki aktif dili (appLocale) almak için

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

// ---------------- BÖLÜM 1 SONU ----------------

// ==========================================
// BÖLÜM 2: Veritabanı Oluşturma ve Bağlantı
// ==========================================
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('isim_sehir.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 33, // 🚀 VERSİYON 33: Otomatik format atıp sıfırlaması için yükselttik
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }
// ---------------- BÖLÜM 2 SONU ----------------

// ==========================================
// BÖLÜM 3: Tabloların Kurulumu ve Güncellenmesi (Create & Upgrade)
// ==========================================
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE oyuncu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        skor INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE botlar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bot_adi TEXT NOT NULL UNIQUE,
        skor INTEGER NOT NULL,
        lang TEXT DEFAULT 'tr' 
      )
    ''');

    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        first_letter TEXT NOT NULL,
        word_value TEXT NOT NULL,
        lang TEXT DEFAULT 'tr'
      )
    ''');

    await db.insert('oyuncu', {'id': 1, 'skor': 0},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await _1000BotuVeritabaninaEkle(db);
    await _sqlDosyasindanKelimeleriYukle(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 33) {
      print("🚀 Veritabanı 33. Sürüme Yükseltiliyor (Kurşun Geçirmez Sistem)...");
      await db.execute('DROP TABLE IF EXISTS botlar');
      await db.execute('DROP TABLE IF EXISTS words');

      await db.execute('''
        CREATE TABLE botlar (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bot_adi TEXT NOT NULL UNIQUE,
          skor INTEGER NOT NULL,
          lang TEXT DEFAULT 'tr'
        )
      ''');
      await db.execute('''
        CREATE TABLE words (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          first_letter TEXT NOT NULL,
          word_value TEXT NOT NULL,
          lang TEXT DEFAULT 'tr'
        )
      ''');
      await _1000BotuVeritabaninaEkle(db);
      await _sqlDosyasindanKelimeleriYukle(db);
    }
  }
// ---------------- BÖLÜM 3 SONU ----------------

// ==========================================
// BÖLÜM 4: SQL Dosyasından Başlangıç Kelimelerini Yükleme
// ==========================================
  static Future<void> _sqlDosyasindanKelimeleriYukle(Database db) async {
    try {
      String sqlContent = await rootBundle.loadString('assets/game_data.sql');
      List<String> statements = sqlContent.split(';');

      // 🚀 YENİ SİSTEM: Batch (Toplu İşlem) ve Hata Yoksayma
      Batch batch = db.batch();
      for (String statement in statements) {
        String trimmed = statement.trim();
        if (trimmed.isNotEmpty) {
          batch.execute(trimmed);
        }
      }

      // continueOnError: true sayesinde SQL içinde 1 virgül bile eksik olsa
      // sistemi çökertmez, hatalı satırı atlayıp diğer tüm kelimeleri yükler!
      await batch.commit(continueOnError: true);

      print("🎯 game_data.sql verileri kurşun geçirmez sistemle yüklendi!");
    } catch (e) {
      print("🚨 game_data.sql yüklenirken kritik hata oluştu: $e");
    }
  }
// ---------------- BÖLÜM 4 SONU ----------------
// ==========================================
// BÖLÜM 5: ÇOK DİLLİ 1000 BOT JENERATÖRÜ 🚀🌍
// ==========================================
  static Future<void> _1000BotuVeritabaninaEkle(Database db) async {
    Random random = Random(42);
    List<Map<String, dynamic>> botListesi = [];
    Set<String> eklenenIsimler = {};
    int genelIndex = 0;

    void botUret(String lang, List<String> isimler, List<String> ekler, int count) {
      for (int i = 0; i < count; i++) {
        String isim = isimler[i % isimler.length];
        String ek = ekler[random.nextInt(ekler.length)];
        String botAdi = "${isim}_$ek";

        if (eklenenIsimler.contains(botAdi)) {
          botAdi = "${isim}_${ek}_$i";
        }
        eklenenIsimler.add(botAdi);

        // Skorlar yukarıdan aşağıya dağıtılsın
        int skor = 3000 - ((genelIndex * 2700) ~/ 999);
        genelIndex++;

        botListesi.add({'bot_adi': botAdi, 'skor': skor, 'lang': lang});
      }
    }

    // 🇹🇷 TÜRK BOTLARI
    botUret('tr',
        ["Ahmet", "Mehmet", "Ayse", "Fatma", "Burak", "Zeynep", "Elif", "Can", "Ece", "Kaan"],
        ["Pro", "Kral", "Efsane", "TR", "Uzman", "34", "35", "06"], 250);

    // 🇬🇧 İNGİLİZ BOTLARI
    botUret('en',
        ["John", "Emma", "Michael", "Sarah", "James", "Emily", "David", "Olivia", "Daniel", "Sophia"],
        ["Pro", "Star", "Master", "Hero", "Gamer", "X", "Alpha"], 250);

    // 🇩🇪 ALMAN BOTLARI
    botUret('de',
        ["Hans", "Klaus", "Julia", "Anna", "Lukas", "Laura", "Felix", "Mia", "Leon", "Lea"],
        ["Pro", "Meister", "Chef", "Kaiser", "Blitz", "DE"], 250);

    // 🇪🇸 İSPANYOL BOTLARI
    botUret('es',
        ["Carlos", "Maria", "Alejandro", "Sofia", "Diego", "Lucia", "Mateo", "Valentina", "Hugo", "Isabella"],
        ["Pro", "Maestro", "Jefe", "Rey", "Lider", "ES"], 250);

    Batch batch = db.batch();
    for (var bot in botListesi) {
      batch.insert('botlar', bot, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);

    print("🤖 1000 Çok Dilli Bot (250 TR, 250 EN, 250 DE, 250 ES) oluşturuldu.");
  }

// ---------------- BÖLÜM 5 SONU ----------------

// ==========================================
// BÖLÜM 6: AKILLI HARF DÖNÜŞTÜRÜCÜ (Dile Göre) 🌍
// ==========================================
  String smartToLowerCase(String text) {
    if (text.isEmpty) return "";
    String lang = appLocale.value.languageCode;

    if (lang == 'tr') {
      return text.trim()
          .replaceAll('İ', 'i')
          .replaceAll('I', 'ı')
          .replaceAll('Ğ', 'ğ')
          .replaceAll('Ü', 'ü')
          .replaceAll('Ş', 'ş')
          .replaceAll('Ö', 'ö')
          .replaceAll('Ç', 'ç')
          .toLowerCase();
    } else {
      // İngilizce, Almanca ve İspanyolca için standart küçültme
      return text.trim().toLowerCase();
    }
  }

// ---------------- BÖLÜM 6 SONU ----------------

// ==========================================
// BÖLÜM 7: Kelime Doğruluk Kontrolü (Veritabanı Araması)
// ==========================================
  Future<int> checkWordWithToleranceAndTdk(
      int catId, String harf, String kelime) async {
    String temizKelime = kelime.trim();
    if (temizKelime.isEmpty || temizKelime == "-") return 0;

    String girilenIlkharf = smartToLowerCase(temizKelime[0]);
    String secilenHarf = smartToLowerCase(harf);

    if (girilenIlkharf != secilenHarf) {
      return 0;
    }

    bool tamDogru = await _checkWordInDb(catId, harf, temizKelime);
    return tamDogru ? 1 : 0;
  }

  Future<bool> _checkWordInDb(int catId, String harf, String kelime) async {
    final db = await instance.database;
    String lang = appLocale.value.languageCode;

    // Güvenlik: Dil kodunu her ihtimale karşı ilk 2 harfle (tr, en) sınırlayalım
    if (lang.length > 2) {
      lang = lang.substring(0, 2);
    }

    String arananKelime = smartToLowerCase(kelime.trim());
    String arananHarf = smartToLowerCase(harf.trim()[0]);
    String arananHarfBuyuk = arananHarf.toUpperCase();

    // 🌍 Sadece oyun Türkçe ise Türkçe karakter büyütmelerini yap
    if (lang == 'tr') {
      if (arananHarf == 'ı') arananHarfBuyuk = 'I';
      else if (arananHarf == 'i') arananHarfBuyuk = 'İ';
      else if (arananHarf == 'ğ') arananHarfBuyuk = 'Ğ';
      else if (arananHarf == 'ü') arananHarfBuyuk = 'Ü';
      else if (arananHarf == 'ş') arananHarfBuyuk = 'Ş';
      else if (arananHarf == 'ö') arananHarfBuyuk = 'Ö';
      else if (arananHarf == 'ç') arananHarfBuyuk = 'Ç';
    }

    List<String> harfIhtimalleri = [arananHarf, arananHarfBuyuk];
    String placeholders = List.filled(harfIhtimalleri.length, '?').join(', ');

    List<Map<String, dynamic>> res;

    // 🚀 HATA ÇÖZÜMÜ: Şehir(2) ve Ülke(6) evrenseldir. Dil fark etmeksizin tüm sözlükte ara!
    if (catId == 2 || catId == 6) {
      res = await db.query(
        'words',
        where: 'category_id = ? AND first_letter IN ($placeholders)',
        whereArgs: [catId, ...harfIhtimalleri],
      );
    } else {
      // Diğer kategorilerde (İsim, Eşya vb.) sadece aktif dilin sözlüğünde ara
      res = await db.query(
        'words',
        where: 'category_id = ? AND first_letter IN ($placeholders) AND lang = ?',
        whereArgs: [catId, ...harfIhtimalleri, lang],
      );
    }

    for (var row in res) {
      String dbKelime = smartToLowerCase(row['word_value'].toString().trim());
      if (dbKelime == arananKelime ||
          dbKelime.replaceAll(' ', '') == arananKelime.replaceAll(' ', '')) {
        return true;
      }
    }

    if (lang == 'tr' && _ozelIsimKontrolEt(catId, arananKelime)) return true;

    return false;
  }

  bool _ozelIsimKontrolEt(int catId, String kelime) {
    List<String> yedekOzelIsimler = [
      "ısparta", "ığdır", "içel", "iskenderun", "izmir", "istanbul",
      "isveç", "isviçre", "ispanya", "italya", "irlanda", "israil", "izlanda", "ingiltere"
    ];
    return yedekOzelIsimler.contains(kelime);
  }

// ---------------- BÖLÜM 7 SONU ----------------

// ==========================================
// BÖLÜM 8: Toplu Değerlendirme (Gemini ile)
// ==========================================
  Future<List<int>> topluDegerlendirmeMotoru(
      List<Map<String, dynamic>> sorgular, String secilenHarf) async {
    final db = await instance.database;
    String lang = appLocale.value.languageCode;
    List<int> sonuclar = List.filled(sorgular.length, 0);
    List<Map<String, dynamic>> geminiyeGidecekler = [];

    for (int i = 0; i < sorgular.length; i++) {
      int catId = sorgular[i]["id"];
      String kelime = sorgular[i]["cvp"].toString().trim();
      if (kelime.isEmpty || kelime == "-") continue;

      String girilenIlkharf = smartToLowerCase(kelime[0]);
      String arananHarf = smartToLowerCase(secilenHarf);

      if (girilenIlkharf != arananHarf) continue;

      bool tdkOnayi = await _checkWordInDb(catId, secilenHarf, kelime);

      if (tdkOnayi) {
        sonuclar[i] = 1;
      } else if (catId != 2 && catId != 6) {
        geminiyeGidecekler
            .add({"index": i, "catId": catId, "kelime": smartToLowerCase(kelime)});
      }
    }

    if (geminiyeGidecekler.isNotEmpty) {
      List<Map<int, String>> paketler = [];
      Set<String> eklenenAnahtarlar = {};

      for (var item in geminiyeGidecekler) {
        int catId = item["catId"];
        String kelime = item["kelime"];
        String anahtar = "${catId}_$kelime";

        if (eklenenAnahtarlar.contains(anahtar)) continue;

        bool eklendi = false;
        for (var paket in paketler) {
          if (!paket.containsKey(catId)) {
            paket[catId] = kelime;
            eklendi = true;
            break;
          }
        }
        if (!eklendi) {
          paketler.add({catId: kelime});
        }
        eklenenAnahtarlar.add(anahtar);
      }

      for (var paket in paketler) {
        Map<int, bool> geminiCevaplari =
        await GeminiService.topluKelimeKontrol(paket);

        for (var entry in paket.entries) {
          int catId = entry.key;
          String kelime = entry.value;
          bool onaylandi = geminiCevaplari[catId] ?? false;

          if (onaylandi) {
            for (var gItem in geminiyeGidecekler) {
              if (gItem["catId"] == catId && gItem["kelime"] == kelime) {
                sonuclar[gItem["index"]] = 1;
              }
            }

            // 🌍 YENİ KELİMLERİ İLGİLİ DİL KODUYLA (lang) VERİTABANINA KAYDET
            await db.insert(
                'words',
                {
                  'category_id': catId,
                  'first_letter': smartToLowerCase(secilenHarf[0]),
                  'word_value': kelime,
                  'lang': lang
                },
                conflictAlgorithm: ConflictAlgorithm.ignore);

            try {
              await FirebaseFirestore.instance
                  .collection('onaylanmis_yeni_kelimeler')
                  .add({
                'kelime': kelime,
                'kategori_id': catId,
                'harf': smartToLowerCase(secilenHarf[0]),
                'dil': lang, // 🌍 Firebase'de dilleri ayrıştırıyoruz
                'eklenme_tarihi': FieldValue.serverTimestamp(),
              });
            } catch (e) {
              print("Firebase kelime ekleme hatası: $e");
            }
          }
        }
      }
    }
    return sonuclar;
  }

// ---------------- BÖLÜM 8 SONU ----------------

// ==========================================
// BÖLÜM 9: Botlar İçin Rastgele Kelime Seçme Motoru
// ==========================================
  Future<String?> getBotKelime(int catId, String harf) async {
    final db = await instance.database;
    String lang = appLocale.value.languageCode;

    String kucukHarf = smartToLowerCase(harf);
    String arananHarfBuyuk = kucukHarf.toUpperCase();

    if (lang == 'tr') {
      if (kucukHarf == 'ı') arananHarfBuyuk = 'I';
      else if (kucukHarf == 'i') arananHarfBuyuk = 'İ';
      else if (kucukHarf == 'ğ') arananHarfBuyuk = 'Ğ';
      else if (kucukHarf == 'ü') arananHarfBuyuk = 'Ü';
      else if (kucukHarf == 'ş') arananHarfBuyuk = 'Ş';
      else if (kucukHarf == 'ö') arananHarfBuyuk = 'Ö';
      else if (kucukHarf == 'ç') arananHarfBuyuk = 'Ç';
    }

    List<String> harfIhtimalleri = [kucukHarf, arananHarfBuyuk];
    String placeholders = List.filled(harfIhtimalleri.length, '?').join(', ');

    // 🌍 SADECE O ANKİ DİLDEKİ KELİMELERİ ÇEK
    List<Map<String, dynamic>> res = await db.query(
      'words',
      where: 'category_id = ? AND first_letter IN ($placeholders) AND lang = ?',
      whereArgs: [catId, ...harfIhtimalleri, lang],
    );

    if (res.isNotEmpty) {
      List<Map<String, dynamic>> mutableRes = List.from(res);
      mutableRes.shuffle();
      return mutableRes.first['word_value'] as String?;
    }
    return null; // Eğer o dilde/harfte kelime yoksa bot boş bırakır (doğal görünüm)
  }

// ---------------- BÖLÜM 9 SONU ----------------

// ==========================================
// BÖLÜM 10 & 11: Skor İşlemleri (Aynı Kaldı)
// ==========================================
  Future<int> getOyuncuSkor() async {
    final db = await instance.database;
    List<Map<String, dynamic>> res = await db.query('oyuncu');
    if (res.isNotEmpty) return res.first['skor'] as int;
    return 0;
  }

  Future<void> saveOyuncuSkor(String oyuncuAdi, int eklenecekSkor) async {
    final db = await instance.database;
    int mevcutSkor = await getOyuncuSkor();
    int yeniToplamSkor = mevcutSkor + eklenecekSkor;

    await db.insert('oyuncu', {'id': 1, 'skor': yeniToplamSkor},
        conflictAlgorithm: ConflictAlgorithm.replace);

    try {
      String isim = oyuncuAdi.isEmpty ? "Misafir" : oyuncuAdi;
      await FirebaseFirestore.instance.collection('liderlik_tablosu').doc(isim).set({
        'kullanici_adi': isim,
        'skor': yeniToplamSkor,
        'is_bot': false,
        'son_guncelleme': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Firebase online skor güncelleme hatası: $e");
    }
  }

  Future<void> saveBotSkor(String botAdi, int eklenecekSkor) async {
    final db = await instance.database;
    List<Map<String, dynamic>> res = await db.query('botlar', where: 'bot_adi = ?', whereArgs: [botAdi]);

    if (res.isEmpty) return;
    int mevcut = res.first['skor'] as int;
    int yeniBotSkor = mevcut + eklenecekSkor;

    await db.update('botlar', {'skor': yeniBotSkor}, where: 'bot_adi = ?', whereArgs: [botAdi]);

    try {
      await FirebaseFirestore.instance.collection('liderlik_tablosu').doc(botAdi).set({
        'kullanici_adi': botAdi,
        'skor': yeniBotSkor,
        'is_bot': true,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Firebase bot skor güncelleme hatası: $e");
    }
  }

// ==========================================
// BÖLÜM 12: KÜLTÜREL BOT SEÇİMİ 🌍
// ==========================================
  Future<Map<String, dynamic>> getRandomBot({List<String>? haricTutulacakBotlar}) async {
    final db = await instance.database;
    String lang = appLocale.value.languageCode;

    // 🌍 SADECE OYUNUN O ANKİ DİLİNE AİT BOTLARI GETİR
    List<Map<String, dynamic>> botlar = await db.query('botlar', where: 'lang = ?', whereArgs: [lang]);

    // Eğer o dilde bot bulunamazsa (hata olursa) mecburen varsayılan Türkçe botları çek
    if (botlar.isEmpty) {
      botlar = await db.query('botlar', where: 'lang = ?', whereArgs: ['tr']);
    }

    if (botlar.isNotEmpty) {
      List<Map<String, dynamic>> secilebilirBotlar = List.from(botlar);

      if (haricTutulacakBotlar != null && haricTutulacakBotlar.isNotEmpty) {
        secilebilirBotlar.removeWhere((b) => haricTutulacakBotlar.contains(b['bot_adi']));
      }

      if (secilebilirBotlar.isEmpty) {
        secilebilirBotlar = List.from(botlar);
      }

      secilebilirBotlar.shuffle();
      return secilebilirBotlar.first;
    }
    return {'bot_adi': 'Ahmet_34', 'skor': 3000};
  }

// ==========================================
// BÖLÜM 13: Hızlı Sıralama Sayacı (Aynı Kaldı)
// ==========================================
  Future<Map<String, int>> getHizliSiralamaVeToplamOyuncu(int benimSkorum) async {
    final db = await instance.database;
    var botResult = await db.rawQuery('SELECT COUNT(*) FROM botlar WHERE skor > ?', [benimSkorum]);
    int ustumdekiBotSayisi = Sqflite.firstIntValue(botResult) ?? 0;

    int ustumdekiGercekOyuncuSayisi = 0;
    int toplamGercekOyuncuSayisi = 0;

    try {
      var ustumdekilerSnapshot = await FirebaseFirestore.instance
          .collection('liderlik_tablosu').where('is_bot', isEqualTo: false)
          .where('skor', isGreaterThan: benimSkorum).count().get().timeout(const Duration(seconds: 5));
      ustumdekiGercekOyuncuSayisi = ustumdekilerSnapshot.count ?? 0;

      var toplamGercekSnapshot = await FirebaseFirestore.instance
          .collection('liderlik_tablosu').where('is_bot', isEqualTo: false)
          .count().get().timeout(const Duration(seconds: 5));
      toplamGercekOyuncuSayisi = toplamGercekSnapshot.count ?? 0;
    } catch (e) {
      print("🚨 Sıralama sayılırken Firebase hatası: $e");
    }

    int benimSiralamam = ustumdekiBotSayisi + ustumdekiGercekOyuncuSayisi + 1;
    int gercekKisiSayisi = max(1, toplamGercekOyuncuSayisi);
    int toplamOyuncu = 1000 + gercekKisiSayisi;

    return {'sira': benimSiralamam, 'toplam': toplamOyuncu};
  }
}