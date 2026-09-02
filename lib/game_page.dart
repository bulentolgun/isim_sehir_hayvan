import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'l10n/app_localizations.dart'; // 🚀 Doğru Çeviri Yolu
import 'database_helper.dart';
import 'result_page.dart';
import 'ad_service.dart';
import 'main.dart'; // 🚀 DİL KONTROLÜ İÇİN EKLENDİ

class GamePage extends StatefulWidget {
  final String oyuncuAdi;
  final String rakipAdi;
  final int yuzIndex;
  final int aksesuarIndex;
  final int renkIndex;
  final int mevcutTur;
  final int toplamTurSayisi;
  final int oyuncuKumulatifSkor;
  final int rakip1KumulatifSkor;
  final String? secilenHarf;
  final String? odaKodu;

  const GamePage({
    super.key,
    required this.oyuncuAdi,
    required this.rakipAdi,
    required this.yuzIndex,
    required this.aksesuarIndex,
    required this.renkIndex,
    required this.mevcutTur,
    required this.toplamTurSayisi,
    required this.oyuncuKumulatifSkor,
    required this.rakip1KumulatifSkor,
    this.secilenHarf,
    this.odaKodu,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {

// ==========================================
// BÖLÜM 1: Temel Değişkenler ve Oyun Durumları
// ==========================================
  final List<Map<String, dynamic>> kategoriler = const [
    {"id": 1, "isim": "İsim", "icon": Icons.groups},
    {"id": 2, "isim": "Şehir", "icon": Icons.home},
    {"id": 3, "isim": "Hayvan", "icon": Icons.pets},
    {"id": 4, "isim": "Bitki", "icon": Icons.eco},
    {"id": 5, "isim": "Eşya", "icon": Icons.handyman},
    {"id": 6, "isim": "Ülke", "icon": Icons.flag},
  ];

  String getKategoriIsmi(int id, AppLocalizations l10n) {
    switch (id) {
      case 1: return l10n.catName;
      case 2: return l10n.catCity;
      case 3: return l10n.catAnimal;
      case 4: return l10n.catPlant;
      case 5: return l10n.catObject;
      case 6: return l10n.catCountry;
      default: return "";
    }
  }

  int aktifKategoriIndex = 0;
  final TextEditingController _inputController = TextEditingController();

  late String ben;
  List<String> masadakiHerkes = [];
  Map<String, Map<int, String>> tumCevaplar = {};
  Map<String, Map<int, int>> tumKategoriPuanlari = {};
  Map<String, int> tumTurPuanlari = {};
  Map<int, Map<String, int>> gecmisTurPuanlari = {};
  Map<String, int> genelKumulatifSkorlar = {};
  Map<String, int> macSkorlari = {};

  List<int> botTurBasariOranlari = [];

  bool turBittiMi = false;
  bool erkenBitirmeBonusuKazandiMi = false;
  bool rakipBekleniyor = false;
  bool isLoading = false;
  bool _hukmenGalibiyetGosterildi = false;
  bool _elenmeGosterildi = false;
  final List<String> _toleransBeklenenler = [];
  bool benHazirMiyim = false;
  int hazirOyuncuSayisi = 0;
  bool _isTransitioning = false;
  Timer? _guvenlikTimer;
  Timer? _kopyaTimer;
  int _kalanGuvenlikSaniyesi = 30;

  bool _kopyaIcinArkaPlanaGitti = false;
  bool _reklamAcik = false;

  String odadakiErkenBitirenKisi = "";
  String secilenHarf = "A";
  Timer? _timer;

  DatabaseReference? _benimPresenceRef;
  StreamSubscription<DatabaseEvent>? _presenceSubscription;
  StreamSubscription<DocumentSnapshot>? _odaSubscription;

  int _kalanSure = 90;
  late int _guncelMevcutTur;
  int _seciliRakipIndex = 1;

  final List<String> yasakliKelimeler = const [
    "amk", "sik", "piç", "orospu", "oç", "sg", "yarrak",
    "göt", "meme", "dalyarak", "pezevenk", "kaltak", "fahişe"
  ];
  List<String> kullanilanHarfler = [];

// ==========================================
// BÖLÜM 2: Türkçe Karakterleri Düzeltme Kodları
// ==========================================
  String trToLowerCase(String text) {
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

  String trToUpperCase(String text) {
    return text
        .replaceAll('i', 'İ')
        .replaceAll('ı', 'I')
        .replaceAll('ğ', 'Ğ')
        .replaceAll('ü', 'Ü')
        .replaceAll('ş', 'Ş')
        .replaceAll('ö', 'Ö')
        .replaceAll('ç', 'Ç')
        .toUpperCase();
  }

// ==========================================
  // ==========================================
// BÖLÜM 2.5: ÇOK DİLLİ ALFABE SİSTEMİ 🌍
// ==========================================
  List<String> _getAlfabe() {
    String lang = appLocale.value.languageCode;

    if (lang == 'en') {
      return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
    } else if (lang == 'de') {
      return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Ä", "Ö", "Ü"];
    } else if (lang == 'es') {
      return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Ñ"];
    } else {
      // Varsayılan (Türkçe)
      return ["A", "B", "C", "Ç", "D", "E", "F", "G", "H", "I", "İ", "J", "K", "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"];
    }
  }
// ---------------- BÖLÜM 2.5 SONU ----------------
// BÖLÜM 3: Sayfa İlk Açıldığında Çalışan Kurallar (initState)
// ==========================================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _guncelMevcutTur = widget.mevcutTur;

    ben = widget.oyuncuAdi.trim().isEmpty ? "Tokatlı60" : widget.oyuncuAdi.trim();
    List<String> rakipler = widget.rakipAdi
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (rakipler.isEmpty) rakipler = ["Rakip"];

    masadakiHerkes = [ben, ...rakipler];

    for (var p in masadakiHerkes) {
      tumCevaplar[p] = {};
      tumKategoriPuanlari[p] = {};
      tumTurPuanlari[p] = 0;
      macSkorlari[p] = 0;
      genelKumulatifSkorlar[p] =
      (p == ben) ? widget.oyuncuKumulatifSkor : widget.rakip1KumulatifSkor;
    }

    _gercekSkorlariYukle();
    AdService.instance.loadInterstitialAd();
    _canliOdaDinle();
    _presenceSisteminiBaslat();
    _yeniTurBaslat(ilkBaslangic: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _timer?.cancel();
    _guvenlikTimer?.cancel();
    _odaSubscription?.cancel();
    _kopyaTimer?.cancel();

    _presenceSubscription?.cancel();
    _benimPresenceRef?.remove();

    _inputController.dispose();

    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
      FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
        'aktifOyuncular': FieldValue.arrayRemove([ben])
      }).catchError((e) => print("Çıkış bildirimi gönderilemedi: $e"));
    }

    super.dispose();
  }

  /// ==========================================
// BÖLÜM 3.5: Uygulama Yaşam Döngüsü (Gizli Kopya Koruması)
// ==========================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused &&
        _kalanSure > 0 &&
        !turBittiMi &&
        !isLoading &&
        !rakipBekleniyor &&
        !_reklamAcik) {

      _kopyaTimer?.cancel();
      _kopyaTimer = Timer(const Duration(seconds: 5), () {
        if (!mounted) return;

        setState(() {
          _kopyaIcinArkaPlanaGitti = true;
          for (var kat in kategoriler) {
            tumCevaplar.putIfAbsent(ben, () => {})[kat["id"]] = "-";
          }
          _inputController.clear();
          _timer?.cancel();
        });

        _cevaplariFirebaseeGonderAndDegerlendir();
      });
    }
    else if (state == AppLifecycleState.resumed) {
      if (_kopyaTimer != null && _kopyaTimer!.isActive) {
        _kopyaTimer!.cancel();
      }
      else if (_kopyaIcinArkaPlanaGitti) {
        _kopyaIcinArkaPlanaGitti = false;

        final l10n = AppLocalizations.of(context);
        if (l10n != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.cheatingWarning),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ));
        }
      }
    }
  }
