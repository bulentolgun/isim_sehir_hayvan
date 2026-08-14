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
  final List<Map<String, dynamic>> kategoriler = const [
    {"id": 1, "isim": "İsim", "icon": Icons.groups},
    {"id": 2, "isim": "Şehir", "icon": Icons.home},
    {"id": 3, "isim": "Hayvan", "icon": Icons.pets},
    {"id": 4, "isim": "Bitki", "icon": Icons.eco},
    {"id": 5, "isim": "Eşya", "icon": Icons.handyman},
    {"id": 6, "isim": "Ülke", "icon": Icons.flag},
  ];

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

  // 🚀 EKLENDİ: Yükleme ekranı durumu
  bool isLoading = false;

  bool benHazirMiyim = false;
  int hazirOyuncuSayisi = 0;
  bool _isTransitioning = false;
  Timer? _guvenlikTimer;
  int _kalanGuvenlikSaniyesi = 15;

  String odadakiErkenBitirenKisi = "";

  String secilenHarf = "A";
  Timer? _timer;
  StreamSubscription<DocumentSnapshot>? _odaSubscription;
  int _kalanSure = 90;

  late int _guncelMevcutTur;
  int _seciliRakipIndex = 1;

  final List<String> yasakliKelimeler = const [
    "amk", "sik", "piç", "orospu", "oç", "sg", "yarrak", "göt", "meme", "dalyarak", "pezevenk", "kaltak", "fahişe"
  ];
  List<String> kullanilanHarfler = [];

  String trToLowerCase(String text) {
    return text.replaceAll('İ', 'i').replaceAll('I', 'ı').replaceAll('Ğ', 'ğ').replaceAll('Ü', 'ü')
        .replaceAll('Ş', 'ş').replaceAll('Ö', 'ö').replaceAll('Ç', 'ç').toLowerCase();
  }
  String trToUpperCase(String text) {
    return text.replaceAll('i', 'İ').replaceAll('ı', 'I').replaceAll('ğ', 'Ğ').replaceAll('ü', 'Ü')
        .replaceAll('ş', 'Ş').replaceAll('ö', 'Ö').replaceAll('ç', 'Ç').toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _guncelMevcutTur = widget.mevcutTur;

    ben = widget.oyuncuAdi.trim().isEmpty ? "Tokatlı60" : widget.oyuncuAdi.trim();
    List<String> rakipler = widget.rakipAdi.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (rakipler.isEmpty) rakipler = ["Rakip"];

    masadakiHerkes = [ben, ...rakipler];

    for (var p in masadakiHerkes) {
      tumCevaplar[p] = {};
      tumKategoriPuanlari[p] = {};
      tumTurPuanlari[p] = 0;
      macSkorlari[p] = 0;
      genelKumulatifSkorlar[p] = (p == ben) ? widget.oyuncuKumulatifSkor : widget.rakip1KumulatifSkor;
    }

    _gercekSkorlariYukle();

    AdService.instance.loadInterstitialAd();
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

  Future<void> _gercekSkorlariYukle() async {
    List<Map<String, dynamic>> tablo = await DatabaseHelper.instance.getTumLiderlikTablosu(ben);
    if (mounted) {
      setState(() {
        for (var p in masadakiHerkes) {
          if (p != ben) {
            var oyuncuVeri = tablo.firstWhere(
                    (element) => element['bot_adi'] == p,
                orElse: () => {'skor': widget.rakip1KumulatifSkor}
            );
            genelKumulatifSkorlar[p] = (oyuncuVeri['skor'] as num).toInt();
          }
        }
      });
    }
  }

  void _canliOdaDinle() {
    if (widget.odaKodu == null || widget.odaKodu!.isEmpty) return;

    _odaSubscription = FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).snapshots().listen((snapshot) async {
      if (!snapshot.exists || !mounted) return;

      var data = snapshot.data() as Map<String, dynamic>;
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
        if (mounted) {
          setState(() {
            hazirOyuncuSayisi = hazirOyuncular.length;
          });
        }
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

  void _guvenlikSayaciniBaslat() {
    _guvenlikTimer?.cancel();
    _kalanGuvenlikSaniyesi = 15;
    _guvenlikTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
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
    if (mounted) setState(() { benHazirMiyim = true; });

    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
      await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
        'hazirOyuncular': FieldValue.arrayUnion([ben]),
      });
    } else {
      _sonrakiTuraGec();
    }
  }

  void _yeniTurBaslat({bool ilkBaslangic = false, String? firebaseHarfi}) {
    _isTransitioning = false;
    _timer?.cancel();
    _guvenlikTimer?.cancel();
    _inputController.clear();

    if (ilkBaslangic) kullanilanHarfler.clear();

    if (firebaseHarfi != null && firebaseHarfi.isNotEmpty) {
      secilenHarf = firebaseHarfi;
      if (!kullanilanHarfler.contains(secilenHarf)) kullanilanHarfler.add(secilenHarf);
    } else if (widget.secilenHarf != null && widget.secilenHarf!.isNotEmpty && ilkBaslangic) {
      secilenHarf = widget.secilenHarf!;
      if (!kullanilanHarfler.contains(secilenHarf)) kullanilanHarfler.add(secilenHarf);
    } else {
      final tumHarfler = ["A", "B", "C", "Ç", "D", "E", "F", "G", "H", "I", "İ", "J", "K", "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"];
      List<String> kullanilabilirHarfler = tumHarfler.where((h) => !kullanilanHarfler.contains(h)).toList();
      if (kullanilabilirHarfler.isEmpty) { kullanilabilirHarfler = List.from(tumHarfler); kullanilanHarfler.clear(); }
      kullanilabilirHarfler.shuffle();
      secilenHarf = kullanilabilirHarfler.first;
      kullanilanHarfler.add(secilenHarf);
    }

    if (ilkBaslangic || botTurBasariOranlari.isEmpty) {
      botTurBasariOranlari = List<int>.filled(widget.toplamTurSayisi, 90, growable: true);
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

    _zamanlayiciyiBaslat();

    if (widget.odaKodu == null || widget.odaKodu!.isEmpty) {
      _botCevaplariniHazirla();
    }
  }

  void _zamanlayiciyiBaslat() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (_kalanSure > 0) { _kalanSure--; }
        else {
          _timer?.cancel();
          _mevcutKelimeyiKaydet();
          _cevaplariFirebaseeGonderAndDegerlendir();
        }
      });
    });
  }

  Future<void> _botCevaplariniHazirla() async {
    final random = Random();
    int basariYuzdesi = 90;

    for (var botName in masadakiHerkes) {
      if (botName == ben) continue;
      Map<int, String> geciciCevaplar = {};

      for (var kat in kategoriler) {
        int catId = kat["id"];
        if (random.nextInt(100) < basariYuzdesi) {
          String? botKelime = await DatabaseHelper.instance.getBotKelime(catId, secilenHarf);
          geciciCevaplar[catId] = botKelime ?? "-";
        } else {
          geciciCevaplar[catId] = "-";
        }
      }

      if (mounted) {
        setState(() { tumCevaplar[botName] = geciciCevaplar; });
      }
    }
  }

  bool _harfDogruMu(String kelime) {
    if (kelime.isEmpty || kelime == "-") return true;
    return trToLowerCase(kelime[0]) == trToLowerCase(secilenHarf);
  }

  void _harfUyarisiGoster() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Girdiğiniz kelime '$secilenHarf' harfi ile başlamalıdır!"), backgroundColor: Colors.orange.shade800, duration: const Duration(seconds: 2),
    ));
  }

  bool _girdiGecerliMi() {
    String metin = trToLowerCase(_inputController.text.trim());
    int currentCatId = kategoriler[aktifKategoriIndex]["id"];

    if (metin.isEmpty) return true;

    List<String> istisnalar = ["sikke", "siklamen"];
    if (!istisnalar.contains(metin)) {
      String noktalamaBozuk = metin.replaceAll(RegExp(r'[.,!?*/\-_]'), '');
      List<String> girilenKelimeler = noktalamaBozuk.split(' ');

      for (var yasakli in yasakliKelimeler) {
        String kucukYasakli = trToLowerCase(yasakli);
        for(var kelime in girilenKelimeler) {
          if (kelime == kucukYasakli || kelime.startsWith(kucukYasakli)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uygunsuz kelime tespiti!"), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
            return false;
          }
        }
      }
    }

    if (!_harfDogruMu(metin)) { _harfUyarisiGoster(); return false; }

    if (currentCatId == 1 && metin.contains(" ")) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İsim bölümüne sadece tek bir isim girebilirsiniz!"), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
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
      String cevap = (id == mevcutCatId) ? anlikKelime : (tumCevaplar[ben]?[id] ?? "-");
      if (cevap == "-" || cevap.trim().isEmpty || cevap.trim().length < 2) bosKutuSayisi++;
    }
    return bosKutuSayisi <= 1;
  }

  void turuErkenBitirIstegi() async {
    if (erkenBitirmeBonusuKazandiMi) return;
    if (!_girdiGecerliMi()) return;
    _mevcutKelimeyiKaydet();

    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
      await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
        'erkenBitiren': ben,
      });
    } else {
      setState(() {
        odadakiErkenBitirenKisi = ben;
        erkenBitirmeBonusuKazandiMi = true;
        if (_kalanSure > 20) _kalanSure = 20;
      });
    }

    AdService.instance.showEmniyetliGecisReklami(
      onReklamBitti: () {
        if (!mounted) return;
        if (_kalanSure <= 0) { _cevaplariFirebaseeGonderAndDegerlendir(); }
        else { setState(() {}); }
      },
    );
  }

  void _arkaplanTdkKontrol(int catId, String kelime) {
    if (kelime.length >= 2 && kelime != "-") {
      DatabaseHelper.instance.checkWordWithToleranceAndTdk(catId, secilenHarf, kelime);
    }
  }

  void _mevcutKelimeyiKaydet() {
    if (!_girdiGecerliMi()) { _inputController.clear(); }

    String girilenKelime = _inputController.text.trim();
    int currentCatId = kategoriler[aktifKategoriIndex]["id"];

    if (girilenKelime.isEmpty || girilenKelime.length < 2) {
      tumCevaplar.putIfAbsent(ben, () => {})[currentCatId] = "-";
    } else {
      tumCevaplar.putIfAbsent(ben, () => {})[currentCatId] = girilenKelime;
      _arkaplanTdkKontrol(currentCatId, girilenKelime);
    }
  }

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

  Future<void> _cevaplariFirebaseeGonderAndDegerlendir() async {
    _timer?.cancel();
    _mevcutKelimeyiKaydet();

    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
      Map<String, String> stringMap = {};
      for (var kat in kategoriler) {
        int id = kat["id"];
        String cevap = tumCevaplar[ben]?[id] ?? "-";
        stringMap[id.toString()] = cevap.trim().isEmpty ? "-" : cevap;
      }

      await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
        'cevaplar.$ben': stringMap,
      });

      var doc = await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).get();
      var anlikCevaplar = doc.data()?['cevaplar'] as Map<String, dynamic>? ?? {};

      if (anlikCevaplar.length < masadakiHerkes.length) {
        if (mounted) setState(() { rakipBekleniyor = true; });

        String kurucu = doc.data()?['kurucu']?.toString().trim() ?? "";
        if (trToLowerCase(kurucu) == trToLowerCase(ben)) {
          Future.delayed(const Duration(seconds: 7), () async {
            if (mounted && rakipBekleniyor && !turBittiMi) {
              var guncelDoc = await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).get();
              var guncelCevaplar = guncelDoc.data()?['cevaplar'] as Map<String, dynamic>? ?? {};

              bool eksikVarMi = false;
              Map<String, dynamic> tamamlanmisCevaplar = Map.from(guncelCevaplar);

              for (var p in masadakiHerkes) {
                if (!tamamlanmisCevaplar.containsKey(p)) {
                  eksikVarMi = true;
                  Map<String, String> bosCevap = {};
                  for (var kat in kategoriler) { bosCevap[kat["id"].toString()] = "-"; }
                  tamamlanmisCevaplar[p] = bosCevap;
                }
              }

              if (eksikVarMi) {
                await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
                  'cevaplar': tamamlanmisCevaplar,
                });
              }
            }
          });
        }
        return;
      } else {
        String kurucu = doc.data()?['kurucu']?.toString().trim() ?? "";
        if (trToLowerCase(kurucu) == trToLowerCase(ben)) {
          await _hostPuanlariHesaplaVeKaydet();
        } else {
          if (mounted) setState(() { rakipBekleniyor = true; });
        }
      }
    } else {
      await topluDegerlendir();
    }
  }

  Future<void> _hostPuanlariHesaplaVeKaydet() async {
    await topluDegerlendir();
    Map<String, dynamic> tumPuanlarFirebase = {};

    for (var p in masadakiHerkes) {
      Map<String, int> pPuan = {};
      tumKategoriPuanlari[p]?.forEach((k, v) => pPuan[k.toString()] = v);
      tumPuanlarFirebase[p] = pPuan;
    }

    await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
      'puanlar': tumPuanlarFirebase,
    });
  }

  // 🚀 İŞTE BEKLENEN O BÜYÜK SİHİR: PARALEL HESAPLAMA! 🚀
  Future<void> topluDegerlendir() async {
    _timer?.cancel();

    // Ekranı "Hesaplanıyor" durumuna al
    if (mounted) setState(() { isLoading = true; });

    try {
      List<Future<int>> futures = [];
      List<Map<String, dynamic>> futureMeta = [];

      // 1. Tüm kelimeleri (oyuncular * kategoriler) toplayıp listeye ekliyoruz
      for (var kat in kategoriler) {
        int id = kat["id"];
        for (var p in masadakiHerkes) {
          String cvp = tumCevaplar[p]?[id] ?? "-";
          // Her kelimenin sorgusunu futures listesine ekliyoruz
          futures.add(DatabaseHelper.instance.checkWordWithToleranceAndTdk(id, secilenHarf, cvp));
          // Bu sonucun kime ve hangi kategoriye ait olduğunu bilmek için not alıyoruz
          futureMeta.add({"id": id, "player": p, "cvp": cvp});
        }
      }

      // ⚡ 2. BÜYÜK SİHİR: Tüm kontrolleri (örn. 4 oyuncu x 6 kategori = 24 sorgu) AYNI ANDA başlatıp bekliyoruz!
      var sonuclar = await Future.wait(futures);

      Map<int, Map<String, int>> dogruluklar = {};
      Map<int, Map<String, String>> cevaplar = {};
      Map<int, int> enUzunDogruKelime = {};

      for (var kat in kategoriler) {
        int id = kat["id"];
        dogruluklar[id] = {};
        cevaplar[id] = {};
        enUzunDogruKelime[id] = 0;
      }

      // 3. Yapay zekadan saniyeler içinde gelen tüm sonuçları ayrıştırıp ilgili değişkenlere yazıyoruz
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

      // 4. Mükemmel "Pişti" kuralları ve puan hesaplama
      for (var kat in kategoriler) {
        int id = kat["id"];
        for (var p in masadakiHerkes) {
          int puan = 0;
          if (dogruluklar[id]![p]! > 0) {
            String benimCevap = trToLowerCase(cevaplar[id]![p]!);
            bool pistiOlduMu = false;

            for (var diger in masadakiHerkes) {
              if (diger != p && dogruluklar[id]![diger]! > 0) {
                if (trToLowerCase(cevaplar[id]![diger]!) == benimCevap) {
                  pistiOlduMu = true; break;
                }
              }
            }

            // Pişti ise 5, değilse 10 puan!
            puan = pistiOlduMu ? 5 : 10;
            // En uzun kelime bonusu!
            if (cevaplar[id]![p]!.length == enUzunDogruKelime[id]! && enUzunDogruKelime[id]! > 0) puan += 2;
          }

          tumKategoriPuanlari.putIfAbsent(p, () => {})[id] = puan;
          tumTurPuanlari[p] = (tumTurPuanlari[p] ?? 0) + puan;
        }
      }

      // 5. Erken bitirene ekstra puan
      if (odadakiErkenBitirenKisi.isNotEmpty) {
        tumTurPuanlari[odadakiErkenBitirenKisi] = (tumTurPuanlari[odadakiErkenBitirenKisi] ?? 0) + 10;
      }

      // 6. Sonuçları ekrana yansıt
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
      // İşlem bitince yükleme ekranını kapat
      if (mounted) setState(() { isLoading = false; });
    }
  }

  Future<void> _sonrakiTuraGec() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _guvenlikTimer?.cancel();

    if (_guncelMevcutTur < widget.toplamTurSayisi) {
      if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty) {
        var doc = await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).get();
        String kurucu = doc.data()?['kurucu']?.toString().trim() ?? "";

        if (trToLowerCase(kurucu) == trToLowerCase(ben)) {
          List<String> tumHarfler = ["A", "B", "C", "Ç", "D", "E", "F", "G", "H", "I", "İ", "J", "K", "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"];
          List<String> kullanilabilirHarfler = tumHarfler.where((h) => !kullanilanHarfler.contains(h)).toList();
          if (kullanilabilirHarfler.isEmpty) { kullanilabilirHarfler = List.from(tumHarfler); kullanilanHarfler.clear(); }
          kullanilabilirHarfler.shuffle();
          String yeniHarf = kullanilabilirHarfler.first;
          kullanilanHarfler.add(yeniHarf);

          await FirebaseFirestore.instance.collection('odalar').doc(widget.odaKodu).update({
            'mevcutTur': _guncelMevcutTur + 1,
            'secilenHarf': yeniHarf,
            'cevaplar': {},
            'puanlar': {},
            'hazirOyuncular': [],
            'erkenBitiren': "",
          });
        }
      } else {
        setState(() {
          for(var p in masadakiHerkes) {
            macSkorlari[p] = (macSkorlari[p] ?? 0) + (tumTurPuanlari[p] ?? 0);
            genelKumulatifSkorlar[p] = (genelKumulatifSkorlar[p] ?? 0) + (tumTurPuanlari[p] ?? 0);
            tumTurPuanlari[p] = 0;
          }
          _guncelMevcutTur += 1;
          aktifKategoriIndex = 0;
          _seciliRakipIndex = 1;
          _yeniTurBaslat(ilkBaslangic: false);
        });
      }
    } else {
      for(var p in masadakiHerkes) {
        macSkorlari[p] = (macSkorlari[p] ?? 0) + (tumTurPuanlari[p] ?? 0);
        genelKumulatifSkorlar[p] = (genelKumulatifSkorlar[p] ?? 0) + (tumTurPuanlari[p] ?? 0);
        tumTurPuanlari[p] = 0;
      }

      int benimMacSkorum = macSkorlari[ben] ?? 0;
      bool birinciMiyim = true;
      for (var p in masadakiHerkes) {
        if (p != ben && (macSkorlari[p] ?? 0) > benimMacSkorum) {
          birinciMiyim = false; break;
        }
      }

      int yazilacakDBPuan = (genelKumulatifSkorlar[ben] ?? 0) + (birinciMiyim ? 100 : 0);
      await DatabaseHelper.instance.saveOyuncuSkor(ben, yazilacakDBPuan);

      if (widget.odaKodu == null || widget.odaKodu!.isEmpty) {
        for (var rakipAdi in masadakiHerkes) {
          if (rakipAdi != ben) {
            int botMacPuan = macSkorlari[rakipAdi] ?? 0;
            bool botBirinci = true;
            for(var diger in masadakiHerkes) {
              if (diger != rakipAdi && (macSkorlari[diger] ?? 0) > botMacPuan) { botBirinci = false; break; }
            }
            int botDBPuan = (genelKumulatifSkorlar[rakipAdi] ?? 0) + (botBirinci ? 100 : 0);
            await DatabaseHelper.instance.saveBotSkor(rakipAdi, botDBPuan);
          }
        }
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

      int eskiGenelPuan = max(0, yeniGenelPuan - yazilacakDBPuan);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              oyuncuAdi: ben,
              tumMacSkorlari: macSkorlari,
              eskiGenelPuan: eskiGenelPuan,
              yeniGenelPuan: yeniGenelPuan,
              eskiSiralama: 1000,
              yeniSiralama: yeniSiralama,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 YÜKLEME EKRANI (Paralel sorgular yaparken çalışır)
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.purple.shade900,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 5),
              SizedBox(height: 25),
              Text(
                "Kelimeler Yapay Zeka Tarafından\nHızlıca Değerlendiriliyor... 🚀",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text("Cevaplarınız Kaydedildi! 🚀\nDiğer Oyuncular Bekleniyor...", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        bottomNavigationBar: const SafeArea(child: BottomBannerAdWidget()),
      );
    }

    if (turBittiMi) {
      bool sonTurMu = (_guncelMevcutTur >= widget.toplamTurSayisi);
      List<String> rakipler = masadakiHerkes.where((p) => p != ben).toList();
      String seciliRakip = rakipler.isNotEmpty ? rakipler[(_seciliRakipIndex - 1) % rakipler.length] : "Rakip Yok";

      int benimSkorum = (macSkorlari[ben] ?? 0) + (tumTurPuanlari[ben] ?? 0);
      int rakipSkorum = (macSkorlari[seciliRakip] ?? 0) + (tumTurPuanlari[seciliRakip] ?? 0);

      return Scaffold(
        backgroundColor: Colors.purple.shade900,
        body: SafeArea(
          child: Column(
            children: [
              // ÜST HEADER: SEN vs RAKİP PANOLARI
              Container(
                height: 90,
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
                            Text("$benimSkorum", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            Text(trToUpperCase(ben), overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      alignment: Alignment.center,
                      child: Text("VS", style: TextStyle(color: Colors.purple.shade800, fontWeight: FontWeight.bold, fontSize: 16)),
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
                                Text("$rakipSkorum", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25),
                                  child: Text(trToUpperCase(seciliRakip), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            if (rakipler.length > 1) ...[
                              Positioned(
                                left: 0,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _seciliRakipIndex = _seciliRakipIndex - 1 < 1 ? rakipler.length : _seciliRakipIndex - 1;
                                    });
                                  },
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _seciliRakipIndex = _seciliRakipIndex + 1 > rakipler.length ? 1 : _seciliRakipIndex + 1;
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

              const SizedBox(height: 10),

              // KELİMELERİN KARŞILAŞTIRILMASI LISTESİ (ORTA İKONLU, SİMETRİK)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: kategoriler.length + 1,
                  itemBuilder: (context, index) {

                    if (index == kategoriler.length) {
                      int benimBonus = (odadakiErkenBitirenKisi == ben) ? 10 : 0;
                      int rakipBonus = (odadakiErkenBitirenKisi == seciliRakip) ? 10 : 0;

                      if (benimBonus == 0 && rakipBonus == 0) return const SizedBox.shrink();

                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text("ZAMAN BONUSU", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text("+$benimBonus", style: TextStyle(color: benimBonus > 0 ? Colors.greenAccent : Colors.white24, fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                ),
                                Container(
                                  width: 45, height: 45,
                                  decoration: BoxDecoration(color: Colors.purple.shade700, shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 1.5)),
                                  child: const Icon(Icons.timer, color: Colors.white, size: 22),
                                ),
                                Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text("ZAMAN BONUSU", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text("+$rakipBonus", style: TextStyle(color: rakipBonus > 0 ? Colors.greenAccent : Colors.white24, fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                ),
                              ]
                          )
                      );
                    }

                    int id = kategoriler[index]["id"];
                    String benimKelime = trToUpperCase(tumCevaplar[ben]?[id] ?? "-");
                    int benimPuan = tumKategoriPuanlari[ben]?[id] ?? 0;

                    String rakipKelime = trToUpperCase(tumCevaplar[seciliRakip]?[id] ?? "-");
                    int rakipPuan = tumKategoriPuanlari[seciliRakip]?[id] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "+$benimPuan",
                                  style: TextStyle(color: benimPuan > 0 ? Colors.greenAccent : Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade700,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 1.5),
                            ),
                            child: Icon(kategoriler[index]["icon"], color: Colors.white, size: 22),
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  rakipKelime,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "+$rakipPuan",
                                  style: TextStyle(color: rakipPuan > 0 ? Colors.greenAccent : Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: [
                    if (widget.odaKodu != null && widget.odaKodu!.isNotEmpty && !sonTurMu)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          hazirOyuncuSayisi >= masadakiHerkes.length ? " Herkes Hazır! İlerleniyor..." : "⏳ $hazirOyuncuSayisi / ${masadakiHerkes.length} Oyuncu Hazır",
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: benHazirMiyim ? null : () => _hazirButonunaBasildi(),
                        icon: Icon(
                          benHazirMiyim ? Icons.check_circle_rounded : (sonTurMu ? Icons.emoji_events_rounded : Icons.play_arrow_rounded),
                          color: benHazirMiyim ? Colors.green : Colors.purple.shade900, size: 26,
                        ),
                        label: Text(
                          benHazirMiyim ? "HAZIR BEKLİYOR..." : (sonTurMu ? "SONUÇLARI GÖR 🏆 ($_kalanGuvenlikSaniyesi sn)" : "HAZIRIM 👍 ($_kalanGuvenlikSaniyesi sn)"),
                          style: TextStyle(color: benHazirMiyim ? Colors.white70 : Colors.purple.shade900, fontSize: 15, fontWeight: FontWeight.bold),
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
        child: AppBar(title: const Text("İsim Şehir Hayvan Oyunu", style: const TextStyle(fontSize: 18)), backgroundColor: Colors.purple, foregroundColor: Colors.white, centerTitle: true),
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
                  decoration: BoxDecoration(color: _kalanSure <= 20 ? Colors.red.shade100 : Colors.purple.shade50, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [Icon(Icons.timer, color: _kalanSure <= 20 ? Colors.red : Colors.purple, size: 15), const SizedBox(width: 4), Text("$_kalanSure sn", style: const TextStyle(fontSize: 13))]),
                ),
                Text("Harf: $secilenHarf", style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 15),

            CircleAvatar(radius: 20, backgroundColor: Colors.purple.shade100, child: Text(secilenHarf, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple))),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(kategoriler.length, (index) {
                  String cevap = tumCevaplar[ben]?[kategoriler[index]["id"]] ?? "";
                  bool dolumu = (cevap.isNotEmpty && cevap != "-" && cevap.length >= 2);
                  return InkWell(
                    onTap: () { if (!erkenBitirmeBonusuKazandiMi) kategoriDegistir(index); },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(padding: const EdgeInsets.all(6.0), child: Icon(kategoriler[index]["icon"], size: 24, color: index == aktifKategoriIndex ? Colors.purple : (dolumu ? Colors.blue : Colors.grey.shade400))),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text("${mevcutKategori["isim"]} Kategorisi", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
            const SizedBox(height: 10),
            TextField(
              controller: _inputController, autocorrect: false, enableSuggestions: false, textCapitalization: TextCapitalization.words, keyboardType: TextInputType.text, enabled: !erkenBitirmeBonusuKazandiMi,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: "Kelimenizi buraya yazın...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(mevcutKategori["icon"], color: Colors.purple)),
            ),
            const SizedBox(height: 16),

            if (erkenBitirmeBonusuKazandiMi)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.purple.shade900, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    const Text("⚡ 20 SANİYE KURALI BAŞLATILDI!", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(width: 75, height: 75, child: CircularProgressIndicator(value: _kalanSure / 20, strokeWidth: 6, color: Colors.amber, backgroundColor: Colors.purple.shade700)),
                        Text("$_kalanSure", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity, alignment: Alignment.center, padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: const ClipRRect(borderRadius: BorderRadius.all(Radius.circular(12)), child: MediumRectangleAdWidget()),
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
                      width: double.infinity, height: 48,
                      child: ElevatedButton.icon(
                        onPressed: turuBitirBtnAktif ? () => turuErkenBitirIstegi() : null,
                        icon: const Icon(Icons.flag_rounded, color: Colors.white),
                        label: Text(
                          erkenBitirmeBonusuKazandiMi ? "Sürenin Bitmesi Bekleniyor..." : (_kalanSure < 20 ? "SON 20 SANİYE (BONUS KAPANDI)" : (turuBitirBtnAktif ? "TURU BİTİR (+10 ZAMAN BONUSU)" : "TURU BİTİR (EN AZ 5 KELİME YAZIN)")),
                          style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: turuBitirBtnAktif ? Colors.redAccent.shade200 : Colors.grey.shade400, disabledBackgroundColor: Colors.grey.shade400, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: ElevatedButton(onPressed: (aktifKategoriIndex > 0 && !erkenBitirmeBonusuKazandiMi) ? () => kategoriDegistir(aktifKategoriIndex - 1) : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("◄ Önceki", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)))),
                        const SizedBox(width: 10),
                        Expanded(child: ElevatedButton(onPressed: (aktifKategoriIndex < kategoriler.length - 1 && !erkenBitirmeBonusuKazandiMi) ? () => kategoriDegistir(aktifKategoriIndex + 1) : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Sonraki ►", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                      ],
                    ),
                  ],

                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: erkenBitirmeBonusuKazandiMi ? const SizedBox.shrink() : const SafeArea(child: BottomBannerAdWidget()),
    );
  }
}