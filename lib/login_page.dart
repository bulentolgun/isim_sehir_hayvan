// ==========================================
// BÖLÜM 1: KÜTÜPHANELER VE İÇE AKTARMALAR (IMPORTS)
// ==========================================
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'game_mode_page.dart';
import 'rules_page.dart';
import 'contact_us_page.dart';
import 'gemini_service.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';
import 'privacy_policy_page.dart'; // 🚀 GİZLİLİK POLİTİKASI SAYFASI EKLENDİ
// ---------------- BÖLÜM 1 SONU ----------------

// ==========================================
// BÖLÜM 2: SINIF TANIMLAMALARI VE DEĞİŞKENLER (STATE & VARIABLES)
// ==========================================
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

  bool _isLoading = false;

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

  final List<String> yasakliKelimeler = [
    "amk", "sik", "piç", "orospu", "oç", "sg", "yarrak", "göt",
    "meme", "dalyarak", "pezevenk", "kaltak", "fahişe", "amq",
    "aq", "mk", "sürtük", "yavşak", "ibne", "kahpe", "gay",
    "porno", "sex", "bok"
  ];
// ---------------- BÖLÜM 2 SONU ----------------

// ==========================================
// BÖLÜM 3: YARDIMCI FONKSİYONLAR VE KONTROLLER (HELPER METHODS)
// ==========================================
  String trToLowerCase(String text) {
    return text
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .replaceAll('Ğ', 'ğ')
        .replaceAll('Ü', 'ü')
        .replaceAll('Ş', 'ş')
        .replaceAll('Ö', 'ö')
        .replaceAll('Ç', 'ç')
        .toLowerCase();
  }

  bool _isimUygunMu(String isim) {
    String temizIsim = isim.trim();

    String sadeceHarfler = temizIsim.replaceAll(RegExp(r'[\d\W_]'), '');
    if (sadeceHarfler.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.nameTooShortError),
            backgroundColor: Colors.red),
      );
      return false;
    }

    String kucukIsim = trToLowerCase(temizIsim);
    String hileCozulmus = kucukIsim
        .replaceAll('1', 'i')
        .replaceAll('0', 'o')
        .replaceAll('3', 'e')
        .replaceAll('@', 'a')
        .replaceAll('5', 's');

    String sadeceHarflerVeBosluk =
    hileCozulmus.replaceAll(RegExp(r'[^a-zçğıöşü\s]'), '');
    String bitisikKelime = sadeceHarflerVeBosluk.replaceAll(RegExp(r'\s+'), '');

    if (yasakliKelimeler.contains(bitisikKelime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.profanityNameError),
            backgroundColor: Colors.red),
      );
      return false;
    }

    List<String> kelimeler = sadeceHarflerVeBosluk.split(RegExp(r'\s+'));
    for (var kelime in kelimeler) {
      if (yasakliKelimeler.contains(kelime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.profanityNameError),
              backgroundColor: Colors.red),
        );
        return false;
      }
    }

    return true;
  }
// ---------------- BÖLÜM 3 SONU ----------------

// ==========================================
// BÖLÜM 4: CİHAZ, KAYIT VE FİREBASE İŞLEMLERİ (BACKEND & STORAGE)
// ==========================================
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

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        return "web_device_${DateTime.now().millisecondsSinceEpoch}";
      }

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
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

  Future<void> _girisYap(String name, int yuz, int aksesuar, int renk) async {
    try {
      await _saveUser(name, yuz, aksesuar, renk);
      String deviceId = await _getDeviceId();
      String safeName = trToLowerCase(name).replaceAll(RegExp(r'\s+'), '_');
      final userDoc = FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc("${deviceId}_$safeName");

      await userDoc.set({
        'deviceId': deviceId,
        'oyuncuAdi': name,
        'yuzIndex': yuz,
        'aksesuarIndex': aksesuar,
        'renkIndex': renk,
        'sonGirisTarihi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameModePage(
              oyuncuAdi: name,
              yuzIndex: yuz,
              aksesuarIndex: aksesuar,
              renkIndex: renk,
            ),
          ),
        );
        if (mounted) _loadSavedUser();
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.connectionTimeoutError),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Firebase Kullanıcı Kayıt Hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.serverConnectionError),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
// ---------------- BÖLÜM 4 SONU ----------------