// ---------------- BÖLÜM 3.5 SONU ----------------
// ==========================================
// BÖLÜM 4: Rakiplerin ve Sizin Genel Skorunuzu Çeken Kod
// ==========================================
  Future<void> _gercekSkorlariYukle() async {
    int benimGuncelSkorum = await DatabaseHelper.instance.getOyuncuSkor();
    if (mounted) {
      setState(() {
        genelKumulatifSkorlar[ben] = benimGuncelSkorum;
      });
    }

    final db = await DatabaseHelper.instance.database;

    for (var p in masadakiHerkes) {
      if (p != ben) {
        int rakipSkor = widget.rakip1KumulatifSkor;

        if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
          try {
            var doc = await FirebaseFirestore.instance
                .collection('liderlik_tablosu')
                .doc(p)
                .get();
            if (doc.exists) rakipSkor = doc.data()?['skor'] ?? 0;
          } catch (e) {
            print("Rakip skoru çekilemedi: $e");
          }
        } else {
          var res = await db.query('botlar', where: 'bot_adi = ?', whereArgs: [p]);
          if (res.isNotEmpty) {
            rakipSkor = res.first['skor'] as int;
          }
        }

        if (mounted) {
          setState(() {
            genelKumulatifSkorlar[p] = rakipSkor;
          });
        }
      }
    }
  }

// ==========================================
// BÖLÜM 5: Firebase Üzerinden Canlı Odayı Dinleyen Kod
// ==========================================
  void _canliOdaDinle() {
    if (widget.odaKodu == null || widget.odaKodu!.isEmpty) return;

    _odaSubscription = FirebaseFirestore.instance
        .collection('odalar')
        .doc(widget.odaKodu)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists || !mounted) return;

      var data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> dbAktifOyuncular = data['aktifOyuncular'] ?? [];
      String anlikKurucu = data['kurucu']?.toString().trim() ?? "";

      if (dbAktifOyuncular.length < masadakiHerkes.length) {

        List<String> dusenler = masadakiHerkes.where((p) {
          String cleanP = trToLowerCase(p.trim());
          return !dbAktifOyuncular.any((aktif) => trToLowerCase(aktif.toString().trim()) == cleanP);
        }).toList();

        for (String dusenKisi in dusenler) {
          if (!masadakiHerkes.contains(dusenKisi)) continue;

          if (trToLowerCase(dusenKisi.trim()) == trToLowerCase(ben.trim())) {
            _oyundanElendimIsleminiBaslat();
            return;
          }

          setState(() {
            masadakiHerkes.remove(dusenKisi);
          });

          final l10n = AppLocalizations.of(context);
          if (l10n != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.playerEliminatedWarning(dusenKisi)),
              backgroundColor: Colors.orange.shade900,
              duration: const Duration(seconds: 4),
            ));
          }

          if (odadakiErkenBitirenKisi == dusenKisi) {
            setState(() => odadakiErkenBitirenKisi = "");
          }

          if (trToLowerCase(dusenKisi.trim()) == trToLowerCase(anlikKurucu) && dbAktifOyuncular.isNotEmpty) {
            String yeniKurucu = dbAktifOyuncular.first.toString();
            if (trToLowerCase(yeniKurucu.trim()) == trToLowerCase(ben.trim())) {
              await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
                'kurucu': ben
              });
              anlikKurucu = ben;
              if (mounted && l10n != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(l10n.newHostWarning),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ));
              }
            }
          }
        }

        if (masadakiHerkes.length <= 1) {
          _hukmenGalibiyetIsleminiBaslat();
          return;
        }

        if (turBittiMi && hazirOyuncuSayisi >= masadakiHerkes.length) {
          if (trToLowerCase(anlikKurucu) == trToLowerCase(ben) || _guncelMevcutTur >= widget.toplamTurSayisi) {
            _sonrakiTuraGec();
          }
        }

        if (rakipBekleniyor) {
          var anlikCevaplar = data['cevaplar'] as Map<String, dynamic>? ?? {};
          bool herkesCevapVerdiMi = true;
          for (var p in masadakiHerkes) {
            if (!anlikCevaplar.containsKey(p)) {
              herkesCevapVerdiMi = false;
              break;
            }
          }
          String kurucuGuncel = (data['kurucu'] ?? anlikKurucu).toString().trim();
          if (herkesCevapVerdiMi && (trToLowerCase(kurucuGuncel) == trToLowerCase(ben) || trToLowerCase(anlikKurucu) == trToLowerCase(ben))) {
            await _hostPuanlariHesaplaVeKaydet();
          }
        }
      }

      var cevaplarMap = data['cevaplar'] as Map<String, dynamic>? ?? {};
      var puanlarMap = data['puanlar'] as Map<String, dynamic>? ?? {};
      List<dynamic> hazirOyuncular = data['hazirOyuncular'] ?? [];
      String kurucu = (data['kurucu'] ?? "").toString().trim();
      int odaTur = data['mevcutTur'] ?? 1;
      String yeniHarf = data['secilenHarf'] ?? "A";

      String dbErkenBitiren = data['erkenBitiren'] ?? "";
      if (dbErkenBitiren.isNotEmpty && !erkenBitirmeBonusuKazandiMi) {
        setState(() {
          odadakiErkenBitirenKisi = dbErkenBitiren;
          erkenBitirmeBonusuKazandiMi = true;
          if (_kalanSure > 20) _kalanSure = 20;
        });
      }

      if (odaTur > _guncelMevcutTur) {
        if (_hukmenGalibiyetGosterildi || _elenmeGosterildi) return;

        _guvenlikTimer?.cancel();
        setState(() {
          for (var p in masadakiHerkes) {
            macSkorlari[p] = (macSkorlari[p] ?? 0) + (tumTurPuanlari[p] ?? 0);
            genelKumulatifSkorlar[p] = (genelKumulatifSkorlar[p] ?? 0) + (tumTurPuanlari[p] ?? 0);
            tumTurPuanlari[p] = 0;
          }
          _guncelMevcutTur = odaTur;
          aktifKategoriIndex = 0;
          benHazirMiyim = false;
          secilenHarf = yeniHarf;
          odadakiErkenBitirenKisi = "";
          _seciliRakipIndex = 1;
          _yeniTurBaslat(ilkBaslangic: false, firebaseHarfi: yeniHarf);
        });
        return;
      }

      cevaplarMap.forEach((kullanici, cevaplar) {
        String kName = kullanici.toString().trim();
        if (trToLowerCase(kName) != trToLowerCase(ben) && masadakiHerkes.contains(kName)) {
          Map<dynamic, dynamic> rawCevap = cevaplar as Map<dynamic, dynamic>;
          rawCevap.forEach((k, v) {
            tumCevaplar.putIfAbsent(kName, () => {})[int.parse(k.toString())] = v.toString();
          });
        }
      });

      if (turBittiMi) {
        if (mounted) setState(() { hazirOyuncuSayisi = hazirOyuncular.length; });
        if (hazirOyuncuSayisi >= masadakiHerkes.length) {
          if (trToLowerCase(kurucu) == trToLowerCase(ben) || _guncelMevcutTur >= widget.toplamTurSayisi) {
            _sonrakiTuraGec();
          }
        }
      }

      if (puanlarMap.isNotEmpty && trToLowerCase(kurucu) != trToLowerCase(ben)) {
        puanlarMap.forEach((kullanici, pMap) {
          String kName = kullanici.toString().trim();
          if (masadakiHerkes.contains(kName)) {
            int toplam = 0;
            Map<String, dynamic> rawP = pMap as Map<String, dynamic>? ?? {};
            rawP.forEach((k, v) {
              int val = (v as num).toInt();
              tumKategoriPuanlari.putIfAbsent(kName, () => {})[int.parse(k)] = val;
              toplam += val;
            });
            tumTurPuanlari[kName] = toplam;
          }
        });

        if (odadakiErkenBitirenKisi.isNotEmpty && masadakiHerkes.contains(odadakiErkenBitirenKisi)) {
          tumTurPuanlari[odadakiErkenBitirenKisi] = (tumTurPuanlari[odadakiErkenBitirenKisi] ?? 0) + 10;
        }

        if (mounted && !turBittiMi) {
          setState(() {
            turBittiMi = true;
            rakipBekleniyor = false;
            Map<String, int> buTurPuanlari = {};
            tumTurPuanlari.forEach((key, value) => buTurPuanlari[key] = value);
            gecmisTurPuanlari[_guncelMevcutTur] = buTurPuanlari;
          });
          _guvenlikSayaciniBaslat();
        }
        return;
      }

      if (rakipBekleniyor && cevaplarMap.length >= masadakiHerkes.length && trToLowerCase(kurucu) == trToLowerCase(ben) && !turBittiMi) {
        setState(() { rakipBekleniyor = false; });
        await _hostPuanlariHesaplaVeKaydet();
        _guvenlikSayaciniBaslat();
      }
    });
  }

