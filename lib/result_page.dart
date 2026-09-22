// ============================================================================
// BÖLÜM 1: KÜTÜPHANELER, SINIF TANIMI VE BAŞLANGIÇ AYARLARI
// ============================================================================
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'ad_service.dart';

class ResultPage extends StatefulWidget {
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

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  // --- Alt Başlık: Değişkenler ---
  // Cihazda engellenen oyuncuların tutulacağı liste
  List<String> _engellenenKullanicilar = [];

  // --- Alt Başlık: Başlangıç (Init) Ayarları ---
  @override
  void initState() {
    super.initState();
    _engellenenleriYukle();
  }

  // Cihaz hafızasından engellenenleri çekiyoruz
  Future<void> _engellenenleriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _engellenenKullanicilar = prefs.getStringList('engellenen_kisiler') ?? [];
    });
  }
// ---------------- BÖLÜM 1 SONU ----------------


// ============================================================================
// BÖLÜM 2: ÇOKLU DİL SÖZLÜĞÜ VE APPLE ŞİKAYET/ENGELLEME SİSTEMİ
// ============================================================================
  // --- Alt Başlık: Apple Kuralı İçin Çoklu Dil Sözlüğü ---
  final Map<String, Map<String, String>> _raporCeviri = {
    'tr': {
      'title': 'Şikayet Et / Engelle',
      'desc1': "'",
      'desc2': "' adlı kullanıcıyı uygunsuz içerik nedeniyle şikayet etmek ve engellemek istiyor musunuz?\n\nBu şikayet 24 saat içinde incelenecek ve kullanıcı ekranınızdan gizlenecektir.",
      'cancel': 'İptal',
      'block': 'Engelle',
      'success': 'Kullanıcı engellendi. Artık görünmeyecek.',
      'tooltip': 'Şikayet Et ve Engelle'
    },
    'en': {
      'title': 'Report / Block',
      'desc1': "Do you want to report and block the user '",
      'desc2': "' for inappropriate content?\n\nThis will be reviewed within 24 hours, and the user will be instantly hidden.",
      'cancel': 'Cancel',
      'block': 'Block',
      'success': 'User blocked. They will no longer appear.',
      'tooltip': 'Report and Block'
    },
    'de': {
      'title': 'Melden / Blockieren',
      'desc1': "Möchten Sie den Benutzer '",
      'desc2': "' wegen unangemessener Inhalte melden und blockieren?\n\nDies wird innerhalb von 24 Stunden überprüft und der Benutzer wird ausgeblendet.",
      'cancel': 'Abbrechen',
      'block': 'Blockieren',
      'success': 'Benutzer blockiert. Er wird nicht mehr angezeigt.',
      'tooltip': 'Melden und Blockieren'
    },
    'es': {
      'title': 'Reportar / Bloquear',
      'desc1': "¿Deseas reportar y bloquear al usuario '",
      'desc2': "' por contenido inapropiado?\n\nEsto será revisado en 24 horas y el usuario se ocultará al instante.",
      'cancel': 'Cancelar',
      'block': 'Bloquear',
      'success': 'Usuario bloqueado. Ya no aparecerá.',
      'tooltip': 'Reportar y Bloquear'
    }
  };

  // --- Alt Başlık: Gerçek Şikayet ve Engelleme (Dialog) Fonksiyonu ---
  void _sikayetEtDialogGoster(BuildContext context, String sikayetEdilenKullanici) {
    String dil = Localizations.localeOf(context).languageCode;
    var t = _raporCeviri[dil] ?? _raporCeviri['en']!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.report_problem, color: Colors.red),
              const SizedBox(width: 10),
              Text(t['title']!, style: const TextStyle(color: Colors.red, fontSize: 18)),
            ],
          ),
          content: Text("${t['desc1']!}$sikayetEdilenKullanici${t['desc2']!}", style: const TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t['cancel']!, style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(dialogContext); // Pencereyi kapat

                // 1. ADIM: KULLANICIYI LOKAL OLARAK ENGELLE VE EKRANDAN GİZLE
                final prefs = await SharedPreferences.getInstance();
                _engellenenKullanicilar.add(sikayetEdilenKullanici);
                await prefs.setStringList('engellenen_kisiler', _engellenenKullanicilar);

                setState(() {}); // Ekranı yenile, o kullanıcı anında yok olsun!

                // 2. ADIM: Firestore'a şikayet kaydını düş
                try {
                  await FirebaseFirestore.instance.collection('sikayetler').add({
                    'sikayetEden': widget.oyuncuAdi,
                    'sikayetEdilen': sikayetEdilenKullanici,
                    'tarih': FieldValue.serverTimestamp(),
                    'durum': 'İncelenecek',
                    'sebep': 'Kullanıcı Tarafından Bildirildi (UGC Kural İhlali)'
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t['success']!),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint("Şikayet kaydedilemedi: $e");
                }
              },
              child: Text(t['block']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
// ---------------- BÖLÜM 2 SONU ----------------


// ============================================================================
// BÖLÜM 3: EKRAN ÇİZİMİ (BUILD) VE MATEMATİKSEL HESAPLAMALAR
// ============================================================================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // --- Alt Başlık: Dil Algılayıcı (Tooltip İçin) ---
    String dil = Localizations.localeOf(context).languageCode;
    var t = _raporCeviri[dil] ?? _raporCeviri['en']!;

    // --- Alt Başlık: Puan Hesaplamaları ve Liderlik Filtresi ---
    // Engellenen kullanıcıları Liderlik tablosundan süzüp atıyoruz
    List<MapEntry<String, int>> siraliSkorlar = widget.tumMacSkorlari.entries
        .where((entry) => !_engellenenKullanicilar.contains(entry.key))
        .toList();

    siraliSkorlar.sort((a, b) => b.value.compareTo(a.value));

    // Sıralamadaki yerimizi ve en yüksek skoru buluyoruz
    int benimSiram = siraliSkorlar.indexWhere((element) => element.key == widget.oyuncuAdi) + 1;
    int enYuksekSkor = siraliSkorlar.isNotEmpty ? siraliSkorlar.first.value : 0;

    // Kazanma durumu kontrolleri
    bool kazandi = (widget.tumMacSkorlari[widget.oyuncuAdi] == enYuksekSkor && enYuksekSkor > 0);
    bool berabere = kazandi && siraliSkorlar.where((e) => e.value == enYuksekSkor).length > 1;
    int siralamaFarki = widget.eskiSiralama - widget.yeniSiralama;
// ---------------- BÖLÜM 3 SONU ----------------


// ============================================================================
// BÖLÜM 4: KULLANICI ARAYÜZÜ (UI) - DURUM İKONU VE BAŞLIK
// ============================================================================
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // --- Alt Başlık: Kupa veya Üzgün Yüz İkonu ---
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

              // --- Alt Başlık: Kazandın / Kaybettin Metni ---
              Text(
                kazandi && !berabere
                    ? l10n.matchWinnerTitle
                    : (berabere ? l10n.matchTieTitle : l10n.matchLoserTitle),
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
// ---------------- BÖLÜM 4 SONU ----------------


// ============================================================================
// BÖLÜM 5: DİNAMİK LİDERLİK TABLOSU KARTI (OYUNCU LİSTESİ)
// ============================================================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.shade100, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(l10n.matchRankingTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 13,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 15),

                    // --- Alt Başlık: Oyuncuları Sırayla Çizdirme Döngüsü ---
                    ...siraliSkorlar.asMap().entries.map((entry) {
                      int index = entry.key;
                      String isim = entry.value.key;
                      int skor = entry.value.value;
                      bool benMiyim = isim == widget.oyuncuAdi;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: benMiyim ? Colors.purple.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: benMiyim
                                  ? Colors.purple.shade300
                                  : Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            // 1. Sıra Numarası ve Madalya Rengi
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
                                    color: index < 3 ? Colors.white : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // 2. Oyuncu Adı
                            Expanded(
                              child: Text(
                                benMiyim ? "$isim ${l10n.youLabel}" : isim,
                                style: TextStyle(
                                  fontWeight: benMiyim ? FontWeight.w900 : FontWeight.bold,
                                  color: benMiyim ? Colors.purple.shade900 : Colors.black87,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // 3. ŞİKAYET ET BUTONU (Sadece Rakiplerde Çıkar)
                            if (!benMiyim)
                              IconButton(
                                icon: const Icon(Icons.report_problem_rounded, color: Colors.redAccent, size: 22),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: t['tooltip']!,
                                onPressed: () => _sikayetEtDialogGoster(context, isim),
                              ),
                            if (!benMiyim) const SizedBox(width: 8),

                            // 4. Oyuncu Skoru
                            Text(
                              "$skor ${l10n.pointsSuffix}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: benMiyim ? Colors.purple.shade900 : Colors.purple.shade400,
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
// ---------------- BÖLÜM 5 SONU ----------------


// ============================================================================
// BÖLÜM 6: GENEL İSTATİSTİK KARTI (PUAN VE SIRALAMA)
// ============================================================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Text(l10n.overallStatsTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 13)),
                    const SizedBox(height: 15),

                    // --- Alt Başlık: Genel Puan Satırı ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.overallScoreLabel,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                                  Text("${widget.yeniGenelPuan} ${l10n.pointsSuffix}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue)),
                                  const SizedBox(width: 6),
                                  Text(
                                    (widget.yeniGenelPuan - widget.eskiGenelPuan) >= 0
                                        ? "(+${widget.yeniGenelPuan - widget.eskiGenelPuan})"
                                        : "(${widget.yeniGenelPuan - widget.eskiGenelPuan})",
                                    style: TextStyle(
                                      color: (widget.yeniGenelPuan - widget.eskiGenelPuan) >= 0
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

                    // --- Alt Başlık: Sıralama Satırı ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.leaderboard, color: Colors.purple, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.rankingLabel,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                                  Text("#${widget.yeniSiralama}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(width: 6),
                                  if (siralamaFarki > 0)
                                    Text(l10n.wentUpLabel(siralamaFarki),
                                        style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12))
                                  else if (siralamaFarki < 0)
                                    Text(l10n.wentDownLabel(siralamaFarki.abs()),
                                        style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12))
                                  else
                                    Text(l10n.noChangeLabel,
                                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
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
// ---------------- BÖLÜM 6 SONU ----------------


// ============================================================================
// BÖLÜM 7: ANA SAYFAYA DÖN BUTONU VE REKLAM ALANI
// ============================================================================
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.home, size: 22),
                label: Text(l10n.returnToHomeButton,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),

      // --- Alt Başlık: Alt Banner Reklam ---
      bottomNavigationBar: const SafeArea(
        child: BottomBannerAdWidget(),
      ),
    );
  }
}
// ============================================================================
// SAYFA SONU
// ============================================================================