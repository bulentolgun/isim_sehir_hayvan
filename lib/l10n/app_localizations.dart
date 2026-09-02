import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('tr')
  ];

  /// No description provided for @gameTitle.
  ///
  /// In tr, this message translates to:
  /// **'İsim Şehir Hayvan'**
  String get gameTitle;

  /// No description provided for @gameSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Zekanı yarıştır, rakibini geride bırak!'**
  String get gameSubtitle;

  /// No description provided for @readyButton.
  ///
  /// In tr, this message translates to:
  /// **'HAZIR 👍'**
  String get readyButton;

  /// No description provided for @finishTurnButton.
  ///
  /// In tr, this message translates to:
  /// **'DUR!'**
  String get finishTurnButton;

  /// No description provided for @nameTooShortError.
  ///
  /// In tr, this message translates to:
  /// **'İsminiz en az 2 harften oluşmalıdır!'**
  String get nameTooShortError;

  /// No description provided for @profanityNameError.
  ///
  /// In tr, this message translates to:
  /// **'Uygunsuz takma ad tespiti! Lütfen başka bir isim seçin.'**
  String get profanityNameError;

  /// No description provided for @connectionTimeoutError.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı zaman aşımına uğradı! Lütfen internetinizi kontrol edin.'**
  String get connectionTimeoutError;

  /// No description provided for @serverConnectionError.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya bağlanılamadı. Lütfen tekrar deneyin.'**
  String get serverConnectionError;

  /// No description provided for @defaultPlayerName.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu'**
  String get defaultPlayerName;

  /// No description provided for @menuTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Menü'**
  String get menuTooltip;

  /// No description provided for @welcomeContestant.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin Yarışmacı! 🎮'**
  String get welcomeContestant;

  /// No description provided for @gameRules.
  ///
  /// In tr, this message translates to:
  /// **'Oyun Kuralları'**
  String get gameRules;

  /// No description provided for @gameRulesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Puanlama ve yarışma rehberi'**
  String get gameRulesSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'İsim Şehir Oyunu Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Veri kullanımı ve gizlilik haklarınız'**
  String get privacyPolicySubtitle;

  /// No description provided for @contactUs.
  ///
  /// In tr, this message translates to:
  /// **'Bize Ulaşın'**
  String get contactUs;

  /// No description provided for @contactUsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet, öneri ve destek'**
  String get contactUsSubtitle;

  /// No description provided for @versionText.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon 1.0.0'**
  String get versionText;

  /// No description provided for @lastLoggedInPlayer.
  ///
  /// In tr, this message translates to:
  /// **'Son Giriş Yapan Oyuncu'**
  String get lastLoggedInPlayer;

  /// No description provided for @continueWithSamePlayer.
  ///
  /// In tr, this message translates to:
  /// **'Aynı Oyuncuyla Devam Et'**
  String get continueWithSamePlayer;

  /// No description provided for @loginWithDifferentName.
  ///
  /// In tr, this message translates to:
  /// **'Farklı bir isimle giriş yap'**
  String get loginWithDifferentName;

  /// No description provided for @returnToProfile.
  ///
  /// In tr, this message translates to:
  /// **'profiline dön'**
  String get returnToProfile;

  /// No description provided for @playerNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu Adınız'**
  String get playerNameLabel;

  /// No description provided for @customizeAvatar.
  ///
  /// In tr, this message translates to:
  /// **'Avatarını Özelleştir'**
  String get customizeAvatar;

  /// No description provided for @chooseExpression.
  ///
  /// In tr, this message translates to:
  /// **'İfade Seç:'**
  String get chooseExpression;

  /// No description provided for @chooseAccessory.
  ///
  /// In tr, this message translates to:
  /// **'Aksesuar Seç:'**
  String get chooseAccessory;

  /// No description provided for @chooseThemeColor.
  ///
  /// In tr, this message translates to:
  /// **'Tema Rengi Seç:'**
  String get chooseThemeColor;

  /// No description provided for @aiProfanityError.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı uygunsuz ifadeler içeriyor! Lütfen başka bir isim seçin.'**
  String get aiProfanityError;

  /// No description provided for @loginAndStart.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap ve Başla'**
  String get loginAndStart;

  /// No description provided for @chooseGameMode.
  ///
  /// In tr, this message translates to:
  /// **'OYUN MODU SEÇİN'**
  String get chooseGameMode;

  /// No description provided for @welcomePlayer.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin'**
  String get welcomePlayer;

  /// No description provided for @howToPlay.
  ///
  /// In tr, this message translates to:
  /// **'Nasıl oynamak istersin?'**
  String get howToPlay;

  /// No description provided for @playWithFriends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlarınla Oyna (2-10 Kişi)'**
  String get playWithFriends;

  /// No description provided for @findOpponent.
  ///
  /// In tr, this message translates to:
  /// **'Rakip Bul (Hızlı Kapışma)'**
  String get findOpponent;

  /// No description provided for @returnToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Sayfasına Dön'**
  String get returnToLogin;

  /// No description provided for @scoreText.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get scoreText;

  /// No description provided for @rankText.
  ///
  /// In tr, this message translates to:
  /// **'Sıra'**
  String get rankText;

  /// No description provided for @friendRoomTitle.
  ///
  /// In tr, this message translates to:
  /// **'ARKADAŞ ODASI'**
  String get friendRoomTitle;

  /// No description provided for @tournamentRoundsTitle.
  ///
  /// In tr, this message translates to:
  /// **'TURNUVA TUR SAYISI'**
  String get tournamentRoundsTitle;

  /// No description provided for @friendRoomSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin {playerName}! Oda açıp arkadaş grubunu davet edebilirsin.'**
  String friendRoomSubtitle(String playerName);

  /// No description provided for @tournamentRoundsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin {playerName}, kaç tur yarışmak istersiniz?'**
  String tournamentRoundsSubtitle(String playerName);

  /// No description provided for @createRoomButton.
  ///
  /// In tr, this message translates to:
  /// **'Oda Oluştur (2-10 Kişi)'**
  String get createRoomButton;

  /// No description provided for @joinWithCodeButton.
  ///
  /// In tr, this message translates to:
  /// **'Oda Kodu ile Katıl'**
  String get joinWithCodeButton;

  /// No description provided for @quickMatch.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Kapışma'**
  String get quickMatch;

  /// No description provided for @standardLeague.
  ///
  /// In tr, this message translates to:
  /// **'Standart Lig'**
  String get standardLeague;

  /// No description provided for @marathonGiants.
  ///
  /// In tr, this message translates to:
  /// **'Maraton Devleri'**
  String get marathonGiants;

  /// No description provided for @goBackButton.
  ///
  /// In tr, this message translates to:
  /// **'Geri Dön'**
  String get goBackButton;

  /// No description provided for @roundText.
  ///
  /// In tr, this message translates to:
  /// **'TUR'**
  String get roundText;

  /// No description provided for @searchingOpponent.
  ///
  /// In tr, this message translates to:
  /// **'Rakip Aranıyor'**
  String get searchingOpponent;

  /// No description provided for @waitingForOpponent.
  ///
  /// In tr, this message translates to:
  /// **'Rakip bekleniyor...'**
  String get waitingForOpponent;

  /// No description provided for @matchFound.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşme Tamam!'**
  String get matchFound;

  /// No description provided for @timeText.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get timeText;

  /// No description provided for @roomClosedOrNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Oda kapatıldı veya bulunamadı.'**
  String get roomClosedOrNotFound;

  /// No description provided for @gameRoom.
  ///
  /// In tr, this message translates to:
  /// **'Oyun Odası'**
  String get gameRoom;

  /// No description provided for @roomCode.
  ///
  /// In tr, this message translates to:
  /// **'ODA KODU'**
  String get roomCode;

  /// No description provided for @copyButton.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get copyButton;

  /// No description provided for @roomCodeCopied.
  ///
  /// In tr, this message translates to:
  /// **'Oda kodu panoya kopyalandı!'**
  String get roomCodeCopied;

  /// No description provided for @inviteFriend.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşını Davet Et'**
  String get inviteFriend;

  /// No description provided for @joinedPlayers.
  ///
  /// In tr, this message translates to:
  /// **'Katılan Oyuncular'**
  String get joinedPlayers;

  /// No description provided for @youText.
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get youText;

  /// No description provided for @leaveButton.
  ///
  /// In tr, this message translates to:
  /// **'Ayrıl'**
  String get leaveButton;

  /// No description provided for @startGameButton.
  ///
  /// In tr, this message translates to:
  /// **'Oyunu Başlat'**
  String get startGameButton;

  /// No description provided for @enterRoomCode.
  ///
  /// In tr, this message translates to:
  /// **'Oda Kodunu Girin'**
  String get enterRoomCode;

  /// No description provided for @cancelButton.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancelButton;

  /// No description provided for @joinButton.
  ///
  /// In tr, this message translates to:
  /// **'Katıl'**
  String get joinButton;

  /// No description provided for @roomFullError.
  ///
  /// In tr, this message translates to:
  /// **'Oda kapasitesi dolu (Maksimum 10 kişi)!'**
  String get roomFullError;

  /// No description provided for @roomNotFoundError.
  ///
  /// In tr, this message translates to:
  /// **'Böyle bir oda bulunamadı!'**
  String get roomNotFoundError;

  /// No description provided for @rulesPageTitle.
  ///
  /// In tr, this message translates to:
  /// **'📜 Oyun Kuralları'**
  String get rulesPageTitle;

  /// No description provided for @rule1Title.
  ///
  /// In tr, this message translates to:
  /// **'1. Harf Kuralı'**
  String get rule1Title;

  /// No description provided for @rule1Desc.
  ///
  /// In tr, this message translates to:
  /// **'Her turun başında rastgele bir harf seçilir. Yazacağınız tüm kelimeler bu harf ile başlamalıdır.'**
  String get rule1Desc;

  /// No description provided for @rule2Title.
  ///
  /// In tr, this message translates to:
  /// **'2. Kategori Puanlaması'**
  String get rule2Title;

  /// No description provided for @rule2Desc.
  ///
  /// In tr, this message translates to:
  /// **'• İki oyuncu aynı doğru kelimeyi yazarsa: 5 Puan\n• İki oyuncu farklı doğru kelimeler yazarsa: 10 Puan\n• Sadece tek oyuncu doğru kelime yazarsa: 20 Puan\n• Doğru bilinen en uzun kelimeye: +2 Puan Bonus\n• Maçı kazanan oyuncu +100 Puan alır.'**
  String get rule2Desc;

  /// No description provided for @rule3Title.
  ///
  /// In tr, this message translates to:
  /// **'3. Turu Erken Bitirme & 20 Sn Kuralı'**
  String get rule3Title;

  /// No description provided for @rule3Desc.
  ///
  /// In tr, this message translates to:
  /// **'En az 5 kategoriyi doldurduğunuzda \'TURU BİTİR\' butonuna basabilirsiniz. Sayaç anında 20 saniyeye düşer ve tur sonunda +10 Zaman Bonusu kazanırsınız.'**
  String get rule3Desc;

  /// No description provided for @rule4Title.
  ///
  /// In tr, this message translates to:
  /// **'4. 🏆 Maç Sonu Galibiyet Bonusu'**
  String get rule4Title;

  /// No description provided for @rule4Desc.
  ///
  /// In tr, this message translates to:
  /// **'• Maç bittiğinde, maçı kim kazandıysa genel puanına ve liderlik tablosuna kaydedilmek üzere +100 Galibiyet Bonusu eklenir.\n• Beraberlik durumunda kimseye ekstra +100 eklenmez, sadece maçta toplanan ham puanlar genel skora yansır.'**
  String get rule4Desc;

  /// No description provided for @rule5Title.
  ///
  /// In tr, this message translates to:
  /// **'5. Geçerli Kelimeler'**
  String get rule5Title;

  /// No description provided for @rule5Desc.
  ///
  /// In tr, this message translates to:
  /// **'Eşya, Hayvan, Bitki ve Ülke kategorilerinde sadece gerçek ve somut kelimeler kabul edilir. TDK\'deki soyut veya kural dışı kelimeler puan almaz.'**
  String get rule5Desc;

  /// No description provided for @understoodButton.
  ///
  /// In tr, this message translates to:
  /// **'ANLADIM, OYUNA DÖN 👍'**
  String get understoodButton;

  /// No description provided for @contactUsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bize Ulaşın'**
  String get contactUsTitle;

  /// No description provided for @feedbackSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Geri bildiriminiz başarıyla iletildi. Teşekkür ederiz! 🎉'**
  String get feedbackSuccess;

  /// No description provided for @feedbackError.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj gönderilirken hata oluştu:'**
  String get feedbackError;

  /// No description provided for @anonymousPlayer.
  ///
  /// In tr, this message translates to:
  /// **'Anonim Oyuncu'**
  String get anonymousPlayer;

  /// No description provided for @feedbackHeader.
  ///
  /// In tr, this message translates to:
  /// **'Görüşleriniz Bizim İçin Değerli!'**
  String get feedbackHeader;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin {playerName}! Oyunla ilgili şikayet, öneri veya karşılaştığın hataları bize iletebilirsin.'**
  String feedbackSubtitle(String playerName);

  /// No description provided for @feedbackSubjectLabel.
  ///
  /// In tr, this message translates to:
  /// **'Konu / Bildirim Türü'**
  String get feedbackSubjectLabel;

  /// No description provided for @emailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-Posta Adresiniz (Geri dönüş için)'**
  String get emailLabel;

  /// No description provided for @invalidEmailError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir e-posta adresi girin.'**
  String get invalidEmailError;

  /// No description provided for @messageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mesajınız'**
  String get messageLabel;

  /// No description provided for @messageHint.
  ///
  /// In tr, this message translates to:
  /// **'Düşüncelerinizi veya karşılaştığınız sorunu detaylıca yazabilirsiniz...'**
  String get messageHint;

  /// No description provided for @emptyMessageError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen mesajınızı yazın.'**
  String get emptyMessageError;

  /// No description provided for @shortMessageError.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen en az 10 karakterlik bir açıklama yazın.'**
  String get shortMessageError;

  /// No description provided for @sendingButton.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor...'**
  String get sendingButton;

  /// No description provided for @sendMessageButton.
  ///
  /// In tr, this message translates to:
  /// **'Mesajı Gönder'**
  String get sendMessageButton;

  /// No description provided for @feedbackTypeSuggestion.
  ///
  /// In tr, this message translates to:
  /// **'Öneri'**
  String get feedbackTypeSuggestion;

  /// No description provided for @feedbackTypeComplaint.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet'**
  String get feedbackTypeComplaint;

  /// No description provided for @feedbackTypeBug.
  ///
  /// In tr, this message translates to:
  /// **'Hata Bildirimi'**
  String get feedbackTypeBug;

  /// No description provided for @feedbackTypeOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get feedbackTypeOther;

  /// No description provided for @cheatingWarning.
  ///
  /// In tr, this message translates to:
  /// **'Oyun ekranından 5 saniyeden fazla ayrıldığınız için kağıdınıza el konuldu!'**
  String get cheatingWarning;

  /// No description provided for @playerEliminatedWarning.
  ///
  /// In tr, this message translates to:
  /// **'⚠️ {playerName} boş kağıt verdiği (veya koptuğu) için elendi!'**
  String playerEliminatedWarning(String playerName);

  /// No description provided for @newHostWarning.
  ///
  /// In tr, this message translates to:
  /// **'👑 Kurucu ayrıldı. Odanın yeni kurucusu sizsiniz!'**
  String get newHostWarning;

  /// No description provided for @winByForfeitTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hükmen Galibiyet! 🏆'**
  String get winByForfeitTitle;

  /// No description provided for @winByForfeitDesc.
  ///
  /// In tr, this message translates to:
  /// **'Diğer tüm oyuncuların bağlantısı koptuğu için oyunu hükmen kazandınız!'**
  String get winByForfeitDesc;

  /// No description provided for @goToResultsButton.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç Sayfasına Git'**
  String get goToResultsButton;

  /// No description provided for @eliminatedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Elendiniz! ❌'**
  String get eliminatedTitle;

  /// No description provided for @eliminatedDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hiçbir kategoriye kelime yazmadığınız için (veya bağlantınız koptuğu için) bu oyundan elendiniz.'**
  String get eliminatedDesc;

  /// No description provided for @returnToMainMenuButton.
  ///
  /// In tr, this message translates to:
  /// **'Ana Menüye Dön'**
  String get returnToMainMenuButton;

  /// No description provided for @wrongLetterWarning.
  ///
  /// In tr, this message translates to:
  /// **'Girdiğiniz kelime \'{letter}\' harfi ile başlamalıdır!'**
  String wrongLetterWarning(String letter);

  /// No description provided for @inappropriateWordWarning.
  ///
  /// In tr, this message translates to:
  /// **'Uygunsuz kelime tespiti!'**
  String get inappropriateWordWarning;

  /// No description provided for @singleNameWarning.
  ///
  /// In tr, this message translates to:
  /// **'İsim bölümüne sadece tek bir isim girebilirsiniz!'**
  String get singleNameWarning;

  /// No description provided for @connectionError.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı sorunu!'**
  String get connectionError;

  /// No description provided for @checkingWords.
  ///
  /// In tr, this message translates to:
  /// **'Kelimeler Kontrol Ediliyor... 🚀'**
  String get checkingWords;

  /// No description provided for @answersSavedWaiting.
  ///
  /// In tr, this message translates to:
  /// **'Cevaplarınız Kaydedildi! 🚀\nDiğer Oyuncular Bekleniyor...'**
  String get answersSavedWaiting;

  /// No description provided for @noOpponent.
  ///
  /// In tr, this message translates to:
  /// **'Rakip Yok'**
  String get noOpponent;

  /// No description provided for @roundNumberLabel.
  ///
  /// In tr, this message translates to:
  /// **'{roundNo}. TUR'**
  String roundNumberLabel(int roundNo);

  /// No description provided for @timeBonus.
  ///
  /// In tr, this message translates to:
  /// **'ZAMAN BONUSU'**
  String get timeBonus;

  /// No description provided for @everyoneReady.
  ///
  /// In tr, this message translates to:
  /// **' Herkes Hazır! İlerleniyor...'**
  String get everyoneReady;

  /// No description provided for @playersReady.
  ///
  /// In tr, this message translates to:
  /// **'⏳ {ready} / {total} Oyuncu Hazır'**
  String playersReady(int ready, int total);

  /// No description provided for @waitingReady.
  ///
  /// In tr, this message translates to:
  /// **'HAZIR BEKLİYOR...'**
  String get waitingReady;

  /// No description provided for @seeResultsWithTimer.
  ///
  /// In tr, this message translates to:
  /// **'SONUÇLARI GÖR 🏆 ({time} sn)'**
  String seeResultsWithTimer(int time);

  /// No description provided for @readyWithTimer.
  ///
  /// In tr, this message translates to:
  /// **'HAZIRIM 👍 ({time} sn)'**
  String readyWithTimer(int time);

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'İsim Şehir Hayvan Oyunu'**
  String get appTitle;

  /// No description provided for @tourProgress.
  ///
  /// In tr, this message translates to:
  /// **'Tur: {current} / {total}'**
  String tourProgress(int current, int total);

  /// No description provided for @secondsLeft.
  ///
  /// In tr, this message translates to:
  /// **'{sec} sn'**
  String secondsLeft(int sec);

  /// No description provided for @currentLetterLabel.
  ///
  /// In tr, this message translates to:
  /// **'Harf: {letter}'**
  String currentLetterLabel(String letter);

  /// No description provided for @categoryLabel.
  ///
  /// In tr, this message translates to:
  /// **'{category} Kategorisi'**
  String categoryLabel(String category);

  /// No description provided for @typeYourWordHint.
  ///
  /// In tr, this message translates to:
  /// **'Kelimenizi buraya yazın...'**
  String get typeYourWordHint;

  /// No description provided for @twentySecondsRule.
  ///
  /// In tr, this message translates to:
  /// **'⚡ 20 SANİYE KURALI BAŞLATILDI!'**
  String get twentySecondsRule;

  /// No description provided for @waitingForTimeEnd.
  ///
  /// In tr, this message translates to:
  /// **'Sürenin Bitmesi Bekleniyor...'**
  String get waitingForTimeEnd;

  /// No description provided for @last20SecondsNoBonus.
  ///
  /// In tr, this message translates to:
  /// **'SON 20 SANİYE (BONUS KAPANDI)'**
  String get last20SecondsNoBonus;

  /// No description provided for @finishTurnWithBonus.
  ///
  /// In tr, this message translates to:
  /// **'TURU BİTİR (+10 ZAMAN BONUSU)'**
  String get finishTurnWithBonus;

  /// No description provided for @finishTurnMinWords.
  ///
  /// In tr, this message translates to:
  /// **'TURU BİTİR (EN AZ 5 KELİME YAZIN)'**
  String get finishTurnMinWords;

  /// No description provided for @previousButton.
  ///
  /// In tr, this message translates to:
  /// **'◄ Önceki'**
  String get previousButton;

  /// No description provided for @nextButton.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki ►'**
  String get nextButton;

  /// No description provided for @catName.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get catName;

  /// No description provided for @catCity.
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get catCity;

  /// No description provided for @catAnimal.
  ///
  /// In tr, this message translates to:
  /// **'Hayvan'**
  String get catAnimal;

  /// No description provided for @catPlant.
  ///
  /// In tr, this message translates to:
  /// **'Bitki'**
  String get catPlant;

  /// No description provided for @catObject.
  ///
  /// In tr, this message translates to:
  /// **'Eşya'**
  String get catObject;

  /// No description provided for @catCountry.
  ///
  /// In tr, this message translates to:
  /// **'Ülke'**
  String get catCountry;

  /// No description provided for @matchWinnerTitle.
  ///
  /// In tr, this message translates to:
  /// **'MAÇIN GALİBİSİN! 🎉'**
  String get matchWinnerTitle;

  /// No description provided for @matchTieTitle.
  ///
  /// In tr, this message translates to:
  /// **'LİDERLİĞİ PAYLAŞTIN!'**
  String get matchTieTitle;

  /// No description provided for @matchLoserTitle.
  ///
  /// In tr, this message translates to:
  /// **'MAÇI KAYBETTİN!'**
  String get matchLoserTitle;

  /// No description provided for @matchRankingTitle.
  ///
  /// In tr, this message translates to:
  /// **'MAÇ SIRALAMASI'**
  String get matchRankingTitle;

  /// No description provided for @youLabel.
  ///
  /// In tr, this message translates to:
  /// **'(Sen)'**
  String get youLabel;

  /// No description provided for @overallStatsTitle.
  ///
  /// In tr, this message translates to:
  /// **'GENEL İSTATİSTİK DURUMUN'**
  String get overallStatsTitle;

  /// No description provided for @overallScoreLabel.
  ///
  /// In tr, this message translates to:
  /// **'Genel Puanın:'**
  String get overallScoreLabel;

  /// No description provided for @rankingLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sıralaman:'**
  String get rankingLabel;

  /// No description provided for @wentUpLabel.
  ///
  /// In tr, this message translates to:
  /// **'(▲ {diff} Yükseldin)'**
  String wentUpLabel(int diff);

  /// No description provided for @wentDownLabel.
  ///
  /// In tr, this message translates to:
  /// **'(▼ {diff} Geriledin)'**
  String wentDownLabel(int diff);

  /// No description provided for @noChangeLabel.
  ///
  /// In tr, this message translates to:
  /// **'(- Değişmedi)'**
  String get noChangeLabel;

  /// No description provided for @returnToHomeButton.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfaya Dön'**
  String get returnToHomeButton;

  /// No description provided for @pointsSuffix.
  ///
  /// In tr, this message translates to:
  /// **'P'**
  String get pointsSuffix;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyLastUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Son Güncelleme: 9 Ağustos 2026'**
  String get privacyLastUpdate;

  /// No description provided for @privacyIntro.
  ///
  /// In tr, this message translates to:
  /// **'Bu gizlilik politikası, İsim Şehir mobil uygulamasını kullanan oyuncularımızın gizliliğini koruma taahhüdümüzü açıklamaktadır. Uygulamamızı kullanarak bu politikada belirtilen veri işleme süreçlerini kabul etmiş sayılırsınız.'**
  String get privacyIntro;

  /// No description provided for @privacySection1Title.
  ///
  /// In tr, this message translates to:
  /// **'1. Toplanan Veriler ve Kullanım Amacı'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Text.
  ///
  /// In tr, this message translates to:
  /// **'• Kişisel Veriler: Uygulamamız e-posta adresi, gerçek ad-soyad, T.C. kimlik numarası veya hassas konum gibi kişisel verileri toplamaz, cihazınıza kaydetmez ve sizden talep etmez.\n\n• Takma Ad ve Skorlar: Kullanıcıların belirledikleri rastgele takma adlar ve oyun skorları, sadece rakip eşleşmelerinde ve liderlik tablosunda sıralama göstermek amacıyla Firebase üzerinde güvenle saklanır.'**
  String get privacySection1Text;

  /// No description provided for @privacySection2Title.
  ///
  /// In tr, this message translates to:
  /// **'2. Reklamlar ve Üçüncü Taraf'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Text.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamamızın ücretsiz sunulabilmesi amacıyla Google AdMob kullanılmaktadır. AdMob, kullanıcılara uygun reklamlar sunmak için cihaz reklam kimliklerini kullanabilir. Ayrıca hataları tespit etmek için anonim veriler toplayan Firebase Crashlytics kullanılmaktadır.'**
  String get privacySection2Text;

  /// No description provided for @privacySection3Title.
  ///
  /// In tr, this message translates to:
  /// **'3. Çocukların Gizliliği'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Text.
  ///
  /// In tr, this message translates to:
  /// **'İsim Şehir oyunu her yaşa hitap eder. Uygulamamız 13 yaşından küçük çocuklardan bilerek herhangi bir kişisel veri (isim, e-posta, konum) toplamaz.'**
  String get privacySection3Text;

  /// No description provided for @privacySection4Title.
  ///
  /// In tr, this message translates to:
  /// **'4. Veri Güvenliği ve İletişim'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Text.
  ///
  /// In tr, this message translates to:
  /// **'Toplanan hiçbir veri pazarlama amacıyla satılmaz ve paylaşılmaz. Sistemdeki takma adlarınızın ve skorlarınızın silinmesini isterseniz, bulentolgun75@gmail.com adresi üzerinden bizimle iletişime geçebilirsiniz.'**
  String get privacySection4Text;

  /// No description provided for @closeButton.
  ///
  /// In tr, this message translates to:
  /// **'Kapat ve Geri Dön'**
  String get closeButton;

  /// No description provided for @inviteTitle.
  ///
  /// In tr, this message translates to:
  /// **'İsim Şehir Hayvan oynamaya davet edildin! 🎮'**
  String get inviteTitle;

  /// No description provided for @inviteBody.
  ///
  /// In tr, this message translates to:
  /// **'Sen de gel, yarışalım!'**
  String get inviteBody;

  /// No description provided for @inviteRoomCode.
  ///
  /// In tr, this message translates to:
  /// **'📌 Oda Kodun:'**
  String get inviteRoomCode;

  /// No description provided for @inviteLink.
  ///
  /// In tr, this message translates to:
  /// **'🔗 Hemen Katıl:'**
  String get inviteLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
