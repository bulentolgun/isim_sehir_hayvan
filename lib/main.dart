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
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';



// ---------------- BÖLÜM 1 SONU ----------------

// ==========================================
// BÖLÜM 2: TEMEL BAŞLATMA VE ÇEVRE DEĞİŞKENLERİ (.env)
// ==========================================
final ValueNotifier<Locale> appLocale = ValueNotifier<Locale>(const Locale('tr'));

Future<void> main() async {
  // 1. Flutter motorunu garantiye al
  WidgetsFlutterBinding.ensureInitialized();

  // 2. GİZLİ KASA (.env) YÜKLEMESİ
  try {
    //await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("🚨 .env dosyası bulunamadı: $e");
  }
// ---------------- BÖLÜM 2 SONU ----------------

// ==========================================
// BÖLÜM 3: FIREBASE, CRASHLYTICS VE KİMLİK DOĞRULAMA (AUTH) (ZIRHLI VERSİYON)
// ==========================================
  // 🚀 YENİ YÖNTEM: HATA YUTUCU ZIRH
  // Android zaten başlattıysa çıkan duplicate-app hatasını yutup çökmeyi engeller!
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("⚠️ Firebase zaten çalışıyor (Android Otomatik Başlatma). Hata yoksayıldı!");
  }
  await FirebaseAppCheck.instance.activate(
    // Eğer uygulama canlıdaysa PlayIntegrity (Gerçek Kullanıcı Güvenliği) kullan,
    // Eğer emülatördeysek Debug (Geliştirici) şifresini kullan.
    androidProvider: kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    appleProvider: kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,

    // 🌐 YENİ EKLENEN KISIM: WEB RECAPTCHA GÜVENLİĞİ
    webProvider: ReCaptchaV3Provider('6Leg57AtAAAAANZYzuP-O02ti22BL9lG8ow7Drfa'),
  );
// 🌟 ŞOK DALGASI: Eski bozuk jetonu çöpe at ve zorla yenisini al!
  try {
    final appCheckToken = await FirebaseAppCheck.instance.getToken();
    debugPrint("🛡️ App Check Jetonu başarıyla alındı: $appCheckToken");
  } catch (e) {
    debugPrint("🚨 App Check Jeton HATA: $e");
  }
  // 4. FIREBASE CRASHLYTICS (Hata Yakalayıcılar)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 5. GİRİŞ VE REKLAM İŞLEMLERİNİ ARKA PLANA AT (Bekleme Yok)
  FirebaseAuth.instance.signInAnonymously().then((_) {
    debugPrint("✅ Firebase Anonim Giriş Başarılı!");
  }).catchError((e) {
    debugPrint("🚨 Firebase Anonim Giriş Hatası: $e");
  });
// ---------------- BÖLÜM 3 SONU ----------------

// ==========================================
// BÖLÜM 4: REKLAM MOTORU, YEREL VERİTABANI VE UYGULAMA BAŞLATMA
// ==========================================
  if (!kIsWeb) {
    AdService.instance.initializeAds().then((_) {
      debugPrint("✅ AdMob Başarılı!");
    }).catchError((e) {
      debugPrint("❌ AdMob Hatası: $e");
    });
  }

  try {
    DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint("SQLite hatası: $e");
  }

  // 🚀 6. NE OLURSA OLSUN OYUNU EKRANA ÇİZ!
  runApp(const MyApp());
}
// ---------------- BÖLÜM 4 SONU ----------------
/// ==========================================
// BÖLÜM 5: UYGULAMA KÖK SINIFI (MYAPP) VE ARAYÜZ YAPILANDIRMASI
// ==========================================
String? globalBekleyenOdaKodu;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

      globalBekleyenOdaKodu = odaKodu;

      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text("Oda Daveti Algılandı! (Kod: $odaKodu) Odaya girmek için giriş yapın."),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'İsim Şehir',
          debugShowCheckedModeBanner: false,
          // ============================================================================
          // 🚀 EKLENEN KISIM BAŞLANGICI: WEB İÇİN TELEFON ÇERÇEVESİ TASARIMI
          // ============================================================================
          builder: (context, child) {
            // Eğer oyun WEB'de çalışıyorsa bu şık çerçeveyi çiz:
            if (kIsWeb) {
              return Container(
                color: Colors.blueGrey.shade50, // Masaüstündeki geniş boşluğun rengi (Hafif kırık beyaz/gri)
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430), // İdeal telefon genişliği
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 24), // Üstten ve alttan boşluk
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36), // Telefon gibi yuvarlak köşeler
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.15), // Temanıza uygun tatlı bir gölge
                            blurRadius: 30,
                            spreadRadius: 8,
                            offset: const Offset(0, 15), // Gölgeyi hafif aşağı vererek 3D hissi katar
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 4), // Telefon kasası hissi
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32), // İçerik köşelerden taşmasın diye kırpıyoruz
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            }

            // Eğer oyun gerçek bir MOBİL cihazda (Android/iOS) çalışıyorsa,
            // çerçeve ekleme ve direkt tam ekran yap:
            return child!;
          },
          // ============================================================================
          // 🚀 EKLENEN KISIM BİTİŞİ
          // ============================================================================
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              primary: Colors.indigo,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: locale,
          supportedLocales: const [
            Locale('tr', ''),
            Locale('de', ''),
            Locale('en', ''),
            Locale('es', ''),
          ],
          home: const LoginPage(),
        );
      },
    );
  }
}
// ---------------- BÖLÜM 5 SONU ----------------