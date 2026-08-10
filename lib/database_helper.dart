import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tdk_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

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
      version: 30, // 🎯
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

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

    await db.insert('oyuncu', {'id': 1, 'skor': 0}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await _1000BotuVeritabaninaEkle(db);
    await _sqlDosyasindanKelimeleriYukle(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 🎯 BURASI ÇOK ÖNEMLİ: Kod her güncellendiğinde eski kelime havuzunu silip yenisini %100 yükleyecek
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

    if (oldVersion < 6) {
      await db.delete('botlar');
      await _1000BotuVeritabaninaEkle(db);
    }
  }

  // 🎯 GÜVENLİ VE HIZLI SQL YÜKLEME
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

  // 🚀 1.000 KİŞİLİK CANLI VE DİNAMİK BOT HAVUZU OLUŞTURMA
  static Future<void> _1000BotuVeritabaninaEkle(Database db) async {
    List<String> sehirKodlari = ["34", "06", "35", "16", "07", "01", "60", "61", "55", "42", "22", "10", "20", "26", "27", "33", "41", "45", "54"];
    List<String> unvanlar = ["Pro", "Star", "Master", "Kral", "Efsane", "Gamer", "Kaptan", "TR", "X", "Uzman", "Atak", "Zeki", "Hizli", "Guc", "Lider"];
    List<String> temelIsimler = [
      "Ahmet", "Mehmet", "Ayse", "Fatma", "Mustafa", "Emre", "Can", "Zeynep", "Elif", "Burak",
      "Deniz", "Ece", "Serkan", "Gamze", "Kaan", "Merve", "Omer", "Selin", "Murat", "Buse",
      "Onur", "Gokhan", "Hande", "Kadir", "Tugba", "Yasin", "Hakan", "Dilara", "Doruk", "Bora",
      "Tolga", "Sibel", "Koray", "Pinar", "Eren", "Derya", "Volkan", "Ezgi", "Kerem", "Gizem"
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

    unawaited(Future(() async {
      try {
        var collectionRef = FirebaseFirestore.instance.collection('liderlik_tablosu');
        WriteBatch fbBatch = FirebaseFirestore.instance.batch();
        int count = 0;

        for (var bot in botListesi) {
          DocumentReference docRef = collectionRef.doc(bot['bot_adi']);
          fbBatch.set(docRef, {
            'kullanici_adi': bot['bot_adi'],
            'skor': bot['skor'],
            'is_bot': true,
          }, SetOptions(merge: true));

          count++;
          if (count % 400 == 0) {
            await fbBatch.commit();
            fbBatch = FirebaseFirestore.instance.batch();
          }
        }
        if (count % 400 != 0) {
          await fbBatch.commit();
        }
      } catch (e) {
        print("Firebase 1000 bot senkronizasyon hatası: $e");
      }
    }));
  }

  // 🎯 TÜRKÇE HARF DUYARLI KÜÇÜK HARF DÖNÜŞTÜRÜCÜ
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

  // 🎯 İLK HARF ŞARTINI VE İ/I HARF TOLERANSINI KONTROL EDEN METOD
  Future<int> checkWordWithToleranceAndTdk(int catId, String harf, String kelime) async {
    String temizKelime = kelime.trim();
    if (temizKelime.isEmpty || temizKelime == "-") return 0;

    String girilenIlkharf = trToLowerCase(temizKelime[0]);
    String secilenHarf = trToLowerCase(harf);

    bool harfUyumluMu = (girilenIlkharf == secilenHarf) ||
        (girilenIlkharf == 'i' && secilenHarf == 'ı') ||
        (girilenIlkharf == 'ı' && secilenHarf == 'i');

    if (!harfUyumluMu) {
      return 0;
    }

    bool tamDogru = await _checkWordInDbOrTdk(catId, harf, temizKelime);

    if (tamDogru) {
      return 1;
    } else {
      return 0;
    }
  }

  // 🎯 KUSURSUZ DOĞRULAMA (ÜLKELER DAHİL HER ŞEYİ KÜÇÜK HARF YAPARAK KIYASLAR)
  Future<bool> _checkWordInDbOrTdk(int catId, String harf, String kelime) async {
    final db = await instance.database;

    // 🎯 DÜZELTME: Kategori ne olursa olsun, girilen kelimeyi kontrol için %100 küçük harfe çeviriyoruz.
    // Bu sayede kullanıcı "tüRkiye" de yazsa, "TÜRKİYE" de yazsa veritabanında kesinlikle bulunur.
    String arananKelime = trToLowerCase(kelime.trim());
    String arananHarf = trToLowerCase(harf.trim()[0]);

    List<Map<String, dynamic>> res = await db.query(
      'words',
      where: 'category_id = ? AND (first_letter = ? OR LOWER(first_letter) = ?)',
      whereArgs: [catId, arananHarf, arananHarf],
    );

    for (var row in res) {
      // Veritabanındaki kelimeyi de kıyaslama için küçük harfe çeviriyoruz.
      String dbKelime = trToLowerCase(row['word_value'].toString().trim());

      // Kelime birebir uyuşuyor mu veya boşluksuz hali tutuyor mu?
      if (dbKelime == arananKelime || dbKelime.replaceAll(' ', '') == arananKelime.replaceAll(' ', '')) {
        return true; // ✅ VERİTABANINDA BULUNDU, PUANI VER!
      }
    }

    bool ozelIsimGecerli = _ozelIsimKontrolEt(catId, arananKelime);
    if (ozelIsimGecerli) {
      await db.insert('words', {
        'category_id': catId,
        'first_letter': arananHarf,
        'word_value': kelime.trim(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      return true;
    }

    if (catId == 1 || catId == 2 || catId == 6) {
      return false;
    }

    try {
      bool tdkGecerli = await TdkService.kelimeyiTdkdanDogrula(catId, arananKelime);
      if (tdkGecerli) {
        await db.insert('words', {
          'category_id': catId,
          'first_letter': arananHarf,
          'word_value': kelime.trim(),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        return true;
      }
    } catch (e) {
      print("TDK Servis Kontrol Hatası: $e");
    }

    return false;
  }

  bool _ozelIsimKontrolEt(int catId, String kelime) {
    List<String> yedekOzelIsimler = [
      "irlanda", "italya", "isvec", "isvicre", "ingiltere", "ispanya", "israil", "izlanda",
      "istanbul", "izmir", "isparta", "igdir", "icel", "iskenderun"
    ];
    return yedekOzelIsimler.contains(kelime);
  }

  Future<String?> getBotKelime(int catId, String harf) async {
    final db = await instance.database;
    String kucukHarf = trToLowerCase(harf);

    List<Map<String, dynamic>> res = await db.query(
      'words',
      where: 'category_id = ? AND (first_letter = ? OR LOWER(first_letter) = ?)',
      whereArgs: [catId, kucukHarf, kucukHarf],
    );

    if (res.isNotEmpty) {
      List<Map<String, dynamic>> mutableRes = List.from(res);
      mutableRes.shuffle();
      return mutableRes.first['word_value'] as String?;
    }
    return null;
  }

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
    List<Map<String, dynamic>> res = await db.query(
      'botlar',
      where: 'bot_adi = ?',
      whereArgs: [botAdi],
    );

    int mevcut = res.isNotEmpty ? (res.first['skor'] as int) : 0;
    int yeniBotSkor = mevcut + eklenecekSkor;

    await db.insert(
      'botlar',
      {
        'bot_adi': botAdi,
        'skor': yeniBotSkor,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    try {
      await FirebaseFirestore.instance.collection('liderlik_tablosu').doc(botAdi).set({
        'kullanici_adi': botAdi,
        'skor': yeniBotSkor,
        'is_bot': true,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getTumLiderlikTablosu(String oyuncuAdi) async {
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

  Future<Map<String, dynamic>> getRandomBot({List<String>? haricTutulacakBotlar}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> botlar = await db.query('botlar');

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
}