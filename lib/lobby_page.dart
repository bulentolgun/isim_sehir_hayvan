// ==========================================
// BÖLÜM 1: Kütüphaneler, Sınıf Tanımlaması ve Değişkenler
// ==========================================
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';
import 'database_helper.dart';
import 'game_page.dart';
import 'ad_service.dart';
import 'main.dart'; // 🚀 DİL KİLİDİ İÇİN EKLENDİ

class LobbyPage extends StatelessWidget {
  final String oyuncuAdi;
  final int yuzIndex;
  final int aksesuarIndex;
  final int renkIndex;
  final bool isFriendMode;

  const LobbyPage({
    super.key,
    required this.oyuncuAdi,
    required this.yuzIndex,
    required this.aksesuarIndex,
    required this.renkIndex,
    this.isFriendMode = false,
  });

// ---------------- BÖLÜM 1 SONU ----------------

// ==========================================
// BÖLÜM 2: UI Yardımcı Widget'ları (Butonlar vb.)
// ==========================================
  Widget _buildTurButonu(
      BuildContext context, int turSayisi, String turAciklamasi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: OutlinedButton(
        onPressed: () => _eslesmeVeBaslat(context, turSayisi),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.purple, width: 1.5),
          minimumSize: const Size(double.infinity, 50),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          "$turSayisi ${AppLocalizations.of(context)!.roundText} ($turAciklamasi)",
          style: const TextStyle(
            color: Colors.purple,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

// ---------------- BÖLÜM 2 SONU ----------------

// ==========================================
// BÖLÜM 3: Ana Ekran Arayüzü (Build Metodu)
// ==========================================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String mevcutOyuncu = oyuncuAdi.isEmpty ? l10n.defaultPlayerName : oyuncuAdi;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [

            // 🎯 SOL ÜSTTE CANLI DİNAMİK PUAN VE SIRALAMA BİLGİSİ
            Positioned(
              top: 12,
              left: 16,
              child: FutureBuilder<Map<String, dynamic>>(
                future: _oyuncuBilgileriniGetir(mevcutOyuncu),
                builder: (context, snapshot) {
                  int puan = snapshot.data?['puan'] ?? 0;
                  int siralama = snapshot.data?['siralama'] ?? 1000;
                  int toplamYarismaci = snapshot.data?['toplamYarismaci'] ?? 1000;

                  if (siralama > toplamYarismaci) {
                    toplamYarismaci = siralama;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${l10n.scoreText}: $puan",
                        style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${l10n.rankText}: $siralama/$toplamYarismaci",
                        style: TextStyle(
                          color: Colors.purple.shade300,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Icon(
                    isFriendMode ? Icons.groups_rounded : Icons.timer,
                    size: 70,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isFriendMode ? l10n.friendRoomTitle : l10n.tournamentRoundsTitle,
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isFriendMode
                        ? l10n.friendRoomSubtitle(mevcutOyuncu)
                        : l10n.tournamentRoundsSubtitle(mevcutOyuncu),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isFriendMode) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      label: Text(l10n.createRoomButton,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      onPressed: () => _canliOdaOlustur(context, mevcutOyuncu),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side:
                        const BorderSide(color: Colors.purple, width: 1.5),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      icon: const Icon(Icons.login_rounded,
                          color: Colors.purple, size: 22),
                      label: Text(l10n.joinWithCodeButton,
                          style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      onPressed: () =>
                          _odaKoduGirDiyalogu(context, mevcutOyuncu),
                    ),
                  ] else ...[
                    _buildTurButonu(context, 1, l10n.quickMatch),
                    _buildTurButonu(context, 3, l10n.standardLeague),
                    _buildTurButonu(context, 5, l10n.marathonGiants),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400, width: 1.2),
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    icon: Icon(Icons.arrow_back,
                        color: Colors.grey.shade700, size: 18),
                    label: Text(l10n.goBackButton,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 300,
                    height: 250,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.shade100),
                    ),
                    child: const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      child: MediumRectangleAdWidget(),
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

// ---------------- BÖLÜM 3 SONU ----------------

// ==========================================
// BÖLÜM 4: Oyuncu Bilgilerini ve Sıralamayı Çekme Motoru
// ==========================================
  Future<Map<String, dynamic>> _oyuncuBilgileriniGetir(String oyuncuAdi) async {
    int dbSkor = await DatabaseHelper.instance.getOyuncuSkor();
    Map<String, int> hizliVeri =
    await DatabaseHelper.instance.getHizliSiralamaVeToplamOyuncu(dbSkor);

    return {
      'puan': dbSkor,
      'siralama': hizliVeri['sira'] ?? 1000,
      'toplamYarismaci': hizliVeri['toplam'] ?? 1000,
    };
  }

// ---------------- BÖLÜM 4 SONU ----------------
  // ==========================================
// BÖLÜM 4.5: ÇOK DİLLİ ALFABE SİSTEMİ 🌍
// ==========================================
  List<String> _getAlfabe(String lang) {
    if (lang == 'en') return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
    if (lang == 'de') return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Ä", "Ö", "Ü"];
    if (lang == 'es') return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Ñ"];
    return ["A", "B", "C", "Ç", "D", "E", "F", "G", "H", "I", "İ", "J", "K", "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"];
  }

// ==========================================
// ==========================================
// BÖLÜM 5: Arkadaş Odası Kurulumu ve Diyalogları
// ==========================================
  Future<void> _canliOdaOlustur(
      BuildContext context, String mevcutOyuncu) async {
    final String kod =
    (1000 + (DateTime.now().millisecondsSinceEpoch % 8999)).toString();

    String lang = appLocale.value.languageCode; // 🚀 ODAYI KURANIN DİLİ

    await FirebaseFirestore.instance.collection('odalar').doc(kod).set({
      'odaKodu': kod,
      'kurucu': mevcutOyuncu,
      'oyuncular': [mevcutOyuncu],
      'aktifOyuncular': [mevcutOyuncu],
      'durum': 'BEKLENIYOR',
      'odaDili': lang, // 🚀 ODA DİLİ FİREBASE'E KAYDEDİLİYOR
      'olusturulmaTarihi': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      _canliOdaLobiEkraniGoster(context, mevcutOyuncu, kod, isHost: true);
    }
  }

  void _canliOdaLobiEkraniGoster(
      BuildContext context, String mevcutOyuncu, String kod,
      {required bool isHost}) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('odalar')
              .doc(kod)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return AlertDialog(content: Text(l10n.roomClosedOrNotFound));
            }

            var odaData = snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> oyuncular = odaData['oyuncular'] ?? [];
            String durum = odaData['durum'] ?? 'BEKLENIYOR';

            if (durum == 'BASLADI' && !isHost) {
              String gelenHarf = odaData['secilenHarf'] ?? "A";

              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamePage(
                      oyuncuAdi: mevcutOyuncu,
                      rakipAdi:
                      oyuncular.where((p) => p != mevcutOyuncu).join(", "),
                      yuzIndex: yuzIndex,
                      aksesuarIndex: aksesuarIndex,
                      renkIndex: renkIndex,
                      mevcutTur: 1,
                      toplamTurSayisi: 3,
                      oyuncuKumulatifSkor: 0,
                      rakip1KumulatifSkor: 0,
                      secilenHarf: gelenHarf,
                      odaKodu: kod,
                    ),
                  ),
                );
              });
            }

            return AlertDialog(
              insetPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Column(
                children: [
                  Text("🎮 ${l10n.gameRoom}",
                      style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.roomCode,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            Text(kod,
                                style: const TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26)),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade100,
                            foregroundColor: Colors.purple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.copy, size: 18),
                          label: Text(l10n.copyButton,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: kod));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l10n.roomCodeCopied),
                                  duration: const Duration(seconds: 1)),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      String deepLink = "https://isimsehir.app/join?code=$kod";
                      String storeLink =
                          "https://play.google.com/store/apps/details?id=com.tamam.isim_sehir_hayvan";

                      String mesaj =
                          "İsim Şehir Hayvan oynamaya davet edildin! 🎮\n\n"
                          "Sen de gel, yarışalım!\n"
                          "📌 Oda Kodun: $kod\n\n"
                          "🔗 Doğrudan Odaya Katılmak İçin Tıkla:\n$deepLink\n\n"
                          "📲 Uygulama yüklü değilse hemen indir:\n$storeLink";

                      Share.share(mesaj,
                          subject: 'İsim Şehir Hayvan Oyunu Oda Daveti');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.purple, Colors.purple.shade700]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text("${l10n.inviteFriend} 🚀",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${l10n.joinedPlayers} (${oyuncular.length}/10):",
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: oyuncular
                              .map((p) => Card(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12)),
                            child: ListTile(
                              dense: true,
                              leading: const Icon(Icons.person,
                                  color: Colors.purple),
                              title: Text(p.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              trailing: p == mevcutOyuncu
                                  ? Text(l10n.youText,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold))
                                  : null,
                            ),
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('odalar')
                        .doc(kod)
                        .update({
                      'oyuncular': FieldValue.arrayRemove([mevcutOyuncu]),
                      'aktifOyuncular': FieldValue.arrayRemove([mevcutOyuncu])
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  child:
                  Text(l10n.leaveButton, style: const TextStyle(color: Colors.red)),
                ),
                if (isHost)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: oyuncular.length >= 2
                        ? () async {

                      // 🚀 SABİT TÜRKÇE ALFABE SİLİNDİ, DİNAMİK ALFABE GELDİ!
                      String lang = appLocale.value.languageCode;
                      List<String> harfler = _getAlfabe(lang);

                      harfler.shuffle();
                      String ortakHarf = harfler.first;

                      await FirebaseFirestore.instance
                          .collection('odalar')
                          .doc(kod)
                          .update({
                        'durum': 'BASLADI',
                        'secilenHarf': ortakHarf,
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GamePage(
                              oyuncuAdi: mevcutOyuncu,
                              rakipAdi: oyuncular
                                  .where((p) => p != mevcutOyuncu)
                                  .join(", "),
                              yuzIndex: yuzIndex,
                              aksesuarIndex: aksesuarIndex,
                              renkIndex: renkIndex,
                              mevcutTur: 1,
                              toplamTurSayisi: 3,
                              oyuncuKumulatifSkor: 0,
                              rakip1KumulatifSkor: 0,
                              secilenHarf: ortakHarf,
                              odaKodu: kod,
                            ),
                          ),
                        );
                      }
                    }
                        : null,
                    child: Text("${l10n.startGameButton} (${oyuncular.length})",
                        style: const TextStyle(color: Colors.white)),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _odaKoduGirDiyalogu(BuildContext context, String mevcutOyuncu) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.enterRoomCode),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
                hintText: "", border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancelButton)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () async {
                String kod = controller.text.trim();
                if (kod.isNotEmpty) {
                  var doc = await FirebaseFirestore.instance
                      .collection('odalar')
                      .doc(kod)
                      .get();
                  if (doc.exists) {

                    // 🚀 DİL KİLİDİ KONTROLÜ BAŞLIYOR 🚀
                    String odaDili = doc.data()?['odaDili'] ?? 'tr';
                    String benimDilim = appLocale.value.languageCode;

                    if (odaDili != benimDilim) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Oda ($odaDili) dilinde kurulmuş. Oynamak için cihaz oyun dilinizi değiştirmelisiniz! / Room is in ($odaDili)."),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                      return; // GİRİŞİ YASAKLA!
                    }
                    // ---------------------------------

                    List<dynamic> odadakiOyuncular =
                        doc.data()?['oyuncular'] ?? [];
                    if (odadakiOyuncular.length >= 10) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(l10n.roomFullError),
                              backgroundColor: Colors.red),
                        );
                      }
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('odalar')
                        .doc(kod)
                        .update({
                      'oyuncular': FieldValue.arrayUnion([mevcutOyuncu]),
                      'aktifOyuncular': FieldValue.arrayUnion([mevcutOyuncu])
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      _canliOdaLobiEkraniGoster(context, mevcutOyuncu, kod,
                          isHost: false);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(l10n.roomNotFoundError),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: Text(l10n.joinButton, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

// ---------------- BÖLÜM 5 SONU ----------------

// ==========================================
// BÖLÜM 6: Rastgele Eşleştirme Motoru ve Oyuna Geçiş
// ==========================================
  void _eslesmeVeBaslat(BuildContext context, int turSayisi) {
    final l10n = AppLocalizations.of(context)!;
    int kalanSaniye = 5;
    bool rakipBulundu = false;
    String secilenRakip = "";
    String ortakHarf = "A";
    Timer? timer;
    StreamSubscription? odaDinleyici;
    String ben = oyuncuAdi.isEmpty ? l10n.defaultPlayerName : oyuncuAdi;
    String aktifOdaId = "";
    bool islemBasladi = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (innerContext, setDialogState) {
              if (!islemBasladi) {
                islemBasladi = true;

                _rastgeleEslesmeOdasinaGir(ben, turSayisi).then((sonuc) async {
                  if (sonuc.containsKey('error')) {
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    return;
                  }

                  aktifOdaId = sonuc['docId'];
                  bool odayaKatildi = sonuc['joined'];

                  if (odayaKatildi) {
                    rakipBulundu = true;
                    secilenRakip = sonuc['rakip'];
                    ortakHarf = sonuc['harf'];

                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    if (context.mounted) {
                      _oyunaGit(context, ben, secilenRakip, turSayisi,
                          aktifOdaId, ortakHarf);
                    }
                    return;
                  }

                  odaDinleyici = FirebaseFirestore.instance
                      .collection('odalar')
                      .doc(aktifOdaId)
                      .snapshots()
                      .listen((doc) {
                    if (doc.exists && doc.data()?['durum'] == 'BASLADI') {
                      List<dynamic> oyuncular = doc.data()?['oyuncular'] ?? [];
                      if (oyuncular.length >= 2) {
                        rakipBulundu = true;
                        secilenRakip = oyuncular
                            .firstWhere((p) => p != ben,
                            orElse: () => "GizemliOyuncu")
                            .toString();
                        ortakHarf = doc.data()?['secilenHarf'] ?? "A";

                        timer?.cancel();
                        odaDinleyici?.cancel();

                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        if (context.mounted) {
                          _oyunaGit(context, ben, secilenRakip, turSayisi,
                              aktifOdaId, ortakHarf);
                        }
                      }
                    }
                  });

                  timer = Timer.periodic(const Duration(seconds: 1), (t) async {
                    if (kalanSaniye <= 1) {
                      t.cancel();
                      odaDinleyici?.cancel();

                      if (aktifOdaId.isNotEmpty) {
                        FirebaseFirestore.instance
                            .collection('odalar')
                            .doc(aktifOdaId)
                            .delete();
                      }

                      final randomBot =
                      await DatabaseHelper.instance.getRandomBot();
                      secilenRakip = randomBot['bot_adi'] ?? "Ahmet_34";

                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      if (context.mounted) {
                        _oyunaGit(
                            context, ben, secilenRakip, turSayisi, "", null);
                      }
                    } else {
                      setDialogState(() {
                        kalanSaniye--;
                      });
                    }
                  });
                });
              }

              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text("⚔️ ${l10n.searchingOpponent}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!rakipBulundu) ...[
                      const CircularProgressIndicator(color: Colors.purple),
                      const SizedBox(height: 15),
                      Text(l10n.waitingForOpponent,
                          style: const TextStyle(fontSize: 15)),
                    ] else ...[
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 48),
                      const SizedBox(height: 10),
                      Text("${l10n.matchFound}\n$secilenRakip",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple)),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text("${l10n.timeText}: $kalanSaniye",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _oyunaGit(BuildContext context, String ben, String secilenRakip,
      int turSayisi, String odaKodu, String? harf) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          oyuncuAdi: ben,
          rakipAdi: secilenRakip,
          yuzIndex: yuzIndex,
          aksesuarIndex: aksesuarIndex,
          renkIndex: renkIndex,
          mevcutTur: 1,
          toplamTurSayisi: turSayisi,
          oyuncuKumulatifSkor: 0,
          rakip1KumulatifSkor: 0,
          odaKodu: odaKodu.isNotEmpty ? odaKodu : null,
          secilenHarf: harf,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _rastgeleEslesmeOdasinaGir(
      String ben, int turSayisi) async {
    try {

      String lang = appLocale.value.languageCode; // 🚀 YENİ DİL FİLTRESİ

      var mevcutOda = await FirebaseFirestore.instance
          .collection('odalar')
          .where('durum', isEqualTo: 'BEKLIYOR')
          .where('isRandomMatch', isEqualTo: true)
          .where('toplamTurSayisi', isEqualTo: turSayisi)
          .where('odaDili', isEqualTo: lang) // 🚀 SADECE KENDİ DİLİNDEKİLERLE EŞLEŞ
          .limit(1)
          .get();

      if (mevcutOda.docs.isNotEmpty) {
        String docId = mevcutOda.docs.first.id;

        // 🚀 DİNAMİK ALFABE DEVREDE
        List<String> harfler = _getAlfabe(lang);
        harfler.shuffle();
        String ortakHarf = harfler.first;
        String kurucu = mevcutOda.docs.first.data()['kurucu'] ?? "Rakip";

        await FirebaseFirestore.instance
            .collection('odalar')
            .doc(docId)
            .update({
          'oyuncular': FieldValue.arrayUnion([ben]),
          'aktifOyuncular': FieldValue.arrayUnion([ben]),
          'durum': 'BASLADI',
          'secilenHarf': ortakHarf
        });

        return {
          'docId': docId,
          'joined': true,
          'harf': ortakHarf,
          'rakip': kurucu
        };
      } else {
        var yeniOda = FirebaseFirestore.instance.collection('odalar').doc();
        await yeniOda.set({
          'odaKodu': yeniOda.id,
          'kurucu': ben,
          'oyuncular': [ben],
          'aktifOyuncular': [ben],
          'durum': 'BEKLIYOR',
          'isRandomMatch': true,
          'toplamTurSayisi': turSayisi,
          'odaDili': lang, // 🚀 YENİ ODA DİLİ İLE KURULUYOR
          'mevcutTur': 1,
          'olusturulmaTarihi': FieldValue.serverTimestamp(),
        });

        return {'docId': yeniOda.id, 'joined': false};
      }
    } catch (e) {
      print("🚨 Matchmaking hatası: $e");
      return {'error': true};
    }
  }
}
// ---------------- BÖLÜM 6 SONU ----------------