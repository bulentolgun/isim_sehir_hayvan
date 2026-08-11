import 'package:flutter/material.dart';
import 'ad_service.dart';

class ResultPage extends StatelessWidget {
  final String oyuncuAdi;
  final String rakipAdi;
  final int oyuncuMacSkor;
  final int rakipMacSkor;
  final int eskiGenelPuan;
  final int yeniGenelPuan;
  final int eskiSiralama;
  final int yeniSiralama;

  const ResultPage({
    super.key,
    required this.oyuncuAdi,
    required this.rakipAdi,
    required this.oyuncuMacSkor,
    required this.rakipMacSkor,
    required this.eskiGenelPuan,
    required this.yeniGenelPuan,
    required this.eskiSiralama,
    required this.yeniSiralama,
  });

  @override
  Widget build(BuildContext context) {
    bool kazandi = oyuncuMacSkor > rakipMacSkor;
    bool berabere = oyuncuMacSkor == rakipMacSkor;
    int siralamaFarki = eskiSiralama - yeniSiralama; // Pozitifse yükselmiştir

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 🏆 DURUM İKONU VE BAŞLIK
              Icon(
                kazandi ? Icons.emoji_events : (berabere ? Icons.handshake : Icons.sentiment_dissatisfied),
                size: 90,
                color: kazandi ? Colors.amber.shade700 : (berabere ? Colors.orange : Colors.red),
              ),
              const SizedBox(height: 15),
              Text(
                kazandi ? "MAÇIN GALİBİSİN! 🎉" : (berabere ? "MAÇ BERABERE BİTTİ!" : "MAÇI RAKİP KAZANDI"),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kazandi ? Colors.green.shade700 : (berabere ? Colors.orange.shade800 : Colors.red.shade700),
                ),
              ),
              const SizedBox(height: 25),

              // ⚔️ MAÇ SKOR KARTI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.shade100, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(oyuncuAdi, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text("$oyuncuMacSkor P", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)),
                      ],
                    ),
                    const Text("VS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.purple)),
                    Column(
                      children: [
                        Text(rakipAdi, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text("$rakipMacSkor P", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 📊 GENEL PUAN VE SIRALAMA KARTI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Text("GENEL İSTATİSTİK DURUMUN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 13)),
                    const SizedBox(height: 15),

                    // PUAN DEĞİŞİMİ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.stars, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Text("Genel Puanın:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Row(
                                children: [
                                  Text("$yeniGenelPuan P", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue)),
                                  const SizedBox(width: 6),
                                  Text(
                                    (yeniGenelPuan - eskiGenelPuan) >= 0
                                        ? "(+${yeniGenelPuan - eskiGenelPuan} Puan)"
                                        : "(${yeniGenelPuan - eskiGenelPuan} Puan)",
                                    style: TextStyle(
                                      color: (yeniGenelPuan - eskiGenelPuan) >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // SIRALAMA DEĞİŞİMİ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.leaderboard, color: Colors.purple, size: 20),
                            SizedBox(width: 8),
                            Text("Sıralaman:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Row(
                                children: [
                                  Text("#$yeniSiralama", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(width: 6),
                                  if (siralamaFarki > 0)
                                    Text("(▲ $siralamaFarki Yükseldin)", style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12))
                                  else if (siralamaFarki < 0)
                                    Text("(▼ ${siralamaFarki.abs()} Geriledin)", style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12))
                                  else
                                    const Text("(- Değişmedi)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // 🚀 ANA SAYFAYA DÖN BUTONU
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.home, size: 22),
                label: const Text("Ana Sayfaya Dön", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),

      // 🎯 SAYFA ALTINA SABİT BANNER REKLAM
      bottomNavigationBar: const SafeArea(
        child: BottomBannerAdWidget(),
      ),
    );
  }
}