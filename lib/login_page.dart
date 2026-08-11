import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'game_mode_page.dart';
import 'rules_page.dart';
import 'contact_us_page.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();

  int secilenYuzIndex = 0;
  int secilenAksesuarIndex = 0;
  int secilenRenkIndex = 0;

  String? savedOyuncuAdi;
  int? savedYuzIndex;
  int? savedAksesuarIndex;
  int? savedRenkIndex;
  bool hasSavedUser = false;

  final List<String> yuzler = ["😀", "😎", "🦊", "🐱", "🦁", "🐻"];
  final List<String> aksesuarlar = ["👑", "🕶️", "🎧", "🎩", "🎀", "⭐"];
  final List<Color> renkler = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.indigo,
    Colors.pink,
    Colors.red
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 🎯 CİHAZIN BENZERSİZ KİMLİĞİNİ (DEVICE ID) ALAN YARDIMCI METOT
  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Android Cihaz ID'si
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? "ios_unknown_device";
      }
    } catch (e) {
      debugPrint("Cihaz ID alma hatası: $e");
    }
    return "unknown_device_${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<void> _saveUser(String name, int yuz, int aksesuar, int renk) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_oyuncu_adi', name);
    await prefs.setInt('saved_yuz_index', yuz);
    await prefs.setInt('saved_aksesuar_index', aksesuar);
    await prefs.setInt('saved_renk_index', renk);
  }

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('saved_oyuncu_adi');
    if (name != null && name.isNotEmpty && mounted) {
      setState(() {
        savedOyuncuAdi = name;
        savedYuzIndex = (prefs.getInt('saved_yuz_index') ?? 0).clamp(0, yuzler.length - 1);
        savedAksesuarIndex = (prefs.getInt('saved_aksesuar_index') ?? 0).clamp(0, aksesuarlar.length - 1);
        savedRenkIndex = (prefs.getInt('saved_renk_index') ?? 0).clamp(0, renkler.length - 1);
        hasSavedUser = true;
      });
    }
  }

  // 🎯 GİRİŞ VE FIREBASE CANLI KULLANICI KAYDI
  Future<void> _girisYap(String name, int yuz, int aksesuar, int renk) async {
    // 1. Yerel Cihaz Hafızasına Kayıt
    await _saveUser(name, yuz, aksesuar, renk);

    // 2. Cihaz Kimliği (Device ID) ile Firebase Cloud Firestore Kaydı
    try {
      String deviceId = await _getDeviceId();
      final userDoc = FirebaseFirestore.instance.collection('kullanicilar').doc(deviceId);

      await userDoc.set({
        'deviceId': deviceId,
        'oyuncuAdi': name,
        'yuzIndex': yuz,
        'aksesuarIndex': aksesuar,
        'renkIndex': renk,
        'sonGirisTarihi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Firebase Kullanıcı Kayıt Hatası: $e");
    }

    // 3. Oyun Modu Sayfasına Yönlendirme
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameModePage(
            oyuncuAdi: name,
            yuzIndex: yuz,
            aksesuarIndex: aksesuar,
            renkIndex: renk,
          ),
        ),
      ).then((_) {
        if (mounted) _loadSavedUser();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Güvenli renk ve ikon seçimi
    final Color activeColor = renkler[(savedRenkIndex ?? 0).clamp(0, renkler.length - 1)];
    final String mevcutOyuncu = savedOyuncuAdi ?? (_nameController.text.trim().isEmpty ? "Oyuncu" : _nameController.text.trim());

    return Scaffold(
      backgroundColor: Colors.white,

      // 🎯 APPBAR: SADECE KAYITLI OYUNCU EKRANINDA MENÜ İKONU GÖRÜNECEK
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Eğer önceden kaydedilmiş bir kullanıcı varsa (2. sayfa görünümü) menüyü göster
          if (hasSavedUser && savedOyuncuAdi != null)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.indigo, size: 32),
                tooltip: "Menü",
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          if (hasSavedUser && savedOyuncuAdi != null)
            const SizedBox(width: 8),
        ],
      ),

      // 🎯 SAĞDAN AÇILAN YAN MENÜ (endDrawer)
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.indigo,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 45, color: Colors.indigo.shade700),
              ),
              accountName: Text(
                mevcutOyuncu,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: const Text("Hoş geldin Yarışmacı! 🎮"),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded, color: Colors.indigo),
              title: const Text("Oyun Kuralları", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Puanlama ve yarışma rehberi"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RulesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: Colors.indigo),
              title: const Text('İsim Şehir Oyunu Gizlilik Politikası', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: const Text('Veri kullanımı ve gizlilik haklarınız'),
              onTap: () async {
                Navigator.pop(context); // Menüyü kapatır

                // BURAYA KENDİ GITHUB LİNKİNİZİ YAPIŞTIRIN
                final Uri url = Uri.parse('https://bulentolgun.github.io/isim-sehir-gizlilik/');

                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  debugPrint('Sayfa açılamadı');
                }
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.mark_email_unread_rounded, color: Colors.indigo),
              title: const Text("Bize Ulaşın", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Şikayet, öneri ve destek"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactUsPage(oyuncuAdi: mevcutOyuncu),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Versiyon 1.0.0",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/logo.png', // Eğer logonuzun adı logo.png ise burayı .png yapmayı unutmayın!
                  height: 120,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "İsim Şehir Hayvan Oyunu",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
              const SizedBox(height: 8),
              const Text(
                "Zekanı yarıştır, rakibini geride bırak!",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 30),

              // DAHA ÖNCE KAYDEDİLMİŞ OYUNCU VARSA
              if (hasSavedUser && savedOyuncuAdi != null) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: activeColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          "Son Giriş Yapan Oyuncu",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 15),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: activeColor,
                              child: Text(yuzler[savedYuzIndex!], style: const TextStyle(fontSize: 40)),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Text(aksesuarlar[savedAksesuarIndex!], style: const TextStyle(fontSize: 28)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          savedOyuncuAdi!,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: activeColor),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () => _girisYap(savedOyuncuAdi!, savedYuzIndex!, savedAksesuarIndex!, savedRenkIndex!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeColor,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text(
                            "Aynı Oyuncuyla Devam Et",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _nameController.clear();
                      hasSavedUser = false;
                    });
                  },
                  icon: const Icon(Icons.swap_horiz, color: Colors.indigo),
                  label: const Text(
                    "Farklı bir isimle giriş yap",
                    style: TextStyle(color: Colors.indigo, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ]
              // YENİ GİRİŞ FORMU
              else ...[
                TextField(
                  controller: _nameController,
                  maxLength: 15,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: "Oyuncu Adınız",
                    prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Avatarını Özelleştir", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ),
                const SizedBox(height: 15),

                // İfade Seçimi
                const Align(alignment: Alignment.centerLeft, child: Text("İfade Seç:", style: TextStyle(color: Colors.black, fontSize: 12))),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: yuzler.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => secilenYuzIndex = index),
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: secilenYuzIndex == index ? Colors.indigo.withOpacity(0.1) : Colors.transparent,
                            border: Border.all(color: secilenYuzIndex == index ? Colors.indigo : Colors.grey.shade300, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(yuzler[index], style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Aksesuar Seçimi
                const Align(alignment: Alignment.centerLeft, child: Text("Aksesuar Seç:", style: TextStyle(color: Colors.black, fontSize: 12))),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: aksesuarlar.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => secilenAksesuarIndex = index),
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: secilenAksesuarIndex == index ? Colors.indigo.withOpacity(0.1) : Colors.transparent,
                            border: Border.all(color: secilenAksesuarIndex == index ? Colors.indigo : Colors.grey.shade300, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(aksesuarlar[index], style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Tema Rengi Seçimi
                const Align(alignment: Alignment.centerLeft, child: Text("Tema Rengi Seç:", style: TextStyle(color: Colors.black, fontSize: 12))),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: renkler.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => secilenRenkIndex = index),
                        child: Container(
                          width: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                          decoration: BoxDecoration(
                            color: renkler[index],
                            shape: BoxShape.circle,
                            border: Border.all(color: secilenRenkIndex == index ? Colors.black87 : Colors.transparent, width: 2.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 35),

                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lütfen geçerli bir isim yazın!")),
                      );
                      return;
                    }
                    _girisYap(name, secilenYuzIndex, secilenAksesuarIndex, secilenRenkIndex);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "Giriş Yap ve Başla",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (savedOyuncuAdi != null) ...[
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => setState(() => hasSavedUser = true),
                    child: const Text("Vazgeç, Son Kullanıcıyla Devam Et", style: TextStyle(color: Colors.black)),
                  )
                ]
              ],
            ],
          ),
        ),
      ),
    );
  }
}