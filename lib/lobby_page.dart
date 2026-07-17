import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isim_sehir_hayvan/game_page.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final TextEditingController _isimController = TextEditingController();
  int _secilenYuz = 0;
  int _secilenAksesuar = 0;
  int _secilenRenk = 0;
  bool _profilKilitliMi = false;
  bool _turSecimEkranindaMi = false;

  final List<String> _yuzler = ["😊", "😎", "🐱", "🦁", "🤖", "🦊", "🐼", "🦄"];
  final List<String> _aksesuarlar = ["👑", "🕶️", "🎧", "🎩", "🎯", "🎓", "🚀", "❌"];
  final List<Color> _renkler = [
    const Color(0xFFF6366F), const Color(0xFF10B981), const Color(0xFFF59E0B),
    const Color(0xFFFEF444), const Color(0xFFFEC489), const Color(0xFF06B6D4),
  ];

  @override
  void initState() {
    super.initState();
    _hafizadakiProfiliYukle();
  }

  Future<void> _hafizadakiProfiliYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? kayitliIsim = prefs.getString('kayitli_oyuncu_adi');
      if (kayitliIsim != null && kayitliIsim.isNotEmpty) {
        _isimController.text = kayitliIsim;
        _secilenYuz = prefs.getInt('kayitli_yuz') ?? 0;
        _secilenAksesuar = prefs.getInt('kayitli_aksesuar') ?? 0;
        _secilenRenk = prefs.getInt('kayitli_renk') ?? 0;
        _profilKilitliMi = true;
      }
    });
  }

  Future<void> _profiliKaydet() async {
    if (_isimController.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kayitli_oyuncu_adi', _isimController.text.trim());
    await prefs.setInt('kayitli_yuz', _secilenYuz);
    await prefs.setInt('kayitli_aksesuar', _secilenAksesuar);
    await prefs.setInt('kayitli_renk', _secilenRenk);
    setState(() {
      _profilKilitliMi = true;
    });
  }

  void _oyunuBaslat(int toplamTur) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          oyuncuAdi: _isimController.text.trim(),
          yuzIndex: _secilenYuz,
          aksesuarIndex: _secilenAksesuar,
          renkIndex: _secilenRenk,
          mevcutTur: 1,
          toplamTurSayisi: toplamTur,
          oyuncuKumulatifSkor: 0,
          rakip1KumulatifSkor: 0,
          rakip2KumulatifSkor: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _turSecimEkranindaMi ? _buildTurSecimArayuzu() : _buildProfilArayuzu(),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilArayuzu() {
    return Column(
      children: [
        const Text("🎨 PROFiLiNi OLUSTUR", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5E17EB))),
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 60,
          backgroundColor: _renkler[_secilenRenk],
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(_yuzler[_secilenYuz], style: const TextStyle(fontSize: 50)),
              if (_aksesuarlar[_secilenAksesuar] != "❌")
                Positioned(
                  top: 10,
                  child: Text(_aksesuarlar[_secilenAksesuar], style: const TextStyle(fontSize: 32)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _isimController,
          enabled: !_profilKilitliMi,
          decoration: InputDecoration(
            hintText: "Oyuncu Adınız...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        if (!_profilKilitliMi) ...[
          _secimSatiri("Yüz Seçimi", _yuzler, _secilenYuz, (val) => setState(() => _secilenYuz = val)),
          _secimSatiri("Aksesuar", _aksesuarlar, _secilenAksesuar, (val) => setState(() => _secilenAksesuar = val)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_renkler.length, (index) {
              return GestureDetector(
                onTap: () => setState(() => _secilenRenk = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _renkler[index],
                    shape: BoxShape.circle,
                    border: _secilenRenk == index ? Border.all(color: Colors.black, width: 2) : null,
                  ),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: 30),

        // ANA BUTON (Kayıtlıysa Doğrudan Tur Seçimine Atlar, Değilse Kaydeder)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E17EB),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (_isimController.text.trim().isEmpty) return;
              if (!_profilKilitliMi) {
                _profiliKaydet();
              } else {
                setState(() {
                  _turSecimEkranindaMi = true;
                });
              }
            },
            child: Text(
              _profilKilitliMi ? "OYUNA BAŞLA 🚀" : "PROFiLi KAYDET 💾",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),

        // ✏️ YENİ DÜĞME: Eğer profil kilitliyse kilidi açıp düzenlemeye izin veren buton
        if (_profilKilitliMi) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            icon: const Icon(Icons.edit, size: 16, color: Color(0xFF5E17EB)),
            label: const Text(
              "Farklı İsimle Gir / Profili Düzenle ✏️",
              style: TextStyle(color: Color(0xFF5E17EB), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () {
              setState(() {
                _profilKilitliMi = false; // Kilidi kaldır, düzenlemeyi aktif et!
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTurSecimArayuzu() {
    return Column(
      children: [
        const Text("⏱️ TURNUVA TUR SAYISI", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5E17EB))),
        const SizedBox(height: 8),
        const Text("Kaç tur yarışmak istersiniz?", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 30),
        _turButonu("1 TUR (Hızlı Kapışma)", 1),
        _turButonu("3 TUR (Standart Lig)", 3),
        _turButonu("5 TUR (Maraton Devleri)", 5),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => setState(() => _turSecimEkranindaMi = false),
          child: const Text("⬅️ Geri Dön", style: TextStyle(color: Color(0xFF5E17EB), fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _turButonu(String baslik, int tur) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF5E17EB),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
        ),
        onPressed: () => _oyunuBaslat(tur),
        child: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _secimSatiri(String baslik, List<String> liste, int seciliIndex, Function(int) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(onPressed: seciliIndex > 0 ? () => onChange(seciliIndex - 1) : null, icon: const Icon(Icons.arrow_left)),
              Text(liste[seciliIndex], style: const TextStyle(fontSize: 20)),
              IconButton(onPressed: seciliIndex < liste.length - 1 ? () => onChange(seciliIndex + 1) : null, icon: const Icon(Icons.arrow_right)),
            ],
          )
        ],
      ),
    );
  }
}