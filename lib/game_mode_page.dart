import 'package:flutter/material.dart';
import 'lobby_page.dart';
import 'ad_service.dart'; // 🎯 Reklam Servisimiz (Artık Aktif!)
import 'auth_service.dart';
import 'nickname_dialog.dart';

class GameModePage extends StatelessWidget {
  final String oyuncuAdi;
  final int yuzIndex;
  final int aksesuarIndex;
  final int renkIndex;

  const GameModePage({
    Key? key,
    required this.oyuncuAdi,
    required this.yuzIndex,
    required this.aksesuarIndex,
    required this.renkIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String mevcutOyuncu = oyuncuAdi.isEmpty ? "Tokatlı60" : oyuncuAdi;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Icon(
                Icons.sports_esports_rounded,
                size: 90,
                color: Colors.purple,
              ),
              const SizedBox(height: 20),

              const Text(
                "OYUN MODU SEÇİN",
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Hoş geldin $mevcutOyuncu!\nNasıl oynamak istersin?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Icons.groups_rounded, size: 28),
                label: const Text(
                  "Arkadaşlarınla Oyna (2-4 Kişi)",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LobbyPage(
                        oyuncuAdi: mevcutOyuncu,
                        yuzIndex: yuzIndex,
                        aksesuarIndex: aksesuarIndex,
                        renkIndex: renkIndex,
                        isFriendMode: true,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.purple, width: 2),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.flash_on_rounded, color: Colors.purple, size: 28),
                label: const Text(
                  "Rakip Bul (Hızlı Kapışma)",
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LobbyPage(
                        oyuncuAdi: mevcutOyuncu,
                        yuzIndex: yuzIndex,
                        aksesuarIndex: aksesuarIndex,
                        renkIndex: renkIndex,
                        isFriendMode: false,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400, width: 1.2),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: Icon(Icons.arrow_back, color: Colors.grey.shade700, size: 20),
                label: Text(
                  "Giriş Sayfasına Dön",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 🎯 SAYFA ALTINA SABİT BANNER REKLAMI EKLENDİ
      bottomNavigationBar: const SafeArea(
        child: BottomBannerAdWidget(),
      ),
    );
  }
}