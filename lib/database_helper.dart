// ==========================================
// BÖLÜM 1: Kütüphaneler ve Sınıf Tanımlaması (Singleton Yapısı)
// ==========================================
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gemini_service.dart'; // 🚀

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
      version: 31,
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
        skor INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        first_letter TEXT NOT NULL,
        word_value TEXT NOT NULL
      )
    ''');

    await db.insert('oyuncu', {'id': 1, 'skor': 0},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await _1000BotuVeritabaninaEkle(db);
    await _sqlDosyasindanKelimeleriYukle(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS words');
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        first_letter TEXT NOT NULL,
        word_value TEXT NOT NULL
      )
    ''');
    await _sqlDosyasindanKelimeleriYukle(db);

    if (oldVersion < 31) {
      await db.delete('botlar');
      await _1000BotuVeritabaninaEkle(db);
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

      await db.transaction((txn) async {
        for (String statement in statements) {
          String trimmed = statement.trim();
          if (trimmed.isNotEmpty) {
            await txn.execute(trimmed);
          }
        }
      });
      print("🎯 game_data.sql verileri words tablosuna başarıyla yüklendi!");
    } catch (e) {
      print("game_data.sql yüklenirken hata oluştu: $e");
    }
  }

// ---------------- BÖLÜM 4 SONU ----------------

