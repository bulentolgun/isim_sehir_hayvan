import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // 🎯 Google AdMob Kütüphanesi
import 'package:firebase_core/firebase_core.dart';
import 'database_helper.dart';
import 'login_page.dart';
import 'deep_link_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // EMÜLATÖR TESTİ İÇİN ADMOB GEÇİCİ OLARAK KAPATILDI
  /*
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint("AdMob Web üzerinde çalışmadığı için atlandı.");
  }
  */

  try {
    // 3. SQLite Veritabanı ve Arka Plan Senkronizasyonu
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint("SQLite Web üzerinde çalışmadığı için atlandı.");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // 🎯 Deep Link Dinleyicisi
    DeepLinkService.initDeepLinks((odaKodu) {
      debugPrint("Gelen Otomatik Oda Kodu: $odaKodu");
      // TODO: Kullanıcı yönlendirme veya diyalog açma mantığı buraya gelecek
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İsim Şehir Hayvan Oyunu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          primary: Colors.purple,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginPage(),
    );
  }
}