// ==========================================
/// ==========================================
// BÖLÜM 5.5: Hükmen Galibiyet Operasyonu (GÜNCELLENDİ)
// ==========================================
Future<void> _hukmenGalibiyetIsleminiBaslat() async {
if (!mounted || _hukmenGalibiyetGosterildi) return;
_hukmenGalibiyetGosterildi = true;
_isTransitioning = true;

_timer?.cancel();
_guvenlikTimer?.cancel();
_kopyaTimer?.cancel();

// 🚀 KRİTİK MÜDAHALE: Ekran kilitlenmesini önlemek için tüm beklemeleri iptal et!
setState(() {
isLoading = false;
rakipBekleniyor = false;
});

final l10n = AppLocalizations.of(context)!;

showDialog(
context: context,
barrierDismissible: false,
builder: (context) => AlertDialog(
backgroundColor: Colors.purple.shade900,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
title: Column(
children: [
const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
const SizedBox(height: 10),
Text(l10n.winByForfeitTitle, style: const TextStyle(color: Colors.amber)),
],
),
content: Text(
l10n.winByForfeitDesc,
textAlign: TextAlign.center,
style: const TextStyle(color: Colors.white, fontSize: 16),
),
actionsAlignment: MainAxisAlignment.center,
actions: [
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.greenAccent.shade700,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
onPressed: () {
Navigator.pop(context);
setState(() {
_guncelMevcutTur = widget.toplamTurSayisi;

int enYuksekRakipPuan = 0;
macSkorlari.forEach((key, value) {
if (key != ben && value > enYuksekRakipPuan) {
enYuksekRakipPuan = value;
}
});

int benimGuncelSkorum = macSkorlari[ben] ?? 0;

if (benimGuncelSkorum <= enYuksekRakipPuan) {
macSkorlari[ben] = enYuksekRakipPuan + 10;
} else {
macSkorlari[ben] = benimGuncelSkorum + 10;
}
});

_isTransitioning = false;
_sonrakiTuraGec();
},
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
child: Text(l10n.goToResultsButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
),
)
],
),
);
}
// ---------------- BÖLÜM 5.5 SONU ----------------
// ==========================================
// BÖLÜM 5.6: Oyundan Elenme (Boş Kağıt veya Kopma)
// ==========================================
  Future<void> _oyundanElendimIsleminiBaslat() async {
    if (!mounted || _elenmeGosterildi) return;
    _elenmeGosterildi = true;
    _isTransitioning = true;

    _timer?.cancel();
    _guvenlikTimer?.cancel();
    _kopyaTimer?.cancel();

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.sentiment_very_dissatisfied, color: Colors.white, size: 50),
            const SizedBox(height: 10),
            Text(l10n.eliminatedTitle, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          l10n.eliminatedDesc,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(l10n.returnToMainMenuButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

// ==========================================
// BÖLÜM 6: Zombi Koruması (Güvenlik Sayacı) GÜNCELLENDİ
// ==========================================
  void _guvenlikSayaciniBaslat() {
    _guvenlikTimer?.cancel();
    _kalanGuvenlikSaniyesi = 30;
    _guvenlikTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_kalanGuvenlikSaniyesi > 1) {
          _kalanGuvenlikSaniyesi--;
        } else {
          timer.cancel();
          _zamanAsimiKurtarmaOperasyonu();
        }
      });
    });
  }

  Future<void> _zamanAsimiKurtarmaOperasyonu() async {
    if (!benHazirMiyim) {
      await _hazirButonunaBasildi();
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await _zorlaTuruAtlatKontrolu();
  }

  Future<void> _zorlaTuruAtlatKontrolu() async {
    if (widget.odaKodu == null || widget.odaKodu!.isEmpty) return;

    // 🚀 YENİ MANTIK: Artık "Kurucu muyum?" diye kontrol etmiyoruz.
    // Süre bittiğinde odadaki HERKES turu atlatma isteği gönderebilir.
    // Ancak BÖLÜM 21'de kurduğumuz Transaction (Şartlı Güncelleme) sayesinde
    // sadece İLK ulaşan komut işlenecek, diğerleri reddedilecek.
    _sonrakiTuraGec();
  }
// BÖLÜM 7: Hazır Butonuna Tıklandığında
// ==========================================
  Future<void> _hazirButonunaBasildi() async {
    if (benHazirMiyim) return;
    if (mounted) {
      setState(() {
        benHazirMiyim = true;
      });
    }

    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('odalar')
          .doc(widget.odaKodu)
          .update({
        'hazirOyuncular': FieldValue.arrayUnion([ben]),
      });
    } else {
      _sonrakiTuraGec();
    }
  }

// ==========================================
// BÖLÜM 8: Yeni Turu Başlatan ve Temizleyen Kod
// ==========================================
  void _yeniTurBaslat({bool ilkBaslangic = false, String? firebaseHarfi}) {
    _isTransitioning = false;
    _timer?.cancel();
    _guvenlikTimer?.cancel();
    _kopyaTimer?.cancel();
    _inputController.clear();

    if (ilkBaslangic) kullanilanHarfler.clear();

    if (firebaseHarfi != null && firebaseHarfi.isNotEmpty) {
      secilenHarf = firebaseHarfi;
      if (!kullanilanHarfler.contains(secilenHarf)) {
        kullanilanHarfler.add(secilenHarf);
      }
    } else if (widget.secilenHarf != null &&
        widget.secilenHarf!.isNotEmpty &&
        ilkBaslangic) {
      secilenHarf = widget.secilenHarf!;
      if (!kullanilanHarfler.contains(secilenHarf)) {
        kullanilanHarfler.add(secilenHarf);
      }
    } else {
      final tumHarfler = _getAlfabe(); // 🚀 ÇOK DİLLİ ALFABE DEVREDE
      List<String> kullanilabilirHarfler =
      tumHarfler.where((h) => !kullanilanHarfler.contains(h)).toList();
      if (kullanilabilirHarfler.isEmpty) {
        kullanilabilirHarfler = List.from(tumHarfler);
        kullanilanHarfler.clear();
      }
      kullanilabilirHarfler.shuffle();
      secilenHarf = kullanilabilirHarfler.first;
      kullanilanHarfler.add(secilenHarf);
    }

    if (ilkBaslangic || botTurBasariOranlari.isEmpty) {
      botTurBasariOranlari =
      List<int>.filled(widget.toplamTurSayisi, 90, growable: true);
    }

    for (var p in masadakiHerkes) {
      tumCevaplar[p] = {};
      tumKategoriPuanlari[p] = {};
      tumTurPuanlari[p] = 0;
    }

    turBittiMi = false;
    erkenBitirmeBonusuKazandiMi = false;
    rakipBekleniyor = false;
    benHazirMiyim = false;
    hazirOyuncuSayisi = 0;
    _kalanSure = 90;

    odadakiErkenBitirenKisi = "";

    _zamanlayiciyiBaslat();

    if (widget.odaKodu == null || widget.odaKodu!.isEmpty) {
      _botCevaplariniHazirla();
    }
  }

