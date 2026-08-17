// ==========================================
// BÖLÜM 1: Kütüphaneler, Sınıf Tanımlaması ve Dışarıdan Gelen Veriler
// ==========================================
import 'package:flutter/material.dart';
import 'ad_service.dart';

class ResultPage extends StatelessWidget {
  final String oyuncuAdi;
  final Map<String, int> tumMacSkorlari;
  final int eskiGenelPuan;
  final int yeniGenelPuan;
  final int eskiSiralama;
  final int yeniSiralama;

  const ResultPage({
    super.key,
    required this.oyuncuAdi,
    required this.tumMacSkorlari,
    required this.eskiGenelPuan,
    required this.yeniGenelPuan,
    required this.eskiSiralama,
    required this.yeniSiralama,
  });

// ---------------- BÖLÜM 1 SONU ----------------

// ==========================================
// BÖLÜM 2: Kazananı Belirleme ve Matematiksel Hesaplamalar
// ==========================================
  @override
  Widget build(BuildContext context) {
    // Gelen haritayı puanlara göre büyükten küçüğe sıralıyoruz
    List<MapEntry<String, int>> siraliSkorlar = tumMacSkorlari.entries.toList();
    siraliSkorlar.sort((a, b) => b.value.compareTo(a.value));

    // Sıralamadaki yerimizi buluyoruz
    int benimSiram =
        siraliSkorlar.indexWhere((element) => element.key == oyuncuAdi) + 1;
    int enYuksekSkor = siraliSkorlar.isNotEmpty ? siraliSkorlar.first.value : 0;

    // Kazanma durumu: Eğer 1. sıradaysak (veya 1. ile aynı puandaysak) kazandık demektir
    bool kazandi =
        (tumMacSkorlari[oyuncuAdi] == enYuksekSkor && enYuksekSkor > 0);
    bool berabere = kazandi &&
        siraliSkorlar.where((e) => e.value == enYuksekSkor).length > 1;

    int siralamaFarki = eskiSiralama - yeniSiralama;
// ---------------- BÖLÜM 2 SONU ----------------

// ==========================================
// BÖLÜM 3: Ana Sayfa İskeleti ve Durum İkonu (Kupa/Üzgün Yüz)
// ==========================================
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
                kazandi && !berabere
                    ? Icons.emoji_events
                    : (berabere
                        ? Icons.handshake
                        : Icons.sentiment_dissatisfied),
                size: 90,
                color: kazandi && !berabere
                    ? Colors.amber.shade700
                    : (berabere ? Colors.orange : Colors.red),
              ),
              const SizedBox(height: 15),
              Text(
                kazandi && !berabere
                    ? "MAÇIN GALİBİSİN! 🎉"
                    : (berabere ? "LİDERLİĞİ PAYLAŞTIN!" : "MAÇI KAYBETTİN!"),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kazandi && !berabere
                      ? Colors.green.shade700
                      : (berabere
                          ? Colors.orange.shade800
                          : Colors.red.shade700),
                ),
              ),
              const SizedBox(height: 25),
// ---------------- BÖLÜM 3 SONU ----------------

// ==========================================
// BÖLÜM 4: Maç Sıralaması (Kutu İçindeki Liste)
// ==========================================
              // ⚔️ DİNAMİK LİDERLİK TABLOSU KARTI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.shade100, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Text("MAÇ SIRALAMASI",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 13,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 15),

                    // Oyuncuları sırayla ekrana çizdiriyoruz
                    ...siraliSkorlar.asMap().entries.map((entry) {
                      int index = entry.key;
                      String isim = entry.value.key;
                      int skor = entry.value.value;
                      bool benMiyim = isim == oyuncuAdi;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              benMiyim ? Colors.purple.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: benMiyim
                                  ? Colors.purple.shade300
                                  : Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            // Sıra Numarası ve Madalya
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? Colors.amber
                                    : (index == 1
                                        ? Colors.grey.shade400
                                        : (index == 2
                                            ? Colors.brown.shade300
                                            : Colors.grey.shade200)),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                    color: index < 3
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Oyuncu Adı
                            Expanded(
                              child: Text(
                                benMiyim ? "$isim (Sen)" : isim,
                                style: TextStyle(
                                  fontWeight: benMiyim
                                      ? FontWeight.w900
                                      : FontWeight.bold,
                                  color: benMiyim
                                      ? Colors.purple.shade900
                                      : Colors.black87,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Skor
                            Text(
                              "$skor P",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: benMiyim
                                    ? Colors.purple.shade900
                                    : Colors.purple.shade400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 25),
// ---------------- BÖLÜM 4 SONU ----------------

// ==========================================
// BÖLÜM 5: Genel İstatistik (Puan ve Sıralama Gösterimi)
// ==========================================
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
                    const Text("GENEL İSTATİSTİK DURUMUN",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 13)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.stars, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Text("Genel Puanın:",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
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
                                  Text("$yeniGenelPuan P",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.blue)),
                                  const SizedBox(width: 6),
                                  Text(
                                    (yeniGenelPuan - eskiGenelPuan) >= 0
                                        ? "(+${yeniGenelPuan - eskiGenelPuan})"
                                        : "(${yeniGenelPuan - eskiGenelPuan})",
                                    style: TextStyle(
                                      color:
                                          (yeniGenelPuan - eskiGenelPuan) >= 0
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.leaderboard,
                                color: Colors.purple, size: 20),
                            SizedBox(width: 8),
                            Text("Sıralaman:",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
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
                                  Text("#$yeniSiralama",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(width: 6),
                                  if (siralamaFarki > 0)
                                    Text("(▲ $siralamaFarki Yükseldin)",
                                        style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12))
                                  else if (siralamaFarki < 0)
                                    Text("(▼ ${siralamaFarki.abs()} Geriledin)",
                                        style: TextStyle(
                                            color: Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12))
                                  else
                                    const Text("(- Değişmedi)",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
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
// ---------------- BÖLÜM 5 SONU ----------------

// ==========================================
// BÖLÜM 6: Ana Sayfaya Dön Butonu ve Reklam Alanı
// ==========================================
              // 🚀 ANA SAYFAYA DÖN BUTONU
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.home, size: 22),
                label: const Text("Ana Sayfaya Dön",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
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
// ---------------- BÖLÜM 6 SONU ----------------
