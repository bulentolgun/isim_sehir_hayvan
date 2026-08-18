// ==========================================
// BÖLÜM 1: İçe Aktarmalar ve Sınıf Tanımları
// ==========================================
import 'package:flutter/material.dart';
import 'lobby_page.dart'; // 🔴 Nokta atışı: Kendi lobi dosyan eklendi!

class FinalPodiumPage extends StatefulWidget {
  final String oyuncuAdi;
  final String rakip1Adi;
  final String rakip2Adi;
  final int oyuncuSkor;
  final int rakip1Skor;
  final int rakip2Skor;

  const FinalPodiumPage({
    super.key,
    required this.oyuncuAdi,
    required this.rakip1Adi,
    required this.rakip2Adi,
    required this.oyuncuSkor,
    required this.rakip1Skor,
    required this.rakip2Skor,
  });

  @override
  State<FinalPodiumPage> createState() => _FinalPodiumPageState();
}

class _FinalPodiumPageState extends State<FinalPodiumPage> {
// ---------------- BÖLÜM 1 SONU ----------------


// ==========================================
// BÖLÜM 2: Değişkenler, Sıralama Mantığı ve Animasyonlar
// ==========================================
  List<Map<String, dynamic>> _siralamalar = [];
  bool _ucuncuGoster = false;
  bool _ikinciGoster = false;
  bool _birinciGoster = false;
  bool _konfetiGoster = false;

  @override
  void initState() {
    super.initState();
    // Gelen puanları listeye alıp büyükten küçüğe sıralıyoruz
    _siralamalar = [
      {'ad': widget.oyuncuAdi, 'puan': widget.oyuncuSkor, 'benMi': true},
      {'ad': widget.rakip1Adi, 'puan': widget.rakip1Skor, 'benMi': false},
      {'ad': widget.rakip2Adi, 'puan': widget.rakip2Skor, 'benMi': false},
    ];
    _siralamalar.sort((a, b) => b['puan'].compareTo(a['puan']));

    _animasyonlariBaslat();
  }

  void _animasyonlariBaslat() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _ucuncuGoster = true);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _ikinciGoster = true);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted)
      setState(() {
        _birinciGoster = true;
        _konfetiGoster = true;
      });
  }

  void _anaMenuyeDon() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LobbyPage(
            oyuncuAdi: widget.oyuncuAdi,
            aksesuarIndex: 0,
            renkIndex: 0,
            yuzIndex: 0,
          )),
          (route) => false,
    );
  }
// ---------------- BÖLÜM 2 SONU ----------------


// ==========================================
// BÖLÜM 3: Kürsü (Podium) Görsel Tasarım Aracı
// ==========================================
  Widget _kursuSutunu(Map<String, dynamic> kisi, int sira, double yukseklik,
      Color renk, bool goster) {
    return AnimatedOpacity(
      opacity: goster ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, goster ? 0 : 60, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (goster && sira == 1)
              const Text("👑", style: TextStyle(fontSize: 45)),
            Text(
              kisi['ad'] + (kisi['benMi'] ? "\n(Sen)" : ""),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                  kisi['benMi'] ? const Color(0xFF5E17EB) : Colors.black87,
                  fontSize: sira == 1 ? 16 : 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text("${kisi['puan']} Puan",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: yukseklik,
              decoration: BoxDecoration(
                color: renk,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ],
              ),
              child: Center(
                child: Text("$sira",
                    style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2))
                        ])),
              ),
            ),
          ],
        ),
      ),
    );
  }
// ---------------- BÖLÜM 3 SONU ----------------


// ==========================================
// BÖLÜM 4: Ana Arayüz (Build) ve Butonlar
// ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Text("🏆 TURNUVA BİTTİ 🏆",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E17EB))),
                const SizedBox(height: 10),
                const Text("İşte Şampiyonlar!",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: _kursuSutunu(_siralamalar[1], 2, 170,
                                Colors.blueGrey.shade400, _ikinciGoster)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _kursuSutunu(_siralamalar[0], 1, 240,
                                const Color(0xFFFFC107), _birinciGoster)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _kursuSutunu(_siralamalar[2], 3, 130,
                                const Color(0xFFCD7F32), _ucuncuGoster)),
                      ],
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _birinciGoster ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E17EB),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: _birinciGoster ? _anaMenuyeDon : null,
                      child: const Text("ANA MENÜYE DÖN ↩️",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_konfetiGoster)
            IgnorePointer(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 120.0),
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, val, child) {
                      return Transform.scale(
                        scale: val,
                        child: const Text("🎊 🎉 🏆 🎉 🎊",
                            style: TextStyle(fontSize: 45)),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
// ---------------- BÖLÜM 4 SONU ----------------