// ==========================================
// BÖLÜM 9: Ana 90 Saniyelik Geri Sayım
// ==========================================
  void _zamanlayiciyiBaslat() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_kalanSure > 0) {
          _kalanSure--;
        } else {
          _timer?.cancel();
          _mevcutKelimeyiKaydet();
          _cevaplariFirebaseeGonderAndDegerlendir();
        }
      });
    });
  }

// ==========================================
// BÖLÜM 10: Botların Cevaplarını Hazırlayan Kod
// ==========================================
  Future<void> _botCevaplariniHazirla() async {
    final random = Random();
    int basariYuzdesi = 90;

    for (var botName in masadakiHerkes) {
      if (botName == ben) continue;
      Map<int, String> geciciCevaplar = {};

      for (var kat in kategoriler) {
        int catId = kat["id"];
        if (random.nextInt(100) < basariYuzdesi) {
          String? botKelime =
          await DatabaseHelper.instance.getBotKelime(catId, secilenHarf);
          geciciCevaplar[catId] = botKelime ?? "-";
        } else {
          geciciCevaplar[catId] = "-";
        }
      }

      if (mounted) {
        setState(() {
          tumCevaplar[botName] = geciciCevaplar;
        });
      }
    }
  }

// ==========================================
// BÖLÜM 11: İlk Harf Doğruluğu
// ==========================================
  bool _harfDogruMu(String kelime) {
    if (kelime.isEmpty || kelime == "-") return true;
    return trToLowerCase(kelime[0]) == trToLowerCase(secilenHarf);
  }

  void _harfUyarisiGoster(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.wrongLetterWarning(secilenHarf)),
      backgroundColor: Colors.orange.shade800,
      duration: const Duration(seconds: 2),
    ));
  }

// ==========================================
// BÖLÜM 12: Kurallara Uygunluk ve Küfür Kontrolü
// ==========================================
  bool _girdiGecerliMi() {
    final l10n = AppLocalizations.of(context)!;
    String metin = trToLowerCase(_inputController.text.trim());
    int currentCatId = kategoriler[aktifKategoriIndex]["id"];

    if (metin.isEmpty) return true;

    List<String> istisnalar = ["sikke", "siklamen"];
    if (!istisnalar.contains(metin)) {
      String noktalamaBozuk = metin.replaceAll(RegExp(r'[.,!?*/\-_]'), '');
      List<String> girilenKelimeler = noktalamaBozuk.split(' ');

      for (var yasakli in yasakliKelimeler) {
        String kucukYasakli = trToLowerCase(yasakli);
        for (var kelime in girilenKelimeler) {
          if (kelime == kucukYasakli || kelime.startsWith(kucukYasakli)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.inappropriateWordWarning),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2)));
            return false;
          }
        }
      }
    }

    if (!_harfDogruMu(metin)) {
      _harfUyarisiGoster(l10n);
      return false;
    }

    if (currentCatId == 1 && metin.contains(" ")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.singleNameWarning),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2)));
      return false;
    }
    return true;
  }

// ==========================================
// BÖLÜM 13: Turu Bitir Aktiflik Kontrolü
// ==========================================
  bool turuBitirAktifMi() {
    if (erkenBitirmeBonusuKazandiMi || rakipBekleniyor || _kalanSure < 20) {
      return false;
    }
    String anlikKelime = _inputController.text.trim();
    int mevcutCatId = kategoriler[aktifKategoriIndex]["id"];
    int bosKutuSayisi = 0;

    for (var kat in kategoriler) {
      int id = kat["id"];
      String cevap =
      (id == mevcutCatId) ? anlikKelime : (tumCevaplar[ben]?[id] ?? "-");
      if (cevap == "-" || cevap.trim().isEmpty || cevap.trim().length < 2) {
        bosKutuSayisi++;
      }
    }
    return bosKutuSayisi <= 1;
  }

// ==========================================
// BÖLÜM 14: Turu Erken Bitir (20 SN BAŞLATICI)
// ==========================================
  void turuErkenBitirIstegi() async {
    if (erkenBitirmeBonusuKazandiMi) return;
    if (!_girdiGecerliMi()) return;
    _mevcutKelimeyiKaydet();

    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('odalar')
          .doc(widget.odaKodu)
          .update({
        'erkenBitiren': ben,
      });
    } else {
      setState(() {
        odadakiErkenBitirenKisi = ben;
        erkenBitirmeBonusuKazandiMi = true;
        if (_kalanSure > 20) _kalanSure = 20;
      });
    }

    FocusManager.instance.primaryFocus?.unfocus();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _reklamAcik = true);

      AdService.instance.showEmniyetliGecisReklami(
        onReklamBitti: () {
          if (!mounted) return;
          setState(() => _reklamAcik = false);

          if (_kalanSure <= 0 && !turBittiMi && !isLoading) {
            _cevaplariFirebaseeGonderAndDegerlendir();
          } else {
            setState(() {});
          }
        },
      );
    });
  }

// ==========================================
// BÖLÜM 15: TDK Kontrolü
// ==========================================
  void _arkaplanTdkKontrol(int catId, String kelime) {
    if (kelime.length >= 2 && kelime != "-") {
      DatabaseHelper.instance
          .checkWordWithToleranceAndTdk(catId, secilenHarf, kelime);
    }
  }

// ==========================================
// BÖLÜM 16: Mevcut Kelimeyi Kaydetme
// ==========================================
  void _mevcutKelimeyiKaydet() {
    if (!_girdiGecerliMi()) {
      _inputController.clear();
    }

    String girilenKelime = _inputController.text.trim();
    int currentCatId = kategoriler[aktifKategoriIndex]["id"];

    if (girilenKelime.isEmpty || girilenKelime.length < 2) {
      tumCevaplar.putIfAbsent(ben, () => {})[currentCatId] = "-";
    } else {
      tumCevaplar.putIfAbsent(ben, () => {})[currentCatId] = girilenKelime;
      _arkaplanTdkKontrol(currentCatId, girilenKelime);
    }
  }

// ==========================================
// BÖLÜM 17: Kategori Değiştirme
// ==========================================
  void kategoriDegistir(int yeniIndex) {
    if (!_girdiGecerliMi()) return;
    _mevcutKelimeyiKaydet();
    setState(() {
      aktifKategoriIndex = yeniIndex;
      int yeniCatId = kategoriler[aktifKategoriIndex]["id"];
      String eskiCevap = tumCevaplar[ben]?[yeniCatId] ?? "";
      _inputController.text = (eskiCevap == "-") ? "" : eskiCevap;
    });
  }

