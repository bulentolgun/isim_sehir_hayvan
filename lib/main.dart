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


// BÖLÜM 3: FIREBASE, CRASHLYTICS VE KİMLİK DOĞRULAMA (AUTH) (ZIRHLI VERSİYON)
/// ==========================================


  // 🚀 YENİ YÖNTEM: HATA YUTUCU ZIRH
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("⚠️ Firebase zaten çalışıyor (Android Otomatik Başlatma). Hata yoksayıldı!");
  }

  // 👇 GÜVENLİK KALKANI GEÇİCİ OLARAK DEVRE DIŞI BIRAKILDI 👇
  /*
  await FirebaseAppCheck.instance.activate(
    androidProvider: kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    appleProvider: kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
    webProvider: ReCaptchaEnterpriseProvider('6Ldav8ktAAAAAMKMWLgpPganmxfUVxmV9QUAtdf5'),
  );

  try {
    final appCheckToken = await FirebaseAppCheck.instance.getToken(true);
    debugPrint("🛡️ App Check Jetonu başarıyla alındı: $appCheckToken");
  } catch (e) {
    debugPrint("🚨 App Check Jeton HATA: $e");
  }
  */
  // 👆 YORUMA ALMA İŞLEMİ BİTTİ 👆


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

          // ============================================================================
          // 🚀 AKILLI GÖRÜNÜM: MOBİLDE APP GİBİ, MASAÜSTÜNDE WEB GİBİ
          // ============================================================================
          builder: (context, child) {
            if (kIsWeb) {
              // Ekran genişliğini anlık olarak ölçüyoruz
              return LayoutBuilder(
                builder: (context, constraints) {
                  // EĞER KULLANICI MASAÜSTÜ BİLGİSAYARDAN (VEYA YATAY TABLETTEN) GİRİYORSA:
                  if (constraints.maxWidth > 600) {
                    return Container(
                      color: Colors.blueGrey.shade50, // Masaüstü arka plan boşluk rengi
                      child: Center(
                        child: ConstrainedBox(
                          // Bilgisayar ekranında oyunu maksimum 800 piksele sabitle
                          // Böylece butonlar devasa uzamaz, masaüstü sitesi gibi şık durur
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15), // Hafif masaüstü gölgesi
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: child, // Oyun burada çalışır
                          ),
                        ),
                      ),
                    );
                  }

                  // EĞER KULLANICI CEP TELEFONUNUN TARAYICISINDAN GİRİYORSA:
                  // Hiçbir kısıtlama yapma, tam ekran %100 normal APP gibi çalışsın!
                  return child!;
                },
              );
            }

            // Eğer oyun mağazadan indirilen yerel uygulamadaysa zaten tam ekran APP gibi çalışır
            return child!;
          },
          // ============================================================================
          // 🚀 AKILLI GÖRÜNÜM BİTİŞİ
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
          home: const YnlendirmePolisi(), // 🚀 YENİ POLİSİMİZ BURADA
        );
      },
    );
  }
}
// ---------------- BÖLÜM 5 SONU ----------------
// ==========================================
// BÖLÜM 6: WEB & MOBİL ÇAKIŞMA POLİSİ (YENİ)
// ==========================================
class YnlendirmePolisi extends StatelessWidget {
  const YnlendirmePolisi({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚀 KURAL: Eğer kullanıcı WEB tarayıcısından giriyorsa VE cihazı bir telefon/tablet ise:
    if (kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
      return Scaffold(
        backgroundColor: Colors.purple.shade900,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phonelink_ring_rounded, color: Colors.greenAccent, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "Uygulamaya Yönlendiriliyorsunuz...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Bağlantı çakışmasını önlemek için oyunun tarayıcı sürümü duraklatıldı. Lütfen açılan yerel uygulamadan devam edin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Eğer arkadaşınızda uygulama yüklü değilse mecburen web'den oynayabilmesi için manuel izin butonu
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text("Uygulama Açılmadıysa Tarayıcıdan Devam Et", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                )
              ],
            ),
          ),
        ),
      );
    }

    // 🟢 KURAL 2: Eğer gerçek bir PC'den (Windows/Mac) web'e giriyorsa veya doğrudan uygulamanın kendisindeyse normal başlat:
    return const LoginPage();
  }
}