// ==========================================
// ==========================================
// BÖLÜM 5: 1000 Adet Botun Oluşturulması (SADECE YEREL SQLITE)
// ==========================================
  static Future<void> _1000BotuVeritabaninaEkle(Database db) async {
    List<String> sehirKodlari = [
      "34",
      "06",
      "35",
      "16",
      "07",
      "01",
      "60",
      "61",
      "55",
      "42",
      "22",
      "10",
      "20",
      "26",
      "27",
      "33",
      "41",
      "45",
      "54"
    ];
    List<String> unvanlar = [
      "Pro",
      "Star",
      "Master",
      "Kral",
      "Efsane",
      "Gamer",
      "Kaptan",
      "TR",
      "X",
      "Uzman",
      "Atak",
      "Zeki",
      "Hizli",
      "Guc",
      "Lider"
    ];
    List<String> temelIsimler = [
      "Ahmet",
      "Mehmet",
      "Ayse",
      "Fatma",
      "Mustafa",
      "Emre",
      "Can",
      "Zeynep",
      "Elif",
      "Burak",
      "Deniz",
      "Ece",
      "Serkan",
      "Gamze",
      "Kaan",
      "Merve",
      "Omer",
      "Selin",
      "Murat",
      "Buse",
      "Onur",
      "Gokhan",
      "Hande",
      "Kadir",
      "Tugba",
      "Yasin",
      "Hakan",
      "Dilara",
      "Doruk",
      "Bora",
      "Tolga",
      "Sibel",
      "Koray",
      "Pinar",
      "Eren",
      "Derya",
      "Volkan",
      "Ezgi",
      "Kerem",
      "Gizem"
    ];

    Random random = Random(42);
    List<Map<String, dynamic>> botListesi = [];
    Set<String> eklenenIsimler = {};

    for (int i = 0; i < 1000; i++) {
      String temelIsim = temelIsimler[i % temelIsimler.length];
      String ek = (i % 2 == 0)
          ? sehirKodlari[random.nextInt(sehirKodlari.length)]
          : unvanlar[random.nextInt(unvanlar.length)];

      String botAdi = "${temelIsim}_$ek";
      if (eklenenIsimler.contains(botAdi)) {
        botAdi = "${temelIsim}_${ek}_$i";
      }
      eklenenIsimler.add(botAdi);

      int skor = 3000 - ((i * 2700) ~/ 999);
      botListesi.add({'bot_adi': botAdi, 'skor': skor});
    }

    Batch batch = db.batch();
    for (var bot in botListesi) {
      batch.insert('botlar', bot, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);

    print(
        "🤖 1000 Bot yerel veritabanına eklendi (Firebase'e yazma kapatıldı).");
  }

// ---------------- BÖLÜM 5 SONU ----------------

// ==========================================
// BÖLÜM 6: Türkçe Karakter Dönüştürme (Küçük Harf)
// ==========================================
  String trToLowerCase(String text) {
    if (text.isEmpty) return "";
    return text
        .trim()
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .replaceAll('Ğ', 'ğ')
        .replaceAll('Ü', 'ü')
        .replaceAll('Ş', 'ş')
        .replaceAll('Ö', 'ö')
        .replaceAll('Ç', 'ç')
        .toLowerCase();
  }

// ---------------- BÖLÜM 6 SONU ----------------

// ==========================================
// BÖLÜM 7: Kelime Doğruluk Kontrolü (İlk Harf ve Veritabanı Araması)
// ==========================================
  Future<int> checkWordWithToleranceAndTdk(
      int catId, String harf, String kelime) async {
    String temizKelime = kelime.trim();
    if (temizKelime.isEmpty || temizKelime == "-") return 0;

    String girilenIlkharf = trToLowerCase(temizKelime[0]);
    String secilenHarf = trToLowerCase(harf);

    if (girilenIlkharf != secilenHarf) {
      return 0;
    }

    bool tamDogru = await _checkWordInDb(catId, harf, temizKelime);
    return tamDogru ? 1 : 0;
  }

  Future<bool> _checkWordInDb(int catId, String harf, String kelime) async {
    final db = await instance.database;
    String arananKelime = trToLowerCase(kelime.trim());
    String arananHarf = trToLowerCase(harf.trim()[0]);

    String arananHarfBuyuk = arananHarf.toUpperCase();
    if (arananHarf == 'ı')
      arananHarfBuyuk = 'I';
    else if (arananHarf == 'i')
      arananHarfBuyuk = 'İ';
    else if (arananHarf == 'ğ')
      arananHarfBuyuk = 'Ğ';
    else if (arananHarf == 'ü')
      arananHarfBuyuk = 'Ü';
    else if (arananHarf == 'ş')
      arananHarfBuyuk = 'Ş';
    else if (arananHarf == 'ö')
      arananHarfBuyuk = 'Ö';
    else if (arananHarf == 'ç') arananHarfBuyuk = 'Ç';

    List<String> harfIhtimalleri = [arananHarf, arananHarfBuyuk];
    String placeholders = List.filled(harfIhtimalleri.length, '?').join(', ');

    List<Map<String, dynamic>> res = await db.query(
      'words',
      where: 'category_id = ? AND first_letter IN ($placeholders)',
      whereArgs: [catId, ...harfIhtimalleri],
    );

    for (var row in res) {
      String dbKelime = trToLowerCase(row['word_value'].toString().trim());
      if (dbKelime == arananKelime ||
          dbKelime.replaceAll(' ', '') == arananKelime.replaceAll(' ', '')) {
        return true;
      }
    }

    if (_ozelIsimKontrolEt(catId, arananKelime)) return true;

    return false;
  }

  bool _ozelIsimKontrolEt(int catId, String kelime) {
    List<String> yedekOzelIsimler = [
      "ısparta",
      "ığdır",
      "içel",
      "iskenderun",
      "izmir",
      "istanbul",
      "isveç",
      "isviçre",
      "ispanya",
      "italya",
      "irlanda",
      "israil",
      "izlanda",
      "ingiltere"
    ];
    return yedekOzelIsimler.contains(kelime);
  }

// ---------------- BÖLÜM 7 SONU ----------------

// ==========================================
// BÖLÜM 8: Toplu Değerlendirme ve Gemini Yapay Zeka Entegrasyonu
// ==========================================
  Future<List<int>> topluDegerlendirmeMotoru(
      List<Map<String, dynamic>> sorgular, String secilenHarf) async {
    final db = await instance.database;
    List<int> sonuclar = List.filled(sorgular.length, 0);
    List<Map<String, dynamic>> geminiyeGidecekler = [];

    for (int i = 0; i < sorgular.length; i++) {
      int catId = sorgular[i]["id"];
      String kelime = sorgular[i]["cvp"].toString().trim();
      if (kelime.isEmpty || kelime == "-") continue;

      String girilenIlkharf = trToLowerCase(kelime[0]);
      String arananHarf = trToLowerCase(secilenHarf);

      if (girilenIlkharf != arananHarf) continue;

      bool tdkOnayi = await _checkWordInDb(catId, secilenHarf, kelime);

      if (tdkOnayi) {
        sonuclar[i] = 1;
      } else if (catId != 2 && catId != 6) {
        geminiyeGidecekler
            .add({"index": i, "catId": catId, "kelime": trToLowerCase(kelime)});
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

            await db.insert(
                'words',
                {
                  'category_id': catId,
                  'first_letter': trToLowerCase(secilenHarf[0]),
                  'word_value': kelime,
                },
                conflictAlgorithm: ConflictAlgorithm.ignore);

            try {
              await FirebaseFirestore.instance
                  .collection('onaylanmis_yeni_kelimeler')
                  .add({
                'kelime': kelime,
                'kategori_id': catId,
                'harf': trToLowerCase(secilenHarf[0]),
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
    String kucukHarf = trToLowerCase(harf);

    String arananHarfBuyuk = kucukHarf.toUpperCase();
    if (kucukHarf == 'ı')
      arananHarfBuyuk = 'I';
    else if (kucukHarf == 'i')
      arananHarfBuyuk = 'İ';
    else if (kucukHarf == 'ğ')
      arananHarfBuyuk = 'Ğ';
    else if (kucukHarf == 'ü')
      arananHarfBuyuk = 'Ü';
    else if (kucukHarf == 'ş')
      arananHarfBuyuk = 'Ş';
    else if (kucukHarf == 'ö')
      arananHarfBuyuk = 'Ö';
    else if (kucukHarf == 'ç') arananHarfBuyuk = 'Ç';

    List<String> harfIhtimalleri = [kucukHarf, arananHarfBuyuk];
    String placeholders = List.filled(harfIhtimalleri.length, '?').join(', ');

    List<Map<String, dynamic>> res = await db.query(
      'words',
      where: 'category_id = ? AND first_letter IN ($placeholders)',
      whereArgs: [catId, ...harfIhtimalleri],
    );

    if (res.isNotEmpty) {
      List<Map<String, dynamic>> mutableRes = List.from(res);
      mutableRes.shuffle();
      return mutableRes.first['word_value'] as String?;
    }
    return null;
  }

// ---------------- BÖLÜM 9 SONU ----------------

// ==========================================
// BÖLÜM 10: Oyuncu ve Bot Skorlarını Kaydetme ve Çekme İşlemleri
// ==========================================
  Future<int> getOyuncuSkor() async {
    final db = await instance.database;
    List<Map<String, dynamic>> res = await db.query('oyuncu');
    if (res.isNotEmpty) {
      return res.first['skor'] as int;
    }
    return 0;
  }

  Future<void> saveOyuncuSkor(String oyuncuAdi, int eklenecekSkor) async {
    final db = await instance.database;
    int mevcutSkor = await getOyuncuSkor();
    int yeniToplamSkor = mevcutSkor + eklenecekSkor;

    await db.insert(
      'oyuncu',
      {'id': 1, 'skor': yeniToplamSkor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    try {
      String isim = oyuncuAdi.isEmpty ? "Tokatlı60" : oyuncuAdi;
      await FirebaseFirestore.instance
          .collection('liderlik_tablosu')
          .doc(isim)
          .set({
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

    List<Map<String, dynamic>> res = await db.query(
      'botlar',
      where: 'bot_adi = ?',
      whereArgs: [botAdi],
    );

    if (res.isEmpty) return;

    int mevcut = res.first['skor'] as int;
    int yeniBotSkor = mevcut + eklenecekSkor;

    await db.update(
      'botlar',
      {'skor': yeniBotSkor},
      where: 'bot_adi = ?',
      whereArgs: [botAdi],
    );

    try {
      await FirebaseFirestore.instance
          .collection('liderlik_tablosu')
          .doc(botAdi)
          .set({
        'kullanici_adi': botAdi,
        'skor': yeniBotSkor,
        'is_bot': true,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Firebase bot skor güncelleme hatası: $e");
    }
  }

// ---------------- BÖLÜM 10 SONU ----------------

// ==========================================
// BÖLÜM 11: Liderlik Tablosunu (Sıralamayı) Oluşturma
// ==========================================
/*Future<List<Map<String, dynamic>>> getTumLiderlikTablosu(String oyuncuAdi) async {
    final db = await instance.database;
    int oyuncuSkor = await getOyuncuSkor();
    String isim = oyuncuAdi.isEmpty ? "Tokatlı60" : oyuncuAdi;

    List<Map<String, dynamic>> botlar = await db.query('botlar');
    List<Map<String, dynamic>> hepsi = [];

    hepsi.add({'bot_adi': isim, 'skor': oyuncuSkor});
    for (var bot in botlar) {
      hepsi.add({'bot_adi': bot['bot_adi'], 'skor': bot['skor']});
    }

    hepsi.sort((a, b) => (b['skor'] as int).compareTo(a['skor'] as int));

    return hepsi;
  }
// ---------------- BÖLÜM 11 SONU ----------------*/

// ==========================================
// BÖLÜM 12: Eşleştirme İçin Rastgele Bot Seçme
// ==========================================
  Future<Map<String, dynamic>> getRandomBot(
      {List<String>? haricTutulacakBotlar}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> botlar = await db.query('botlar');

    if (botlar.isNotEmpty) {
      List<Map<String, dynamic>> secilebilirBotlar = List.from(botlar);

      if (haricTutulacakBotlar != null && haricTutulacakBotlar.isNotEmpty) {
        secilebilirBotlar
            .removeWhere((b) => haricTutulacakBotlar.contains(b['bot_adi']));
      }

      if (secilebilirBotlar.isEmpty) {
        secilebilirBotlar = List.from(botlar);
      }

      secilebilirBotlar.shuffle();
      return secilebilirBotlar.first;
    }
    return {'bot_adi': 'Ahmet_34', 'skor': 3000};
  }

// ---------------- BÖLÜM 12 SONU ----------------
// ==========================================

// BÖLÜM 13: Hızlı ve Sıfır Maliyetli Sıralama / Toplam Oyuncu Sayacı
// ==========================================
  Future<Map<String, int>> getHizliSiralamaVeToplamOyuncu(
      int benimSkorum) async {
    final db = await instance.database;

    // 1. Üstümdeki Botları Say (Yerel SQLite - 0 Maliyet)
    var botResult = await db
        .rawQuery('SELECT COUNT(*) FROM botlar WHERE skor > ?', [benimSkorum]);
    int ustumdekiBotSayisi = Sqflite.firstIntValue(botResult) ?? 0;

    int ustumdekiGercekOyuncuSayisi = 0;
    int toplamGercekOyuncuSayisi = 0;

    try {
      // 2. Firebase: Benden yüksek puanlı gerçek oyuncuları SAY (Sıralamam için)
      var ustumdekilerSnapshot = await FirebaseFirestore.instance
          .collection('liderlik_tablosu')
          .where('is_bot', isEqualTo: false)
          .where('skor', isGreaterThan: benimSkorum)
          .count()
          .get()
          .timeout(const Duration(seconds: 5));
      ustumdekiGercekOyuncuSayisi = ustumdekilerSnapshot.count ?? 0;

      // 3. Firebase: Toplam gerçek oyuncu sayısını SAY (Payda için)
      var toplamGercekSnapshot = await FirebaseFirestore.instance
          .collection('liderlik_tablosu')
          .where('is_bot', isEqualTo: false)
          .count()
          .get()
          .timeout(const Duration(seconds: 5));
      toplamGercekOyuncuSayisi = toplamGercekSnapshot.count ?? 0;
    } catch (e) {
      print(
          "🚨 Sıralama sayılırken Firebase hatası (İndeks eksik veya İnternet yok olabilir): $e");
    }

    // 4. Matematiksel Hesaplama
    int benimSiralamam = ustumdekiBotSayisi + ustumdekiGercekOyuncuSayisi + 1;
    int gercekKisiSayisi = max(1, toplamGercekOyuncuSayisi);
    int toplamOyuncu = 1000 + gercekKisiSayisi;

    // Sonuçları küçük bir paket olarak sayfaya yolla
    return {
      'sira': benimSiralamam,
      'toplam': toplamOyuncu,
    };
  }
// ---------------- BÖLÜM 13 SONU ----------------
} // <--- DOSYANIN EN SONUNDAKİ KAPANIŞ PARANTEZİ