/// ==========================================
// ==========================================
// BÖLÜM 18: Süre Bittiğinde Cevapları Gönder
// ==========================================
  Future<void> _cevaplariFirebaseeGonderAndDegerlendir() async {
    final l10n = AppLocalizations.of(context)!;
    _timer?.cancel();
    _mevcutKelimeyiKaydet();

    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
      try {
        Map<String, String> stringMap = {};
        for (var kat in kategoriler) {
          int id = kat["id"];
          String cevap = tumCevaplar[ben]?[id] ?? "-";
          stringMap[id.toString()] = cevap.trim().isEmpty ? "-" : cevap;
        }

        await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
          'cevaplar.$ben': stringMap,
        });

        // 🚀 KRİTİK MÜDAHALE: Eğer masada yalnız kaldıysam, hemen işlemi iptal et ve hükmeni bekle!
        if (masadakiHerkes.length <= 1) {
          return;
        }

        var doc = await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).get();
        var anlikCevaplar = doc.data()?['cevaplar'] as Map<String, dynamic>? ?? {};

        if (anlikCevaplar.length < masadakiHerkes.length) {
          if (mounted) setState(() { rakipBekleniyor = true; });

          String kurucu = doc.data()?['kurucu']?.toString().trim() ?? "";
          if (trToLowerCase(kurucu) == trToLowerCase(ben)) {
            int beklemeSuresi = _kalanSure > 0 ? (_kalanSure + 7) : 7;
            Future.delayed(Duration(seconds: beklemeSuresi), () async {
              if (mounted && rakipBekleniyor && !turBittiMi) {
                try {
                  var guncelDoc = await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).get();
                  var guncelCevaplar = guncelDoc.data()?['cevaplar'] as Map<String, dynamic>? ?? {};

                  bool eksikVarMi = false;
                  Map<String, dynamic> tamamlanmisCevaplar = Map.from(guncelCevaplar);
                  for (var p in masadakiHerkes) {
                    if (!tamamlanmisCevaplar.containsKey(p)) {
                      eksikVarMi = true;
                      Map<String, String> bosCevap = {};
                      for (var kat in kategoriler) bosCevap[kat["id"].toString()] = "-";
                      tamamlanmisCevaplar[p] = bosCevap;
                    }
                  }
                  if (eksikVarMi) {
                    await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({'cevaplar': tamamlanmisCevaplar});
                  }
                } catch (e) {
                  if (mounted) setState(() => rakipBekleniyor = false);
                }
              }
            });
          }

          Future.delayed(const Duration(seconds: 15), () async {
            if (mounted && rakipBekleniyor && !turBittiMi) {
              try {
                var zDoc = await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).get();
                var zCevaplar = zDoc.data()?['cevaplar'] as Map<String, dynamic>? ?? {};

                bool zEksik = false;
                Map<String, dynamic> zTamam = Map.from(zCevaplar);
                for (var p in masadakiHerkes) {
                  if (!zTamam.containsKey(p)) {
                    zEksik = true;
                    Map<String, String> bos = {};
                    for (var kat in kategoriler) bos[kat["id"].toString()] = "-";
                    zTamam[p] = bos;
                  }
                }
                if (zEksik) await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({'cevaplar': zTamam});

                if (mounted && rakipBekleniyor) {
                  setState(() { rakipBekleniyor = false; });
                  await _hostPuanlariHesaplaVeKaydet();
                }
              } catch(e) {
                if (mounted) setState(() { rakipBekleniyor = false; });
              }
            }
          });
          return;
        } else {
          String kurucu = doc.data()?['kurucu']?.toString().trim() ?? "";
          if (trToLowerCase(kurucu) == trToLowerCase(ben)) {
            await _hostPuanlariHesaplaVeKaydet();
          } else {
            // --- KATILIMCI (GUEST) MANTIĞI ---
            if (mounted) setState(() { rakipBekleniyor = true; });

            // 🚀 YENİ: NÖBETÇİ KAPTAN MANTIĞI
            // Herkes sırasına göre farklı süre bekler (Kurucu koptuysa yığılmayı önleriz)
            int benimSiraNumaram = masadakiHerkes.indexOf(ben);
            if (benimSiraNumaram == -1) benimSiraNumaram = 1;

            // 1. sıradaki 15 sn, 2. sıradaki 18 sn, 3. sıradaki 21 sn...
            int apiBeklemeSuresi = 15 + (benimSiraNumaram * 3);

            Future.delayed(Duration(seconds: apiBeklemeSuresi), () async {
              if (mounted && rakipBekleniyor && !turBittiMi) {
                try {
                  // SÜRE BİTTİ AMA KONTROL EDELİM: Benden önceki nöbetçi hesaplamış mı?
                  var kontrolDoc = await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).get();
                  var puanlarMap = kontrolDoc.data()?['puanlar'] as Map<String, dynamic>? ?? {};

                  if (puanlarMap.isEmpty) {
                    // Kimse hesaplamamış! Demek ki benden öncekiler de koptu.
                    // Görevi ben devralıyorum ve Gemini'ye yolluyorum.
                    setState(() { rakipBekleniyor = false; });
                    await _hostPuanlariHesaplaVeKaydet();
                  } else {
                    // Puanlar zaten hesaplanmış! Gemini API kotamı boşuna harcamıyorum.
                    setState(() { rakipBekleniyor = false; });
                  }
                } catch (e) {
                  if (mounted) setState(() { rakipBekleniyor = false; });
                }
              }
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() { rakipBekleniyor = false; isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.connectionError), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
        }
      }
    } else {
      int oyuncuDoluKelime = 0;
      tumCevaplar[ben]?.forEach((key, value) { if (value != "-") oyuncuDoluKelime++; });
      final random = Random();
      int gecenSure = 90 - _kalanSure;
      int zamanaGoreMaxKelime = (gecenSure ~/ 7) + 1;
      int performansaGoreMaxKelime = oyuncuDoluKelime == 0 ? (random.nextInt(3) + 1) : (oyuncuDoluKelime + random.nextInt(2));
      int izinVerilenKelimeSayisi = zamanaGoreMaxKelime < performansaGoreMaxKelime ? zamanaGoreMaxKelime : performansaGoreMaxKelime;

      for (var botName in masadakiHerkes) {
        if (botName != ben) {
          int botDoluKelime = 0;
          tumCevaplar[botName]?.forEach((key, value) { if (value != "-") botDoluKelime++; });
          if (botDoluKelime > izinVerilenKelimeSayisi) {
            int silinmesiGereken = botDoluKelime - izinVerilenKelimeSayisi;
            for (var kat in kategoriler.reversed) {
              if (silinmesiGereken <= 0) break;
              int catId = kat["id"];
              if (tumCevaplar[botName] != null && tumCevaplar[botName]?[catId] != "-") {
                tumCevaplar[botName]![catId] = "-";
                silinmesiGereken--;
              }
            }
          }
        }
      }
      await topluDegerlendir();
    }
  }
