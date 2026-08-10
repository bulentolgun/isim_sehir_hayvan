import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_helper.dart';
import 'result_page.dart';
import 'ad_service.dart';

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

class _GamePageState extends State<GamePage> {
  final List<Map<String, dynamic>> kategoriler = [
    {"id": 1, "isim": "İsim", "icon": Icons.groups},
    {"id": 2, "isim": "Şehir", "icon": Icons.home},
    {"id": 3, "isim": "Hayvan", "icon": Icons.pets},
    {"id": 4, "isim": "Bitki", "icon": Icons.eco},
    {"id": 5, "isim": "Eşya", "icon": Icons.handyman},
    {"id": 6, "isim": "Ülke", "icon": Icons.flag},
  ];

  int aktifKategoriIndex = 0;
  final TextEditingController _inputController = TextEditingController();

  Map<int, String> oyuncuCevaplari = {};
  Map<int, String> rakip1Cevaplari = {};

  Map<int, int> oyuncuKategoriPuanlari = {};
  Map<int, int> rakipKategoriPuanlari = {};

  Map<int, int> turBazliOyuncuPuanlari = {};
  Map<int, int> turBazliRakipPuanlari = {};

  List<int> botTurBasariOranlari = [];

  int oyuncuTurPuani = 0;
  int rakip1TurPuani = 0;
  bool turBittiMi = false;
  bool erkenBitirmeBonusuKazandiMi = false;
  bool rakipBekleniyor = false;

  bool benHazirMiyim = false;
  bool rakipHazirMi = false;
  bool _isTransitioning = false; // 🎯 YENİ EKLENEN KİLİT DEĞİŞKENİ
  Timer? _guvenlikTimer;
  int _kalanGuvenlikSaniyesi = 15;

  String secilenHarf = "A";
  Timer? _timer;
  StreamSubscription<DocumentSnapshot>? _odaSubscription;
  int _kalanSure = 90;

  late int _guncelMevcutTur;
  late int _guncelOyuncuSkor;
  late int _guncelRakip1Skor;

  int genelToplamPuan = 0;
  int genelSiralama = 1000;
  int toplamYarismaciSayisi = 1000;

  List<String> kullanilanHarfler = [];

  final List<String> yasakliKelimeler = [
    "amk", "sik", "piç", "orospu", "oç", "sg", "yarrak", "göt", "meme", "dalyarak", "pezevenk", "kaltak", "fahişe"
  ];

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

