// ==========================================
// BÖLÜM 1: Kütüphaneler, Sınıf Tanımlaması ve Değişkenler
// ==========================================
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_helper.dart';
import 'game_page.dart';
import 'ad_service.dart';

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
          "$turSayisi TUR ($turAciklamasi)",
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
    final String mevcutOyuncu = oyuncuAdi.isEmpty ? "Tokatlı60" : oyuncuAdi;

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

                  // ==================================================
                  // 🛡️ SİHİRLİ KALKAN: MANTIK HATASINI GİZLEYEN KOD
                  // ==================================================
                  if (siralama > toplamYarismaci) {
                    toplamYarismaci = siralama;
                  }
                  // ==================================================

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Puan: $puan",
                        style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Sıra: $siralama/$toplamYarismaci",
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
                    isFriendMode ? "ARKADAŞ ODASI" : "TURNUVA TUR SAYISI",
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
                        ? "Hoş geldin $mevcutOyuncu! Oda açıp arkadaş grubunu davet edebilirsin."
                        : "Hoş geldin $mevcutOyuncu, kaç tur yarışmak istersiniz?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
// YENİ DÜZELTME: Buton metni (2-10 Kişi) olarak güncellendi.
                      label: const Text("Oda Oluştur (2-10 Kişi)",
                          style: TextStyle(
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
                      label: const Text("Oda Kodu ile Katıl",
                          style: TextStyle(
                              color: Colors.purple,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      onPressed: () =>
                          _odaKoduGirDiyalogu(context, mevcutOyuncu),
                    ),
                  ] else ...[
                    _buildTurButonu(context, 1, "Hızlı Kapışma"),
                    _buildTurButonu(context, 3, "Standart Lig"),
                    _buildTurButonu(context, 5, "Maraton Devleri"),
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
                    label: const Text("Geri Dön",
                        style: TextStyle(
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
// BÖLÜM 4: Oyuncu Bilgilerini ve Sıralamayı Çekme Motoru (SIFIR MALİYETLİ YENİ SİSTEM)
// ==========================================
  Future<Map<String, dynamic>> _oyuncuBilgileriniGetir(String oyuncuAdi) async {
    // 1. Kendi yerel puanımızı alıyoruz (Maliyet: 0)
    int dbSkor = await DatabaseHelper.instance.getOyuncuSkor();

    // 2. Az önce veritabanında yazdığımız ZIRHLI ve UCUZ motoru (Bölüm 13) çağırıyoruz
    Map<String, int> hizliVeri =
        await DatabaseHelper.instance.getHizliSiralamaVeToplamOyuncu(dbSkor);

    // 3. Gelen hazır rakamları alıp ekrana gönderiyoruz
    return {
      'puan': dbSkor,
      'siralama': hizliVeri['sira'] ?? 1000,
      'toplamYarismaci': hizliVeri['toplam'] ?? 1000,
    };
  }

// ---------------- BÖLÜM 4 SONU ----------------

// ==========================================
// BÖLÜM 5: Arkadaş Odası Kurulumu ve Diyalogları
// ==========================================
  Future<void> _canliOdaOlustur(
      BuildContext context, String mevcutOyuncu) async {
    final String kod =
    (1000 + (DateTime.now().millisecondsSinceEpoch % 8999)).toString();

    await FirebaseFirestore.instance.collection('odalar').doc(kod).set({
      'odaKodu': kod,
      'kurucu': mevcutOyuncu,
      'oyuncular': [mevcutOyuncu],
      'aktifOyuncular': [mevcutOyuncu], // 🚀 1. EKLENTİ: Kurucu aktif listeye eklendi
      'durum': 'BEKLENIYOR',
      'olusturulmaTarihi': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      _canliOdaLobiEkraniGoster(context, mevcutOyuncu, kod, isHost: true);
    }
  }

  void _canliOdaLobiEkraniGoster(
      BuildContext context, String mevcutOyuncu, String kod,
      {required bool isHost}) {
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
              return const AlertDialog(
                  content: Text("Oda kapatıldı veya bulunamadı."));
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
                  const Text("🎮 Oyun Odası",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
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
                            const Text("ODA KODU",
                                style: TextStyle(
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
                          label: const Text("Kopyala",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: kod));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Oda kodu panoya kopyalandı!"),
                                  duration: Duration(seconds: 1)),
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
                        children: const [
                          Icon(Icons.share_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text("Arkadaşını Davet Et 🚀",
                              style: TextStyle(
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
                    Text("Katılan Oyuncular (${oyuncular.length}/10):",
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
                                  ? const Text("Sen",
                                  style: TextStyle(
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
                      'aktifOyuncular': FieldValue.arrayRemove([mevcutOyuncu]) // 🚀 2. EKLENTİ (TESTTE BULUNAN HATA): Lobiden çıkan, aktiflerden de silinir.
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  child:
                  const Text("Ayrıl", style: TextStyle(color: Colors.red)),
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
                      List<String> harfler = [
                        "A", "B", "C", "Ç", "D", "E", "F", "G", "H", "I", "İ", "J", "K", "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"
                      ];
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
                    child: Text("Oyunu Başlat (${oyuncular.length} Kişi)",
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
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Oda Kodunu Girin"),
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
                child: const Text("İptal")),
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
                    List<dynamic> odadakiOyuncular =
                        doc.data()?['oyuncular'] ?? [];
                    if (odadakiOyuncular.length >= 10) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Oda kapasitesi dolu (Maksimum 10 kişi)!"),
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
                      'aktifOyuncular': FieldValue.arrayUnion([mevcutOyuncu]) // 🚀 3. EKLENTİ: Odaya kodla katılan kişi aktiflere eklendi
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      _canliOdaLobiEkraniGoster(context, mevcutOyuncu, kod,
                          isHost: false);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Böyle bir oda bulunamadı!"),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text("Katıl", style: TextStyle(color: Colors.white)),
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
    int kalanSaniye = 5;
    bool rakipBulundu = false;
    String secilenRakip = "";
    String ortakHarf = "A";
    Timer? timer;
    StreamSubscription? odaDinleyici;
    String ben = oyuncuAdi.isEmpty ? "Tokatlı60" : oyuncuAdi;
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
                            .delete(); // Eşleşme başarısızsa Firebase düğümü tamamen siliniyor (Güvenli)
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
                title: const Text("⚔️ Rakip Aranıyor",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!rakipBulundu) ...[
                      const CircularProgressIndicator(color: Colors.purple),
                      const SizedBox(height: 15),
                      const Text("Rakip bekleniyor...",
                          style: TextStyle(fontSize: 15)),
                    ] else ...[
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 48),
                      const SizedBox(height: 10),
                      Text("Eşleşme Tamam!\n$secilenRakip",
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
                      child: Text("Süre: $kalanSaniye",
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
      var mevcutOda = await FirebaseFirestore.instance
          .collection('odalar')
          .where('durum', isEqualTo: 'BEKLIYOR')
          .where('isRandomMatch', isEqualTo: true)
          .where('toplamTurSayisi', isEqualTo: turSayisi)
          .limit(1)
          .get();

      if (mevcutOda.docs.isNotEmpty) {
        String docId = mevcutOda.docs.first.id;
        List<String> harfler = [
          "A", "B", "C", "Ç", "D", "E", "F", "G", "H", "I", "İ", "J", "K", "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"
        ];
        harfler.shuffle();
        String ortakHarf = harfler.first;
        String kurucu = mevcutOda.docs.first.data()['kurucu'] ?? "Rakip";

        await FirebaseFirestore.instance
            .collection('odalar')
            .doc(docId)
            .update({
          'oyuncular': FieldValue.arrayUnion([ben]),
          'aktifOyuncular': FieldValue.arrayUnion([ben]), // 🚀 4. EKLENTİ: Rastgele eşleşmede odaya giren kişi aktiflere eklendi
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
          'aktifOyuncular': [ben], // 🚀 5. EKLENTİ: Rastgele odayı ilk kuran kişi aktiflere eklendi
          'durum': 'BEKLIYOR',
          'isRandomMatch': true,
          'toplamTurSayisi': turSayisi,
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