// ---------------- BÖLÜM 18 SONU ----------------
// BÖLÜM 19: Kurucunun Puanları İşlemesi
// ==========================================
  Future<void> _hostPuanlariHesaplaVeKaydet() async {
    var doc = await FirebaseFirestore.instance
        .collection('odalar')
        .doc(widget.odaKodu)
        .get();
    var anlikCevaplar = doc.data()?['cevaplar'] as Map<String, dynamic>? ?? {};

    List<String> bosKagitVerenler = [];

    anlikCevaplar.forEach((kullanici, cevaplar) {
      String kName = kullanici.toString().trim();
      if (masadakiHerkes.contains(kName)) {
        Map<dynamic, dynamic> rawCevap = cevaplar as Map<dynamic, dynamic>;

        bool hepsiBos = true;
        rawCevap.forEach((k, v) {
          if (v.toString().trim() != "-") hepsiBos = false;

          if (trToLowerCase(kName) != trToLowerCase(ben)) {
            tumCevaplar.putIfAbsent(kName, () => {})[int.parse(k.toString())] = v.toString();
          }
        });

        if (hepsiBos) bosKagitVerenler.add(kName);
      }
    });

    if (bosKagitVerenler.isNotEmpty) {
      await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
        'aktifOyuncular': FieldValue.arrayRemove(bosKagitVerenler)
      });
    }

    await topluDegerlendir();

    Map<String, dynamic> tumPuanlarFirebase = {};
    for (var p in masadakiHerkes) {
      Map<String, int> pPuan = {};
      tumKategoriPuanlari[p]?.forEach((k, v) => pPuan[k.toString()] = v);
      tumPuanlarFirebase[p] = pPuan;
    }

    await FirebaseFirestore.instance
        .collection('odalar')
        .doc(widget.odaKodu)
        .update({
      'puanlar': tumPuanlarFirebase,
    });
  }

// ==========================================
// BÖLÜM 20: Gemini ve TDK Kullanarak Puan Hesaplama
// ==========================================
  Future<void> topluDegerlendir() async {
    _timer?.cancel();
    if (mounted) setState(() { isLoading = true; });

    try {
      List<Map<String, dynamic>> sorgular = [];
      List<Map<String, dynamic>> futureMeta = [];

      for (var kat in kategoriler) {
        int id = kat["id"];
        for (var p in masadakiHerkes) {
          String cvp = tumCevaplar[p]?[id] ?? "-";
          sorgular.add({"id": id, "cvp": cvp});
          futureMeta.add({"id": id, "player": p, "cvp": cvp});
        }
      }

      List<int> sonuclar = await DatabaseHelper.instance
          .topluDegerlendirmeMotoru(sorgular, secilenHarf)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        return List.filled(sorgular.length, 0);
      });

      Map<int, Map<String, int>> dogruluklar = {};
      Map<int, Map<String, String>> cevaplar = {};
      Map<int, int> enUzunDogruKelime = {};

      for (var kat in kategoriler) {
        int id = kat["id"];
        dogruluklar[id] = {};
        cevaplar[id] = {};
        enUzunDogruKelime[id] = 0;
      }

      for (int i = 0; i < sonuclar.length; i++) {
        int sonuc = sonuclar[i];
        int id = futureMeta[i]["id"];
        String p = futureMeta[i]["player"];
        String cvp = futureMeta[i]["cvp"];

        cevaplar[id]![p] = cvp;
        dogruluklar[id]![p] = sonuc;

        if (sonuc > 0 && cvp.length > enUzunDogruKelime[id]!) {
          enUzunDogruKelime[id] = cvp.length;
        }
      }

      for (var p in masadakiHerkes) { tumTurPuanlari[p] = 0; }

      for (var kat in kategoriler) {
        int id = kat["id"];
        int dogruBilenSayisi = 0;
        for (var p in masadakiHerkes) {
          if (dogruluklar[id]![p]! > 0) dogruBilenSayisi++;
        }

        for (var p in masadakiHerkes) {
          int puan = 0;
          if (dogruluklar[id]![p]! > 0) {
            if (dogruBilenSayisi == 1) {
              puan = 20;
            } else {
              String benimCevap = trToLowerCase(cevaplar[id]![p]!);
              bool pistiOlduMu = false;
              for (var diger in masadakiHerkes) {
                if (diger != p && dogruluklar[id]![diger]! > 0) {
                  if (trToLowerCase(cevaplar[id]![diger]!) == benimCevap) {
                    pistiOlduMu = true;
                    break;
                  }
                }
              }
              puan = pistiOlduMu ? 5 : 10;
            }
            if (cevaplar[id]![p]!.length == enUzunDogruKelime[id]! && enUzunDogruKelime[id]! > 0) {
              puan += 2;
            }
          }
          tumKategoriPuanlari.putIfAbsent(p, () => {})[id] = puan;
          tumTurPuanlari[p] = (tumTurPuanlari[p] ?? 0) + puan;
        }
      }

      if (odadakiErkenBitirenKisi.isNotEmpty) {
        tumTurPuanlari[odadakiErkenBitirenKisi] = (tumTurPuanlari[odadakiErkenBitirenKisi] ?? 0) + 10;
      }

      if (mounted) {
        setState(() {
          turBittiMi = true;
          rakipBekleniyor = false;
          Map<String, int> buTurMap = {};
          tumTurPuanlari.forEach((key, value) => buTurMap[key] = value);
          gecmisTurPuanlari[_guncelMevcutTur] = buTurMap;
        });
        _guvenlikSayaciniBaslat();
      }
    } catch (e) {
      print("🚨 Toplu Değerlendirme Hatası: $e");
    } finally {
      if (mounted) setState(() { isLoading = false; });
    }
  }


  // ==========================================
