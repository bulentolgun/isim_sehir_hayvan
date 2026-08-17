import 'package:flutter/material.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Hafif mor arka plan
      appBar: AppBar(
        title: const Text(
          "📜 Oyun Kuralları",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRuleCard(
              icon: Icons.abc_rounded,
              iconColor: Colors.orange,
              title: "1. Harf Kuralı",
              description:
                  "Her turun başında rastgele bir harf seçilir. Yazacağınız tüm kelimeler bu harf ile başlamalıdır.",
            ),
            _buildRuleCard(
              icon: Icons.score_rounded,
              iconColor: Colors.blue,
              title: "2. Kategori Puanlaması",
              description: "• İki oyuncu aynı doğru kelimeyi yazarsa: 5 Puan\n"
                  "• İki oyuncu farklı doğru kelimeler yazarsa: 10 Puan\n"
                  "• Sadece tek oyuncu doğru kelime yazarsa: 20 Puan\n"
                  "• Doğru bilinen en uzun kelimeye: +2 Puan Bonus"
                  "• Maçı kazanan oyuncu +100 Puan alır.",
            ),
            _buildRuleCard(
              icon: Icons.timer_rounded,
              iconColor: Colors.redAccent,
              title: "3. Turu Erken Bitirme & 20 Sn Kuralı",
              description:
                  "En az 5 kategoriyi doldurduğunuzda 'TURU BİTİR' butonuna basabilirsiniz. "
                  "Sayaç anında 20 saniyeye düşer ve tur sonunda +10 Zaman Bonusu kazanırsınız.",
            ),
            _buildRuleCard(
              icon: Icons.emoji_events_rounded,
              iconColor: Colors.amber,
              title: "4. 🏆 Maç Sonu Galibiyet Bonusu",
              description:
                  "• Maç bittiğinde, maçı kim kazandıysa genel puanına ve liderlik tablosuna kaydedilmek üzere +100 Galibiyet Bonusu eklenir.\n"
                  "• Beraberlik durumunda kimseye ekstra +100 eklenmez, sadece maçta toplanan ham puanlar genel skora yansır.",
            ),
            _buildRuleCard(
              icon: Icons.verified_rounded,
              iconColor: Colors.green,
              title: "5. Geçerli Kelimeler",
              description:
                  "Eşya, Hayvan, Bitki ve Ülke kategorilerinde sadece gerçek ve somut kelimeler kabul edilir. "
                  "TDK'deki soyut veya kural dışı kelimeler puan almaz.",
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  "ANLADIM, OYUNA DÖN 👍",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎯 İsterseniz Açılır Pencere (Dialog) Olarak Çağırmak İçin Yardımcı Metot
void showRulesDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: RulesPage(),
      ),
    ),
  );
}
