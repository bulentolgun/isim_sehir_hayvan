import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ⌨️ Klavye servisleri için eklendi
import 'dart:async';
import 'dart:math';
import 'package:isim_sehir_hayvan/result_page.dart';

class GamePage extends StatefulWidget {
  final String oyuncuAdi;
  final int yuzIndex;
  final int aksesuarIndex;
  final int renkIndex;
  final int mevcutTur;
  final int toplamTurSayisi;
  final int oyuncuKumulatifSkor;
  final int rakip1KumulatifSkor;
  final int rakip2KumulatifSkor;

  const GamePage({
    super.key,
    required this.oyuncuAdi,
    required this.yuzIndex,
    required this.aksesuarIndex,
    required this.renkIndex,
    required this.mevcutTur,
    required this.toplamTurSayisi,
    required this.oyuncuKumulatifSkor,
    required this.rakip1KumulatifSkor,
    required this.rakip2KumulatifSkor,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<String> _kategoriler = ['isim', 'sehir', 'hayvan', 'bitki', 'esya', 'ulke'];

  final Map<String, TextEditingController> _controllers = {
    'isim': TextEditingController(), 'sehir': TextEditingController(), 'hayvan': TextEditingController(),
    'bitki': TextEditingController(), 'esya': TextEditingController(), 'ulke': TextEditingController(),
  };

  final Map<String, FocusNode> _focusNodes = {
    'isim': FocusNode(), 'sehir': FocusNode(), 'hayvan': FocusNode(),
    'bitki': FocusNode(), 'esya': FocusNode(), 'ulke': FocusNode(),
  };

  final Map<String, String> _kategoriBasliklari = {
    'isim': 'İSİM', 'sehir': 'ŞEHİR', 'hayvan': 'HAYVAN', 'bitki': 'BİTKİ', 'esya': 'EŞYA', 'ulke': 'ÜLKE'
  };

  int _aktifKategoriIndex = 0;
  late String _secilenHarf;
  int _kalanSure = 90;
  Timer? _timer;
  bool _turBittiMi = false;
  bool _bitirBasildiMi = false;

  final List<String> _isimHavuzu = [
    'Yiğit_34', 'Merve_İzmir', 'Can_Kaya', 'Aslan_Alper', 'Zeynep_İst',
    'Burak_06', 'Ebru_Yılmaz', 'Arda_Bursa', 'Selin_Güneş', 'Deniz_Efe'
  ];
  late String _rakip1; late String _rakip2;

  final List<String> _turkceHarfler = [
    "A", "B", "C", "Ç", "D", "E", "F", "G", "Ğ", "H", "I", "İ", "J", "K",
    "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"
  ];

  final List<String> _karaListeKokler = ['KÜFÜR', 'ARGO', 'IRKCI', 'SLANG'];

  // 📝 Genişletilmiş ve Türkçe Karakterleri Barındıran Kelime Veritabanı
  final Map<String, Map<String, List<String>>> _kelimeVeritabani = {
    'K': {
      'isim': ['KEMAL', 'KAAN', 'KADİR', 'KEREM', 'KADRİYE', 'KÜBRA', 'KORAY', 'KAYRA', 'KAZIM', 'KENAN', 'KERİM', 'KAMİL', 'KARDELEN', 'KARTAL', 'KÜRŞAT'],
      'sehir': ['KARS', 'KASTAMONU', 'KAYSERİ', 'KIRKLARELİ', 'KIRŞEHİR', 'KOCAELİ', 'KONYA', 'KÜTAHYA', 'KIRIKKALE', 'KARAMAN', 'KARABÜK'],
      'hayvan': ['KEDİ', 'KÖPEK', 'KUŞ', 'KANGURU', 'KAPLAN', 'KAPLUMBAĞA', 'KAZ', 'KOYUN', 'KEÇİ', 'KOALA', 'KARTAL', 'KARINCA', 'KELEBEK', 'KÖSTEBEK', 'KÖPEKBALIĞI'],
      'bitki': ['KAVUN', 'KARPUZ', 'KAYISI', 'KİRAZ', 'KİVİ', 'KESTANE', 'KARNABAHAR', 'KEREVİZ', 'KABAK', 'KEKİK', 'KARANFİL', 'KAKTÜS', 'KAVAK', 'KIZILCIK'],
      'esya': ['KALE', 'KAPI', 'KOLTUK', 'KAŞIK', 'KASE', 'KİTAP', 'KALEM', 'KLAVYE', 'KAZAN', 'KUTU', 'KİLİT', 'KİLİM', 'KUMANDA', 'KAFES', 'KASK', 'KAVANOZ'],
      'ulke': ['KANADA', 'KAZAKİSTAN', 'KENYA', 'KIRGIZİSTAN', 'KOLOMBİYA', 'KONGO', 'KOSOVA', 'KUVEYT', 'KUZEY KORE', 'KUZEY MAKEDONYA', 'KAMERUN', 'KATAR', 'KİRİBATİ', 'KAMBOÇYA']
    },
    'Ç': {
      'isim': ['ÇAĞLA', 'ÇAĞRI', 'ÇINAR', 'ÇETİN', 'ÇİĞDEM', 'ÇAĞATAY'],
      'sehir': ['ÇANAKKALE', 'ÇANKIRI', 'ÇORUM', 'ÇORLU'],
      'hayvan': ['ÇİTA', 'ÇAKAL', 'ÇEKİRGE', 'ÇULLUK', 'ÇAÇA'],
      'bitki': ['ÇİLEK', 'ÇAĞLA', 'ÇAY', 'ÇÖREKOTU', 'ÇINAR'],
      'esya': ['ÇANTA', 'ÇATAL', 'ÇEKİÇ', 'ÇERÇEVE', 'ÇAYDANLIK', 'ÇORAP'],
      'ulke': ['ÇAD', 'ÇEK CUMHURİYETİ', 'ÇİN']
    },
    'Ğ': {
      'isim': ['GALİP', 'GÖKSU'],
      'sehir': ['GÜMÜŞHANE', 'GAZİANTEP'],
      'hayvan': ['GEYİK', 'GÖVERCİN'],
      'bitki': ['GÜL', 'GELİNCİK'],
      'esya': ['GÖZLÜK', 'GAZETE'],
      'ulke': ['GANA', 'GÜRCİSTAN']
    },
    'I': {
      'isim': ['IRMAK', 'ILGAR', 'ILGIN', 'IŞIK', 'IŞIL', 'ITIR'],
      'sehir': ['IĞDIR', 'ISPARTA'],
      'hayvan': ['ISTAKOZ', 'IŞIKBÖCEĞİ'],
      'bitki': ['IHLAMUR', 'ISPANAK', 'ITIR'],
      'esya': ['IZGARA', 'IŞILDAK', 'IŞIK'],
      'ulke': ['IRAK', 'İRLANDA']
    },
    'Ö': {
      'isim': ['ÖMER', 'ÖZGE', 'ÖZGÜR', 'ÖZLEM', 'ÖMÜR', 'ÖZKAN', 'ÖZCAN'],
      'sehir': ['ÖDEMİŞ'],
      'hayvan': ['ÖRDEK', 'ÖMERCİK', 'ÖREKKE'],
      'bitki': ['ÖKSE OTU', 'ÖLMEZ ÇİÇEK'],
      'esya': ['ÖNLÜK', 'ÖLÇEK', 'ÖRGÜ ŞİŞİ'],
      'ulke': ['ÖZBEKİSTAN', 'AVUSTURYA']
    },
    'Ş': {
      'isim': ['ŞENOL', 'ŞENAY', 'ŞERİF', 'ŞAHİN', 'ŞULE', 'ŞEYMA', 'ŞEVVAL'],
      'sehir': ['ŞANLIURFA', 'ŞIRNAK'],
      'hayvan': ['ŞANPANZE', 'ŞAHİN', 'ŞETLAND'],
      'bitki': ['ŞEFTALİ', 'ŞALGAM', 'ŞEKER PANCARI'],
      'esya': ['ŞEMSİYE', 'ŞİŞE', 'ŞAMDAN', 'ŞAPKA', 'ŞARJ CİHAZI'],
      'ulke': ['ŞİLİ', 'ŞERİ LANKA']
    },
    'Ü': {
      'isim': ['ÜMİT', 'ÜMMÜHAN', 'ÜNAL', 'ÜLKÜ', 'ÜZEYİR', 'ÜLKEM'],
      'sehir': ['ÜRGÜP', 'ÜMRANİYE'],
      'hayvan': ['ÜVEYİK', 'ÜVEZ'],
      'bitki': ['ÜZÜM', 'ÜZERLİKOTU'],
      'esya': ['ÜTÜ', 'ÜSTÜBÜ', 'ÜÇGEN CETVEL'],
      'ulke': ['ÜRDÜN', 'UKRAYNA']
    }
  };

  @override
  void initState() {
    super.initState();
    _secilenHarf = _turkceHarfler[(widget.mevcutTur * 7 + widget.oyuncuAdi.length) % _turkceHarfler.length];

    final r = Random();
    _rakip1 = _isimHavuzu[r.nextInt(5)];
    _rakip2 = _isimHavuzu[5 + r.nextInt(5)];

    for (var controller in _controllers.values) {
      controller.addListener(_onControllerChanged);
    }

    _sureyiBaslat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[_kategoriler[_aktifKategoriIndex]]?.requestFocus();
    });
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _sureyiBaslat() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_kalanSure > 0) {
        setState(() => _kalanSure--);
      } else {
        _turuTamamla(erkenBitirildiMi: _bitirBasildiMi);
      }
    });
  }

  bool _isFirstCharValid(String input, String secilenHarf) {
    String cleanInput = input.trim();
    if (cleanInput.isEmpty) return true;

    String ilkKarakter = cleanInput.substring(0, 1);

    String ilkKarakterTrBuyuk = _turkceBuyukHarfeCevir(ilkKarakter);
    String secilenHarfTrBuyuk = _turkceBuyukHarfeCevir(secilenHarf.trim());

    return ilkKarakterTrBuyuk == secilenHarfTrBuyuk;
  }

  bool _isRealWord(String input, String kategori) {
    String word = input.trim();
    if (word.length < 2) return false;

    String buyukWord = _turkceBuyukHarfeCevir(word);

    if (_kelimeVeritabani.containsKey(_secilenHarf)) {
      var katListesi = _kelimeVeritabani[_secilenHarf]![kategori];
      if (katListesi != null && katListesi.contains(buyukWord)) {
        return true;
      }
    }

    // ❌ Peş peşe 3 tane aynı harf yazılmasını denetleyen akıllı algoritmamız
    for (int i = 0; i < buyukWord.length - 2; i++) {
      if (buyukWord[i] == buyukWord[i+1] && buyukWord[i] == buyukWord[i+2]) {
        return false;
      }
    }

    bool sesliVarMi = buyukWord.contains(RegExp(r'[AEIİOÖUÜ]'));
    if (!sesliVarMi) return false;

    // ❌ Yan yana 4 tane sessiz harf gelmesini engelleyen dil kuralları
    int ardisikSessizSayisi = 0;
    String sessizler = "BCÇDFGĞHJKLMNPRSŞTVYZ";
    for (int i = 0; i < buyukWord.length; i++) {
      if (sessizler.contains(buyukWord[i])) {
        ardisikSessizSayisi++;
        if (ardisikSessizSayisi >= 4) {
          return false;
        }
      } else {
        ardisikSessizSayisi = 0;
      }
    }

    return true;
  }

  // 🧠 TÜRKÇE KARAKTER UYUMUNU %100 SAĞLAYAN MÜKEMMEL BÜYÜK HARF METODUNUZ!
  String _turkceBuyukHarfeCevir(String text) {
    const Map<String, String> degisimTablosu = {
      'i': 'İ',
      'ı': 'I',
      'ş': 'Ş',
      'ğ': 'Ğ',
      'ç': 'Ç',
      'ö': 'Ö',
      'ü': 'Ü',
    };

    return text
        .split('')
        .map(
          (harf) => degisimTablosu[harf] ?? harf.toUpperCase(),
    )
        .join();
  }

  bool _isGameReadyToFinish() {
    if (_bitirBasildiMi) return false;
    if (_kalanSure <= 20) return false;

    int doluKutuSayisi = 0;
    bool gecersizHarfVarMi = false;

    _controllers.forEach((kategori, controller) {
      String text = controller.text.trim();
      if (text.isNotEmpty) {
        doluKutuSayisi++;
        if (!_isFirstCharValid(text, _secilenHarf) || !_isRealWord(text, kategori)) {
          gecersizHarfVarMi = true;
        }
      }
    });

    int toplamKutuSayisi = _kategoriler.length;
    return (doluKutuSayisi >= (toplamKutuSayisi - 1)) && !gecersizHarfVarMi;
  }

  void _bitirButonunaBasildi() {
    if (_bitirBasildiMi || _kalanSure <= 20) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _bitirBasildiMi = true;
      _kalanSure = 20;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("⏱️ '$_secilenHarf' Harfi İçin Son 20 Saniyelik Geri Sayım Başladı!"),
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 3),
    ));
  }

  // 📦 Kelimeleri Süzgeçten Geçirip ResultPage'e Gönderdiğimiz Nokta
  Map<String, String> _cevaplariDenetleVeFiltrele() {
    Map<String, String> suzulenCevaplar = {};

    _controllers.forEach((kategori, controller) {
      String orijinalText = controller.text.trim();

      if (orijinalText.isEmpty) {
        suzulenCevaplar[kategori] = "";
        return;
      }

      // 🔴 Cezalandırma kuralımız: Eğer girilen kelimenin baş harfi seçilen harfle eşleşmiyorsa doğrudan elenir (0 Puan)
      if (!_isFirstCharValid(orijinalText, _secilenHarf)) {
        suzulenCevaplar[kategori] = "";
        return;
      }

      if (!_isRealWord(orijinalText, kategori)) {
        suzulenCevaplar[kategori] = "";
        return;
      }

      bool uygunsuzMu = false;
      for (var yasak in _karaListeKokler) {
        if (orijinalText.toUpperCase().contains(yasak)) {
          uygunsuzMu = true;
          break;
        }
      }

      if (uygunsuzMu) {
        suzulenCevaplar[kategori] = "UYGUNSUZ İÇERİK";
      } else {
        suzulenCevaplar[kategori] = orijinalText;
      }
    });

    return suzulenCevaplar;
  }

  void _turuTamamla({required bool erkenBitirildiMi}) {
    if (_turBittiMi) return;
    _turBittiMi = true;
    _timer?.cancel();

    Map<String, String> denetlenmisCevaplar = _cevaplariDenetleVeFiltrele();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          secilenHarf: _secilenHarf, oyuncuAdi: widget.oyuncuAdi, oyuncuKelimeleri: denetlenmisCevaplar,
          kalanSure: _kalanSure, erkenBitirildiMi: erkenBitirildiMi, mevcutTur: widget.mevcutTur,
          toplamTurSayisi: widget.toplamTurSayisi, oyuncuKumulatifSkor: widget.oyuncuKumulatifSkor,
          rakip1KumulatifSkor: widget.rakip1KumulatifSkor, rakip2KumulatifSkor: widget.rakip2KumulatifSkor,
          rakip1Adi: _rakip1, rakip2Adi: _rakip2, yuzIndex: widget.yuzIndex, aksesuarIndex: widget.aksesuarIndex, renkIndex: widget.renkIndex,
        ),
      ),
    );
  }

  IconData _getIcon(String k) {
    switch (k) {
      case 'isim': return Icons.person; case 'sehir': return Icons.location_city; case 'hayvan': return Icons.pets;
      case 'bitki': return Icons.eco; case 'esya': return Icons.chair; default: return Icons.flag;
    }
  }

  void _kategoriDegistir(int yeniIndex) {
    if (_bitirBasildiMi) return;

    if (yeniIndex >= 0 && yeniIndex < _kategoriler.length) {
      setState(() {
        _aktifKategoriIndex = yeniIndex;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        _focusNodes[_kategoriler[yeniIndex]]?.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifKat = _kategoriler[_aktifKategoriIndex];
    String aktifText = _controllers[aktifKat]!.text;

    // ⚠️ Hata durumunu belirleyen mantığımız (ilk harf yanlışsa veya uydurmaysa)
    bool aktifHataVarMi = aktifText.trim().isNotEmpty &&
        ((!_isFirstCharValid(aktifText, _secilenHarf)) ||
            (aktifText.trim().length >= 2 && !_isRealWord(aktifText, aktifKat)));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text("🔴 CANLI TURNUVA - TUR ${widget.mevcutTur}/${widget.toplamTurSayisi}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        centerTitle: true, backgroundColor: const Color(0xFF5E17EB), automaticallyImplyLeading: false,
        actions: [Container(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: Center(child: Text("⏱️ $_kalanSure sn", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity, margin: const EdgeInsets.fromLTRB(16, 12, 16, 8), padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF5E17EB)]), borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                const Text("YAZMAN GEREKEN BAŞ HARF", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(_secilenHarf, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ]),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_kategoriler.length, (index) {
                  String kat = _kategoriler[index];
                  String text = _controllers[kat]!.text.trim();
                  bool isSelected = _aktifKategoriIndex == index;

                  Color iconColor = Colors.grey.shade400;
                  if (isSelected) {
                    iconColor = const Color(0xFF5E17EB);
                  } else if (text.isNotEmpty) {
                    iconColor = (_isFirstCharValid(text, _secilenHarf) && _isRealWord(text, kat)) ? const Color(0xFF10B981) : Colors.redAccent;
                  }

                  return GestureDetector(
                    onTap: () => _kategoriDegistir(index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF5E17EB).withOpacity(0.12) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: const Color(0xFF5E17EB), width: 1.5) : null,
                      ),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Icon(_getIcon(kat), color: iconColor, size: 24),
                          if (text.isNotEmpty && !isSelected)
                            Positioned(
                              right: 0, top: 0,
                              child: Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: (_isFirstCharValid(text, _secilenHarf) && _isRealWord(text, kat)) ? const Color(0xFF10B981) : Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    key: ValueKey<int>(_aktifKategoriIndex),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: aktifHataVarMi ? Colors.redAccent : const Color(0xFF5E17EB).withOpacity(0.3),
                        width: aktifHataVarMi ? 2.0 : 1.5,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFF5E17EB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(_getIcon(aktifKat), color: const Color(0xFF5E17EB), size: 28),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              _kategoriBasliklari[aktifKat]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 🛠️ TÜRKÇE KLAVYE VE "YAZMA ENGELLERİ KALKAN" GÜVENLİ METİN ALANIMIZ!
                        // 🔐 İLK HARF KİLİTLİ YENİ METİN ALANI
                        TextField(
                          controller: _controllers[aktifKat],
                          focusNode: _focusNodes[aktifKat],
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          enableSuggestions: false,
                          readOnly: _bitirBasildiMi,
                          inputFormatters: [
                            // 🔑 Yanlış harfle başlamayı fiziksel olarak engelleyen filtre:
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              final girilenMetin = newValue.text.trimLeft();

                              if (girilenMetin.isEmpty) {
                                return newValue;
                              }

                              final ilkHarf = _turkceBuyukHarfeCevir(
                                girilenMetin.substring(0, 1),
                              );

                              final gerekliHarf = _turkceBuyukHarfeCevir(
                                _secilenHarf,
                              );

                              // Baş harf eşleşmiyorsa klavye girdiyi reddeder, eski hali kalır!
                              return ilkHarf == gerekliHarf ? newValue : oldValue;
                            }),
                          ],
                          onChanged: (_) {
                            setState(() {});
                          },
                          textInputAction: _aktifKategoriIndex == _kategoriler.length - 1
                              ? TextInputAction.done
                              : TextInputAction.next,
                          onSubmitted: (val) {
                            if (_aktifKategoriIndex < _kategoriler.length - 1) {
                              _kategoriDegistir(_aktifKategoriIndex + 1);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: _bitirBasildiMi ? 'Süre doluyor, yeni ekleme yapılamaz!' : 'Kelimenizi buraya yazın...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _bitirBasildiMi ? Colors.grey : const Color(0xFF5E17EB)
                          ),
                        ),
                        if (aktifHataVarMi)
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent, size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _isFirstCharValid(aktifText, _secilenHarf)
                                        ? "Lütfen geçerli ve anlamlı bir kelime girin!"
                                        : "Kelime '$_secilenHarf' harfi ile başlamalı!",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF5E17EB),
                            side: BorderSide(color: (_aktifKategoriIndex > 0 && !_bitirBasildiMi) ? const Color(0xFF5E17EB) : Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: (_aktifKategoriIndex > 0 && !_bitirBasildiMi) ? () => _kategoriDegistir(_aktifKategoriIndex - 1) : null,
                          child: const Text("⬅️ ÖNCEKİ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E17EB),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: (_aktifKategoriIndex < _kategoriler.length - 1 && !_bitirBasildiMi) ? () => _kategoriDegistir(_aktifKategoriIndex + 1) : null,
                          child: const Text("SONRAKİ ➡️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _bitirBasildiMi
                            ? const Color(0xFFF59E0B)
                            : (_isGameReadyToFinish() ? const Color(0xFF10B981) : Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: _isGameReadyToFinish() || _bitirBasildiMi ? 2 : 0,
                      ),
                      onPressed: _isGameReadyToFinish() ? _bitirButonunaBasildi : null,
                      child: _bitirBasildiMi
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              value: _kalanSure / 20,
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _kalanSure <= 5 ? Colors.redAccent : Colors.white,
                              ),
                              backgroundColor: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "SÜRE DOLUYOR... $_kalanSure sn",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: _kalanSure <= 5 ? Colors.redAccent : Colors.white,
                            ),
                          ),
                        ],
                      )
                          : Text(
                        _kalanSure <= 20
                            ? "SÜRE AZALDI, BİTİRİLEMEZ 🔒"
                            : "BÜTÜN KELİMELERİ YAZDIM, BİTİR 🏁",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}