// BÖLÜM 21: Sonraki Tura Yönlendirme (ZAMAN DONDURMA VE NÖBETÇİ KAPTAN ZIRHI)
// ==========================================
  Future<void> _sonrakiTuraGec() async {
    if (_isTransitioning) return;
    _isTransitioning = true; // 🚀 Kilidi anında kapatıyoruz (Çift basmayı engeller)

    final int hedeflenenTur = _guncelMevcutTur;

    // 🚀 1. NÖBETÇİ KAPTAN (Host Migration) SÜRESİ HESAPLAMA
    // Listedeki sıramıza göre bekleme süresi alıyoruz. (Kurucu 0 sn, diğerleri 2-4-6 sn bekler)
    int benimSiraNumaram = masadakiHerkes.indexOf(ben);
    if (benimSiraNumaram == -1) benimSiraNumaram = 1;
    int beklemeSuresi = benimSiraNumaram * 2;

    if (!_hukmenGalibiyetGosterildi && !_elenmeGosterildi && widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
      try {
        var odaDoc = await FirebaseFirestore.instance
            .collection('odalar')
            .doc(widget.odaKodu)
            .get(const GetOptions(source: Source.server));

        List<dynamic> anlikAktifler = odaDoc.data()?['aktifOyuncular'] ?? [];
        bool benHalaAktifMiyim = anlikAktifler.any((aktif) => trToLowerCase(aktif.toString().trim()) == trToLowerCase(ben.trim()));

        if (!benHalaAktifMiyim) {
          _oyundanElendimIsleminiBaslat();
          return;
        }

        if (anlikAktifler.length <= 1) {
          _hukmenGalibiyetIsleminiBaslat();
          return;
        }
      } catch (e) {
        print("Tur atlama aktif oyuncu kontrol hatası: $e");
      }
    }

    _guvenlikTimer?.cancel();

    if (hedeflenenTur < widget.toplamTurSayisi) {
      if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {

        // 🚀 2. KADEMELİ GECİKME DEVREDE! Herkes kendi sırası geldiğinde Firebase'e bakar.
        Future.delayed(Duration(seconds: beklemeSuresi), () async {
          if (!mounted) return;

          DocumentReference odaRef = FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu);

          try {
            // 🚀 3. TRANSACTION KORUMASI (Eşzamanlı Çakışmaları Engeller)
            await FirebaseFirestore.instance.runTransaction((transaction) async {
              DocumentSnapshot snapshot = await transaction.get(odaRef);
              if (!snapshot.exists) return;

              Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
              int dbMevcutTur = 1;
              if (data != null && data.containsKey('mevcutTur')) {
                dbMevcutTur = data['mevcutTur'] as int;
              }

              // 🚀 ZIRH: Eğer Firebase'deki tur hala bizim eski (hedeflenen) turumuzda takılıysa:
              // (Yani bizden önceki kaptanların interneti koptuğu için atlatamamışlarsa)
              if (dbMevcutTur == hedeflenenTur) {

                final tumHarfler = _getAlfabe();
                List<String> kullanilabilirHarfler =
                tumHarfler.where((h) => !kullanilanHarfler.contains(h)).toList();
                if (kullanilabilirHarfler.isEmpty) {
                  kullanilabilirHarfler = List.from(tumHarfler);
                  kullanilanHarfler.clear();
                }
                kullanilabilirHarfler.shuffle();
                String yeniHarf = kullanilabilirHarfler.first;

                transaction.update(odaRef, {
                  'mevcutTur': hedeflenenTur + 1, // 🚀 increment YERİNE SABİT HEDEF SAYI (+)
                  'secilenHarf': yeniHarf,
                  'cevaplar': {},
                  'puanlar': {},
                  'hazirOyuncular': [],
                  'erkenBitiren': "",
                });
              }
            });
          } catch (e) {
            print("Transaction hatası: $e");
            if (mounted) setState(() => _isTransitioning = false); // Hata olursa kilidi aç
          }
        });

      } else {
        // --- BOTLU OYUN MANTIĞI (DEĞİŞMEDİ) ---
        setState(() {
          for (var p in masadakiHerkes) {
            macSkorlari[p] = (macSkorlari[p] ?? 0) + (tumTurPuanlari[p] ?? 0);
            tumTurPuanlari[p] = 0;
          }
          _guncelMevcutTur += 1;
          aktifKategoriIndex = 0;
          _seciliRakipIndex = 1;
          _yeniTurBaslat(ilkBaslangic: false);
        });
      }
    } else {
      // --- OYUN SONU PUANLAMA MANTIĞI (DEĞİŞMEDİ) ---
      for (var p in masadakiHerkes) {
        macSkorlari[p] = (macSkorlari[p] ?? 0) + (tumTurPuanlari[p] ?? 0);
        tumTurPuanlari[p] = 0;
      }

      int benimMacSkorum = macSkorlari[ben] ?? 0;
      bool birinciMiyim = true;
      for (var p in masadakiHerkes) {
        if (p != ben && (macSkorlari[p] ?? 0) > benimMacSkorum) {
          birinciMiyim = false;
          break;
        }
      }

      int safKazanilanPuan = benimMacSkorum + (birinciMiyim ? 100 : 0);
      int eskiGenelPuan = await DatabaseHelper.instance.getOyuncuSkor();
      Map<String, int> eskiSiraVerisi = await DatabaseHelper.instance
          .getHizliSiralamaVeToplamOyuncu(eskiGenelPuan);
      int gercekEskiSiralama = eskiSiraVerisi['sira'] ?? 1000;

      await DatabaseHelper.instance.saveOyuncuSkor(ben, safKazanilanPuan);

      if (widget.odaKodu == null || widget.odaKodu!.isEmpty) {
        for (var rakipAdi in masadakiHerkes) {
          if (rakipAdi != ben) {
            int botMacPuan = macSkorlari[rakipAdi] ?? 0;
            bool botBirinci = true;
            for (var diger in masadakiHerkes) {
              if (diger != rakipAdi && (macSkorlari[diger] ?? 0) > botMacPuan) {
                botBirinci = false;
                break;
              }
            }
            int botSafKazanilanPuan = botMacPuan + (botBirinci ? 100 : 0);
            await DatabaseHelper.instance
                .saveBotSkor(rakipAdi, botSafKazanilanPuan);
          }
        }
      }

      int yeniGenelPuan = await DatabaseHelper.instance.getOyuncuSkor();
      Map<String, int> yeniSiraVerisi = await DatabaseHelper.instance
          .getHizliSiralamaVeToplamOyuncu(yeniGenelPuan);
      int gercekYeniSiralama = yeniSiraVerisi['sira'] ?? 1000;

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              oyuncuAdi: ben,
              tumMacSkorlari: macSkorlari,
              eskiGenelPuan: eskiGenelPuan,
              yeniGenelPuan: yeniGenelPuan,
              eskiSiralama: gercekEskiSiralama,
              yeniSiralama: gercekYeniSiralama,
            ),
          ),
        );
      }
    }
  }
// ---------------- BÖLÜM 21 SONU ----------------

