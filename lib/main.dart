// ==========================================
// BÖLÜM 1: KÜTÜPHANELER VE İÇE AKTARMALAR (IMPORTS)
// ==========================================
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // 🎯 Google AdMob Kütüphanesi
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🟢 KİMLİK DOĞRULAMA İÇİN EKLENDİ
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'; // Hataları yakalamak için gerekli
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 🟢 GİZLİ KASA KÜTÜPHANESİ EKLENDİ

import 'database_helper.dart';
import 'login_page.dart';
import 'deep_link_service.dart';
import 'firebase_options.dart';
import 'ad_service.dart'; // 🔴 YENİ EKLENDİ: Reklam ve İzin Servisimizi Tanıması İçin
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';


// ---------------- BÖLÜM 1 SONU ----------------

// ==========================================
// BÖLÜM 2: TEMEL BAŞLATMA VE ÇEVRE DEĞİŞKENLERİ (.env)
// ==========================================
final ValueNotifier<Locale> appLocale = ValueNotifier<Locale>(const Locale('tr'));
// 🟢 void main yerine Future<void> main kullanıldı (Asenkron işlemler için)
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // 🟢 GİZLİ KASA (.env) YÜKLEMESİ (Çökme korumalı try-catch ile eklendi)
  try {
    await dotenv.load(fileName: ".env");

    // 🔍 DEDEKTİF KODU BURADA: Şifre gerçekten okunuyor mu bakıyoruz!
    String testSifre = dotenv.env['GEMINI_API_KEY'] ?? "BOS";
    debugPrint("🕵️ .env KONTROLÜ -> Şifre uzunluğu: ${testSifre.length}");
  } catch (e) {
    debugPrint("🚨 .env dosyası bulunamadı veya yüklenemedi: $e");
  }
// ---------------- BÖLÜM 2 SONU ----------------

// ==========================================
// BÖLÜM 3: FIREBASE, CRASHLYTICS VE KİMLİK DOĞRULAMA (AUTH)
// ==========================================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🎯 FIREBASE CRASHLYTICS HATA YAKALAYICILARI
  // 1. Flutter çerçevesindeki (görünüm, widget) tüm ölümcül hataları yakalar
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 2. Arka planda (asenkron, veritabanı vb.) olan gizli hataları yakalar
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 🟢 ÇÖZÜM NOKTASI: Veritabanı işlemlerinden ÖNCE Anonim Giriş yapıyoruz!
  try {
    await FirebaseAuth.instance.signInAnonymously();
    debugPrint(
        "✅ Firebase Anonim Giriş Başarılı! Artık Firestore veri izni verecek.");
  } catch (e) {
    debugPrint("🚨 Firebase Anonim Giriş Hatası: $e");
  }
// ---------------- BÖLÜM 3 SONU ----------------

// ==========================================
// BÖLÜM 4: REKLAM MOTORU, YEREL VERİTABANI VE UYGULAMA BAŞLATMA
// ==========================================
  // 🔴 YENİ YAPI: Önce Apple ATT İzinlerini sorar, sonra AdMob'u başlatır
  try {
    await AdService.instance.initializeAds();
  } catch (e) {
    debugPrint(
        "AdMob veya İzin Sistemi Web üzerinde çalışmadığı için atlandı: $e");
  }

  try {
    // 3. SQLite Veritabanı ve Arka Plan Senkronizasyonu
    // Giriş yapıldığı için artık permission-denied hatası VERMEYECEK!
    DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint("SQLite Web üzerinde çalışmadığı için atlandı.");
  }

  // 🎯 İŞTE EKSİK OLAN VE OYUNU BAŞLATAN O SİHİRLİ SATIR:
  runApp(const MyApp());
}
// ---------------- BÖLÜM 4 SONU ----------------

// ==========================================
// BÖLÜM 5: UYGULAMA KÖK SINIFI (MYAPP) VE ARAYÜZ YAPILANDIRMASI
// ==========================================
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
// 🚀 KUMANDAYI DİNLEYEN YENİ YAPI
return ValueListenableBuilder<Locale>(
valueListenable: appLocale,
builder: (context, locale, child) {
return MaterialApp(
title: 'İsim Şehir',
debugShowCheckedModeBanner: false,
theme: ThemeData(
colorScheme: ColorScheme.fromSeed(
seedColor: Colors.indigo,
primary: Colors.indigo,
),
useMaterial3: true,
scaffoldBackgroundColor: Colors.white,
),

// --- ÇOKLU DİL MOTORU BAŞLANGICI ---
localizationsDelegates: const [
AppLocalizations.delegate,
GlobalMaterialLocalizations.delegate,
GlobalWidgetsLocalizations.delegate,
GlobalCupertinoLocalizations.delegate,
],

// 🚀 DİKKAT: Artık sabit 'de' veya 'tr' değil, yukarıdaki kumandadan gelen 'locale' kelimesini kullanıyoruz.
locale: locale,

supportedLocales: const [
Locale('tr', ''),
Locale('de', ''),
Locale('en', ''),
Locale('es', ''),
],
// --- ÇOKLU DİL MOTORU SONU ---
  home: const LoginPage(),
);
},
);
  } // <--- 1. EKSİK OLABİLECEK PARANTEZ (build metodunu kapatır)
} // <--- 2. EKSİK OLABİLECEK PARANTEZ (Sınıfı kapatır)
// ---------------- BÖLÜM 5 SONU ----------------