  @override
  void initState() {
    super.initState();
    _guncelMevcutTur = widget.mevcutTur;
    _guncelOyuncuSkor = widget.oyuncuKumulatifSkor;
    _guncelRakip1Skor = widget.rakip1KumulatifSkor;

    AdService.instance.loadInterstitialAd();

    _genelBilgileriYukle();
    _canliOdaDinle();
    _yeniTurBaslat(ilkBaslangic: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _guvenlikTimer?.cancel();
    _odaSubscription?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  void _canliOdaDinle() {
    if (widget.odaKodu == null || widget.odaKodu!.isEmpty) return;

    _odaSubscription = FirebaseFirestore.instance
        .collection('odalar')
        .doc(widget.odaKodu)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists || !mounted) return;

      var data = snapshot.data() as Map<String, dynamic>;
      var cevaplarMap = data['cevaplar'] as Map<String, dynamic>? ?? {};
      var puanlarMap = data['puanlar'] as Map<String, dynamic>? ?? {};
      List<dynamic> hazirOyuncular = data['hazirOyuncular'] ?? [];
      String kurucu = (data['kurucu'] ?? "").toString().trim();
      int odaTur = data['mevcutTur'] ?? 1;
      String yeniHarf = data['secilenHarf'] ?? "A";

      String ben = widget.oyuncuAdi.trim().isEmpty ? "Tokatlı60" : widget.oyuncuAdi.trim();

      // 🎯 DÜZELTME 2 (HARF KOPMASI): Firebase'deki tur numarası ilerlediyse harfi zorunlu eşitle!
      if (odaTur > _guncelMevcutTur) {
        _guvenlikTimer?.cancel();
        setState(() {
          _guncelOyuncuSkor += oyuncuTurPuani;
          _guncelRakip1Skor += rakip1TurPuani;
          _guncelMevcutTur = odaTur;
          aktifKategoriIndex = 0;
          benHazirMiyim = false;
          rakipHazirMi = false;
          secilenHarf = yeniHarf; // 🔥 Yeni harf burada zorla Firebase'den alınıp eşitleniyor
          _yeniTurBaslat(ilkBaslangic: false, firebaseHarfi: yeniHarf);
        });
        return;
      }

      cevaplarMap.forEach((kullanici, cevaplar) {
        if (trToLowerCase(kullanici.toString().trim()) != trToLowerCase(ben)) {
          Map<dynamic, dynamic> rawCevap = cevaplar as Map<dynamic, dynamic>;
          Map<int, String> donusturulmusCevap = {};
          rawCevap.forEach((k, v) {
            donusturulmusCevap[int.parse(k.toString())] = v.toString();
          });

          if (mounted) {
            setState(() {
              rakip1Cevaplari = donusturulmusCevap;
            });
          }
        }
      });

      if (turBittiMi) {
        bool rHazir = hazirOyuncular.any((p) => trToLowerCase(p.toString().trim()) != trToLowerCase(ben));
        if (rHazir != rakipHazirMi && mounted) {
          setState(() {
            rakipHazirMi = rHazir;
          });
        }

        if (hazirOyuncular.length >= 2) {
          if (trToLowerCase(kurucu) == trToLowerCase(ben)) {
            _sonrakiTuraGec();
          } else if (_guncelMevcutTur >= widget.toplamTurSayisi) {
            _sonrakiTuraGec();
          }
        }
      }

      if (puanlarMap.isNotEmpty && trToLowerCase(kurucu) != trToLowerCase(ben)) {
        Map<int, int> tempOPuan = {};
        Map<int, int> tempRPuan = {};
        int oToplam = 0;
        int rToplam = 0;

        puanlarMap.forEach((kullanici, pMap) {
          Map<String, dynamic> rawP = pMap as Map<String, dynamic>? ?? {};
          if (trToLowerCase(kullanici.toString().trim()) == trToLowerCase(ben)) {
            rawP.forEach((k, v) {
              int val = (v as num).toInt();
              tempOPuan[int.parse(k)] = val;
              oToplam += val;
            });
          } else {
            rawP.forEach((k, v) {
              int val = (v as num).toInt();
              tempRPuan[int.parse(k)] = val;
              rToplam += val;
            });
          }
        });

        if (mounted && !turBittiMi) {
          setState(() {
            oyuncuKategoriPuanlari = tempOPuan;
            rakipKategoriPuanlari = tempRPuan;
            oyuncuTurPuani = oToplam;
            rakip1TurPuani = rToplam;
            turBittiMi = true;
            rakipBekleniyor = false;

            turBazliOyuncuPuanlari[_guncelMevcutTur] = oToplam;
            turBazliRakipPuanlari[_guncelMevcutTur] = rToplam;
          });

          _guvenlikSayaciniBaslat();
        }
        return;
      }

      if (rakipBekleniyor && cevaplarMap.length >= 2 && trToLowerCase(kurucu) == trToLowerCase(ben) && !turBittiMi) {
        setState(() {
          rakipBekleniyor = false;
        });
        await _hostPuanlariHesaplaVeKaydet();
        _guvenlikSayaciniBaslat();
      }
    });
  }

  void _guvenlikSayaciniBaslat() {
    _guvenlikTimer?.cancel();
    _kalanGuvenlikSaniyesi = 15;

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
          _hazirButonunaBasildi();
        }
      });
    });
  }

  Future<void> _hazirButonunaBasildi() async {
    if (benHazirMiyim) return;

    if (mounted) {
      setState(() {
        benHazirMiyim = true;
      });
    }

    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
      String ben = widget.oyuncuAdi.trim().isEmpty ? "Tokatlı60" : widget.oyuncuAdi.trim();

      await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
        'hazirOyuncular': FieldValue.arrayUnion([ben]),
      });
    } else {
      _sonrakiTuraGec();
    }
  }

  Future<void> _genelBilgileriYukle() async {
    int dbSkor = await DatabaseHelper.instance.getOyuncuSkor();
    String ben = widget.oyuncuAdi.trim().isEmpty ? "Tokatlı60" : widget.oyuncuAdi.trim();
    List<Map<String, dynamic>> tablo = await DatabaseHelper.instance.getTumLiderlikTablosu(ben);

    int siralama = tablo.length;
    for (int i = 0; i < tablo.length; i++) {
      if (tablo[i]['bot_adi'].toString().trim().toLowerCase() == ben.toLowerCase()) {
        siralama = i + 1;
        break;
      }
    }

    if (mounted) {
      setState(() {
        genelToplamPuan = dbSkor;
        genelSiralama = siralama;
        toplamYarismaciSayisi = max(1000, tablo.length);
      });
    }
  }

  void _yeniTurBaslat({bool ilkBaslangic = false, String? firebaseHarfi}) {
    _isTransitioning = false; // 🎯 DÜZELTME: Yeni tur başlayınca kilit açılır
    _timer?.cancel();
    _guvenlikTimer?.cancel();
    _inputController.clear();

    if (ilkBaslangic) {
      kullanilanHarfler.clear();
    }

    // 🎯 Eğer Firebase'den zorunlu harf geldiyse KESİNLİKLE onu kullan
    if (firebaseHarfi != null && firebaseHarfi.isNotEmpty) {
      secilenHarf = firebaseHarfi;
      if (!kullanilanHarfler.contains(secilenHarf)) {
        kullanilanHarfler.add(secilenHarf);
      }
    } else if (widget.secilenHarf != null && widget.secilenHarf!.isNotEmpty && ilkBaslangic) {
      secilenHarf = widget.secilenHarf!;
      if (!kullanilanHarfler.contains(secilenHarf)) {
        kullanilanHarfler.add(secilenHarf);
      }
    } else {
      final tumHarfler = ["A", "B", "C", "Ç", "D", "E", "F", "G", "H", "I", "İ", "J", "K", "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"];
      List<String> kullanilabilirHarfler = tumHarfler.where((h) => !kullanilanHarfler.contains(h)).toList();

      if (kullanilabilirHarfler.isEmpty) {
        kullanilabilirHarfler = List.from(tumHarfler);
        kullanilanHarfler.clear();
      }
      kullanilabilirHarfler.shuffle();
      secilenHarf = kullanilabilirHarfler.first;
      kullanilanHarfler.add(secilenHarf);
    }

    if (ilkBaslangic || botTurBasariOranlari.isEmpty) {
      if (widget.toplamTurSayisi == 1) {
        botTurBasariOranlari = [90];
      } else if (widget.toplamTurSayisi == 3) {
        botTurBasariOranlari = [95, 90, 85]..shuffle();
      } else if (widget.toplamTurSayisi == 5) {
        botTurBasariOranlari = [95, 90, 85, 80, 80]..shuffle();
      } else {
        botTurBasariOranlari = List<int>.filled(widget.toplamTurSayisi, 90, growable: true);
      }
    }

    oyuncuCevaplari.clear();
    rakip1Cevaplari.clear();
    oyuncuKategoriPuanlari.clear();
    rakipKategoriPuanlari.clear();

    oyuncuTurPuani = 0;
    rakip1TurPuani = 0;
    turBittiMi = false;
    erkenBitirmeBonusuKazandiMi = false;
    rakipBekleniyor = false;
    benHazirMiyim = false;
    rakipHazirMi = false;
    _kalanSure = 90;

    _zamanlayiciyiBaslat();

    if (widget.odaKodu == null || widget.odaKodu!.isEmpty) {
      _botCevaplariniHazirla();
    }
  }

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

  Future<void> _botCevaplariniHazirla() async {
    final random = Random();

    int turIndex = _guncelMevcutTur - 1;
    int basariYuzdesi = 90;

    if (botTurBasariOranlari.isNotEmpty) {
      if (turIndex >= 0 && turIndex < botTurBasariOranlari.length) {
        basariYuzdesi = botTurBasariOranlari[turIndex];
      } else {
        basariYuzdesi = botTurBasariOranlari.last;
      }
    }

    Map<int, String> geciciCevaplar = {};

    for (var kat in kategoriler) {
      int catId = kat["id"];
      bool basarili = random.nextInt(100) < basariYuzdesi;
      if (basarili) {
        String? botKelime = await DatabaseHelper.instance.getBotKelime(catId, secilenHarf);
        geciciCevaplar[catId] = botKelime ?? "-";
      } else {
        geciciCevaplar[catId] = "-";
      }
    }

    int doluKutuSayisi = geciciCevaplar.values.where((v) => v != "-" && v.trim().isNotEmpty).length;

    if (doluKutuSayisi < 4) {
      List<int> bosKategoriIds = [];
      geciciCevaplar.forEach((catId, cevap) {
        if (cevap == "-" || cevap.trim().isEmpty) {
          bosKategoriIds.add(catId);
        }
      });

      bosKategoriIds.shuffle();

      for (int catId in bosKategoriIds) {
        if (doluKutuSayisi >= 4) break;

        String? botKelime = await DatabaseHelper.instance.getBotKelime(catId, secilenHarf);

        if (botKelime != null && botKelime.isNotEmpty) {
          geciciCevaplar[catId] = botKelime;
          doluKutuSayisi++;
        }
      }
    }

    if (mounted) {
      setState(() {
        rakip1Cevaplari = geciciCevaplar;
      });
    }
  }

  bool _harfDogruMu(String kelime) {
    if (kelime.isEmpty || kelime == "-") return true;
    return trToLowerCase(kelime[0]) == trToLowerCase(secilenHarf);
  }

  void _harfUyarisiGoster() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Girdiğiniz kelime '$secilenHarf' harfi ile başlamalıdır!"),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _girdiGecerliMi() {
    String metin = trToLowerCase(_inputController.text.trim());
    int currentCatId = kategoriler[aktifKategoriIndex]["id"];

    if (metin.isEmpty) return true;

    for (var yasakli in yasakliKelimeler) {
      if (metin.contains(trToLowerCase(yasakli))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Uygunsuz kelime tespiti! Lütfen geçerli bir kelime giriniz."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }
    }

    if (!_harfDogruMu(metin)) {
      _harfUyarisiGoster();
      return false;
    }

    if (currentCatId == 1 && metin.contains(" ")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("İsim bölümüne sadece tek bir isim girebilirsiniz!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  bool turuBitirAktifMi() {
    if (erkenBitirmeBonusuKazandiMi || rakipBekleniyor || _kalanSure < 20) return false;

    String anlikKelime = _inputController.text.trim();
    int mevcutCatId = kategoriler[aktifKategoriIndex]["id"];

    int bosKutuSayisi = 0;
    for (var kat in kategoriler) {
      int id = kat["id"];
      String cevap = (id == mevcutCatId) ? anlikKelime : (oyuncuCevaplari[id] ?? "-");

      if (cevap == "-" || cevap.trim().isEmpty || cevap.trim().length < 2) {
        bosKutuSayisi++;
      }
    }

    return bosKutuSayisi <= 1;
  }

  void turuErkenBitirIstegi() {
    if (erkenBitirmeBonusuKazandiMi) return;
    if (!_girdiGecerliMi()) return;

    _mevcutKelimeyiKaydet();

    setState(() {
      erkenBitirmeBonusuKazandiMi = true;
      if (_kalanSure > 20) {
        _kalanSure = 20;
      }
    });

    AdService.instance.showEmniyetliGecisReklami(
      onReklamBitti: () {
        if (!mounted) return;

        if (_kalanSure <= 0) {
          _cevaplariFirebaseeGonderAndDegerlendir();
        } else {
          setState(() {});
        }
      },
    );
  }

  void _arkaplanTdkKontrol(int catId, String kelime) {
    if (kelime.length >= 2 && kelime != "-") {
      DatabaseHelper.instance.checkWordWithToleranceAndTdk(catId, secilenHarf, kelime);
    }
  }

  void _mevcutKelimeyiKaydet() {
    String girilenKelime = _inputController.text.trim();
    int currentCatId = kategoriler[aktifKategoriIndex]["id"];

    if (girilenKelime.isEmpty || girilenKelime.length < 2) {
      oyuncuCevaplari[currentCatId] = "-";
    } else {
      oyuncuCevaplari[currentCatId] = girilenKelime;
      _arkaplanTdkKontrol(currentCatId, girilenKelime);
    }
  }

  void kategoriDegistir(int yeniIndex) {
    if (!_girdiGecerliMi()) return;

    _mevcutKelimeyiKaydet();
    setState(() {
      aktifKategoriIndex = yeniIndex;
      int yeniCatId = kategoriler[aktifKategoriIndex]["id"];
      String eskiCevap = oyuncuCevaplari[yeniCatId] ?? "";
      _inputController.text = (eskiCevap == "-") ? "" : eskiCevap;
    });
  }

  Future<void> _cevaplariFirebaseeGonderAndDegerlendir() async {
    _timer?.cancel();
    _mevcutKelimeyiKaydet(); // Son kutuyu kaydet

    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
      String ben = widget.oyuncuAdi.trim().isEmpty ? "Tokatlı60" : widget.oyuncuAdi.trim();

      // 🔥 DÜZELTME 1 (KAYIP KELİMELER): Firebase'e yollanırken SADECE dolu olanları değil,
      // 6 kategorinin 6'sını da zorla tarayıp gönderiyoruz. Böylece kelimeler kaybolmuyor!
      Map<String, String> stringMap = {};
      for (var kat in kategoriler) {
        int id = kat["id"];
        String cevap = oyuncuCevaplari[id] ?? "-";
        if (cevap.trim().isEmpty) cevap = "-";
        stringMap[id.toString()] = cevap;
      }

      await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
        'cevaplar.$ben': stringMap,
      });

      if (rakip1Cevaplari.isEmpty) {
        if (mounted) {
          setState(() {
            rakipBekleniyor = true;
          });
        }
        return;
      } else {
        var doc = await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).get();
        String kurucu = doc.data()?['kurucu']?.toString().trim() ?? "";

        if (trToLowerCase(kurucu) == trToLowerCase(ben)) {
          await _hostPuanlariHesaplaVeKaydet();
        } else {
          if (mounted) {
            setState(() {
              rakipBekleniyor = true;
            });
          }
        }
      }
    } else {
      await topluDegerlendir();
    }
  }

  Future<void> _hostPuanlariHesaplaVeKaydet() async {
    await topluDegerlendir();

    String ben = widget.oyuncuAdi.trim().isEmpty ? "Tokatlı60" : widget.oyuncuAdi.trim();

    // 🎯 DÜZELTME 1: Rakibin gerçek adını Firebase'den (cevaplar listesinden) buluyoruz
    var doc = await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).get();
    var cevaplarMap = doc.data()?['cevaplar'] as Map<String, dynamic>? ?? {};

    String gercekRakipAdi = "";
    for (var key in cevaplarMap.keys) {
      if (trToLowerCase(key) != trToLowerCase(ben)) {
        gercekRakipAdi = key;
        break;
      }
    }
    // Eğer rakip bulunamazsa yedeğe düş
    if (gercekRakipAdi.isEmpty) gercekRakipAdi = widget.rakipAdi.trim().isEmpty ? "Rakip" : widget.rakipAdi.trim();

    Map<String, int> oPuanMap = {};
    Map<String, int> rPuanMap = {};

    oyuncuKategoriPuanlari.forEach((k, v) => oPuanMap[k.toString()] = v);
    rakipKategoriPuanlari.forEach((k, v) => rPuanMap[k.toString()] = v);

    Map<String, dynamic> tumPuanlar = {
      ben: oPuanMap,
      gercekRakipAdi: rPuanMap, // 🔥 Puanlar artık jenerik isimle değil, gerçek rakip adıyla kaydediliyor!
    };

    await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
      'puanlar': tumPuanlar,
    });
  }

  Future<void> topluDegerlendir() async {
    _timer?.cancel();

    int oToplam = 0;
    int r1Toplam = 0;

    for (var kat in kategoriler) {
      int id = kat["id"];

      String oCevap = oyuncuCevaplari[id] ?? "-";
      String r1Cevap = rakip1Cevaplari[id] ?? "-";

      int oSonuc = await DatabaseHelper.instance.checkWordWithToleranceAndTdk(id, secilenHarf, oCevap);
      int r1Sonuc = await DatabaseHelper.instance.checkWordWithToleranceAndTdk(id, secilenHarf, r1Cevap);

      bool oDogru = oSonuc > 0;
      bool r1Dogru = r1Sonuc > 0;

      int oPuan = 0;
      int r1Puan = 0;

      if (oDogru && r1Dogru) {
        if (trToLowerCase(oCevap) == trToLowerCase(r1Cevap)) {
          oPuan = 5;
          r1Puan = 5;
        } else {
          oPuan = 10;
          r1Puan = 10;
        }
      } else if (oDogru && !r1Dogru) {
        oPuan = 20;
        r1Puan = 0;
      } else if (!oDogru && r1Dogru) {
        oPuan = 0;
        r1Puan = 20;
      }

      int maxLen = max(oDogru ? oCevap.length : 0, r1Dogru ? r1Cevap.length : 0);
      if (maxLen > 0) {
        if (oDogru && oCevap.length == maxLen) { oPuan += 2; }
        if (r1Dogru && r1Cevap.length == maxLen) { r1Puan += 2; }
      }

      oyuncuKategoriPuanlari[id] = oPuan;
      rakipKategoriPuanlari[id] = r1Puan;

      oToplam += oPuan;
      r1Toplam += r1Puan;
    }

    if (erkenBitirmeBonusuKazandiMi) { oToplam += 10; }

    if (mounted) {
      setState(() {
        oyuncuTurPuani = oToplam;
        rakip1TurPuani = r1Toplam;
        turBittiMi = true;
        rakipBekleniyor = false;

        turBazliOyuncuPuanlari[_guncelMevcutTur] = oToplam;
        turBazliRakipPuanlari[_guncelMevcutTur] = r1Toplam;
      });

      _guvenlikSayaciniBaslat();
    }
  }

  Future<void> _sonrakiTuraGec() async {
    if (_isTransitioning) return; // 🎯 DÜZELTME 2: Çift tetiklenme (Race Condition) kilidi!
    _isTransitioning = true;

    _guvenlikTimer?.cancel();

    if (_guncelMevcutTur < widget.toplamTurSayisi) {
      if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
        var doc = await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).get();
        String kurucu = doc.data()?['kurucu']?.toString().trim() ?? "";
        String ben = widget.oyuncuAdi.trim().isEmpty ? "Tokatlı60" : widget.oyuncuAdi.trim();

        if (trToLowerCase(kurucu) == trToLowerCase(ben)) {
          List<String> tumHarfler = ["A", "B", "C", "Ç", "D", "E", "F", "G", "H", "I", "İ", "J", "K", "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"];
          List<String> kullanilabilirHarfler = tumHarfler.where((h) => !kullanilanHarfler.contains(h)).toList();

          if (kullanilabilirHarfler.isEmpty) {
            kullanilabilirHarfler = List.from(tumHarfler);
            kullanilanHarfler.clear();
          }
          kullanilabilirHarfler.shuffle();
          String yeniHarf = kullanilabilirHarfler.first;
          kullanilanHarfler.add(yeniHarf);

          await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
            'mevcutTur': _guncelMevcutTur + 1,
            'secilenHarf': yeniHarf,
            'cevaplar': {},
            'puanlar': {},
            'hazirOyuncular': [],
          });
        }
      } else {
        setState(() {
          _guncelOyuncuSkor += oyuncuTurPuani;
          _guncelRakip1Skor += rakip1TurPuani;
          _guncelMevcutTur += 1;
          aktifKategoriIndex = 0;
          _yeniTurBaslat(ilkBaslangic: false);
        });
      }
    } else {
      int hamOyuncuSkoru = _guncelOyuncuSkor + oyuncuTurPuani;
      int hamRakipSkoru = _guncelRakip1Skor + rakip1TurPuani;

      int dbOyuncuSkoru = hamOyuncuSkoru;
      int dbRakipSkoru = hamRakipSkoru;

      if (hamOyuncuSkoru > hamRakipSkoru) {
        dbOyuncuSkoru += 100;
      } else if (hamRakipSkoru > hamOyuncuSkoru) {
        dbRakipSkoru += 100;
      }

      String ben = widget.oyuncuAdi.trim().isEmpty ? "Tokatlı60" : widget.oyuncuAdi.trim();

      List<Map<String, dynamic>> eskiTablo = await DatabaseHelper.instance.getTumLiderlikTablosu(ben);
      int eskiSiralama = max(1000, eskiTablo.length);
      for (int i = 0; i < eskiTablo.length; i++) {
        if (eskiTablo[i]['bot_adi'] == ben) {
          eskiSiralama = i + 1;
          break;
        }
      }

      await DatabaseHelper.instance.saveOyuncuSkor(ben, dbOyuncuSkoru);
      if (widget.rakipAdi.trim().isNotEmpty) {
        await DatabaseHelper.instance.saveBotSkor(widget.rakipAdi.trim(), dbRakipSkoru);
      }

      List<Map<String, dynamic>> yeniTablo = await DatabaseHelper.instance.getTumLiderlikTablosu(ben);
      int yeniSiralama = max(1000, yeniTablo.length);
      int yeniGenelPuan = 0;

      for (int i = 0; i < yeniTablo.length; i++) {
        if (yeniTablo[i]['bot_adi'] == ben) {
          yeniSiralama = i + 1;
          yeniGenelPuan = (yeniTablo[i]['skor'] as num).toInt();
          break;
        }
      }

      int eskiGenelPuan = max(0, yeniGenelPuan - dbOyuncuSkoru);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              oyuncuAdi: ben,
              rakipAdi: widget.rakipAdi.trim(),
              oyuncuMacSkor: hamOyuncuSkoru,
              rakipMacSkor: hamRakipSkoru,
              eskiGenelPuan: eskiGenelPuan,
              yeniGenelPuan: yeniGenelPuan,
              eskiSiralama: eskiSiralama,
              yeniSiralama: yeniSiralama,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var mevcutKategori = kategoriler[aktifKategoriIndex];
    String ben = widget.oyuncuAdi.trim().isEmpty ? "Tokatlı60" : trToUpperCase(widget.oyuncuAdi.trim());
    String rakip = widget.rakipAdi.trim().isEmpty ? "RAKİP" : trToUpperCase(widget.rakipAdi.trim());

    if (rakipBekleniyor) {
      return Scaffold(
        backgroundColor: Colors.purple.shade800,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Cevaplarınız Kaydedildi! 🚀\nRakibin Turu Bitirmesi Bekleniyor...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const SafeArea(child: BottomBannerAdWidget()),
      );
    }

    if (turBittiMi) {
      int toplamOyuncu = _guncelOyuncuSkor + oyuncuTurPuani;
      int toplamRakip = _guncelRakip1Skor + rakip1TurPuani;
      bool sonTurMu = (_guncelMevcutTur >= widget.toplamTurSayisi);

      return Scaffold(
        backgroundColor: Colors.purple.shade900,
        body: SafeArea(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 85,
                          color: Colors.purple.shade500,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("$toplamOyuncu", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              Text(ben, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 85,
                          color: Colors.pink.shade400,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("$toplamRakip", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              Text(rakip, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Text(trToUpperCase(secilenHarf), style: TextStyle(color: Colors.purple.shade900, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ...kategoriler.map((kat) {
                        int id = kat["id"];
                        String oKelime = trToUpperCase(oyuncuCevaplari[id] ?? "-");
                        String rKelime = trToUpperCase(rakip1Cevaplari[id] ?? "-");
                        int oPuan = oyuncuKategoriPuanlari[id] ?? 0;
                        int rPuan = rakipKategoriPuanlari[id] ?? 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      oKelime,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "$oPuan",
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white38, width: 1.5),
                                  color: Colors.purple.shade800,
                                ),
                                child: Icon(kat["icon"], color: Colors.white, size: 18),
                              ),

                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      rKelime,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "$rPuan",
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 6),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(Icons.access_time, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text("ZAMAN BONUSU", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                                  Text("${erkenBitirmeBonusuKazandiMi ? 10 : 0}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Column(
                                children: [
                                  Text("ZAMAN BONUSU", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                                  Text("0", style: TextStyle(color: Colors.white, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Colors.white38, thickness: 1.2),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text("📊 OTURUM TUR DETAYLARI", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),

                      ...List.generate(_guncelMevcutTur, (index) {
                        int turNo = index + 1;
                        int oTurPuan = turBazliOyuncuPuanlari[turNo] ?? (turNo == _guncelMevcutTur ? oyuncuTurPuani : 0);
                        int rTurPuan = turBazliRakipPuanlari[turNo] ?? (turNo == _guncelMevcutTur ? rakip1TurPuani : 0);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("$turNo. Tur Puanı", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                              Row(
                                children: [
                                  Text("+$oTurPuan", style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 35),
                                  Text("+$rTurPuan", style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(color: Colors.white38, thickness: 1.2),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Toplam: $toplamOyuncu", style: const TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("Toplam: $toplamRakip", style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: [
                    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty && !sonTurMu)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          rakipHazirMi ? " Rakip Hazır! Seni Bekliyor." : "⏳ Rakibin Hazır Olması Bekleniyor...",
                          style: TextStyle(
                            color: rakipHazirMi ? Colors.greenAccent : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: benHazirMiyim ? null : () => _hazirButonunaBasildi(),
                        icon: Icon(
                          benHazirMiyim
                              ? Icons.check_circle_rounded
                              : (sonTurMu ? Icons.emoji_events_rounded : Icons.play_arrow_rounded),
                          color: benHazirMiyim ? Colors.green : Colors.purple.shade900,
                          size: 26,
                        ),
                        label: Text(
                          benHazirMiyim
                              ? "HAZIR - İLERLENİYOR..."
                              : (sonTurMu
                              ? "SONUÇLARI GÖR 🏆 ($_kalanGuvenlikSaniyesi sn)"
                              : "HAZIRIM 👍 ($_kalanGuvenlikSaniyesi sn)"),
                          style: TextStyle(
                            color: benHazirMiyim ? Colors.white70 : Colors.purple.shade900,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: benHazirMiyim ? Colors.green.shade800 : Colors.white,
                          disabledBackgroundColor: Colors.purple.shade800,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
          title: const Text("İsim Şehir Hayvan Oyunu", style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tur: $_guncelMevcutTur / ${widget.toplamTurSayisi}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kalanSure <= 20 ? Colors.red.shade100 : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: _kalanSure <= 20 ? Colors.red : Colors.purple, size: 15),
                      const SizedBox(width: 4),
                      Text("$_kalanSure sn", style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Text("Harf: $secilenHarf", style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 15),

            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.purple.shade100,
              child: Text(secilenHarf, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(kategoriler.length, (index) {
                  String cevap = oyuncuCevaplari[kategoriler[index]["id"]] ?? "";
                  bool dolumu = (cevap.isNotEmpty && cevap != "-" && cevap.length >= 2);

                  return InkWell(
                    onTap: () { if (!erkenBitirmeBonusuKazandiMi) kategoriDegistir(index); },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        kategoriler[index]["icon"],
                        size: 24,
                        color: index == aktifKategoriIndex
                            ? Colors.purple
                            : (dolumu ? Colors.blue : Colors.grey.shade400),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text("${mevcutKategori["isim"]} Kategorisi", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
            const SizedBox(height: 10),
            TextField(
              controller: _inputController,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              enabled: !erkenBitirmeBonusuKazandiMi,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: "Kelimenizi buraya yazın...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(mevcutKategori["icon"], color: Colors.purple),
              ),
            ),
            const SizedBox(height: 16),

            if (erkenBitirmeBonusuKazandiMi)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade900,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "⚡ 20 SANİYE KURALI BAŞLATILDI!",
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
                            backgroundColor: Colors.purple.shade700,
                          ),
                        ),
                        Text(
                          "$_kalanSure",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Text(
                      "Rakibin süresinin dolması bekleniyor...",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: MediumRectangleAdWidget(),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: turuBitirBtnAktif ? () => turuErkenBitirIstegi() : null,
                        icon: const Icon(Icons.flag_rounded, color: Colors.white),
                        label: Text(
                          erkenBitirmeBonusuKazandiMi
                              ? "Sürenin Bitmesi Bekleniyor..."
                              : (_kalanSure < 20
                              ? "SON 20 SANİYE (BONUS KAPANDI)"
                              : (turuBitirBtnAktif
                              ? "TURU BİTİR (+10 ZAMAN BONUSU)"
                              : "TURU BİTİR (EN AZ 5 KELİME YAZIN)")),
                          style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: turuBitirBtnAktif ? Colors.redAccent.shade200 : Colors.grey.shade400,
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: turuBitirBtnAktif ? 3 : 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (aktifKategoriIndex > 0 && !erkenBitirmeBonusuKazandiMi)
                                ? () => kategoriDegistir(aktifKategoriIndex - 1)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("◄ Önceki", style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: (aktifKategoriIndex < kategoriler.length - 1 && !erkenBitirmeBonusuKazandiMi)
                                ? () => kategoriDegistir(aktifKategoriIndex + 1)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Sonraki ►", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: erkenBitirmeBonusuKazandiMi
          ? const SizedBox.shrink()
          : const SafeArea(child: BottomBannerAdWidget()),
    );
  }
}