// BÖLÜM 22: GÖRSEL TASARIM VE KULLANICI ARAYÜZÜ
// ==========================================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.purple.shade900,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 5),
              const SizedBox(height: 25),
              Text(
                l10n.checkingWords,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    var mevcutKategori = kategoriler[aktifKategoriIndex];

    if (rakipBekleniyor) {
      return Scaffold(
        backgroundColor: Colors.purple.shade800,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(l10n.answersSavedWaiting,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        bottomNavigationBar: const SafeArea(child: BottomBannerAdWidget()),
      );
    }

    if (turBittiMi) {
      bool sonTurMu = (_guncelMevcutTur >= widget.toplamTurSayisi);
      List<String> rakipler = masadakiHerkes.where((p) => p != ben).toList();
      String seciliRakip = rakipler.isNotEmpty
          ? rakipler[(_seciliRakipIndex - 1) % rakipler.length]
          : l10n.noOpponent;

      int benimSkorum = (macSkorlari[ben] ?? 0) + (tumTurPuanlari[ben] ?? 0);
      int rakipSkorum =
          (macSkorlari[seciliRakip] ?? 0) + (tumTurPuanlari[seciliRakip] ?? 0);

      return Scaffold(
        backgroundColor: Colors.purple.shade900,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 75,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.purple.shade600,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("$benimSkorum",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            Text(trToUpperCase(ben),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text("VS",
                          style: TextStyle(
                              color: Colors.purple.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.pink.shade400,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("$rakipSkorum",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: Text(trToUpperCase(seciliRakip),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            if (rakipler.length > 1) ...[
                              Positioned(
                                left: 0,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.arrow_back_ios_rounded,
                                      color: Colors.white70, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _seciliRakipIndex =
                                      _seciliRakipIndex - 1 < 1
                                          ? rakipler.length
                                          : _seciliRakipIndex - 1;
                                    });
                                  },
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white70,
                                      size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _seciliRakipIndex =
                                      _seciliRakipIndex + 1 >
                                          rakipler.length
                                          ? 1
                                          : _seciliRakipIndex + 1;
                                    });
                                  },
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade800,
                  border: const Border(
                      bottom: BorderSide(color: Colors.white24, width: 1)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: List.generate(_guncelMevcutTur, (index) {
                        int turNo = index + 1;
                        int benimOturkiPuanim =
                            gecmisTurPuanlari[turNo]?[ben] ?? 0;
                        int rakipOturkiPuani =
                            gecmisTurPuanlari[turNo]?[seciliRakip] ?? 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            children: [
                              Text(l10n.roundNumberLabel(turNo),
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "$benimOturkiPuanim - $rakipOturkiPuani",
                                  style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  itemCount: kategoriler.length + 1,
                  itemBuilder: (context, index) {
                    if (index == kategoriler.length) {
                      int benimBonus =
                      (odadakiErkenBitirenKisi == ben) ? 10 : 0;
                      int rakipBonus =
                      (odadakiErkenBitirenKisi == seciliRakip) ? 10 : 0;

                      if (benimBonus == 0 && rakipBonus == 0)
                        return const SizedBox.shrink();

                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(children: [
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(l10n.timeBonus,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text("+$benimBonus",
                                        style: TextStyle(
                                            color: benimBonus > 0
                                                ? Colors.greenAccent
                                                : Colors.white24,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                )),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                  color: Colors.purple.shade700,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white24, width: 1.5)),
                              child: const Icon(Icons.timer,
                                  color: Colors.white, size: 18),
                            ),
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(l10n.timeBonus,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text("+$rakipBonus",
                                        style: TextStyle(
                                            color: rakipBonus > 0
                                                ? Colors.greenAccent
                                                : Colors.white24,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                )),
                          ]));
                    }

                    int id = kategoriler[index]["id"];
                    String benimKelime =
                    trToUpperCase(tumCevaplar[ben]?[id] ?? "-");
                    int benimPuan = tumKategoriPuanlari[ben]?[id] ?? 0;

                    String rakipKelime =
                    trToUpperCase(tumCevaplar[seciliRakip]?[id] ?? "-");
                    int rakipPuan = tumKategoriPuanlari[seciliRakip]?[id] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  benimKelime,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "+$benimPuan",
                                  style: TextStyle(
                                      color: benimPuan > 0
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade700,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white24, width: 1.5),
                                  ),
                                  child: Icon(kategoriler[index]["icon"],
                                      color: Colors.white, size: 18),
                                ),
                                const SizedBox(height: 2),
                                SizedBox(
                                  width: 75,
                                  child: Text(
                                    trToUpperCase(getKategoriIsmi(id, l10n)),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  rakipKelime,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "+$rakipPuan",
                                  style: TextStyle(
                                      color: rakipPuan > 0
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  children: [
                    if (widget.odaKodu != null &&
                        widget.odaKodu!.isNotEmpty &&
                        !sonTurMu)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          hazirOyuncuSayisi >= masadakiHerkes.length
                              ? l10n.everyoneReady
                              : l10n.playersReady(hazirOyuncuSayisi, masadakiHerkes.length),
                          style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: benHazirMiyim
                            ? null
                            : () => _hazirButonunaBasildi(),
                        icon: Icon(
                          benHazirMiyim
                              ? Icons.check_circle_rounded
                              : (sonTurMu
                              ? Icons.emoji_events_rounded
                              : Icons.play_arrow_rounded),
                          color: benHazirMiyim
                              ? Colors.green
                              : Colors.purple.shade900,
                          size: 22,
                        ),
                        label: Text(
                          benHazirMiyim
                              ? l10n.waitingReady
                              : (sonTurMu
                              ? l10n.seeResultsWithTimer(_kalanGuvenlikSaniyesi)
                              : l10n.readyWithTimer(_kalanGuvenlikSaniyesi)),
                          style: TextStyle(
                              color: benHazirMiyim
                                  ? Colors.white70
                                  : Colors.purple.shade900,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: benHazirMiyim
                              ? Colors.green.shade800
                              : Colors.white,
                          disabledBackgroundColor: Colors.purple.shade800,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: benHazirMiyim ? 0 : 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const SafeArea(child: BottomBannerAdWidget()),
      );
    }

    bool turuBitirBtnAktif = turuBitirAktifMi();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45.0),
        child: AppBar(
            title: Text(l10n.appTitle,
                style: const TextStyle(fontSize: 18)),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            centerTitle: true),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.tourProgress(_guncelMevcutTur, widget.toplamTurSayisi),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _kalanSure <= 20
                          ? Colors.red.shade100
                          : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Icon(Icons.timer,
                        color: _kalanSure <= 20 ? Colors.red : Colors.purple,
                        size: 15),
                    const SizedBox(width: 4),
                    Text(l10n.secondsLeft(_kalanSure), style: const TextStyle(fontSize: 13))
                  ]),
                ),
                Text(l10n.currentLetterLabel(secilenHarf),
                    style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
            const SizedBox(height: 15),
            CircleAvatar(
                radius: 20,
                backgroundColor: Colors.purple.shade100,
                child: Text(secilenHarf,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(kategoriler.length, (index) {
                  String cevap =
                      tumCevaplar[ben]?[kategoriler[index]["id"]] ?? "";
                  bool dolumu =
                  (cevap.isNotEmpty && cevap != "-" && cevap.length >= 2);
                  return InkWell(
                    onTap: () {
                      if (_kalanSure > 0) kategoriDegistir(index);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(kategoriler[index]["icon"],
                            size: 24,
                            color: index == aktifKategoriIndex
                                ? Colors.purple
                                : (dolumu
                                ? Colors.blue
                                : Colors.grey.shade400))),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.categoryLabel(getKategoriIsmi(mevcutKategori["id"], l10n)),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple)),
            const SizedBox(height: 10),
            TextField(
              controller: _inputController,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              enabled: _kalanSure > 0,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                  labelText: l10n.typeYourWordHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon:
                  Icon(mevcutKategori["icon"], color: Colors.purple)),
            ),
            const SizedBox(height: 16),
            if (erkenBitirmeBonusuKazandiMi)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.purple.shade900,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Text(l10n.twentySecondsRule,
                        style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                            width: 75,
                            height: 75,
                            child: CircularProgressIndicator(
                                value: _kalanSure / 20,
                                strokeWidth: 6,
                                color: Colors.amber,
                                backgroundColor: Colors.purple.shade700)),
                        Text("$_kalanSure",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed:
                    turuBitirBtnAktif ? () => turuErkenBitirIstegi() : null,
                    icon: const Icon(Icons.flag_rounded, color: Colors.white),
                    label: Text(
                      erkenBitirmeBonusuKazandiMi
                          ? l10n.waitingForTimeEnd
                          : (_kalanSure < 20
                          ? l10n.last20SecondsNoBonus
                          : (turuBitirBtnAktif
                          ? l10n.finishTurnWithBonus
                          : l10n.finishTurnMinWords)),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: turuBitirBtnAktif
                            ? Colors.redAccent.shade200
                            : Colors.grey.shade400,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: (aktifKategoriIndex > 0 && _kalanSure > 0)
                            ? () => kategoriDegistir(aktifKategoriIndex - 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: Text(l10n.previousButton,
                            style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold)))),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton(
                        onPressed:
                        (aktifKategoriIndex < kategoriler.length - 1 &&
                            _kalanSure > 0)
                            ? () => kategoriDegistir(aktifKategoriIndex + 1)
                            : null,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: Text(l10n.nextButton,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)))),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: erkenBitirmeBonusuKazandiMi
          ? const SizedBox.shrink()
          : const SafeArea(child: BottomBannerAdWidget()),
    );
  }

// ==========================================
// BÖLÜM 23: Firebase Presence API (Gerçek Zamanlı Kopma Tespiti)
// ==========================================
  Future<void> _presenceSisteminiBaslat() async {
    if (widget.odaKodu == null || widget.odaKodu!.isEmpty) return;

    _benimPresenceRef = FirebaseDatabase.instance.ref('oda_presence/${widget.odaKodu}/$ben');
    await _benimPresenceRef!.onDisconnect().remove();
    await _benimPresenceRef!.set(true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _presenceSubscription = FirebaseDatabase.instance.ref('oda_presence/${widget.odaKodu}').onValue.listen((event) async {
        if (!mounted) return;
        var aktifler = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

        List<String> rtdbDusenler = [];
        for (String oyuncu in masadakiHerkes) {
          if (oyuncu != ben && !aktifler.containsKey(oyuncu)) {
            rtdbDusenler.add(oyuncu);
          }
        }

        if (rtdbDusenler.isNotEmpty) {
          try {
            await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
              'aktifOyuncular': FieldValue.arrayRemove(rtdbDusenler)
            });
          } catch (e) {
            print("Presence Firestore güncelleme hatası: $e");
          }
        }
      });
    });
  }
}