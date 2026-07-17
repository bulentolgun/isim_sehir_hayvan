import 'package:flutter/material.dart';
import 'dart:math';

class ResultPage extends StatefulWidget {
  final String secilenHarf;
  final String oyuncuAdi;
  final Map<String, String> oyuncuKelimeleri;
  final int kalanSure;
  final bool erkenBitirildiMi;
  final int mevcutTur;
  final int toplamTurSayisi;
  final int oyuncuKumulatifSkor;
  final int rakip1KumulatifSkor;
  final int rakip2KumulatifSkor;
  final String rakip1Adi;
  final String rakip2Adi;
  final int yuzIndex;
  final int aksesuarIndex;
  final int renkIndex;

  const ResultPage({
    super.key,
    required this.secilenHarf,
    required this.oyuncuAdi,
    required this.oyuncuKelimeleri,
    required this.kalanSure,
    required this.erkenBitirildiMi,
    required this.mevcutTur,
    required this.toplamTurSayisi,
    required this.oyuncuKumulatifSkor,
    required this.rakip1KumulatifSkor,
    required this.rakip2KumulatifSkor,
    required this.rakip1Adi,
    required this.rakip2Adi,
    required this.yuzIndex,
    required this.aksesuarIndex,
    required this.renkIndex,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final List<String> _kategoriler = ['isim', 'sehir', 'hayvan', 'bitki', 'esya', 'ulke'];

  final Map<String, Map<String, List<String>>> _rakipCevaplariHavuzu = {
    'K': {
      'isim': ['KEMAL', 'KAAN', 'KADİR', 'KÜRŞAT', 'KADRİYE'],
      'sehir': ['KARS', 'KONYA', 'KAYSERİ', 'KASTAMONU', 'KIRKLARELİ'],
      'hayvan': ['KEDİ', 'KÖPEK', 'KANGURU', 'KAPLUMBAĞA', 'KÖPEKBALIĞI'],
      'bitki': ['KAVUN', 'KAYISI', 'KARNABAHAR', 'KIZILCIK', 'KARANFİL'],
      'esya': ['KAPI', 'KASE', 'KLAVYE', 'KUMANDA', 'KAVANOZ'],
      'ulke': ['KENYA', 'KANADA', 'KOLOMBİYA', 'KAZAKİSTAN', 'KUZEY MAKEDONYA']
    }
  };

  late Map<String, String> _rakip1Kelimeleri;
  late Map<String, String> _rakip2Kelimeleri;

  final Map<String, int> _oyuncuPuanlari = {};
  final Map<String, int> _rakip1Puanlari = {};
  final Map<String, int> _rakip2Puanlari = {};

  final Map<String, bool> _oyuncuUzunlukBonusu = {};
  final Map<String, bool> _rakip1UzunlukBonusu = {};
  final Map<String, bool> _rakip2UzunlukBonusu = {};

  int _oyuncuTurSkor = 0;
  int _rakip1TurSkor = 0;
  int _rakip2TurSkor = 0;

  @override
  void initState() {
    super.initState();
    _rakipCevaplariniUret();
    _puanlariHesapla();
  }

  String _turkceBuyukHarfeCevir(String text) {
    Map<String, String> degisimTablosu = {
      'i': 'İ', 'ı': 'I', 'ş': 'Ş', 'ğ': 'Ğ', 'ç': 'Ç', 'ö': 'Ö', 'ü': 'Ü'
    };

    String sonuc = "";
    for (int i = 0; i < text.length; i++) {
      String harf = text[i];
      if (degisimTablosu.containsKey(harf)) {
        sonuc += degisimTablosu[harf]!;
      } else {
        sonuc += harf.toUpperCase();
      }
    }
    return sonuc;
  }

  void _rakipCevaplariniUret() {
    _rakip1Kelimeleri = {};
    _rakip2Kelimeleri = {};

    String arananHarf = _turkceBuyukHarfeCevir(widget.secilenHarf);
    final r = _rakipCevaplariHavuzu[arananHarf] ?? {};

    for (var kat in _kategoriler) {
      var liste = r[kat] ?? [];

      if (liste.isNotEmpty) {
        _rakip1Kelimeleri[kat] = (randomPercent(85)) ? liste[randomInt(liste.length)] : "";
        _rakip2Kelimeleri[kat] = (randomPercent(85)) ? liste[randomInt(liste.length)] : "";
      } else {
        _rakip1Kelimeleri[kat] = "";
        _rakip2Kelimeleri[kat] = "";
      }
    }
  }

  bool randomPercent(int percent) {
    final random = Random();
    return random.nextInt(100) < percent;
  }

  int randomInt(int max) {
    if (max <= 1) return 0;
    final random = Random();
    return random.nextInt(max);
  }

  void _puanlariHesapla() {
    int oTurPuan = 0;
    int r1TurPuan = 0;
    int r2TurPuan = 0;

    for (var kat in _kategoriler) {
      String rawOWord = (widget.oyuncuKelimeleri[kat] ?? "").trim();
      String rawR1Word = (_rakip1Kelimeleri[kat] ?? "").trim();
      String rawR2Word = (_rakip2Kelimeleri[kat] ?? "").trim();

      String oWord = (rawOWord == "UYGUNSUZ İÇERİK") ? "" : _turkceBuyukHarfeCevir(rawOWord);
      String r1Word = _turkceBuyukHarfeCevir(rawR1Word);
      String r2Word = _turkceBuyukHarfeCevir(rawR2Word);

      int oP = 0;
      int r1P = 0;
      int r2P = 0;

      if (oWord.isNotEmpty) {
        bool r1Elesir = r1Word.isNotEmpty && (oWord == r1Word);
        bool r2Elesir = r2Word.isNotEmpty && (oWord == r2Word);
        if (r1Elesir || r2Elesir) {
          oP = 5;
        } else {
          oP = 10;
        }
      }

      if (r1Word.isNotEmpty) {
        bool oElesir = oWord.isNotEmpty && (r1Word == oWord);
        bool r2Elesir = r2Word.isNotEmpty && (r1Word == r2Word);
        if (oElesir || r2Elesir) {
          r1P = 5;
        } else {
          r1P = 10;
        }
      }

      if (r2Word.isNotEmpty) {
        bool oElesir = oWord.isNotEmpty && (r2Word == oWord);
        bool r1Elesir = r1Word.isNotEmpty && (r2Word == r1Word);
        if (oElesir || r1Elesir) {
          r2P = 5;
        } else {
          r2P = 10;
        }
      }

      int oLen = oWord.isNotEmpty ? oWord.length : 0;
      int r1Len = r1Word.isNotEmpty ? r1Word.length : 0;
      int r2Len = r2Word.isNotEmpty ? r2Word.length : 0;

      int maxLen = 0;
      if (oLen > maxLen) maxLen = oLen;
      if (r1Len > maxLen) maxLen = r1Len;
      if (r2Len > maxLen) maxLen = r2Len;

      _oyuncuUzunlukBonusu[kat] = false;
      _rakip1UzunlukBonusu[kat] = false;
      _rakip2UzunlukBonusu[kat] = false;

      if (maxLen >= 2) {
        if (oLen == maxLen) {
          oP += 2;
          _oyuncuUzunlukBonusu[kat] = true;
        }
        if (r1Len == maxLen) {
          r1P += 2;
          _rakip1UzunlukBonusu[kat] = true;
        }
        if (r2Len == maxLen) {
          r2P += 2;
          _rakip2UzunlukBonusu[kat] = true;
        }
      }

      _oyuncuPuanlari[kat] = oP;
      _rakip1Puanlari[kat] = r1P;
      _rakip2Puanlari[kat] = r2P;

      oTurPuan += oP;
      r1TurPuan += r1P;
      r2TurPuan += r2P;
    }

    if (widget.erkenBitirildiMi && widget.kalanSure > 20) {
      oTurPuan += 10;
    }

    _oyuncuTurSkor = oTurPuan;
    _rakip1TurSkor = r1TurPuan;
    _rakip2TurSkor = r2TurPuan;
  }

  @override
  Widget build(BuildContext context) {
    int oToplam = widget.oyuncuKumulatifSkor + _oyuncuTurSkor;
    int r1Toplam = widget.rakip1KumulatifSkor + _rakip1TurSkor;
    int r2Toplam = widget.rakip2KumulatifSkor + _rakip2TurSkor;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("🏆 TUR SONUÇLARI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF5E17EB),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF5E17EB), Color(0xFF6366F1)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _skorSutunu(widget.oyuncuAdi, _oyuncuTurSkor, oToplam, isPlayer: true),
                  _skorSutunu(widget.rakip1Adi, _rakip1TurSkor, r1Toplam),
                  _skorSutunu(widget.rakip2Adi, _rakip2TurSkor, r2Toplam),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _kategoriler.length,
                itemBuilder: (context, index) {
                  String kat = _kategoriler[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(kat.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5E17EB))),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _kelimeDetayRow(widget.oyuncuAdi, widget.oyuncuKelimeleri[kat] ?? "", _oyuncuPuanlari[kat] ?? 0, _oyuncuUzunlukBonusu[kat] ?? false),
                              _kelimeDetayRow(widget.rakip1Adi, _rakip1Kelimeleri[kat] ?? "", _rakip1Puanlari[kat] ?? 0, _rakip1UzunlukBonusu[kat] ?? false),
                              _kelimeDetayRow(widget.rakip2Adi, _rakip2Kelimeleri[kat] ?? "", _rakip2Puanlari[kat] ?? 0, _rakip2UzunlukBonusu[kat] ?? false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(widget.mevcutTur < widget.toplamTurSayisi ? "SONRAKİ TURA GEÇ ➡️" : "OYUNU BİTİR 🏆", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _skorSutunu(String isim, int turSkor, int toplamSkor, {bool isPlayer = false}) {
    return Column(
      children: [
        Text(isim, style: TextStyle(color: isPlayer ? Colors.yellow : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Text("+$turSkor", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text("Toplam: $toplamSkor", style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _kelimeDetayRow(String isim, String kelime, int puan, bool uzunlukBonusu) {
    String displayKelime = kelime.isEmpty ? "-" : kelime;
    return Expanded(
      child: Column(
        children: [
          Text(isim, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  displayKelime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: kelime.isEmpty ? Colors.grey : (kelime == "UYGUNSUZ İÇERİK" ? Colors.red : Colors.black87),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (uzunlukBonusu)
                const Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Icon(Icons.workspace_premium, color: Colors.amber, size: 14),
                ),
            ],
          ),
          Text("$puan Puan", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: puan > 5 ? const Color(0xFF10B981) : Colors.orange)),
          if (uzunlukBonusu)
            const Text("+2 En Uzun 👑", style: TextStyle(fontSize: 8, color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}