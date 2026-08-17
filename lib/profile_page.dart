import 'package:flutter/material.dart';
import 'dart:math';
import 'lobby_page.dart';
import 'game_mode_page.dart';
import 'ad_service.dart'; // 🎯 AdMob Reklam Servisimiz Eklendi

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> alinmisIsimler = [
    "ahmet",
    "mehmet",
    "ayşe",
    "temel",
    "dursun",
    "admin",
    "player1"
  ];

  final List<String> yasakliKelimeler = [
    "am",
    "amcık",
    "amcik",
    "götoş",
    "gotos",
    "ibne",
    "pç",
    "orospu",
    "orospucocugu",
    "pic",
    "sik",
    "sikerim",
    "sikis",
    "göt",
    "got",
    "götveren",
    "yavşak",
    "yavsak",
    "şerefsiz",
    "serefsiz",
    "piç",
    "mal",
    "salak",
    "gerizekali",
    "gerizekalı",
    "it",
    "kopek",
    "köpek",
    "orospuçocuğu",
    "amk",
    "aq",
    "sg",
    "oç",
    "oc",
    "meme",
    "daşşak",
    "dassak",
    "taşşak",
    "yarak",
    "yarrak",
    "kahpe",
    "gavat",
    "kavat",
    "pezevenk",
    "godoş",
    "godos",
    "ermeni",
    "kürt",
    "yunan",
    "yahudi",
    "zenci",
    "nigger",
    "lan",
    "salak",
    "aptal",
    "zoofili",
    "ensest",
    "yasakli"
  ];

  final TextEditingController _nameController = TextEditingController();

  final List<String> _yuzler = [
    "😀",
    "😎",
    "🤠",
    "🤖",
    "🦊",
    "🦁",
    "👽",
    "🦄",
    "🐼",
    "👻"
  ];
  final List<String> _aksesuarlar = [
    "👑",
    "🎩",
    "🎓",
    "🎸",
    "🕶️",
    "🚀",
    "💎",
    "🎈",
    "🎧",
    "🔥"
  ];
  final List<Color> _arkaPlanlar = [
    Colors.purple.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.pink.shade100,
    Colors.teal.shade100,
    Colors.amber.shade100,
    Colors.cyan.shade100,
    Colors.indigo.shade100,
    Colors.deepOrange.shade100,
  ];

  int _yuzIndex = 0;
  int _aksesuarIndex = 0;
  int _renkIndex = 0;

  @override
  void initState() {
    super.initState();
    _rastgeleKombinasyonUret();

    _nameController.addListener(() {
      String text = _nameController.text.trim();
      if (text.isNotEmpty) {
        int toplamDeger = 0;
        for (int i = 0; i < text.length; i++) {
          toplamDeger += text.codeUnitAt(i);
        }
        setState(() {
          _yuzIndex = toplamDeger % _yuzler.length;
          _aksesuarIndex = (toplamDeger + 3) % _aksesuarlar.length;
          _renkIndex = (toplamDeger + 7) % _arkaPlanlar.length;
        });
      }
    });
  }

  void _rastgeleKombinasyonUret() {
    final rastgele = Random();
    setState(() {
      _yuzIndex = rastgele.nextInt(_yuzler.length);
      _aksesuarIndex = rastgele.nextInt(_aksesuarlar.length);
      _renkIndex = rastgele.nextInt(_arkaPlanlar.length);
    });
  }

  void _profilKaydet() {
    String girilenIsim = _nameController.text.trim();
    String kucukHarfIsim = girilenIsim.toLowerCase();

    String temizIsim = kucukHarfIsim
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');

    if (girilenIsim.isEmpty || girilenIsim.length < 3) {
      _uyariMesajiGoster(
          "⚠️ Lütfen en az 3 karakterden oluşan geçerli bir takma ad giriniz!");
      return;
    }

    bool yasakliMi = false;
    for (var yasakli in yasakliKelimeler) {
      if (kucukHarfIsim.contains(yasakli) || temizIsim.contains(yasakli)) {
        yasakliMi = true;
        break;
      }
    }

    if (yasakliMi) {
      _uyariMesajiGoster(
          "⚠️ Lütfen topluluk kurallarına uygun, temiz bir takma ad seçiniz!");
      return;
    }

    if (alinmisIsimler.contains(kucukHarfIsim)) {
      _uyariMesajiGoster(
          "⚠️ Bu takma ad zaten alınmış! Farklı bir isim deneyiniz.");
      return;
    }

    // Seçilen tüm profil bilgilerini yanımıza alıp lobiye geçiyoruz
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LobbyPage(
          oyuncuAdi: girilenIsim,
          yuzIndex: _yuzIndex,
          aksesuarIndex: _aksesuarIndex,
          renkIndex: _renkIndex,
        ),
      ),
    );
  }

  void _uyariMesajiGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        backgroundColor: Colors.amber[900],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F7),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    spreadRadius: 5)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("İsim Şehir Hayvan Oyunu",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E17EB)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text("Başlamak için bir takma ad girin",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                          color: _arkaPlanlar[_renkIndex],
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF5E17EB), width: 3)),
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(_yuzler[_yuzIndex],
                              style: const TextStyle(fontSize: 55)),
                          Positioned(
                              top: 5,
                              right: 5,
                              child: Text(_aksesuarlar[_aksesuarIndex],
                                  style: const TextStyle(fontSize: 26))),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _rastgeleKombinasyonUret,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color(0xFF5E17EB), shape: BoxShape.circle),
                        child: const Icon(Icons.casino,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  maxLength: 15,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline,
                        color: Color(0xFF5E17EB)),
                    hintText: "Takma Adınız (Nickname)",
                    counterText: "",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                            color: Color(0xFF5E17EB), width: 2)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _profilKaydet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E17EB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text("Devam Et",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 🎯 SAYFA ALTINA SABİT BANNER REKLAM (Takma ad yazılırken klavye açılınca otomatik gizlenir)
      bottomNavigationBar: const SafeArea(
        child: BottomBannerAdWidget(),
      ),
    );
  }
}
