import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text(
          l10n.privacyPolicyTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ÜST BÖLÜM: İkon ve Son Güncelleme
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      size: 60,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.privacyLastUpdate,
                      style: TextStyle(
                          color: Colors.indigo.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // GİRİŞ METNİ
              Text(
                l10n.privacyIntro,
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 25),

              // 1. BÖLÜM
              _buildSection(l10n.privacySection1Title, l10n.privacySection1Text),

              // 2. BÖLÜM
              _buildSection(l10n.privacySection2Title, l10n.privacySection2Text),

              // 3. BÖLÜM
              _buildSection(l10n.privacySection3Title, l10n.privacySection3Text),

              // 4. BÖLÜM
              _buildSection(l10n.privacySection4Title, l10n.privacySection4Text),

              const SizedBox(height: 15),

              // KAPAT BUTONU
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  l10n.closeButton,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Başlık ve metinleri şık kartlar halinde çizen yardımcı metot
  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
              fontSize: 15,
            ),
          ),
          const Divider(),
          Text(
            content,
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }
}