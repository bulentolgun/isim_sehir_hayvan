import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart'; // 🚀 Doğru Çeviri Yolu

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Hafif mor arka plan
      appBar: AppBar(
        title: Text(
          l10n.rulesPageTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
              title: l10n.rule1Title,
              description: l10n.rule1Desc,
            ),
            _buildRuleCard(
              icon: Icons.score_rounded,
              iconColor: Colors.blue,
              title: l10n.rule2Title,
              description: l10n.rule2Desc,
            ),
            _buildRuleCard(
              icon: Icons.timer_rounded,
              iconColor: Colors.redAccent,
              title: l10n.rule3Title,
              description: l10n.rule3Desc,
            ),
            _buildRuleCard(
              icon: Icons.emoji_events_rounded,
              iconColor: Colors.amber,
              title: l10n.rule4Title,
              description: l10n.rule4Desc,
            ),
            _buildRuleCard(
              icon: Icons.verified_rounded,
              iconColor: Colors.green,
              title: l10n.rule5Title,
              description: l10n.rule5Desc,
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
                child: Text(
                  l10n.understoodButton,
                  style: const TextStyle(
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