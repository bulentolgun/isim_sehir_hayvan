import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'lobby_page.dart';
import 'ad_service.dart';

class GameModePage extends StatelessWidget {
  final String oyuncuAdi;
  final int yuzIndex;
  final int aksesuarIndex;
  final int renkIndex;

  const GameModePage({
    super.key,
    required this.oyuncuAdi,
    required this.yuzIndex,
    required this.aksesuarIndex,
    required this.renkIndex,
  });

// ---------------- BÖLÜM 1 SONU ----------------

// ==========================================
// BÖLÜM 2: Ana Sayfa İskeleti, Başlık ve Karşılama Alanı
// ==========================================
  @override
  Widget build(BuildContext context) {
    // Eğer oyuncu adı boşsa, dil dosyasındaki varsayılan ismi çeker
    final String mevcutOyuncu = oyuncuAdi.isEmpty ? AppLocalizations.of(context)!.defaultPlayerName : oyuncuAdi;

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

              Text(
                AppLocalizations.of(context)!.chooseGameMode, // 🚀 ÇEVİRİ EKLENDİ
                style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${AppLocalizations.of(context)!.welcomePlayer} $mevcutOyuncu!\n${AppLocalizations.of(context)!.howToPlay}", // 🚀 ÇEVİRİ EKLENDİ
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),
// ---------------- BÖLÜM 2 SONU ----------------

// ==========================================
// BÖLÜM 3: Oyun Modu Seçim Butonları (Arkadaş Odası & Hızlı Eşleşme)
// ==========================================
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
                label: Text(
                  AppLocalizations.of(context)!.playWithFriends, // 🚀 ÇEVİRİ EKLENDİ
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                icon: const Icon(Icons.flash_on_rounded,
                    color: Colors.purple, size: 28),
                label: Text(
                  AppLocalizations.of(context)!.findOpponent, // 🚀 ÇEVİRİ EKLENDİ
                  style: const TextStyle(
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
// ---------------- BÖLÜM 3 SONU ----------------

// ==========================================
// BÖLÜM 4: Geri Dön Butonu ve Alt Banner Reklam
// ==========================================
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400, width: 1.2),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                icon: Icon(Icons.arrow_back,
                    color: Colors.grey.shade700, size: 20),
                label: Text(
                  AppLocalizations.of(context)!.returnToLogin, // 🚀 ÇEVİRİ EKLENDİ
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
      bottomNavigationBar: const SafeArea(
        child: BottomBannerAdWidget(),
      ),
    );
  }
}
// ---------------- BÖLÜM 4 SONU ----------------