// ==========================================
// BÖLÜM 5: KULLANICI ARAYÜZÜ (BUILD METODU VE WIDGET'LAR)
// ==========================================
  @override
  Widget build(BuildContext context) {
    final Color activeColor = renkler[(savedRenkIndex ?? 0).clamp(0, renkler.length - 1)];
    final String mevcutOyuncu = savedOyuncuAdi ??
        (_nameController.text.trim().isEmpty ? AppLocalizations.of(context)!.defaultPlayerName : _nameController.text.trim());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        // 🚀 İŞTE YENİ SOL DİL MENÜSÜ BURADA BAŞLIYOR 🚀
        leading: PopupMenuButton<Locale>(
          icon: const Icon(Icons.language, color: Colors.indigo, size: 28),
          tooltip: "Dil Seçimi / Language",
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          onSelected: (Locale locale) {
            appLocale.value = locale; // Seçilen dili anında uygular
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
            const PopupMenuItem<Locale>(value: Locale('tr'), child: Text("🇹🇷 Türkçe")),
            const PopupMenuItem<Locale>(value: Locale('de'), child: Text("🇩🇪 Deutsch")),
            const PopupMenuItem<Locale>(value: Locale('en'), child: Text("🇬🇧 English")),
            const PopupMenuItem<Locale>(value: Locale('es'), child: Text("🇪🇸 Español")),
          ],
        ),
        // 🚀 SOL DİL MENÜSÜ SONU 🚀
        actions: [
          if (hasSavedUser && savedOyuncuAdi != null)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.indigo, size: 32),
                tooltip: AppLocalizations.of(context)!.menuTooltip,
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          if (hasSavedUser && savedOyuncuAdi != null) const SizedBox(width: 8),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 45, color: Colors.indigo.shade700),
              ),
              accountName: Text(mevcutOyuncu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text(AppLocalizations.of(context)!.welcomeContestant),
            ),



            // --- ESKİ MENÜ ELEMANLARI (Oyun Kuralları, Gizlilik vb.) ---
            ListTile(
              leading: const Icon(Icons.menu_book_rounded, color: Colors.indigo),
              title: Text(AppLocalizations.of(context)!.gameRules, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(AppLocalizations.of(context)!.gameRulesSubtitle),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RulesPage()));
              },
            ),

            // 🚀 GİZLİLİK POLİTİKASI DÜZELTİLDİ 🚀
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: Colors.indigo),
              title: Text(AppLocalizations.of(context)!.privacyPolicy, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Text(AppLocalizations.of(context)!.privacyPolicySubtitle),
              onTap: () {
                Navigator.pop(context); // Menüyü kapat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.mark_email_unread_rounded, color: Colors.indigo),
              title: Text(AppLocalizations.of(context)!.contactUs, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(AppLocalizations.of(context)!.contactUsSubtitle),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ContactUsPage(oyuncuAdi: mevcutOyuncu)));
              },
            ),
            const Divider(height: 1),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(AppLocalizations.of(context)!.versionText, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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
                child: Image.asset('assets/logo.png', height: 120),
              ),
              const SizedBox(height: 15),
              Text(AppLocalizations.of(context)!.gameTitle,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple)),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.gameSubtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black)),
              const SizedBox(height: 30),
              if (hasSavedUser && savedOyuncuAdi != null) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: activeColor.withAlpha(25),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(AppLocalizations.of(context)!.lastLoggedInPlayer,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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
                        Text(savedOyuncuAdi!,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: activeColor)),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _girisYap(savedOyuncuAdi!, savedYuzIndex!, savedAksesuarIndex!, savedRenkIndex!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeColor,
                            disabledBackgroundColor: Colors.grey.shade400,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : Text(AppLocalizations.of(context)!.continueWithSamePlayer,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      secilenYuzIndex = 0;
                      secilenAksesuarIndex = 0;
                      secilenRenkIndex = 0;
                    });
                  },
                  icon: const Icon(Icons.swap_horiz, color: Colors.indigo),
                  label: Text(AppLocalizations.of(context)!.loginWithDifferentName,
                      style: const TextStyle(color: Colors.indigo, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                if (savedOyuncuAdi != null) ...[
                  InkWell(
                    onTap: () => setState(() => hasSavedUser = true),
                    borderRadius: BorderRadius.circular(30),
                    splashColor: Colors.indigo.withAlpha(30),
                    highlightColor: Colors.indigo.withAlpha(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withAlpha(15),
                        border: Border.all(color: Colors.indigo.withAlpha(40), width: 1.5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Text(
                              yuzler[(savedYuzIndex ?? 0).clamp(0, yuzler.length - 1)],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 180), // En fazla 180 piksel genişleyebilir
                            child: Text(
                              "${savedOyuncuAdi!} ${AppLocalizations.of(context)!.returnToProfile}",
                              style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.2),
                              overflow: TextOverflow.ellipsis, // Sığmazsa sonuna 3 nokta (...) koyar
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.indigo, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
                TextField(
                  controller: _nameController,
                  maxLength: 15,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.playerNameLabel,
                    prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.customizeAvatar,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo))),
                const SizedBox(height: 15),

                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.chooseExpression, style: const TextStyle(color: Colors.black, fontSize: 12))),
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
                            color: secilenYuzIndex == index ? Colors.indigo.withAlpha(25) : Colors.transparent,
                            border: Border.all(
                                color: secilenYuzIndex == index ? Colors.indigo : Colors.grey.shade300, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(yuzler[index], style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),

                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.chooseAccessory, style: const TextStyle(color: Colors.black, fontSize: 12))),
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
                            color: secilenAksesuarIndex == index ? Colors.indigo.withAlpha(25) : Colors.transparent,
                            border: Border.all(
                                color: secilenAksesuarIndex == index ? Colors.indigo : Colors.grey.shade300,
                                width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(aksesuarlar[index], style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),

                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.chooseThemeColor, style: const TextStyle(color: Colors.black, fontSize: 12))),
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
                            border: Border.all(
                                color: secilenRenkIndex == index ? Colors.black87 : Colors.transparent, width: 2.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 35),

                // 🚀 BÜYÜK SİHİR BURADA: YAPAY ZEKA GÜVENLİĞİ EKLENDİ 🚀
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                    final name = _nameController.text.trim();

                    if (!_isimUygunMu(name)) return;

                    setState(() {
                      _isLoading = true;
                    });

                    bool isimTemizMi = await GeminiService.isimUygunMu(name);

                    if (!mounted) return;

                    if (!isimTemizMi) {
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.aiProfanityError),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    await _girisYap(name, secilenYuzIndex, secilenAksesuarIndex, secilenRenkIndex);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    disabledBackgroundColor: Colors.grey.shade400,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text(AppLocalizations.of(context)!.loginAndStart,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}